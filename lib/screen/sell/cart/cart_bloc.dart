// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:http/http.dart' as http;
import 'package:dms/model/network/request/apply_discount_request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../model/database/data_local.dart';
import '../../../model/database/dbhelper.dart';
import '../../../model/entity/entity.dart';
// import '../../../model/entity/entity_request.dart';
import '../../../model/entity/product.dart';
import '../../../model/network/request/create_order_request.dart';
import '../../../model/network/request/discount_request.dart';
import '../../../model/network/request/order_create_checkin_request.dart';
import '../../../model/network/request/save_inventory_control_request.dart';
import '../../../model/network/request/search_list_item_request.dart';
import '../../../model/network/request/update_order_request.dart';
import '../../../model/network/response/apply_discount_response.dart';
import '../../../model/network/response/cart_response.dart';
import '../../../model/network/response/list_stock_response.dart';
import '../../../model/network/response/list_vvhd_response.dart';
import '../../../model/network/response/search_list_item_response.dart';
import '../../../model/network/response/history_order_detail_reponse.dart';
import '../../../model/network/response/gift_product_list_response.dart';
// import '../../../model/network/services/host.dart';
import '../../../model/network/services/network_factory.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import 'helpers/cart_draft_storage.dart';

class CartBloc extends Bloc<CartEvent,CartState>{

  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String get accessToken => _accessToken!;
  String? _refreshToken;
  String get refreshToken => _refreshToken!;
  
  // ✅ Helper method để call API get list tax
  Future<Object?> getListTaxFromAPI() async {
    try {
      if (_networkFactory != null && _accessToken != null && _accessToken!.isNotEmpty) {
        return await _networkFactory!.getListTax(_accessToken!);
      }
      return null;
    } catch (e) {
      print('❌ Error in getListTaxFromAPI: $e');
      return null;
    }
  }

  final db = DatabaseHelper();

  List<SearchItemResponseData> listOrder = [];
  
  // ✅ Biến tạm để lưu listOrder từ draft khi AddProductToCartEvent chạy
  // Sẽ được restore trong GetListProductFromDBSuccess nếu đang tạo đơn mới
  List<SearchItemResponseData>? preservedListOrderFromDraft;
  
  // List<SearchItemResponseData> listProductGift = [];
  List<Product> listProductOrder = [];
  List<Product> listProductOrderAndUpdate = [];
 List<SearchItemResponseData> listItemOrder = [];
  double? totalMNProduct = 0;
  double? totalMNDiscount = 0;
  double? totalMNVAT = 0;
  double? totalMNPayment = 0;
  bool isChecked = true;

  bool expanded = false;

  bool expandedProductGift = false;

  List<String>? listCodeDisCount = [];
  List<DsCk>? listDiscountName = [];

  final List<Product> _lineItemOrder = <Product>[];
  List<Product> get lineItemOrder => _lineItemOrder;

  List<SearchItemResponseData> _searchResults = <SearchItemResponseData>[];
  List<SearchItemResponseData> get searchResults => _searchResults;

  int _currentPage = 1;
  int _maxPage = Const.MAX_COUNT_ITEM;
  int get maxPage => _maxPage;
  int get currentPage => _currentPage;

  String? _currentSearchText;
  bool isShowCancelButton = false;
  bool isScroll = true;

  bool attachInvoice = false;
  bool exportInvoice =false;
  bool tax =false;

  Future<List<Product>> getListFromDb() {
    return db.fetchAllProduct();
  }
  String? customerName;
  String? phoneCustomer;
  String? addressCustomer;
  String? codeCustomer;

  bool chooseAgencyCode =  false;
  String? codeAgency;
  String? nameAgency;
  String typeDiscount = '';
  double discountAgency = 0;

  String? storeCode;

  bool allowTaxPercent = false;

  int storeIndex = 0;

  int taxIndex = 0;

  // String? transactionCode;
  int typeDeliveryIndex = 0;
  int transactionIndex = 0;
  int typeOrderIndex = 0;
  int typePaymentIndex = 0;

  String? idUser;

  bool isGrantCamera = false;

  List<File> listFileInvoice = [];
  List<ListImageInvoice> listFileInvoiceSave = [];

  List<ListCkTongDon> listCkTongDon = [];
  List<ListCkMatHang> listCkMatHang = [];
  List<ListCk> listDiscount = [];
  
  // CKN - Chiết khấu nhóm: Cho phép chọn sản phẩm tặng từ nhóm (MULTIPLE selection)
  List<ListCkMatHang> listCkn = [];
  bool hasCknDiscount = false;
  String? selectedCknProductCode; // Mã sản phẩm CKN đã chọn
  String? selectedCknSttRecCk; // Mã CK CKN đã chọn
  List<GiftProductItem> listGiftProducts = []; // Danh sách hàng tặng từ API
  String? selectedDiscountGroup; // Legacy - keep for backward compatibility
  Set<String> selectedCknGroups = {}; // Set of group_dk đã chọn (MULTIPLE)
  
  // CKG - Chiết khấu giá: Giảm giá trực tiếp cho sản phẩm (từ list_ck)
  List<ListCk> listCkg = [];
  bool hasCkgDiscount = false;
  Set<String> selectedCkgIds = {}; // Set of maCk đã chọn (multiple selection) - ✅ CHANGED: dùng maCk thay vì sttRecCk_productCode
  
  // HH - Hàng hóa tặng: Tặng hàng cố định kèm theo (từ list_ck)
  List<ListCk> listHH = [];
  bool hasHHDiscount = false;
  Set<String> selectedHHIds = {}; // Set of sttRecCk đã chọn (multiple selection)
  
  // CKTDTT - Chiết khấu tổng đơn tặng tiền (từ listCkTongDon với kieuCK = 'CKTDTT')
  List<ListCkTongDon> listCktdtt = [];
  bool hasCktdttDiscount = false;
  Set<String> selectedCktdttIds = {}; // Set of sttRecCk đã chọn (multiple selection)
  
  // CKTDTH - Chiết khấu tổng đơn tặng hàng (từ listCkMatHang với kieuCK = 'CKTDTH')
  List<ListCkMatHang> listCktdth = [];
  bool hasCktdthDiscount = false;
  Set<String> selectedCktdthGroups = {}; // Set of group_dk đã chọn (multiple selection)

  double totalMoney = 0;
  double totalMoneyOld = 0;
  double totalDiscount = 0;
  double totalDiscountOldByHand = 0;
  double totalDiscountOld = 0;
  double totalTax = 0;
  double valuesTax = 0;
  double totalPayment = 0;
  double totalPaymentOld = 0;

  double totalDiscountByHand = 0;

  String listPromotion = '';

  String maHangTangOld = '';
  String codeDiscountOld = '';
  
  // ✅ Lưu ck_dac_biet từ response apply-discount-v2
  int? ck_dac_biet;

  String codeDiscountTD = '';
  String sttRecCKOld = '';

  String idVv = '';
  String idHd = '';
  String idHdForVv = '';

  String nameVv= 'Chọn Chương trình bán hàng';
  String nameHd = 'Chọn loại hợp đồng';


  List<LineItems> lineItem = [];

  InfoPayment? infoPayment;

  List<ListVv> listVv = [];
  List<ListHd> listHd = [];

  TextEditingController nguoiNhan = TextEditingController();
  TextEditingController ghiChu = TextEditingController();
  TextEditingController thoiGianGiao = TextEditingController();
  TextEditingController tien = TextEditingController();
  TextEditingController baoGia = TextEditingController();

  void reset() {
    _currentSearchText = "";
    _currentPage = 1;
    _searchResults.clear();
  }

  CartBloc(this.context) : super(CartInitial()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefs>(_getPrefs);
    ///
    on<CreateOderEvent>(_createOderEvent);
    on<GetListItemApplyDiscountEvent>(_getListItemApplyDiscountEvent);
    ///
    on<GetListItemUpdateOrderEvent>(_getListItemUpdateOrderEvent);
    on<CheckDisCountWhenUpdateEvent>(_checkDisCountWhenUpdateEvent);
    on<GetListProductFromDB>(_getListProductFromDB);
    on<DeleteProductFromDB>(_deleteProductFromDB);
    on<Decrement>(_decrement);
    on<Increment>(_increment);
    on<SearchProduct>(_searchProduct);
    on<CheckShowCloseEvent>(_checkShowCloseEvent);
    on<AddCartEvent>(_addCartEvent);
    on<CheckInTransferEvent>(_checkInTransferEvent);
    on<PickInfoCustomer>(_pickInfoCustomer);
    on<AddNote>(_addNote);
    on<DeleteAllProductFromDB>(_deleteAllProductFromDB);
    on<PickStoreName>(_pickStoreName);
    on<UpdateOderEvent>(_updateOderEvent);
    on<UpdateProductCount>(_updateProductCount);
    on<UpdateProductCountInventory>(_updateProductCountInventory);
    on<AddProductCountFromCheckIn>(_addProductCountFromCheckIn);
    on<UpdateProductCountOrderFromCheckIn>(_updateProductCountOrderFromCheckIn);
    on<GetCameraEvent>(_getCameraEvent);
    // on<CreateOderFromCheckInEvent>(_createOderFromCheckInEvent);
    on<AddProductSaleOutEvent>(_addProductSaleOutEvent);
    on<PickListTypeDeliveryEvent>(_pickListTypeDeliveryEvent);
    on<PickTransactionName>(_pickTransactionName);
    on<PickTypePayment>(_pickTypePayment);
    on<ChangeHeightListEvent>(_changeHeightListEvent);
    on<ChangeHeightListProductGiftEvent>(_changeHeightListProductGiftEvent);
    on<AddOrDeleteProductGiftEvent>(_addOrDeleteProductGiftEvent);
    on<DeleteEvent>(_deleteEvent);
    on<AddProductToCartEvent>(_addProductToCartEvent);
    on<CalculatorDiscountEvent>(_calculatorDiscountEvent);
    on<GetListStockEvent>(_getListStockEvent);
    on<PickTaxAfter>(_pickTaxAfter);
    on<PickTaxBefore>(_pickTaxBefore);
    on<PickInfoAgency>(_pickInfoAgency);
    on<DeleteProductInCartEvent>(_deleteProductInCartEvent);
    on<SearchItemVvEvent>(_searchItemVvEvent);
    on<SearchItemHdEvent>(_searchItemHdEvent);
    on<CheckIsMarkProductEvent>(_checkIsMarkProductEvent);
    on<CheckAllProductEvent>(_checkAllProductEvent);
    on<AddDiscountForProductEvent>(_addDiscountForProductEvent);
    on<DeleteAllProductEvent>(_deleteAllProductEvent);
    on<AutoDiscountEvent>(_autoDiscountEvent);
    on<AddAllHDVVProductEvent>(_addAllHDVVProductEvent);
    on<GetListVVHD>(_getListVVHD);
    on<ApproveOrderEvent>(_approveOrderEvent);
    on<PickTypeOrderName>(_pickTypeOrderName);
    on<DownloadFileEvent>(_downloadFileEvent);
    on<DownloadFileSuccessEvent>(_downloadFileSuccessEvent);
    on<SearchItemInOrderEvent>(_searchItemInOrderEvent);
    on<CalculatorTaxForItemEvent>(_calculatorTaxForItemEvent);
    on<UpdateListOrder>(_updateListOrder);
    on<GetGiftProductListEvent>(_getGiftProductListEvent);
    on<ApplyManualTotalDiscountEvent>(_applyManualTotalDiscountEvent);
    on<ApplyManualTotalDiscountPercentEvent>(_applyManualTotalDiscountPercentEvent);
  }
  final box = GetStorage();
  
  void _getPrefs(GetPrefs event, Emitter<CartState> emitter)async{
    emitter(CartInitial());
    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    idUser = box.read(Const.USER_ID);
    
    // ✅ PRESERVE gifts từ chi tiết đơn hàng trước khi restore từ cache
    // (gifProductByHand == false và không có typeCK)
    List<SearchItemResponseData> preservedGiftsFromOrderDetail = DataLocal.listProductGift.where((gift) => 
      gift.gifProduct == true && 
      gift.gifProductByHand == false && 
      (gift.typeCK == null || gift.typeCK == '')
    ).toList();
    print('💰 _getPrefs: Preserving ${preservedGiftsFromOrderDetail.length} gifts from order detail before restore from cache');
    
    // ✅ PRESERVE gifts từ API tính chiết khấu (có typeCK)
    List<SearchItemResponseData> preservedGiftsFromAPI = DataLocal.listProductGift.where((gift) => 
      gift.gifProduct == true && 
      gift.gifProductByHand == false && 
      gift.typeCK != null && gift.typeCK!.isNotEmpty
    ).toList();
    print('💰 _getPrefs: Preserving ${preservedGiftsFromAPI.length} gifts from discount API before restore from cache');
    
    // Khôi phục danh sách sản phẩm tặng từ cache (chỉ gifts thêm bằng tay)
    // ✅ CHỈ restore từ cache nếu DataLocal.listProductGift đang rỗng (chưa được restore từ draft)
    // Nếu đã có dữ liệu từ draft, không restore từ cache để tránh restore lại hàng tặng đã xóa
    List<SearchItemResponseData> restoredGiftsFromCache = [];
    if (DataLocal.listProductGift.isEmpty) {
      // Chỉ restore từ cache nếu chưa có dữ liệu (chưa được restore từ draft)
      try{
        final storedGifts = box.read('listProductGift');
        if(storedGifts != null){
          final List decoded = jsonDecode(storedGifts) as List;
          // Chỉ khôi phục quà tặng thêm thủ công (gifProductByHand == true)
          restoredGiftsFromCache = decoded
              .map((e)=> SearchItemResponseData.fromJson(e as Map<String,dynamic>))
              .where((e)=> e.gifProductByHand == true)
              .toList();
          print('💰 _getPrefs: Restored ${restoredGiftsFromCache.length} gifts from cache (manual gifts)');
        }
      }catch(_){
        // nếu parse lỗi thì bỏ qua
      }
    } else {
      print('💰 _getPrefs: Skip restore from cache - DataLocal.listProductGift already has ${DataLocal.listProductGift.length} items (likely from draft)');
    }
    
    // ✅ MERGE: Gifts từ chi tiết đơn hàng + Gifts từ API + Gifts từ cache (thêm bằng tay)
    // Chỉ clear và merge nếu chưa có dữ liệu từ draft
    if (DataLocal.listProductGift.isEmpty) {
      DataLocal.listProductGift.addAll(preservedGiftsFromOrderDetail); // 1. Từ chi tiết đơn hàng
      DataLocal.listProductGift.addAll(preservedGiftsFromAPI); // 2. Từ API tính chiết khấu
      DataLocal.listProductGift.addAll(restoredGiftsFromCache); // 3. Từ cache (thêm bằng tay)
    } else {
      // Đã có dữ liệu từ draft, chỉ merge gifts từ API (không merge từ cache)
      print('💰 _getPrefs: DataLocal.listProductGift already has data, only merging gifts from API');
      // Merge gifts từ API vào danh sách hiện tại (tránh duplicate)
      // ✅ Khi merge, giữ stockCode và stockName từ draft nếu đã có
      for (var apiGift in preservedGiftsFromAPI) {
        final existingGift = DataLocal.listProductGift.firstWhere(
          (gift) =>
            gift.code == apiGift.code &&
            gift.typeCK == apiGift.typeCK &&
            gift.sttRecCK == apiGift.sttRecCK,
          orElse: () => apiGift, // Nếu không tìm thấy, dùng apiGift
        );
        
        if (existingGift == apiGift) {
          // Không tìm thấy trong draft, thêm mới
          DataLocal.listProductGift.add(apiGift);
        } else {
          // ✅ Tìm thấy trong draft, giữ stockCode và stockName từ draft nếu đã có
          if ((existingGift.stockCode != null && existingGift.stockCode.toString().trim().isNotEmpty && existingGift.stockCode.toString().trim() != 'null') ||
              (existingGift.stockName != null && existingGift.stockName.toString().trim().isNotEmpty && existingGift.stockName.toString().trim() != 'null')) {
            // Draft đã có kho, giữ lại
            print('💰 Preserving stock info from draft for gift ${apiGift.code}: stockCode=${existingGift.stockCode}, stockName=${existingGift.stockName}');
          } else {
            // Draft chưa có kho, cập nhật từ API nếu có
            if ((apiGift.stockCode != null && apiGift.stockCode.toString().trim().isNotEmpty && apiGift.stockCode.toString().trim() != 'null') ||
                (apiGift.stockName != null && apiGift.stockName.toString().trim().isNotEmpty && apiGift.stockName.toString().trim() != 'null')) {
              existingGift.stockCode = apiGift.stockCode;
              existingGift.stockName = apiGift.stockName;
              print('💰 Updated stock info from API for gift ${apiGift.code}: stockCode=${apiGift.stockCode}, stockName=${apiGift.stockName}');
            }
          }
        }
      }
    }
    
    // Tính lại totalProductGift
    totalProductGift = 0;
    for (var gift in DataLocal.listProductGift) {
      totalProductGift += gift.count ?? 0;
    }
    
    print('💰 _getPrefs: After merge - totalProductGift=$totalProductGift, listProductGift.length=${DataLocal.listProductGift.length}');
    print('  - From order detail: ${preservedGiftsFromOrderDetail.length}');
    print('  - From discount API: ${preservedGiftsFromAPI.length}');
    print('  - From cache (manual): ${restoredGiftsFromCache.length}');
    
    emitter(GetPrefsSuccess());
  }
  void _downloadFileSuccessEvent(DownloadFileSuccessEvent event, Emitter<CartState> emitter)async{
    emitter(CartInitial());
  }

  int totalPager = 0;
  String idDVTC = '';
  String nameDVTC = '';
  String idMDC = '';
  String nameMDC = '';

  void _searchItemInOrderEvent(SearchItemInOrderEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    CartState state;
    if(event.typeSearch == 1){
      state = _handleLoadListSearchItemInOrder(await _networkFactory!.getListDVTC(_accessToken!,event.pageIndex,20));
    }else if(event.typeSearch == 2){
      GetListItemSearchInOrderRequest request = GetListItemSearchInOrderRequest(
        maKh: event.customerID,
        pageIndex: event.pageIndex,
        pageCount: 20
      );
      state = _handleLoadListSearchItemInOrder(await _networkFactory!.getListMDC(request,_accessToken.toString()));
    }else{
      GetListItemSearchInOrder2Request request = GetListItemSearchInOrder2Request(
          maKh: event.customerID,
          pageIndex: event.pageIndex,
          keySearch: event.keySearch,
          pageCount: 20
      );
      state = _handleLoadListSearchItemInOrder(await _networkFactory!.getListNVKD(request,_accessToken.toString()));
    }

    emitter(state);
  }
  List<SearchItemResponseDataOrder>  listItemInOrder = [];
  CartState _handleLoadListSearchItemInOrder(Object data) {
    if (data is String) return CartFailure('Úi, ${data.toString()}');
    try {
      listItemInOrder.clear();
      SearchItemResponse response = SearchItemResponse.fromJson(data as Map<String,dynamic>);
      listItemInOrder = response.data??[];
      totalPager = response.totalPage!;
      return SearchItemSuccess();
    } catch (e) {
      return CartFailure('Úi, ${e.toString()}');
    }
  }


  void _getListVVHD(GetListVVHD event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    CartState state = _handleLoadListVVHD(await _networkFactory!.getListVVHD(_accessToken!,codeCustomer.toString()));
    emitter(state);
  }

  void _autoDiscountEvent(AutoDiscountEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    for (int i = 0; i <= listOrder.length -1; i++) {
      if(i < listOrder.length -1){
        if(listOrder[i].discountPercentByHand > 0 && (listOrder[i + 1].discountPercentByHand == 0)){
          listOrder[i + 1].discountByHand = true;
          double sl = listOrder[i + 1].count!;
          double price = allowTaxPercent == true ?  listOrder[i + 1].priceAfterTax! : (/*listOrder[i + 1].giaGui > 0 ? listOrder[i + 1].giaGui :*/ listOrder[i + 1].giaSuaDoi);
          listOrder[i + 1].discountPercentByHand = listOrder[i].discountPercentByHand;
          totalPayment = totalPayment -  (price * sl * listOrder[i].discountPercentByHand )/100;
          listOrder[i + 1].ckntByHand = (price * sl * listOrder[i].discountPercentByHand )/100;
          listOrder[i + 1].priceAfter2 = price;
          listOrder[i + 1].priceAfter = ( /*listOrder[i + 1].giaGui > 0 ? listOrder[i + 1].giaGui :*/ listOrder[i + 1].giaSuaDoi - ((/*listOrder[i + 1].giaGui > 0 ? listOrder[i + 1].giaGui :*/ listOrder[i + 1].giaSuaDoi * 1) * listOrder[i].discountPercentByHand)/100);
          if(DataLocal.listOrderCalculatorDiscount.any((element) => element.code.toString().trim() == listOrder[i].code.toString().trim())){
            DataLocal.listOrderCalculatorDiscount.removeAt(DataLocal.listOrderCalculatorDiscount.indexWhere((element) => element.code.toString().trim() == listOrder[i].code.toString().trim()));
            DataLocal.listOrderCalculatorDiscount.add(listOrder[i]);
          }
          else{
            DataLocal.listOrderCalculatorDiscount.add(listOrder[i]);
          }
        }
      }
    }
    emitter(AutoDiscountEventSuccess());
  }

  void _addDiscountForProductEvent(AddDiscountForProductEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    for (var element in listOrder) {
      if(element.isMark == 1){
        element.discountByHand = true;
        double sl = element.count!;
        double price = allowTaxPercent == true ?  element.priceAfterTax! : (element.giaSuaDoi != 0 ? element.giaSuaDoi : element.price??0);
        element.discountPercentByHand = event.discountValues;
        totalPayment = totalPayment -  (price * sl * event.discountValues )/100;
        element.ckntByHand = (price * sl * event.discountValues)/100;
        element.priceAfter2 = price;
        element.priceAfter =
       /* element.giaGui > 0
            ?
        (element.giaGui - ((element.giaGui * 1) * event.discountValues)/100)
            :*/
        (element.giaSuaDoi - ((element.giaSuaDoi * 1) * event.discountValues)/100);
        if(DataLocal.listOrderCalculatorDiscount.any((elements) => elements.code.toString().trim() == element.code.toString().trim())){
          DataLocal.listOrderCalculatorDiscount.removeAt(DataLocal.listOrderCalculatorDiscount.indexWhere((elements) => elements.code.toString().trim() == element.code.toString().trim()));
          DataLocal.listOrderCalculatorDiscount.add(element);
        }
        else{
          DataLocal.listOrderCalculatorDiscount.add(element);
        }
      }
    }
    emitter(AddDiscountForProductEventSuccess());
  }

  void _deleteAllProductEvent(DeleteAllProductEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    if(listOrder.isNotEmpty){
      for (int i = 0; i < listOrder.length; i++) {
        if(listOrder[i].isMark == 1){
          deleteProduct(listOrder[i].code.toString(), listOrder[i].stockCode.toString().trim());
        }
      }
    }
    listOrder.clear();
    emitter(DeleteAllProductEventSuccess());
  }
  
  void _addAllHDVVProductEvent(AddAllHDVVProductEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    for (var element in listOrder) {
      if(element.isMark == 1){
        element.chooseVuViec = true;
        element.idVv = event.idVv;
        element.nameVv = event.nameVv;
        element.idHd = event.idHd;
        element.nameHd = event.nameHd;
        element.idHdForVv = event.idHdForVv;
        add(CalculatorDiscountEvent(addOnProduct: true,product: element,reLoad: false, addTax: false));
      }
    }
    emitter(AddAllHDVVProductEventSuccess());
  }

  void _checkAllProductEvent(CheckAllProductEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    checkAllProduct = event.isMark;
    totalProductBuy = 0;
    totalProductView = 0;

    for (var element in listOrder) {
      element.isMark = event.isMark == true ? 1 : 0;
      if(event.isMark == true){
        totalProductBuy = totalProductBuy + 1;
        totalProductView = totalProductView + element.count!;
      }
      Product production = Product(
        code: element.code,
        name: element.name,
        name2: element.name2,
        dvt:element.dvt,
        description:element.descript,
        price: element.price ,
        priceMin: element.priceMin,


        priceAfterTax: element.priceAfterTax,
        taxPercent: element.taxPercent,
        valuesTax: element.valuesTax,

        applyPriceAfterTax: element.applyPriceAfterTax == true ? 1 : 0,
        discountByHand: element.discountByHand == true ? 1 : 0,
        discountPercentByHand: element.discountPercentByHand,
        ckntByHand: element.ckntByHand,
        giaSuaDoi: element.giaSuaDoi,
        priceOk: element.priceOk,
        woPrice: element.woPrice,
        woPriceAfter: element.woPriceAfter,


        discountPercent:element.discountPercent,
        priceAfter:  element.priceAfter ,

        imageUrl:element.imageUrl ?? '',
        count:element.count,
        countMax: element.countMax,
        so_luong_kd: element.so_luong_kd,
        maVt2: element.maVt2,
        sttRec0: element.sttRec0,
        isMark: event.isMark == true ? 1  : 0,
        discountMoney:element.discountMoney ?? '0',
        discountProduct:element.discountProduct ?? '0',
        budgetForItem:element.budgetForItem ?? '',
        budgetForProduct:element.budgetForProduct ?? '',
        residualValueProduct:element.residualValueProduct ?? 0,
        residualValue:element.residualValue ?? 0,
        unit:element.unit ?? '',
        unitProduct:element.unitProduct ?? '',
        dsCKLineItem:element.maCk.toString(),
        allowDvt: element.allowDvt == true ? 0 : 1,
        contentDvt: element.contentDvt ?? '',
        kColorFormatAlphaB: element.kColorFormatAlphaB?.value,
        codeStock: element.stockCode,
        nameStock: element.stockName,
        stockAmount:element.stockAmount,

      );
      db.updateProduct(production,production.codeStock.toString(),false);
    }
    emitter(CheckAllIsMarkProductSuccess(event.isMark));
  }

  void _updateListOrder(UpdateListOrder event, Emitter<CartState> emitter){
    emitter(CartInitial());
    for (var element in listOrder) {
      Product production = Product(
        code: element.code,
        name: element.name,
        name2: element.name2,
        dvt:element.dvt,
        description:element.descript,
        price: element.price ,
        priceMin: element.priceMin,


        priceAfterTax: element.priceAfterTax,
        taxPercent: element.taxPercent,
        valuesTax: element.valuesTax,

        applyPriceAfterTax: element.applyPriceAfterTax == true ? 1 : 0,
        discountByHand: element.discountByHand == true ? 1 : 0,
        discountPercentByHand: element.discountPercentByHand,
        ckntByHand: element.ckntByHand,
        giaSuaDoi: element.giaSuaDoi,
        priceOk: element.priceOk,
        woPrice: element.woPrice,
        woPriceAfter: element.woPriceAfter,


        discountPercent:element.discountPercent,
        priceAfter:  element.priceAfter ,

        imageUrl:element.imageUrl ?? '',
        count:element.count,
        countMax: element.countMax,
        so_luong_kd: element.so_luong_kd,
        maVt2: element.maVt2,
        sttRec0: element.sttRec0,
        isMark: 1,
        discountMoney:element.discountMoney ?? '0',
        discountProduct:element.discountProduct ?? '0',
        budgetForItem:element.budgetForItem ?? '',
        budgetForProduct:element.budgetForProduct ?? '',
        residualValueProduct:element.residualValueProduct ?? 0,
        residualValue:element.residualValue ?? 0,
        unit:element.unit ?? '',
        unitProduct:element.unitProduct ?? '',
        dsCKLineItem:element.maCk.toString(),
        allowDvt: element.allowDvt == true ? 0 : 1,
        contentDvt: element.contentDvt ?? '',
        kColorFormatAlphaB: element.kColorFormatAlphaB?.value,
        codeStock: element.stockCode,
        nameStock: element.stockName,
        stockAmount:element.stockAmount,

      );
      db.updateProduct(production,production.codeStock.toString(),false);
    }
    emitter(CartInitial());
  }

  bool checkAllProduct = false;
  double totalProductBuy = 0;
  double totalProductView= 0;
  void _checkIsMarkProductEvent(CheckIsMarkProductEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    db.updateProduct(event.production,event.production.codeStock.toString(),false);
    totalProductBuy = 0;
    totalProductView = 0;
    if(event.isMark == true){
      totalMoney = totalMoney + (event.item.price! * event.item.count!);
      totalTax = totalTax + ((event.item.valuesTax.toString() != null && event.item.valuesTax.toString() != 'null' && event.item.valuesTax.toString() != '') ? event.item.valuesTax! : 0);
      totalDiscount = totalDiscount + ((event.item.price! * event.item.count!) - (event.item.priceAfter! * event.item.count!));
    }else{
      if(totalMoney > 0){
        totalMoney = totalMoney - (event.item.price! * event.item.count!);
        totalTax = totalTax - ((event.item.valuesTax.toString() != null && event.item.valuesTax.toString() != 'null' && event.item.valuesTax.toString() != '') ? event.item.valuesTax! : 0);
        totalDiscount = totalDiscount - ((event.item.price! * event.item.count!) - (event.item.priceAfter! * event.item.count!));
      }
    }
    if(listOrder.isNotEmpty){
      bool allows = true;
      for (var element in listOrder) {
        if(element.isMark == 0){
          checkAllProduct = false;
          allows = false;
          //break;
        }else{
          totalProductBuy = totalProductBuy + 1;
          totalProductView = totalProductView + element.count!;
    }
      }
      if(allows == true){
        checkAllProduct = true;
      }
    }
    else{
      checkAllProduct = false;
    }
    emitter(CheckIsMarkProductSuccess());
  }

  void _searchItemVvEvent(SearchItemVvEvent event, Emitter<CartState> emitter){
    emitter(CartLoading());
    listVv = getSuggestionsVv(event.keysText);
    emitter(SearchItemVvSuccess());
  }

  List<ListVv> getSuggestionsVv(String query) {
    List<ListVv> matches = [];
    matches.addAll(DataLocal.listVv);
    matches.retainWhere((s) => s.tenVv.toString().toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  void _searchItemHdEvent(SearchItemHdEvent event, Emitter<CartState> emitter){
    emitter(CartLoading());
    listHd = getSuggestionsHd(event.keysText);
    emitter(SearchItemVvSuccess());
  }

  List<ListHd> getSuggestionsHd(String query) {
    List<ListHd> matches = [];
    matches.addAll(DataLocal.listHd);
    matches.retainWhere((s) => s.tenHd.toString().toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  void _getListItemApplyDiscountEvent(GetListItemApplyDiscountEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    ApplyDiscountRequest request = ApplyDiscountRequest(
      listCKVT: event.listCKVT,
      listPromo: event.listPromotion,
      listItem: event.listItem,
      listQty: event.listQty,
      listMoney: event.listMoney,
      listPrice: event.listPrice,
        warehouseId: event.warehouseId,
      customerId: event.customerId
    );
    CartState state = _handlerApplyDiscountV2(await _networkFactory!.applyDiscountV2(request, _accessToken!),event.keyLoad);
    emitter(state);
  }

  void _changeHeightListEvent(ChangeHeightListEvent event, Emitter<CartState> emitter)async{
    emitter(CartInitial());
    expanded = event.expanded!;
    emitter(ChangeHeightListSuccess());
  }

  void _changeHeightListProductGiftEvent(ChangeHeightListProductGiftEvent event, Emitter<CartState> emitter)async{
    emitter(CartInitial());
    expandedProductGift = event.expandedProductGift!;
    emitter(ChangeHeightListSuccess());
  }

  double totalMoneyProductGift = 0;
  void _addOrDeleteProductGiftEvent(AddOrDeleteProductGiftEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    if(event.addItem == true){
      if(DataLocal.listProductGift.isEmpty){
        DataLocal.listProductGift.add(event.item);
      }else{
        // Check if product already exists
        bool productExists = DataLocal.listProductGift.any((element) => 
          element.code.toString().trim() == event.item.code.toString().trim() &&
          element.typeCK == event.item.typeCK &&
          element.sttRecCK == event.item.sttRecCK
        );
        
        if(productExists){
          // Remove existing product with same code + CK info
          DataLocal.listProductGift.removeWhere((element) => 
            element.code.toString().trim() == event.item.code.toString().trim() &&
            element.typeCK == event.item.typeCK &&
            element.sttRecCK == event.item.sttRecCK
          );
          // Add updated product
          DataLocal.listProductGift.add(event.item);
        }else{
          // Add new product
          DataLocal.listProductGift.add(event.item);
        }
      }
    }else{
      // Remove product when deleting
      DataLocal.listProductGift.removeWhere((element) => 
        element.code.toString().trim() == event.item.code.toString().trim() &&
        element.typeCK == event.item.typeCK &&
        element.sttRecCK == event.item.sttRecCK
      );
    }
    totalMoneyProductGift = 0;
    if(Const.enableViewPriceAndTotalPriceProductGift == true && DataLocal.listProductGift.isNotEmpty){
      for (var element in DataLocal.listProductGift) {
        totalMoneyProductGift = totalMoneyProductGift + (
            ( /*element.giaGui > 0 ?  element.giaGui :*/ element.giaSuaDoi)
                *
            ((element.count.toString().isNotEmpty && element.count.toString() != 'null') ? element.count! : 0)
        );
      }
    }
    // Lưu lại chỉ các quà tặng thêm thủ công để mở app vẫn giữ được
    try{
      final manualGifts = DataLocal.listProductGift.where((e)=> e.gifProductByHand == true).toList();
      box.write('listProductGift', jsonEncode(manualGifts.map((e)=>e.toJson()).toList()));
    }catch(_){
      // ignore write error
    }
    emitter(AddOrDeleteProductGiftSuccess());
  }

  void _getCameraEvent(GetCameraEvent event, Emitter<CartState> emitter)async{
    emitter(CartInitial());
    Map<Permission, PermissionStatus> permissionRequestResult = await [Permission.location,Permission.camera].request();
    if (permissionRequestResult[Permission.camera] == PermissionStatus.granted) {
      isGrantCamera = true;
      emitter(GrantCameraPermission());
    }
    else {
      if (await Permission.camera.isPermanentlyDenied) {
        emitter(CartInitial());
      } else {
        isGrantCamera = false;
        emitter(EmployeeScanFailure('Vui lòng cấp quyền truy cập Camera.'));
      }
    }
  }

  void _pickStoreName(PickStoreName event, Emitter<CartState> emitter){
    emitter(CartInitial());
    storeIndex = event.storeIndex;
    emitter(PickStoreNameSuccess());
  }

  void _pickTaxBefore(PickTaxBefore event, Emitter<CartState> emitter){
    emitter(CartLoading());
    taxIndex = event.taxIndex;
    
    // 不要清空 listOrder 和 listItemOrder，因为UI需要它们来显示产品
    // 只需要更新税额相关的计算
    
    // 重置税额和总金额
    totalTax = 0;
    totalPayment = 0;
    
    if(listProductOrderAndUpdate.isNotEmpty){
      for (var element in listProductOrderAndUpdate) {
        try {
          if(element.code != null && element.code != '' && element.code != 'null'){
            // 获取价格（优先使用 giaSuaDoi，如果没有则使用 price）
            double basePrice = element.giaSuaDoi > 0 ? element.giaSuaDoi : (element.price ?? 0);
            double count = element.count ?? 0;
            
            if(basePrice > 0 && count > 0){
              // 设置税率
              element.taxPercent = DataLocal.taxPercent;
              
              // 计算含税单价（税在折扣前）
              element.priceAfterTax = basePrice + ((basePrice * DataLocal.taxPercent) / 100);
              
              // 计算税额（单价含税 * 数量 - 不含税金额）
              element.valuesTax = ((basePrice * count) * DataLocal.taxPercent) / 100;
              
              // 累加总税额
              totalTax = totalTax + element.valuesTax!;
              
              // 累加总金额（不含税金额）
              totalPayment = totalPayment + (basePrice * count);
              
              // 同时更新 listOrder 中对应项的税额信息
              var matchingItems = listOrder.where((valuesE) => valuesE.code.toString().trim() == element.code.toString().trim());
              if(matchingItems.isNotEmpty){
                SearchItemResponseData item = matchingItems.first;
                item.taxPercent = DataLocal.taxPercent;
                item.priceAfterTax = element.priceAfterTax;
                item.valuesTax = element.valuesTax;
              }
            }
          }
        } catch (e) {
          // 如果计算出错，跳过这个产品
          print('Error in _pickTaxBefore for code ${element.code}: $e');
        }
      }
      
      // 根据 allowTaxPercent 决定是否将税额加入总金额
      if(allowTaxPercent == false){
        totalPayment = totalPaymentOld - totalDiscount;
      } else {
        totalPayment = totalPayment + totalTax;
      }
      
      print("_pickTaxBefore - totalPayment: $totalPayment");
      print("_pickTaxBefore - totalTax: $totalTax");
      print("_pickTaxBefore - totalDiscount: $totalDiscount");
      
      emitter(PickTaxBeforeSuccess());
    }else{
      emitter(PickTaxNameFail());
    }
  }

  bool showSelectAgency = false;
  String transactionName = '';
  String typeDeliveryName = '';
  String typeDeliveryCode = '';

  void _pickTransactionName(PickTransactionName event, Emitter<CartState> emitter){
    emitter(CartLoading());
    transactionIndex = event.transactionIndex;
    transactionName = event.transactionName;
    if(Const.chooseAgency == true){
      if(event.showSelectAgency == 1){
        showSelectAgency = true;
      }else{
        showSelectAgency = false;
      }
    }
    emitter(PickTransactionSuccess(showSelectAgency));
  }
  String typeOrderName = '';
  String typeOrderCode = '';
  void _pickTypeOrderName(PickTypeOrderName event, Emitter<CartState> emitter){
    emitter(CartLoading());
    typeOrderIndex = event.typeOrderIndex;
    typeOrderName = event.typeOrderName;
    typeOrderCode = event.typeOrderCode;
    emitter(PickTypeOrderSuccess());
  }
  void _pickListTypeDeliveryEvent(PickListTypeDeliveryEvent event, Emitter<CartState> emitter){
    emitter(CartLoading());
    typeDeliveryIndex = event.typeDeliveryIndex;
    typeDeliveryName = event.item.idTypeDelivery.toString();
    typeDeliveryCode = event.item.nameTypeDelivery.toString();
    emitter(PickTypeDeliverySuccess());
  }

  double discountTypePayment = 0;
  // Chiết khấu tổng đơn nhập tay (%) cho freeDiscount
  double manualTotalDiscountPercent = 0;
  // Giá trị chiết khấu tổng đơn nhập tay (tính từ percent) để tránh cộng dồn khi recalculation nhiều lần
  double manualTotalDiscountValue = 0;
  double totalDiscountWhenChooseTypePayment = 0;
  String codeTypePayment = '';

  bool showWarning = true;

  // Recalculate totals locally (manual total discount only)
  void _applyManualTotalDiscountEvent(ApplyManualTotalDiscountEvent event, Emitter<CartState> emitter) {
    try {
      // Recompute item totals (exclude gifts)
      totalMoney = 0;
      totalDiscount = 0; // item-level discount sum (will add order-level later if needed)
      totalTax = 0;

      for (var item in listOrder) {
        if (item.gifProduct == true) continue;

        double itemPrice = item.giaSuaDoi ?? item.price ?? 0;
        double itemCount = item.count ?? 0;
        double itemTotal = itemPrice * itemCount;
        totalMoney += itemTotal;

        double itemDiscount = 0;
        if (item.discountByHand == true && (item.ckntByHand ?? 0) > 0) {
          itemDiscount = item.ckntByHand ?? 0;
        } else if (item.discountByHand == true && (item.discountPercentByHand ?? 0) > 0) {
          itemDiscount = (itemPrice * itemCount * item.discountPercentByHand!) / 100;
          item.ckntByHand = itemDiscount;
        } else if (item.discountByHand == true && (item.discountPercentByHand ?? 0) == 0) {
          item.discountPercentByHand = 0;
          item.ckntByHand = 0;
          item.discountPercent = 0;
          item.ck = 0;
          item.cknt = 0;
          item.priceAfter = itemPrice;
          item.priceAfter2 = itemPrice;
          itemDiscount = 0;
        } else if (item.cknt != null && item.cknt! > 0) {
          itemDiscount = item.cknt ?? 0;
        } else if (item.discountPercent != null && item.discountPercent! > 0) {
          itemDiscount = (itemPrice * itemCount * item.discountPercent!) / 100;
        }

        totalDiscount += itemDiscount;
      }

      // Bỏ hoàn toàn manual tổng đơn, sẽ áp dụng ở cuối flow (handleCalculator) để tránh lệch state
      manualTotalDiscountValue = 0;
      totalPayment = totalMoney + totalTax - totalDiscount;

      print('💰 [MANUAL TOTAL DISCOUNT LOCAL - SIMPLE] percent=$manualTotalDiscountPercent%, totalPayment=$totalPayment, totalDiscount(item)=$totalDiscount');
      emitter(CalculatorDiscountSuccess());
    } catch (e) {
      emitter(CartFailure('Lỗi tính chiết khấu tổng đơn: $e'));
    }
  }

  void _applyManualTotalDiscountPercentEvent(
    ApplyManualTotalDiscountPercentEvent event,
    Emitter<CartState> emitter,
  ) {
    try {
      // Clamp 0..100
      double percentValue = event.percent;
      if (percentValue < 0) percentValue = 0;
      if (percentValue > 100) percentValue = 100;

      manualTotalDiscountPercent = percentValue;

      print(
        '💰 [MANUAL TOTAL DISCOUNT APPLY] Set manualTotalDiscountPercent=$manualTotalDiscountPercent%, '
        'triggering CalculatorDiscountEvent to recalculate...',
      );

      // ✅ QUAN TRỌNG: Trigger CalculatorDiscountEvent để tính toán lại toàn bộ
      // thay vì tính toán trực tiếp, đảm bảo tính toán nhất quán với logic trong _calculatorDiscountEvent
      _calculatorDiscountEvent(
        CalculatorDiscountEvent(
          addOnProduct: false,
          reLoad: false,
          addTax: false,
        ),
        emitter,
      );
    } catch (e) {
      emitter(CartFailure('Lỗi áp dụng chiết khấu tổng đơn: $e'));
    }
  }

  void _pickTypePayment(PickTypePayment event, Emitter<CartState> emitter){
    emitter(CartLoading());
    typePaymentIndex = event.typePaymentIndex;
    codeTypePayment = event.nameTypePayment;
    if(listProductOrderAndUpdate.isNotEmpty){
      chooseTypePayment();
      emitter(PickTypePaymentSuccess());
    // }else{
    //   if(showWarning == true){
    //     emitter(CartFailure('Úi, Giỏ hàng của bạn có gì đâu'));
    //   }
    }
  }

  bool showDatePayment = false;

  void chooseTypePayment(){

    if(codeTypePayment.contains('Thanh toán ngay')){
      showDatePayment = false;
      discountTypePayment = 0;
      for (var element in DataLocal.listTypePayment) {
        discountTypePayment = element.discountPercent!;
        break;
      }
    }else{
      showDatePayment = false;
      if(codeTypePayment.contains('Công nợ')){
        showDatePayment = true;
      }
      discountTypePayment = 0;
      totalDiscount = totalDiscount - totalDiscountWhenChooseTypePayment;
      double totalDiscountForOderValue = totalDiscountForOder ?? 0;
      totalPayment = totalMoney - totalDiscount - totalDiscountForOderValue;
      totalDiscountWhenChooseTypePayment = 0;
    }
    if(discountTypePayment > 0 && listProductOrderAndUpdate.isNotEmpty){
      if(discountAgency == 0){
        totalDiscount = totalDiscountOldByHand;
        totalPayment = totalPaymentOld;
      }
      double totalMoneyTypePayment = 0;
      totalDiscountWhenChooseTypePayment = 0;
      for(var element in listProductOrderAndUpdate){
        totalMoneyTypePayment = totalMoneyTypePayment + ( /*element.giaGui > 0 ?  element.giaGui :*/ element.giaSuaDoi * element.count!);
      }
      totalDiscountWhenChooseTypePayment = (totalMoneyTypePayment * discountTypePayment)/100;
      totalDiscount = totalDiscount + totalDiscountWhenChooseTypePayment;
      double totalDiscountForOderValue = totalDiscountForOder ?? 0;
      totalPayment = totalMoney - (totalDiscount + valuesTax) - totalDiscountForOderValue;
    }
  }

  double totalDiscountWhenChooseAgency = 0;

  void _pickInfoAgency(PickInfoAgency event, Emitter<CartState> emitter){
    emitter(CartLoading());
    codeAgency = event.codeAgency;
    nameAgency = event.nameAgency;
    typeDiscount = event.typeDiscount!;
    chooseAgency(event.cancelAgency);
    emitter(PickAgencySuccess());
  }

  void chooseAgency(bool cancelAgency){
    if(DataLocal.listAgency.isNotEmpty && listProductOrderAndUpdate.isNotEmpty && typeDiscount.isNotEmpty && cancelAgency == false){
      discountAgency = 0;
      for (var element in DataLocal.listAgency) {
        if(element.typeCustomer.toString().trim() == typeDiscount.toString().trim()){
          discountAgency = element.discountPercent!;
          break;
        }
      }
    }
    else{
      nameAgency = null;
      codeAgency = null;
      discountAgency = 0;
      totalDiscount = totalDiscount - totalDiscountWhenChooseAgency;
      double totalDiscountForOderValue = totalDiscountForOder ?? 0;
      totalPayment = totalMoney - totalDiscount - totalDiscountForOderValue;
    }
    if(discountAgency > 0 && listProductOrderAndUpdate.isNotEmpty && typeDiscount.isNotEmpty && cancelAgency == false){
      if(discountTypePayment == 0){
        totalDiscount = totalDiscountOldByHand;
        totalPayment = totalPaymentOld;
      }

      double totalMoneyAgency = 0;
      totalDiscountWhenChooseAgency = 0;
      for(var element in listProductOrderAndUpdate){
        totalMoneyAgency = totalMoneyAgency + ( /*element.giaGui > 0 ?  element.giaGui :*/ element.giaSuaDoi * element.count!);
      }
      totalDiscountWhenChooseAgency = (totalMoneyAgency * discountAgency)/100;
      totalDiscount = totalDiscount + totalDiscountWhenChooseAgency;
      double totalDiscountForOderValue = totalDiscountForOder ?? 0;
      totalPayment = totalMoney - (totalDiscount + valuesTax) - totalDiscountForOderValue;
    }
  }

  void _addProductCountFromCheckIn(AddProductCountFromCheckIn event, Emitter<CartState> emitter){
    emitter(CartLoading());
    if(DataLocal.listOrderProductLocal.isNotEmpty){
      bool itemIsExits = DataLocal.listOrderProductLocal.any((item) => item.code == event.product.code);
      if(itemIsExits == true){
        var itemCheck = DataLocal.listOrderProductLocal.firstWhere((item) => item.code == event.product.code);
        if(itemCheck != null){
          int index  = DataLocal.listOrderProductLocal.indexOf(itemCheck);
          DataLocal.listOrderProductLocal[index].count = event.product.count;
        }else{
          Product production =  Product(
              code: event.product.code,
              name: event.product.name,
              name2: event.product.name2,
              dvt: event.product.dvt,
              description: event.product.descript,
              price: event.product.price,
              discountPercent: event.product.discountPercent,
              imageUrl: event.product.imageUrl,
              priceAfter: event.product.priceAfter,
              stockAmount: event.product.stockAmount,
              count: event.product.count,
          );
          DataLocal.listOrderProductLocal.add(production);
        }
      }else{
        Product production =  Product(
            code: event.product.code,
            name: event.product.name,
            name2: event.product.name2,
            dvt: event.product.dvt,
            description: event.product.descript,
            price: event.product.price,
            discountPercent: event.product.discountPercent,
            imageUrl: event.product.imageUrl,
            priceAfter: event.product.priceAfter,
            stockAmount: event.product.stockAmount,
            count: event.product.count
        );
        DataLocal.listOrderProductLocal.add(production);
      }
    }
    else{
      Product production =  Product(
          code: event.product.code,
          name: event.product.name,
          name2: event.product.name2,
          dvt: event.product.dvt,
          description: event.product.descript,
          price: event.product.price,
          discountPercent: event.product.discountPercent,
          imageUrl: event.product.imageUrl,
          priceAfter: event.product.priceAfter,
          stockAmount: event.product.stockAmount,
          count: event.product.count,
      );
      DataLocal.listOrderProductLocal.add(production);
    }
    emitter(AddProductCountFromCheckInSuccess());
  }

  void _updateProductCountInventory(UpdateProductCountInventory event, Emitter<CartState> emitter){
    emitter(CartLoading());
    if(DataLocal.listInventoryLocal.isNotEmpty){
      bool itemIsExits = DataLocal.listInventoryLocal.any((item) => item.codeProduct == event.product.code);
      if(itemIsExits == true){
        var itemCheck = DataLocal.listInventoryLocal.firstWhere((item) => item.codeProduct == event.product.code);
        if(itemCheck != null){
          int index  = DataLocal.listInventoryLocal.indexOf(itemCheck);
          DataLocal.listInventoryLocal[index].inventoryNumber = event.product.count;
        }
        else{
          ProductStore product = ProductStore(
              codeProduct: event.product.code,
              nameProduct: event.product.name,
              dvt: event.product.dvt,
              inventoryNumber: event.product.count,
              kColorFormatAlphaB: event.product.kColorFormatAlphaB
          );
          DataLocal.listInventoryLocal.add(product);
        }
      }else{
        ProductStore product = ProductStore(
            codeProduct: event.product.code,
            nameProduct: event.product.name,
            dvt: event.product.dvt,
            inventoryNumber: event.product.count,
            kColorFormatAlphaB: event.product.kColorFormatAlphaB
        );
        DataLocal.listInventoryLocal.add(product);
      }
    }else{
      ProductStore product = ProductStore(
          codeProduct: event.product.code,
          nameProduct: event.product.name,
          dvt: event.product.dvt,
          inventoryNumber: event.product.count,
          kColorFormatAlphaB: event.product.kColorFormatAlphaB
      );
      DataLocal.listInventoryLocal.add(product);
    }
    emitter(UpdateProductCountInventorySuccess());
  }

  void _updateProductCountOrderFromCheckIn(UpdateProductCountOrderFromCheckIn event, Emitter<CartState> emitter){
    emitter(CartLoading());
    if(DataLocal.listOrderProductLocal.isNotEmpty){
      var itemCheck = DataLocal.listOrderProductLocal.firstWhere((item) => item.code == event.product.code);
      if(itemCheck != null){
        int index  = DataLocal.listOrderProductLocal.indexOf(itemCheck);
        DataLocal.listOrderProductLocal[index].count = event.product.count;
      }else{
        DataLocal.listOrderProductLocal.add(event.product);
      }
    }else{
      DataLocal.listOrderProductLocal.add(event.product);
    }
    emitter(UpdateProductCountOrderFromCheckInSuccess());
  }

  void _createOderEvent(CreateOderEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    List<DetailOrderV3> listDetailOrderV3 = [];
    String codeStock = '';
    bool orderNotMin = false;
    for (var element in listOrder) {
      if(Const.typeProduction == true && orderNotMin == false){
        if(element.giaSuaDoi > element.priceMin){
          orderNotMin = true;
        }
      }

      List<ListObjectJson> listEntityClass = [];
      final String jsonOtherInfoText = (element.jsonOtherInfo ?? '').toString();
      if(jsonOtherInfoText.trim().replaceAll('null', '').isNotEmpty){
        final valueMap = json.decode(jsonOtherInfoText) as List;
        listEntityClass = (valueMap.map((itemValues) => ListObjectJson.fromJson(itemValues))).toList();
      }
      // Note: SL_KD is now sent via DetailOrderV3.slKd, not listAdvanceOrderInfo


      if(element.isMark == 1 && element.typeCK != 'HH'){
        codeStock = element.stockCode.toString();
        
        // ✅ QUAN TRỌNG: Với CKG, chỉ truyền tiền chiết khấu HOẶC tỷ lệ phần trăm, không truyền cả 2
        // Backend không chấp nhận null, phải truyền 0 thay vì null
        // Check xem có tiền chiết khấu hay tỷ lệ phần trăm
        double finalDiscountPercent = 0;
        double finalCk = 0;
        double finalCknt = 0;
        
        // Lấy giá trị discountPercent và ck/cknt
        double discountPercentValue = element.discountPercent ?? 0;
        
        double ckValue = element.discountByHand == true ? (element.ckntByHand ?? 0) : (element.ck ?? 0);
        double ckntValue = element.discountByHand == true ? (element.ckntByHand ?? 0) : (element.cknt ?? 0);
        
        // ✅ Logic payload cũ: truyền tiền chiết khấu HOẶC tỷ lệ phần trăm
        if (ckValue > 0 || ckntValue > 0) {
          finalCk = ckValue > 0 ? ckValue : 0;
          finalCknt = ckntValue > 0 ? ckntValue : 0;
          //finalDiscountPercent = 0;
          finalDiscountPercent = discountPercentValue;
          print('💰 [CKG CREATE] Sending money discount: ck=$finalCk, cknt=$finalCknt, discountPercent=$finalDiscountPercent');
        } 
        // ✅ Nếu có tỷ lệ phần trăm (discountPercent > 0) → chỉ truyền tỷ lệ phần trăm, set ck/cknt = 0
        // else if (discountPercentValue > 0) {
        //   finalDiscountPercent = discountPercentValue;
        //   finalCk = 0;
        //   finalCknt = 0;
        //   print('💰 [CKG CREATE] Sending percentage discount: discountPercent=$finalDiscountPercent, ck=0, cknt=0');
        // }
        // ✅ Nếu không có cả 2 → set tất cả = 0
        else {
          finalDiscountPercent = 0;
          finalCk = 0;
          finalCknt = 0;
        }
        
        // ✅ FREE DISCOUNT: Thêm điều kiện truyền tỷ lệ chiết khấu từ discountPercentByHand
        if (Const.freeDiscount == true) {
          if (element.discountPercentByHand > 0) {
            finalDiscountPercent = element.discountPercentByHand;
            print('💰 [FREE DISCOUNT CREATE] Added discountPercent=$finalDiscountPercent from discountPercentByHand (keeping ck=$finalCk, cknt=$finalCknt)');
          } else {
            finalDiscountPercent = 0;
            print('💰 [FREE DISCOUNT CREATE] No discountPercentByHand, set discountPercent=0');
          }
        }
        
        // ✅ QUAN TRỌNG: Tính priceOk (giá trước chiết khấu)
        // priceOk phải là giá TRƯỚC KHI áp dụng chiết khấu
        // - Nếu Const.editPrice == true → ưu tiên giaSuaDoi (giá đã sửa, trước chiết khấu)
        // - Nếu Const.editPrice == false → dùng price (giá gốc)
        double priceOkValue = 0;
        
        bool hasDiscount = (element.discountPercent != null && element.discountPercent! > 0) ||
                          (element.maCk != null && element.maCk.toString().trim().isNotEmpty);
        
        if (hasDiscount) {
          // Có chiết khấu → priceOk = giá trước chiết khấu (ưu tiên giaSuaDoi nếu có sửa giá)
          if (Const.editPrice == true) {
            // Ưu tiên giá sửa đổi (giá trước chiết khấu)
            priceOkValue = element.giaSuaDoi ?? element.price ?? 0;
          } else {
            // Dùng giá gốc
            priceOkValue = element.price ?? element.giaSuaDoi ?? 0;
          }
        } else {
          // Không có chiết khấu → dùng logic cũ (giữ ưu tiên giá sửa đổi)
          priceOkValue = Const.editPrice == true 
            ? (element.giaSuaDoi ?? 0) 
            : (element.priceOk.toString().replaceAll('null','').isNotEmpty ? element.priceOk ?? 0 : 0);
        }
        
        DetailOrderV3 item = DetailOrderV3(
            nameProduction: element.name,
            code: element.code,
            sttRec0: element.sttRec0,
            count: element.count,
            price:  element.giaSuaDoi,
            priceAfter: element.priceAfter,
            discountPercent: finalDiscountPercent,
            dvt: element.dvt,
            ck: finalCk,
            cknt: finalCknt,
            maCk: element.maCk,
            kmYN: 0,
            stockCode: element.stockCode,

            taxValues: ((element.price ?? 0) * (element.valuesTax ?? element.thueSuat ?? 0)) / 100,
            codeTax: (DataLocal.taxCode != null && DataLocal.taxCode.toString().isNotEmpty) ? DataLocal.taxCode.toString() : (element.maThue?.toString() ?? element.tenThue?.toString() ?? ''),
            priceOk: priceOkValue, // ✅ Giá gốc chưa chiết khấu
            taxPercent: element.taxPercent ?? 0,
            idVv: Const.isVv == true ? element.idVv : idVv,
            idHd: Const.isHd == true ? element.idHd : idHd,
            isCheBien: element.isCheBien == true ? 1 : 0,
            isSanXuat: element.isSanXuat == true ? 1 : 0,
            giaGui: element.giaGui * Const.tyGiaQuyDoi,
            giaSuaDoi: element.giaSuaDoi  * Const.tyGiaQuyDoi,
            tienGui: element.giaGui * element.count! * Const.tyGiaQuyDoi,
            tienGuiNT: element.giaGui * element.count!,
            giaGuiNT: element.giaGui,
            note: element.note,
            heSo: element.heSo.toString().replaceAll('null', '').isNotEmpty ? element.heSo.toString() : '1',
            idNVKD: element.idNVKD,
            ncsx: element.nuocsx,quycach: element.quycach,
            listAdvanceOrderInfo: listEntityClass,
            slKd: (event.sttRectHD ?? '').toString().trim().isNotEmpty ? (element.so_luong_kd as num?)?.toDouble() : null,
        );
        listDetailOrderV3.add(item);
      }
      else if(element.typeCK == 'HH'){
        DetailOrderV3 item = DetailOrderV3(
            nameProduction: element.name,
            code: element.code,
            sttRec0: element.sttRec0,
            count: element.count,
            price: Const.editPrice == true ? element.giaSuaDoi : element.price,
            priceAfter: element.priceAfter,
            discountPercent: element.discountPercent,
            dvt: element.dvt,
            ck: (element.ck),
            cknt: (element.cknt ?? 0),
            maCk: element.maCk,
            kmYN: 1,
            taxValues: 0,
            taxPercent: 0,
            codeTax: '',
            priceOk: 0,
            stockCode: codeStock,
            idVv: Const.isVv == true ? element.idVv : idVv,
            idHd: Const.isHd == true ? element.idHd : idHd,
            isCheBien: element.isCheBien == true ? 1 : 0,
            isSanXuat: element.isSanXuat == true ? 1 : 0,
            giaGui: element.giaGui * Const.tyGiaQuyDoi,
            giaSuaDoi: element.giaSuaDoi  * Const.tyGiaQuyDoi,
            tienGui: element.giaGui * element.count! * Const.tyGiaQuyDoi,
            tienGuiNT: element.giaGui * element.count!,
            giaGuiNT: element.giaGui,
            note: element.note,
            heSo: element.heSo.toString().replaceAll('null', '').isNotEmpty ?
            (element.heSo.toString().replaceAll('null', '').toUpperCase().contains('TRUE') || element.heSo.toString().replaceAll('null', '').toUpperCase().contains('FALSE'))
                ?
            (element.heSo.toString().replaceAll('null', '').toUpperCase().contains('TRUE') ? "1" : "0")
                :
            element.heSo.toString() : "1",
            listAdvanceOrderInfo: listEntityClass,
            slKd: (event.sttRectHD ?? '').toString().trim().isNotEmpty ? (element.so_luong_kd as num?)?.toDouble() : null,
            idNVKD: element.idNVKD,
            ncsx: element.nuocsx,quycach: element.quycach,

        );
        listDetailOrderV3.add(item);
        codeStock = '';
      }
    }

    for (var element in DataLocal.listProductGift) {
      final rawHeSo = element.heSo.toString().replaceAll('null', '');
      int heSoValue = 1;
      if (rawHeSo.isNotEmpty) {
        final normalized = rawHeSo.toUpperCase();
        if (normalized.contains('TRUE') || normalized.contains('FALSE')) {
          heSoValue = normalized.contains('TRUE') ? 1 : 0;
        } else {
          heSoValue = int.tryParse(rawHeSo) ?? 1;
        }
      }

      DetailOrderV3 item = DetailOrderV3(
          nameProduction: element.name,
          code: element.code,
          sttRec0: element.sttRec0,
          count: element.count,
          price: Const.editPrice == true ? element.giaSuaDoi : element.price,
          priceAfter: element.priceAfter,
          discountPercent: element.discountPercent,
          dvt: element.dvt,
          ck: (element.ck),
          cknt: (element.cknt ?? 0),
          maCk: element.maCk,
          kmYN: 1,
          taxValues: 0,
          taxPercent: 0,
          codeTax: '',
          priceOk: 0,
          stockCode: element.stockCode,
          idVv: Const.isVv == true ? element.idVv : idVv,
          idHd: Const.isHd == true ? element.idHd : idHd,
          isCheBien: element.isCheBien == true ? 1 : 0,
          isSanXuat: element.isSanXuat == true ? 1 : 0,
          giaGui: element.giaGui * Const.tyGiaQuyDoi,
          giaSuaDoi: element.giaSuaDoi * Const.tyGiaQuyDoi,
          tienGui: element.giaGui * element.count! * Const.tyGiaQuyDoi,
          tienGuiNT: element.giaGui * element.count!,
          giaGuiNT: element.giaGui,
          note: element.note,
          heSo: heSoValue,
          idNVKD: element.idNVKD,
          ncsx: element.nuocsx,quycach: element.quycach,
      );
      listDetailOrderV3.add(item);
    }

    List<DsCkTongDon> listCKTongDons = [];

    if(listCkTongDon.isNotEmpty){
      final kieuCkRaw = listCkTongDon[0].kieuCK?.toString() ?? '';
      final kieuCkValue = kieuCkRaw.isEmpty ? 0 : int.tryParse(kieuCkRaw) ?? 0;
      DsCkTongDon itemDSCK = DsCkTongDon(
          maCk:listCkTongDon[0].maCk,
          tCkTt: listCkTongDon[0].tlCkTt,
          kieuCk: kieuCkValue
      );
      listCKTongDons.add(itemDSCK);
    }
    TotalCreateOrderV3 totalCreateOrderV3 = TotalCreateOrderV3(
      preAmount: totalMoney,
      discount: totalDiscount,
      amount: totalPayment,
      tax: totalTax,
      fee: 0,
      totalDiscountForItem: (totalDiscount - totalDiscountForOder), 
      totalDiscountForOrder: totalDiscountForOder
    );
    // ✅ Helper function để tính ck_dac_biet từ các chiết khấu đã chọn
    int? calculateCkDacBiet() {
      // Check CKG đã chọn - ✅ CHANGED: selectedCkgIds giờ chứa maCk thay vì ckgId
      for (var ckgItem in listCkg) {
        String maCk = (ckgItem.maCk ?? '').trim();
        
        // ✅ Check theo maCk (thay vì ckgId)
        if (maCk.isNotEmpty && selectedCkgIds.contains(maCk)) {
          final ckDacBietValue = ckgItem.ck_dac_biet;
          if (ckDacBietValue != null) {
            int? ckDacBietInt;
            if (ckDacBietValue is int) {
              ckDacBietInt = ckDacBietValue;
            } else if (ckDacBietValue is String && ckDacBietValue.trim().isNotEmpty) {
              ckDacBietInt = int.tryParse(ckDacBietValue);
            } else if (ckDacBietValue is num) {
              ckDacBietInt = ckDacBietValue.toInt();
            }
            
            if (ckDacBietInt == 1) {
              print('💰 ✅ Found CKG with ck_dac_biet = 1: maCk=$maCk, sttRecCk=${ckgItem.sttRecCk}');
              return 1; // Đã tìm thấy, không cần check tiếp
            }
          }
        }
      }
      
      // ✅ Check HH đã chọn hoặc tự động áp dụng
      for (var hhItem in listHH) {
        String sttRecCk = (hhItem.sttRecCk ?? '').trim();
        
        // HH được tự động áp dụng hoặc user đã chọn
        // Check nếu HH có trong selectedHHIds hoặc được tự động áp dụng (có trong listPromotion string)
        bool isHHSelected = selectedHHIds.contains(sttRecCk);
        bool isHHAutoApplied = listPromotion.isNotEmpty && 
                               (listPromotion == sttRecCk || 
                                listPromotion.startsWith('$sttRecCk,') || 
                                listPromotion.contains(',$sttRecCk,') || 
                                listPromotion.endsWith(',$sttRecCk'));
        
        if (isHHSelected || isHHAutoApplied) {
          final ckDacBietValue = hhItem.ck_dac_biet;
          if (ckDacBietValue != null) {
            int? ckDacBietInt;
            if (ckDacBietValue is int) {
              ckDacBietInt = ckDacBietValue;
            } else if (ckDacBietValue is String && ckDacBietValue.trim().isNotEmpty) {
              ckDacBietInt = int.tryParse(ckDacBietValue);
            } else if (ckDacBietValue is num) {
              ckDacBietInt = ckDacBietValue.toInt();
            }
            
            if (ckDacBietInt == 1) {
              print('💰 ✅ Found HH with ck_dac_biet = 1: sttRecCk=$sttRecCk, maCk=${hhItem.maCk}');
              return 1; // Đã tìm thấy, không cần check tiếp
            }
          }
        }
      }
      
      // Check CKTDTT đã chọn
      for (var cktdttItem in listCktdtt) {
        String sttRecCk = (cktdttItem.sttRecCk ?? '').trim();
        String cktdttId = sttRecCk;
        
        if (selectedCktdttIds.contains(cktdttId)) {
          final ckDacBietValue = cktdttItem.ck_dac_biet;
          if (ckDacBietValue != null) {
            int? ckDacBietInt;
            if (ckDacBietValue is int) {
              ckDacBietInt = ckDacBietValue;
            } else if (ckDacBietValue is String && ckDacBietValue.trim().isNotEmpty) {
              ckDacBietInt = int.tryParse(ckDacBietValue);
            } else if (ckDacBietValue is num) {
              ckDacBietInt = ckDacBietValue.toInt();
            }
            
            if (ckDacBietInt == 1) {
              print('💰 ✅ Found CKTDTT with ck_dac_biet = 1: cktdttId=$cktdttId, sttRecCk=$sttRecCk');
              return 1; // Đã tìm thấy, không cần check tiếp
            }
          }
        }
      }
      
      return 0; // Không tìm thấy chiết khấu nào có ck_dac_biet = 1
    }
    
    // ✅ Check tất cả các chiết khấu đã chọn (CKG, HH, CKTDTT) - nếu có bất kỳ chiết khấu nào có ck_dac_biet = 1 thì set ck_dac_biet = 1
    int? finalCkDacBiet = calculateCkDacBiet();
    
    // ✅ Set ck_dac_biet vào bloc để UI có thể sử dụng
    ck_dac_biet = finalCkDacBiet;
    
    // ✅ API không chấp nhận null, nên nếu finalCkDacBiet là null thì set = 0
    final int finalCkDacBietValue = finalCkDacBiet ?? 0;
    
    if (finalCkDacBiet == 1) {
      print('💰 ✅ Final ck_dac_biet = 1 (at least one selected discount has ck_dac_biet = 1)');
      print('💰 ✅ Set bloc.ck_dac_biet = 1');
    } else {
      print('💰 ℹ️ Final ck_dac_biet = 0 (no selected discount has ck_dac_biet = 1)');
      print('💰 ℹ️ Set bloc.ck_dac_biet = 0');
    }
    
    CreateOrderV3Request request = CreateOrderV3Request(
        requestData: CreateOrderV3RequestData(
            customerCode: event.code,
            saleCode: idUser,
            orderDate: DateTime.now().toString(),
            currency: event.currencyCode,
            stockCode: event.storeCode,
            description: DataLocal.noteSell,
            phoneCustomer: phoneCustomer,
            addressCustomer: addressCustomer,
            dsCk: listCKTongDons,
            detail: listDetailOrderV3,
            total: totalCreateOrderV3,
            comment: DataLocal.noteSell,
            idTransaction: (DataLocal.transactionCode != null && DataLocal.transactionCode != 'null') ? DataLocal.transactionCode : '',
            idVv: idVv,
            idHd: idHd,
            discountPercentAgency: totalDiscountWhenChooseAgency,
            discountPercentTypePayment: totalDiscountWhenChooseTypePayment,
            codeAgency: codeAgency,
            datePayment: DataLocal.datePayment.toString(),
            codeTypePayment: codeTypePayment.contains('Thanh toán ngay') ? 'N' : codeTypePayment.contains('Công nợ') ? 'S' : '',
            orderStatus:
            Const.typeProduction == true
                ?
            (orderNotMin == true ?  event.valuesStatus : 1)
                :
            event.valuesStatus,
            dateEstDelivery: event.dateEstDelivery,
            nameCompany: event.nameCompany,
            mstCompany: event.mstCompany,
            addressCompany: event.addressCompany,
            noteCompany: event.noteCompany,
            typeDelivery: typeDeliveryCode,
            idTypeOrder: typeOrderCode,
            idDVTC:idDVTC, idNguoiNhan: nguoiNhan.text,
            ghiChuKM: ghiChu.text,     idMDC:idMDC,     thoiGianGiao:thoiGianGiao.text,        tien:tien.text,        baoGia:baoGia.text,
            sttRecHD: event.sttRectHD,
            ck_dac_biet: finalCkDacBietValue
        )
    );
    CartState state = _handlerCreateOrder(await _networkFactory!.createOrder(request, _accessToken!));
    emitter(state);
  }

  void _updateOderEvent(UpdateOderEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    List<DetailOrderV3> listDetailOrderV3 = [];
    bool orderNotMin = false;

    for (var element in listOrder) {
      if(Const.typeProduction == true && orderNotMin == false){
        if(element.price! > element.priceMin){
          orderNotMin = true;
        }
      }

      // ✅ QUAN TRỌNG: Tính priceOk (giá trước chiết khấu)
      // priceOk phải là giá TRƯỚC KHI áp dụng chiết khấu
      // - Nếu Const.editPrice == true → ưu tiên giaSuaDoi (giá đã sửa, trước chiết khấu)
      // - Nếu Const.editPrice == false → dùng price (giá gốc)
      double? priceOkForAPI = 0;
      
      // Nếu có chiết khấu (bất kể add hay edit mode), priceOk = giá trước chiết khấu
      bool hasDiscount = (element.discountPercent != null && element.discountPercent! > 0) ||
                        (element.maCk != null && element.maCk.toString().trim().isNotEmpty) ||
                        (element.discountPercentByHand != null && element.discountPercentByHand! > 0);
      
      if (hasDiscount) {
        // Có chiết khấu → priceOk = giá trước chiết khấu (ưu tiên giaSuaDoi nếu có sửa giá)
        if (Const.editPrice == true) {
          // Ưu tiên giá sửa đổi (giá trước chiết khấu)
          priceOkForAPI = element.giaSuaDoi ?? element.price ?? 0;
        } else {
          // Dùng giá gốc
          priceOkForAPI = element.price ?? element.giaSuaDoi ?? 0;
        }
        print('💰 Has discount: priceOk = ${priceOkForAPI} (giá trước chiết khấu, editPrice=${Const.editPrice})');
      } else {
        // Không có chiết khấu → giữ logic cũ (ưu tiên giá sửa đổi)
        priceOkForAPI = Const.editPrice == true 
          ? element.giaSuaDoi 
          : (element.priceOk.toString().replaceAll('null','').isNotEmpty ? element.priceOk : 0);
      }

      // ✅ QUAN TRỌNG: Backend vẫn đang xử lý theo nguyên tắc "tiền" HOẶC "tỷ lệ".
      // Để giữ đúng tl_ck khi xem chi tiết đơn:
      //  - Nếu có tỷ lệ (tl_ck / discountPercent / discountPercentByHand) → CHỈ gửi DiscountPercent, set ck/cknt = 0.
      //  - Nếu KHÔNG có tỷ lệ → CHỈ gửi ck/cknt (tiền), set DiscountPercent = 0.
      //
      // Như vậy đơn tạo từ CTKM theo % sẽ luôn giữ lại tl_ck sau khi update.
      double finalDiscountPercent = 0;
      double finalCk = 0;
      double finalCknt = 0;

      // 1) Xác định xem line này đang có tỷ lệ chiết khấu hay không
      final double rawPercent = (element.discountPercent ?? 0);
      final double manualPercent =
          Const.freeDiscount == true ? (element.discountPercentByHand ?? 0) : 0;
      final bool hasPercent = (manualPercent > 0) || (rawPercent > 0);

      if (hasPercent) {
        // Ưu tiên: nếu có freeDiscount và user nhập tay theo %, dùng discountPercentByHand
        if (manualPercent > 0) {
          finalDiscountPercent = manualPercent;
        } else {
          // Ngược lại dùng discountPercent (đã map từ tl_ck / CTKM / đơn chi tiết)
          finalDiscountPercent = rawPercent;
        }

        // ✅ FIX: Tính và truyền tiền chiết khấu ngay cả khi có tỷ lệ phần trăm
        // Backend có thể cần cả hai giá trị để xử lý đúng
        if (element.discountByHand == true && (element.ckntByHand ?? 0) > 0) {
          // Ưu tiên dùng ckntByHand nếu đã được tính
          finalCk = 0;
          finalCknt = element.ckntByHand ?? 0;
        } else if ((element.ck ?? 0) > 0 || (element.cknt ?? 0) > 0) {
          // Dùng giá trị từ CTKM / đơn gốc
          finalCk = element.ck ?? 0;
          finalCknt = element.cknt ?? 0;
        } else {
          // Tính từ phần trăm nếu chưa có giá trị tiền chiết khấu
          double priceForDiscount = priceOkForAPI ?? element.price ?? element.giaSuaDoi ?? 0;
          double countValue = element.count ?? 0;
          finalCk = 0;
          finalCknt = (priceForDiscount * countValue * finalDiscountPercent) / 100;
        }
        print(
            '💰 [DISCOUNT UPDATE] Send PERCENT + MONEY: discountPercent=$finalDiscountPercent, ck=$finalCk, cknt=$finalCknt');
      } else {
        // Không có tỷ lệ → sử dụng tiền chiết khấu
        if (element.discountByHand == true) {
          // Chiết khấu nhập tay theo tiền (ckntByHand)
          finalCk = 0;
          finalCknt = (element.ckntByHand ?? 0);
        } else {
          // Tiền chiết khấu từ CTKM / đơn gốc
          finalCk = (element.ck ?? 0);
          finalCknt = (element.cknt ?? 0);
        }

        finalDiscountPercent = 0;
        print(
            '💰 [DISCOUNT UPDATE] Send MONEY ONLY: ck=$finalCk, cknt=$finalCknt, discountPercent=0');
      }

      DetailOrderV3 item = DetailOrderV3(
          code: element.code,
          sttRec0: element.sttRec0,
          count: element.count,
          price: element.giaSuaDoi,
          priceAfter: element.priceAfter,
          discountPercent: finalDiscountPercent,
          dvt: element.dvt,
          ck: finalCk,
          cknt: finalCknt,
          maCk: element.maCk,
          kmYN: 0,
          stockCode: element.stockCode,
          taxValues: ((element.price ?? 0) * (element.valuesTax ?? element.thueSuat ?? 0)) / 100,
        codeTax: (DataLocal.taxCode != null && DataLocal.taxCode.toString().isNotEmpty) ? DataLocal.taxCode.toString() : (element.maThue?.toString() ?? element.tenThue?.toString() ?? ''),
          priceOk: priceOkForAPI,
          taxPercent: element.taxPercent ?? 0,
          idVv: Const.isVv == true ? element.idVv : idVv,
          idHd: Const.isHd == true ? element.idHd : idHd,
          isCheBien: element.isCheBien == true ? 1 : 0,
          isSanXuat: element.isSanXuat == true ? 1 : 0,
          giaGui: element.giaGui * Const.tyGiaQuyDoi,
          giaSuaDoi: element.giaSuaDoi * Const.tyGiaQuyDoi,
          tienGui: element.giaGui * element.count! * Const.tyGiaQuyDoi,
          tienGuiNT: element.giaGui * element.count!,
          giaGuiNT: element.giaGui,
          idNVKD: element.idNVKD,
          ncsx: element.nuocsx,quycach: element.quycach,
      );
      listDetailOrderV3.add(item);
    }

    for (var element in DataLocal.listProductGift) {
      DetailOrderV3 item = DetailOrderV3(
          code: element.code,
          sttRec0: element.sttRec0,
          count: element.count,
          price: element.price,
          priceAfter: element.priceAfter,
          discountPercent: element.discountPercent,
          dvt: element.dvt,
          ck: (element.ck),
          cknt: (element.cknt ?? 0),
          maCk: element.maCk,
          kmYN: 1,
          taxValues: 0,
          taxPercent: 0,
          codeTax: '',
          priceOk: 0,
          stockCode: element.stockCode,
          idVv: Const.isVv == true ? element.idVv : idVv,
          idHd: Const.isHd == true ? element.idHd : idHd,
          isCheBien: element.isCheBien == true ? 1 : 0,
          isSanXuat: element.isSanXuat == true ? 1 : 0,
          giaGui: element.giaGui * Const.tyGiaQuyDoi,
          giaSuaDoi: element.giaSuaDoi * Const.tyGiaQuyDoi,
          tienGui: element.giaGui * element.count! * Const.tyGiaQuyDoi,
          tienGuiNT: element.giaGui * element.count!,
          giaGuiNT: element.giaGui
      );
      listDetailOrderV3.add(item);
    }

    List<DsCkTongDon> listCKTongDons = [];

    if(listCkTongDon.isNotEmpty){
      final kieuCkRaw = listCkTongDon[0].kieuCK?.toString() ?? '';
      final kieuCkValue = kieuCkRaw.isEmpty ? 0 : int.tryParse(kieuCkRaw) ?? 0;
      DsCkTongDon itemDSCK = DsCkTongDon(
          maCk:listCkTongDon[0].maCk,
          tCkTt: listCkTongDon[0].tlCkTt,
          kieuCk: kieuCkValue
      );
      listCKTongDons.add(itemDSCK);
    }
    TotalCreateOrderV3 totalCreateOrderV3 = TotalCreateOrderV3(
        preAmount: totalMoney,
        discount: totalDiscount,
        amount: totalPayment,
        tax: totalTax,
        fee: 0,
        totalDiscountForItem: (totalDiscount - totalDiscountForOder),
        totalDiscountForOrder: totalDiscountForOder
    );

    UpdateOrderRequest request = UpdateOrderRequest(
        requestData: UpdateOrderRequestBody(
            sttRec: event.sttRec,
            customerCode: event.code,
            saleCode: idUser,
            orderDate: DateTime.now().toString(),
            currency: event.currencyCode,
            stockCode: event.storeCode,
            description: DataLocal.noteSell,
            phoneCustomer: phoneCustomer,
            addressCustomer: addressCustomer,
            dsCk: listCKTongDons,
            detail: listDetailOrderV3,
            total: totalCreateOrderV3,
            comment: DataLocal.noteSell,
            idTransaction: (DataLocal.transactionCode != null && DataLocal.transactionCode != 'null') ? DataLocal.transactionCode : '',
            idVv: idVv,
            idHd: idHd,
            discountPercentAgency: totalDiscountWhenChooseAgency,
            discountPercentTypePayment: totalDiscountWhenChooseTypePayment,
            codeAgency: codeAgency,
            datePayment: DataLocal.datePayment.toString(),
            codeTypePayment: codeTypePayment.contains('Thanh toán ngay') ? 'N' : codeTypePayment.contains('Công nợ') ? 'S' : '',
            orderStatus:
            Const.typeProduction == true
                ?
            (orderNotMin == true ?  event.valuesStatus : 1)
                :
            event.valuesStatus,
            dateEstDelivery: event.dateEstDelivery,
            nameCompany: event.nameCompany,
            mstCompany: event.mstCompany,
            addressCompany: event.addressCompany,
            noteCompany: event.noteCompany,
            typeDelivery: typeDeliveryCode,
            idTypeOrder: typeOrderCode,
           idDVTC:idDVTC,   idNguoiNhan: nguoiNhan.text,
            ghiChuKM: ghiChu.text,     idMDC:idMDC,     thoiGianGiao:thoiGianGiao.text,        tien:tien.text,        baoGia:baoGia.text,
        )
    );
    CartState state = _handlerCreateOrder(await _networkFactory!.updateOrder(request, _accessToken!));
    emitter(state);
    emitter(CartInitial());
  }

  void _addNote(AddNote event, Emitter<CartState> emitter){
    emitter(CartInitial());
    DataLocal.noteSell = event.note.toString();
    emitter(AddNoteSuccess());
  }

  void _deleteAllProductFromDB(DeleteAllProductFromDB event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    await db.deleteAllProduct();
    emitter(DeleteAllProductFromDBSuccess());
  }

  void _pickInfoCustomer(PickInfoCustomer event, Emitter<CartState> emitter){
    print('💾 _pickInfoCustomer called:');
    print('💾   - event.codeCustomer = ${event.codeCustomer}');
    print('💾   - event.customerName = ${event.customerName}');
    print('💾   - Before: bloc.codeCustomer = $codeCustomer');
    emitter(CartInitial());
    customerName = event.customerName;
    phoneCustomer = event.phone;
    addressCustomer = event.address;
    codeCustomer = event.codeCustomer;
    print('💾   - After: bloc.codeCustomer = $codeCustomer');
    emitter(PickInfoCustomerSuccess());
  }

  void _calculatorTaxForItemEvent(CalculatorTaxForItemEvent event, Emitter<CartState> emitter){
    emitter(CartInitial());
    calculatorTaxForItem(); 
    emitter(CalculatorTaxForItemSuccess());
  }

  void _checkInTransferEvent(CheckInTransferEvent event, Emitter<CartState> emitter)async{
    emitter(CartInitial());
    switch (event.index){
      case 4:
        if(attachInvoice == true){
          attachInvoice = false;
        }else{
          attachInvoice = true;
        }
        break;
      case 5:
        if(exportInvoice == true){
          exportInvoice = false;
        }else{
          exportInvoice = true;
        }
        break;
      case 6:
        if(tax == true){
          tax = false;
        }else{
          tax = true;
        }
        break;
    }
    emitter(CheckInTransferSuccess());
  }

  void _getListProductFromDB(GetListProductFromDB event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    if(event.addOrderFromCheckIn == false){
      listProductOrderAndUpdate  = await db.fetchAllProduct();
      print('💰 Fetched ${listProductOrderAndUpdate.length} products from DB:');
      for(var p in listProductOrderAndUpdate){
        print('💰   - ${p.code}: dsCKLineItem="${p.dsCKLineItem}"');
      }
      if(listProductOrderAndUpdate.isEmpty){
        totalProductView = 0;
      }
    }else{
      listProductOrderAndUpdate  = listProductOrder;
    }
    if(event.reloadAndCalculatorListProduct == true){
      emitter(CartInitial());
    }else{
      emitter(GetListProductFromDBSuccess(true,event.getValuesTax,event.key));
    }
  }

  void _updateProductCount(UpdateProductCount event, Emitter<CartState> emitter)async{
    emitter(CartInitial());
    await db.updateProduct(event.product,event.stockCodeOld.toString(),true);
    add(GetListProductFromDB(addOrderFromCheckIn: event.addOrderFromCheckIn, getValuesTax: false,key: 'Second'));
    // listProductOrderAndUpdate  = await db.fetchAllProduct();
    // emitter(GetListProductFromDBSuccess());
  }

  void _decrement(Decrement event, Emitter<CartState> emitter)async{
    emitter(CartInitial());
    if (listProductOrderAndUpdate.elementAt(event.index).count! >= 2) {
      await db.decreaseProduct(listProductOrderAndUpdate.elementAt(event.index));
    }
    listProductOrderAndUpdate  = await db.fetchAllProduct();
    emitter(GetListProductFromDBSuccess(false,false,''));
  }

  void _increment(Increment event, Emitter<CartState> emitter)async{
    emitter(CartInitial());
    await db.increaseProduct(listProductOrderAndUpdate.elementAt(event.index));
    listProductOrderAndUpdate  = await db.fetchAllProduct();
    emitter(GetListProductFromDBSuccess(false,false,''));
  }

  void _deleteProductFromDB(DeleteProductFromDB event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    if(event.viewUpdateOrder == false){
      deleteProduct(event.codeProduct.toString(),event.codeStock.toString().trim());
      
      // ✅ FIX: Clear listOrder ngay khi xóa sản phẩm để UI rebuild đúng
      // Đặc biệt quan trọng khi chỉ còn 1 sản phẩm
      if(listProductOrderAndUpdate.isEmpty){
        listOrder.clear();
        listItemOrder.clear();
        totalMoney = 0;
        totalDiscount = 0;
        totalPayment = 0;
        print('💰 Cleared listOrder after deleting last product');
      }
      
      add(GetListProductFromDB(addOrderFromCheckIn: false, getValuesTax: false, key: 'Second'));
      emitter(CartInitial());
    }
    else {
      listProductOrderAndUpdate.removeAt(event.index);
      emitter(GetListItemUpdateOrderSuccess());
    }
  }

  void deleteProduct(String codeProduct, String codeStock){
    listProductOrderAndUpdate.removeWhere((element) => element.code.toString().trim() == codeProduct.toString().trim());
    db.removeProduct(codeProduct.toString(),codeStock);
    if(DataLocal.listOrderCalculatorDiscount.any((values) => values.code.toString().trim() == codeProduct.toString().trim())){
      DataLocal.listOrderCalculatorDiscount.removeWhere((element) => element.code.toString().trim() == codeProduct.toString().trim());
    }
    Const.numberProductInCart = listProductOrderAndUpdate.length;
  }

  bool chooseTax = false;
  double totalDiscountForItem = 0;
  double totalDiscountForOder = 0;

  void _calculatorDiscountEvent(CalculatorDiscountEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    totalMoney = 0; // ✅ FIX: Reset totalMoney về 0 để tính lại từ đầu
    totalDiscount = 0;
    totalDiscountOldByHand = 0;
    totalMoneyOld = 0;
    totalTax = 0;
    
    // ✅ QUAN TRỌNG: Khi reLoad: true (vào lại giỏ hàng), reset manualTotalDiscountValue về 0
    // để đảm bảo tính lại từ đầu, không bị ảnh hưởng bởi giá trị cũ
    // Và nếu có manualTotalDiscountPercent > 0, cần reset totalDiscountForOder về 0
    // để đảm bảo tính lại đúng chiết khấu tổng đơn bằng tay (sẽ được tính lại trong logic tính toán)
    if (event.reLoad == true) {
      manualTotalDiscountValue = 0;
      // ✅ QUAN TRỌNG: Khi reLoad: true, totalDiscountForOder có thể đã bao gồm cả manualTotalDiscountValue cũ
      // Reset totalDiscountForOder về 0 để tính lại từ đầu
      // Nếu có CKTDTT từ API, nó sẽ được tính lại trong logic khác và cập nhật vào totalDiscountForOder
      if (Const.freeDiscount == true && manualTotalDiscountPercent > 0) {
        print('💰 [RELOAD] Reset manualTotalDiscountValue=0, manualTotalDiscountPercent=${manualTotalDiscountPercent}%');
        print('💰 [RELOAD] totalDiscountForOder before reset: ${totalDiscountForOder}');
        // ✅ QUAN TRỌNG: Reset totalDiscountForOder về 0 để tính lại từ đầu
        // Logic tính toán manual total discount sẽ tính lại = baseOrderDiscount (từ API nếu có) + manualValue (từ manualTotalDiscountPercent)
        totalDiscountForOder = 0;
      } else {
        print('💰 [RELOAD] Reset manualTotalDiscountValue=0, manualTotalDiscountPercent=${manualTotalDiscountPercent}%');
      }
    }
    
    // ✅ QUAN TRỌNG: Chỉ restore từ listOrderCalculatorDiscount nếu có chiết khấu thủ công
    // Trong mode add, không restore chiết khấu từ chương trình (đã được clear)
    if(event.reLoad == false) {
      // ✅ FIX: Kiểm tra null trước khi sử dụng event.product
      if(event.product != null && event.product!.code != null && event.product!.code != ''){
        if(event.addOnProduct == true){
          if(DataLocal.listOrderCalculatorDiscount.any((element) => element.code.toString().trim() == event.product!.code.toString().trim())){
            DataLocal.listOrderCalculatorDiscount.removeAt(DataLocal.listOrderCalculatorDiscount.indexWhere((element) => element.code.toString().trim() == event.product!.code.toString().trim()));
            DataLocal.listOrderCalculatorDiscount.add(event.product!);
          }
          else{
            DataLocal.listOrderCalculatorDiscount.add(event.product!);
          }
        }
        else{
          if(DataLocal.listOrderCalculatorDiscount.any((element) => element.code.toString().trim() == event.product!.code.toString().trim())){
            DataLocal.listOrderCalculatorDiscount.removeAt(DataLocal.listOrderCalculatorDiscount.indexWhere((element) => element.code.toString().trim() == event.product!.code.toString().trim()));
          } 
        }
      }
      // ✅ Nếu event.product == null (như khi gọi từ ApplyManualTotalDiscountPercentEvent), không làm gì cả
    }
    for (var element in listOrder) {
      if(Const.afterTax == true){ /// thuế sau chiết khấu
        element.priceAfterTax = /* element.giaGui > 0
                ?
            (element.giaGui) + (((element.giaGui * 1) * DataLocal.taxPercent)/100) => 2.250.000
                :*/ (element.priceAfter!) + (((element.priceAfter! * 1) * DataLocal.taxPercent)/100);
      }
      else if(Const.afterTax == false){ /// thuế trước chiết khấu
        element.priceAfterTax = (element.giaSuaDoi) + (((element.giaSuaDoi * 1) * DataLocal.taxPercent)/100);
      }
      // print('GGG: ${element.giaSuaDoi} - ${element.price}');
      // print('Đơn giá st 1: ${element.priceAfter} = ${element.price} + ( (${element.price} * 1) * ${DataLocal.taxPercent})/100');
      if(Const.freeDiscount == true && DataLocal.listOrderCalculatorDiscount.isNotEmpty && event.reLoad == true){
        if(DataLocal.listOrderCalculatorDiscount.any((values) => values.code.toString().trim() == element.code.toString().trim())){
          SearchItemResponseData item = DataLocal.listOrderCalculatorDiscount.firstWhere((value) => value.code.toString().trim() == element.code.toString().trim());
          int index = listOrder.indexOf(element);
          if(item != null){
            // ✅ QUAN TRỌNG: Chỉ restore chiết khấu thủ công (discountByHand == true)
            // Nếu không phải chiết khấu thủ công, không restore để tránh restore chiết khấu không còn match
            if(item.discountByHand == true){
              double a = item.ckntByHand!;
             if(allowTaxPercent == true && event.addTax == true){
               a = (((element.priceAfterTax! * element.count!) * item.discountPercentByHand)/100);
             }
              listOrder[index].discountByHand = true;
              listOrder[index].discountPercentByHand = item.discountPercentByHand;
              totalPayment = totalPayment - a;
              listOrder[index].ckntByHand = a;
              listOrder[index].giaSuaDoi = item.giaSuaDoi == 0 ? item.price??0 : item.giaSuaDoi;
              listOrder[index].price = item.giaSuaDoi == 0 ? item.price : item.giaSuaDoi;
              listOrder[index].priceAfter2 = item.priceAfter;
              listOrder[index].priceAfter = item.priceAfter;
              listOrder[index].idHd = item.idHd;
              listOrder[index].idVv = item.idVv;
              listOrder[index].nameHd = item.nameHd.toString();
              listOrder[index].nameVv = item.nameVv.toString();
              listOrder[index].idHdForVv = item.idHdForVv.toString();
            } else {
              // ✅ Nếu không phải chiết khấu thủ công, xóa khỏi listOrderCalculatorDiscount
              // Vì chiết khấu này có thể không còn match với chương trình chiết khấu hiện tại
              print('💰 ⚠️ Skipping restore discount from listOrderCalculatorDiscount for ${element.code}: not a manual discount (discountByHand=${item.discountByHand})');
              DataLocal.listOrderCalculatorDiscount.removeWhere((values) => values.code.toString().trim() == element.code.toString().trim());
            }
          }
        }
      }
      if(Const.freeDiscount == true ){
        // print('Đơn giá: ${element.giaSuaDoi}');
        // print('Đơn giá price: ${element.price}');
        // print('Đơn giá st: ${element.priceAfterTax}');
        // print('Số lượng: ${element.count}');
        // print('Tỷ lệ phần trăm: ${element.discountPercentByHand}');
        // print('------');

        double ax = 0;
        if(allowTaxPercent == true /*&& Const.afterTax == false*/){
          ax =  (element.giaSuaDoi * element.count!) -  (element.priceAfter! * element.count!);
        }
        else{
         ax = (((element.giaSuaDoi * element.count!) * double.parse(
             (
                 "${Const.freeDiscount == true
                     ?
                 (element.discountPercentByHand > 0 ? element.discountPercentByHand :  element.discountPercent)
                     :
                 element.discountPercent}"
             )
         ))/100);
        }
        element.ckntByHand = ax;
      }
      if( Const.freeDiscount == true) {
        print('totalDiscount1---$firstLoadUpdateOrder--- $totalDiscount');
        totalDiscountOldByHand += element.ckntByHand!;

        if(firstLoadUpdateOrder == 0){
          totalDiscount += element.ckntByHand!;
        }
        print('totalDiscount2------ $totalDiscount');
        print('ckntByHand------ ${element.ckntByHand!}');
        print('totalDiscountOld------ ${totalDiscountOld}');
      }
      else{
        // ✅ FIX: Tính discount từ priceAfter thay vì dùng totalDiscountOld
        // Vì khi apply CKG discount, priceAfter đã được cập nhật, cần tính lại discount từ đó
        // QUAN TRỌNG: Trong edit mode, giaSuaDoi = priceAfter (giá sau chiết khấu), nên phải dùng price (giá gốc)
        bool isEditMode = (element.maCk != null && element.maCk.toString().trim().isNotEmpty) ||
                         (element.giaSuaDoi != null && element.price != null && 
                          element.giaSuaDoi! > 0 && element.price! > 0 && 
                          element.giaSuaDoi != element.price);

        // ✅ TÍNH GIÁ GỐC (originalPrice) AN TOÀN CHO EDIT MODE
        // Trong một số case sửa đơn, server trả về Price = 0 nhưng giaSuaDoi vẫn giữ giá gốc.
        // Nếu dùng Price = 0 để tính lại tổng tiền/chiết khấu → tổng tiền bị về 0 (bug như user report).
        double originalPrice;
        if (isEditMode) {
          // Ưu tiên Price (giá gốc). Nếu Price = 0 nhưng giaSuaDoi > 0 thì fallback sang giaSuaDoi.
          originalPrice = element.price ?? 0;
          if (originalPrice <= 0 && (element.giaSuaDoi ?? 0) > 0) {
            originalPrice = element.giaSuaDoi ?? 0;
          }
        } else {
          // Create mode: giữ logic cũ, dùng giaSuaDoi làm giá gốc
          originalPrice = element.giaSuaDoi ?? 0;
        }
        
        // ✅ DEBUG: Log để kiểm tra isEditMode + originalPrice thực tế
        if (element.isMark == 1 && element.gifProduct != true) {
          print('💰 [DEBUG] Product ${element.code}: isEditMode=$isEditMode, price=${element.price}, giaSuaDoi=${element.giaSuaDoi}, originalPrice=$originalPrice, priceAfter=${element.priceAfter}, discountPercent=${element.discountPercent}');
        }
        
        // ✅ FIX: Ưu tiên tính từ ck_nt nếu tl_ck = 0 và ck_nt có giá trị
        double? finalPriceAfter = element.priceAfter;
        double lineDiscount = 0;
        
        if (isEditMode && originalPrice > 0) {
          // ✅ QUAN TRỌNG: Ưu tiên tính từ chiết khấu nhập tay (ckntByHand) nếu có
          bool hasManualDiscount = element.discountByHand == true && 
                                    (element.discountPercentByHand ?? 0) > 0;
          
          if (hasManualDiscount) {
            // Có chiết khấu nhập tay, tính từ ckntByHand hoặc discountPercentByHand
            if (element.ckntByHand != null && element.ckntByHand! > 0) {
              // Đã có ckntByHand, dùng trực tiếp
              lineDiscount = element.ckntByHand!;
              // Tính priceAfter từ ckntByHand
              if (element.count != null && element.count! > 0) {
                double ckNtPerItem = lineDiscount / element.count!;
                finalPriceAfter = originalPrice - ckNtPerItem;
                if (finalPriceAfter < 0) finalPriceAfter = 0;
              }
              print('💰 [EDIT MODE] ✅ Using ckntByHand for manual discount: ckntByHand=${element.ckntByHand}, lineDiscount=$lineDiscount, priceAfter=$finalPriceAfter');
            } else if (element.discountPercentByHand != null && element.discountPercentByHand! > 0) {
              // Tính từ discountPercentByHand
              lineDiscount = (originalPrice * element.count! * element.discountPercentByHand!) / 100;
              element.ckntByHand = lineDiscount;
              finalPriceAfter = originalPrice - (originalPrice * element.discountPercentByHand! / 100);
              if (finalPriceAfter < 0) finalPriceAfter = 0;
              print('💰 [EDIT MODE] ✅ Calculated ckntByHand from discountPercentByHand: originalPrice=$originalPrice, count=${element.count}, discountPercentByHand=${element.discountPercentByHand}%, lineDiscount=$lineDiscount, priceAfter=$finalPriceAfter');
            }
          } else {
            // Không có chiết khấu nhập tay, tính từ discountPercent hoặc ck_nt như cũ
            // Parse ck_nt từ discountMoney (String)
            double ckNtValue = 0;
            if (element.discountMoney != null && element.discountMoney!.isNotEmpty && element.discountMoney != '0') {
              try {
                ckNtValue = double.parse(element.discountMoney!);
              } catch (e) {
                print('💰 [EDIT MODE] ⚠️ Cannot parse discountMoney "${element.discountMoney}" to double: $e');
              }
            }
            
            double discountPercentValue = element.discountPercent ?? 0;
            
            // ✅ QUAN TRỌNG: Nếu tl_ck = 0 và ck_nt có giá trị, tính từ ck_nt
            if (discountPercentValue == 0 && ckNtValue > 0 && element.count != null && element.count! > 0) {
              // Tính priceAfter từ ck_nt: priceAfter = originalPrice - (ck_nt / count)
              double ckNtPerItem = ckNtValue / element.count!;
              finalPriceAfter = originalPrice - ckNtPerItem;
              if (finalPriceAfter < 0) finalPriceAfter = 0;
              
              // lineDiscount = ck_nt (tổng tiền chiết khấu)
              lineDiscount = ckNtValue;
              
              print('💰 [EDIT MODE] ✅ Calculated from ck_nt: ck_nt=$ckNtValue, count=${element.count}, ck_nt_per_item=$ckNtPerItem, priceAfter=$finalPriceAfter, lineDiscount=$lineDiscount');
            } 
            // ✅ Nếu có discountPercent > 0, tính từ discountPercent
            else if (discountPercentValue > 0) {
              // Nếu priceAfter == originalPrice (không có chiết khấu) nhưng có discountPercent > 0, tính lại
              if (finalPriceAfter == null || finalPriceAfter <= 0 || finalPriceAfter >= originalPrice) {
                finalPriceAfter = originalPrice - (originalPrice * discountPercentValue / 100);
                print('💰 [EDIT MODE] ⚠️ Recalculated priceAfter from discountPercent: $originalPrice - ($originalPrice * $discountPercentValue% / 100) = $finalPriceAfter');
              } else {
                // Verify: Nếu priceAfter từ DB khác với tính toán từ discountPercent, ưu tiên tính toán
                double calculatedPriceAfter = originalPrice - (originalPrice * discountPercentValue / 100);
                double difference = (finalPriceAfter - calculatedPriceAfter).abs();
                if (difference > 1.0) { // Nếu sai lệch > 1 VND, dùng giá trị tính toán
                  finalPriceAfter = calculatedPriceAfter;
                  print('💰 [EDIT MODE] ⚠️ priceAfter from DB ($finalPriceAfter) differs from calculated ($calculatedPriceAfter), using calculated value');
                }
              }
              
              // Tính lineDiscount từ priceAfter
              if (finalPriceAfter != null && finalPriceAfter < originalPrice) {
                lineDiscount = (originalPrice - finalPriceAfter) * (element.count ?? 0);
              }
            }
          }
        }
        
        // ✅ ADD MODE: Tính discount từ priceAfter nếu không phải edit mode
        if (!isEditMode && originalPrice > 0) {
          // ✅ QUAN TRỌNG: Ưu tiên tính từ chiết khấu nhập tay (ckntByHand) nếu có
          bool hasManualDiscount = element.discountByHand == true && 
                                    (element.discountPercentByHand ?? 0) > 0;
          
          if (hasManualDiscount) {
            // Có chiết khấu nhập tay, tính từ ckntByHand hoặc discountPercentByHand
            if (element.ckntByHand != null && element.ckntByHand! > 0) {
              // Đã có ckntByHand, dùng trực tiếp
              lineDiscount = element.ckntByHand!;
              print('💰 [CREATE MODE] ✅ Using ckntByHand for manual discount: ckntByHand=${element.ckntByHand}, lineDiscount=$lineDiscount');
            } else if (element.discountPercentByHand != null && element.discountPercentByHand! > 0) {
              // Tính từ discountPercentByHand
              lineDiscount = (originalPrice * element.count! * element.discountPercentByHand!) / 100;
              element.ckntByHand = lineDiscount;
              print('💰 [CREATE MODE] ✅ Calculated ckntByHand from discountPercentByHand: originalPrice=$originalPrice, count=${element.count}, discountPercentByHand=${element.discountPercentByHand}%, lineDiscount=$lineDiscount');
            }
            
            // Cập nhật priceAfter nếu chưa có
            if (finalPriceAfter == null || finalPriceAfter == 0 || finalPriceAfter >= originalPrice) {
              finalPriceAfter = originalPrice - (lineDiscount / (element.count ?? 1));
              if (finalPriceAfter < 0) finalPriceAfter = 0;
              element.priceAfter = finalPriceAfter;
              print('💰 [CREATE MODE] ✅ Updated priceAfter from manual discount: priceAfter=$finalPriceAfter');
            }
          } else {
            // Không có chiết khấu nhập tay, tính từ discountPercent như cũ
            // ✅ QUAN TRỌNG: Nếu priceAfter chưa được set, tính từ discountPercent
            if (finalPriceAfter == null || finalPriceAfter == 0 || finalPriceAfter >= originalPrice) {
              double discountPercentValue = element.discountPercent ?? 0;
              
              if (discountPercentValue > 0) {
                finalPriceAfter = originalPrice - (originalPrice * discountPercentValue / 100);
                if (finalPriceAfter < 0) finalPriceAfter = 0;
                print('💰 [CREATE MODE] ✅ Calculated priceAfter from discountPercent: $originalPrice - ($originalPrice * $discountPercentValue% / 100) = $finalPriceAfter');
              } else {
                finalPriceAfter = originalPrice;
              }
            }
            
            if (finalPriceAfter != null && finalPriceAfter < originalPrice) {
              lineDiscount = (originalPrice - finalPriceAfter) * (element.count ?? 0);
              print('💰 [CREATE MODE] ✅ Calculated discount: originalPrice=$originalPrice, priceAfter=$finalPriceAfter, count=${element.count}, lineDiscount=$lineDiscount');
            }
          }
        }
        
        if (lineDiscount > 0) {
          totalDiscount += lineDiscount;
          if (isEditMode) {
            print('💰 [EDIT MODE] ✅ Added to totalDiscount: lineDiscount=$lineDiscount, totalDiscount=$totalDiscount');
            print('💰 [EDIT MODE] Product ${element.code}: originalPrice=$originalPrice, priceAfter=$finalPriceAfter, discountPercent=${element.discountPercent}%, discountMoney=${element.discountMoney}');
          }
        } else if (isEditMode && originalPrice > 0) {
          // ✅ DEBUG: Log khi không có discount
          print('💰 [EDIT MODE] ⚠️ No discount calculated for ${element.code}: originalPrice=$originalPrice, priceAfter=$finalPriceAfter (from ${element.priceAfter}), discountPercent=${element.discountPercent}, discountMoney=${element.discountMoney}');
        } else if (isEditMode) {
          // ✅ DEBUG: Log khi originalPrice = 0
          print('💰 [EDIT MODE] ⚠️ originalPrice = 0 for ${element.code}: price=${element.price}, giaSuaDoi=${element.giaSuaDoi}');
        }
        // totalDiscount = totalDiscountOld; // ❌ REMOVED: Không dùng giá trị cũ, tính lại từ priceAfter
      }
      if(Const.useTax == true){
        element.valuesTax = 0;
        element.valuesTax = (((element.priceAfter! * element.count!) * DataLocal.taxPercent)/100);
        totalTax = totalTax + element.valuesTax!;
      }
      // valuesTax += element.priceAfterTax != null ? element.priceAfterTax! : 0;


      // ✅ Calculate totalMoney từ originalPrice - chỉ tính cho products được mark
      // QUAN TRỌNG: Trong edit mode, nếu Price = 0 nhưng giaSuaDoi > 0 thì fallback sang giaSuaDoi để tránh tổng tiền = 0
      if(element.isMark == 1 && element.gifProduct != true){
        bool isEditMode = (element.maCk != null && element.maCk.toString().trim().isNotEmpty) ||
                         (element.giaSuaDoi != null && element.price != null && 
                          element.giaSuaDoi! > 0 && element.price! > 0 && 
                          element.giaSuaDoi != element.price);
        
        double originalPrice;
        if (isEditMode) {
          originalPrice = element.price ?? 0;
          if (originalPrice <= 0 && (element.giaSuaDoi ?? 0) > 0) {
            originalPrice = element.giaSuaDoi ?? 0;
          }
        } else {
          originalPrice = element.giaSuaDoi ?? 0;
        }
        
        if (originalPrice > 0) {
          totalMoney = totalMoney + (originalPrice * element.count!);
          totalMoneyOld = totalMoneyOld + (originalPrice * element.count!);
          if (isEditMode) {
            print('💰 [EDIT MODE] Calculated totalMoney: originalPrice=$originalPrice, count=${element.count}, lineTotal=${originalPrice * element.count!}');
          }
        }
      }
    }
    if(Const.chooseAgency == true && typeDiscount.isNotEmpty){
      chooseAgency(false);
    }
    if(Const.chooseTypePayment == true && codeTypePayment.contains('Thanh toán ngay')){
      chooseTypePayment();
    }
    // ✅ FIX: Dùng totalDiscountForOder thay vì cktd từ listCkTongDon[0]
    // totalDiscountForOder đã được cập nhật từ API response và có thể chứa tổng của nhiều CKTDTT
    double cktd = totalDiscountForOder;
    
    // ✅ FIX: Tính totalPayment = totalMoney - totalDiscount - totalDiscountForOder + totalTax
    // totalMoney: Tổng tiền nguyên giá
    // totalDiscount: Tổng chiết khấu sản phẩm (CKG, CKN, HH)
    // totalDiscountForOder: Tổng chiết khấu tổng đơn (CKTDTT - Chiết khấu tổng đơn tặng tiền)
    // totalTax: Tổng thuế (nếu có)
    double totalDiscountForOderValue = totalDiscountForOder ?? 0;
    print('💰 [BEFORE MANUAL CALC] totalDiscountForOderValue=$totalDiscountForOderValue, manualTotalDiscountValue=$manualTotalDiscountValue, manualTotalDiscountPercent=$manualTotalDiscountPercent%');

    // ✅ Manual total discount (order-level) for freeDiscount
    // ✅ FIX: Loại bỏ giá trị cũ của manual total discount khỏi totalDiscountForOderValue
    // để tránh cộng dồn khi tính lại (ví dụ khi add chiết khấu sản phẩm sau khi đã add chiết khấu tổng đơn)
    // hoặc khi loại bỏ chiết khấu tổng đơn (set về 0)
    double manualValue = 0;
    if (Const.freeDiscount == true) {
      // ✅ QUAN TRỌNG: Khi reLoad: true, totalDiscountForOder đã được reset về 0 ở trên
      // nên totalDiscountForOderValue = 0, và baseOrderDiscount = 0 (trừ khi có CKTDTT từ API được tính lại)
      // Khi reLoad: false, loại bỏ giá trị cũ của manual total discount khỏi totalDiscountForOderValue
      double baseOrderDiscount = totalDiscountForOderValue - manualTotalDiscountValue;
      if (baseOrderDiscount < 0) baseOrderDiscount = 0;
      print('💰 [MANUAL CALC START] baseOrderDiscount=$baseOrderDiscount (totalDiscountForOderValue=$totalDiscountForOderValue - manualTotalDiscountValue=$manualTotalDiscountValue)');
      
      if (manualTotalDiscountPercent > 0) {
        // ✅ QUAN TRỌNG: Tính trên tổng sau chiết khấu dòng (bao gồm cả chiết khấu byHand)
        // nhưng trước CK tổng đơn hiện có (baseOrderDiscount - không bao gồm manual total discount)
        // totalDiscount ở đây đã bao gồm cả ckntByHand từ các sản phẩm (đã được tính ở trên)
        final base = totalMoney + totalTax - totalDiscount - baseOrderDiscount;
        if (base > 0) {
          manualValue = (base * manualTotalDiscountPercent) / 100;
          if (manualValue < 0) manualValue = 0;
          // ✅ Cập nhật manualTotalDiscountValue để lần sau có thể loại bỏ đúng
          manualTotalDiscountValue = manualValue;
          totalDiscountForOderValue = baseOrderDiscount + manualValue;
          print('💰 [MANUAL TOTAL DISCOUNT CALC] percent=$manualTotalDiscountPercent%, base=$base (totalMoney=$totalMoney + totalTax=$totalTax - totalDiscount=$totalDiscount - baseOrderDiscount=$baseOrderDiscount), manualValue=$manualValue, totalDiscountForOderValue=$totalDiscountForOderValue');
        } else {
          // ✅ Nếu base <= 0, reset manualTotalDiscountValue
          manualTotalDiscountValue = 0;
          totalDiscountForOderValue = baseOrderDiscount;
          print('💰 [MANUAL TOTAL DISCOUNT CALC] base <= 0, reset manualTotalDiscountValue=0');
        }
      } else {
        // ✅ Nếu manualTotalDiscountPercent = 0, loại bỏ giá trị cũ khỏi totalDiscountForOderValue
        manualTotalDiscountValue = 0;
        totalDiscountForOderValue = baseOrderDiscount;
        print('💰 [MANUAL TOTAL DISCOUNT CALC] percent=0, removed old manualTotalDiscountValue, totalDiscountForOderValue=$totalDiscountForOderValue');
      }
    } else {
      // ✅ Nếu không có freeDiscount, reset manualTotalDiscountValue
      manualTotalDiscountValue = 0;
    }

    totalPayment = totalMoney + totalTax - totalDiscount - totalDiscountForOderValue;
    if (totalPayment < 0) totalPayment = 0;
    // ✅ Sync field for later payload/use
    totalDiscountForOder = totalDiscountForOderValue;

    // if(Const.useTax  == true){
    //   totalPayment = totalPayment + totalTax;
    // }
    print('💰 ========================================');
    print('💰 FINAL CALCULATION:');
    print('💰   totalMoney (tổng tiền nguyên giá) = $totalMoney');
    print('💰   totalDiscount (tổng chiết khấu sản phẩm) = $totalDiscount');
    print('💰   totalDiscountForOderValue (calculated) = $totalDiscountForOderValue');
    print('💰   totalDiscountForOder (synced) = $totalDiscountForOder');
    print('💰   totalTax (tổng thuế) = $totalTax');
    print('💰   totalPayment = totalMoney + totalTax - totalDiscount - totalDiscountForOderValue');
    print('💰   totalPayment = $totalMoney + $totalTax - $totalDiscount - $totalDiscountForOderValue = $totalPayment');
    print('💰   manualTotalDiscountPercent = $manualTotalDiscountPercent%');
    print('💰   manualTotalDiscountValue = $manualTotalDiscountValue');
    print('💰 ========================================');
    emitter(CalculatorDiscountSuccess());
  }

  void calculatorTax(){
    totalTax = 0;
    totalPayment = 0;
    for (var element in listProductOrderAndUpdate) {
      var matchingItems = listOrder.where((valuesE) => valuesE.code.toString().trim() == element.code.toString().trim());
      if(matchingItems.isEmpty) continue;
      SearchItemResponseData item = matchingItems.first;
      if(item.code != '' && item.code != 'null'){
        element.taxPercent = DataLocal.taxPercent;
        if(Const.afterTax == true){
          element.valuesTax = 0;
          element.priceAfterTax =  (item.priceAfter!) + ((item.priceAfter! * DataLocal.taxPercent)/100);
          element.valuesTax = (((item.priceAfter! * item.count!) * DataLocal.taxPercent)/100);
          print('Price = ${item.priceAfter} + ${((item.priceAfter! * DataLocal.taxPercent)/100)} == ${element.priceAfterTax} ');
          print('Tax = ${item.priceAfter!} * ${item.count!} * ${(( DataLocal.taxPercent)/100)} == ${element.valuesTax} ');
          // print('BT: (${item.priceAfter!} * $taxPercent)/100 = ${( item.priceAfter! * taxPercent)/100}');
          // print('Tax: ${element.valuesTax}'); //29.454
          item.valuesTax = element.valuesTax;
          item.taxPercent = element.taxPercent;
          listOrder[listOrder.indexWhere((elementListOrder) => elementListOrder.code.toString().trim() == element.code.toString().trim())] = item;
          totalTax = totalTax + element.valuesTax! ;
          totalPayment = totalPayment + (item.priceAfter! * item.count!);
        }
        else{
          element.valuesTax = 0;
          element.priceAfterTax =  (item.giaSuaDoi) + ((item.giaSuaDoi * DataLocal.taxPercent)/100);
          element.valuesTax = (((item.giaSuaDoi * item.count!) * DataLocal.taxPercent)/100);

          // print('Price = ${item.giaSuaDoi} + ${((item.giaSuaDoi * DataLocal.taxPercent)/100)} == ${element.priceAfterTax} ');
          // // print('BT: (${item.priceAfter!} * $taxPercent)/100 = ${( item.priceAfter! * taxPercent)/100}');
          // print('Tax: ${element.valuesTax}'); //29.454
          item.valuesTax = element.valuesTax;
          item.taxPercent = element.taxPercent;
          listOrder[listOrder.indexWhere((elementListOrder) => elementListOrder.code.toString().trim() == element.code.toString().trim())] = item;
          totalTax = totalTax + element.valuesTax! ;
          totalPayment = totalPayment + (item.giaSuaDoi * item.count!);
        }
      }
    }
    if(allowTaxPercent == false){
      totalPayment = totalPaymentOld - totalDiscount;
    }else{
      totalPayment = totalPayment + totalTax; //3375000 + 675000 - 375000
    }
    //
    print("totalPayment:$totalPayment");
    print("totalTax:$totalTax");
    print("totalDiscount:$totalDiscount");
    print("totalPayment:$totalPayment");
  }

  int firstLoadUpdateOrder = 0;
  void _getListStockEvent(GetListStockEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    CartState state = _handleGetListStock(await _networkFactory!.getListStock(
        token: _accessToken.toString(),
        itemCode: event.itemCode.toString(),
        listKeyGroup: Const.listKeyGroupCheck,
        checkGroup: event.lockInputToCart == true ? 0 : (event.getListGroup == true ? (Const.checkGroup == true ? 1 : 0) : 0),
        checkStock: Const.lockStockInItem == true ? 0 : 1,
        checkStockEmployee: event.checkStockEmployee
    ), event.getListGroup);
    emitter(state);
  }

  List<ListStore> listStockResponse = [];
  List<ListQDDVT> listQuyDoiDonViTinh = [];
  CartState _handleGetListStock(Object data, bool checkGroup){
    if(data is String) return CartFailure('Úi, ${data.toString()}');
    String message = '';
    try{
      if(listStockResponse.isNotEmpty) {
        listStockResponse.clear();
      }
      ListStockAndGroupResponse response = ListStockAndGroupResponse.fromJson(data as Map<String,dynamic>);
      message = response.message.toString();
      listStockResponse = response.listStore??[];
      listQuyDoiDonViTinh = response.listQuyDoiDonViTinh??[];
      if(listStockResponse.isNotEmpty){
        ton13 = listStockResponse[0].ton13!;
      }
      ///Trong giỏ hàng thì không cần
      if(checkGroup == true && Const.listKeyGroup.isEmpty){
        Const.listKeyGroup = '';
        listStockResponse = response.listStore??[];
        List<ListGroup> listGroup = response.listGroup!;
        if(listGroup.isNotEmpty){
          for (var element in listGroup) {
            if(element.maNhom.toString().isNotEmpty && element.maNhom != 'null'){
              Const.listKeyGroup = Const.listKeyGroup.isEmpty ? '${element.loaiNhom}:${element.maNhom}' : '${Const.listKeyGroup},${element.loaiNhom}:${element.maNhom}' ;
            }
          }
        }
      }
      return GetListStockEventSuccess();
    }
    catch(e){
      return CartFailure('Úi, ${message.toString()}');
    }
  }
 double ton13 = 0;
  void _getListItemUpdateOrderEvent(GetListItemUpdateOrderEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    CartState state = _handleGetDetailOrder(await _networkFactory!.getItemDetailOrder(_accessToken!,event.sttRec));
    emitter(state);
  }

  void _checkDisCountWhenUpdateEvent(CheckDisCountWhenUpdateEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    
    // ✅ PRESERVE gifts từ chi tiết đơn hàng từ 2 nguồn:
    // 1. Từ DataLocal.listProductGift (nếu đã có)
    // 2. Từ lineItem (nếu chưa có trong DataLocal)
    List<SearchItemResponseData> preservedGiftsFromOrderDetail = DataLocal.listProductGift.where((gift) => 
      gift.gifProduct == true && 
      gift.gifProductByHand == false && 
      (gift.typeCK == null || gift.typeCK == '')
    ).toList();
    
    // ✅ Nếu chưa có gifts trong DataLocal, lấy từ lineItem (từ _handleGetDetailOrder)
    if(preservedGiftsFromOrderDetail.isEmpty && lineItem.isNotEmpty){
      for (var element in lineItem) {
        bool isGiftProduct = element.kmYn != null && element.kmYn != 0;
        if(isGiftProduct){
          // ✅ QUAN TRỌNG: Set sttRecCK và sttRec0 từ lineItem để validation có thể match
          // Note: LineItems không có sttRecCk, chỉ có maCk. 
          // Validation sẽ match theo maVt (code) và maCk
          String? maCkFromLineItem = element.maCk?.toString().trim();
          // Note: LineItems không có kieuCk, mặc định typeCK = 'HH' cho gift products
          String? typeCkFromLineItem = 'HH'; // Mặc định 'HH' cho hàng tặng
          
          SearchItemResponseData giftItem = SearchItemResponseData(
            code: element.maVt,
            sttRec0: '', // LineItems không có sttRecCk, sẽ match theo maVt (code) và maCk
            name: element.tenVt,
            name2: element.name2,
            dvt: element.dvt,
            descript: "",
            price: element.price,
            giaSuaDoi: element.price ?? 0,
            applyPriceAfterTax: false,
            totalMoneyDiscount: 0,
            totalMoneyProduct: 0,
            valuesTax: 0,
            priceAfter: element.priceAfter,
            discountPercent: 0,
            stockAmount: element.stockAmount,
            taxPercent: 0,
            priceOk: 0,
            imageUrl: element.imageUrl ?? '',
            count: element.soLuong,
            isMark: 0,
            discountMoney: '0',
            discountProduct: '0',
            budgetForItem: '',
            budgetForProduct: '',
            residualValueProduct: 0,
            residualValue: 0,
            unit: element.dvt ?? '',
            priceAfter2: 0,
            maCk: maCkFromLineItem ?? '', // ✅ Set từ lineItem để validation match
            maCkOld: maCkFromLineItem ?? '', // ✅ Set từ lineItem
            kColorFormatAlphaB: element.kColorFormatAlphaB,
            maVtGoc: '', 
            ck: 0, 
            cknt: 0, 
            sttRecCK: '', // LineItems không có sttRecCk, sẽ match theo maVt (code) và maCk
            typeCK: typeCkFromLineItem ?? 'HH', // ✅ Set typeCK từ lineItem (hoặc mặc định 'HH')
            gifProduct: true, 
            gifProductByHand: false,
            discountByHand: false, 
            discountPercentByHand: 0,
            unitProduct: '',
            contentDvt: '',
            woPrice: 0,
            woPriceAfter: 0,
            stockCode: element.codeStore,
            stockName: element.nameStore,
            idVv: element.maVV,
            idHd: element.maHD,
            nameVv: element.tenVV,
            nameHd: element.tenHD,
          );

          preservedGiftsFromOrderDetail.add(giftItem);
        }
      }
    }
    
    // ✅ QUAN TRỌNG: Đảm bảo dsCKLineItem được set từ lineItem trước khi build draft
    // (để restore có thể match maCk từ listOrder)
    if(event.viewUpdateOrder == true && lineItem.isNotEmpty && listProductOrderAndUpdate.isNotEmpty){
      print('💰 Setting dsCKLineItem from lineItem for ${lineItem.length} items...');
      for(int i = 0; i < lineItem.length; i++){
        try {
          var currentLineItem = lineItem[i];
          if(currentLineItem == null) continue;
          
          // ✅ Safe null handling
          String? lineItemMaCk;
          if(currentLineItem.maCk != null) {
            lineItemMaCk = currentLineItem.maCk.toString().trim();
          }
          
          String? lineItemMaVt;
          if(currentLineItem.maVt != null) {
            lineItemMaVt = currentLineItem.maVt.toString().trim();
          }
          
          if(lineItemMaCk != null && lineItemMaCk.isNotEmpty && lineItemMaVt != null && lineItemMaVt.isNotEmpty){
            // Tìm product trong listProductOrderAndUpdate có code match với lineItem[i].maVt
            int productIndex = listProductOrderAndUpdate.indexWhere((p) => 
              p.code != null && (p.code?.trim() ?? '') == lineItemMaVt
            );

            if(productIndex >= 0 && productIndex < listProductOrderAndUpdate.length){
              // Set dsCKLineItem từ lineItem[i].maCk
              List<String> itemCodeDiscountInLine = [];
              
              if(lineItemMaCk.isNotEmpty){
                itemCodeDiscountInLine.add(lineItemMaCk);
              }
              
              // ✅ LineItems không có discountProductCode, chỉ có maCk
              if(itemCodeDiscountInLine.isNotEmpty){
                listProductOrderAndUpdate[productIndex].dsCKLineItem = itemCodeDiscountInLine.join(',');
                print('💰 Set dsCKLineItem for product ${listProductOrderAndUpdate[productIndex].code}: ${listProductOrderAndUpdate[productIndex].dsCKLineItem}');
              }
            }
          }
        } catch (e) {
          print('⚠️ Error setting dsCKLineItem for lineItem[$i]: $e');
          continue;
        }
      }
    }
    
    List<SearchItemResponseData> draft = [];
    for (var element in listProductOrderAndUpdate) {
      SearchItemResponseData item = SearchItemResponseData(
          code: element.code,
          name: element.name,
          name2:element.name2,
          dvt: element.dvt,
          descript: element.description,
          price: element.price,
          discountPercent: element.discountPercent,
          priceAfter: element.priceAfter,
          stockAmount: element.stockAmount,
          taxPercent: element.taxPercent,
          imageUrl: element.imageUrl,
          count: element.count,
          countMax: element.countMax,
          so_luong_kd: element.so_luong_kd,
          maVt2: element.maVt2,
          sttRec0: element.sttRec0,
          isMark:0,
          discountMoney: element.discountMoney,
          discountProduct: element.discountProduct,
          budgetForItem: element.budgetForItem,
          budgetForProduct: element.budgetForProduct,
          residualValueProduct: element.residualValueProduct,
          residualValue: element.residualValue,
          unit: element.unit,
          unitProduct: element.unitProduct,
          maCk: element.dsCKLineItem,
          maCkOld: element.dsCKLineItem.toString(),
          giaSuaDoi: element.giaSuaDoi,
          giaGui: element.giaGui,
          isCheBien: element.isCheBien == 1 ? true : false,
          isSanXuat: element.isSanXuat == 1 ? true : false,
          availableQuantity: element.availableQuantity,
          // ✅ QUAN TRỌNG: Copy chiết khấu byhand từ listProductOrderAndUpdate
          discountByHand: element.discountByHand == 1,
          discountPercentByHand: element.discountPercentByHand ?? 0,
          ckntByHand: element.ckntByHand ?? 0
      );
      draft.add(item);
    }
    DiscountRequest requestBody = DiscountRequest(
        sttRec: event.sttRec,
        maKh: event.codeCustomer,
        maKho: event.codeStore,
        lineItem: draft
    );
    // ✅ Truyền preservedGiftsFromOrderDetail vào _handleCalculator để restore sau
    CartState state = _handleCalculator(
      await _networkFactory!.getDiscountWhenUpdate(requestBody,_accessToken!),
      event.viewUpdateOrder,
      event.addNewItem,
      true,
      preservedGiftsFromOrderDetail: preservedGiftsFromOrderDetail, // Truyền gifts đã preserve
    );
    emitter(state);
  }
  List<Product> listProduct = <Product>[];

  List<SearchItemResponseData> listProductGift = [];
  void _addProductToCartEvent(AddProductToCartEvent event, Emitter<CartState> emitter)async{
    
    // ✅ PRESERVE listOrder từ draft TRƯỚC KHI clear
    // Vì AddProductToCartEvent sẽ load đơn cũ vào database, có thể làm mất listOrder từ draft
    List<SearchItemResponseData> preservedListOrderFromDraft = [];
    final draftExists = await CartDraftStorage.checkDraftExists();
    if (draftExists) {
      // Restore draft tạm thời để lấy listOrder
      final tempBloc = CartBloc(context);
      final restored = await CartDraftStorage.restoreDraft(tempBloc);
      if (restored && tempBloc.listOrder.isNotEmpty) {
        preservedListOrderFromDraft = List<SearchItemResponseData>.from(tempBloc.listOrder);
        for (int i = 0; i < preservedListOrderFromDraft.length; i++) {
          final item = preservedListOrderFromDraft[i];
        }
      }
      final draftInfo = await CartDraftStorage.getDraftInfo();
    } else {
      print('💾 No draft in database, safe to clear');
    }
    
    emitter(CartLoading());
    db.deleteAllProduct().then((value) => print('delete success'));
    // Clear listProductGift trước khi thêm mới
    listProductGift.clear();
    for (var element in lineItem) {
      // Kiểm tra kmYn: null hoặc 0 = sản phẩm thường, != 0 = sản phẩm khuyến mại
      bool isGiftProduct = element.kmYn != null && element.kmYn != 0;
      
      if(!isGiftProduct){
        // Sản phẩm thường
        // ✅ Extract maCk from lineItem for CKG restore
        String maCkFromLineItem = element.maCk?.toString().trim() ?? '';
        
        // ✅ CHECK EDIT MODE: Có maCk hoặc có priceAfter/discountPercent từ lineItem
        bool isEditMode = (maCkFromLineItem.isNotEmpty) || 
                          (element.priceAfter != null && element.priceAfter! > 0 && element.priceAfter != element.price) ||
                          (element.discountPercent != null && element.discountPercent! > 0);
        
        // ✅ LOGIC CŨ (CREATE MODE): Giữ nguyên logic cũ
        String discountMoneyStr = '0';
        double finalPriceAfter = element.priceAfter ?? element.price ?? 0;
        double finalDiscountPercent = element.discountPercent ?? 0;
        double finalGiaSuaDoi = element.price ?? 0; // ✅ LOGIC CŨ: giaSuaDoi = price (giá gốc)
        
        // ✅ QUAN TRỌNG: Khai báo các biến chiết khấu byhand ở ngoài để có thể sử dụng sau
        bool isManualDiscount = false;
        double manualDiscountPercent = 0;
        double manualCknt = 0;
        
        // ✅ LOGIC MỚI (EDIT MODE): Set giá từ lineItem nếu có chiết khấu
        if (isEditMode) {
          // Tính toán tiền chiết khấu từ ck_nt (nếu có)
          if (element.ckNt != null && element.ckNt! > 0) {
            discountMoneyStr = element.ckNt.toString();
          }
          
          // Set giá sau chiết khấu từ priceAfter
          finalPriceAfter = element.priceAfter ?? element.price ?? 0;
          
        // ✅ QUAN TRỌNG: Ưu tiên lấy tl_ck từ API order-detail (tlCk),
        // nếu không có thì fallback về discountPercent (giữ backward-compatible).
        // Đây chính là tỷ lệ chiết khấu gốc từ chương trình khuyến mại/đơn hàng.
          double tlCk = element.tlCk ?? (element.discountPercent ?? 0);
          
          if (tlCk == 0 && element.ckNt != null && element.ckNt! > 0 && element.price != null && element.price! > 0) {
            // Tính tỷ lệ phần trăm từ tiền chiết khấu: discountPercent = (ck_nt / (price * count)) * 100
            double originalPrice = element.price!;
            double quantity = element.soLuong ?? 1;
            double totalOriginalPrice = originalPrice * quantity;
            
            if (totalOriginalPrice > 0) {
              finalDiscountPercent = (element.ckNt! / totalOriginalPrice) * 100;
              isManualDiscount = true;
              manualDiscountPercent = finalDiscountPercent;
              manualCknt = element.ckNt!;
            } else {
              finalDiscountPercent = 0;
            }
          } else if (tlCk > 0) {
            // ✅ Nếu có tlCk > 0 từ lineItem (order-detail) → đây là chiết khấu theo TỶ LỆ từ CTKM/đơn gốc
            // KHÔNG coi là chiết khấu nhập tay (byhand), để khi UPDATE luôn gửi DiscountPercent cho backend.
            finalDiscountPercent = tlCk;
            isManualDiscount = false;           // Không bật byhand cho case tl_ck từ server
            manualDiscountPercent = 0;          // Không dùng discountPercentByHand trong trường hợp này
            manualCknt = 0;                     // Tiền chiết khấu sẽ do backend tính lại từ tl_ck
            print('💰   [EDIT MODE] ✅ Detected discount from order detail (PERCENT): tlCk=$tlCk%');
          } else {
            finalDiscountPercent = tlCk;
          }
          
          // ✅ FIX (EDIT MODE): giaSuaDoi phải là GIÁ GỐC (trước chiết khấu)
          // Nếu set giaSuaDoi = priceAfter sẽ bị apply % thêm lần nữa khi giỏ hàng tính freeDiscount
          finalGiaSuaDoi = element.price ?? (element.priceAfter ?? 0);

        } else {
          print('💰   [CREATE MODE] Using default logic: price=${element.price}, priceAfter=$finalPriceAfter, discountPercent=$finalDiscountPercent');
        }
        
        Product production = Product(
            code: element.maVt,
            name: element.tenVt,
            name2:element.name2,
            dvt: element.dvt,
            description: "",
            price: /*element.giaNet ?? */element.price,
            priceAfter: finalPriceAfter,
            discountPercent: finalDiscountPercent,
            stockAmount:element.stockAmount,
            taxPercent: 0,
            imageUrl: element.imageUrl ?? '',
            count: element.soLuong,
            countMax: element.soLuongKD,
            so_luong_kd: element.soLuongKD ?? 0,
            isMark:1,
            discountMoney: discountMoneyStr,
            discountProduct: '0',
            budgetForItem:'',
            budgetForProduct: '',
            residualValueProduct:0,
            residualValue: 0,
            unit: element.dvt ?? '',
            unitProduct: '',
            dsCKLineItem: maCkFromLineItem,
            codeStock: element.codeStore,
            nameStock: element.nameStore,
            idVv:element.maVV,
            idHd : element.maHD,
            nameVv: element.tenVV,
            nameHd : element.tenHD,
            giaSuaDoi: finalGiaSuaDoi,
            priceMin: element.giaMin??0,
            // ✅ QUAN TRỌNG: Set chiết khấu byhand từ ck_nt (order detail)
            discountByHand: isManualDiscount ? 1 : 0,
            discountPercentByHand: isManualDiscount ? manualDiscountPercent : 0,
            ckntByHand: isManualDiscount ? manualCknt : 0,
            // ✅ Giá gốc để tính discount/tax đúng trong giỏ hàng & payload
            priceOk: element.price ?? 0
        );
        listProduct.add(production);
        await db.addProduct(production);
      }
      else {
        // Sản phẩm khuyến mại từ chi tiết đơn hàng
        // Đánh dấu gifProductByHand = false để phân biệt với hàng thêm bằng tay
        SearchItemResponseData item = SearchItemResponseData(
          code: element.maVt,
          name: element.tenVt,
          name2:element.name2,
          dvt: element.dvt,
          descript: "",
          price: /*element.giaNet ??*/ element.price,
          giaSuaDoi: element.price ?? 0,
          applyPriceAfterTax: false,
          totalMoneyDiscount: 0,
          totalMoneyProduct: 0,
          valuesTax: 0,
          priceAfter: element.priceAfter,
          discountPercent: 0,
          stockAmount:element.stockAmount,
          taxPercent: 0,
          priceOk: 0,
          imageUrl: element.imageUrl ?? '',
          count: element.soLuong,
          isMark:0,
          discountMoney: '0',
          discountProduct: '0',
          budgetForItem:'',
          budgetForProduct: '',
          residualValueProduct:0,
          residualValue: 0,
          unit: element.dvt ?? '',
          priceAfter2: 0,
          maCk: '',
          maCkOld: '',
          kColorFormatAlphaB: element.kColorFormatAlphaB,
          maVtGoc: '',ck: 0,cknt: 0,sttRecCK: '',typeCK: '',gifProduct: true,gifProductByHand: false,discountByHand: false,discountPercentByHand: 0,
          unitProduct: '',
          contentDvt:  '',
          woPrice: 0,
          woPriceAfter: 0,
          stockCode: element.codeStore,
          stockName: element.nameStore,
            idVv:element.maVV,
            idHd : element.maHD,
            nameVv: element.tenVV,
            nameHd : element.tenHD,
        );
        listProductGift.add(item);
      }
    }
    
    // ✅ PRESERVE gifts từ chi tiết đơn hàng trước khi clear
    // (gifProductByHand == false và không có typeCK)
    List<SearchItemResponseData> preservedGiftsFromOrderDetail = DataLocal.listProductGift.where((gift) => 
      gift.gifProduct == true && 
      gift.gifProductByHand == false && 
      (gift.typeCK == null || gift.typeCK == '')
    ).toList();
    print('💰 _addProductToCartEvent: Preserving ${preservedGiftsFromOrderDetail.length} gifts from order detail before clear');
    
    // ✅ PRESERVE gifts từ DRAFT trước khi clear
    // (gifProductByHand == true - gifts được thêm bằng tay từ draft)
    List<SearchItemResponseData> preservedGiftsFromDraft = DataLocal.listProductGift.where((gift) => 
      gift.gifProduct == true && 
      gift.gifProductByHand == true
    ).toList();

    // ⚠️ CRITICAL: Clear DataLocal.listProductGift - This may affect draft!
    DataLocal.listProductGift.addAll(listProductGift);
    
    // ✅ RESTORE gifts từ chi tiết đơn hàng sau khi add gifts mới
    for (var gift in preservedGiftsFromOrderDetail) {
      bool exists = DataLocal.listProductGift.any((g) => 
        g.code == gift.code &&
        g.gifProductByHand == false &&
        (g.typeCK == null || g.typeCK == '')
      );
      if (!exists) {
        DataLocal.listProductGift.add(gift);
      }
    }
    
    // ✅ RESTORE gifts từ DRAFT sau khi add gifts từ đơn cũ
    // Đây là phần quan trọng: giữ lại gifts từ draft khi sửa đơn
    for (var gift in preservedGiftsFromDraft) {
      bool exists = DataLocal.listProductGift.any((g) => 
        g.code == gift.code &&
        g.gifProductByHand == true
      );
      if (!exists) {
        DataLocal.listProductGift.add(gift);
        print('💾 ✅ Restored gift from DRAFT: ${gift.code} (qty: ${gift.count})');
      } else {
        print('💾 Draft gift already exists: ${gift.code}');
      }
    }
    
    // ✅ Lưu preservedListOrderFromDraft vào biến tạm để restore sau trong GetListProductFromDBSuccess
    if (preservedListOrderFromDraft.isNotEmpty) {
      this.preservedListOrderFromDraft = preservedListOrderFromDraft;
      print('💾   - preservedListOrderFromDraft.length = ${this.preservedListOrderFromDraft!.length} (saved for later restore)');
    } else {
      this.preservedListOrderFromDraft = null;
    }
    
    print('💾 ========== AddProductToCartEvent COMPLETED ==========');
    emitter(AddProductToCartSuccess());
  }

  void _deleteProductInCartEvent(DeleteProductInCartEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    db.deleteAllProduct().then((value) => print('delete success'));
    emitter(DeleteProductInCartSuccess());
  }

  CartState _handlerCreateOrder(Object data){
    if (data is String) return CartFailure('Úi, ${data.toString()}');
    try{
      return CreateOrderSuccess();
    }catch(e){
      return OrderCreateFailure(e.toString());
    }
  }

  void _pickTaxAfter(PickTaxAfter event, Emitter<CartState> emitter){
    emitter(CartInitial());
    taxIndex = event.taxIndex;
    if(listProductOrderAndUpdate.isNotEmpty){
      calculatorTax();
      emitter(PickTaxAfterSuccess());
    }
    else {
      emitter(PickTaxNameFail());
    }
  }



  double totalTax2 = 0;
  void calculatorTaxForItem(){
    totalTax2 = 0;
    for (var item in listOrder) {
      // Kiểm tra null safety cho giaSuaDoi và thueSuat
      final double giaSuaDoi = (item.giaSuaDoi as num?)?.toDouble() ?? 0.0;
      final double thueSuat = (item.thueSuat as num?)?.toDouble() ?? 0.0;
      final double count = (item.count as num?)?.toDouble() ?? 0.0;
      
      if (giaSuaDoi > 0 && thueSuat > 0 && count > 0) {
        totalTax2 = totalTax2 + (((giaSuaDoi * count) * thueSuat)/100);
      }
    }
    totalPayment = totalPayment + totalTax2;
  }

  String codeDiscountSelecting = '';
  String typeDiscountSelecting = '';

  bool allowed = true;
  bool allowed2 = false;

  double totalProductGift = 0;

  CartState _handlerApplyDiscountV2(Object data, String keyLoad){
    if (data is String) return CartFailure('Úi, ${data.toString()}');
    try{
      print('🔍 ========== _handlerApplyDiscountV2 START (keyLoad=$keyLoad) ==========');
      print('🔍 listOrder.length = ${listOrder.length}');
      print('🔍 listProductOrderAndUpdate.length = ${listProductOrderAndUpdate.length}');
      
      // ✅ DEBUG: Kiểm tra chiết khấu nhập tay TRƯỚC KHI preserve
      int manualDiscountBefore = 0;
      for (var item in listOrder) {
        if (item.discountByHand == true && (item.discountPercentByHand ?? 0) > 0) {
          manualDiscountBefore++;
          print('🔍   - listOrder[${item.code}]: discountByHand=${item.discountByHand}, discountPercentByHand=${item.discountPercentByHand}, ckntByHand=${item.ckntByHand}');
        }
      }
      for (var element in listProductOrderAndUpdate) {
        if (element.discountByHand == 1 && (element.discountPercentByHand ?? 0) > 0) {
          manualDiscountBefore++;
          print('🔍   - listProductOrderAndUpdate[${element.code}]: discountByHand=${element.discountByHand}, discountPercentByHand=${element.discountPercentByHand}, ckntByHand=${element.ckntByHand}');
        }
      }
      print('🔍 Total manual discount BEFORE preserve: $manualDiscountBefore');
      
      totalMoney = 0;
      totalDiscount = 0;
      totalPayment = 0;
      totalMNProduct = 0;
      totalMNDiscount = 0;
      totalMNPayment = 0;
      listDiscount.clear(); listItemOrder.clear();
      
      // ✅ PRESERVE listPromotion và DataLocal.listCKVT khi keyLoad == 'Second'
      // (Để không mất các chiết khấu đã chọn trước đó như CKN, CKTDTH, CKTDTT)
      String preservedListPromotion = '';
      String preservedListCKVT = '';
      if(keyLoad == 'Second'){
        preservedListPromotion = listPromotion;
        preservedListCKVT = DataLocal.listCKVT;
        print('💰 Preserving listPromotion: $preservedListPromotion');
        print('💰 Preserving listCKVT: $preservedListCKVT');
      }

      // Backup quà nhập tay (giữ lại qua mọi lần load)
      final List<SearchItemResponseData> preservedManualGiftsAlways = DataLocal.listProductGift.where((e)=> e.gifProductByHand == true).toList();
      
      // ✅ PRESERVE gifts từ chi tiết đơn hàng (gifProductByHand == false và không có typeCK)
      final List<SearchItemResponseData> preservedGiftsFromOrderDetail = DataLocal.listProductGift.where((gift) => 
        gift.gifProduct == true && 
        gift.gifProductByHand == false && 
        (gift.typeCK == null || gift.typeCK == '')
      ).toList();
      print('💰 _handleCalculator: Preserving ${preservedGiftsFromOrderDetail.length} gifts from order detail');

      if(keyLoad == 'First'){
        listPromotion = '';
        DataLocal.listCKVT = '';
        DataLocal.listProductGift.clear();
        totalProductGift = 0;
        selectedCkgIds.clear();
        selectedHHIds.clear();
        selectedCknGroups.clear();
        
        // ✅ RESTORE gifts từ chi tiết đơn hàng ngay sau khi clear
        for (var gift in preservedGiftsFromOrderDetail) {
          DataLocal.listProductGift.add(gift);
          totalProductGift += gift.count ?? 0;
          print('💰 Restored gift from order detail (First): ${gift.code} (qty: ${gift.count})');
        }
        
        // ✅ Tính lại totalProductGift từ DataLocal.listProductGift để đảm bảo chính xác
        totalProductGift = 0;
        for (var gift in DataLocal.listProductGift) {
          totalProductGift += gift.count ?? 0;
        }
        print('💰 After restore (First): totalProductGift=$totalProductGift, listProductGift.length=${DataLocal.listProductGift.length}');
      }
      
      // Clear CKN data when recalculating
      if(keyLoad == 'First'){
        listCkn.clear();
        hasCknDiscount = false;
      }

      // ✅ QUAN TRỌNG: Preserve chiết khấu nhập tay từ listOrder VÀ listProductOrderAndUpdate
      // Map để lưu chiết khấu nhập tay theo code sản phẩm
      Map<String, Map<String, dynamic>> preservedManualDiscounts = {};
      
      print('🔍 ========== PRESERVE MANUAL DISCOUNT (keyLoad=$keyLoad) ==========');
      print('🔍 listOrder.length = ${listOrder.length}');
      print('🔍 listProductOrderAndUpdate.length = ${listProductOrderAndUpdate.length}');
      
      // Preserve từ listOrder (nếu có)
      int preservedFromListOrder = 0;
      for (var item in listOrder) {
        if (item.discountByHand == true && 
            (item.discountPercentByHand ?? 0) > 0 && 
            item.code != null && 
            item.code!.isNotEmpty) {
          preservedManualDiscounts[item.code!] = {
            'discountByHand': true,
            'discountPercentByHand': item.discountPercentByHand ?? 0,
            'ckntByHand': item.ckntByHand ?? 0,
            'priceAfter': item.priceAfter,
          };
          preservedFromListOrder++;
          print('🔍 ✅ Preserving from listOrder: ${item.code} - discountPercentByHand=${item.discountPercentByHand}, ckntByHand=${item.ckntByHand}, priceAfter=${item.priceAfter}');
        }
      }
      
      // ✅ QUAN TRỌNG: Preserve từ listProductOrderAndUpdate (database) - ưu tiên hơn
      int preservedFromDB = 0;
      for (var element in listProductOrderAndUpdate) {
        if (element.discountByHand == 1 && 
            (element.discountPercentByHand ?? 0) > 0 && 
            element.code != null && 
            element.code.toString().trim().isNotEmpty) {
          preservedManualDiscounts[element.code.toString()] = {
            'discountByHand': true,
            'discountPercentByHand': element.discountPercentByHand ?? 0,
            'ckntByHand': element.ckntByHand ?? 0,
            'priceAfter': element.priceAfter,
          };
          preservedFromDB++;
          print('🔍 ✅ Preserving from listProductOrderAndUpdate: ${element.code} - discountPercentByHand=${element.discountPercentByHand}, ckntByHand=${element.ckntByHand}, priceAfter=${element.priceAfter}');
        }
      }
      
      print('🔍 Total preserved: $preservedFromListOrder from listOrder, $preservedFromDB from DB, ${preservedManualDiscounts.length} unique products');
      print('🔍 Preserved codes: ${preservedManualDiscounts.keys.toList()}');
      print('🔍 ================================================================');
      
      if(keyLoad == 'Second'){
        if(listOrder.isNotEmpty){
          for (int j =0; j< listProductOrderAndUpdate.length ;j++) {
            for (int i =0; i< listOrder.length ;i++) {
              if(listOrder[i].code.toString().trim() == listProductOrderAndUpdate[j].code.toString().trim() && listOrder[i].gifProduct != true && listOrder[i].maVtGoc.toString().replaceAll('null', '').isNotEmpty){
                listProductOrderAndUpdate[j].maVtGoc = listOrder[i].maVtGoc;
                listProductOrderAndUpdate[j].sctGoc = listOrder[i].sctGoc;
                break;
              }
            }
          }
        }
      }

      // ✅ LUÔN clear listOrder trước khi build lại từ response apply-discount-v2
      // Tránh bị nhân đôi sản phẩm khi:
      //  - keyLoad = 'First' (ví dụ khi chọn khách hàng trong giỏ hàng → getDiscountProduct('First'))
      //  - listOrder đã chứa sẵn danh sách sản phẩm trước đó (từ DB/draft)
      //
      // Dữ liệu hiển thị sẽ được build lại hoàn toàn từ itemOrder/listItemOrder, 
      // trong khi chiết khấu nhập tay đã được preserve ở trên (preservedManualDiscounts).
      listOrder.clear();
      /// Salonzo có chiết khấu nhập tay : freeDiscount và chiết khấu hàng tự chọn : discountspecial
      /// Vậy khi xoá ds hàng tặng khi và chỉ khi freeDiscount được sử dụng
      // ✅ Backup quà nhập tay (mọi trường hợp)
      List<SearchItemResponseData> preservedManualGiftsFirst = DataLocal.listProductGift.where((e)=> e.gifProductByHand == true).toList();

      // ✅ CHỈ clear hàng tặng khi keyLoad == 'First' (lần đầu load)
      // Khi keyLoad == 'Second' (reload sau khi chọn thêm chiết khấu), PRESERVE các hàng tặng đã chọn (CKN, CKTDTH)
      if(Const.freeDiscount == false && keyLoad == 'First'){
        // ✅ Preserve gifts từ chi tiết đơn hàng trước khi clear
        List<SearchItemResponseData> preservedGiftsFromOrderDetailBeforeClear = DataLocal.listProductGift.where((gift) => 
          gift.gifProduct == true && 
          gift.gifProductByHand == false && 
          (gift.typeCK == null || gift.typeCK == '')
        ).toList();
        
        DataLocal.listProductGift.clear();
        DataLocal.listProductGift.addAll(preservedManualGiftsFirst);
        // ✅ Restore gifts từ chi tiết đơn hàng sau khi restore manual gifts
        DataLocal.listProductGift.addAll(preservedGiftsFromOrderDetailBeforeClear);
        print('💰 After clear (freeDiscount=false): Restored ${preservedManualGiftsFirst.length} manual gifts and ${preservedGiftsFromOrderDetailBeforeClear.length} gifts from order detail');
      }
      
      // ✅ PRESERVE CKN và CKTDTH gifts khi keyLoad == 'Second'
      List<SearchItemResponseData> preservedCknGifts = [];
      List<SearchItemResponseData> preservedCktdthGifts = [];
      List<SearchItemResponseData> preservedManualGifts = [];
      if(keyLoad == 'Second'){
        // Backup các hàng tặng CKN, CKTDTH và manual gifts
        for (var gift in DataLocal.listProductGift) {
          if (gift.typeCK == 'CKN') {
            preservedCknGifts.add(gift);
          } else if (gift.typeCK == 'CKTDTH') {
            preservedCktdthGifts.add(gift);
          } else if (gift.gifProductByHand == true) {
            preservedManualGifts.add(gift);
          }
        }
        print('💰 Preserving gifts: CKN=${preservedCknGifts.length}, CKTDTH=${preservedCktdthGifts.length}, Manual=${preservedManualGifts.length}');
      }
      ApplyDiscountResponse response = ApplyDiscountResponse.fromJson(data as Map<String,dynamic>);
      if(listCkMatHang.isEmpty){
        listCkMatHang = response.listCkMatHang!;
      }
      if(listCkTongDon.isEmpty){
        listCkTongDon = response.listCkTongDon!;
      }
      if(listDiscount.isEmpty){
        listDiscount = response.listCk!;
      }
      List<ListCkMatHang> listCheckCKMH = [];
      listCheckCKMH = response.listCkMatHang!;
      
      // Filter discount products by type
      // ✅ Cập nhật danh sách chiết khấu cho CẢ 'First' và 'Second' để sheet hiển thị dữ liệu mới nhất
      // CKN - Chiết khấu nhóm (từ list_ck_mat_hang vì cần group_dk)
      if(response.listCkMatHang != null){
        listCkn = response.listCkMatHang!.where((item) => item.kieuCK == 'CKN').toList();
        hasCknDiscount = listCkn.isNotEmpty;
        
        // CKTDTH - Chiết khấu tổng đơn tặng hàng (từ list_ck_mat_hang với kieuCK = 'CKTDTH')
        listCktdth = response.listCkMatHang!.where((item) => item.kieuCK == 'CKTDTH').toList();
        hasCktdthDiscount = listCktdth.isNotEmpty;
        
        if(keyLoad == 'First') {
          selectedCktdthGroups.clear();
        }
      }
      
      // CKTDTT - Chiết khấu tổng đơn tặng tiền (từ listCkTongDon với kieuCK = 'CKTDTT')
      if(response.listCkTongDon != null){
        listCktdtt = response.listCkTongDon!.where((item) => item.kieuCK == 'CKTDTT').toList();
        hasCktdttDiscount = listCktdtt.isNotEmpty;
        
        if(keyLoad == 'First') {
          selectedCktdttIds.clear();
        }
      }
      
      // CKG & HH - Từ list_ck (vì backend trả về ở đó)
      if(response.listCk != null){
        // CKG - Chiết khấu giá
        listCkg = response.listCk!.where((item) => item.kieuCk == 'CKG').toList();
        hasCkgDiscount = listCkg.isNotEmpty;
        
        if(keyLoad == 'First') {
          selectedCkgIds.clear();
        }
        
        // HH - Hàng hóa tặng
        listHH = response.listCk!.where((item) => item.kieuCk == 'HH').toList();
        hasHHDiscount = listHH.isNotEmpty;
        
        if(keyLoad == 'First') {
          selectedHHIds.clear();
        }
      }
      
      print('💰 Discount Debug (keyLoad=$keyLoad): CKN: ${listCkn.length}, CKG: ${listCkg.length}, HH: ${listHH.length}, CKTDTT: ${listCktdtt.length}, CKTDTH: ${listCktdth.length}');
      print('💰 Default Selected: CKG: ${selectedCkgIds.length}, HH: ${selectedHHIds.length}, CKTDTT: ${selectedCktdttIds.length}, CKTDTH: ${selectedCktdthGroups.length}');
      print('💰 Discount Source: CKN/CKTDTH from listCkMatHang, CKG/HH from listCk, CKTDTT from listCkTongDon');

      if(listProductOrderAndUpdate.isNotEmpty){
        print('💰 Building listOrder from listProductOrderAndUpdate (${listProductOrderAndUpdate.length} items)...');
        for (var element in listProductOrderAndUpdate) {
          String dsCK = element.dsCKLineItem?.toString().trim() ?? '';
          print('💰   - Product ${element.code}: dsCKLineItem="$dsCK" (will be set to maCk)');
          
          // ✅ QUAN TRỌNG: Preserve chiết khấu nhập tay từ element
          // Kiểm tra cả discountByHand == 1 (database) và discountByHand == true (listOrder)
          bool hasManualDiscount = (element.discountByHand == 1 || element.discountByHand == true) && 
                                    element.discountPercentByHand != null && 
                                    element.discountPercentByHand! > 0;
          
          // ✅ QUAN TRỌNG: Kiểm tra xem có chiết khấu nhập tay được preserve không
          bool hasRestoredManualDiscount = false;
          
          SearchItemResponseData itemOrder = SearchItemResponseData(
              code: element.code,
              name: element.name,
              name2:element.name2,
              dvt: element.dvt,
              descript: element.description,
              price: element.price ,
              // ✅ QUAN TRỌNG: Preserve chiết khấu nhập tay
              discountByHand: hasManualDiscount,
              discountPercentByHand: element.discountPercentByHand ?? 0,
              ckntByHand: element.ckntByHand ?? 0, 
              discountPercent: element.discountPercent, 
              discountMoney: element.discountMoney,
              discountProduct: element.discountProduct,  
              priceOk: element.price,
              priceAfter: element.priceAfter,
              priceAfterTax:element.priceAfterTax,
              valuesTax: element.valuesTax,
              stockAmount: element.stockAmount,
              taxPercent: element.taxPercent,
              imageUrl: element.imageUrl,
              count: element.count,
              countMax: element.countMax,
              so_luong_kd: element.so_luong_kd,
              maVt2: element.maVt2,
              isMark: element.isMark,
              sttRec0: element.sttRec0,
              budgetForItem: element.budgetForItem,
              budgetForProduct: element.budgetForProduct,
              residualValueProduct: element.residualValueProduct,
              residualValue: element.residualValue,
              unit: element.unit,
              unitProduct: element.unitProduct,
              maCk: element.dsCKLineItem,
              // maCkOld: element.ma,
              listDiscount: [],
              listDiscountProduct: [],
              sttRecCK: '',
              typeCK: '',
              maVtGoc: element.maVtGoc,
              sctGoc: element.sctGoc,
              stockCode: element.codeStock,
              stockName: element.nameStock,
              idVv: element.idVv,
              nameVv: element.nameVv,
              chooseVuViec: (element.idVv.toString().isNotEmpty && element.idVv.toString() != 'null') == true ? true : false,
              isCheBien: element.isCheBien == 1 ? true :false,
              isSanXuat: element.isSanXuat == 1 ? true : false,
              giaSuaDoi: element.giaSuaDoi,
              giaGui: element.giaGui,
              priceMin: element.priceMin,
              codeUnit: element.codeUnit,
              nameUnit: element.nameUnit,
              note: element.note,
              jsonOtherInfo: element.jsonOtherInfo,
              heSo: element.heSo,
              idNVKD: element.idNVKD,
              nameNVKD: element.nameNVKD,
              nuocsx: element.nuocsx,
              quycach: element.quycach,
              maThue: element.maThue,
              tenThue: element.tenThue,
              thueSuat: element.thueSuat,
              availableQuantity: element.availableQuantity
            );
          
          // ✅ QUAN TRỌNG: Restore chiết khấu nhập tay từ preservedManualDiscounts
          // Restore TRƯỚC khi xử lý logic keyLoad == 'First' để không bị ghi đè
          String? itemCode = itemOrder.code;
          bool hasPreserved = itemCode != null && preservedManualDiscounts.containsKey(itemCode);
          print('🔍 Checking restore for ${itemCode}: preservedManualDiscounts.containsKey=$hasPreserved');
          print('🔍   - preservedManualDiscounts.keys = ${preservedManualDiscounts.keys.toList()}');
          print('🔍   - itemOrder.code = $itemCode');
          print('🔍   - element.discountByHand=${element.discountByHand}, element.discountPercentByHand=${element.discountPercentByHand}, element.ckntByHand=${element.ckntByHand}');
          
          if (hasPreserved) {
            final manualDiscount = preservedManualDiscounts[itemCode]!;
            print('🔍 BEFORE restore: discountByHand=${itemOrder.discountByHand}, discountPercentByHand=${itemOrder.discountPercentByHand}, ckntByHand=${itemOrder.ckntByHand}, priceAfter=${itemOrder.priceAfter}');
            print('🔍   - Preserved data: discountPercentByHand=${manualDiscount['discountPercentByHand']}, ckntByHand=${manualDiscount['ckntByHand']}, priceAfter=${manualDiscount['priceAfter']}');
            
            itemOrder.discountByHand = manualDiscount['discountByHand'] as bool;
            itemOrder.discountPercentByHand = manualDiscount['discountPercentByHand'] as double;
            itemOrder.ckntByHand = manualDiscount['ckntByHand'] as double;
            if (manualDiscount['priceAfter'] != null) {
              itemOrder.priceAfter = manualDiscount['priceAfter'] as double?;
            }
            hasRestoredManualDiscount = true;
            hasManualDiscount = true; // Update flag để logic sau không clear
            print('🔍 ✅ AFTER restore: discountByHand=${itemOrder.discountByHand}, discountPercentByHand=${itemOrder.discountPercentByHand}, ckntByHand=${itemOrder.ckntByHand}, priceAfter=${itemOrder.priceAfter}');
            print('🔍 ✅ hasRestoredManualDiscount=$hasRestoredManualDiscount, hasManualDiscount=$hasManualDiscount');
          } else {
            print('🔍 ⚠️ NOT restoring: itemOrder.code=$itemCode, preservedManualDiscounts.keys=${preservedManualDiscounts.keys.toList()}');
            print('🔍 ⚠️   - element.discountByHand=${element.discountByHand}, element.discountPercentByHand=${element.discountPercentByHand}');
          }
          
          if(listDiscount.isNotEmpty){
            for (var elements in listDiscount) {
              if(elements.maVt.toString().trim() == element.code.toString().trim()){
                itemOrder.listDiscount?.add(elements);
              }
              if(elements.kieuCk.toString().trim() == 'TDTH' && allowed == true){
                ListCkTongDon voucher = ListCkTongDon(
                  sttRecCk: elements.sttRecCk,
                  maCk: elements.maCk,
                  loaiCk: '',
                  tlCkTt: elements.tlCk,
                  tCkTt: 0,
                  tCkTtNt: 0,
                  gtVip: 0,
                  gtVip2: 0,
                  gtVipNt: 0,
                  gtVipNt2: 0,
                  soVoucher: '',
                  gtVocher: '',
                  tDiemSo: 0,
                  showGift: '',
                  note: '',
                  createvip: '',
                  maLoai: '',
                  capCk: elements.capCk,
                  kieuCK: elements.kieuCk,
                  isMark: elements.isMark
                );
                listCkTongDon.add(voucher);
              }
            }
            allowed = false;
          }
          if(keyLoad == 'First'){
            // ✅ CHỈ apply CKTDTT khi được tích chọn (không tự động apply nữa)
            // Logic apply CKTDTT sẽ được xử lý trong cart_screen khi user tích chọn trong DiscountVoucherSelectionSheet
            // Giữ lại logic cũ cho các loại CKTD khác (nếu có) để backward compatibility
            if(listCkTongDon.isNotEmpty){
              // Chỉ apply nếu không phải CKTDTT (CKTDTT sẽ được apply thủ công khi user tích chọn)
              final cktdItem = listCkTongDon[0];
              if(cktdItem.kieuCK != 'CKTDTT'){
                // ignore: iterable_contains_unrelated_type
                if(!listPromotion.contains(cktdItem.sttRecCk.toString().trim())){
                  listPromotion = cktdItem.sttRecCk.toString().trim();
                  codeDiscountTD = cktdItem.maCk.toString().trim();
                  sttRecCKOld = cktdItem.sttRecCk.toString().trim();
                  totalDiscountForOder = cktdItem.tCkTtNt??0;
                }
                if(!DataLocal.listCKVT.contains(cktdItem.sttRecCk.toString().trim())){
                  DataLocal.listCKVT = cktdItem.sttRecCk.toString().trim();
                }
              }
            }
          }
          if(listCkMatHang.isNotEmpty){
            for (var elements in listCkMatHang) {
              if(elements.maVt.toString().trim() == element.code.toString().trim() && elements.kieuCK.toString().trim() != 'TDTH'){
                itemOrder.listDiscountProduct?.add(elements);
              }
              else if(keyLoad != 'First' && elements.kieuCK.toString().trim() == 'TDTH' && elements.sttRecCk.toString().trim() == sttRecCKOld.toString().trim()){
                SearchItemResponseData itemTDTH = SearchItemResponseData(
                  code: elements.maHangTang,
                  name: elements.tenHangTang,
                  name2: elements.tenHangTang,
                  dvt: elements.dvt,
                  price: 0,
                  discountPercent: 0,
                  priceAfter: 0,
                  count: elements.soLuong,
                  countMax: element.countMax,
                  maVt2: element.maVt2,
                  sttRec0: element.sttRec0,
                  so_luong_kd: element.so_luong_kd,
                  isMark: element.isMark,
                  maCk: elements.maCk.toString().trim(),
                  maCkOld: elements.maCk.toString(),
                  maVtGoc: elements.maVt.toString().trim(),
                  sctGoc: elements.sttRecCk.toString().trim(),
                  sttRecCK: elements.sttRecCk.toString().trim(),
                  gifProduct: true,
                  typeCK: 'TDTH',
                    heSo: element.heSo,
                    idNVKD: element.idNVKD,
                    nameNVKD: element.nameNVKD,
                    nuocsx: element.nuocsx,
                    quycach: element.quycach,
                    contentDvt: element.contentDvt,
                    allowDvt: element.allowDvt == 1 ? true : false,
                  maThue: element.maThue,
                  tenThue: element.tenThue,
                  thueSuat: element.thueSuat.toString().replaceAll('null', '').isNotEmpty ? element.thueSuat : 0,
                );
                totalProductGift += elements.soLuong!;
                DataLocal.listProductGift.add(itemTDTH);
              }
            }
          }
          if(keyLoad == 'First'){
            // ✅ CHỈ clear maCk nếu nó rỗng hoặc 'null'
            // Giữ lại maCk từ dsCKLineItem (cho edit mode với CKG)
            String maCkValue = itemOrder.maCk?.toString().trim() ?? '';
            bool shouldClearMaCk = maCkValue.isEmpty || maCkValue == 'null';
            
            print('💰 keyLoad=First, product=${itemOrder.code}: maCk="$maCkValue", shouldClear=$shouldClearMaCk');
            
            if(shouldClearMaCk){
              itemOrder.maCk = '';
              itemOrder.maCkOld = '';
              print('💰   -> Cleared maCk');
            } else {
              print('💰   -> Kept maCk="$maCkValue"');
            }
            
            itemOrder.sttRecCK = '';
            itemOrder.typeCK = '';
            itemOrder.maVtGoc = '';
            itemOrder.sctGoc = '';
            
            // ✅ CHECK EDIT MODE: 
            // 1. Có maCk (từ dsCKLineItem) - chỉ có trong edit mode
            // 2. giaSuaDoi != price (vì trong edit mode, giaSuaDoi = priceAfter từ lineItem, còn price = giá gốc)
            // 3. priceAfter và discountPercent đã có giá trị từ lineItem
            bool isEditMode = maCkValue.isNotEmpty || 
                              (itemOrder.giaSuaDoi != null && itemOrder.price != null && 
                               itemOrder.giaSuaDoi! > 0 && itemOrder.price! > 0 && 
                               itemOrder.giaSuaDoi != itemOrder.price) ||
                              (itemOrder.priceAfter != null && itemOrder.priceAfter! > 0 && 
                               itemOrder.priceAfter != itemOrder.price && 
                               itemOrder.discountPercent != null && itemOrder.discountPercent! > 0);
            
            print('💰   - isEditMode=$isEditMode (maCk=$maCkValue, giaSuaDoi=${itemOrder.giaSuaDoi}, price=${itemOrder.price}, priceAfter=${itemOrder.priceAfter}, discountPercent=${itemOrder.discountPercent})');
            
            // ✅ QUAN TRỌNG: Ưu tiên chiết khấu nhập tay (ckntByHand)
            print('🔍 [keyLoad=First] Processing ${itemOrder.code}: hasRestoredManualDiscount=$hasRestoredManualDiscount, hasManualDiscount=$hasManualDiscount, isEditMode=$isEditMode');
            print('🔍   - BEFORE: discountByHand=${itemOrder.discountByHand}, discountPercentByHand=${itemOrder.discountPercentByHand}, ckntByHand=${itemOrder.ckntByHand}, priceAfter=${itemOrder.priceAfter}');
            
            // Nếu đã restore từ preservedManualDiscounts, không cần xử lý lại
            if (hasRestoredManualDiscount) {
              // Đã restore từ preservedManualDiscounts, chỉ cần đảm bảo priceAfter đúng
              double originalPrice = itemOrder.giaSuaDoi ?? itemOrder.price ?? 0;
              if (itemOrder.priceAfter == null || itemOrder.priceAfter == 0 || itemOrder.priceAfter! >= originalPrice) {
                itemOrder.priceAfter = originalPrice * (1 - itemOrder.discountPercentByHand! / 100);
              }
              // Tính lại ckntByHand nếu chưa có hoặc bằng 0
              if (itemOrder.ckntByHand == null || itemOrder.ckntByHand == 0) {
                double count = itemOrder.count ?? 0;
                itemOrder.ckntByHand = (originalPrice * count * itemOrder.discountPercentByHand!) / 100;
              }
              // Clear chiết khấu tự động nhưng giữ chiết khấu nhập tay
              itemOrder.discountPercent = 0;
              itemOrder.maCk = null;
              itemOrder.sttRecCK = '';
              itemOrder.typeCK = '';
              print('🔍 ✅ [CREATE MODE] Preserved restored manual discount: discountPercentByHand=${itemOrder.discountPercentByHand}, ckntByHand=${itemOrder.ckntByHand}, priceAfter=${itemOrder.priceAfter}');
            } else if (hasManualDiscount) {
              // Có chiết khấu nhập tay từ element, giữ nguyên và tính lại priceAfter nếu cần
              double originalPrice = itemOrder.giaSuaDoi ?? itemOrder.price ?? 0;
              if (itemOrder.priceAfter == null || itemOrder.priceAfter == 0) {
                itemOrder.priceAfter = originalPrice * (1 - itemOrder.discountPercentByHand! / 100);
              }
              // Tính lại ckntByHand nếu chưa có hoặc bằng 0
              if (itemOrder.ckntByHand == null || itemOrder.ckntByHand == 0) {
                double count = itemOrder.count ?? 0;
                itemOrder.ckntByHand = (originalPrice * count * itemOrder.discountPercentByHand!) / 100;
              }
              // Clear chiết khấu tự động nhưng giữ chiết khấu nhập tay
              itemOrder.discountPercent = 0;
              itemOrder.maCk = null;
              itemOrder.sttRecCK = '';
              itemOrder.typeCK = '';
              print('💰   [CREATE MODE] Preserved manual discount: discountPercentByHand=${itemOrder.discountPercentByHand}, ckntByHand=${itemOrder.ckntByHand}, priceAfter=${itemOrder.priceAfter}');
            } else if (!isEditMode) {
              // ✅ LOGIC CŨ (CREATE MODE): Clear discountPercent và set priceAfter = giaSuaDoi
              itemOrder.discountPercent = 0;
              itemOrder.priceAfter = itemOrder.giaSuaDoi;
              print('🔍 ⚠️ [CREATE MODE] Cleared discountPercent, set priceAfter = giaSuaDoi (${itemOrder.priceAfter})');
            } else {
              // ✅ LOGIC MỚI (EDIT MODE): Giữ lại discountPercent và priceAfter từ lineItem
              // KHÔNG clear, giữ nguyên giá trị đã có từ lineItem
              print('🔍 [EDIT MODE] Kept values from lineItem: discountPercent=${itemOrder.discountPercent}, priceAfter=${itemOrder.priceAfter}, giaSuaDoi=${itemOrder.giaSuaDoi}');
            }
            
            itemOrder.ck = 0;
            itemOrder.cknt = 0;
            
            print('🔍 [keyLoad=First] FINAL for ${itemOrder.code}: discountByHand=${itemOrder.discountByHand}, discountPercentByHand=${itemOrder.discountPercentByHand}, ckntByHand=${itemOrder.ckntByHand}, priceAfter=${itemOrder.priceAfter}, discountPercent=${itemOrder.discountPercent}');
            
            listOrder.add(itemOrder);
            listItemOrder.add(itemOrder);
            
            // ✅ DEBUG: Kiểm tra sau khi add vào listOrder (keyLoad=First, no discount)
            print('🔍 [keyLoad=First, no discount] Added ${itemOrder.code}: discountByHand=${itemOrder.discountByHand}, discountPercentByHand=${itemOrder.discountPercentByHand}, ckntByHand=${itemOrder.ckntByHand}');
            
            continue;
          }
          if(keyLoad == 'First' && itemOrder.listDiscount!.isNotEmpty){
            allowed = false;
            // ✅ keyLoad='First': Apply tất cả discount từ API để restore đơn cũ trong EDIT mode
            if(itemOrder.listDiscount![0].kieuCk == 'HH'){
              SearchItemResponseData itemValues = SearchItemResponseData(
                  code: (itemOrder.listDiscountProduct != null && itemOrder.listDiscountProduct!.isNotEmpty) ? itemOrder.listDiscountProduct![0].maHangTang : "",
                  name: (itemOrder.listDiscountProduct != null && itemOrder.listDiscountProduct!.isNotEmpty) ? itemOrder.listDiscountProduct![0].tenHangTang : "",
                  name2:(itemOrder.listDiscountProduct != null && itemOrder.listDiscountProduct!.isNotEmpty) ? itemOrder.listDiscountProduct![0].tenHangTang : "",
                  dvt: (itemOrder.listDiscountProduct != null && itemOrder.listDiscountProduct!.isNotEmpty) ? itemOrder.listDiscount![0].dvt : "",
                  price: 0,
                  discountPercent: 0,
                  discountPercentByHand: 0,
                  priceAfter: 0,
                  count: (itemOrder.listDiscountProduct != null && itemOrder.listDiscountProduct!.isNotEmpty) ? itemOrder.listDiscountProduct![0].soLuong : 0,
                  maCk: (itemOrder.listDiscountProduct != null && itemOrder.listDiscountProduct!.isNotEmpty) ? itemOrder.listDiscountProduct![0].maCk.toString().trim() : "",
                  maCkOld: (itemOrder.listDiscountProduct != null && itemOrder.listDiscountProduct!.isNotEmpty) ? itemOrder.listDiscountProduct![0].maCk.toString() : "",
                  maVtGoc: (itemOrder.listDiscountProduct != null && itemOrder.listDiscountProduct!.isNotEmpty) ? itemOrder.listDiscountProduct![0].maVt.toString().trim() : "",
                  sctGoc: (itemOrder.listDiscountProduct != null && itemOrder.listDiscountProduct!.isNotEmpty) ? itemOrder.listDiscountProduct![0].sttRecCk.toString().trim() : "",
                  sttRecCK: (itemOrder.listDiscountProduct != null && itemOrder.listDiscountProduct!.isNotEmpty) ? itemOrder.listDiscountProduct![0].sttRecCk.toString().trim() : "",
                  typeCK: 'HH',
                  gifProduct: true,
                  gifProductByHand: false,
                  heSo: element.heSo,
                  idNVKD: element.idNVKD,
                  nameNVKD: element.nameNVKD,
                  nuocsx: element.nuocsx,
                  quycach: element.quycach,
                  contentDvt: element.contentDvt,
                  allowDvt: element.allowDvt == 1 ? true : false,
                maThue: element.maThue,
                tenThue: element.tenThue,
                thueSuat: element.thueSuat.toString().replaceAll('null', '').isNotEmpty ? element.thueSuat : 0,
              );

              itemOrder.maCkOld = (itemOrder.listDiscountProduct != null && itemOrder.listDiscountProduct!.isNotEmpty) ? itemOrder.listDiscountProduct![0].maCk.toString() : "";
              itemOrder.sctGoc = (itemOrder.listDiscountProduct != null && itemOrder.listDiscountProduct!.isNotEmpty) ? itemOrder.listDiscountProduct![0].sttRecCk.toString() : "";
              itemOrder.maVtGoc = (itemOrder.listDiscountProduct != null && itemOrder.listDiscountProduct!.isNotEmpty) ? itemOrder.listDiscountProduct![0].maVt.toString() : "";
              itemOrder.priceAfter = 0;
              maHangTangOld = (itemOrder.listDiscountProduct != null && itemOrder.listDiscountProduct!.isNotEmpty) ? itemOrder.listDiscountProduct![0].maHangTang.toString() : "";
              codeDiscountOld = itemOrder.listDiscount![0].maCk.toString();
              listOrder.add(itemValues);
              
              // ✅ ADD gifts từ API tính chiết khấu (HH) vào DataLocal.listProductGift
              // Kiểm tra xem gift này đã có chưa (tránh duplicate)
              bool exists = DataLocal.listProductGift.any((g) => 
                g.code == itemValues.code &&
                g.typeCK == 'HH' &&
                g.sttRecCK == itemValues.sttRecCK
              );
              if (!exists && itemValues.code != null && itemValues.code!.isNotEmpty) {
                DataLocal.listProductGift.add(itemValues);
                totalProductGift += itemValues.count ?? 0;
                print('💰 Added HH gift from discount API: ${itemValues.code} - ${itemValues.name}, count: ${itemValues.count}');
              }
            }
            else if(itemOrder.listDiscount![0].kieuCk == 'VND'){
              // ✅ QUAN TRỌNG: Chỉ apply chiết khấu VND nếu KHÔNG có chiết khấu nhập tay
              if (!hasManualDiscount) {
                itemOrder.maCk = itemOrder.listDiscount![0].maCk.toString().trim();
                itemOrder.discountPercent = itemOrder.listDiscount![0].tlCk;
                itemOrder.priceAfter = itemOrder.listDiscount![0].giaSauCk;
                itemOrder.price = itemOrder.listDiscount![0].giaGoc;
                itemOrder.ck = itemOrder.listDiscount![0].ck!;
                itemOrder.maCkOld = itemOrder.listDiscount![0].maCk.toString();
                itemOrder.cknt = itemOrder.listDiscount![0].ckNt;
                itemOrder.sttRecCK = itemOrder.listDiscount![0].sttRecCk.toString().trim();
                itemOrder.typeCK =  'VND';
                itemOrder.priceOk = itemOrder.listDiscount![0].giaSauCk;
                itemOrder.sctGoc = (itemOrder.listDiscount != null && itemOrder.listDiscount!.isNotEmpty) ? itemOrder.listDiscount![0].sttRecCk.toString() : '';
                itemOrder.maVtGoc = (itemOrder.listDiscount != null && itemOrder.listDiscount!.isNotEmpty) ? itemOrder.listDiscount![0].maVt.toString() : "";
                if(itemOrder.listDiscount![0].tlCk! > 0){
                  // ✅ FIX: priceAfter là ĐƠN GIÁ, KHÔNG NHÂN count!
                  itemOrder.priceAfter = itemOrder.giaSuaDoi - (itemOrder.giaSuaDoi * itemOrder.listDiscount![0].tlCk! / 100);
                }
                /// add ck lần đầu để ghi nhận ck lần tiếp User chọn
                maHangTangOld = '';
                codeDiscountOld = itemOrder.listDiscount![0].maCk.toString();
              } else {
                print('💰 [VND] ⚠️ Skipping VND discount because manual discount exists: discountPercentByHand=${itemOrder.discountPercentByHand}');
              }
            }
            else if(itemOrder.listDiscount![0].kieuCk == 'CKG' && element.editPrice != 1){
              // ✅ QUAN TRỌNG: Chỉ apply chiết khấu CKG nếu KHÔNG có chiết khấu nhập tay
              if (!hasManualDiscount) {
                itemOrder.maCk = itemOrder.listDiscount![0].maCk.toString().trim();
                itemOrder.priceAfter = itemOrder.listDiscount![0].giaSauCk;
                itemOrder.price = itemOrder.listDiscount![0].giaGoc;
                itemOrder.ck = itemOrder.listDiscount![0].ck!;
                itemOrder.maCkOld = itemOrder.listDiscount![0].maCk.toString();
                itemOrder.cknt = itemOrder.listDiscount![0].ckNt;
                itemOrder.sttRecCK = itemOrder.listDiscount![0].sttRecCk.toString().trim();
                itemOrder.typeCK = 'CKG';
                itemOrder.priceOk = itemOrder.listDiscount![0].giaSauCk;
                itemOrder.sctGoc = (itemOrder.listDiscount != null && itemOrder.listDiscount!.isNotEmpty) ? itemOrder.listDiscount![0].sttRecCk.toString() : "";
                itemOrder.maVtGoc = (itemOrder.listDiscount != null && itemOrder.listDiscount!.isNotEmpty) ? itemOrder.listDiscount![0].maVt.toString() : "";
                // itemOrder.giaSuaDoi = itemOrder.listDiscount![0].giaSauCk!;
                double giaGoc = itemOrder.listDiscount![0].giaGoc ?? itemOrder.giaSuaDoi ?? 0;
                double giaSauCk = itemOrder.listDiscount![0].giaSauCk ?? 0;
                double ckValue = itemOrder.listDiscount![0].ck ?? 0;
                double ckNtValue = itemOrder.listDiscount![0].ckNt ?? 0;
                double tlCk = itemOrder.listDiscount![0].tlCk ?? 0;
                
                // ✅ CHECK EDIT MODE: Có maCk hoặc giaSuaDoi != price (đã được set = priceAfter)
                bool isEditMode = (itemOrder.maCk != null && itemOrder.maCk.toString().trim().isNotEmpty) ||
                                 (itemOrder.giaSuaDoi != null && itemOrder.price != null && 
                                  itemOrder.giaSuaDoi! > 0 && itemOrder.price! > 0 && 
                                  itemOrder.giaSuaDoi != itemOrder.price);
                
                // ✅ QUAN TRỌNG: Nếu có ck_nt và tl_ck = 0, tự động tính toán tỷ lệ phần trăm chiết khấu
                // CHỈ ÁP DỤNG CHO EDIT MODE
                if(tlCk > 0){
                  // Case 1: Trường hợp có tỉ lệ chiết khấu (%)
                  itemOrder.discountPercent = tlCk;
                  // ✅ FIX: priceAfter là ĐƠN GIÁ, KHÔNG NHÂN count!
                  itemOrder.priceAfter = itemOrder.giaSuaDoi - (itemOrder.giaSuaDoi * tlCk / 100);
                } else if(giaSauCk > 0 && giaSauCk != giaGoc && giaGoc > 0){
                  // Ưu tiên: Trường hợp có giá sau chiết khấu và khác giá gốc (có chiết khấu thực sự)
                  itemOrder.priceAfter = giaSauCk;
                  itemOrder.discountPercent = ((giaGoc - giaSauCk) / giaGoc) * 100;
                } else if(isEditMode && ckNtValue > 0 && giaGoc > 0 && itemOrder.count != null && itemOrder.count! > 0){
                  // ✅ EDIT MODE ONLY: Trường hợp có ck_nt (tiền chiết khấu) và tl_ck = 0, tính tỷ lệ phần trăm
                  double totalOriginalPrice = giaGoc * itemOrder.count!;
                  if (totalOriginalPrice > 0) {
                    itemOrder.discountPercent = (ckNtValue / totalOriginalPrice) * 100;
                    itemOrder.priceAfter = giaGoc - (giaGoc * itemOrder.discountPercent! / 100);
                    print('💰 [CKG API EDIT MODE] Calculated discountPercent from ckNt: $ckNtValue / $totalOriginalPrice * 100 = ${itemOrder.discountPercent}%');
                  } else {
                    itemOrder.discountPercent = 0;
                  }
                } else if(ckValue > 0){
                  // Case 2: Trường hợp có số tiền chiết khấu
                  double ckPerItem = ckValue;

                  // Nếu ck > giaGoc, có thể là tổng chiết khấu cho số lượng sản phẩm
                  // Chia ck cho số lượng sản phẩm
                  if (ckValue > giaGoc && giaGoc > 0 && itemOrder.count != null && itemOrder.count! > 0) {
                    ckPerItem = ckValue / itemOrder.count!;
                    print('💰 CKG (bloc): ck=$ckValue là tổng cho ${itemOrder.count} sản phẩm, ckPerItem=$ckPerItem');
                  }
                  
                  // Áp dụng chiết khấu nếu hợp lý (ckPerItem <= giaGoc)
                  if (ckPerItem <= giaGoc && giaGoc > 0) {
                    itemOrder.priceAfter = itemOrder.giaSuaDoi - ckPerItem;
                    if (itemOrder.priceAfter! < 0) itemOrder.priceAfter = 0;
                    itemOrder.discountPercent = (ckPerItem / giaGoc) * 100;
                  } else if (ckPerItem > giaGoc && giaGoc > 0) {
                    // Nếu ckPerItem vẫn > giaGoc, có thể là lỗi dữ liệu, nhưng vẫn tính để hiển thị
                    itemOrder.priceAfter = 0;
                    itemOrder.discountPercent = 100; // 100% discount
                    print('💰 ⚠️ WARNING (bloc): ckPerItem=$ckPerItem > giaGoc=$giaGoc, set priceAfter=0');
                  }
                }
                /// add ck lần đầu để ghi nhận ck lần tiếp User chọn
                maHangTangOld = '';
                codeDiscountOld = itemOrder.listDiscount![0].maCk.toString();
              } else {
                print('💰 [CKG] ⚠️ Skipping CKG discount because manual discount exists: discountPercentByHand=${itemOrder.discountPercentByHand}');
              }
            }
            
            // ✅ keyLoad='First': Auto-add vào listPromotion và listCKVT để restore đơn cũ
            listPromotion = listPromotion == '' ? itemOrder.listDiscount![0].sttRecCk.toString().trim() : '$listPromotion,${itemOrder.listDiscount![0].sttRecCk.toString().trim()}';
            if(DataLocal.listCKVT.contains('${itemOrder.listDiscount![0].sttRecCk.toString().trim()}-${element.code.toString().trim()}') == false){
              DataLocal.listCKVT = DataLocal.listCKVT == '' ? '${itemOrder.listDiscount![0].sttRecCk.toString().trim()}-${itemOrder.listDiscount![0].maVt.toString().trim()}' : '${DataLocal.listCKVT},${'${itemOrder.listDiscount![0].sttRecCk.toString().trim()}-${itemOrder.listDiscount![0].maVt.toString().trim()}'}';
            }
            codeDiscountSelecting  = itemOrder.listDiscount![0].sttRecCk.toString().trim();
            listOrder.add(itemOrder);
            listItemOrder.add(itemOrder);
            
            // ✅ DEBUG: Kiểm tra sau khi add vào listOrder (keyLoad=First, has discount)
            print('🔍 [keyLoad=First, has discount] Added ${itemOrder.code}: discountByHand=${itemOrder.discountByHand}, discountPercentByHand=${itemOrder.discountPercentByHand}, ckntByHand=${itemOrder.ckntByHand}');
          }
          else if(keyLoad == 'Second'){
            bool findDiscountProduct = false;
            allowed = false;
            
            // ✅ QUAN TRỌNG: CHỈ apply discount nếu có trong listCKVT
            // Check xem product này có trong listCKVT không (match với sttRecCk-maVt)
            String productCode = (itemOrder.code ?? '').trim();
            bool hasDiscountInSelection = false;
            String matchedDiscountKey = '';
            
            // Check trong listCKVT (format: "sttRecCk-maVt")
            if (DataLocal.listCKVT.isNotEmpty) {
              List<String> ckvtList = DataLocal.listCKVT.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
              for (String key in ckvtList) {
                if (key.endsWith('-$productCode')) {
                  hasDiscountInSelection = true;
                  matchedDiscountKey = key;
                  break;
                }
              }
            }
            
            print('💰 [keyLoad=Second] Product ${productCode}:');
            print('💰   - hasDiscountInSelection: $hasDiscountInSelection');
            print('💰   - matchedDiscountKey: $matchedDiscountKey');
            print('💰   - listCKVT: ${DataLocal.listCKVT}');
            
            // ✅ Nếu KHÔNG có trong selection, CLEAR discount và skip
            if (!hasDiscountInSelection) {
              print('💰 [keyLoad=Second] ⚠️ Product $productCode NOT in listCKVT, clearing discount');
              
              // ✅ QUAN TRỌNG: Clear ALL discount fields NHƯNG giữ lại chiết khấu nhập tay
              if (!hasManualDiscount) {
                itemOrder.discountPercent = 0;
                itemOrder.priceAfter = itemOrder.giaSuaDoi; // Reset về giá gốc
                itemOrder.maCk = '';
                itemOrder.sttRecCK = '';
                itemOrder.typeCK = '';
                itemOrder.ck = 0;
                itemOrder.cknt = 0;
                itemOrder.maVtGoc = '';
                itemOrder.sctGoc = '';
                
                print('💰 [keyLoad=Second] ✅ Cleared discount: priceAfter=${itemOrder.priceAfter}, discountPercent=0');
              } else {
                print('💰 [keyLoad=Second] ⚠️ Preserved manual discount: discountPercentByHand=${itemOrder.discountPercentByHand}, ckntByHand=${itemOrder.ckntByHand}');
              }
              
              listOrder.add(itemOrder);
              listItemOrder.add(itemOrder);
              
              // ✅ DEBUG: Kiểm tra sau khi add vào listOrder (keyLoad=Second, has manual discount)
              print('🔍 [keyLoad=Second, has manual discount] Added ${itemOrder.code}: discountByHand=${itemOrder.discountByHand}, discountPercentByHand=${itemOrder.discountPercentByHand}, ckntByHand=${itemOrder.ckntByHand}');
              
              continue; // Skip applying từ API response
            }
            
            // ✅ Nếu có trong selection, tiếp tục apply discount từ API response
            print('💰 [keyLoad=Second] ✅ Product $productCode IN listCKVT, applying discount from API');
            
            for(var x in itemOrder.listDiscount!){
              if( (itemOrder.sctGoc.toString().trim().isEmpty ? true : x.sttRecCk.toString().trim() == itemOrder.sctGoc.toString().trim())
                  && (x.maVt.toString().trim() == itemOrder.maVtGoc.toString().trim()) && (x.kieuCk == 'VND') ){
                itemOrder.maCk = x.maCk.toString().trim();
                itemOrder.discountPercent = x.tlCk;
                // itemOrder.priceAfter = x.giaSauCk;
                itemOrder.priceAfter = x.giaSauCk ;
                itemOrder.price = x.giaGoc;
                itemOrder.ck = x.ck!;
                itemOrder.maCkOld = x.maCk.toString();
                itemOrder.cknt = x.ckNt;
                itemOrder.sttRecCK = x.sttRecCk.toString().trim();
                itemOrder.typeCK = 'VND';
                itemOrder.priceOk = x.giaSauCk;
                if(x.tlCk! > 0){
                  // ✅ FIX: priceAfter là ĐƠN GIÁ, KHÔNG NHÂN count!
                  itemOrder.priceAfter = itemOrder.giaSuaDoi - (itemOrder.giaSuaDoi * x.tlCk! / 100);
                }
                /// add ck lần đầu để ghi nhận ck lần tiếp User chọn
                maHangTangOld = '';
                codeDiscountOld = x.maCk.toString();
              }
              else if((itemOrder.sctGoc.toString().trim().isEmpty ? true : x.sttRecCk.toString().trim() == itemOrder.sctGoc.toString().trim())
                  && (x.maVt.toString().trim() == itemOrder.maVtGoc.toString().trim()) && (x.kieuCk == 'CKG') && element.editPrice != 1 ){
                itemOrder.maCk = x.maCk.toString().trim();
                itemOrder.price = x.giaGoc;
                itemOrder.ck = x.ck!;
                itemOrder.maCkOld = x.maCk.toString();
                itemOrder.cknt = x.ckNt;
                itemOrder.sttRecCK = x.sttRecCk.toString().trim();
                itemOrder.typeCK = 'CKG';
                // itemOrder.giaSuaDoi = x.giaSauCk!;
                double giaGoc = x.giaGoc ?? itemOrder.giaSuaDoi ?? 0;
                double giaSauCk = x.giaSauCk ?? 0;
                double ckValue = x.ck ?? 0;
                double ckNtValue = x.ckNt ?? 0;
                double tlCk = x.tlCk ?? 0;
                
                // ✅ CHECK EDIT MODE: Có maCk hoặc giaSuaDoi != price (đã được set = priceAfter)
                bool isEditMode = (itemOrder.maCk != null && itemOrder.maCk.toString().trim().isNotEmpty) ||
                                 (itemOrder.giaSuaDoi != null && itemOrder.price != null && 
                                  itemOrder.giaSuaDoi! > 0 && itemOrder.price! > 0 && 
                                  itemOrder.giaSuaDoi != itemOrder.price);
                
                // ✅ DEBUG: Log để kiểm tra điều kiện
                print('💰 [CKG API Second DEBUG] Product ${itemOrder.code}:');
                print('   giaGoc=$giaGoc, giaSauCk=$giaSauCk, tlCk=$tlCk, ckNtValue=$ckNtValue, ckValue=$ckValue');
                print('   isEditMode=$isEditMode, itemOrder.count=${itemOrder.count}');
                print('   itemOrder.maCk=${itemOrder.maCk}, itemOrder.giaSuaDoi=${itemOrder.giaSuaDoi}, itemOrder.price=${itemOrder.price}');
                
                // ✅ QUAN TRỌNG: Tính priceAfter và discountPercent TRƯỚC KHI set vào itemOrder
                // Đặc biệt quan trọng khi API trả về gia_sau_ck sai (bằng gia_goc)
                double calculatedPriceAfter = giaSauCk;
                double calculatedDiscountPercent = tlCk;
                
                if(tlCk > 0){
                  // Case 1: Trường hợp có tỉ lệ chiết khấu (%)
                  calculatedDiscountPercent = tlCk;
                  // ✅ FIX: priceAfter là ĐƠN GIÁ, KHÔNG NHÂN count!
                  calculatedPriceAfter = giaGoc - (giaGoc * tlCk / 100);
                  print('💰 [CKG API Second] Case 1: Using tlCk=$tlCk%, calculatedPriceAfter=$calculatedPriceAfter');
                } else if(isEditMode && ckNtValue > 0 && giaGoc > 0){
                  // ✅ EDIT MODE PRIORITY: Ưu tiên tính từ ckNt trong edit mode (khi API trả về gia_sau_ck sai)
                  // Case 2: Trường hợp có ck_nt (tiền chiết khấu) và tl_ck = 0, tính tỷ lệ phần trăm
                  // ✅ FIX: Dùng element.count thay vì itemOrder.count (có thể null)
                  double itemCount = itemOrder.count ?? element.count ?? 0;
                  if (itemCount > 0) {
                    double totalOriginalPrice = giaGoc * itemCount;
                    if (totalOriginalPrice > 0) {
                      calculatedDiscountPercent = (ckNtValue / totalOriginalPrice) * 100;
                      calculatedPriceAfter = giaGoc - (giaGoc * calculatedDiscountPercent / 100);
                      print('💰 [CKG API EDIT MODE Second] ✅ Calculated from ckNt: ckNt=$ckNtValue, totalOriginalPrice=$totalOriginalPrice (giaGoc=$giaGoc * count=$itemCount), discountPercent=$calculatedDiscountPercent%, priceAfter=$calculatedPriceAfter');
                    } else {
                      calculatedDiscountPercent = 0;
                      calculatedPriceAfter = giaGoc;
                      print('💰 [CKG API EDIT MODE Second] ⚠️ totalOriginalPrice=0, cannot calculate');
                    }
                  } else {
                    calculatedDiscountPercent = 0;
                    calculatedPriceAfter = giaGoc;
                    print('💰 [CKG API EDIT MODE Second] ⚠️ itemCount=0 (itemOrder.count=${itemOrder.count}, element.count=${element.count}), cannot calculate');
                  }
                } else if(giaSauCk > 0 && giaSauCk != giaGoc && giaGoc > 0){
                  // Case 3: Trường hợp có giá sau chiết khấu và khác giá gốc (có chiết khấu thực sự)
                  calculatedPriceAfter = giaSauCk;
                  calculatedDiscountPercent = ((giaGoc - giaSauCk) / giaGoc) * 100;
                  print('💰 [CKG API Second] Case 3: Using giaSauCk=$giaSauCk, calculatedDiscountPercent=$calculatedDiscountPercent%');
                } else if(ckValue > 0){
                  // Case 2: Trường hợp có số tiền chiết khấu
                  double ckPerItem = ckValue;
                  
                  // Nếu ck > giaGoc, có thể là tổng chiết khấu cho số lượng sản phẩm
                  // Chia ck cho số lượng sản phẩm
                  if (ckValue > giaGoc && giaGoc > 0 && itemOrder.count != null && itemOrder.count! > 0) {
                    ckPerItem = ckValue / itemOrder.count!;
                    print('💰 CKG (bloc): ck=$ckValue là tổng cho ${itemOrder.count} sản phẩm, ckPerItem=$ckPerItem');
                  }
                  
                  // Áp dụng chiết khấu nếu hợp lý (ckPerItem <= giaGoc)
                  if (ckPerItem <= giaGoc && giaGoc > 0) {
                    calculatedPriceAfter = giaGoc - ckPerItem;
                    if (calculatedPriceAfter < 0) calculatedPriceAfter = 0;
                    calculatedDiscountPercent = (ckPerItem / giaGoc) * 100;
                  } else if (ckPerItem > giaGoc && giaGoc > 0) {
                    // Nếu ckPerItem vẫn > giaGoc, có thể là lỗi dữ liệu, nhưng vẫn tính để hiển thị
                    calculatedPriceAfter = 0;
                    calculatedDiscountPercent = 100; // 100% discount
                    print('💰 ⚠️ WARNING (bloc): ckPerItem=$ckPerItem > giaGoc=$giaGoc, set priceAfter=0');
                  }
                }
                
                // ✅ QUAN TRỌNG: Set priceAfter và discountPercent vào itemOrder SAU KHI đã tính xong
                itemOrder.priceAfter = calculatedPriceAfter;
                itemOrder.discountPercent = calculatedDiscountPercent;
                itemOrder.priceOk = calculatedPriceAfter;
                
                print('💰 [CKG API Second] Final values for ${itemOrder.code}: price=$giaGoc, priceAfter=$calculatedPriceAfter, discountPercent=$calculatedDiscountPercent%');
                /// add ck lần đầu để ghi nhận ck lần tiếp User chọn
                maHangTangOld = '';
                codeDiscountOld = x.maCk.toString();
              }
              else if((itemOrder.sctGoc.toString().trim().isEmpty ? true : x.sttRecCk.toString().trim() == itemOrder.sctGoc.toString().trim())
                  && (x.maVt.toString().trim() == itemOrder.maVtGoc.toString().trim()) && x.kieuCk == 'HH'){
                findDiscountProduct = true;
                codeDiscountSelecting = itemOrder.sctGoc.toString().trim();
                itemOrder.priceAfter = itemOrder.price;
                itemOrder.discountPercent = 0;
              }
              else if((itemOrder.sctGoc.toString().trim().isEmpty ? true : x.sttRecCk.toString().trim() == itemOrder.sctGoc.toString().trim())
                  && (x.maVt.toString().trim() == itemOrder.maVtGoc.toString().trim())){
                  itemOrder.maCkOld = x.maCk.toString();
              }
            }
            if(findDiscountProduct == true){
              for(var y in itemOrder.listDiscountProduct!){
                if(y.sttRecCk.toString().trim() == codeDiscountSelecting){
                  itemOrder.maCkOld = y.maCk.toString();
                  itemOrder.priceAfter = /*itemOrder.giaGui > 0 ? itemOrder.giaGui :*/ itemOrder.giaSuaDoi;
                  }
              }
            }
            listOrder.add(itemOrder);
            listItemOrder.add(itemOrder);
            
            // ✅ DEBUG: Kiểm tra sau khi add vào listOrder (keyLoad=Second, applied discount)
            print('🔍 [keyLoad=Second, applied discount] Added ${itemOrder.code}: discountByHand=${itemOrder.discountByHand}, discountPercentByHand=${itemOrder.discountPercentByHand}, ckntByHand=${itemOrder.ckntByHand}');
          }
          else if(keyLoad == 'First' && itemOrder.listDiscount!.isEmpty){
            listOrder.add(itemOrder);
            listItemOrder.add(itemOrder);
            
            // ✅ DEBUG: Kiểm tra sau khi add vào listOrder (keyLoad=First, empty discount)
            print('🔍 [keyLoad=First, empty discount] Added ${itemOrder.code}: discountByHand=${itemOrder.discountByHand}, discountPercentByHand=${itemOrder.discountPercentByHand}, ckntByHand=${itemOrder.ckntByHand}');
          }
        }
        
        // ✅ DEBUG: Kiểm tra chiết khấu nhập tay sau khi build xong listOrder
        print('🔍 ========== AFTER BUILDING listOrder (keyLoad=$keyLoad) ==========');
        print('🔍 listOrder.length = ${listOrder.length}');
        int manualDiscountCountAfter = 0;
        for (var item in listOrder) {
          if (item.discountByHand == true && (item.discountPercentByHand ?? 0) > 0) {
            manualDiscountCountAfter++;
            print('🔍 ✅ Product ${item.code}: discountByHand=${item.discountByHand}, discountPercentByHand=${item.discountPercentByHand}, ckntByHand=${item.ckntByHand}, priceAfter=${item.priceAfter}');
          }
        }
        print('🔍 Total manual discount after building: $manualDiscountCountAfter');
        print('🔍 ================================================================');
        
        if(keyLoad != 'First'){
          listOrder.clear();
          for (var elementDiscount in listItemOrder) {
            listOrder.add(elementDiscount);
            for (var elementProduct in listCheckCKMH) {
              if((elementDiscount.sctGoc.toString().trim().isEmpty ? true : elementProduct.sttRecCk.toString().trim() == elementDiscount.sctGoc.toString().trim()) &&
                  elementDiscount.code.toString().trim() == elementProduct.maVt.toString().trim()){
                SearchItemResponseData itemValues = SearchItemResponseData(
                    code: elementProduct.maHangTang,
                    name: elementProduct.tenHangTang,
                    name2: elementProduct.tenHangTang,
                    dvt: elementProduct.dvt,
                    price: 0,
                    discountPercent: 0,
                    priceAfter: 0,
                    count: elementProduct.soLuong,
                    maCk: elementProduct.maCk.toString().trim(),
                    maCkOld: elementProduct.maCk.toString(),
                    maVtGoc: elementProduct.maVt.toString().trim(),
                    sctGoc: elementProduct.sttRecCk.toString().trim(),
                    sttRecCK: elementProduct.sttRecCk.toString().trim(),
                    typeCK: 'HH',
                    gifProduct: true,
                    gifProductByHand: false,
                    // priceOk:  elementProduct
                );
                listOrder.add(itemValues);
                
                // ✅ ADD gifts từ API tính chiết khấu (HH) vào DataLocal.listProductGift khi keyLoad != 'First'
                // Kiểm tra xem gift này đã có chưa (tránh duplicate)
                bool exists = DataLocal.listProductGift.any((g) => 
                  g.code == itemValues.code &&
                  g.typeCK == 'HH' &&
                  g.sttRecCK == itemValues.sttRecCK
                );
                if (!exists && itemValues.code != null && itemValues.code!.isNotEmpty) {
                  DataLocal.listProductGift.add(itemValues);
                  totalProductGift += itemValues.count ?? 0;
                  print('💰 Added HH gift from discount API (keyLoad != First): ${itemValues.code} - ${itemValues.name}, count: ${itemValues.count}');
                }
              }
            }
          }
        }
      }
      allowed = false;
      if(keyLoad == 'First'){
        double baseTotal = 0;
        for (var elementDiscount in listOrder) {
          if(elementDiscount.gifProduct == true) continue;
          final double unitPrice = (elementDiscount.giaSuaDoi as num?)?.toDouble()
              ?? (elementDiscount.price as num?)?.toDouble()
              ?? (elementDiscount.priceAfter as num?)?.toDouble()
              ?? 0;
          final double quantity = (elementDiscount.count as num?)?.toDouble() ?? 0;
          baseTotal += unitPrice * quantity;
        }
        totalMoney = baseTotal;
        totalDiscount = 0;
        totalDiscountOldByHand = 0;
        totalDiscountOld = 0;
        totalPayment = baseTotal;
        totalPaymentOld = baseTotal;
        totalMNProduct = baseTotal;
        totalMNDiscount = 0;
        totalMNPayment = baseTotal;
      }else{
        final totalMoneyDiscount = response.totalMoneyDiscount;
        totalMoney =  totalMoneyDiscount?.tTien??0;
        totalDiscount =  totalMoneyDiscount?.tCk??0;
        totalDiscountOldByHand =  totalMoneyDiscount?.tCk??0;
        totalDiscountOld =  totalMoneyDiscount?.tCk??0;
        totalPayment =  totalMoneyDiscount?.tThanhToan??0;
        totalPaymentOld =  totalMoneyDiscount?.tThanhToan??0;
        totalMNProduct = totalMoneyDiscount?.tTien ?? 0;
        totalMNDiscount = totalMoneyDiscount?.tCk ?? 0;
        totalMNPayment = totalMoneyDiscount?.tThanhToan ?? 0;
        
        // ✅ Cập nhật totalDiscountForOder từ listCkTongDon nếu có CKTDTT được chọn
        // ✅ CỘNG DỒN tất cả CKTDTT đã chọn thay vì chỉ lấy 1
        if (response.listCkTongDon != null && response.listCkTongDon!.isNotEmpty) {
          double totalDiscount = 0;
          List<String> codeDiscountList = [];
          
          // ✅ Duyệt qua TẤT CẢ CKTDTT đã được chọn và cộng dồn
          for (var cktdttItem in response.listCkTongDon!) {
            String sttRecCk = (cktdttItem.sttRecCk ?? '').trim();
            if (cktdttItem.kieuCK == 'CKTDTT' && selectedCktdttIds.contains(sttRecCk)) {
              double discountAmount = cktdttItem.tCkTtNt ?? 0;
              totalDiscount += discountAmount;
              
              String maCk = (cktdttItem.maCk ?? '').trim();
              if (maCk.isNotEmpty && !codeDiscountList.contains(maCk)) {
                codeDiscountList.add(maCk);
              }
              
              print('💰 CKTDTT: Found selected discount - sttRecCk=$sttRecCk, tCkTtNt=$discountAmount, running total=$totalDiscount');
            }
          }
          
          // ✅ Cập nhật totalDiscountForOder với tổng của tất cả CKTDTT
          if (totalDiscount > 0) {
            totalDiscountForOder = totalDiscount;
            codeDiscountTD = codeDiscountList.isNotEmpty ? codeDiscountList.first : '';
            print('💰 CKTDTT: Updated from API response - totalDiscountForOder=$totalDiscountForOder (sum of ${selectedCktdttIds.length} discounts), codeDiscountTD=$codeDiscountTD');
            
            // ✅ QUAN TRỌNG: API có thể chưa tính CKTDTT vào tThanhToan, nên cần trừ thủ công
            // Trừ tổng chiết khấu vào totalPayment
            totalPayment = totalPayment - totalDiscountForOder;
            totalPaymentOld = totalPayment;
            totalMNPayment = totalPayment;
            print('💰 CKTDTT: Trừ chiết khấu tổng đơn vào totalPayment: ${totalMoneyDiscount?.tThanhToan} - $totalDiscountForOder = $totalPayment');
          } else if (selectedCktdttIds.isNotEmpty) {
            // ✅ Nếu có selectedCktdttIds nhưng không tìm thấy trong response, giữ nguyên giá trị hiện tại
            print('💰 CKTDTT: Selected ${selectedCktdttIds.length} discounts but not found in API response, keeping current totalDiscountForOder=$totalDiscountForOder');
          }
        } else {
          // ✅ Nếu không có CKTDTT trong response nhưng đang có selectedCktdttIds, reset totalDiscountForOder
          if (selectedCktdttIds.isEmpty) {
            totalDiscountForOder = 0;
            codeDiscountTD = '';
            print('💰 CKTDTT: No CKTDTT selected, reset totalDiscountForOder=0');
          } else {
            // ✅ Nếu có selectedCktdttIds nhưng response không có, giữ nguyên giá trị hiện tại
            print('💰 CKTDTT: Selected ${selectedCktdttIds.length} discounts but API response is empty, keeping current totalDiscountForOder=$totalDiscountForOder');
          }
        }
      }
      
      // ✅ Tính và set ck_dac_biet sau khi apply discount
      // Helper function để tính ck_dac_biet từ các chiết khấu đã chọn
      int? calculateCkDacBietFromSelected() {
        // Check CKG đã chọn
        for (var ckgItem in listCkg) {
          String maCk = (ckgItem.maCk ?? '').trim();
          if (maCk.isNotEmpty && selectedCkgIds.contains(maCk)) {
            final ckDacBietValue = ckgItem.ck_dac_biet;
            if (ckDacBietValue != null) {
              int? ckDacBietInt;
              if (ckDacBietValue is int) {
                ckDacBietInt = ckDacBietValue;
              } else if (ckDacBietValue is String && ckDacBietValue.trim().isNotEmpty) {
                ckDacBietInt = int.tryParse(ckDacBietValue);
              } else if (ckDacBietValue is num) {
                ckDacBietInt = ckDacBietValue.toInt();
              }
              
              if (ckDacBietInt == 1) {
                print('💰 ✅ Found CKG with ck_dac_biet = 1: maCk=$maCk, sttRecCk=${ckgItem.sttRecCk}');
                return 1;
              }
            }
          }
        }
        
        // ✅ Check HH đã chọn hoặc tự động áp dụng
        for (var hhItem in listHH) {
          String sttRecCk = (hhItem.sttRecCk ?? '').trim();
          
          // HH được tự động áp dụng hoặc user đã chọn
          // Check nếu HH có trong selectedHHIds hoặc được tự động áp dụng (có trong listPromotion string)
          bool isHHSelected = selectedHHIds.contains(sttRecCk);
          bool isHHAutoApplied = listPromotion.isNotEmpty && 
                                 (listPromotion == sttRecCk || 
                                  listPromotion.startsWith('$sttRecCk,') || 
                                  listPromotion.contains(',$sttRecCk,') || 
                                  listPromotion.endsWith(',$sttRecCk'));
          
          if (isHHSelected || isHHAutoApplied) {
            final ckDacBietValue = hhItem.ck_dac_biet;
            if (ckDacBietValue != null) {
              int? ckDacBietInt;
              if (ckDacBietValue is int) {
                ckDacBietInt = ckDacBietValue;
              } else if (ckDacBietValue is String && ckDacBietValue.trim().isNotEmpty) {
                ckDacBietInt = int.tryParse(ckDacBietValue);
              } else if (ckDacBietValue is num) {
                ckDacBietInt = ckDacBietValue.toInt();
              }
              
              if (ckDacBietInt == 1) {
                print('💰 ✅ Found HH with ck_dac_biet = 1: sttRecCk=$sttRecCk, maCk=${hhItem.maCk}');
                return 1;
              }
            }
          }
        }
        
        // Check CKTDTT đã chọn
        for (var cktdttItem in listCktdtt) {
          String sttRecCk = (cktdttItem.sttRecCk ?? '').trim();
          String cktdttId = sttRecCk;
          
          if (selectedCktdttIds.contains(cktdttId)) {
            final ckDacBietValue = cktdttItem.ck_dac_biet;
            if (ckDacBietValue != null) {
              int? ckDacBietInt;
              if (ckDacBietValue is int) {
                ckDacBietInt = ckDacBietValue;
              } else if (ckDacBietValue is String && ckDacBietValue.trim().isNotEmpty) {
                ckDacBietInt = int.tryParse(ckDacBietValue);
              } else if (ckDacBietValue is num) {
                ckDacBietInt = ckDacBietValue.toInt();
              }
              
              if (ckDacBietInt == 1) {
                print('💰 ✅ Found CKTDTT with ck_dac_biet = 1: cktdttId=$cktdttId, sttRecCk=$sttRecCk');
                return 1;
              }
            }
          }
        }
        
        return 0;
      }
      
      // ✅ Set ck_dac_biet vào bloc để UI có thể sử dụng ngay
      ck_dac_biet = calculateCkDacBietFromSelected();
      if (ck_dac_biet == 1) {
        print('💰 ✅ Set bloc.ck_dac_biet = 1 (after apply discount)');
      } else {
        print('💰 ℹ️ Set bloc.ck_dac_biet = 0 (after apply discount)');
      }
      // ✅ RESTORE CKN và CKTDTH gifts sau khi xử lý response (keyLoad == 'Second')
      if(keyLoad == 'Second'){
        // Remove only HH gifts (từ response), preserve CKN, CKTDTH và manual gifts
        DataLocal.listProductGift.removeWhere((gift) => gift.typeCK == 'HH');
        
        // Restore preserved CKN gifts
        for (var gift in preservedCknGifts) {
          // Check if not already exists
          bool exists = DataLocal.listProductGift.any((g) => 
            g.code == gift.code && 
            g.typeCK == gift.typeCK && 
            g.sttRecCK == gift.sttRecCK
          );
          if (!exists) {
            DataLocal.listProductGift.add(gift);
            totalProductGift += gift.count ?? 0;
            print('💰 Restored CKN gift: ${gift.code} (qty: ${gift.count})');
          }
        }
        
        // Restore preserved CKTDTH gifts
        for (var gift in preservedCktdthGifts) {
          // Check if not already exists
          bool exists = DataLocal.listProductGift.any((g) => 
            g.code == gift.code && 
            g.typeCK == gift.typeCK && 
            g.sttRecCK == gift.sttRecCK
          );
          if (!exists) {
            DataLocal.listProductGift.add(gift);
            totalProductGift += gift.count ?? 0;
            print('💰 Restored CKTDTH gift: ${gift.code} (qty: ${gift.count})');
          }
        }
        
        // Restore preserved manual gifts (từ cả First và Second)
        final List<SearchItemResponseData> manualToRestore = [
          ...preservedManualGiftsAlways, // luôn giữ quà nhập tay
          ...preservedManualGiftsFirst,
          ...preservedManualGifts,
        ];
        for (var gift in manualToRestore) {
          // Check if not already exists
          bool exists = DataLocal.listProductGift.any((g) => 
            g.code == gift.code && 
            g.gifProductByHand == true
          );
          if (!exists) {
            DataLocal.listProductGift.add(gift);
            totalProductGift += gift.count ?? 0;
            print('💰 Restored manual gift: ${gift.code} (qty: ${gift.count})');
          }
        }
        
        // ✅ RESTORE gifts từ chi tiết đơn hàng (khi keyLoad == 'Second')
        for (var gift in preservedGiftsFromOrderDetail) {
          bool exists = DataLocal.listProductGift.any((g) => 
            g.code == gift.code && 
            g.gifProductByHand == false &&
            (g.typeCK == null || g.typeCK == '')
          );
          if (!exists) {
            DataLocal.listProductGift.add(gift);
            totalProductGift += gift.count ?? 0;
            print('💰 Restored gift from order detail (Second): ${gift.code} (qty: ${gift.count})');
          }
        }
        
        // ✅ Tính lại totalProductGift từ DataLocal.listProductGift để đảm bảo chính xác
        totalProductGift = 0;
        for (var gift in DataLocal.listProductGift) {
          totalProductGift += gift.count ?? 0;
        }
        print('💰 After restore (Second): totalProductGift=$totalProductGift, listProductGift.length=${DataLocal.listProductGift.length}');
        
        // ✅ RESTORE listPromotion và DataLocal.listCKVT để không mất các chiết khấu đã chọn trước đó
        // Merge với các giá trị từ response (nếu có)
        if (preservedListPromotion.isNotEmpty) {
          // Merge: giữ lại các sttRecCk từ preserved, thêm các sttRecCk mới từ response (nếu chưa có)
          List<String> preservedPromoList = preservedListPromotion.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          List<String> currentPromoList = listPromotion.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          
          // Combine: preserved + current (loại bỏ duplicate)
          Set<String> combinedPromoSet = {...preservedPromoList, ...currentPromoList};
          listPromotion = combinedPromoSet.join(',');
          print('💰 Restored listPromotion: $listPromotion (preserved: $preservedListPromotion)');
        }
        
        if (preservedListCKVT.isNotEmpty) {
          // Merge: giữ lại các discountKey từ preserved, thêm các discountKey mới từ response (nếu chưa có)
          List<String> preservedCkvtList = preservedListCKVT.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          List<String> currentCkvtList = DataLocal.listCKVT.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          
          // Combine: preserved + current (loại bỏ duplicate)
          Set<String> combinedCkvtSet = {...preservedCkvtList, ...currentCkvtList};
          DataLocal.listCKVT = combinedCkvtSet.join(',');
          print('💰 Restored listCKVT: ${DataLocal.listCKVT} (preserved: $preservedListCKVT)');
        }
      }
      
      // 🔄 Always restore manual gifts (applies to both First and Second)
      final List<SearchItemResponseData> manualToRestoreAlways = [
        ...preservedManualGiftsAlways, // backup từ đầu
        ...preservedManualGiftsFirst,
        ...preservedManualGifts,
      ];
      for (var gift in manualToRestoreAlways) {
        bool exists = DataLocal.listProductGift.any((g) =>
          g.code == gift.code &&
          g.gifProductByHand == true
        );
        if (!exists) {
          DataLocal.listProductGift.add(gift);
          totalProductGift += gift.count ?? 0;
          print('💰 Restored manual gift (always): ${gift.code} (qty: ${gift.count})');
        }
      }
      
      // ✅ Always restore gifts từ chi tiết đơn hàng (applies to both First and Second)
      for (var gift in preservedGiftsFromOrderDetail) {
        bool exists = DataLocal.listProductGift.any((g) =>
          g.code == gift.code &&
          g.gifProductByHand == false &&
          (g.typeCK == null || g.typeCK == '')
        );
        if (!exists) {
          DataLocal.listProductGift.add(gift);
          totalProductGift += gift.count ?? 0;
          print('💰 Restored gift from order detail (Always): ${gift.code} (qty: ${gift.count})');
        }
      }
      // ✅ Tính lại totalProductGift từ DataLocal.listProductGift để đảm bảo chính xác
      totalProductGift = 0;
      for (var gift in DataLocal.listProductGift) {
        totalProductGift += gift.count ?? 0;
      }
      print('💰 After restore ALL gifts: totalProductGift=$totalProductGift, listProductGift.length=${DataLocal.listProductGift.length}');

      // ✅ QUAN TRỌNG: Tính lại totalDiscount và totalPayment sau khi restore chiết khấu nhập tay
      // Đảm bảo tổng chiết khấu và tổng tiền được tính lại chính xác
      totalMoney = 0;
      totalDiscount = 0;
      totalPayment = 0;
      
      for (var item in listOrder) {
        if (item.gifProduct == true) continue; // Bỏ qua quà tặng
        
        double itemPrice = item.giaSuaDoi ?? item.price ?? 0;
        double itemCount = item.count ?? 0;
        double itemTotal = itemPrice * itemCount;

        // ✅ FREE DISCOUNT: nếu chiết khấu nhập tay = 0 thì reset ckntByHand & priceAfter
        if (Const.freeDiscount == true &&
            item.discountByHand == true &&
            (item.discountPercentByHand ?? 0) <= 0) {
          item.discountPercentByHand = 0;
          item.ckntByHand = 0;
          item.discountPercent = 0;
          item.ck = 0;
          item.cknt = 0;
          item.priceAfter = itemPrice;
          item.priceAfter2 = itemPrice;
        }
        
        totalMoney += itemTotal;
        
        // Tính chiết khấu: ưu tiên ckntByHand (chiết khấu nhập tay)
        double itemDiscount = 0;
        if (item.discountByHand == true && (item.ckntByHand ?? 0) > 0) {
          // Chiết khấu nhập tay
          itemDiscount = item.ckntByHand ?? 0;
          print('💰 Calculating discount for ${item.code}: ckntByHand=${item.ckntByHand} (manual)');
        } else if (item.discountByHand == true && (item.discountPercentByHand ?? 0) > 0) {
          // Tính từ discountPercentByHand
          itemDiscount = (itemPrice * itemCount * item.discountPercentByHand!) / 100;
          item.ckntByHand = itemDiscount; // Update ckntByHand
          print('💰 Calculating discount for ${item.code}: discountPercentByHand=${item.discountPercentByHand}%, calculated=${itemDiscount}');
        } else if (item.discountByHand == true && (item.discountPercentByHand ?? 0) == 0) {
          // FREE DISCOUNT: percent = 0 => reset về giá gốc, không chiết khấu
          item.discountPercentByHand = 0;
          item.ckntByHand = 0;
          item.discountPercent = 0;
          item.ck = 0;
          item.cknt = 0;
          item.priceAfter = itemPrice;
          item.priceAfter2 = itemPrice;
          print('💰 Reset manual discount for ${item.code}: percent=0, ckntByHand=0, priceAfter=$itemPrice');
          itemDiscount = 0;
        } else if (item.cknt != null && item.cknt! > 0) {
          // Chiết khấu tự động
          itemDiscount = item.cknt!;
          print('💰 Calculating discount for ${item.code}: cknt=${item.cknt} (auto)');
        } else if (item.discountPercent != null && item.discountPercent! > 0) {
          // Tính từ discountPercent
          itemDiscount = (itemPrice * itemCount * item.discountPercent!) / 100;
          print('💰 Calculating discount for ${item.code}: discountPercent=${item.discountPercent}%, calculated=${itemDiscount}');
        }
        
        totalDiscount += itemDiscount;
      }
      
      // ✅ FIX: Tính totalPayment = totalMoney + totalTax - totalDiscount - totalDiscountForOder
      // để đảm bảo tính toán đúng, bao gồm cả chiết khấu tổng đơn (manual total discount)
      totalPayment = totalMoney + totalTax - totalDiscount - (totalDiscountForOder ?? 0);
      if (totalPayment < 0) totalPayment = 0;

      // ✅ REMOVED: Manual total discount calculation moved to _calculatorDiscountEvent
      // để đảm bảo tính toán nhất quán và tránh xung đột
      // Manual total discount sẽ được tính trong _calculatorDiscountEvent khi được trigger
      
      print('💰 ========== RECALCULATED TOTALS (keyLoad=$keyLoad) ==========');
      print('💰 totalMoney = $totalMoney');
      print('💰 totalDiscount = $totalDiscount');
      print('💰 totalDiscountForOder = ${totalDiscountForOder ?? 0}');
      print('💰 totalTax = $totalTax');
      print('💰 totalPayment = $totalMoney + $totalTax - $totalDiscount - ${totalDiscountForOder ?? 0} = $totalPayment');
      print('💰 ============================================================');

      print('check tax ${keyLoad} => ${ Const.useTax} ${DataLocal.indexValuesTax} ${allowed2 = true}');
      if(keyLoad == 'Second' && Const.useTax == true && DataLocal.indexValuesTax >= 0 && allowed2 == true){
        allowed2 = false;
        allowTaxPercent = true;
        calculatorTax();
      }
      return ApplyDiscountSuccess(keyLoad);
    }catch(e){
      return CartFailure('Úi, ${e.toString()}');
    }
  }

  CartState _handleCalculator(Object data, bool viewUpdateOrder,bool addNewItem,bool reCalculator, {List<SearchItemResponseData>? preservedGiftsFromOrderDetail}){
    if (data is String) return CartFailure('Úi,${data.toString()}');
    try{
      // ✅ PRESERVE gifts từ chi tiết đơn hàng trước khi xử lý response
      // Nếu không được truyền vào từ _checkDisCountWhenUpdateEvent, lấy từ DataLocal
      List<SearchItemResponseData> giftsToPreserve = preservedGiftsFromOrderDetail ?? 
        DataLocal.listProductGift.where((gift) => 
          gift.gifProduct == true && 
          gift.gifProductByHand == false && 
          (gift.typeCK == null || gift.typeCK == '')
        ).toList();
      
      print('💰 _handleCalculator: Preserving ${giftsToPreserve.length} gifts from order detail');
      for (var gift in giftsToPreserve) {
        print('  - Gift to preserve: ${gift.code} - ${gift.name}, count: ${gift.count}');
      }
      
      if(listCodeDisCount?.isNotEmpty == true){
        listCodeDisCount?.clear();
      }
      CartResponse response = CartResponse.fromJson(data as Map<String,dynamic>);
      List<LineItem>? lineItem = response.data?.lineItem;
      listDiscountName = response.data?.order?.dsCk!;
      listDiscountName?.forEach((element) {
        if(listCodeDisCount!.isEmpty){
          listCodeDisCount?.add(element.maCk.toString());
        }
        else {
          listCodeDisCount?.add(element.maCk.toString());
        }
      });
      if(viewUpdateOrder == false){
        for(int i = 0; i < lineItem!.length; i++){
          List<String> itemCodeDiscountInLine = [];
          if(listProductOrder.isNotEmpty){
            final valueItem = listProductOrder.firstWhere((item) => item.code ==  lineItem[i].maVt,);
            if (valueItem != null) {
              int indexWithStart =  listProductOrder.indexWhere((element) => element.code == valueItem.code);
              //itemCodeDiscountInLine.clear();
              if(!Utils.isEmpty(lineItem[i].maCk.toString())){
                itemCodeDiscountInLine.add(lineItem[i].maCk.toString());
              }
              if(!Utils.isEmpty(lineItem[i].discountProductCode.toString())){
                itemCodeDiscountInLine.add(lineItem[i].discountProductCode.toString());
              }
              Product production = Product(
                  code: listProductOrder[indexWithStart].code,
                  name: listProductOrder[indexWithStart].name,
                  name2:listProductOrder[indexWithStart].name2,
                  dvt: listProductOrder[indexWithStart].dvt,
                  description: listProductOrder[indexWithStart].description,
                  price: listProductOrder[indexWithStart].price,
                  discountPercent: listProductOrder[indexWithStart].discountPercent,
                  priceAfter: listProductOrder[indexWithStart].priceAfter,
                  stockAmount: listProductOrder[indexWithStart].stockAmount,
                  taxPercent: listProductOrder[indexWithStart].taxPercent,
                  imageUrl: listProductOrder[indexWithStart].imageUrl,
                  count: listProductOrder[indexWithStart].count,
                  countMax: listProductOrder[indexWithStart].countMax,
                  maVt2: listProductOrder[indexWithStart].maVt2,
                  sttRec0: listProductOrder[indexWithStart].sttRec0,
                  so_luong_kd: listProductOrder[indexWithStart].so_luong_kd,
                  isMark:0,
                  discountMoney: lineItem[i].tenCk,
                  discountProduct: lineItem[i].discountProduct,
                  budgetForItem: lineItem[i].nganSach,
                  budgetForProduct: lineItem[i].nganSachSp,
                  residualValueProduct: lineItem[i].nganSachProduct,
                  residualValue: lineItem[i].residualValue,
                  unit: lineItem[i].unit,
                  unitProduct: lineItem[i].unitProduct,
                  dsCKLineItem: itemCodeDiscountInLine.join(','),
                  kColorFormatAlphaB:listProductOrder[indexWithStart].kColorFormatAlphaB,
                  codeStock: listProductOrder[indexWithStart].codeStock.toString(),
                  nameStock: listProductOrder[indexWithStart].nameStock.toString(),
                  giaGui: listProductOrder[indexWithStart].giaGui,
                  giaSuaDoi: listProductOrder[indexWithStart].giaSuaDoi,
                  isCheBien: listProductOrder[indexWithStart].isCheBien,
                  isSanXuat: listProductOrder[indexWithStart].isSanXuat,
                  note: listProductOrder[indexWithStart].note,
                  jsonOtherInfo: listProductOrder[indexWithStart].jsonOtherInfo
              );
              db.updateProduct(production,listProductOrder[indexWithStart].codeStock.toString(),false);
            }
          }
        }
      }
      else{
        // ✅ EDIT MODE: Preserve chiết khấu byhand trước khi match từ lineItem
        // Map để lưu chiết khấu byhand theo code sản phẩm
        Map<String, Map<String, dynamic>> preservedManualDiscounts = {};
        for (var element in listProductOrderAndUpdate) {
          if (element.discountByHand == 1 && 
              (element.discountPercentByHand ?? 0) > 0 && 
              element.code != null && 
              element.code.toString().trim().isNotEmpty) {
            preservedManualDiscounts[element.code.toString()] = {
              'discountByHand': 1,
              'discountPercentByHand': element.discountPercentByHand ?? 0,
              'ckntByHand': element.ckntByHand ?? 0,
              'priceAfter': element.priceAfter,
            };
            print('🔍 [EDIT MODE] Preserving manual discount for ${element.code}: discountPercentByHand=${element.discountPercentByHand}, ckntByHand=${element.ckntByHand}');
          }
        }
        
        for(int i = 0; i < lineItem!.length; i++){
          List<String> itemCodeDiscountInLine = [];
          if(_lineItemOrder.isNotEmpty){
            final valueItem = _lineItemOrder.firstWhere((item) => item.code ==  lineItem[i].maVt,);
            if (valueItem != null) {
              // final indexWithStart = _lineItemOrder.indexOf(valueItem);
              int indexWithStart =  _lineItemOrder.indexWhere((element) => element.code == valueItem.code);
              
              // ✅ Kiểm tra index hợp lệ trước khi truy cập
              if(indexWithStart >= 0 && indexWithStart < listProductOrderAndUpdate.length){
                // ✅ LOGIC CŨ: Match chiết khấu từ lineItem (giữ nguyên)
                listProductOrderAndUpdate[indexWithStart].discountMoney = lineItem[i].tenCk;
                listProductOrderAndUpdate[indexWithStart].discountProduct = lineItem[i].discountProduct;
                listProductOrderAndUpdate[indexWithStart].budgetForItem = lineItem[i].nganSach;
                listProductOrderAndUpdate[indexWithStart].residualValueProduct = lineItem[i].nganSachProduct;
                listProductOrderAndUpdate[indexWithStart].residualValue = lineItem[i].residualValue;
                listProductOrderAndUpdate[indexWithStart].unit = lineItem[i].unit;
                listProductOrderAndUpdate[indexWithStart].budgetForProduct = lineItem[i].nganSachSp;
                listProductOrderAndUpdate[indexWithStart].unitProduct = lineItem[i].unitProduct;
                itemCodeDiscountInLine.clear();
                if(!Utils.isEmpty(lineItem[i].maCk.toString())){
                  itemCodeDiscountInLine.add(lineItem[i].maCk.toString());
                }
                if(!Utils.isEmpty(lineItem[i].discountProductCode.toString())){
                  itemCodeDiscountInLine.add(lineItem[i].discountProductCode.toString());
                }
                listProductOrderAndUpdate[indexWithStart].dsCKLineItem = itemCodeDiscountInLine.join(',');
                
                // ✅ QUAN TRỌNG: Ưu tiên restore chiết khấu byhand (FreeDiscount = true)
                // Sau khi match chiết khấu từ lineItem, restore lại chiết khấu byhand nếu có
                String? productCode = listProductOrderAndUpdate[indexWithStart].code?.toString();
                if (productCode != null && preservedManualDiscounts.containsKey(productCode)) {
                  final manualDiscount = preservedManualDiscounts[productCode]!;
                  // Restore chiết khấu byhand (ưu tiên cao nhất)
                  listProductOrderAndUpdate[indexWithStart].discountByHand = manualDiscount['discountByHand'] as int;
                  listProductOrderAndUpdate[indexWithStart].discountPercentByHand = manualDiscount['discountPercentByHand'] as double;
                  listProductOrderAndUpdate[indexWithStart].ckntByHand = manualDiscount['ckntByHand'] as double;
                  // Giữ lại priceAfter từ chiết khấu byhand nếu có
                  if (manualDiscount['priceAfter'] != null) {
                    listProductOrderAndUpdate[indexWithStart].priceAfter = manualDiscount['priceAfter'] as double?;
                  }
                  print('🔍 ✅ [EDIT MODE] Restored manual discount for ${productCode}: discountPercentByHand=${listProductOrderAndUpdate[indexWithStart].discountPercentByHand}, ckntByHand=${listProductOrderAndUpdate[indexWithStart].ckntByHand}');
                }
                
                // ✅ LƯU Ý: Product class không có field maCk/maCkOld
                // maCk đã được lưu vào dsCKLineItem (có thể nhiều mã cách nhau dấu phẩy)
                // Logic restore sẽ đọc từ _bloc.listOrder (SearchItemResponseData) có field maCk
              } else {
                print('⚠️ Warning: Invalid indexWithStart=$indexWithStart for product ${valueItem.code}');
              }
            } 
          }
        }
      }
      totalMNProduct = response.data?.order?.tTien;
      totalMNDiscount = response.data?.order?.ck;
      totalMNPayment = response.data?.order?.tTt;
      
      // ✅ RESTORE gifts từ chi tiết đơn hàng sau khi xử lý response
      if(viewUpdateOrder == true){
        for (var gift in giftsToPreserve) {
          bool exists = DataLocal.listProductGift.any((g) =>
            g.code == gift.code &&
            g.gifProductByHand == false &&
            (g.typeCK == null || g.typeCK == '')
          );
          if (!exists) {
            DataLocal.listProductGift.add(gift);
            totalProductGift += gift.count ?? 0;
            print('💰 _handleCalculator: Restored gift from order detail: ${gift.code} (qty: ${gift.count})');
          }
        }
        
        // ✅ Tính lại totalProductGift từ DataLocal.listProductGift để đảm bảo chính xác
        totalProductGift = 0;
        for (var gift in DataLocal.listProductGift) {
          totalProductGift += gift.count ?? 0;
        }
        print('💰 _handleCalculator: After restore, totalProductGift=$totalProductGift, listProductGift.length=${DataLocal.listProductGift.length}');
      }
      
      if(viewUpdateOrder == false && addNewItem == false){
        return CartInitial();
      }else {
        return TotalMoneyUpdateOrderSuccess();
      }
    }catch(e){
      return CartFailure('Úi, ${e.toString()}');
    }
  }

  Master masterDetailOrder = Master();
  String description = '';

  CartState _handleGetDetailOrder(Object data) {
    if (data is String) return CartFailure('Úi, ${data.toString()}');
    try {
      DataLocal.maVV = '';
      DataLocal.maHD = '';
      HistoryOrderDetailResponse response = HistoryOrderDetailResponse.fromJson(data as Map<String,dynamic>);
      lineItem = response.data!.lineItems!;
      infoPayment = response.data!.infoPayment!;
      masterDetailOrder = response.data!.master!;
      description = masterDetailOrder.description.toString().trim();
      DataLocal.typePayment = response.data!.master!.hTTT.toString().trim();
      DataLocal.typeDiscount = response.data!.master!.typeDiscount.toString().trim();
      
      // ✅ Set CKTDTT từ order detail (master.ck và infoPayment.tCkTtNt)
      if (masterDetailOrder.ck != null && masterDetailOrder.ck!.maCk != null && masterDetailOrder.ck!.maCk!.isNotEmpty) {
        codeDiscountTD = masterDetailOrder.ck!.maCk!.trim();
        print('💰 _handleGetDetailOrder: Set codeDiscountTD from order detail: $codeDiscountTD');
      }
      
      // ✅ Set totalDiscountForOder từ infoPayment.tCkTtNt
      if (infoPayment != null && infoPayment!.tCkTtNt != null && infoPayment!.tCkTtNt! > 0) {
        totalDiscountForOder = infoPayment!.tCkTtNt!;
        print('💰 _handleGetDetailOrder: Set totalDiscountForOder from order detail: $totalDiscountForOder');
      }

      // ✅ Lưu InfoPayment vào DataLocal để CartScreen (CartBloc mới) có thể khôi phục chiết khấu tổng đơn khi SỬA ĐƠN
      if (infoPayment != null) {
        DataLocal.editOrderTotalMoney = infoPayment!.tTien ?? 0;
        DataLocal.editOrderTotalDiscount = infoPayment!.tCkTtNt ?? 0;
        DataLocal.editOrderTotalPayment = infoPayment!.tTtNt ?? 0;
        DataLocal.editOrderTotalTax = infoPayment!.tThueNt ?? 0;
        // Reset lại tỷ lệ CK tổng đơn nhập tay khi mở lại chi tiết đơn
        DataLocal.editOrderManualTotalDiscountPercent = 0;
        print(
          '💰 _handleGetDetailOrder: Saved InfoPayment to DataLocal '
          '(editOrderTotalMoney=${DataLocal.editOrderTotalMoney}, '
          'editOrderTotalDiscount=${DataLocal.editOrderTotalDiscount}, '
          'editOrderTotalPayment=${DataLocal.editOrderTotalPayment}, '
          'editOrderTotalTax=${DataLocal.editOrderTotalTax})',
        );
      } else {
        DataLocal.editOrderTotalMoney = 0;
        DataLocal.editOrderTotalDiscount = 0;
        DataLocal.editOrderTotalPayment = 0;
        DataLocal.editOrderTotalTax = 0;
        DataLocal.editOrderManualTotalDiscountPercent = 0;
        print('💰 _handleGetDetailOrder: InfoPayment is null, reset edit-order payment summary in DataLocal');
      }

      if(DataLocal.typePayment == 'N'){
        DataLocal.typePayment = 'Thanh toán ngay';
      }else if(DataLocal.typePayment == 'S'){
        DataLocal.typePayment = 'Công nợ';
      }

      DataLocal.dueDatePayment = response.data!.master!.hanTT.toString().trim();
      DataLocal.transactionCode = response.data!.master!.maGD.toString().trim();
      DataLocal.nameTransition = response.data!.master!.tenGD.toString().trim();

      DataLocal.tenDL = response.data!.master!.tenDL.toString().trim();
      DataLocal.maDL = response.data!.master!.maDL.toString().trim();

      // ✅ PRESERVE gifts từ chi tiết đơn hàng (kmYn = 1) trước khi xử lý
      // Chỉ preserve gifts chưa có trong DataLocal (tránh duplicate)
      List<SearchItemResponseData> giftsFromOrderDetail = [];
      
      if(lineItem.isNotEmpty){
        for (var element in lineItem) {
          if(element.maVV != null){
            DataLocal.maVV = element.maVV.toString().trim();
            DataLocal.tenVV = element.tenVV.toString().trim();
          }
          if(element.maHD != null){
            DataLocal.maHD = element.maHD.toString().trim();
            DataLocal.tenHD = element.tenHD.toString().trim();
          }
          if(element.maThue.toString() != null && element.maThue.toString() != ''){
            DataLocal.codeTax = element.maThue.toString();
          }
          if(element.maKho.toString() != null && element.maKho.toString() != ''){
            DataLocal.nameStockMater = element.tenKho.toString().trim();
            DataLocal.codeStockMater = element.maKho.toString().trim();
          }
          
          // ✅ Xử lý gifts từ chi tiết đơn hàng (kmYn = 1)
          bool isGiftProduct = element.kmYn != null && element.kmYn != 0;
          if(isGiftProduct){
            // Kiểm tra xem gift này đã có trong DataLocal chưa
            bool exists = DataLocal.listProductGift.any((g) => 
              g.code == element.maVt &&
              g.gifProductByHand == false &&
              (g.typeCK == null || g.typeCK == '')
            );
            
            if(!exists){
              // ✅ QUAN TRỌNG: Set maCk từ lineItem để validation có thể match
              // Note: LineItems không có sttRecCk, chỉ có maCk. 
              // Validation sẽ match theo maVt (code) và maCk
              String? maCkFromLineItem = element.maCk?.toString().trim();
              // Note: LineItems không có kieuCk, mặc định typeCK = 'HH' cho gift products
              String? typeCkFromLineItem = 'HH'; // Mặc định 'HH' cho hàng tặng
              
              SearchItemResponseData giftItem = SearchItemResponseData(
                code: element.maVt,
                sttRec0: '', // LineItems không có sttRecCk, sẽ match theo maVt (code) và maCk
                name: element.tenVt,
                name2: element.name2,
                dvt: element.dvt,
                descript: "",
                price: element.price,
                giaSuaDoi: element.price ?? 0,
                applyPriceAfterTax: false,
                totalMoneyDiscount: 0,
                totalMoneyProduct: 0,
                valuesTax: 0,
                priceAfter: element.priceAfter,
                discountPercent: 0,
                stockAmount: element.stockAmount,
                taxPercent: 0,
                priceOk: 0,
                imageUrl: element.imageUrl ?? '',
                count: element.soLuong,
                isMark: 0,
                discountMoney: '0',
                discountProduct: '0',
                budgetForItem: '',
                budgetForProduct: '',
                residualValueProduct: 0,
                residualValue: 0,
                unit: element.dvt ?? '',
                priceAfter2: 0,
                maCk: maCkFromLineItem ?? '', // ✅ Set từ lineItem để validation match
                maCkOld: maCkFromLineItem ?? '', // ✅ Set từ lineItem
                kColorFormatAlphaB: element.kColorFormatAlphaB,
                maVtGoc: '', 
                ck: 0, 
                cknt: 0, 
                sttRecCK: '', // LineItems không có sttRecCk, sẽ match theo maVt (code) và maCk
                typeCK: typeCkFromLineItem ?? 'HH', // ✅ Set typeCK từ lineItem (hoặc mặc định 'HH')
                gifProduct: true, 
                gifProductByHand: false, // Đánh dấu là gift từ chi tiết đơn, không phải thêm bằng tay
                discountByHand: false, 
                discountPercentByHand: 0,
                unitProduct: '',
                contentDvt: '',
                woPrice: 0,
                woPriceAfter: 0,
                stockCode: element.codeStore,
                stockName: element.nameStore,
                idVv: element.maVV,
                idHd: element.maHD,
                nameVv: element.tenVV,
                nameHd: element.tenHD,
              );
              
              print('  - Extracted gift from lineItem: ${giftItem.code} - ${giftItem.name}, maCk=${giftItem.maCk}, typeCK=${giftItem.typeCK}, count: ${giftItem.count}');
              giftsFromOrderDetail.add(giftItem);
            }
          }
        }
      }
      
      // ✅ Thêm gifts từ chi tiết đơn vào DataLocal (nếu chưa có)
      for (var gift in giftsFromOrderDetail) {
        DataLocal.listProductGift.add(gift);
        totalProductGift += gift.count ?? 0;
        print('💰 _handleGetDetailOrder: Added gift from order detail: ${gift.code} - ${gift.name}, count: ${gift.count}');
      }
      
      if(giftsFromOrderDetail.isNotEmpty){
        print('💰 _handleGetDetailOrder: Total gifts from order detail: ${giftsFromOrderDetail.length}, totalProductGift: $totalProductGift');
      }
      
      return GetListItemUpdateOrderSuccess();
    } catch (e) {
      return CartFailure('Úi, ${e.toString()}');
    }
  }

  void _addProductSaleOutEvent(AddProductSaleOutEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    await db.addProductSaleOut(event.productItem!);
    emitter(AddProductSaleOutSuccess());
  }

  /// search production

  void _addCartEvent(AddCartEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    await db.addProduct(event.productItem!);
    emitter(AddCartSuccess());
  }

  void _searchProduct(SearchProduct event, Emitter<CartState> emitter)async{
    emitter(CartInitial());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    String searchText = event.searchText;
    emitter((!isRefresh && !isLoadMore)
        ? CartLoading()
        : CartInitial());
    if (_currentSearchText != searchText) {
      _currentSearchText = searchText;
      _currentPage = 1;
      _searchResults.clear();
    }
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        CartState state = await handleCallApi(searchText, i,event.listIdGroupProduct,event.selected,event.idCustomer,event.isCheckStock);
        if (state is! SearchProductSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    if (event.searchText != null && event.searchText != '') {
      if (event.searchText.isNotEmpty) {
        CartState state = await handleCallApi(searchText, _currentPage,event.listIdGroupProduct,event.selected,event.idCustomer,event.isCheckStock);
        emitter(state);
      } else {
        emitter(EmptySearchProductState());
      }
    } else {
      emitter(CartInitial());
    }
  }

  void _checkShowCloseEvent(CheckShowCloseEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    isShowCancelButton = !Utils.isEmpty(event.text);
    emitter(CartInitial());
  }

  void _deleteEvent(DeleteEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    CartState state = _handleDeleteOrderHistory(await _networkFactory!.deleteOrderHistory(_accessToken!,event.sttRec));
    emitter(state);
  }

  void _downloadFileEvent(DownloadFileEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
   downloadAndOpenFile(event.sttRec).whenComplete((){
     add(DownloadFileSuccessEvent());
   });
  }
  Future<File?> downloadPDF(String sttRec) async {
    try {

      final response = await _networkFactory!.downloadFile(_accessToken!,sttRec);

      if (response != null) {
        final Directory? appDir = Platform.isAndroid
            ? await getExternalStorageDirectory()
            : await getApplicationDocumentsDirectory();
        String tempPath = appDir!.path;
        final String fileName =
            '${DateTime.now().microsecondsSinceEpoch}-akt.pdf';
        File file = File('$tempPath/$fileName');
        if (!await file.exists()) {
          await file.create();
        }
        await file.writeAsBytes(response as List<int>);
        return file;
      }
      return null;
    } catch (e) {
      print('Lỗi tải xuống: $e');
      return null;
    }
  }
  Future<bool?> downloadAndOpenFile(String sttRec) async {
    try {
      File? file = await downloadPDF(sttRec);
      if (file != null) {
        await openFile(file.path.toString());
        return true;
      }else{
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }}

  static Future<String?> openFile(String url) async {
    final OpenResult openResult = await OpenFile.open(url);
    return openResult.message;
  }


  void _approveOrderEvent(ApproveOrderEvent event, Emitter<CartState> emitter)async{
    emitter(CartLoading());
    CartState state = _handleApproveOrder(await _networkFactory!.approveOrder(_accessToken!,event.sttRec));
    emitter(state);
  }

  CartState _handleDeleteOrderHistory(Object data){
    if(data is String) return CartFailure('Úi, ${data.toString()}');
    try{
      return DeleteOrderSuccess();
    }catch(e){
      return  CartFailure('Úi, ${e.toString()}');
    }
  }


  CartState _handleApproveOrder(Object data){
    if(data is String) return CartFailure('Úi, ${data.toString()}');
    try{
      return ApproveOrderSuccess();
    }catch(e){
      return  CartFailure('Úi, ${e.toString()}');
    }
  }

  Future<CartState> handleCallApi(String searchText, int pageIndex,List<String> listCodeGroupProduct,
      String selectedId, String idCustomer, bool isCheckStock) async {
    String input='';
    if(!Utils.isEmpty(selectedId) && selectedId != 'null'){
      input = selectedId;
    }
    SearchListItemRequest request = SearchListItemRequest(
        searchValue: searchText,
        pageIndex: pageIndex,
        pageCount: 40,
        currency: Const.currencyCode,
        idCustomer: idCustomer,
        isCheckStock: isCheckStock == true ? 1 : 0,
        itemGroup:  listCodeGroupProduct.join(',').toString().contains('1') ? input : '',
        itemGroup2: listCodeGroupProduct.join(',').toString().contains('2') ? input : '',
        itemGroup3: listCodeGroupProduct.join(',').toString().contains('3') ? input : '',
        itemGroup4: listCodeGroupProduct.join(',').toString().contains('4') ? input : '',
        itemGroup5: listCodeGroupProduct.join(',').toString().contains('5') ? input : '',
    );
    CartState state = _handleSearch(await _networkFactory!.getItemListSearchOrder(request, _accessToken!),pageIndex);
    return state;
  }

  CartState _handleSearch(Object data,int pageIndex){
    if(data is String) return CartFailure('Úi, ${data.toString()}');
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
      return CartFailure('Úi, ${e.toString()}');
    }
  }
  CartState _handleLoadListVVHD(Object data) {
    if (data is String) return CartFailure('Úi, ${data.toString()}');
    try {
      ListVVHDResponse response = ListVVHDResponse.fromJson(data as Map<String,dynamic>);
      DataLocal.listVv = response.listVv!;
      DataLocal.listHd = response.listHd!;
      return GetListVvHdSuccess();
    } catch (e) {
      return CartFailure('Úi, ${e.toString()}');
    }
  }

  void _getGiftProductListEvent(GetGiftProductListEvent event, Emitter<CartState> emitter) async {
    emitter(CartLoading());
    CartState state = _handleGetGiftProductList(
      await _networkFactory!.getGiftProductList(event.maNhom, _accessToken!)
    );
    emitter(state);
  }

  CartState _handleGetGiftProductList(Object data) {
    if (data is String) return CartFailure('Úi, ${data.toString()}');
    try {
      listGiftProducts.clear();
      GiftProductListResponse response = GiftProductListResponse.fromJson(data as Map<String, dynamic>);
      listGiftProducts = response.data?.danhSachHangTang ?? [];
      return GetGiftProductListSuccess();
    } catch (e) {
      return CartFailure('Úi, ${e.toString()}');
    }
  }
}