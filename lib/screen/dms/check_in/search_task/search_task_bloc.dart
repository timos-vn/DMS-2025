import 'package:dio/dio.dart';
import 'package:dms/model/database/data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dms/model/network/services/network_factory.dart';
import 'package:dms/utils/const.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../model/entity/item_check_in.dart';
import '../../../../model/network/response/list_tour_response.dart';
import '../../../../model/network/response/search_item_taks_response.dart';
import '../../../../utils/utils.dart';
import 'search_task_event.dart';
import 'search_task_state.dart';


class SearchTaskBloc extends Bloc<SearchTaskEvent,SearchTaskState>{
  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? userName;
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  int _currentPage = 1;
  int get currentPage => _currentPage;
  int _maxPage = 20;
  bool isScroll = true;
  int get maxPage => _maxPage;

  String idTour = '';
  String nameTour = '';

  bool isShowCancelButton = false;

  List<SearchItemTaskResponseData> _searchResults = <SearchItemTaskResponseData>[];
  List<SearchItemTaskResponseData> get searchResults => _searchResults;

  late Position currentLocation;
  String currentAddress = '';

  List<ItemCheckInOffline> listCheckInOffline = [];
  List<ItemCheckInOffline> listItemReSearch = [];

  SearchTaskBloc(this.context) : super(InitialSearchTaskState()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsSearchTask>(_getPrefs);
    on<GetListTaskEvent>(_getListTaskEvent);
    on<CheckShowCloseEvent>(_checkShowCloseEvent);
    on<SearchCustomerCheckInEvent>(_searchCustomerCheckInEvent);

  }

  void _checkShowCloseEvent(CheckShowCloseEvent event, Emitter<SearchTaskState> emitter)async{
    emitter(InitialSearchTaskState());
    isShowCancelButton = !Utils.isEmpty(event.text);
    emitter(InitialSearchTaskState());
  }
  final box = GetStorage();
  void _getPrefs(GetPrefsSearchTask event, Emitter<SearchTaskState> emitter)async{
    emitter(InitialSearchTaskState());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    userName = box.read(Const.USER_NAME);
    emitter(GetPrefsSuccess());
  }

  void _getListTaskEvent(GetListTaskEvent event, Emitter<SearchTaskState> emitter)async{
    emitter(InitialSearchTaskState());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? SearchTaskLoading()
        : InitialSearchTaskState());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        SearchTaskState state = await handleCallApi(i,event.searchKey.toString(),event.dateTime);
        if (state is! GetListTaskSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    SearchTaskState state = await handleCallApi(_currentPage,event.searchKey.toString(),event.dateTime);
    emitter(state);
  }


  Future<SearchTaskState> handleCallApi(int pageIndex,String searchKey,String dateTime) async {

    SearchTaskState state = _handleLoadList(await _networkFactory!.searchItemTask(_accessToken!,searchKey.trim(),dateTime,pageIndex,_maxPage), pageIndex);
    return state;
  }

  void _searchCustomerCheckInEvent(SearchCustomerCheckInEvent event, Emitter<SearchTaskState> emitter){
    emitter(SearchTaskLoading());
    listItemReSearch = getSuggestions(event.keysText);
    print(event.keysText);
    emitter(SearchCustomerCheckInSuccess());
  }

  SearchTaskState _handleLoadList(Object data, int pageIndex) {
    if (data is String) return SearchTaskFailure('Úi, ${data.toString()}');
    try {
      SearchItemTaskResponse response = SearchItemTaskResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 20;
      List<SearchItemTaskResponseData> list = response.data!;
      if (!Utils.isEmpty(list) && _searchResults.length >= (pageIndex - 1) * _maxPage + list.length) {
        _searchResults.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          _searchResults = list;
        } else {
          _searchResults.addAll(list);
        }
      }
      if (Utils.isEmpty(_searchResults)) {
        return GetListTaskEmpty();
      } else {
        isScroll = true;
      }
      return GetListTaskSuccess();
    } catch (e) {
      return SearchTaskFailure('Úi, ${e.toString()}');
    }
  }


  List<ItemCheckInOffline> getSuggestions(String query) {
    List<ItemCheckInOffline> matches = [];
    matches.addAll(listCheckInOffline);
    matches.retainWhere((s) => s.tieuDe.toString().toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
}