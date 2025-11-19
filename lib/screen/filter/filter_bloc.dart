import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import '../../model/network/request/report_field_lookup_request.dart';
import '../../model/network/response/report_field_lookup_response.dart';
import '../../model/network/services/network_factory.dart';
import '../../utils/const.dart';
import '../../utils/utils.dart';
import 'filter_event.dart';
import 'filter_state.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String get accessToken => _accessToken!;
  String? _refreshToken;
  String get refreshToken => _refreshToken!;

  int _currentPage = 1;
  int get currentPage => _currentPage;
  int _maxPage = Const.MAX_COUNT_ITEM;
  int get maxPage => _maxPage;
  bool _hasMoreData = false;
  bool get hasMoreData => _hasMoreData;
  bool isScroll = true;
  List<ReportFieldLookupResponseData> listCheckedReport =
      <ReportFieldLookupResponseData>[];
  List<ReportFieldLookupResponseData> get _listCheckedReport =>
      listCheckedReport;

  List<ReportFieldLookupResponseData> listRPLP =
      <ReportFieldLookupResponseData>[];

  FilterBloc(this.context) : super(FilterInitial()) {
    _networkFactory = NetWorkFactory(context);
    on<GetPrefs>(_getPrefs);
    on<GetListFieldLookup>(_getListFieldLookup);
    on<AddItemSelectedEvent>(_addItemSelectedEvent);
  }
  final box = GetStorage();
  void _getPrefs(GetPrefs event, Emitter<FilterState> emitter) async {
    emitter(FilterInitial());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsSuccess());
  }

  void _getListFieldLookup(
      GetListFieldLookup event, Emitter<FilterState> emitter) async {
    emitter(FilterInitial());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    int targetPage = _currentPage;
    bool append = false;

    emitter((!isRefresh && !isLoadMore) ? FilterLoading() : FilterInitial());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        FilterState state = await handleCallApi(
          i,
          event.controller ?? '',
          event.listItem ?? '',
          event.searchTextCode ?? '',
          event.searchTextName ?? '',
        );
        if (state is! FilterSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
      targetPage = _currentPage;
      append = true;
    } else if (event.pageIndex != null && event.pageIndex! > 0) {
      targetPage = event.pageIndex!;
      _currentPage = targetPage;
    } else {
      _currentPage = 1;
      targetPage = 1;
    }
    FilterState state = await handleCallApi(
      targetPage,
      event.controller ?? '',
      event.listItem ?? '',
      event.searchTextCode ?? '',
      event.searchTextName ?? '',
      append: append,
    );

    emitter(state);
  }

  void _addItemSelectedEvent(
      AddItemSelectedEvent event, Emitter<FilterState> emitter) {
    emitter(FilterInitial());
    if (event.checked == true) {
      final exists = _listCheckedReport.any((item) =>
          item.code.toString().trim() == event.id.code.toString().trim());
      if (!exists) {
        _listCheckedReport.add(event.id);
      }
    } else {
      _listCheckedReport.removeWhere((item) =>
          item.code.toString().trim() == event.id.code.toString().trim());
    }
    emitter(SelectedSuccess());
  }

  Future<FilterState> handleCallApi(int pageIndex, String controller,
      String listItem, String code, String name,
      {bool append = false}) async {
    ReportFieldLookupRequest request = ReportFieldLookupRequest(
        controller: controller,
        pageIndex: pageIndex,
        filterValueCode: !Utils.isEmpty(code) ? code : '',
        filterValueName: !Utils.isEmpty(name) ? name : '');
    FilterState state = _handleLoadList(
        await _networkFactory!.reportFieldLookup(request, _accessToken!),
        pageIndex,
        listItem,
        append: append);
    if (state is FilterSuccess || state is FilterEmpty) {
      _currentPage = pageIndex;
    }
    return state;
  }

  FilterState _handleLoadList(Object data, int pageIndex, String listItem,
      {bool append = false}) {
    if (data is String) return FilterFailure('Úi, $data');
    try {
      ReportFieldLookupResponse response =
          ReportFieldLookupResponse.fromJson(data as Map<String, dynamic>);
      _maxPage = 20;
      List<ReportFieldLookupResponseData> listData = response.data ?? [];
      if (!Utils.isEmpty(listData) &&
          !Utils.isEmpty(listItem) &&
          listItem != 'null') {
        List<String> listItemPush = listItem.split(',');
        for (var element in listData) {
          for (var ele in listItemPush) {
            if (element.code
                .toString()
                .trim()
                .contains(ele.toString().trim())) {
              element.isChecked = true;
              _listCheckedReport.add(element);
            }
          }
        }
      }
      if (!Utils.isEmpty(_listCheckedReport)) {
        for (var element in listData) {
          element.isChecked = _listCheckedReport.any((item) =>
              item.code.toString().trim() == element.code.toString().trim());
        }
      }
      _hasMoreData = listData.length >= _maxPage;
      if (append) {
        if (_currentPage == 1 && Utils.isEmpty(listRPLP)) {
          listRPLP = List<ReportFieldLookupResponseData>.from(listData);
        } else {
          listRPLP.addAll(listData);
        }
      } else {
        listRPLP = List<ReportFieldLookupResponseData>.from(listData);
      }
      if (Utils.isEmpty(listRPLP)) {
        return FilterEmpty();
      } else {
        isScroll = true;
        return FilterSuccess();
      }
    } catch (e) {
      return FilterFailure('Úi, ${e.toString()}');
    }
  }
}
