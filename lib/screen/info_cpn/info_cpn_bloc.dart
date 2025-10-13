import 'dart:io';

import 'package:dms/model/database/data_local.dart';
import 'package:dms/screen/dms/dms_screen.dart';
import 'package:dms/screen/home/home_screen.dart';
import 'package:dms/screen/home/home_screen2.dart';
import 'package:dms/screen/menu/menu_screen.dart';
import 'package:dms/screen/personnel/personnel_screen.dart';
import 'package:dms/screen/sell/sell_screen.dart';
import 'package:dms/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../model/network/request/config_request.dart';
import '../../model/network/response/get_permission_user_response.dart';
import '../../model/network/response/info_company_response.dart';
import '../../model/network/response/info_store_response.dart';
import '../../model/network/response/info_units_response.dart';
import '../../model/network/response/setting_options_response.dart';
import '../../model/network/services/network_factory.dart';
import '../../themes/colors.dart';
import '../../utils/const.dart';
import 'info_cpn_event.dart';
import 'info_cpn_state.dart';


class InfoCPNBloc extends Bloc<InfoCPNEvent,InfoCPNState>{

  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;
  String? deviceToken;

  late List<InfoCompanyResponseCompanies> listInfoCPN = <InfoCompanyResponseCompanies>[];
  late List<InfoUnitsResponseUnits> listUnitsCPN = <InfoUnitsResponseUnits>[];
  late List<InfoStoreResponseData> listStoreCPN = <InfoStoreResponseData>[];


  String? companiesNameSelected;
  String? companiesIdSelected;

  String? unitsNameSelected;
  String? unitsIdSelected;

  String? storeNameSelected;
  String? storeIdSelected;

  bool? showAnimationStore = true;
  int keyLock = 0;
  String userName = '';


  List<UserPermission> listUserPermission=[];
  List<Widget> listMenu = <Widget>[];
  List<PersistentBottomNavBarItem> listNavItem =<PersistentBottomNavBarItem>[];

  InfoCPNBloc(this.context) : super(InitialInfoCPNState()){
    _networkFactory = NetWorkFactory(context);
    getTokenFCM();
    on<GetPrefsInfoCPN>(_getPrefs,);
    on<GetSettingOption>(_getSettingOption);
    on<UpdateTokenFCM>(_updateTokenFCM);
    on<GetCompanyIF>(_getInfoCPN);
    on<Config>(_configCPN);
    on<GetUnits>(_getUnitCPN);
    on<GetStore>(_getStoreCPN);
    on<UpdateCacheStoreEvent>(_updateCacheStoreEvent);
  }

  final box = GetStorage();
  void _getPrefs(GetPrefsInfoCPN event, Emitter<InfoCPNState> emitter)async{
    emitter(InfoCPNLoading());
    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    userName = box.read(Const.FULL_NAME)??'';
    emitter(InfoCPNSuccess());
  }

  void _getInfoCPN(GetCompanyIF event, Emitter<InfoCPNState> emitter)async{
    emitter(InfoCPNLoading());
    InfoCPNState state = _handleGetCompanies(await _networkFactory!.getCompanies(_accessToken!));
    emitter(state);
  }

  void _updateCacheStoreEvent(UpdateCacheStoreEvent event, Emitter<InfoCPNState> emitter)async{
    emitter(InfoCPNLoading());
    InfoCPNState state = _handleUpdateCacheStore(await _networkFactory!.updateCacheStore(_accessToken.toString(),event.storeId.toString()));
    emitter(state);
  }

  void _configCPN(Config event, Emitter<InfoCPNState> emitter)async{
    emitter(InfoCPNLoading());
    ConfigRequest request = ConfigRequest(
        companyId: event.companyId
    );
    InfoCPNState state = _handleConfig(await _networkFactory!.config(request));
    emitter(state);
  }

  void _getUnitCPN(GetUnits event, Emitter<InfoCPNState> emitter)async{
    emitter(InfoCPNLoading());
    InfoCPNState state = _handleGetUnits(await _networkFactory!.getUnits(_accessToken!));
    emitter(state);
  }

  void _getStoreCPN(GetStore event, Emitter<InfoCPNState> emitter)async{
    emitter(InfoCPNLoading());
    InfoCPNState state = _handleGetStore(await _networkFactory!.getStore(_accessToken!,event.unitId));
    emitter(state);
  }

  void _updateTokenFCM(UpdateTokenFCM event, Emitter<InfoCPNState> emitter)async{
    emitter(InfoCPNLoading());
    InfoCPNState state = _handleUpdateUId(await _networkFactory!.updateUId(_accessToken.toString(),deviceToken.toString()));
    emitter(state);
  }

  void _getSettingOption(GetSettingOption event, Emitter<InfoCPNState> emitter)async{
    emitter(InfoCPNLoading());
    InfoCPNState state = _handleGetSettings(await _networkFactory!.getSettingOption(_accessToken!));
    emitter(state);
  }

  InfoCPNState _handleGetCompanies(Object data) {
    if (data is String) return InfoCPNFailure('Úi, ${data.toString()}');
    try {
      InfoCompanyResponse response = InfoCompanyResponse.fromJson(data as Map<String,dynamic>);
      listInfoCPN = response.companies!;
      if(listStoreCPN.isNotEmpty){
        listStoreCPN.clear();
        storeIdSelected = null;
        storeNameSelected = null;
      }
      if(listUnitsCPN.isNotEmpty){
        listUnitsCPN.clear();
        unitsIdSelected = null;
        unitsNameSelected = null;
      }
      return GetInfoCompanySuccessful();
    } catch (e) {
      return InfoCPNFailure('Úi, ${e.toString()}');
    }
  }

  InfoCPNState _handleConfig(Object data){
    if (data is String) return InfoCPNFailure('Úi, ${data.toString()}');
    try {
      if(listStoreCPN.isNotEmpty){
        listStoreCPN.clear();
        storeIdSelected = null;
        storeNameSelected = null;
      }
      if(listUnitsCPN.isNotEmpty){
        listUnitsCPN.clear();
        unitsIdSelected = null;
        unitsNameSelected = null;
      }
      return ConfigSuccessful();
    } catch (e) {
      return InfoCPNFailure('Úi, ${e.toString()}');
    }
  }

  InfoCPNState _handleUpdateCacheStore(Object data){
    if (data is String) return InfoCPNFailure('Úi, ${data.toString()}');
    try {
      return UpdateCacheStoreSuccessful();
    } catch (e) {
      return InfoCPNFailure('Úi, ${e.toString()}');
    }
  }

  InfoCPNState _handleGetUnits(Object data){
    if (data is String) return InfoCPNFailure('Úi, ${data.toString()}');
    try {
      InfoUnitsResponse response = InfoUnitsResponse.fromJson(data as Map<String,dynamic>);
      listUnitsCPN = response.units??[];
      if(listStoreCPN.isNotEmpty){
        listStoreCPN.clear();
        storeIdSelected = null;
        storeNameSelected = null;
      }
      return GetInfoUnitsSuccessful();
    } catch (e) {
      return InfoCPNFailure('Úi, ${e.toString()}');
    }
  }

  InfoCPNState _handleGetStore(Object data){
    if (data is String) return GetStoreCPNFailure('Úi, ${data.toString()}');
    try {
      InfoStoreResponse response = InfoStoreResponse.fromJson(data as Map<String,dynamic>);
      listStoreCPN = response.stores??[];
      DataLocal.listStore = listStoreCPN;
      if(listStoreCPN.isEmpty == true && showAnimationStore == true){
        showAnimationStore = false;
        return GetStoreCPNFailure('null');
      }else if(listStoreCPN.isNotEmpty == true && response.statusCode == 200){
        showAnimationStore = true;
        return GetInfoStoreSuccessful();
      }else{
        return GetStoreCPNFailure('null');
      }
    } catch (e) {
      print(e.toString());
      return GetStoreCPNFailure('Úi, ${e.toString()}');
    }
  }

  // Future<String?> getIdDevice() async {
  //   var deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isIOS) { // import 'dart:io'
  //     var iosDeviceInfo = await deviceInfo.iosInfo;
  //     return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  //   } else {
  //     var androidDeviceInfo = await deviceInfo.androidInfo;
  //     return androidDeviceInfo.androidId; // unique ID on Android
  //   }
  // }

  getTokenFCM() {
    FirebaseMessaging.instance.getToken().then((token) {
      deviceToken = token;
    });
  }

  Future<bool> getPermissionUser()async{
    print(_accessToken);
    print('=============');
    InfoCPNState state = _handleGetPermissionUser(await _networkFactory!.getPermissionUser(_accessToken!));
    if(state is GetPermissionSuccess){
      print('============= T');
      return true;
    }else{
      print('============= F ');
      return false;
    }
  }

  InfoCPNState _handleGetSettings(Object data) {
    if (data is String) return InfoCPNFailure('Úi, ${data.toString()}');
    try {
      SettingOptionsResponse response = SettingOptionsResponse.fromJson(data as Map<String,dynamic>);
      Const.listTransactionsOrder.clear();
      Const.listFunctionQrCode.clear();
      Const.listTransactionsTAH.clear();
      Const.listFunctionQrCode = response.listFunctionQrCode??[];
      if(response.listTransaction != null){
        response.listTransaction?.forEach((element) {
          if(element.maCt.toString().contains('DXA') || element.maCt.toString().contains('DMS') ){
            Const.listTransactionsOrder.add(element);
          }else if(element.maCt.toString().trim() == 'DX3'){
            Const.listTransactionsSaleOut.add(element);
          }else if(element.maCt.toString().trim().contains('TAH')){
            Const.listTransactionsTAH.add(element);
          }
        });
      }
      if(Const.listTransactionsTAH.isNotEmpty){
        Const.indexSelectAdvOrder = 0;
        Const.idTypeAdvOrder = Const.listTransactionsTAH[0].maGd.toString().trim();
        Const.nameTypeAdvOrder = Const.listTransactionsTAH[0].tenGd.toString().trim();
      }
      if( response.masterAppSettings?.inStockCheck == 0){
        Const.inStockCheck = false;
      }
      else if( response.masterAppSettings?.inStockCheck == 1){
        Const.inStockCheck = true;
      }
      Const.distanceLocationCheckIn = response.masterAppSettings?.distanceLocationCheckIn == 0
          ?
      response.masterAppSettings?.distanceLocationCheckIn??0
          :
      response.masterAppSettings?.distanceLocationCheckIn??0 ;
      Const.deliveryPhotoRange = response.masterAppSettings?.deliveryPhotoRange == 0
          ?
      response.masterAppSettings?.deliveryPhotoRange??0
          :
      response.masterAppSettings?.deliveryPhotoRange??0 ;
      Const.inStockCheck = response.masterAppSettings?.inStockCheck == 1 ? true : false;
      Const.freeDiscount = response.masterAppSettings?.freeDiscount == 1 ? true : false;
      Const.discountSpecial = response.masterAppSettings?.discountSpecial == 1 ? true : false;
      Const.woPrice = response.masterAppSettings?.woPrice == 1 ? true : false;
      Const.allowsWoPriceAndTransactionType = response.masterAppSettings?.allowsWoPriceAndTransactionType == 1 ? true : false;
      Const.isVvHd = response.masterAppSettings?.isVvHd == 1 ? true : false;
      Const.saleOutUpdatePrice = response.masterAppSettings?.saleOutUpdatePrice == 1 ? true : false;
      Const.afterTax = response.masterAppSettings?.afterTax == 1 ? true : false;
      Const.useTax = response.masterAppSettings?.useTax == 1 ? true : false;

      Const.chooseAgency = response.masterAppSettings?.chooseAgency == 1 ? true : false;
      Const.chooseTypePayment = response.masterAppSettings?.chooseTypePayment == 1 ? true : false;
      Const.wholesale = response.masterAppSettings?.chooseTypePayment == 1 ? true : false;
      Const.orderWithCustomerRegular = response.masterAppSettings?.orderWithCustomerRegular == 1 ? true : false;
      Const.chooseStockBeforeOrder = response.masterAppSettings?.chooseStockBeforeOrder == 1 ? true : false;

      Const.isVv = response.masterAppSettings?.isVv == 1 ? true : false;
      Const.isHd = response.masterAppSettings?.isHd == 1 ? true : false;
      Const.lockStockInItem = response.masterAppSettings?.lockStockInItem == 1 ? true : false;
      Const.lockStockInCart = response.masterAppSettings?.lockStockInCart == 1 ? true : false;

      Const.checkGroup = response.masterAppSettings?.checkGroup == 1 ? true : false;
      Const.chooseAgentSaleOut = response.masterAppSettings?.chooseAgentSaleOut == 1 ? true : false;
      Const.chooseSaleOffSaleOut = response.masterAppSettings?.chooseSaleOffSaleOut == 1 ? true : false;
      Const.chooseStatusToCreateOrder = response.masterAppSettings?.chooseStatusToCreateOrder == 1 ? true : false;

      Const.enableAutoAddDiscount = response.masterAppSettings?.enableAutoAddDiscount == 1 ? true : false;
      Const.enableProductFollowStore = response.masterAppSettings?.enableProductFollowStore == 1 ? true : false;
      Const.enableViewPriceAndTotalPriceProductGift = response.masterAppSettings?.enableViewPriceAndTotalPriceProductGift == 1 ? true : false;
      Const.chooseStatusToSaleOut = response.masterAppSettings?.chooseStatusToSaleOut == 1 ? true : false;
      Const.chooseStateWhenCreateNewOpenStore = response.masterAppSettings?.chooseStateWhenCreateNewOpenStore == 1 ? true : false;
      Const.editPrice = response.masterAppSettings?.editPrice == 1 ? true : false;
      Const.approveOrder = response.masterAppSettings?.approveOrder == 1 ? true : false;

      Const.dateEstDelivery = response.masterAppSettings?.dateEstDelivery == 1 ? true : false;
      Const.typeProduction = response.masterAppSettings?.typeProduction == 1 ? true : false;
      Const.checkPriceAddToCard = response.masterAppSettings?.checkPriceAddToCard == 1 ? true : false;
      Const.editNameProduction = response.masterAppSettings?.editNameProduction == 1 ? true : false;
      Const.giaGui = response.masterAppSettings?.giaGui == 1 ? true : false;
      Const.checkStockEmployee = response.masterAppSettings?.checkStockEmployee == 1 ? true : false;
      Const.takeFirstStockInList = response.masterAppSettings?.takeFirstStockInList == 1 ? true : false;
      Const.chooseStockBeforeOrderWithGiftProduction = response.masterAppSettings?.chooseStockBeforeOrderWithGiftProduction == 1 ? true : false;
      Const.chooseTypeDelivery = response.masterAppSettings?.chooseTypeDelivery == 1 ? true : false;
      Const.noteForEachProduct = response.masterAppSettings?.noteForEachProduct == 1 ? true : false;
      Const.isCheckStockSaleOut = response.masterAppSettings?.isCheckStockSaleOut == 1 ? true : false;
      Const.isGetAdvanceOrderInfo = response.masterAppSettings?.isGetAdvanceOrderInfo == 1 ? true : false;
      Const.typeOrder = response.masterAppSettings?.typeOrder == 1 ? true : false;
      Const.typeTransfer = response.masterAppSettings?.typeTransfer == 1 ? true : false;
      Const.manyUnitAllow = response.masterAppSettings?.manyUnitAllow == 1 ? true : false;
      Const.isBaoGia = response.masterAppSettings?.isBaoGia == 1 ? true : false;
      Const.isEnableNotification = response.masterAppSettings?.isEnableNotification == 1 ? true : false;
      Const.isDeliveryPhotoRange = response.masterAppSettings?.isDeliveryPhotoRange == 1 ? true : false;
      Const.isDefaultCongNo = response.masterAppSettings?.isDefaultCongNo == 1 ? true : false;
      Const.scanQRCodeForInvoicePXB = response.masterAppSettings?.scanQRCodeForInvoicePXB == 1 ? true : false;
      Const.allowCreateTicketShipping = response.masterAppSettings?.allowCreateTicketShipping == 1 ? true : false;
      Const.percentQuantityImage = response.masterAppSettings?.percentQuantityImage??70;
      Const.reportLocationNoChooseCustomer = response.masterAppSettings?.reportLocationNoChooseCustomer == 1 ? true : false;
      Const.editPriceWidthValuesEmptyOrZero = response.masterAppSettings?.editPriceWidthValuesEmptyOrZero == 1 ? true : false;
      Const.noCheckDayOff = response.masterAppSettings?.noCheckDayOff == 1 ? true : false;
      Const.autoAddAgentFromSaleOut = response.masterAppSettings?.autoAddAgentFromSaleOut == 1 ? true : false;

      DataLocal.listTypeDelivery = response.listTypeDelivery??[];
      DataLocal.listAgency = response.listAgency??[];
      DataLocal.listTypePayment = response.listTypePayment??[];
      DataLocal.listTypeVoucher = response.listTypeVoucher??[];

      return GetSettingsSuccessful();
    } catch (e) {
      return InfoCPNFailure('Úi, ${e.toString()}');
    }
  }

  InfoCPNState _handleUpdateUId(Object data){
    if (data is String) return InfoCPNFailure('Úi, ${data.toString()}');
    try{
      return UpdateUIdSuccess();
    }catch(e){
      return InfoCPNFailure('Úi, ${e.toString()}');
    }
  }

  InfoCPNState _handleGetPermissionUser(Object data){
    if (data is String) return InfoCPNFailure('Úi, ${data.toString()}');
    try{
      if(listMenu.isNotEmpty) {
        listMenu.clear();
      }
      if(listNavItem.isNotEmpty) {
        listNavItem.clear();
      }
      GetPermissionUserResponse response = GetPermissionUserResponse.fromJson(data as Map<String,dynamic>);
      listUserPermission = response.userPermission!;
      List<UserPermissionAccount> userPermissionAccount = response.userPermissionAccount!;
      for (var element in userPermissionAccount) {
        box.write(Const.ACCESS_CODE, element.value.toString().trim());
        box.write(Const.ACCESS_NAME, element.name.toString().trim());
      }
      /// No check menu
      /// 27.8.2022
      ///
      listMenu.add(const HomeScreen2(userName: '',));
      listNavItem.add(PersistentBottomNavBarItem(
        icon: Icon(FluentIcons.home_12_filled),
        title: "Dashboard",
        activeColorPrimary: mainColor,
        inactiveColorPrimary: Colors.grey,
        inactiveColorSecondary: mainColor,
      ),);

      listMenu.add(SellScreen(userName: userName,));
      listNavItem.add(PersistentBottomNavBarItem(
        icon: Icon(MdiIcons.shopping),
        title: "Sell",
        activeColorPrimary: mainColor,
        inactiveColorPrimary: Colors.grey,
        inactiveColorSecondary: mainColor,
      ));

      listMenu.add(const DMSScreen());
      listNavItem.add(PersistentBottomNavBarItem(
        inactiveColorSecondary: mainColor,
        icon: Icon(MdiIcons.webhook),
        title: ("DMS"),
        activeColorPrimary: mainColor,
        activeColorSecondary: mainColor,
        inactiveColorPrimary: Colors.grey,
        // onPressed: (context) {
        //   pushDynamicScreen(context,
        //       screen: SampleModalScreen(), withNavBar: true);
        // }
      ));

      listMenu.add(const PersonnelScreen());
      listNavItem.add(PersistentBottomNavBarItem(
        icon: Icon(MdiIcons.accountDetailsOutline),
        title: ("HR"),
        activeColorPrimary: mainColor,
        inactiveColorPrimary: Colors.grey,
      ));

      listMenu.add(const MenuScreen());
      listNavItem.add(PersistentBottomNavBarItem(
        icon: Icon(MdiIcons.menu),
        title: ("MENU"),
        activeColorPrimary: mainColor,
        inactiveColorPrimary: Colors.grey,
      ),);
      if(listUserPermission.isNotEmpty){
        for (var element in listUserPermission) {
          // Parent Menu

          // Menu
          if(element.menuId == '01.00.65'){
            Const.historyAction = true; // hàng bán trả lại
          }if(element.menuId == '01.00.42'){
            Const.allowChangeTransfer = true; // hàng bán trả lại
          }
          // Home
          if(element.menuId == '01.00.01'){
            Const.notification = true;
          }
          else if(element.menuId == '01.00.02'){
            Const.reportHome = true;
          }
          //Sell
          else if(element.menuId == '01.00.04'){
            Const.createNewOrder = true;
          }
          else if(element.menuId == '01.02.06'){
            Const.createNewOrderForSuggest = true;
          }
          else if(element.menuId == '01.00.05'){
            Const.historyOrder = true;
          }
          else if(element.menuId == '01.00.06'){
            Const.infoProduction = true;
          }
          else if(element.menuId == '01.00.07'){
            Const.infoCustomerSell = true;
          }
          else if(element.menuId == '01.02.05'){
            Const.createNewOrderFromCustomer = true;
          }
          else if(element.menuId == '01.02.04'){
            Const.approveOrder = true;
          }
          else if(element.menuId == '01.02.40'){
            Const.historyKeepCardList = true;
          } else if(element.menuId == '01.02.07'){
            Const.createOrderFormStore = true;
          }
          else if(element.menuId == '01.02.08'){
            Const.downFileFromDetailOrder = true;
          }

          /// Contract
          else if(element.menuId == '01.06.10'){
            Const.contract = true;
          }

          //DMS
          /// checkin
          else if(element.menuId == '01.00.09'){
            Const.checkIn = true;
          }
          else if(element.menuId == '01.00.60'){
            Const.inventoryCheckIn = true;
          }
          else if(element.menuId == '01.00.61'){
            Const.imageCheckIn = true;
          }else if(element.menuId == '01.00.62'){
            Const.ticketCheckIn = true;
          }
          else if(element.menuId == '01.00.63'){
            Const.orderCheckIn = true;
          }
          else if(element.menuId == '01.00.10'){
            Const.pointOfSale = true;
          }
          else if(element.menuId == '01.00.11'){
            Const.orderStatusPlace = true;
          }
          else if(element.menuId == '01.00.12'){
            Const.saleOut = true;
          }
          else if(element.menuId == '01.00.13'){
            Const.reportKPI = true;
          }
          else if(element.menuId == '01.00.14'){
            Const.openStore = true;
          }
          else if(element.menuId == '01.00.15'){
            Const.infoCustomerDMS = true;
          }
          else if(element.menuId == '01.00.16'){
            Const.ticket = true;
          }
          else if(element.menuId == '01.00.17'){
            Const.deliveryPlan = true; // kế hoạch giao hàng
          }
          else if(element.menuId == '01.00.18'){
            Const.delivery = true; // giao vận
          }
          else if(element.menuId == '01.00.19'){
            Const.careDiaryCustomerDMS = true; // nhật ký cskh
          }
          else if(element.menuId == '01.00.79'){
            Const.itinerary = true; // Giám sát hành trình
          }
          else if(element.menuId == '01.00.80'){
            Const.inventory = true; // Kiem ke
          }
          else if(element.menuId == '01.00.64'){
            Const.refundOrder = true; // hàng bán trả lại
          }
          else if(element.menuId == '01.02.01'){
            Const.refundOrderSaleOut = true; // hàng bán trả lại sale out
          }
          else if(element.menuId == '01.02.03'){
            Const.createTaskFromCustomer = true; // Check-in trong KH
          }


          //HR
          else if(element.menuId == '01.05.20'){
            Const.hrm = true;
          }else if(element.menuId == '01.05.31'){
            Const.businessTrip = true;
          }else if(element.menuId == '01.05.32'){
            Const.dayOff = true;
          }else if(element.menuId == '01.05.33'){
            Const.overTime = true;
          }else if(element.menuId == '01.05.34'){
            Const.advanceRequest = true;
          }else if(element.menuId == '01.05.35'){
            Const.checkInExPlan = true;
          }else if(element.menuId == '01.05.36'){
            Const.carRequest = true;
          }else if(element.menuId == '01.05.37'){
            Const.meetingRoom = true;
          }
          else if(element.menuId == '01.05.21'){
            Const.timeKeeping = true;
          }
          else if(element.menuId == '01.05.22'){
            Const.tableTimeKeeping = true;
          }
          else if(element.menuId == '01.05.23'){
            Const.onLeave = true; // nghi phep
          }
          else if(element.menuId == '01.05.24'){
            Const.recommendSpending = true; // de nghi chi
          }
          else if(element.menuId == '01.05.25'){
            Const.articleCar = true; // dieu xe
          }
          else if(element.menuId == '01.05.26'){
            Const.createNewWork = true;
          }
          else if(element.menuId == '01.05.27'){
            Const.workAssigned = true;
          }
          else if(element.menuId == '01.05.28'){
            Const.myWork = true;
          }
          else if(element.menuId == '01.05.29'){
            Const.workInvolved = true;
          }
          else if(element.menuId == '01.00.30'){
            Const.infoEmployee = true;
          }
          // Menu
          else if(element.menuId == '01.00.32'){
            Const.report = true; // báo cáo tổng hợp
          }
          else if(element.menuId == '01.00.33'){
            Const.approval = true; // duyệt phiếu tổng hợp
          }
          else if(element.menuId == '01.00.34'){
            Const.stageStatistic = true; //thống kê công đoạn
          }
          else if(element.menuId == '01.00.39'){
            Const.stageStatisticV2 = true; //thống kê công đoạn v2
          }else if(element.menuId == '01.00.41'){
            Const.listVoucher = true; //Danh sách phiếu
          }
          ///
          ///
          ///
          ///

          else if(element.menuId == '01.00.35'){
            Const.updateDeliveryPlan = true;
          }
          else if(element.menuId == '01.00.37'){
            Const.cacheAllowed = true;
          }
          else if(element.menuId == '01.00.38'){
            Const.allowedConfirm = true;
          }
        }
        return GetPermissionSuccess();
      }
      else{
        return GetPermissionFail();
      }
    }catch(e){
      return InfoCPNFailure('Úi, ${e.toString()}');
    }
  }
}