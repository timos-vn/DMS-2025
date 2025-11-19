
// ignore_for_file: constant_identifier_names, prefer_const_constructors

// import 'package:camera/camera.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/entity/color_for_alpha_b.dart';
import '../model/entity/entity.dart';
import '../model/network/response/data_default_response.dart';
import '../model/network/response/setting_options_response.dart';

class Const {
  // ignore: non_constant_identifier_names
  // static  String HOST_URL = "http://103.48.192.2:6070";
  // ignore: non_constant_identifier_names
  static  String HOST_URL = "";
  static  String token = "";
  // ignore: non_constant_identifier_names
  static  String NAME_URL = "";
  // ignore: non_constant_identifier_names
  static  int PORT_URL = 0;

  static const String HOST_GOOGLE_MAP_URL = "https://maps.googleapis.com/maps/api/";

  // ignore: non_constant_identifier_names
  static TextInputFormatter FORMAT_DECIMA_NUMBER = FilteringTextInputFormatter.deny(RegExp('[\\-|\\ |\\/|\\*|\$|\\#|\\+|\\|]'));

  static List<CameraDescription> cameras = <CameraDescription>[];
  static String valueCamera = '';

  static bool selectedAlbumLock = false;

  static bool checkInOnline = true;
  static const defaultPadding = 16.0;

  ///Migration db
  static const bool migrationDB = true;
  ///version app
  static String versionApp = '1.0.78';

  static const int MAX_COUNT_ITEM = 20;
  static const kDefaultPadding = 20.0;
  static const String BACK = 'Back to screen';

  static const String DATE_FORMAT = "dd/MM/yyyy";
  static const String DATE_TIME_FORMAT_LOCAL = "dd/MM/yyyy HH:mm:ss";
  static const String DATE_TIME_FORMAT = "yyyy-MM-dd HH:mm:ss";
  static const String DATE_FORMAT_1 = "dd-MM-yyyy";
  static const String DATE_FORMAT_2 = "yyyy-MM-dd";
  static const String DATE_SV = "yyyy-MM-dd'T'HH:mm:ss";
  static const String DATE_SV_FORMAT = "yyyy/MM/dd";
  static const String DATE_SV_FORMAT_1 = "MM/dd/yyyy";
  static const String DATE_SV_FORMAT_2 = "yyyy-MM-dd";
  static const String DATE_SV_FORMAT_3 = "yyyy-MM-dd HH:mm:ss.aa";
  static const String DATE_SV_FORMAT_4 = "HH:mm dd-MM-yyyy";
  static const String DATE = "EEE";
  static const String DAY = "dd";
  static const String YEAR = "yyyy";
  static const String TIME = "hh:mm aa";
  static const String TIME2 = "HH:mm:ss";

  static const String REFRESH = "REFRESH";

  static const HOME= 0;
  static const SALE = 1;
  static const DMS = 3;
  static const PERSONNEL= 4;
  static const MENU = 5;

  static const String BAR_CHART = 'bar';
  static const String PIE_CHART = 'pie';
  static const String LINE_CHART = 'line';

  static AppLifecycleState appLifecycleStateChanged = AppLifecycleState.inactive;
  static const String CHART = 'C';
  static const String TABLE = 'G';

  static const String ACCESS_TOKEN = "Token";
  static const String REFRESH_TOKEN = "Refresh token";
  static const String USER_ID = 'User id';
  static const String USER_NAME = "User name";
  static const String FULL_NAME = "Full name";
  static const String PHONE_NUMBER = "Phone number";
  static const String EMAIL = "Email";
  static const String CODE = "Code";
  static const String CODE_NAME = "Code name";
  static const String ACCESS_CODE = "Code ACCESS";
  static const String ACCESS_NAME = "Name ACCESS";

  static const String CODE_EMPLOYEE_SALE = "CODE_EMPLOYEE_SALE";
  static const String CODE_DEPARTMENT = "CODE_DEPARTMENT";
  static const String NAME_DEPARTMENT = "NAME_DEPARTMENT";
  static const String REMAINING_DAYS_OFF = "REMAINING_DAYS_OF";
  static const String ROLES = "roles";
  static const String TOTAL_UNREAD_NOTIFICATION = "TOTAL_UNREAD_NOTIFICATION";
  
  // ✅ Survey data storage keys
  static const String SURVEY_DATA = "SURVEY_DATA";
  static const String SURVEY_PROGRESS = "SURVEY_PROGRESS";

  static const String SEND_OTP_SUCCESS = "Send OTP Success";

  static const List<String> listSex = ['Nam', 'Nữ', 'Khác'];

  static const String logoTag = 'near.huscarl.loginsample.logo';
  static const String titleTag = 'near.huscarl.loginsample.title';

  ///Data
  static String companyId = '';
  static String companyName = '';
  static String unitId = '';
  static String unitName = '';
  static String storeId = '';
  static String storeName = '';
  static String uId = '';
  static String userName = '';
  static String maNvbh = '';
  static String maNPP = '';
  static int userId = 0;
  static int phepCL = 0;
  static String currencyCode = '';
  static int codeGroup = 1;
  static String itemGroupCode = '';
  static List<String> listGroupProductCode = ['1'];
  static double tyGiaQuyDoi = 1;
  static int accessCode = 1;

  static List<StockList> stockList = [];
  static List<CurrencyList> currencyList = [];

  static int numberProductInCart = 0;

  static List<ListFunctionQrCode> listFunctionQrCode = <ListFunctionQrCode>[];
  static List<String> listFunctionQrCodeScanner = ['Quét Phiếu','Cập nhật vị trí'];

  static List<ListTransaction> listTransactionsOrder = <ListTransaction>[];
  static List<ListTransaction> listTransactionsTAH = <ListTransaction>[];
  static List<ListTransaction> listTransactionsSaleOut = <ListTransaction>[];

  static DateTime dateFrom = DateTime.now().add(const Duration(days: -7));
  static DateTime dateTo = DateTime.now();
  static int distanceLocationCheckIn = 500; ///met - Tăng từ 300m lên 500m để giảm khó chịu cho user
  static bool freeDiscount = false; /// Khoá CTCK tự do
  static bool discountSpecial = false; /// Khoá CTCK đặc biệt: chiết khấu tổng đơn tặng hàng
  static bool woPrice = false; /// Khoá giá bán buôn
  static bool allowsWoPriceAndTransactionType = false; /// Cho chọn giá bán buôn/lẻ + loại giao dịch

  static bool isWoPrice = false; /// False : giá bán lẻ - True : giá bán buôn
  static int indexSelectAdvOrder = 0; /// Tuỳ chọn loại hàng hoá - In Quang Trung
  static String idTypeAdvOrder = ''; /// Tuỳ chọn loại hàng hoá - In Quang Trung
  static String nameTypeAdvOrder = ''; /// Tuỳ chọn loại hàng hoá - In Quang Trung
  ///
  static int percentQuantityImage = 70; /// Chất lượng ảnh
  static bool inStockCheck = false; /// cho phép đặt tồn âm
  static bool isGiaGui = false;
  static bool isVvHd = false;
  static bool isVv = false;
  static bool isHd = false;
  static bool lockStockInItem = false;
  static bool lockStockInCart = false;
  static bool lockStockInItemGift = false;
  static bool saleOutUpdatePrice = false; /// Cho phép cập nhật giá cho tính năng sale Out
  static bool afterTax = false; /// Cho phép tính thuế sau chiết khấu : true - false : cho phép tính thuế trước chiết khấu
  static bool useTax = false; /// Cho phép tính thuế
  static bool chooseAgency = false; /// Cho phép chọn Đại Lý
  static bool chooseTypePayment = false; /// Cho phép chọn Hình thức thanh toán
  static bool wholesale = false; /// Cho phép chọn giá theo hình thức bán buôn : true
  static bool orderWithCustomerRegular = false; /// Cho phép đặt hàng với KH thường : true
  static bool chooseStockBeforeOrder = false; /// Chọn kho xong mới được đặt đơn : true
  static bool checkGroup = false; /// Đặt đơn theo nhóm hàng đã chọn vào giỏ hàng
  static bool chooseAgentSaleOut = false; /// Chọn đại lý trong sale out
  static bool chooseSaleOffSaleOut = false; /// Chọn hàng khuyến mại trong sale out
  static bool chooseStatusToCreateOrder = false; /// Khi tạo đơn/sửa đơn có thể chọn được trạng thái lập chứng từ hoặc chờ duyệt
  static bool chooseStatusToSaleOut = false; /// Khi tạo đơn/sửa đơn SALE - OUT có thể chọn được trạng thái
  static bool autoAddDiscount = false; /// Cho phép sản phẩm thêm sau ăn theo CK của sp trước đó.
  static bool enableAutoAddDiscount = false;
  static bool enableProductFollowStore = false; /// Cho phép thêm sản phẩm nhiều kho
  static bool addProductFollowStore = false;
  static bool enableViewPriceAndTotalPriceProductGift = false;
  static bool allowViewPriceAndTotalPriceProductGift = false;
  static bool approveNewStore = false; /// Duyệt điểm bán mở mới
  static bool chooseStateWhenCreateNewOpenStore = false; ///Thêm thông tin trạng thái khi mở mới điểm bán
  static bool dateEstDelivery = false; ///Ngày dự kiến giao hàng
  static bool editPrice = false; /// Cho phép sửa giá (không giới hạn)
  static bool editPriceWidthValuesEmptyOrZero = false; /// Chỉ cho phép sửa giá khi giá = 0 hoặc null
  static bool editNameProduction = false; /// Cho phép sửa tên sản phẩm
  static bool typeProduction = false; /// Loại của sản phẩm: Thường - Chế biến - Sản xuất
  static bool giaGui = false; /// Cho phép nhập thêm giá gửi
  static bool checkPriceAddToCard = false; /// Cho phép kiểm trá trước khi add vào giỏ hàng
  static bool checkStockEmployee = false; /// Cho phép kiểm trá kho theo nhân viên
  static bool chooseStockBeforeOrderWithGiftProduction = false; /// Chọn kho xong mới được đặt đơn với sp tặng  : true
  static bool takeFirstStockInList = false; /// auto chọn kho đầu tiên khi thêm sp vào giỏ
  static bool chooseTypeDelivery = false; /// Chọn loại hình thức vận chuyển
  static bool noteForEachProduct = false; /// Ghi chú cho từng sản phẩm
  static bool isCheckStockSaleOut = false; /// Ghi chú cho từng sản phẩm
  static bool isGetAdvanceOrderInfo = false; /// Nhập thông tin khác cho sản phẩm -> Khi đặt đơn
  static bool typeOrder = false; /// Cho phép chọn Loại hàng
  static bool typeTransfer = false; /// Cho phép chọn giao dịch
  static bool manyUnitAllow = false; /// cho phép quy đổi đơn vị tính
  static bool isBaoGia = false; /// cho phép quy đổi đơn vị tính
  static bool isEnableNotification = false; /// cho phép chức năng thông báo
  static bool isDeliveryPhotoRange = false; /// cho phép chức năng chup anh giao hang
  static int deliveryPhotoRange = -1; /// Khoảng cách giao hàng
  static bool scanQRCodeForInvoicePXB = false; /// cho phép quét phiếu PXB khi xác nhận giao hàng
  static bool allowCreateTicketShipping = false; /// Kiểm tra sl thực giao và sl yêu cầu, nếu nhỏ hơn cho phép tạo phiu giao hàng
  static bool reportLocationNoChooseCustomer = false; /// Yêu cầu phải chọn khách hàng - Báo cáo vị trí
  static bool noCheckDayOff = false; /// Yêu cầu phải chọn khách hàng - Báo cáo vị trí
  static bool autoAddAgentFromSaleOut = false; /// Cho phép tự động add NPP/ĐL theo nhân viên sale ở trong SALE OUT
  static bool discountSpecialAdd = false; /// hiển thị nút add sp tặng ở giỏ hàng
  static bool addProductionSameQuantity = false; /// thêm sp có cùng số lượng


  ///Data format
  static String quantityFormat='';
  static String quantityNtFormat='';
  static String amountFormat='';
  static String amountNtFormat='';
  static String rateFormat='';

  /// Group Key Product
  static String listKeyGroup = '';
  static String listKeyGroupCheck = '';
  static bool addFirstProductToCart = false;

  /// Group Key Group Product
  static List<EntityClass> listKeyGroupProduct = [];

  /// List user permission

  // Dashbroad
  static bool notification = false;
  static bool reportHome = false;

  //Sell
  static bool banner = false;
  static bool createNewOrder = false;
  static bool createNewOrderForSuggest = false;
  static bool createNewOrderSuggest = false;
  static bool createNewOrderFromCustomer = false;
  static bool historyOrder = false;
  static bool infoCustomerSell = false;
  static bool infoProduction = false;
  static bool contract = false;
  static bool historyKeepCardList = false;
  static bool tKSX = false;
  static bool refundOrder = false;
  static bool isDefaultCongNo = false;
  static bool createOrderFormStore = false;
  static bool downFileFromDetailOrder = false;

  //DMS
  static bool checkIn = false;
  static bool inventoryCheckIn = false;
  static bool imageCheckIn = false;
  static bool ticketCheckIn = false;
  static bool orderCheckIn = false;

  static bool pointOfSale = false;
  static bool orderStatusPlace = false;
  static bool saleOut = false;
  static bool reportKPI = false;
  static bool openStore = false;
  static bool infoCustomerDMS = false;
  static bool careDiaryCustomerDMS = false;
  static bool ticket = false;
  static bool refundOrderSaleOut = false;

  static bool deliveryPlan = false;
  static bool delivery = false;
  static bool itinerary = false;
  static bool createTaskFromCustomer = false;
  static bool inventory = false;

  //HR

  static bool hrm = false; // HRM
  static bool businessTrip = false; // de xuat cong tac
  static bool dayOff = false; // xin nghi phep
  static bool overTime = false; // tang ca
  static bool advanceRequest = false; // de nghi tam ung
  static bool checkInExPlan = false; // giai trinh cham cong
  static bool carRequest = false; // dang ky xe
  static bool meetingRoom = false; // dang ky phong hop
  static bool timeKeeping = false; // chấm công
  static bool tableTimeKeeping = false; // bảng chấm công
  static bool onLeave = false; // nghỉ phép
  static bool recommendSpending = false; // đề nghị chi
  static bool articleCar = false; // điều xe
  static bool createNewWork = false; // Thêm mới công việc
  static bool workAssigned = false; // Công việc tôi giao
  static bool myWork = false; // công việc của tôi
  static bool workInvolved = false; // công việc tôi liên quan
  static bool infoEmployee = false;
  //Menu
  static bool report = false;
  static bool approval = false;
  static bool historyAction = false;
  static bool approveOrder = false;
  static bool updateDeliveryPlan = false;
  static bool stageStatistic = false;
  static bool stageStatisticV2 = false;
  static bool listVoucher = false;

  static bool allowChangeTransfer = false;

  // static bool shippingProduct = false;
  // static bool confirmShippingProduct = false;

  static bool cacheAllowed = false;
  static bool allowedConfirm = false;


  static List<String> kColorForAlphaA = ['P','Q','R','S','T','U','V','W','X','Y','Z'];
  static List<ColorForAlphaB> kColorForAlphaB = [
    ColorForAlphaB('A',Color(0xff451599)),
    ColorForAlphaB('Á',Color(0xff451599)), ColorForAlphaB('Â',Color(0xff451599)),ColorForAlphaB('Ă',Color(0xff451599)),
    ColorForAlphaB('B',Color(0xff7e0cde)),
    ColorForAlphaB('C',Color(0xff2f7135)),
    ColorForAlphaB('D',Color(0xff1f3df1)),
    ColorForAlphaB('Đ',Color(0xff1f3df1)),
    ColorForAlphaB('E',Color(0xff21a304)),ColorForAlphaB('Ê',Color(0xff21a304)),
    ColorForAlphaB('F',Color(0xff9a2e2e)),
    ColorForAlphaB('G',Color(0xff490353)),
    ColorForAlphaB('H',Color(0xff03299a)),
    ColorForAlphaB('I',Color(0xff166c05)),
    ColorForAlphaB('J',Color(0xff533a80)),
    ColorForAlphaB('K',Color(0xff8cbb43)),
    ColorForAlphaB('L',Color(0xff845724)),
    ColorForAlphaB('M',Color(0xff0fdb19)),
    ColorForAlphaB('N',Color(0xff2907db)),
    ColorForAlphaB('O',Color(0xff0449d5)),ColorForAlphaB('Ô',Color(0xff0449d5)),ColorForAlphaB('Ơ',Color(0xff0449d5)),
    ColorForAlphaB('P',Color(0xffe0591a)),
    ColorForAlphaB('Q',Color(0xff4d4fad)),
    ColorForAlphaB('R',Color(0xff03ef07)),
    ColorForAlphaB('S',Color(0xffad184b)),
    ColorForAlphaB('T',Color(0xffc1be88)),
    ColorForAlphaB('U',Color(0xff3a4e80)),ColorForAlphaB('Ư',Color(0xff3a4e80)),
    ColorForAlphaB('V',Color(0xff3a805a)),
    ColorForAlphaB('W',Color(0xff3a8076)),
    ColorForAlphaB('X',Color(0xff0370d2)),
    ColorForAlphaB('Y',Color(0xff129303)),
    ColorForAlphaB('Z',Color(0xff3a8068)),

    ColorForAlphaB('0',Color(0xffa9c405)),
    ColorForAlphaB('1',Color(0xff44f54f)),
    ColorForAlphaB('2',Color(0xff59d03e)),
    ColorForAlphaB('3',Color(0xff36c9e2)),
    ColorForAlphaB('4',Color(0xfff3037f)),
    ColorForAlphaB('5',Color(0xff95645f)),
    ColorForAlphaB('6',Color(0xff444947)),
    ColorForAlphaB('7',Color(0xffcd8b05)),
    ColorForAlphaB('8',Color(0xffbffae6)),
    ColorForAlphaB('9',Color(0xff010c34)),
    ColorForAlphaB('',Color(0xff131a18)),
  ];
}

const kTitleKey = Key('FLUTTER_LOGIN_TITLE');
// const kRecoverPasswordIntroKey = Key('RECOVER_PASSWORD_INTRO');
// const kRecoverPasswordDescriptionKey = Key('RECOVER_PASSWORD_DESCRIPTION');
// const kDebugToolbarKey = Key('DEBUG_TOOLBAR');

const kMinLogoHeight = 50.0; // hide logo if less than this
const kMaxLogoHeight = 125.0;

const TextStyle headerTextStyle = TextStyle(
  fontSize: 12,
  color: Colors.blue,
  fontWeight: FontWeight.bold,
  //fontFamily: SizeConfig.montesseratFontFamily););
);
