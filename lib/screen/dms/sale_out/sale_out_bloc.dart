// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import '../../../model/database/data_local.dart';
import '../../../model/database/dbhelper.dart';
import '../../../model/entity/entity_request.dart';
import '../../../model/entity/product.dart';
import '../../../model/network/request/create_order_request.dart';
import '../../../model/network/request/discount_request.dart';
import '../../../model/network/request/order_create_checkin_request.dart';
import '../../../model/network/request/save_inventory_control_request.dart';
import '../../../model/network/response/detail_history_sale_out_response.dart';
import '../../../model/network/response/list_history_sale_out_response.dart';
import '../../../model/network/response/list_stock_response.dart';
import '../../../model/network/response/search_list_item_response.dart';
import '../../../model/network/response/history_order_detail_reponse.dart';
import '../../../model/network/services/network_factory.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import 'sale_out_event.dart';
import 'sale_out_state.dart';

class SaleOutBloc extends Bloc<SaleOutEvent,SaleOutState>{

  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String get accessToken => _accessToken!;
  String? _refreshToken;
  String get refreshToken => _refreshToken!;


  final db = DatabaseHelper();

  // List<SearchItemResponseData> listOrder = [];
  List<Product> listProductOrder = [];
  List<Product> listProductOrderAndUpdate = [];

  final List<Product> _lineItemOrder = <Product>[];
  List<Product> get lineItemOrder => _lineItemOrder;



  Future<List<Product>> getListFromDb() {
    return db.fetchAllProductSaleOut();
  }
  String? customerName;
  String? phoneCustomer;
  String? addressCustomer;
  String? codeCustomer;
  String? noteSell;
  String? storeCode;

  List<ListStore> listStockResponse = [];
  List<ListHistorySaleOutResponseData> listHistorySaleOut = [];
  List<DetailHistorySaleOutResponseData> listDetailItemSaleOut = [];
  bool expandedProductGift = false;
  bool expanded = false;

  String? agentName;
  String? agentPhone;
  String? agentAddress;
  String? agentCode;

  int totalPager = 0;
  String transactionName = '';
  int transactionIndex = 0;
  int transactionCode = 2;

  SaleOutBloc(this.context) : super(SaleOutInitial()){
    _networkFactory = NetWorkFactory(context);
    on<GetSaleOutPrefs>(_getPrefs);
    on<PickTransactionName>(_pickTransactionName);
    on<GetListProductFromDB>(_getListProductFromDB);
    on<DeleteProductFromDB>(_deleteProductFromDB);
    on<PickInfoCustomer>(_pickInfoCustomer);
    on<AddNote>(_addNote);
    on<DeleteAllProductFromDB>(_deleteAllProductFromDB);
    on<ChangeHeightListEvent>(_changeHeightListEvent);
    on<UpdateSaleOutEvent>(_updateSaleOutEvent);
    on<GetListStockEvent>(_getListStockEvent);
    on<AddOrDeleteProductGiftEvent>(_addOrDeleteProductGiftEvent);
    on<ChangeHeightListProductGiftEvent>(_changeHeightListProductGiftEvent);
    on<PickInfoAgent>(_pickInfoAgent);
    on<GetListHistorySaleOutEvent>(_getListHistorySaleOutEvent);
    on<GetDetailHistorySaleOutEvent>(_getDetailHistorySaleOutEvent);
    on<UpdateProductCountEvent>(_updateProductCountEvent);
  }
  final box = GetStorage();
  void _getPrefs(GetSaleOutPrefs event, Emitter<SaleOutState> emitter)async{
    emitter(SaleOutInitial());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);

    emitter(GetPrefsSuccess());
  }

  void _pickTransactionName(PickTransactionName event, Emitter<SaleOutState> emitter){
    emitter(SaleOutInitial());
    transactionIndex = event.transactionIndex;
    transactionName = event.transactionName;
    emitter(PickTransactionSuccess());
  }

  void _getListHistorySaleOutEvent(GetListHistorySaleOutEvent event, Emitter<SaleOutState> emitter)async{
    emitter(SaleOutLoading());
    SaleOutState state = _handleGetListHistorySaleOut(await _networkFactory!.getListHistorySaleOut(
        _accessToken!,
        event.dateFrom.toString(),
        event.dateTo.toString(),
        event.idCustomer.toString() == 'null' ? '' : event.idCustomer.toString(),
        '2',
        event.pageIndex,
        20
    ));
    emitter(state);
  }

  void _getDetailHistorySaleOutEvent(GetDetailHistorySaleOutEvent event, Emitter<SaleOutState> emitter)async{
    emitter(SaleOutLoading());
    SaleOutState state =  _handleGetDetailHistorySaleOut(await _networkFactory!.getDetailHistorySaleOut( _accessToken!,event.sttRec.toString(),event.invoiceDate.toString()));
    emitter(state);
  }

  void _addOrDeleteProductGiftEvent(AddOrDeleteProductGiftEvent event, Emitter<SaleOutState> emitter)async{
    emitter(SaleOutLoading());
    if(event.addItem == true){
      if(DataLocal.listProductGiftSaleOut.isEmpty){
        DataLocal.listProductGiftSaleOut.add(event.item);
      }else{
        if(DataLocal.listProductGiftSaleOut.any((element) => element.code.toString().trim() == event.item.code.toString().trim()) == true){
          DataLocal.listProductGiftSaleOut.remove(event.item);
          DataLocal.listProductGiftSaleOut.add(event.item);
        }else{
          DataLocal.listProductGiftSaleOut.add(event.item);
        }
      }
    }else{
      DataLocal.listProductGiftSaleOut.remove(event.item);
    }
    emitter(AddOrDeleteProductGiftSuccess());
  }

  void _changeHeightListProductGiftEvent(ChangeHeightListProductGiftEvent event, Emitter<SaleOutState> emitter)async{
    emitter(SaleOutInitial());
    expandedProductGift = event.expandedProductGift!;
    emitter(ChangeHeightListSuccess());
  }

  void _changeHeightListEvent(ChangeHeightListEvent event, Emitter<SaleOutState> emitter)async{
    emitter(SaleOutInitial());
    expanded = event.expanded!;
    emitter(ChangeHeightListSuccess());
  }

  void _getListStockEvent(GetListStockEvent event, Emitter<SaleOutState> emitter)async{
    emitter(SaleOutLoading());
    SaleOutState state = _handleGetListStock(await _networkFactory!.getListStock(
        token: _accessToken.toString(),
        itemCode: event.itemCode.toString(),
        listKeyGroup: Const.listKeyGroupCheck,
        checkGroup: 0,
        checkStock: 1, checkStockEmployee: event.checkStockEmployee
    ));
    emitter(state);
  }

  void _updateSaleOutEvent(UpdateSaleOutEvent event, Emitter<SaleOutState> emitter)async{
    emitter(SaleOutLoading());
    List<ProductStore> listSaleOutItem  = [];

    for (var element in event.listOrder) {
      ProductStore item = ProductStore(
          codeProduct: element.code,
          nameProduct: element.name,
          inventoryNumber: element.count,
          dvt: element.dvt,
          price: element.price,
          isDiscount: 0
      );
      listSaleOutItem.add(item);
    }
    for (var element in DataLocal.listProductGiftSaleOut) {
      ProductStore item = ProductStore(
        codeProduct: element.code,
        nameProduct: element.name,
        inventoryNumber: element.count,
        dvt: element.dvt,
        price: 0,
        isDiscount: 1
      );
      listSaleOutItem.add(item);
    }


    InventoryControlAndSaleOutRequest request = InventoryControlAndSaleOutRequest(
        data: InventoryControlAndSaleOutRequestData(
            orderDate: (event.dateTime.toString() == 'null' && event.dateTime.toString() == '') ? DateTime.now().toString()  : event.dateTime ,
            customerID: event.codeCustomer,
            customerAddress: addressCustomer,
            agentId: agentCode,
            detail: listSaleOutItem,
            desc: event.desc,
            typePayment: transactionCode,
            dateEstDelivery: event.dateEstDelivery
        )
    );

    SaleOutState state = _handleUpdateSaleOut(await _networkFactory!.updateSaleOut(request,_accessToken!));
    emitter(state);
  }

  void _addNote(AddNote event, Emitter<SaleOutState> emitter){
    emitter(SaleOutInitial());
    noteSell = event.note;
    emitter(AddNoteSuccess());
  }

  void _deleteAllProductFromDB(DeleteAllProductFromDB event, Emitter<SaleOutState> emitter)async{
    emitter(SaleOutInitial());
    await db.deleteAllProductSaleOut();
    emitter(DeleteAllProductFromDBSuccess());
  }

  void _pickInfoCustomer(PickInfoCustomer event, Emitter<SaleOutState> emitter){
    emitter(SaleOutInitial());
    customerName = event.customerName;
    phoneCustomer = event.phone;
    addressCustomer = event.address;
    codeCustomer = event.codeCustomer;
    emitter(PickInfoCustomerSuccess());
  }

  void _pickInfoAgent(PickInfoAgent event, Emitter<SaleOutState> emitter){
    emitter(SaleOutInitial());
    agentName = event.customerName;
    agentPhone = event.phone;
    agentAddress = event.address;
    agentCode = event.codeCustomer;
    emitter(PickInfoAgentSuccess());
  }

  double totalMoney = 0;

  void _getListProductFromDB(GetListProductFromDB event, Emitter<SaleOutState> emitter)async{
    emitter(SaleOutLoading());
    totalMoney = 0;
    listProductOrderAndUpdate  = await db.fetchAllProductSaleOut();
    for (var element in listProductOrderAndUpdate) {
      totalMoney += element.count! * element.price!;
    }
    emitter(GetListProductFromDBSuccess(true));
  }

  void _deleteProductFromDB(DeleteProductFromDB event, Emitter<SaleOutState> emitter)async{
    emitter(SaleOutLoading());
    listProductOrderAndUpdate.removeAt(event.index);
    db.removeProductSaleOut(event.itemProduct.code.toString());
    Const.numberProductInCart = listProductOrderAndUpdate.length;
    emitter(DeleteProductFromDBSuccess());
  }

  void _updateProductCountEvent(UpdateProductCountEvent event, Emitter<SaleOutState> emitter)async{
    emitter(SaleOutLoading());
    listProductOrderAndUpdate.removeAt(event.index);
    db.updateProductSaleOut(event.item);
    emitter(UpdateProductFromDBSuccess());
  }

  SaleOutState _handleGetListStock(Object data){
    if(data is String) return SaleOutFailure('Úi, ${data.toString()}');
    try{
      if(listStockResponse.isNotEmpty) {
        listStockResponse.clear();
      }
      ListStockAndGroupResponse response = ListStockAndGroupResponse.fromJson(data as Map<String,dynamic>);
      listStockResponse = response.listStore!;
      return GetListStockEventSuccess();
    }
    catch(e){
      print('adfr3 $e');
      return SaleOutFailure('Úi, ${e.toString()}');
    }
  }

  SaleOutState _handleGetListHistorySaleOut(Object data){
    if(data is String) return SaleOutFailure('Úi, ${data.toString()}');
    try{
      if(listHistorySaleOut.isNotEmpty) {
        listHistorySaleOut.clear();
      }
      ListHistorySaleOutResponse response = ListHistorySaleOutResponse.fromJson(data as Map<String,dynamic>);
      listHistorySaleOut = response.data!;
      totalPager = response.totalPage!;
      if(listHistorySaleOut.isNotEmpty){
        return GetListHistorySaleOutSuccess();
      }else {
        return GetListHistorySaleOutEmpty();
      }
    }
    catch(e){
      return SaleOutFailure('Úi, ${e.toString()}');
    }
  }


  double totalProduct =0;
  double totalMoneyS = 0;
  double totalMoneyNT2 = 0;

  SaleOutState _handleGetDetailHistorySaleOut(Object data){
    if(data is String) return SaleOutFailure('Úi, ${data.toString()}');
    try{
      totalProduct = 0;
      DetailHistorySaleOutResponse response = DetailHistorySaleOutResponse.fromJson(data as Map<String,dynamic>);
      listDetailItemSaleOut = response.data!;
      if(listDetailItemSaleOut.isNotEmpty){
        for (var element in listDetailItemSaleOut) {
          totalProduct += element.soLuong!;
          totalMoneyS += element.giaSan!;
          totalMoneyNT2 += element.tienNt2!;
        }
      }
      return GetListDetailSaleOutSuccess();
    }
    catch(e){
      print(e.toString());
      return SaleOutFailure('Úi, ${e.toString()}');
    }
  }

  SaleOutState _handleUpdateSaleOut(Object data){
    if(data is String) return SaleOutFailure('Úi, ${data.toString()}');
    try{
      return SaleOutSuccess();
    }catch(e){
      return SaleOutFailure('Úi, ${e.toString()}');
    }
  }
}