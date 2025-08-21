import 'package:dms/model/database/data_local.dart';
import 'package:dms/screen/sell/sell_event.dart';
import 'package:dms/screen/sell/sell_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import '../../model/network/request/create_item_holder_request.dart';
import '../../model/network/request/list_history_order_request.dart';
import '../../model/network/request/search_list_item_request.dart';
import '../../model/network/response/detail_order_suggest_response.dart';
import '../../model/network/response/get_item_holder_detail_response.dart';
import '../../model/network/response/list_approve_order_response.dart';
import '../../model/network/response/list_history_order_response.dart';
import '../../model/network/response/list_item_suggest_response.dart';
import '../../model/network/response/list_status_order_response.dart';
import '../../model/network/response/list_stock_response.dart';
import '../../model/network/response/list_tax_response.dart';
import '../../model/network/response/search_list_item_response.dart';
import '../../model/network/services/network_factory.dart';
import '../../utils/const.dart';
import '../../utils/utils.dart';


class SellBloc extends Bloc<SellEvent,SellState>{

  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  // late DateTime dateFrom;
  // late DateTime dateTo;
  int valueChange = 0;
  bool isScroll = true;

  int _currentPage = 1;
  int _maxPage = 10;

  List<Values> _list = <Values>[];
  List<Values> get list => _list;
  int get maxPage => _maxPage;

  int accessCode = 0;
  String accessName = '';
  String userCode = '';
  String userName = '';
  bool isShowCancelButton = false;
  int totalPager = 0;
  List<SearchItemResponseData> _searchResults = <SearchItemResponseData>[];
  List<SearchItemResponseData> get searchResults => _searchResults;
  // List<ListStatusOrderResponseData> listStatusOrder= [];
  List<ListApproveOrderResponseData> listApproveOrder= [];
  ItemHolderDetailResponseMaster? masterItemHolderDetail = ItemHolderDetailResponseMaster();
  List<ListItemHolderDetailResponse>? listItemHolderDetail = [];
  List<ListItemSuggestResponseData> _listSuggest = <ListItemSuggestResponseData>[];
  List<ListItemSuggestResponseData> get listSuggest => _listSuggest;
  String? _currentSearchText;
  final box = GetStorage();
  int storeIndexInPut = 0;
  int storeIndexOutPut = 0;
  String? storeCodeInPut;
  String? storeCodeOutPut;
  List<ListStore> listStockResponse = [];
  String? customerName;
  String? phoneCustomer;
  String? addressCustomer;
  String? codeCustomer;
  String? noteSell;

  SellBloc(this.context) : super(InitialSellState()){
    _networkFactory = NetWorkFactory(context);

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    accessCode = int.parse(box.read(Const.ACCESS_CODE)??'0');
    accessName = box.read(Const.ACCESS_NAME)??'';
    userName = box.read(Const.USER_NAME)??'';
    userCode = box.read(Const.USER_ID)??'';

    on<PickStoreName>(_pickStoreName);
    on<GetSellPrefsEvent>(_getPrefs);
    on<GetListHistoryOrder>(_getListHistoryOrder);
    on<DeleteEvent>(_deleteEvent);
    on<ChangePageViewEvent>(_changePageViewEvent);
    // on<GetListVVHD>(_getListVVHD);
    on<GetListTax>(_getListTax);
    on<GetListStatusOrder>(_getListStatusOrder);
    on<GetListApproveOrder>(_getListApproveOrder);
    on<GetItemHolderDetailEvent>(_getItemHolderDetailEvent);
    on<CreateItemHolderEvent>(_createItemHolderEvent);
    on<DeleteItemHolderEvent>(_deleteItemHolderEvent);
    on<GetListStockEvent>(_getListStockEvent);
    on<SearchListProductSuggestEvent>(_searchListProductSuggestEvent);
    on<SearchListProductNoSuggestEvent>(_searchListProductNoSuggestEvent);
    on<CheckShowCloseEvent>(_checkShowCloseEvent);
    on<PickInfoCustomer>(_pickInfoCustomer);
    on<CreateOrderSuggestEvent>(_createOrderSuggestEvent);
    on<GetDetailOrderSuggest>(_getDetailOrderSuggest);
    on<AddNote>(_addNote);
  }

  void _addNote(AddNote event, Emitter<SellState> emitter){
    emitter(InitialSellState());
    noteSell = event.note;
    emitter(AddNoteSuccess());
  }

  void _createOrderSuggestEvent(CreateOrderSuggestEvent event, Emitter<SellState> emitter)async{
    emitter(SellLoading());
    SellState state = _handleCreateOrderSuggest(await _networkFactory!.createOrderSuggest(event.request,_accessToken.toString()));
    emitter(state);
  }
  void _getDetailOrderSuggest(GetDetailOrderSuggest event, Emitter<SellState> emitter)async{
    emitter(SellLoading());
    SellState state = _handleGetDetailOrderSuggest(await _networkFactory!.getDetailOrderSuggest(_accessToken.toString(),event.sttRec));
    emitter(state);
  }
  void _pickStoreName(PickStoreName event, Emitter<SellState> emitter){
    emitter(SellLoading());
    if(event.input == true){
      storeIndexInPut = event.storeIndex;
    }else{
      storeIndexOutPut = event.storeIndex;
    }
    emitter(PickStoreNameSuccess());
  }
  void _pickInfoCustomer(PickInfoCustomer event, Emitter<SellState> emitter){
    emitter(SellLoading());
    customerName = event.customerName;
    phoneCustomer = event.phone;
    addressCustomer = event.address;
    codeCustomer = event.codeCustomer;
    emitter(PickInfoCustomerSuccess());
  }

  void _getPrefs(GetSellPrefsEvent event, Emitter<SellState> emitter)async{
    emitter(InitialSellState());

    emitter(GetPrefsSuccess());
  }

  void _getListStockEvent(GetListStockEvent event, Emitter<SellState> emitter)async{
    emitter(SellLoading());

    SellState state = _handleGetListStock(await _networkFactory!.getListStock(
        token: _accessToken.toString(),
        itemCode: event.itemCode.toString(),
        listKeyGroup:  '',
        checkGroup: 0,
        checkStock: 1,
        checkStockEmployee: true
    ));
    emitter(state);
  }
  void _checkShowCloseEvent(CheckShowCloseEvent event, Emitter<SellState> emitter)async{
    emitter(SellLoading());
    isShowCancelButton = !Utils.isEmpty(event.text);
    emitter(InitialSellState());
  }
 void _searchListProductSuggestEvent(SearchListProductSuggestEvent event, Emitter<SellState> emitter)async{
   emitter(InitialSellState());
   bool isRefresh = event.isRefresh;
   bool isLoadMore = event.isLoadMore;
   String searchText = event.searchText;
   emitter((!isRefresh && !isLoadMore)
       ? SellLoading()
       : InitialSellState());
   if (_currentSearchText != searchText) {
     _currentSearchText = searchText;
     _currentPage = 1;
     listSuggest.clear();
   }
   if (isRefresh) {
     for (int i = 1; i <= _currentPage; i++) {
       SellState state = await handleCallApi2(searchText,_currentPage,true);
       if (state is! SearchProductSuccess) return;
     }
     return;
   }
   if (isLoadMore) {
     isScroll = false;
     _currentPage++;
   }
   SellState state = await handleCallApi2(searchText,_currentPage,true);
   emitter(state);
  }

  void _searchListProductNoSuggestEvent(SearchListProductNoSuggestEvent event, Emitter<SellState> emitter)async{
    emitter(InitialSellState());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    String searchText = event.searchText;
    emitter((!isRefresh && !isLoadMore)
        ? SellLoading()
        : InitialSellState());
    if (_currentSearchText != searchText) {
      _currentSearchText = searchText;
      _currentPage = 1;
      searchResults.clear();
    }
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        SellState state = await handleCallApiSearchProduct(searchText, i,);
        if (state is! SearchProductSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    SellState state = await handleCallApiSearchProduct(searchText, _currentPage);
    emitter(state);
  }

  Future<SellState> handleCallApiSearchProduct(String searchText, int pageIndex) async {

    SearchListItemRequest request = SearchListItemRequest(
      searchValue: searchText,
      pageIndex: pageIndex,
      pageCount: 40,
      currency: Const.currencyCode,
      idCustomer: '',
      isCheckStock:  0,
      itemGroup:   '',
      itemGroup2: '',
      itemGroup3: '',
      itemGroup4:  '',
      itemGroup5: '',
    );
    SellState state = _handleSearchNoSuggest(await _networkFactory!.getItemListSearchOrder(request, _accessToken!),pageIndex);
    return state;
  }

  void _getListApproveOrder(GetListApproveOrder event, Emitter<SellState> emitter)async{
    emitter(SellLoading());
    SellState state = _handleLoadListApproveOrder(await _networkFactory!.getListApproveOrder(
        _accessToken!,
        Utils.parseStringToDate(event.dateFrom.toString(), Const.DATE_SV_FORMAT_2).toString(),
        Utils.parseStringToDate(event.dateTo.toString(), Const.DATE_SV_FORMAT_2).toString(),
        event.pageIndex,20
    ));
    emitter(state);
  }

  void _createItemHolderEvent(CreateItemHolderEvent event, Emitter<SellState> emitter)async{
    emitter(SellLoading());

    CreateItemHolderRequest request = CreateItemHolderRequest(
      data: CreateItemHolderRequestData(
        sttRec: event.sttRec,
        comment: event.comment,
        ngayHetHan: event.expireDate,
        listItem: event.listItemHolderCreate
      )
    );

    SellState state = _handleCreateItemHolder(await _networkFactory!.createItemHolder(request, _accessToken!,));
    emitter(state);
  }
  void _deleteItemHolderEvent(DeleteItemHolderEvent event, Emitter<SellState> emitter)async{
    emitter(SellLoading());
    SellState state = _handleDeleteItemHolder(await _networkFactory!.deleteItemHolder( _accessToken!,event.sttRec));
    emitter(state);
  }

  // void _getListVVHD(GetListVVHD event, Emitter<SellState> emitter)async{
  //   emitter(SellLoading());
  //   SellState state = _handleLoadListVVHD(await _networkFactory!.getListVVHD(_accessToken!));
  //   emitter(state);
  // }

  void _getListTax(GetListTax event, Emitter<SellState> emitter)async{
    emitter(SellLoading());
    SellState state = _handleLoadListTax(await _networkFactory!.getListTax(_accessToken!));
    emitter(state);
  }

  void _getItemHolderDetailEvent(GetItemHolderDetailEvent event, Emitter<SellState> emitter)async{
    emitter(SellLoading());
    SellState state = _handleItemHolderDetail(await _networkFactory!.getItemHolderDetail(token: _accessToken!,sttRec: event.sttRec));
    emitter(state);
  }

  void _getListStatusOrder(GetListStatusOrder event, Emitter<SellState> emitter)async{
    emitter(SellLoading());
    SellState state = _handleLoadListStatusOrder(
        await _networkFactory!.getListStatusOrder(_accessToken.toString(),''));
    emitter(state);
  }

  void _deleteEvent(DeleteEvent event, Emitter<SellState> emitter)async{
    emitter(SellLoading());
    SellState state = _handleDeleteOrderHistory(await _networkFactory!.deleteOrderHistory(_accessToken!,event.sttRec));
    emitter(state);
  }

  void _changePageViewEvent(ChangePageViewEvent event, Emitter<SellState> emitter)async{
    emitter(InitialSellState());
    valueChange = event.valueChange;
    emitter(ChangePageViewSuccess(valueChange));
  }

  void _getListHistoryOrder(GetListHistoryOrder event, Emitter<SellState> emitter)async{
    emitter(InitialSellState());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter((!isRefresh && !isLoadMore)
        ? SellLoading()
        : InitialSellState()) ;
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        SellState state = await handleCallApi(i,event.status,event.dateFrom,event.dateTo,event.userId,event.typeLetterId);
        if (state is! GetListHistoryOrderSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    SellState state = await handleCallApi(_currentPage,event.status,event.dateFrom,event.dateTo,event.userId,event.typeLetterId);
    emitter(state);
  }

  SellState _handleDeleteOrderHistory(Object data){
    if(data is String) return SellFailure('Úi, ${data.toString()}');
    try{
      return DeleteOrderSuccess();
    }catch(e){
      return  SellFailure('Úi, ${e.toString()}');
    }
  }

  SellState _handleCreateItemHolder(Object data){
    if(data is String) return SellFailure('Úi, ${data.toString()}');
    try{
      return CreateItemHolderSuccess();
    }catch(e){
      return  SellFailure('Úi, ${e.toString()}');
    }
  }
  SellState _handleDeleteItemHolder(Object data){
    if(data is String) return SellFailure('Úi, ${data.toString()}');
    try{
      return DeleteItemHolderSuccess();
    }catch(e){
      return  SellFailure('Úi, ${e.toString()}');
    }
  }

  Future<SellState> handleCallApi2(String searchText,int pageIndex, bool isSuggest) async {
    SellState state = _handleSearch(await _networkFactory!.getListSuggest(_accessToken.toString(),searchText,pageIndex.toString(),'20'),pageIndex);
    return state;
  }

  Future<SellState> handleCallApi(int pageIndex,int status, DateTime dateFrom,DateTime dateTo, String userId, String letterTypeId) async {
    ListHistoryOrderRequest request = ListHistoryOrderRequest(
        letterTypeId: letterTypeId,
        userCode: userId,
        pageIndex: pageIndex,
        status: status.toString(),
        dateFrom:Utils.parseDateToString(dateFrom, Const.DATE_SV_FORMAT_2).toString(),
        dateTo: Utils.parseDateToString(dateTo, Const.DATE_SV_FORMAT_2).toString(),
        firstElement: '',
        lastElement: '',
        totalRec: 0,
        timeFilter: ''
    );

    SellState state = _handleLoadList(await _networkFactory!.getListHistoryOrderV2(request,_accessToken!), pageIndex);
    return state;
  }

  SellState _handleLoadList(Object data, int pageIndex) {
    if (data is String) return SellFailure('Úi, ${data.toString()}');
    try {
      _list.clear();
      ListHistoryOrderResponse response = ListHistoryOrderResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 10;
      List<Values>? list = response.values;

      if (!Utils.isEmpty(list!) && _list.length >= (pageIndex - 1) * _maxPage + list.length) {
        _list.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          _list = list;
        } else {
          _list.addAll(list);
        }
      }
      if (Utils.isEmpty(_list)) {
        return GetListHistoryOrderEmpty();
      } else {
        isScroll = true;
      }
      return GetListHistoryOrderSuccess();
    } catch (e) {
      return SellFailure('Úi, ${e.toString()}');
    }
  }

  SellState _handleSearch(Object data, int pageIndex) {
    if (data is String) return SellFailure('Úi, ${data.toString()}');
    try {
      _listSuggest.clear();
      ListItemSuggestResponse response = ListItemSuggestResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 10;
      List<ListItemSuggestResponseData>? list = response.data??[];

      if (!Utils.isEmpty(list) && _listSuggest.length >= (pageIndex - 1) * _maxPage + list.length) {
        _listSuggest.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          _listSuggest = list;
        } else {
          _listSuggest.addAll(list);
        }
      }
      if (Utils.isEmpty(_listSuggest)) {
        return GetListSuggestEmpty();
      } else {
        isScroll = true;
      }
      return GetListSuggestSuccess();
    } catch (e) {
      return SellFailure('Úi, ${e.toString()}');
    }
  }

  SellState _handleSearchNoSuggest(Object data,int pageIndex){
    if(data is String) return SellFailure('Úi, ${data.toString()}');
    try{
      SearchListItemResponse response = SearchListItemResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 20;
      List<SearchItemResponseData> list = response.data ?? [];
      if (!Utils.isEmpty(list) && _searchResults.length >= (pageIndex - 1) * _maxPage + list.length) {
        _searchResults.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list); /// delete list cũ -> add data mới vào list đó.
      } else {
        if (_currentPage == 1) {
          _searchResults = list;
        } else {
          _searchResults.addAll(list);
        }
      }
      if (_searchResults.isNotEmpty) {
        isScroll = true;
        return SearchProductSuccess();
      } else {
        return EmptySearchProductState();
      }
    }
    catch(e){
      return SellFailure('Úi, ${e.toString()}');
    }
  }

  SellState _handleLoadListTax(Object data) {
    if (data is String) return SellFailure('Úi, ${data.toString()}');
    try {

      GetListTaxResponse response = GetListTaxResponse.fromJson(data as Map<String,dynamic>);
      print('Thue');
      DataLocal.listTax = response.data??[];
      if(DataLocal.listTax.isNotEmpty){
        GetListTaxResponseData element = GetListTaxResponseData(
          maThue: '#000',
          tenThue: 'Không áp dụng thuế cho đơn hàng này',
          thueSuat: 0.0
        );
        DataLocal.listTax.insert(0, element);
      }

      return GetListTaxSuccess();
    } catch (e) {
      return SellFailure('Úi, ${e.toString()}');
    }
  }

  SellState _handleLoadListApproveOrder(Object data) {
    if (data is String) return SellFailure('Úi, ${data.toString()}');
    try {
      ListApproveOrderResponse response = ListApproveOrderResponse.fromJson(data as Map<String,dynamic>);
      listApproveOrder = response.data??[];
      totalPager = response.totalPage??0;
      if(listApproveOrder.isNotEmpty){
        return GetListApproveOrderSuccess();
      }else{
        return GetListApproveOrderEmpty();
      }
    } catch (e) {
      return SellFailure('Úi, ${e.toString()}');
    }
  }
  int statusOrderList =0;

  SellState _handleLoadListStatusOrder(Object data) {
    if (data is String) return SellFailure('Úi, ${data.toString()}');
    try {
      ListStatusOrderResponse response = ListStatusOrderResponse.fromJson(data as Map<String,dynamic>);
      DataLocal.listStatusToOrder.clear();
      DataLocal.listStatusToOrderCustom.clear();
      DataLocal.listStatusToOrder = response.data??[];
      if(DataLocal.listStatusToOrder.isNotEmpty){
        for (var element in DataLocal.listStatusToOrder) {
          if(element.status.toString().contains("0") || element.status.toString().contains("1") || element.status.toString().contains("2")){
            DataLocal.listStatusToOrderCustom.add(element);
          }
        }
        return GetListStatusOrderSuccess();
      }else{
        return GetListStatusOrderEmpty();
      }
    } catch (e) {
      return SellFailure('Úi, ${e.toString()}');
    }
  }

  SellState _handleItemHolderDetail(Object data) {
    if (data is String) return SellFailure('Úi, ${data.toString()}');
    try {
      ItemHolderDetailResponse response = ItemHolderDetailResponse.fromJson(data as Map<String,dynamic>);
      masterItemHolderDetail = response.master!;
      listItemHolderDetail = response.listItem!;
      return ItemHolderDetailSuccess();
    } catch (e) {
      return SellFailure('Úi, ${e.toString()}');
    }
  }

  // SellState _handleLoadListVVHD(Object data) {
  //   if (data is String) return SellFailure('Úi, ${data.toString()}');
  //   try {
  //
  //     ListVVHDResponse response = ListVVHDResponse.fromJson(data as Map<String,dynamic>);
  //
  //     DataLocal.listVv = response.listVv!;
  //     DataLocal.listHd = response.listHd!;
  //
  //     return GetListVvHdSuccess();
  //   } catch (e) {
  //     return SellFailure('Úi, ${e.toString()}');
  //   }
  // }
  List<ListQDDVT> listQuyDoiDonViTinh = [];
  SellState _handleGetListStock(Object data){
    if(data is String) return SellFailure(data.toString());
    try{
      if(listStockResponse.isNotEmpty) {
        listStockResponse.clear();
      }
      // Const.listKeyGroup = '';
      ListStockAndGroupResponse response = ListStockAndGroupResponse.fromJson(data as Map<String,dynamic>);
      listStockResponse = response.listStore??[];
      listQuyDoiDonViTinh = response.listQuyDoiDonViTinh??[];
      // List<ListGroup> listGroup = response.listGroup??[];

      // if(listGroup.isNotEmpty  && Const.listKeyGroup.isEmpty ){
      //   for (var element in listGroup) {
      //     if(element.maNhom.toString().isNotEmpty && element.maNhom != 'null' && element.maNhom != ''){
      //       Const.listKeyGroup = Const.listKeyGroup.isEmpty ? '${element.loaiNhom}:${element.maNhom}' : '${Const.listKeyGroup},${element.loaiNhom}:${element.maNhom}' ;
      //     }
      //   }
      // }
      return GetListStockEventSuccess();
    }
    catch(e){
      return SellFailure('Úi, ${e.toString()}');
    }
  }

  SellState _handleCreateOrderSuggest(Object data){
    if(data is String) return SellFailure(data.toString());
    try{
      return CreateOrderSuggestSuccess();
    }
    catch(e){
      return SellFailure('Úi, ${e.toString()}');
    }
  }
  ListTableOne master = ListTableOne();
  List<ListTableTwo>? listDetail = [];
  SellState _handleGetDetailOrderSuggest(Object data){
    if(data is String) return SellFailure(data.toString());
    try{
      DetailOrderSuggestResponse response = DetailOrderSuggestResponse.fromJson(data as Map<String,dynamic>);
      master = response.listTableOne != null ? response.listTableOne![0] : ListTableOne();
      listDetail = response.listTableTwo??[];
      return DetailOrderSuggestSuccess();
    }
    catch(e){
      return SellFailure('Úi, ${e.toString()}');
    }
  }
}