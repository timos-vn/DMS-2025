// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import '../../../model/database/data_local.dart';
import '../../../model/database/dbhelper.dart';
import '../../../model/entity/entity.dart';
import '../../../model/entity/info_login.dart';
import '../../../model/entity/product.dart';
import '../../../model/network/request/search_list_item_request.dart';
import '../../../model/network/response/get_list_advance_order_info_response.dart';
import '../../../model/network/response/group_product_response.dart';
import '../../../model/network/response/list_stock_response.dart';
import '../../../model/network/response/search_list_item_response.dart';
import '../../../model/network/services/network_factory.dart';

import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import 'order_event.dart';
import 'order_sate.dart';

class OrderBloc extends Bloc<OrderEvent,OrderState>{

  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String get accessToken => _accessToken!;
  String? _refreshToken;
  String get refreshToken => _refreshToken!;

  DatabaseHelper db = DatabaseHelper();
  List<Product> listProduct = <Product>[];

  late List<SearchItemResponseData> listItemOrder = <SearchItemResponseData>[];
  late List<SearchItemResponseData> listItemOrderFixColor = <SearchItemResponseData>[];

  List<GroupProductResponseData> listGroupProduct = <GroupProductResponseData>[];
  GroupProductResponseData itemGroupProduct = GroupProductResponseData();

  List<GroupProductResponseData>? _listItemGroupProduct = <GroupProductResponseData>[];
  List<GroupProductResponseData> get listItemGroupProduct => _listItemGroupProduct!;

  List<GroupProductResponseData> listItemReSearch = <GroupProductResponseData>[];
  List<ListStore> listStockResponse = [];

  final int _currentPage = 1;
  int _maxPage = Const.MAX_COUNT_ITEM;
  int get maxPage => _maxPage;
  int get currentPage => _currentPage;

  int _currentPage2 = 1;
  final int _maxPage2 = Const.MAX_COUNT_ITEM;
  int get maxPage2 => _maxPage2;
  int get currentPage2 => _currentPage2;
  bool isScroll = true;
  String currencyName ='VNĐ';
  String typePriceCode = '';
  String typePriceName ='Giá bán lẻ';
  List<String> listGroupProductCode = ['1'];
  String listItemGroupProductCode5 = '';
  String listItemGroupProductCode1 = '';
  String listItemGroupProductCode2 = '';
  String listItemGroupProductCode3 = '';
  String listItemGroupProductCode4 = '';
  List<int> listSelectedAttr = [];

  int countProductCart = 0;
  int totalPager = 0;

  List<ListInfor> listHeaderData = <ListInfor>[];

  Future<List<Product>> getListFromDb() {
    return db.fetchAllProduct();
  }

  OrderBloc(this.context) : super(OrderInitialState()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefs>(_getPrefs);
    on<PickCurrencyName>(_pickCurrencyName);
    on<SearchItemGroupEvent>(_searchItemGroup);
    on<PickGroupProduct>(_pickGroupProduct);
    on<GetListItemGroupEvent>(_getListItemGroupEvent);
    on<GetListOderEvent>(_getListOderEvent);
    on<GetListGroupProductEvent>(_getListGroupProductEvent);
    on<ScanItemEvent>(_scanItemEvent);
    on<AddCartEvent>(_addCartEvent);
    on<GetCountProductEvent>(_getCountProductEvent);
    on<PickTypePriceName>(_pickTypePriceName);
    on<GetListStockEvent>(_getListStockEvent);
    on<GetOrderInfoEvent>(_getOrderInfoEvent);
  }
  final box = GetStorage();
  void _getPrefs(GetPrefs event, Emitter<OrderState> emitter)async{
    emitter(OrderInitialState());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsSuccess());
  }

  void _getListStockEvent(GetListStockEvent event, Emitter<OrderState> emitter)async{
    emitter(OrderLoading());

    OrderState state = _handleGetListStock(await _networkFactory!.getListStock(
      token: _accessToken.toString(),
      itemCode: event.itemCode.toString(),
      listKeyGroup:  Const.listKeyGroupCheck,
      checkGroup: Const.checkGroup == true ? 1 : 0,
      checkStock: Const.lockStockInItem == true ? 0 : 1,
      checkStockEmployee: event.checkStockEmployee
    ));
    emitter(state);
  }

  void _searchItemGroup(SearchItemGroupEvent event, Emitter<OrderState> emitter){
    emitter(OrderLoading());
    listItemReSearch = getSuggestions(event.keysText);
    emitter(SearchItemGroupSuccess());
  }

  void _getOrderInfoEvent(GetOrderInfoEvent event, Emitter<OrderState> emitter)async{
    emitter(OrderLoading());
    OrderState state = _handleGetOrderInfo(
        await _networkFactory!.getOrderInfo(_accessToken.toString(),'ITEM',event.itemCode.toString(),Const.idTypeAdvOrder.toString()),
      event.listObjectJson,event.updateValues
    );
    emitter(state);
  }

  List<GroupProductResponseData> getSuggestions(String query) {
    List<GroupProductResponseData> matches = [];
    matches.addAll(listItemGroupProduct);
    matches.retainWhere((s) => s.groupName.toString().toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  void _pickCurrencyName(PickCurrencyName event, Emitter<OrderState> emitter){
    emitter(OrderLoading());
    currencyName = event.currencyName;
    emitter(PickCurrencyNameSuccess(event.currencyCode));
  }

  void _pickTypePriceName(PickTypePriceName event, Emitter<OrderState> emitter)async{
    emitter(OrderLoading());
    typePriceName = event.typePriceName;
    typePriceCode = event.typePriceCode;
    InfoLogin infoLogin = InfoLogin(
      'vi',
      'Tiếng Việt',
      DataLocal.hotIdName,
      DataLocal.accountName,
      DataLocal.passwordAccount,
      DateTime.now().toString(),
      '',
      '',
      DataLocal.userId,
      DataLocal.userName,
      DataLocal.fullName,
      Const.isWoPrice == true ? 1 : 0,
      Const.autoAddDiscount == true ? 1 : 0,
      Const.addProductFollowStore == true ? 1 : 0,
      Const.allowViewPriceAndTotalPriceProductGift == true ? 1 : 0,
    );
    await db.updateInfoLogin(infoLogin);
    emitter(PickTypePriceNameSuccess());
  }

  void _pickGroupProduct(PickGroupProduct event, Emitter<OrderState> emitter){
    emitter(OrderLoading());
    emitter(PickupGroupProductSuccess(event.codeGroupProduct));
  }

  void _getListItemGroupEvent(GetListItemGroupEvent event, Emitter<OrderState> emitter)async{
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter((!isRefresh && !isLoadMore)
        ? OrderLoading()
        : OrderInitialState());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage2; i++) {
        OrderState state = await _handleCallApiItemProduct(event.codeGroupProduct!,i);
        if (state is! GetListItemGroupSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      _currentPage2++;
    }
    OrderState state = await _handleCallApiItemProduct(event.codeGroupProduct!,_currentPage2);
    emitter(state);
  }

  void _getListOderEvent(GetListOderEvent event, Emitter<OrderState> emitter)async{
    emitter(OrderLoading());
    OrderState state = await handleCallApi(event.idCustomer.toString(),event.searchValues!,event.pageIndex!,event.codeCurrency!,event.listCodeGroupProduct!);
    emitter(state);
  }

  void _getListGroupProductEvent(GetListGroupProductEvent event, Emitter<OrderState> emitter)async{
    emitter(OrderLoading());
    OrderState state = _handleGetListGroupProduct(await _networkFactory!.getItemMainGroup(_accessToken!));
    emitter(state);
  }

  void _scanItemEvent(ScanItemEvent event, Emitter<OrderState> emitter)async{
    // emitter(OrderLoading());
    // OrderState state = _handleScanItem(await _networkFactory!.getListItemScanRequest(_accessToken!,event.codeItem,event.currencyCode));
    // emitter(state);
  }

  void _addCartEvent(AddCartEvent event, Emitter<OrderState> emitter)async{
    emitter(OrderLoading());
    await db.addProduct(event.productItem!);
    emitter(AddCartSuccess());
  }

  void _getCountProductEvent(GetCountProductEvent event, Emitter<OrderState> emitter)async{
    emitter(OrderLoading());
    listProduct = await getListFromDb();
    // ✅ FIX: Chỉ tính số sản phẩm có isMark == 1 (đã được chọn/đánh dấu)
    // Giống như cách cart_bloc tính (chỉ tính products được mark, không tính tất cả)
    Const.numberProductInCart = listProduct.where((product) => product.isMark == 1).length;
    emitter(GetCountProductSuccess(event.firstLoad));
  }

  // OrderState _handleScanItem(Object data){
  //   if (data is String) return OrderFailure('Úi, Có lỗi rồi Đại Vương ơi !!!' + ' :${data.toString()}');
  //   try{
  //     ListItemScanResponse response = ListItemScanResponse.fromJson(data as Map<String,dynamic>);
  //     DataScan? itemScan = response.data;
  //     final valueItemScan = DataLocal.listStore.firstWhere((item) => item.code == itemScan?.code);
  //     // ignore: unnecessary_null_comparison
  //     if (valueItemScan != null) {
  //       double countItem = valueItemScan.count! + 1;
  //       DataLocal.listStore.removeWhere((element) => element.code == itemScan?.code);
  //       SearchItemResponseData itemData =new  SearchItemResponseData(
  //           code: itemScan?.code,
  //           name: itemScan?.name,
  //           name2: itemScan?.name2,
  //           dvt: itemScan?.dvt,
  //           descript: itemScan?.descript,
  //           price: itemScan?.price,
  //           discountPercent: itemScan?.discountPercent,
  //           imageUrl: itemScan?.imageUrl,
  //           priceAfter: itemScan?.priceAfter,
  //           stockAmount: itemScan?.stockAmount,
  //           count: countItem
  //       );
  //       DataLocal.listStore.add(itemData);
  //     } else {
  //       SearchItemResponseData itemData =new  SearchItemResponseData(
  //           code: itemScan?.code,
  //           name: itemScan?.name,
  //           name2: itemScan?.name2,
  //           dvt: itemScan?.dvt,
  //           descript: itemScan?.descript,
  //           price: itemScan?.price,
  //           discountPercent: itemScan?.discountPercent,
  //           imageUrl: itemScan?.imageUrl,
  //           priceAfter: itemScan?.priceAfter,
  //           stockAmount: itemScan?.stockAmount,
  //           count: 1
  //       );
  //       DataLocal.listStore.add(itemData);
  //     }
  //     return ItemScanSuccess();
  //   }catch(e){
  //     return OrderFailure(e.toString());
  //   }
  // }


  OrderState _handleGetListGroupProduct(Object data){
    if (data is String) return OrderFailure('Úi, ${data.toString()}');
    try {
      GroupProductResponse response = GroupProductResponse.fromJson(data as Map<String,dynamic>);
      listGroupProduct = response.data!;
      if(listGroupProduct.isNotEmpty){
        listGroupProduct[0].isChecked =  true;
        // EntityClass item = EntityClass(
        //     key: listGroupProduct[0].groupCode.toString(),
        //     values: ''
        // );
        // Const.listKeyGroupProduct.add(item);
      }
      return GetListGroupProductSuccess();
    }
    catch(e){
      return OrderFailure('Úi, ${e.toString()}');
    }
  }

  Future<OrderState> handleCallApi(String idCustomer,String textSearch,int pageIndex,String codeCurrency,List<String> listCodeGroupProduct) async {
    String input='';
    if(textSearch.isNotEmpty == true && textSearch.toString() != 'null'){
      input = textSearch.toString();
    }
    String keyGroup = '';
    if(Const.listKeyGroupProduct.isNotEmpty){
      for (var element in Const.listKeyGroupProduct) {
        keyGroup = keyGroup.isEmpty ? '${element.key}:${element.values}' : '$keyGroup,${element.key}:${element.values}' ;
      }
    }
    SearchListItemRequest request = SearchListItemRequest(
      searchValue: '',
      pageIndex: pageIndex,
      currency: codeCurrency,
      idCustomer: idCustomer,
      pageCount: 20,
      itemGroup:  listGroupProductCode.join(',').contains('1') ? input.isEmpty ? listItemGroupProductCode1 : input : '',
      itemGroup2: listGroupProductCode.join(',').contains('2') ? input.isEmpty ? listItemGroupProductCode2 : input : '',
      itemGroup3: listGroupProductCode.join(',').contains('3') ? input.isEmpty ? listItemGroupProductCode3 : input : '',
      itemGroup4: listGroupProductCode.join(',').contains('4') ? input.isEmpty ? listItemGroupProductCode4 : input : '',
      itemGroup5: listGroupProductCode.join(',').contains('5') ? input.isEmpty ? listItemGroupProductCode5 : input : '',
      keyGroup: keyGroup
    );
    OrderState state = _handlerGetListOrder(await _networkFactory!.getItemListSearchOrder(request, _accessToken!),pageIndex);
    return state;
  }

  Future<OrderState> _handleCallApiItemProduct(int codeGroup,int pageIndex) async {

    OrderState state = _handlerGetListItemProduct(await _networkFactory!.getItemGroup(_accessToken!,codeGroup,1),pageIndex);
    return state;
  }

  OrderState _handlerGetListItemProduct(Object data,int pageIndex){
    if(data is String) return OrderFailure('Úi, ${data.toString()}');
    try{
      GroupProductResponse response = GroupProductResponse.fromJson(data as Map<String,dynamic>);
      List<GroupProductResponseData> list = response.data ?? [];
      _listItemGroupProduct = list;
      GroupProductResponseData itemAll = GroupProductResponseData(
        groupType: 1,
        groupCode: '',
        groupName: 'Tất cả sản phẩm',
        iconUrl: ''
      );
      _listItemGroupProduct?.insert(0, itemAll);

      return GetListItemProductSuccess();
    }
    catch(e){
      return OrderFailure('Úi, ${e.toString()}');
    }
  }

  OrderState _handlerGetListOrder(Object data,int pageIndex){
    if(data is String) return OrderFailure('Úi, ${data.toString()}');
    try{
      if(listItemOrder.isNotEmpty) {
        listItemOrder.clear();
      }
      if(listItemOrderFixColor.isNotEmpty) {
        listItemOrderFixColor.clear();
      }
      SearchListItemResponse response = SearchListItemResponse.fromJson(data as Map<String,dynamic>);
      _maxPage =  20;//Const.MAX_COUNT_ITEM
      totalPager = response.totalCount!;
      List<SearchItemResponseData> list = response.data ?? [];
      if (!Utils.isEmpty(list) && listItemOrderFixColor.length >= (pageIndex - 1) * _maxPage + list.length) {
        listItemOrderFixColor.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          listItemOrderFixColor = list;
        } else {
          listItemOrderFixColor.addAll(list);
        }
      }
      if (Utils.isEmpty(list)) {
        return EmptyDataState();
      } else {
        isScroll = true;
      }
        for (var element in listItemOrderFixColor) {
          if(element.name!.isNotEmpty){
            bool itemCheck = Const.kColorForAlphaB.any((item) => item.keyText == element.name?.substring(0,1).toUpperCase());
            if(itemCheck == true){
              var valuesColor = Const.kColorForAlphaB.firstWhere((item) => item.keyText == element.name?.substring(0,1).toUpperCase());
              if(itemCheck != null){
                element.kColorFormatAlphaB = valuesColor.color;
                listItemOrder.add(element);
              }
            }else{
              element.kColorFormatAlphaB = const Color(0xff3a8068);
              listItemOrder.add(element);
            }
          }
        }
        return GetListOrderSuccess();
    }
    catch(e){
      return OrderFailure('Úi, ${e.toString()}');
    }
  }

  List<ListQDDVT> listQuyDoiDonViTinh = [];
  OrderState _handleGetListStock(Object data){
    if(data is String) return OrderFailure(data.toString());
    try{
      if(listStockResponse.isNotEmpty) {
        listStockResponse.clear();
      }
      Const.listKeyGroup = '';
      listQuyDoiDonViTinh.clear();
      ListStockAndGroupResponse response = ListStockAndGroupResponse.fromJson(data as Map<String,dynamic>);
      listStockResponse = response.listStore??[];
      List<ListGroup> listGroup = response.listGroup??[];
      listQuyDoiDonViTinh = response.listQuyDoiDonViTinh??[];
      if(listGroup.isNotEmpty  && Const.listKeyGroup.isEmpty ){
        for (var element in listGroup) {
          if(element.maNhom.toString().isNotEmpty && element.maNhom != 'null' && element.maNhom != ''){
            Const.listKeyGroup = Const.listKeyGroup.isEmpty ? '${element.loaiNhom}:${element.maNhom}' : '${Const.listKeyGroup},${element.loaiNhom}:${element.maNhom}' ;
          }
        }
      }
      return GetListStockEventSuccess();
    }
    catch(e){
      return OrderFailure('Úi, ${e.toString()}');
    }
  }

  Future<void> updateCount() async {
    List<Map> listCount = await db.countProduct();
    countProductCart = listCount[0]['COUNT (code)'];
  }
  List<dynamic> responseData = [];
  OrderState _handleGetOrderInfo(Object data, String listObjectJson, bool updateValues){
    if (data is String) return OrderFailure('Úi, ${data.toString()}');
    try {
      GetListAdvanceOrderInfo response = GetListAdvanceOrderInfo.fromJson(data as Map<String,dynamic>);
      listHeaderData = response.listInfo??[];
      List<ListObjectJson> listEntityClass = [];
      Map<String, dynamic> jsonMap =  Map<String, dynamic>.from(data);
      responseData = jsonMap["listValues"];
      if(responseData.isNotEmpty){
        for (var contentRow in responseData) {
          for (var element in listHeaderData) {
            if(element.colName.toString().trim().contains(contentRow.keys.toString().trim())){
              element.textEditingController.text = contentRow.values.toString().trim();
              break;
            }
          }
        }
      }
print(listObjectJson.isNotEmpty);
print(listHeaderData.isNotEmpty);
      if(listObjectJson.isNotEmpty && listHeaderData.isNotEmpty && updateValues == true){
        final valueMap = json.decode(listObjectJson) as List;
        listEntityClass = (valueMap.map((itemValues) => ListObjectJson.fromJson(itemValues))).toList();
        for (var element in listHeaderData) {
          for (var elementItem in listEntityClass) {
            if(element.colName.toString().trim() == elementItem.key.toString().trim()){
              element.textEditingController.text = elementItem.values.toString().trim();
              break;
            }
          }
        }
      }
      return GetInfoOrderSuccess();
    }
    catch(e){
      print(e);
      return OrderFailure('Úi, ${e.toString()}');
    }
  }
}