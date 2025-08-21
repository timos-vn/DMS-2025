import 'package:dms/screen/personnel/suggestions/suggestions_event.dart';
import 'package:dms/screen/personnel/suggestions/suggestions_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import '../../../model/network/request/confirm_dnc_request.dart';
import '../../../model/network/request/create_dnc_request.dart';
import '../../../model/network/request/list_dnc_request.dart';
import '../../../model/network/response/detail_dnc_response.dart';
import '../../../model/network/response/list_dnc_response.dart';
import '../../../model/network/response/list_history_leave_letter_response.dart';
import '../../../model/network/services/network_factory.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';

class SuggestionsBloc extends Bloc<SuggestionsEvent,SuggestionsState>{
  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String get accessToken => _accessToken!;
  String? _refreshToken;
  String get refreshToken => _refreshToken!;

  int _currentPage = 1;
  int _maxPage = 10;
  bool isScroll = true;
  int get maxPage => _maxPage;

  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();

  String remainingDaysOff = "";

  String? dateCreateDNC;

  String transactionType = '1';

  List<ListDNCResponseData> _listDNC = <ListDNCResponseData>[];
  List<ListDNCResponseData> get listDNC => _listDNC;

  List<DetailListDNC>? detailListDNC = <DetailListDNC>[];
  MasterDNC? masterDNC;

  List<ListHistoryLeaveLetterResponseData> _listHistoryLeaveLetter = [];
  List<ListHistoryLeaveLetterResponseData> get listHistoryLeaveLetter => _listHistoryLeaveLetter;

  List<ListDNCDataDetail2> _listDNCDetail = [];
  List<ListDNCDataDetail2> get listDNCDetail => _listDNCDetail;
  List<ListDNCDataDetail> listDNCDataDetail = [];

  SuggestionsBloc(this.context) : super(SuggestionsInitial()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsSuggestions>(_getPrefs);
    on<ConfirmDNCEvent>(_confirmDNCEvent);
    on<CreateDNCEvent>(_createDNCEvent);
    on<AddOrRemoveCoreWater>(_addOrRemoveCoreWater);
    on<GetDetailDNC>(_getDetailDNC);
    on<GetListDNC>(_getListDNC);
    on<GetListHistoryLeaveLetter>(_getListHistoryLeaveLetter);
    on<CreateLeaveLetterEvent>(_createLeaveLetterEvent);
    on<DeleteLeaveLetterEvent>(_deleteLeaveLetterEvent);
  }
  final box = GetStorage();
  void _getPrefs(GetPrefsSuggestions event, Emitter<SuggestionsState> emitter)async{
    emitter(SuggestionsInitial());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    remainingDaysOff = box.read(Const.REMAINING_DAYS_OFF);
    emitter(GetPrefsSuccess());
  }

  void _confirmDNCEvent(ConfirmDNCEvent event, Emitter<SuggestionsState> emitter)async{
    emitter(SuggestionsLoading());
    ConfirmDNCRequest request = ConfirmDNCRequest(
        action: event.action,
        capDuyet: event.levelApproval,
        sttRec: event.sttRec
    );
    SuggestionsState state = _handleConfirmDNC(await _networkFactory!.confirmDNC(request,_accessToken!),event.action);
    emitter(state);
  }

  void _createLeaveLetterEvent(CreateLeaveLetterEvent event, Emitter<SuggestionsState> emitter)async{
    emitter(SuggestionsLoading());
    SuggestionsState state = _handleCreateLeaveLetter(await _networkFactory!.createLeaveLetter(event.request,_accessToken!));
    emitter(state);
  }

  void _deleteLeaveLetterEvent(DeleteLeaveLetterEvent event, Emitter<SuggestionsState> emitter)async{
    emitter(SuggestionsLoading());
    SuggestionsState state = _handleDeleteLeaveLetter(await _networkFactory!.deleteLeaveLetter(event.sttRec,event.stt,_accessToken!));
    emitter(state);
  }

  void _createDNCEvent(CreateDNCEvent event, Emitter<SuggestionsState> emitter)async{
    emitter(SuggestionsLoading());
    if(listDNCDataDetail.isNotEmpty){
      listDNCDataDetail.clear();
    }
    if(listDNCDetail.isNotEmpty){
      for (var element in listDNCDetail) {
        listDNCDataDetail.add(
            ListDNCDataDetail(
                tienNt: element.tienNt,
                dienGiai: element.dienGiai
            )
        );
      }
    }

    CreateDNCRequest request = CreateDNCRequest(
        deptId: event.departmentCode,
        data: CreateDNCData(
            customerCode: event.customerCode,
            dienGiai: event.desc,
            maGd: event.typeTransaction,
            loaiTt: event.typePayment,
            orderDate: Utils.parseStringToDate(dateCreateDNC!, Const.DATE_FORMAT_2).toString(),// DateFormat('yyyy-MM-dd').format(dateCreateDNC) ,
            attachFile: event.attachFile,
            detail: listDNCDataDetail,
        )
    );
    SuggestionsState state = _handleCreateDNC(await _networkFactory!.createDNC(request,_accessToken!));
    emitter(state);
  }

  void _addOrRemoveCoreWater(AddOrRemoveCoreWater event, Emitter<SuggestionsState> emitter)async{
    emitter(SuggestionsLoading());
    if(event.type == true){
      //add
      _listDNCDetail.add(event.item);
    }else{
      //remove
      if(_listDNCDetail.isNotEmpty){
        _listDNCDetail.removeAt(event.index!);
      }
    }
    emitter(AddOrRemoveCoreWaterSuccess());
  }

  void _getDetailDNC(GetDetailDNC event, Emitter<SuggestionsState> emitter)async{
    emitter(SuggestionsLoading());
    SuggestionsState state = _handleDetailDNC(await _networkFactory!.getDetailDNC(_accessToken!,event.sttRec));
    emitter(state);
  }

  void _getListDNC(GetListDNC event, Emitter<SuggestionsState> emitter)async{
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? SuggestionsLoading()
        : SuggestionsInitial());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        SuggestionsState state = await handleCallApi(i,event.dateFrom,event.dateTo);
        if (!(state is GetListDNCSuccess)) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    SuggestionsState state = await handleCallApi(_currentPage,event.dateFrom,event.dateTo);
    emitter(state);
  }

  Future<SuggestionsState> handleCallApi(int pageIndex,String dateFrom, String dateTo) async {
    ListDNCRequest request = ListDNCRequest(
        dateFrom: dateFrom,
        dateTo: dateTo,
        pageIndex: pageIndex,
        pageCount: 10
    );

    SuggestionsState state = _handleLoadList(await _networkFactory!.getListDNCHistory(request,_accessToken!), pageIndex);
    return state;
  }

  SuggestionsState _handleLoadList(Object data, int pageIndex) {
    if (data is String) return SuggestionsFailure('Úi, ${data.toString()}');
    try {
      if(_listDNC.isNotEmpty) {
        _listDNC.clear();
      }
      ListDNCResponse response = ListDNCResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 10;
      List<ListDNCResponseData> list = response.data!;

      if (!Utils.isEmpty(list) && _listDNC.length >= (pageIndex - 1) * _maxPage + list.length) {
        _listDNC.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          _listDNC = list;
        } else {
          _listDNC.addAll(list);
        }
      }
      if (Utils.isEmpty(_listDNC)) {
        return GetListDNCEmpty();
      } else {
        isScroll = true;
      }
      return GetListDNCSuccess();
    } catch (e) {
      return SuggestionsFailure('Úi, '+ ": ${e.toString()}");
    }
  }

  void _getListHistoryLeaveLetter(GetListHistoryLeaveLetter event, Emitter<SuggestionsState> emitter)async{
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? SuggestionsLoading()
        : SuggestionsInitial());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        SuggestionsState state = await handleCallApiListHistoryLeaveLetter(i,event.dateFrom,event.dateTo);
        if (state is! GetListDNCSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    SuggestionsState state = await handleCallApiListHistoryLeaveLetter(_currentPage,event.dateFrom,event.dateTo);
    emitter(state);
  }

  Future<SuggestionsState> handleCallApiListHistoryLeaveLetter(int pageIndex,String dateFrom, String dateTo) async {

    SuggestionsState state = _handleLoadListHistoryLeaveLetter(await _networkFactory!.getListLeaveLetterHistory(dateFrom,dateTo,pageIndex,20,_accessToken!), pageIndex);
    return state;
  }

  SuggestionsState _handleLoadListHistoryLeaveLetter(Object data, int pageIndex) {
    if (data is String) return SuggestionsFailure('Úi, ${data.toString()}');
    try {
      if(_listHistoryLeaveLetter.isNotEmpty) {
        _listHistoryLeaveLetter.clear();
      }
      ListHistoryLeaveLetterResponse response = ListHistoryLeaveLetterResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 10;
      List<ListHistoryLeaveLetterResponseData> list = response.data!;

      if (!Utils.isEmpty(list) && _listHistoryLeaveLetter.length >= (pageIndex - 1) * _maxPage + list.length) {
        _listHistoryLeaveLetter.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          _listHistoryLeaveLetter = list;
        } else {
          _listHistoryLeaveLetter.addAll(list);
        }
      }
      if (Utils.isEmpty(_listHistoryLeaveLetter)) {
        return GetListHistoryLeaveLetterEmpty();
      } else {
        isScroll = true;
      }
      return GetListDNCSuccess();
    } catch (e) {
      return SuggestionsFailure('Úi, '": ${e.toString()}");
    }
  }

  SuggestionsState _handleDetailDNC(Object data) {
    if (data is String) return SuggestionsFailure('Úi, ${data.toString()}');
    try {
      DetailDNCResponse response = DetailDNCResponse.fromJson(data as Map<String,dynamic>);
      detailListDNC = response.data?.detail;
      masterDNC = response.data?.master!;
      if(detailListDNC!.isNotEmpty){
        return GetDetailDNCSuccess();
      }else{
        return GetDetailDNCEmpty();
      }
    } catch (e) {
      return SuggestionsFailure('Úi, ${e.toString()}');
    }
  }

  SuggestionsState _handleCreateDNC(Object data) {
    if (data is String) return SuggestionsFailure('Úi, ${data.toString()}');
    try {
      return CreateDNCSuccess();
    } catch (e) {
      return SuggestionsFailure('Úi, ${data.toString()}');
    }
  }

  SuggestionsState _handleConfirmDNC(Object data,String actionConfirm) {
    if (data is String) return SuggestionsFailure('Úi, ${data.toString()}');
    try {
      return ConfirmDNCSuccess(actionConfirm);
    } catch (e) {
      return ConfirmDNCFailure(actionConfirm: actionConfirm,error: 'Úi, ${e.toString()}');
    }
  }

  SuggestionsState _handleCreateLeaveLetter(Object data) {
    if (data is String) return SuggestionsFailure('Úi, ${data.toString()}');
    try {
      return CreateLeaveLetterSuccess();
    } catch (e) {
      return SuggestionsFailure('Úi, ${e.toString()}');
    }
  }

  SuggestionsState _handleDeleteLeaveLetter(Object data) {
    if (data is String) return SuggestionsFailure('Úi, ${data.toString()}');
    try {
      return DeleteLeaveLetterSuccess();
    } catch (e) {
      return SuggestionsFailure('Úi, ${e.toString()}');
    }
  }

}