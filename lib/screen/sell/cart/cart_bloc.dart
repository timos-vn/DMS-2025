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

class CartBloc extends Bloc<CartEvent,CartState>{

  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String get accessToken => _accessToken!;
  String? _refreshToken;
  String get refreshToken => _refreshToken!;

  final db = DatabaseHelper();

  List<SearchItemResponseData> listOrder = [];

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
  Set<String> selectedCkgIds = {}; // Set of sttRecCk đã chọn (multiple selection)
  
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
    List<SearchItemResponseData> restoredGiftsFromCache = [];
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
    
    // ✅ MERGE: Gifts từ chi tiết đơn hàng + Gifts từ API + Gifts từ cache (thêm bằng tay)
    DataLocal.listProductGift.clear();
    DataLocal.listProductGift.addAll(preservedGiftsFromOrderDetail); // 1. Từ chi tiết đơn hàng
    DataLocal.listProductGift.addAll(preservedGiftsFromAPI); // 2. Từ API tính chiết khấu
    DataLocal.listProductGift.addAll(restoredGiftsFromCache); // 3. Từ cache (thêm bằng tay)
    
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
    listOrder.clear();
    listItemOrder.clear();
    if(listProductOrderAndUpdate.isNotEmpty){
      for (var element in listProductOrderAndUpdate) {
        SearchItemResponseData item = listOrder.firstWhere((valuesE) => valuesE.code.toString().trim() == element.code.toString().trim());
        if(item.code != '' && item.code != 'null'){
          element.priceAfterTax =  (/* element.giaGui > 0 ?  element.giaGui :*/ item.giaSuaDoi) + ((( /*element.giaGui > 0 ?  element.giaGui :*/ item.giaSuaDoi * 1) * DataLocal.taxPercent)/100);
        }
      }
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
  double totalDiscountWhenChooseTypePayment = 0;
  String codeTypePayment = '';

  bool showWarning = true;

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
      totalPayment = totalMoney - totalDiscount;
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
      totalPayment = totalMoney - (totalDiscount + valuesTax);
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
      totalPayment = totalMoney - totalDiscount;
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
      totalPayment = totalMoney - (totalDiscount + valuesTax);
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
        DetailOrderV3 item = DetailOrderV3(
            nameProduction: element.name,
            code: element.code,
            sttRec0: element.sttRec0,
            count: element.count,
            price:  element.giaSuaDoi,
            priceAfter: element.priceAfter,
            discountPercent:  Const.freeDiscount == true ? (
                element.discountPercentByHand > 0 ? element.discountPercentByHand :  element.discountPercent
            ) : element.discountPercent,
            dvt: element.dvt,
            ck: element.discountByHand == true ? element.ckntByHand : (element.ck ),
            cknt: element.discountByHand == true ? element.ckntByHand : (element.cknt ?? 0),
            maCk: element.maCk,
            kmYN: 0,
            stockCode: element.stockCode,

            taxValues: ((element.price ?? 0) * (element.valuesTax ?? element.thueSuat ?? 0)) / 100,
            codeTax: (DataLocal.taxCode != null && DataLocal.taxCode.toString().isNotEmpty) ? DataLocal.taxCode.toString() : (element.maThue?.toString() ?? element.tenThue?.toString() ?? ''),
            priceOk: //element.priceOk.toString().replaceAll('null','').isNotEmpty ? element.priceOk : element.giaSuaDoi,
            Const.editPrice == true ? element.giaSuaDoi : (element.priceOk.toString().replaceAll('null','').isNotEmpty ? element.priceOk : 0),
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
            sttRecHD: event.sttRectHD
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

      DetailOrderV3 item = DetailOrderV3(
          code: element.code,
          sttRec0: element.sttRec0,
          count: element.count,
          price: Const.editPrice == true ? element.giaSuaDoi : element.price,
          priceAfter: element.priceAfter,
          discountPercent:  Const.freeDiscount == true ? (
              element.discountPercentByHand > 0 ? element.discountPercentByHand :  element.discountPercent
          ) : element.discountPercent,
          dvt: element.dvt,
          ck: element.discountByHand == true ? element.ckntByHand : (element.ck ),
          cknt: element.discountByHand == true ? element.ckntByHand : (element.cknt ?? 0),
          maCk: element.maCk,
          kmYN: 0,
          stockCode: element.stockCode,
          taxValues: ((element.price ?? 0) * (element.valuesTax ?? element.thueSuat ?? 0)) / 100,
        codeTax: (DataLocal.taxCode != null && DataLocal.taxCode.toString().isNotEmpty) ? DataLocal.taxCode.toString() : (element.maThue?.toString() ?? element.tenThue?.toString() ?? ''),
          priceOk: Const.editPrice == true ? element.giaSuaDoi : (element.priceOk.toString().replaceAll('null','').isNotEmpty ? element.priceOk : 0),
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
    emitter(CartInitial());
    customerName = event.customerName;
    phoneCustomer = event.phone;
    addressCustomer = event.address;
    codeCustomer = event.codeCustomer;
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
    totalDiscount = 0;
    totalDiscountOldByHand = 0;
    totalMoneyOld = 0;
    totalTax = 0;
    if(event.reLoad == false) {
      if(event.addOnProduct == true && event.product!.code != null && event.product!.code != ''){
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
        totalDiscount = totalDiscountOld;
      }
      if(Const.useTax == true){
        element.valuesTax = 0;
        element.valuesTax = (((element.priceAfter! * element.count!) * DataLocal.taxPercent)/100);
        totalTax = totalTax + element.valuesTax!;
      }
      // valuesTax += element.priceAfterTax != null ? element.priceAfterTax! : 0;


      if(Const.useTax == true && element.giaSuaDoi > 0){
        totalMoneyOld = totalMoneyOld + (element.giaSuaDoi * element.count!);
      }
    }
    if(Const.chooseAgency == true && typeDiscount.isNotEmpty){
      chooseAgency(false);
    }
    if(Const.chooseTypePayment == true && codeTypePayment.contains('Thanh toán ngay')){
      chooseTypePayment();
    }
    double cktd = 0;
    if(listCkTongDon.isNotEmpty){
      cktd = listCkTongDon[0].tCkTt??0;
    }
    if(Const.freeDiscount == true){
      totalPayment = totalMoney + totalTax - (totalDiscount + cktd);
    }

    // if(Const.useTax  == true){
    //   totalPayment = totalPayment + totalTax;
    // }
    print('check money');
    print('totalMoney------: $totalMoney');
    print('cktd------: $cktd');
    print('totalDiscount------: $totalDiscount');
    print('totalTax------: $totalTax');
    print('check money:${ totalMoney - (totalDiscount + totalTax + cktd)}');
    emitter(CalculatorDiscountSuccess());
  }

  void calculatorTax(){
    totalTax = 0;
    totalPayment = 0;
    for (var element in listProductOrderAndUpdate) {
      SearchItemResponseData item = listOrder.firstWhere((valuesE) => valuesE.code.toString().trim() == element.code.toString().trim());
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
      print('💰 No gifts in DataLocal, extracting from lineItem...');
      for (var element in lineItem) {
        bool isGiftProduct = element.kmYn != null && element.kmYn != 0;
        if(isGiftProduct){
          SearchItemResponseData giftItem = SearchItemResponseData(
            code: element.maVt,
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
            maCk: '',
            maCkOld: '',
            kColorFormatAlphaB: element.kColorFormatAlphaB,
            maVtGoc: '', ck: 0, cknt: 0, sttRecCK: '', typeCK: '', 
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
          print('  - Extracted gift from lineItem: ${giftItem.code} - ${giftItem.name}, count: ${giftItem.count}');
        }
      }
    }
    
    print('💰 Preserving gifts from order detail: ${preservedGiftsFromOrderDetail.length}');
    for (var gift in preservedGiftsFromOrderDetail) {
      print('  - Gift from order: ${gift.code} - ${gift.name}, count: ${gift.count}');
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
          availableQuantity: element.availableQuantity
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
    emitter(CartLoading());
    db.deleteAllProduct().then((value) => print('delete success'));
    // Clear listProductGift trước khi thêm mới
    listProductGift.clear();
    for (var element in lineItem) {
      // Kiểm tra kmYn: null hoặc 0 = sản phẩm thường, != 0 = sản phẩm khuyến mại
      bool isGiftProduct = element.kmYn != null && element.kmYn != 0;
      
      if(!isGiftProduct){
        // Sản phẩm thường
        Product production = Product(
            code: element.maVt,
            name: element.tenVt,
            name2:element.name2,
            dvt: element.dvt,
            description: "",
            price: /*element.giaNet ?? */element.price,
            priceAfter:element.priceAfter,
            discountPercent:element.discountPercent,
            stockAmount:element.stockAmount,
            taxPercent: 0,
            imageUrl: element.imageUrl ?? '',
            count: element.soLuong,
            countMax: element.soLuongKD,
            so_luong_kd: element.soLuongKD ?? 0,
            isMark:1,
            discountMoney: '0',
            discountProduct: '0',
            budgetForItem:'',
            budgetForProduct: '',
            residualValueProduct:0,
            residualValue: 0,
            unit: element.dvt ?? '',
            unitProduct: '',
            dsCKLineItem:'',
            codeStock: element.codeStore,
            nameStock: element.nameStore,
            idVv:element.maVV,
            idHd : element.maHD,
            nameVv: element.tenVV,
            nameHd : element.tenHD,
            giaSuaDoi: element.price??0,
            priceMin: element.giaMin??0,

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
    
    // Copy danh sách khuyến mại vào DataLocal ngay sau khi xử lý xong
    DataLocal.listProductGift.clear();
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
        print('💰 _addProductToCartEvent: Restored gift from order detail: ${gift.code} (qty: ${gift.count})');
      }
    }
    
    print('AddProductToCartEvent: listProductGift.length = ${listProductGift.length}');
    print('AddProductToCartEvent: DataLocal.listProductGift.length = ${DataLocal.listProductGift.length} (after restore)');
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

        listOrder.clear();
      }
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
        for (var element in listProductOrderAndUpdate) {
          SearchItemResponseData itemOrder = SearchItemResponseData(
              code: element.code,
              name: element.name,
              name2:element.name2,
              dvt: element.dvt,
              descript: element.description,
              price: element.price ,
              // discountByHand: ,
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
            itemOrder.maCk = '';
            itemOrder.maCkOld = '';
            itemOrder.sttRecCK = '';
            itemOrder.typeCK = '';
            itemOrder.maVtGoc = '';
            itemOrder.sctGoc = '';
            itemOrder.discountPercent = 0;
            itemOrder.ck = 0;
            itemOrder.cknt = 0;
            itemOrder.priceAfter = itemOrder.giaSuaDoi;
            listOrder.add(itemOrder);
            listItemOrder.add(itemOrder);
            continue;
          }
          if(keyLoad == 'First' && itemOrder.listDiscount!.isNotEmpty){
            allowed = false;
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
            }
            else if(itemOrder.listDiscount![0].kieuCk == 'CKG' && element.editPrice != 1){
              itemOrder.maCk = itemOrder.listDiscount![0].maCk.toString().trim();
              itemOrder.discountPercent = itemOrder.listDiscount![0].tlCk;
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
              
              if(itemOrder.listDiscount![0].tlCk! > 0){
                // Case 1: Trường hợp có tỉ lệ chiết khấu (%)
                // ✅ FIX: priceAfter là ĐƠN GIÁ, KHÔNG NHÂN count!
                itemOrder.priceAfter = itemOrder.giaSuaDoi - (itemOrder.giaSuaDoi * itemOrder.listDiscount![0].tlCk! / 100);
              } else if(giaSauCk > 0 && giaSauCk != giaGoc && giaGoc > 0){
                // Ưu tiên: Trường hợp có giá sau chiết khấu và khác giá gốc (có chiết khấu thực sự)
                itemOrder.priceAfter = giaSauCk;
                itemOrder.discountPercent = ((giaGoc - giaSauCk) / giaGoc) * 100;
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
            }
            listPromotion = listPromotion == '' ? itemOrder.listDiscount![0].sttRecCk.toString().trim() : '$listPromotion,${itemOrder.listDiscount![0].sttRecCk.toString().trim()}';
            if(DataLocal.listCKVT.contains('${itemOrder.listDiscount![0].sttRecCk.toString().trim()}-${element.code.toString().trim()}') == false){
              DataLocal.listCKVT = DataLocal.listCKVT == '' ? '${itemOrder.listDiscount![0].sttRecCk.toString().trim()}-${itemOrder.listDiscount![0].maVt.toString().trim()}' : '${DataLocal.listCKVT},${'${itemOrder.listDiscount![0].sttRecCk.toString().trim()}-${itemOrder.listDiscount![0].maVt.toString().trim()}'}';
            }
            codeDiscountSelecting  = itemOrder.listDiscount![0].sttRecCk.toString().trim();
            listOrder.add(itemOrder);
            listItemOrder.add(itemOrder);
          }
          else if(keyLoad == 'Second'){
            bool findDiscountProduct = false;
            allowed = false;
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
                itemOrder.discountPercent = x.tlCk;
                itemOrder.priceAfter = x.giaSauCk;
                itemOrder.price = x.giaGoc;
                itemOrder.ck = x.ck!;
                itemOrder.maCkOld = x.maCk.toString();
                itemOrder.cknt = x.ckNt;
                itemOrder.sttRecCK = x.sttRecCk.toString().trim();
                itemOrder.typeCK = 'CKG';
                itemOrder.priceOk = x.giaSauCk;
                // itemOrder.giaSuaDoi = x.giaSauCk!;
                double giaGoc = x.giaGoc ?? itemOrder.giaSuaDoi ?? 0;
                double giaSauCk = x.giaSauCk ?? 0;
                double ckValue = x.ck ?? 0;
                
                if(x.tlCk! > 0){
                  // Case 1: Trường hợp có tỉ lệ chiết khấu (%)
                  // ✅ FIX: priceAfter là ĐƠN GIÁ, KHÔNG NHÂN count!
                  itemOrder.priceAfter = itemOrder.giaSuaDoi - (itemOrder.giaSuaDoi * x.tlCk! / 100);
                } else if(giaSauCk > 0 && giaSauCk != giaGoc && giaGoc > 0){
                  // Ưu tiên: Trường hợp có giá sau chiết khấu và khác giá gốc (có chiết khấu thực sự)
                  itemOrder.priceAfter = giaSauCk;
                  itemOrder.discountPercent = ((giaGoc - giaSauCk) / giaGoc) * 100;
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
          }
          else if(keyLoad == 'First' && itemOrder.listDiscount!.isEmpty){
            listOrder.add(itemOrder);
            listItemOrder.add(itemOrder);
          }
        }
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
        for(int i = 0; i < lineItem!.length; i++){
          List<String> itemCodeDiscountInLine = [];
          if(_lineItemOrder.isNotEmpty){
            final valueItem = _lineItemOrder.firstWhere((item) => item.code ==  lineItem[i].maVt,);
            if (valueItem != null) {
              // final indexWithStart = _lineItemOrder.indexOf(valueItem);
              int indexWithStart =  _lineItemOrder.indexWhere((element) => element.code == valueItem.code);
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
              SearchItemResponseData giftItem = SearchItemResponseData(
                code: element.maVt,
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
                maCk: '',
                maCkOld: '',
                kColorFormatAlphaB: element.kColorFormatAlphaB,
                maVtGoc: '', ck: 0, cknt: 0, sttRecCK: '', typeCK: '', 
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