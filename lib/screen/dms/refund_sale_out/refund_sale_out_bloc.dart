import 'dart:io';
import 'package:dms/model/database/data_local.dart';
import 'package:dms/model/network/response/get_list_refund_order_response.dart';
import 'package:dms/screen/dms/refund_sale_out/refund_sale_out_event.dart';
import 'package:dms/screen/dms/refund_sale_out/refund_sale_out_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dms/utils/const.dart';
import 'package:get_storage/get_storage.dart';

import '../../../model/network/request/create_refund_sale_out_request.dart';
import '../../../model/network/response/GetDetailSaleOutCompetedResponse.dart';
import '../../../model/network/response/detail_history_refund_order_screen.dart';
import '../../../model/network/response/list_history_sale_out_response.dart';
import '../../../model/network/services/network_factory.dart';
import '../../../utils/utils.dart';


class RefundSaleOutBloc extends Bloc<RefundSaleOutEvent,RefundSaleOutState>{
  NetWorkFactory? _networkFactory;
  BuildContext context;

  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  int get currentPage => _currentPage;
  int _currentPage = 1;
  int _maxPage = 20;
  bool isScroll = true;
  int get maxPage => _maxPage;

  int status = 0;
  bool isGrantCamera = false;


  String? customerName;
  String? phoneCustomer;
  String? addressCustomer;
  String? codeCustomer;
  String? noteSell;

  List<GetListRefundOrderResponseData> _listRefundOrder = <GetListRefundOrderResponseData>[];
  List<GetListRefundOrderResponseData> get listRefundOrder => _listRefundOrder;

  List<ListHistorySaleOutResponseData> _listHistoryRefundOrder = <ListHistorySaleOutResponseData>[];
  List<ListHistorySaleOutResponseData> get listHistoryRefundOrder => _listHistoryRefundOrder;


  List<GetDetailSaleOutCompletedResponseData> _listDetailOrderCompleted = <GetDetailSaleOutCompletedResponseData>[];
  List<GetDetailSaleOutCompletedResponseData> get listDetailOrderCompleted => _listDetailOrderCompleted;

  List<GetDetailHistoryRefundOrderResponseData> _listDetailHistoryRefundOrder = <GetDetailHistoryRefundOrderResponseData>[];
  List<GetDetailHistoryRefundOrderResponseData> get listDetailHistoryRefundOrder => _listDetailHistoryRefundOrder;

  List<String> listImage = [];

  List<File> listFileInvoice = [];

  bool isPhone = false;
  bool isEmail =false;
  bool isSMS =false;
  bool isMXH =false;
  bool isOther =false;
  List<String> typeCare = [];
  bool expanded = false;

  double totalMoney = 0;
  double totalPayment = 0;
  double totalCount = 0;
  String idUser = '';

  List<GetDetailSaleOutCompletedResponseData> listDetailOrderCompletedDraft =[];

  final box = GetStorage();
  RefundSaleOutBloc(this.context) : super(InitialRefundSaleOutState()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsRefundSaleOutEvent>(_getPrefs);
    on<GetListSaleOutCompletedEvent>(_getListSaleOutCompleted);
    on<GetDetailSaleOutCompletedEvent>(_getDetailSaleOutCompleted);
    on<AddNote>(_addNote);
    on<PickInfoCustomer>(_pickInfoCustomer);
    on<ChangeHeightListEvent>(_changeHeightListEvent);
    on<AddNewRefundSaleOutEvent>(_addNewRefundOrderEvent);
    on<GetDetailHistoryRefundSaleOutEvent>(_getDetailHistoryRefundOrderEvent);
    on<GetListHistoryRefundSaleOutEvent>(_getListHistoryRefundSaleOutEvent);
    on<CalculatorEvent>(_calculatorEvent);
  }


  void _getPrefs(GetPrefsRefundSaleOutEvent event, Emitter<RefundSaleOutState> emitter)async{
    emitter(InitialRefundSaleOutState());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    idUser = box.read(Const.USER_ID);

    if(DataLocal.listDetailSaleOutCompletedSave.isNotEmpty && event.calculator == true){
      calculator();
    }

    emitter(GetPrefsRefundSaleOutSuccess());
  }

  void calculator(){
    totalMoney = 0;
    totalCount = 0;
    totalPayment = 0;
    listDetailOrderCompletedDraft =[];

    for (var element in DataLocal.listDetailSaleOutCompletedSave) {
      totalCount = totalCount + element.slSt;
      totalMoney = totalMoney + (element.giaNt2! * element.slSt);
      GetDetailSaleOutCompletedResponseData item = element;
      // item.soLuong = element.slTra;
      listDetailOrderCompletedDraft.add(item);
    }
    totalPayment = totalMoney;
  }

  void _calculatorEvent(CalculatorEvent event, Emitter<RefundSaleOutState> emitter){
    emitter(InitialRefundSaleOutState());
    calculator();
    emitter(CalculatorSuccess());
  }


  void _addNote(AddNote event, Emitter<RefundSaleOutState> emitter){
    emitter(InitialRefundSaleOutState());
    noteSell = event.note;
    emitter(AddNoteSuccess());
  }

  void _pickInfoCustomer(PickInfoCustomer event, Emitter<RefundSaleOutState> emitter){
    emitter(InitialRefundSaleOutState());
    customerName = event.customerName;
    phoneCustomer = event.phone;
    addressCustomer = event.address;
    codeCustomer = event.codeCustomer;
    emitter(PickInfoCustomerSuccess());
  }

  void _changeHeightListEvent(ChangeHeightListEvent event, Emitter<RefundSaleOutState> emitter)async{
    emitter(InitialRefundSaleOutState());
    expanded = event.expanded!;
    emitter(ChangeHeightListSuccess());
  }

  void _addNewRefundOrderEvent(AddNewRefundSaleOutEvent event, Emitter<RefundSaleOutState> emitter)async{
    emitter(RefundSaleOutLoading());

    for (var element in listDetailOrderCompletedDraft) {
      element.soLuong = element.slSt;
    }

    TotalCreateOrderV3 totalCreateOrderV3 = TotalCreateOrderV3(
        preAmount: totalMoney,
        discount: 0,
        amount: totalPayment,
        tax: 0,
        fee: 0
    );

    CreateRefundSaleOutRequest request = CreateRefundSaleOutRequest(
        requestData: CreateRefundSaleOutRequestData(
            sct: (DataLocal.sctSaleOut.toString() != 'null' && DataLocal.sctSaleOut.toString().isNotEmpty && DataLocal.sctSaleOut.toString() != '')
                ?
            DataLocal.sctSaleOut.toString() : '' ,
            customerCode: event.idCustomer,
            saleCode: idUser,
            orderDate: DateTime.now().toString(),
            currency: '',
            stockCode: '',
            description: noteSell,
            phoneCustomer: event.phoneCustomer,
            addressCustomer: event.addressCustomer,
            detail: listDetailOrderCompletedDraft,
            total: totalCreateOrderV3,
            comment: noteSell,
            idTransaction: '',
            discountPercentAgency: 0,
            discountPercentTypePayment: 0,
            codeAgency: event.idAgency,
            datePayment: '',
            codeTypePayment: '',
            codeTax: event.codeTax,
            totalTax: 0,
            codeSell: DataLocal.codeSellLockRefundSaleOut.toString(),
            tk: event.tk.toString()
        )
    );

    RefundSaleOutState state = _handleAddNewRefundOrder(await _networkFactory!.createRefundSaleOut(request, _accessToken!));
    emitter(state);
  }

  void _getDetailSaleOutCompleted(GetDetailSaleOutCompletedEvent event, Emitter<RefundSaleOutState> emitter)async{
    emitter(InitialRefundSaleOutState());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? RefundSaleOutLoading()
        : InitialRefundSaleOutState());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        RefundSaleOutState state = await handleCallApiDetailSaleOutCompleted(i,event.sctRec.toString(),event.invoiceDate.toString(),event.addOrDeleteInList,event.allowAddOrDeleteInList);
        if (state is! GetListRefundSaleOutSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    RefundSaleOutState state = await handleCallApiDetailSaleOutCompleted(_currentPage,event.sctRec.toString(),event.invoiceDate.toString(),event.addOrDeleteInList,event.allowAddOrDeleteInList);
    emitter(state);
  }

  void _getDetailHistoryRefundOrderEvent(GetDetailHistoryRefundSaleOutEvent event, Emitter<RefundSaleOutState> emitter)async{
    emitter(InitialRefundSaleOutState());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? RefundSaleOutLoading()
        : InitialRefundSaleOutState());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        RefundSaleOutState state = await handleCallApiDetailHistoryRefundOrder(i,event.sctRec.toString(),event.invoiceDate.toString());
        if (state is! GetListRefundSaleOutSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    RefundSaleOutState state = await handleCallApiDetailHistoryRefundOrder(_currentPage,event.sctRec.toString(),event.invoiceDate.toString());
    emitter(state);
  }

  Future<RefundSaleOutState> handleCallApiDetailSaleOutCompleted(int pageIndex,String sct, String invoiceDate, bool addOrDelete, bool allowAddOrDeleteInList) async {

    RefundSaleOutState state = _handleLoadListDetailSaleOutCompleted(await _networkFactory!.getDetailSaleOutCompleted(_accessToken!,sct,invoiceDate,pageIndex,addOrDelete ==true ? 100 : _maxPage ), pageIndex,addOrDelete,allowAddOrDeleteInList);
    return state;
  }

  Future<RefundSaleOutState> handleCallApiDetailHistoryRefundOrder(int pageIndex,String sct, String invoiceDate) async {

    RefundSaleOutState state = _handleLoadListDetailHistoryRefundOrder(await _networkFactory!.getDetailHistoryRefundOrder(_accessToken!,sct,invoiceDate,pageIndex,_maxPage ), pageIndex,);
    return state;
  }

  void _getListSaleOutCompleted(GetListSaleOutCompletedEvent event, Emitter<RefundSaleOutState> emitter)async{
    emitter(InitialRefundSaleOutState());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? RefundSaleOutLoading()
        : InitialRefundSaleOutState());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        RefundSaleOutState state = await handleCallApiListSaleOutCompleted(i,event.dateFrom.toString(),event.dateTo.toString(),event.idAgency.toString());
        if (state is! GetListRefundSaleOutSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    RefundSaleOutState state = await handleCallApiListSaleOutCompleted(_currentPage,event.dateFrom.toString(),event.dateTo.toString(),event.idAgency.toString());
    emitter(state);
  }

  void _getListHistoryRefundSaleOutEvent(GetListHistoryRefundSaleOutEvent event, Emitter<RefundSaleOutState> emitter)async{
    emitter(RefundSaleOutLoading());
    RefundSaleOutState state = _handleLoadListHistoryRefundSaleOut(
        await _networkFactory!.getListHistorySaleOut(
        _accessToken!,
        event.dateFrom.toString(),
        event.dateTo.toString(),
        event.idCustomer.toString() == 'null' ? '' : event.idCustomer.toString(),
        '5',
        event.pageIndex,
        20
    ));
    emitter(state);
  }

  Future<RefundSaleOutState> handleCallApiListSaleOutCompleted(int pageIndex,String dateForm, String dateTo, String idAgency) async {

    RefundSaleOutState state = _handleLoadList(await _networkFactory!.getListSaleOutCompleted(
        _accessToken!,
        dateForm,
        dateTo,
        idAgency == 'null' ? '' : idAgency,
        pageIndex,
        _maxPage),
        pageIndex);
    return state;
  }

  RefundSaleOutState _handleLoadListDetailSaleOutCompleted(Object data, int pageIndex, bool addOrDelete, bool allowAddOrDeleteInList) {
    if (data is String) return RefundSaleOutFailure('Úi, $data');
    try {
      GetDetailSaleOutCompletedResponse response = GetDetailSaleOutCompletedResponse.fromJson(data as Map<String,dynamic>);
      if(allowAddOrDeleteInList == true){
        List<GetDetailSaleOutCompletedResponseData> list = response.data!;
        if(list.isNotEmpty){
          for (var element in list) {
            if(addOrDelete == true){
              element.slSt = element.slCl!;
              element.isMark = true;
              DataLocal.listDetailSaleOutCompletedSave.add(element);
            }else{
              DataLocal.listDetailSaleOutCompletedSave.removeWhere((elementIndex) => elementIndex.sttRec.toString().trim() == elementIndex.sttRec.toString().trim());
            }
          }
        }
      }
      else{
        _maxPage = 20;
        List<GetDetailSaleOutCompletedResponseData> list = response.data!;
        if (!Utils.isEmpty(list) && _listDetailOrderCompleted.length >= (pageIndex - 1) * _maxPage + list.length) {
          _listDetailOrderCompleted.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
        } else {
          if (_currentPage == 1) {
            _listDetailOrderCompleted = list;
          }
          else {
            _listDetailOrderCompleted.addAll(list);
          }
        }
        if (Utils.isEmpty(_listDetailOrderCompleted)) {
          return GetListDetailSaleOutCompletedEmpty();
        }
        else {
          isScroll = true;
          if(DataLocal.listDetailSaleOutCompletedSave.isNotEmpty){
            for (var elementIndex in DataLocal.listDetailSaleOutCompletedSave) {
              for(var element in _listDetailOrderCompleted){
                if('${elementIndex.sttRec.toString().trim()}-${elementIndex.sttRec0.toString().trim()}' == '${element.sttRec.toString().trim()}-${element.sttRec0.toString().trim()}'){
                  element.isMark = elementIndex.isMark;
                  element.slSt = elementIndex.slSt;
                  break;
                }
              }
            }
          }
        }
      }
      return GetListDetailSaleOutCompletedSuccess(addOrDelete: addOrDelete);
    } catch (e) {
      return RefundSaleOutFailure('Úi, ${e.toString()}');
    }
  }

  RefundSaleOutState _handleLoadListDetailHistoryRefundOrder(Object data, int pageIndex) {
    if (data is String) return RefundSaleOutFailure('Úi, $data');
    try {
      GetDetailHistoryRefundOrderResponse response = GetDetailHistoryRefundOrderResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 20;
      List<GetDetailHistoryRefundOrderResponseData> list = response.data!;
      if (!Utils.isEmpty(list) && _listDetailHistoryRefundOrder.length >= (pageIndex - 1) * _maxPage + list.length) {
        _listDetailHistoryRefundOrder.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          _listDetailHistoryRefundOrder = list;
        }
        else {
          _listDetailHistoryRefundOrder.addAll(list);
        }
      }
      if (Utils.isEmpty(_listDetailHistoryRefundOrder)) {
        return GetListDetailSaleOutCompletedEmpty();
      }
      else {
        isScroll = true;
      }
      return GetListDetailHistoryRefundSaleOutSuccess();
    } catch (e) {
      return RefundSaleOutFailure('Úi, ${e.toString()}');
    }
  }

  RefundSaleOutState _handleLoadList(Object data, int pageIndex) {
    if (data is String) return RefundSaleOutFailure('Úi, $data');
    try {
      GetListRefundOrderResponse response = GetListRefundOrderResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 20;
      List<GetListRefundOrderResponseData> list = response.data!;
      if (!Utils.isEmpty(list) && _listRefundOrder.length >= (pageIndex - 1) * _maxPage + list.length) {
        _listRefundOrder.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          _listRefundOrder = list;
        } else {
          _listRefundOrder.addAll(list);
        }
      }
      if (Utils.isEmpty(_listRefundOrder)) {
        return GetListRefundSaleOutEmpty();
      } else {
        isScroll = true;
        if(DataLocal.listDetailSaleOutCompletedSave.isNotEmpty){
          for (var elementIndex in DataLocal.listDetailSaleOutCompletedSave) {
            for(var element in _listRefundOrder){
              if(elementIndex.sttRec.toString().trim() == element.sttRec.toString().trim()){
                element.isMark = elementIndex.isMark;
                break;
              }
            }
          }
        }
      }
      return GetListRefundSaleOutSuccess();
    } catch (e) {
      return RefundSaleOutFailure('Úi, ${e.toString()}');
    }
  }
  int totalPager = 0;
  RefundSaleOutState _handleLoadListHistoryRefundSaleOut(Object data) {
    if (data is String) return RefundSaleOutFailure('Úi, $data');
    try {
      if(_listHistoryRefundOrder.isNotEmpty) {
        _listHistoryRefundOrder.clear();
      }
      ListHistorySaleOutResponse response = ListHistorySaleOutResponse.fromJson(data as Map<String,dynamic>);
      _listHistoryRefundOrder = response.data!;
      totalPager = response.totalPage!;
      if(_listHistoryRefundOrder.isNotEmpty){
        return GetListRefundSaleOutSuccess();
      }else {
        return GetListRefundSaleOutEmpty();
      }
    } catch (e) {
      return RefundSaleOutFailure('Úi, ${e.toString()}');
    }
  }



  RefundSaleOutState _handleAddNewRefundOrder(Object data){
    if(data is String) return RefundSaleOutFailure('Úi, ${data.toString()}');
    try{
      return AddNewRefundSaleOutSuccess();
    }catch(e){
      return RefundSaleOutFailure('Úi, ${e.toString()}');
    }
  }
}