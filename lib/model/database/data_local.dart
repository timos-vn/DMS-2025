import 'dart:io';

import 'package:dms/model/entity/item_check_in.dart';
import 'package:dms/model/entity/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

import '../entity/entity.dart';
import '../network/request/create_manufacturing_request.dart';
import '../network/request/save_inventory_control_request.dart';
import '../network/response/GetDetailSaleOutCompetedResponse.dart';
import '../network/response/detail_checkin_response.dart';
import '../network/response/entity_stock_response.dart';
import '../network/response/get_detail_order_complete_response.dart';
import '../network/response/get_item_holder_detail_response.dart';
import '../network/response/get_item_materials_response.dart';
import '../network/response/get_list_slider_image_response.dart';
import '../network/response/info_store_response.dart';
import '../network/response/list_image_store_response.dart';
import '../network/response/list_item_suggest_response.dart';
import '../network/response/list_status_order_response.dart';
import '../network/response/list_tax_response.dart';
import '../network/response/list_vvhd_response.dart';
import '../network/response/manager_customer_response.dart';
import '../network/response/search_list_item_response.dart';
import '../network/response/semi_product_response.dart';
import '../network/response/setting_options_response.dart';
import 'database_models.dart';

class DataLocal{

  // static DateTime dateCustom = DateTime.now();
  static List<ListItemHolderDetailResponse> listItemHolderCreate = [];
  //Data Item Card
  static List<ProductStore> listInventoryLocal = <ProductStore>[];

  static List<Product> listOrderProductLocal = <Product>[];

  static BuildContext? context;
  static List<ListImageFile> listFileAlbum = <ListImageFile>[];
  static List<ItemListTicketOffLine> listTicketLocal = <ItemListTicketOffLine>[];
  // static Lists<ListImageFile> listFileOpenStore = <ListImageFile>[];
  static List<StockResponseData> stockList = <StockResponseData>[];
  static bool saveStockInventory = false;

  static String hotIdName =  '';
  static String accountName =  '';
  static String passwordAccount = '';
  static String dateLogin = '';

  static String userId = '';
  static String userName = '';
  static String fullName = '';


  static String messageLogin = '';

  /// check save inventory
  static bool listInventoryIsChange = true;
  /// check create order
  static bool listOrderProductIsChange = true;

  ///Album yêu cầu phải có ảnh
  static bool addImageToAlbumRequest = false;

  static bool addImageToAlbum = false;

  static String addressCheckInCustomer = '';
  static String latLongLocation = '';

  static Position? currentLocations;

  static String dateTimeStartCheckIn = '';

  static String idCurrentCheckIn = '';

  static List<ListVv> listVv = [];
  static List<ListHd> listHd = [];

  static List<ListAlbum> listItemAlbum = [];
  static List<ListAlbumTicketOffLine> listAlbumTicketOffLine = [];

  static List<GetListTaxResponseData> listTax = [];

  static List<SearchItemResponseData> listOrderCalculatorDiscount = [];
  static List<SearchItemResponseData> listProductGift = [];
  static List<SearchItemResponseData> listProductGiftSaleOut = [];

  // static List<SearchItemResponseData> listProductGift = [];

  static List<ListTypeDelivery> listTypeDelivery = [];
  static List<ListAgency> listAgency = [];
  static List<ListTypePayment> listTypePayment = [];
  static List<ListTypeVoucher> listTypeVoucher = [];
  static List<ModelNews> listNews = [];
  static List<ListSliderImage> listSliderFirebase = [];
  static List<ListMember> listVipMemberFirebase = [];
  static  List<ListSliderImage> listSliderImageActive = [];
  static List<ListSliderImage> listSliderImageDisable = [];

  // static String dateTimeCheckOut = Utils.parseStringToDate(DateTime.now().toString(), Const.DATE_TIME_FORMAT).toString();

  static List<String> typePaymentList = ['Chọn hình thức thanh toán','Thanh toán ngay','Công nợ'];

  /// Hàng bán trả lại
  static List<GetDetailOrderCompletedResponseData> listDetailOrderCompletedSave =[];
  static bool lockRefundOrder = false;
  static String sct = '';
  static String codeLockRefundOrder = '';
  static String codeTaxLockRefundOrder = '';
  static String codeSellLockRefundOrder = '';
  static String tkRefundOrder = '';
  static double percentTaxLockRefundOrder = 0;
  /// Hàng bán trả lại sale out
  static List<GetDetailSaleOutCompletedResponseData> listDetailSaleOutCompletedSave =[];
  static bool lockRefundSaleOut = false;
  static String sctSaleOut = '';
  static String codeLockRefundSaleOut = '';
  static String codeTaxLockRefundSaleOut = '';
  static String codeSellLockRefundSaleOut = '';
  static String tkRefundSaleOut = '';
  static double percentTaxLockRefundSaleOut = 0;

  /// Vị trí bất thường
  static String addressDifferent = '';
  static double latDifferent = 0;
  static double longDifferent = 0;

  /// Sửa đơn hàng
  static String typeDiscount = '';
  static String typePayment = '';
  static String codeStockMater = '';
  static String nameStockMater = '';
  static String dueDatePayment = '';
  static String nameTransition = '';
  static String maVV = '';
  static String maHD = '';
  static String tenVV = '';
  static String tenHD = '';
  static String tenDL = '';
  static String maDL = '';
  static String codeTax = '';
  static String nameTax = '';
  static double valuesTax = 0;

  /// Danh sách hàng đã tick chọn khuyến mãi
  static List<ObjectDiscount> listObjectDiscount = [];
  static List<SearchItemResponseData> listOrderDiscount = [];
  static ManagerCustomerResponseData infoCustomer = ManagerCustomerResponseData();
  static String transactionCode = "";
  static int transactionYN = 0;
  static ListTransaction transaction = ListTransaction();
  static ListTransaction typeOrder = ListTransaction();
  static int indexValuesTax = -1;
  static double taxPercent = 0;
  static String taxCode = '';
  static String valuesTypePayment = '';
  static String datePayment = '';
  static String listCKVT = '';
  static String dateEstDelivery = '';

  /// Qrcode function
  static List<ListStatusOrderResponseData> listStatusToOrder= []; /// Danh sách trạng thái đặt hàng
  static List<ListStatusOrderResponseData> listStatusToOrderCustom= [];

  static List<SemiProductionResponseData> listSemiProduction = [];
  static List<SemiProductionResponseData> listWaste = [];
  static List<GetItemMaterialsResponseData> listGetItemMaterialsResponse = [];
  static List<MachineTable> listMachine = [];
  static String noteSell = '';
  static   List<ListStatusOrderResponseData> listStatus= [];

  static List<ListItemSuggestResponseData> listSuggestSave = [];
  static List<InfoStoreResponseData> listStore = <InfoStoreResponseData>[];
}