import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dms/extension/extension_compare_date.dart';
import 'package:dms/model/database/data_local.dart';
import 'package:dms/model/network/response/get_list_refund_order_response.dart';
import 'package:dms/screen/sell/refund_order/refund_order_event.dart';
import 'package:dms/screen/sell/refund_order/refund_order_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dms/utils/const.dart';
import 'package:get_storage/get_storage.dart';

import '../../../model/network/request/create_refund_order_request.dart';
import '../../../model/network/response/detail_history_refund_order_screen.dart';
import '../../../model/network/response/get_detail_order_complete_response.dart';
import '../../../model/network/response/get_list_history_refund_order_response.dart';
import '../../../model/network/services/network_factory.dart';
import '../../../utils/utils.dart';


class RefundOrderBloc extends Bloc<RefundOrderEvent,RefundOrderState>{
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

  List<GetListHistoryRefundOrderResponseData> _listHistoryRefundOrder = <GetListHistoryRefundOrderResponseData>[];
  List<GetListHistoryRefundOrderResponseData> get listHistoryRefundOrder => _listHistoryRefundOrder;


  List<GetDetailOrderCompletedResponseData> _listDetailOrderCompleted = <GetDetailOrderCompletedResponseData>[];
  List<GetDetailOrderCompletedResponseData> get listDetailOrderCompleted => _listDetailOrderCompleted;

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
  double totalDiscount = 0;
  double totalTax = 0;
  double percentTax = 0;
  double totalPayment = 0;
  double totalCount = 0;
  String idUser = '';

  List<GetDetailOrderCompletedResponseData> listDetailOrderCompletedDraft =[];


  RefundOrderBloc(this.context) : super(InitialRefundOrderState()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsRefundOrderEvent>(_getPrefs);
    on<GetListRefundOrderEvent>(_getListRefundOrder);
    on<GetDetailRefundOrderEvent>(_getDetailRefundOrder);
    on<AddNote>(_addNote);
    on<PickInfoCustomer>(_pickInfoCustomer);
    on<ChangeHeightListEvent>(_changeHeightListEvent);
    on<AddNewRefundOrderEvent>(_addNewRefundOrderEvent);
    on<GetDetailHistoryRefundOrderEvent>(_getDetailHistoryRefundOrderEvent);
    on<GetListHistoryRefundOrderEvent>(_getListHistoryRefundOrderEvent);
    on<CalculatorEvent>(_calculatorEvent);
  }

  final box = GetStorage();
  void _getPrefs(GetPrefsRefundOrderEvent event, Emitter<RefundOrderState> emitter)async{
    emitter(InitialRefundOrderState());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    idUser = box.read(Const.USER_ID);

    if(DataLocal.listDetailOrderCompletedSave.isNotEmpty && event.calculator == true){
      calculator();
    }

    emitter(GetPrefsRefundOrderSuccess());
  }

  void calculator(){
    totalMoney = 0;
    totalDiscount = 0;
    totalCount = 0;
    totalPayment = 0;
    totalTax = 0;
    listDetailOrderCompletedDraft =[];

    for (var element in DataLocal.listDetailOrderCompletedSave) {
      totalCount = totalCount + element.slSt;
      totalMoney = totalMoney + (element.giaNt2! * element.slSt);
      totalDiscount =totalDiscount + (element.slSt * element.giaNt2! * element.tlCk!)/100;

      GetDetailOrderCompletedResponseData item = element;
      // item.soLuong = element.slTra;
      item.ckNt = (element.slSt * element.giaNt2! * element.tlCk!)/100;
      listDetailOrderCompletedDraft.add(item);
    }

    totalPayment = totalMoney - totalDiscount;
    totalTax = ((totalPayment * percentTax)/100);
    totalPayment = totalPayment + totalTax;
  }

  void _calculatorEvent(CalculatorEvent event, Emitter<RefundOrderState> emitter){
    emitter(InitialRefundOrderState());
    calculator();
    emitter(CalculatorSuccess());
  }


  void _addNote(AddNote event, Emitter<RefundOrderState> emitter){
    emitter(InitialRefundOrderState());
    noteSell = event.note;
    emitter(AddNoteSuccess());
  }

  void _pickInfoCustomer(PickInfoCustomer event, Emitter<RefundOrderState> emitter){
    emitter(InitialRefundOrderState());
    customerName = event.customerName;
    phoneCustomer = event.phone;
    addressCustomer = event.address;
    codeCustomer = event.codeCustomer;
    emitter(PickInfoCustomerSuccess());
  }

  void _changeHeightListEvent(ChangeHeightListEvent event, Emitter<RefundOrderState> emitter)async{
    emitter(InitialRefundOrderState());
    expanded = event.expanded!;
    emitter(ChangeHeightListSuccess());
  }

  void _addNewRefundOrderEvent(AddNewRefundOrderEvent event, Emitter<RefundOrderState> emitter)async{
    emitter(RefundOrderLoading());

    // List<GetDetailOrderCompletedResponseData> listDetailOrderCompletedSaveDraft =[];
    //
    // for (var element in DataLocal.listDetailOrderCompletedSave) {
    //   element.soLuong = element.slSt;
    //   listDetailOrderCompletedSaveDraft.add(element);
    // }

    for (var element in listDetailOrderCompletedDraft) {
      element.soLuong = element.slSt;
    }

    TotalCreateOrderV3 totalCreateOrderV3 = TotalCreateOrderV3(
        preAmount: totalMoney,
        discount: totalDiscount,
        amount: totalPayment,
        tax: totalTax,
        fee: 0
    );

    CreateRefundOrderRequest request = CreateRefundOrderRequest(
        requestData: CreateRefundOrderRequestData(
            sct: (DataLocal.sct.toString() != 'null' && DataLocal.sct.toString().isNotEmpty&& DataLocal.sct.toString() != '')
                ?
            DataLocal.sct.toString() : '' ,
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
            codeAgency: '',
            datePayment: '',
            codeTypePayment: '',
            codeTax: event.codeTax,
            totalTax: totalTax,
            codeSell: DataLocal.codeSellLockRefundOrder.toString(),
            tk: event.tk.toString()
        )
    );

    RefundOrderState state = _handleAddNewRefundOrder(await _networkFactory!.createRefundOrder(request, _accessToken!));
    emitter(state);
  }

  void _getDetailRefundOrder(GetDetailRefundOrderEvent event, Emitter<RefundOrderState> emitter)async{
    emitter(InitialRefundOrderState());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? RefundOrderLoading()
        : InitialRefundOrderState());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        RefundOrderState state = await handleCallApiDetailRefundOrder(i,event.sctRec.toString(),event.invoiceDate.toString(),event.addOrDeleteInList,event.allowAddOrDeleteInList);
        if (state is! GetListRefundOrderSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    RefundOrderState state = await handleCallApiDetailRefundOrder(_currentPage,event.sctRec.toString(),event.invoiceDate.toString(),event.addOrDeleteInList,event.allowAddOrDeleteInList);
    emitter(state);
  }

  void _getDetailHistoryRefundOrderEvent(GetDetailHistoryRefundOrderEvent event, Emitter<RefundOrderState> emitter)async{
    emitter(InitialRefundOrderState());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? RefundOrderLoading()
        : InitialRefundOrderState());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        RefundOrderState state = await handleCallApiDetailHistoryRefundOrder(i,event.sctRec.toString(),event.invoiceDate.toString());
        if (state is! GetListRefundOrderSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    RefundOrderState state = await handleCallApiDetailHistoryRefundOrder(_currentPage,event.sctRec.toString(),event.invoiceDate.toString());
    emitter(state);
  }

  Future<RefundOrderState> handleCallApiDetailRefundOrder(int pageIndex,String sct, String invoiceDate, bool addOrDelete, bool allowAddOrDeleteInList) async {

    RefundOrderState state = _handleLoadListDetail(await _networkFactory!.getDetailOrderCompleted(_accessToken!,sct,invoiceDate,pageIndex,addOrDelete ==true ? 100 : _maxPage ), pageIndex,addOrDelete,allowAddOrDeleteInList);
    return state;
  }

  Future<RefundOrderState> handleCallApiDetailHistoryRefundOrder(int pageIndex,String sct, String invoiceDate) async {

    RefundOrderState state = _handleLoadListDetailHistoryRefundOrder(await _networkFactory!.getDetailHistoryRefundOrder(_accessToken!,sct,invoiceDate,pageIndex,_maxPage ), pageIndex,);
    return state;
  }

  void _getListRefundOrder(GetListRefundOrderEvent event, Emitter<RefundOrderState> emitter)async{
    emitter(InitialRefundOrderState());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? RefundOrderLoading()
        : InitialRefundOrderState());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        RefundOrderState state = await handleCallApiListRefundOrder(i,event.dateFrom.toString(),event.dateTo.toString(),event.idCustomer.toString());
        if (state is! GetListRefundOrderSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    RefundOrderState state = await handleCallApiListRefundOrder(_currentPage,event.dateFrom.toString(),event.dateTo.toString(),event.idCustomer.toString());
    emitter(state);
  }

  void _getListHistoryRefundOrderEvent(GetListHistoryRefundOrderEvent event, Emitter<RefundOrderState> emitter)async{
    emitter(InitialRefundOrderState());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? RefundOrderLoading()
        : InitialRefundOrderState());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        RefundOrderState state = await handleCallApiListHistoryRefundOrder(i,event.dateFrom.toString(),event.dateTo.toString(),event.idCustomer.toString());
        if (state is! GetListRefundOrderSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    RefundOrderState state = await handleCallApiListHistoryRefundOrder(_currentPage,event.dateFrom.toString(),event.dateTo.toString(),event.idCustomer.toString());
    emitter(state);
  }


  Future<RefundOrderState> handleCallApiListHistoryRefundOrder(int pageIndex,String dateForm, String dateTo, String idCustomer) async {

    RefundOrderState state = _handleLoadListHistoryRefundOrder(await _networkFactory!.getListHistoryRefundOrder(
        _accessToken!,
        dateForm,
        dateTo,
        idCustomer == 'null' ? '' : idCustomer,
        pageIndex,
        _maxPage),
        pageIndex);
    return state;
  }

  Future<RefundOrderState> handleCallApiListRefundOrder(int pageIndex,String dateForm, String dateTo, String idCustomer) async {

    RefundOrderState state = _handleLoadList(await _networkFactory!.getListOrderCompleted(
        _accessToken!,
        dateForm,
        dateTo,
        idCustomer == 'null' ? '' : idCustomer,
        pageIndex,
        _maxPage),
        pageIndex);
    return state;
  }

  RefundOrderState _handleLoadListDetail(Object data, int pageIndex, bool addOrDelete, bool allowAddOrDeleteInList) {
    if (data is String) return RefundOrderFailure('Úi, $data');
    try {
      GetDetailOrderCompletedResponse response = GetDetailOrderCompletedResponse.fromJson(data as Map<String,dynamic>);
      if(allowAddOrDeleteInList == true){
        List<GetDetailOrderCompletedResponseData> list = response.data!;
        if(list.isNotEmpty){
          for (var element in list) {
            if(addOrDelete == true){
              element.slSt = element.slCl!;
              element.isMark = true;
              DataLocal.listDetailOrderCompletedSave.add(element);
            }else{
              DataLocal.listDetailOrderCompletedSave.removeWhere((elementIndex) => elementIndex.sttRec.toString().trim() == elementIndex.sttRec.toString().trim());
            }
          }
        }
      }
      else{
        _maxPage = 20;
        List<GetDetailOrderCompletedResponseData> list = response.data!;
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
          return GetListDetailOrderCompletedEmpty();
        }
        else {
          isScroll = true;
          if(DataLocal.listDetailOrderCompletedSave.isNotEmpty){
            for (var elementIndex in DataLocal.listDetailOrderCompletedSave) {
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
      return GetListDetailOrderCompletedSuccess(addOrDelete: addOrDelete);
    } catch (e) {
      return RefundOrderFailure('Úi, ${e.toString()}');
    }
  }

  RefundOrderState _handleLoadListDetailHistoryRefundOrder(Object data, int pageIndex) {
    if (data is String) return RefundOrderFailure('Úi, $data');
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
        return GetListDetailOrderCompletedEmpty();
      }
      else {
        isScroll = true;
      }
      return GetListDetailHistoryRefundOrderSuccess();
    } catch (e) {
      return RefundOrderFailure('Úi, ${e.toString()}');
    }
  }

  RefundOrderState _handleLoadList(Object data, int pageIndex) {
    if (data is String) return RefundOrderFailure('Úi, $data');
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
        return GetListRefundOrderEmpty();
      } else {
        isScroll = true;
        if(DataLocal.listDetailOrderCompletedSave.isNotEmpty){
          for (var elementIndex in DataLocal.listDetailOrderCompletedSave) {
            for(var element in _listRefundOrder){
              if(elementIndex.sttRec.toString().trim() == element.sttRec.toString().trim()){
                element.isMark = elementIndex.isMark;
                break;
              }
            }
          }
        }
      }
      return GetListRefundOrderSuccess();
    } catch (e) {
      return RefundOrderFailure('Úi, ${e.toString()}');
    }
  }

  RefundOrderState _handleLoadListHistoryRefundOrder(Object data, int pageIndex) {
    if (data is String) return RefundOrderFailure('Úi, $data');
    try {
      GetListHistoryRefundOrderResponse response = GetListHistoryRefundOrderResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 20;
      List<GetListHistoryRefundOrderResponseData> list = response.data!;
      if (!Utils.isEmpty(list) && _listHistoryRefundOrder.length >= (pageIndex - 1) * _maxPage + list.length) {
        _listHistoryRefundOrder.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          _listHistoryRefundOrder = list;
        } else {
          _listHistoryRefundOrder.addAll(list);
        }
      }
      if (Utils.isEmpty(_listHistoryRefundOrder)) {
        return GetListRefundOrderEmpty();
      } else {
        isScroll = true;
      }
      return GetListRefundOrderSuccess();
    } catch (e) {
      return RefundOrderFailure('Úi, ${e.toString()}');
    }
  }



  RefundOrderState _handleAddNewRefundOrder(Object data){
    if(data is String) return RefundOrderFailure('Úi, ${data.toString()}');
    try{
      return AddNewRefundOrderSuccess();
    }catch(e){
      return RefundOrderFailure('Úi, ${e.toString()}');
    }
  }
}