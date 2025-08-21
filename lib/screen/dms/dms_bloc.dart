import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dms/extension/extension_compare_date.dart';
import 'package:dms/model/database/data_local.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:dms/utils/const.dart';

import '../../model/database/dbhelper.dart';
import '../../model/entity/item_check_in.dart';
import '../../model/network/request/inventory_request.dart';
import '../../model/network/response/detail_checkin_response.dart';
import '../../model/network/response/detail_open_store_response.dart';
import '../../model/network/response/inventory_response.dart';
import '../../model/network/response/list_checkin_response.dart';
import '../../model/network/response/list_image_store_response.dart';
import '../../model/network/response/list_request_open_store_response.dart';
import '../../model/network/response/list_status_order_response.dart';
import '../../model/network/response/list_task_offline_response.dart';
import '../../model/network/response/list_tax_response.dart';
import '../../model/network/services/network_factory.dart';
import '../../utils/utils.dart';
import 'dms_event.dart';
import 'dms_state.dart';


class DMSBloc extends Bloc<DMSEvent,DMSState>{
  NetWorkFactory? networkFactory;
  BuildContext context;

  String? userName;
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
  int totalPager = 0;
  String? currentAddress;

  DatabaseHelper db = DatabaseHelper();

  String roles = '0';

  Future<List<ItemCheckInOffline>> getListCheckInOffLineFromDb()async {
    listCheckInOffline = await db.fetchAllListCheckInOffline();
    return listCheckInOffline;
  }

  Future<List<ItemAlbum>> getListAlbumOffLineFromDb()async{
    return db.fetchAllListAlbumOffline();
  }

  Future<List<ItemTicket>> getListTicketOffLineFromDb() {
    return db.fetchAllListAlbumTicketOffLine();
  }

  List<DataRequest> _listDataRequest = <DataRequest>[];
  List<DataRequest> get listDataRequest => _listDataRequest;

  List<ListImageFile> listFileAlbumView = <ListImageFile>[];

  List<String> listImage = [];

  List<File> listFileInvoice = [];

  late Position currentLocation;
  List<ItemCheckInOffline> listSynCheckIn = <ItemCheckInOffline>[];
  List<ItemCheckInOffline> listCheckInOffline = [];
  List<ListAlbum> listItemAlbum = [];
  List<ListAlbumTicketOffLine> listAlbumTicketOffLine = [];


  String accessName = '';
  String userId = '';
  List<ListCheckIn> listCheckInToDay = [];

  DateTime? dateSave;

  DetailRequestOpenStore detailRequestOpenStore = DetailRequestOpenStore();

  int userRoles = 0;
  int leadRoles = 0;
  int totalUnreadNotification = 0;

  final box = GetStorage();
  DMSBloc(this.context) : super(InitialDMSState()){
    networkFactory = NetWorkFactory(context);
    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    roles = box.read(Const.ROLES);
    Const.accessCode = int.parse(box.read(Const.ACCESS_CODE)??'0');
    accessName = box.read(Const.ACCESS_NAME)??'';
    userId = box.read(Const.USER_ID)??'';
    totalUnreadNotification = box.read(Const.TOTAL_UNREAD_NOTIFICATION) ?? 0;
    on<GetPrefsDMSEvent>(_getPrefs);
    on<GetListRequestOpenStore>(_getListRequestOpenStore);
    on<GetCameraEvent>(_getCameraEvent);
    on<AddNewRequestOpenStoreEvent>(_addNewRequestOpenStoreEvent);
    on<GetDetailOpenStoreEvent>(_getDetailOpenStoreEvent);
    on<UpdateRequestOpenStoreEvent>(_updateRequestOpenStoreEvent);
    on<CancelOpenStoreEvent>(_cancelOpenStoreEvent);
    on<GetListTaskOffLineEvent>(_getListTaskOffLineEvent);
    on<GetValuesClient>(_getValuesClient);
    on<GetListTax>(_getListTax);
    on<GetListStatusOrder>(_getListStatusOrder);
    on<GetTotalUnreadNotificationEvent>(_getTotalUnreadNotification);
    on<GetListInventoryRequest>(_getListInventoryRequest);
    on<GetListItemInventoryEvent>(_getListItemInventoryEvent);
    on<GetListStoreFromSttRecEvent>(_getListStoreFromSttRecEvent);
    on<GetListHistoryInventoryEvent>(_getListHistoryInventoryEvent);

    on<SelectItemInventory>(_onSelectItemInventory);
    on<UpdateUIEvent>(_updateUIEvent);
    on<UpdateInventoryEvent>(_updateInventoryEvent);
    on<UpdateHistoryInventoryEvent>(_updateHistoryInventoryEvent);
  }

  void _onSelectItemInventory(SelectItemInventory event, Emitter<DMSState> emitter) {
    emitter(DMSInventoryState());
    final currentState = state;
    if (currentState is DMSInventoryState) {
      emitter(currentState.copyWith(selectedIndex: event.index));
    }
  }

  void _getPrefs(GetPrefsDMSEvent event, Emitter<DMSState> emitter)async{
    emitter(InitialDMSState());

    emitter(GetPrefsSuccess());
  }
  void _updateInventoryEvent(UpdateInventoryEvent event, Emitter<DMSState> emitter)async{
    emitter(DMSLoading());
    /// Hàm build InventoryRequest từ currentDraft
    InventoryRequest buildInventoryRequest({
      required String sttRec,
      required String namYc,
      required String ngayCt,
      required String ghiChu,
      required String datetime0,
      required String datetime2,
    }) {
      final items = event.currentDraft.inventoryList.map((item) {
        return InventoryRequestItem(
          sttRec: sttRec,
          ngayCt: ngayCt,
          maKho: item.maKho ?? '',
          maViTri: item.maViTri ?? '',
          maVt: item.maVt ?? '',
          dvt: item.dvt ?? '',
          maLo: item.maLo ?? '',
          soLuong: item.so_luong_kk_tt,
          ghiChu: ghiChu,
          datetime0: datetime0,
          datetime2: datetime2,
        );
      }).toList();

      return InventoryRequest(
        sttRec: sttRec,
        namYc: namYc,
        data: items,
      );
    }
    final request = buildInventoryRequest(
      sttRec: event.sttRec.toString(),
      namYc: DateTime.now().year.toString(),
      ngayCt: DateTime.now().toString(),
      ghiChu: '',
      datetime0: DateTime.now().toString(),
      datetime2: DateTime.now().toString(),
    );
    DMSState state = _handleUpdateInventory(await networkFactory!.updateInventory(request,_accessToken.toString()));
    emitter(state);
  }
  void _updateHistoryInventoryEvent(UpdateHistoryInventoryEvent event, Emitter<DMSState> emitter)async{
    emitter(DMSLoading());
    /// Hàm build InventoryRequest từ currentDraft
    /// Hàm build HistoryRequest từ currentDraft.historyList
    HistoryRequest buildHistoryRequest({
      required String sttRec,
    }) {
      final now = DateTime.now();
      final ngayYc = "${now.year}${now.month.toString().padLeft(2, '0')}";
      final items = event.currentDraft.historyList.map((item) {
        return HistoryRequestItem(
          sttRec: sttRec,
          sttRec0: item.sttRec0 ?? 0,
          maIn: item.maIn ?? '',
          tenIn: item.tenIn ?? '',
          maVt: item.maVt ?? '',
          tenVt: item.tenVt.toString().replaceAll('null', ''),
          maLo: item.maLo ?? '',
          maKho: item.maKho ?? '',
          maViTri: item.maViTri ?? '',
          dateTimeModify: Utils.parseDateToString(DateTime.now(), Const.DATE_SV),
          soLuongKk: item.soLuongKk ?? 0,
          userId: Const.userId
        );
      }).toList();

      return HistoryRequest(
        sttRec: sttRec,
        ngayYc: ngayYc,
        data: items,
      );
    }

    final request = buildHistoryRequest(
      sttRec: event.sttRec,
    );
    DMSState state = _handleUpdateHistoryInventory(await networkFactory!.updateHistoryInventory(request,_accessToken.toString()));
    emitter(state);
  }
  void _updateUIEvent(UpdateUIEvent event, Emitter<DMSState> emitter)async{
    // if(event.dMSInventoryState == true){
      emitter(DMSInventoryState());
    // }else{
      // emitter(InitialDMSState());
    // }
  }

  void _getListStatusOrder(GetListStatusOrder event, Emitter<DMSState> emitter)async{
    // emitter(DMSLoading());
    DMSState state = _handleLoadListStatusOrder(
        await networkFactory!.getListStatusOrder(_accessToken.toString(),event.vcCode));
    emitter(state);
  }
  void _getListTax(GetListTax event, Emitter<DMSState> emitter)async{
    emitter(DMSLoading());
    DMSState state = _handleLoadListTax(await networkFactory!.getListTax(_accessToken!));
    emitter(state);
  }
  void _getListStoreFromSttRecEvent(GetListStoreFromSttRecEvent event, Emitter<DMSState> emitter)async{
    emitter(DMSLoading());
    DMSState state = _handleGetListStoreFromSttRecEvent(await networkFactory!.getListStoreFromSttRec(event.sttRec.toString(),_accessToken.toString()));
    emitter(state);
  }
  void _getListHistoryInventoryEvent(GetListHistoryInventoryEvent event, Emitter<DMSState> emitter)async{
    emitter(DMSLoading());
    DMSState state = _handleGetListHistoryInventory(await networkFactory!.getListHistoryInventoryFromSttRec(event.sttRec.toString(),_accessToken.toString()));
    emitter(state);
  }
  void _getListInventoryRequest(GetListInventoryRequest event, Emitter<DMSState> emitter)async{
    emitter(DMSLoading());
    DMSState state = _handleGetListInventoryRequest(await networkFactory!.getListInventoryRequest(_accessToken.toString(),event.searchKey,event.pageIndex,20));
    emitter(state);
  }
  void _getListItemInventoryEvent(GetListItemInventoryEvent event, Emitter<DMSState> emitter)async{
    emitter(DMSLoading());
    DMSState state = _handleGetListItemInventory(await networkFactory!.getListItemInventory(_accessToken.toString(),event.sttRec,event.searchKey,event.pageIndex,20));
    emitter(state);
  }

  List<ItemAlbum> _listItemAlbum = [];
  List<ItemTicket> _listItemTicket = [];

  void _getValuesClient(GetValuesClient event, Emitter<DMSState> emitter)async{
    emitter(DMSLoading());
    listItemAlbum.clear();
    listAlbumTicketOffLine.clear();
    listCheckInOffline = await db.getListCheckInOffline();
    listSynCheckIn = await db.getListCheckIn();
    _listItemAlbum = await db.getListAlbumOffline();
    _listItemTicket = await db.getListAlbumTicketOffLine();
    if(_listItemAlbum.isNotEmpty){
      for (var element in _listItemAlbum) {
        ListAlbum item = ListAlbum(
          maAlbum: element.maAlbum,
          tenAlbum: element.tenAlbum,
          ycAnhYn: element.ycAnhYN == 1 ? true : false,
        );
        listItemAlbum.add(item);
        DataLocal.listItemAlbum.add(item);
      }
    }
    if(_listItemTicket.isNotEmpty){
      for (var element in _listItemTicket) {
        ListAlbumTicketOffLine item = ListAlbumTicketOffLine(
          maTicket: element.ticketId,
          tenTicket: element.tenLoai,
        );
        listAlbumTicketOffLine.add(item);
        DataLocal.listAlbumTicketOffLine.add(item);
      }
    }
    if(listCheckInOffline.isNotEmpty && listSynCheckIn.isNotEmpty){
      for (var elementSyn in listSynCheckIn) {
        bool anyCheck = listCheckInOffline.any((element) => (element.id.toString().trim() + element.maKh.toString().trim()).toString() == elementSyn.id.toString());
        if(anyCheck == true){
          ItemCheckInOffline itemCheckIn = listCheckInOffline[listCheckInOffline.indexWhere((element) => (element.id.toString().trim() + element.maKh.toString().trim()).toString() == elementSyn.id.toString())];
          if(itemCheckIn.id != null){
            int index = listCheckInOffline.indexWhere((element) => (element.id.toString().trim() + element.maKh.toString().trim()).toString() == elementSyn.id.toString());
            ItemCheckInOffline itemCheckInUpdate = ItemCheckInOffline(
              id:itemCheckIn.id,
              tieuDe: itemCheckIn.tieuDe,
              ngayCheckin: elementSyn.timeCheckIn != '' ? elementSyn.timeCheckIn.toString() :  itemCheckIn.ngayCheckin.toString(),
              maKh: itemCheckIn.maKh,
              tenCh: itemCheckIn.tenCh,
              diaChi: itemCheckIn.diaChi,
              dienThoai: itemCheckIn.dienThoai,
              gps: itemCheckIn.gps,
              trangThai: elementSyn.timeCheckOut != '' ? 'Hoàn thành' : itemCheckIn.trangThai,
              isCheckInSuccessful: itemCheckIn.trangThai == 'Hoàn thành' ? 1 : 0,
              isSynSuccessful: itemCheckIn.isSynSuccessful,
              tgHoanThanh: elementSyn.timeCheckOut ?? itemCheckIn.tgHoanThanh,
              lastChko: elementSyn.lastChko,
              timeCheckOut: '',
              idCheckIn: '',
              timeCheckIn: '',
              numberTimeCheckOut: 0,
              openStore: '',
              latlong: '',
              dateSave: elementSyn.dateSave,
              note: '',
            );
            listCheckInOffline[index] = itemCheckInUpdate;
          }
        }
      }
    }
    if(listCheckInOffline.isNotEmpty){
      print(listCheckInOffline[0].dateSave.toString().trim());
      print( Utils.parseStringToDate(listCheckInOffline[0].dateSave.toString().trim(), Const.DATE_SV_FORMAT_2));
      dateSave = Utils.parseStringToDate(listCheckInOffline[0].dateSave.toString().trim(), Const.DATE_SV_FORMAT_2);
    }
    if(dateSave != null){
      print('check day :$dateSave');
      print(DateTime.now().isBeforeDay(dateSave!));
      if(DateTime.now().isBeforeDay(dateSave!) == false){
        db.deleteAllAppSettings();
        db.deleteAllListCheckInOffline();
        listCheckInOffline.clear();
        db.deleteAllListAlbumOffline();
        listItemAlbum.clear();
        db.deleteAllListAlbumTicketOffLine();
        listAlbumTicketOffLine.clear();
      }
    }
    emitter(GetValuesClientSuccess());
  }

  void _getListTaskOffLineEvent(GetListTaskOffLineEvent event, Emitter<DMSState> emitter)async{
    emitter(DMSLoading());
    DMSState state = _handleGetListTaskOffLine(await networkFactory!.getListListTaskOffLine(_accessToken!,DateTime.now().toString()),event.nextScreen);
    emitter(state);
  }

  void _addNewRequestOpenStoreEvent(AddNewRequestOpenStoreEvent event, Emitter<DMSState> emitter)async{
    emitter(DMSLoading());

    // Random iRandom = Random(10000);
    // String id = '${iRandom.nextInt(10000)}A';
    // print('->>>>>> $id');
    // ItemCheckInOffline itemCheckIn = ItemCheckInOffline(
    //     id: id,
    //     maKh: id,
    //     tenCh: event.nameStore.toString(),
    //     latlong: '${currentLocation.latitude},${currentLocation.longitude}',
    //     diaChi: event.address.toString(),
    //     idCheckIn: id,
    //     timeCheckIn: '',
    //     openStore: '',
    //     timeCheckOut: '',
    //     tieuDe: event.nameCustomer.toString(),
    //     ngayCheckin: DateTime.now().toString(),
    //     numberTimeCheckOut: 0,
    //   dienThoai: event.phoneCustomer.toString(),
    // );
    //
    // await db.addListCheckInOffline(itemCheckIn);
    // listCheckInOffline = await db.getListCheckInOffline();
    // print(listCheckInOffline.length);
    var formData = FormData.fromMap(
        {
          "StoreName":event.nameStore.toString(),
          "StorePhone":event.phoneStore.toString(),
          "City":event.idProvince.toString(),
          "District":event.idDistrict.toString(),
          "ContactPerson":event.nameCustomer.toString(),
          "ContactPhone":event.phoneCustomer.toString(),
          "Note":event.note.toString(),
          "Email":event.email.toString(),
          "Address":event.address.toString(),
          "Birthday":event.birthDay.isEmpty == true ? '1995-03-04' : event.birthDay,
          "GPS":'${currentLocation.latitude},${currentLocation.longitude}',
          "Location":currentAddress.toString(),
          "IdArea":event.idArea.toString(),
          "IdTypeStore": event.idTypeStore.toString(),
          "IdStoreForm": event.idStoreForm.toString(),
          "IdTour": event.idTour.toString(),
          "MST": event.mst.toString(),
          "Desc": event.desc.toString(),
          "IdCommune": event.idCommune.toString(),
          "IdState":event.idState
        }
    );
    if(listFileInvoice.isNotEmpty){
      for (var element in listFileInvoice) {
        formData.files.addAll([
          MapEntry("ListFile",await MultipartFile.fromFile(element.path))
        ]);
      }
    }else{
      const MapEntry("ListFile","");
    }
    DMSState state = _handleAddNewRequestOpenStore(await networkFactory!.addNewRequestOpenStore(formData,_accessToken!));
    emitter(state);
  }

  void _updateRequestOpenStoreEvent(UpdateRequestOpenStoreEvent event, Emitter<DMSState> emitter)async{
    emitter(DMSLoading());
    var formData = FormData.fromMap(
        {
          "idRequestOpenStore":event.idRequestOpenStore,
          "StoreName":event.nameStore,
          "StorePhone":event.phoneStore,
          "City":event.idProvince,
          "District":event.idDistrict,
          "ContactPerson":event.nameCustomer,
          "ContactPhone":event.phoneCustomer,
          "Note":event.note,
          "Email":event.email,
          "Address":event.address,
          "Birthday":event.birthDay,
          "GPS":'',
          "IdArea":event.idArea,
          "IdTypeStore": event.idTypeStore,
          "IdStoreForm": event.idStoreForm,
          "IdTour": event.idTour,
          "MST": event.mst,
          "Desc": event.desc,
          "IdCommune": event.idCommune,
          "IdState":event.idState
        }
    );
    if(listFileInvoice.isNotEmpty){
      for (var element in listFileInvoice) {
        formData.files.addAll([
          MapEntry("ListFile",await MultipartFile.fromFile(element.path))
        ]);
      }
    }else{
      const MapEntry("ListFile","");
    }
    DMSState state = _handleUpdateRequestOpenStore(await networkFactory!.updateRequestOpenStore(formData,_accessToken!));
    emitter(state);
  }

  void _cancelOpenStoreEvent(CancelOpenStoreEvent event, Emitter<DMSState> emitter)async{
    emitter(DMSLoading());
    DMSState state = _handleCancelRequestOpenStore(await networkFactory!.cancelRequestOpenStore(_accessToken!,event.idTour,event.idRequestOpenStore));
    emitter(state);
  }

  void _getCameraEvent(GetCameraEvent event, Emitter<DMSState> emitter)async{
    emitter(InitialDMSState());
    Map<Permission, PermissionStatus> permissionRequestResult = await [Permission.location,Permission.camera].request();
    if (permissionRequestResult[Permission.camera] == PermissionStatus.granted) {
      isGrantCamera = true;
      emitter(GrantCameraPermission());
    }
    else {
      if (await Permission.camera.isPermanentlyDenied) {
        emitter(InitialDMSState());
      } else {
        isGrantCamera = false;
        emitter(EmployeeScanFailure('Vui lòng cấp quyền truy cập Camera.'));
      }
    }
  }

  void _getDetailOpenStoreEvent(GetDetailOpenStoreEvent event, Emitter<DMSState> emitter)async{
    emitter(DMSLoading());
    DMSState state = _handleGetDetailOpenStore(
        await networkFactory!.getDetailRequestOpenStore(_accessToken!,event.idRequestOpenStore));
    emitter(state);
  }

  void _getListRequestOpenStore(GetListRequestOpenStore event, Emitter<DMSState> emitter)async{
    emitter(InitialDMSState());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? DMSLoading()
        : InitialDMSState());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        DMSState state = await handleCallApi(i,event.dateTime.toString(),event.idKhuVuc.toString(),event.dateFrom.toString(),event.dateTo.toString());
        if (state is! GetListRequestOpenStoreSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    DMSState state = await handleCallApi(_currentPage,event.dateTime.toString(),event.idKhuVuc.toString(),event.dateFrom.toString(),event.dateTo.toString());
    emitter(state);
  }

  Future<DMSState> handleCallApi(int pageIndex,String dateTime, String idKhuVuc, String dateForm,String dateTo) async {

    DMSState state = _handleLoadList(
        await networkFactory!.getListRequestOpenStore(_accessToken!,dateForm,dateTo,dateTime,idKhuVuc,pageIndex,_maxPage,status), pageIndex);
    return state;
  }

  DMSState _handleLoadList(Object data, int pageIndex) {
    if (data is String) return DMSFailure('Úi, $data');
    try {
      ListRequestOpenStoreResponse response = ListRequestOpenStoreResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 20;
      List<DataRequest> list = response.data!.dataRequest!;
      if (!Utils.isEmpty(list) && _listDataRequest.length >= (pageIndex - 1) * _maxPage + list.length) {
        _listDataRequest.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          _listDataRequest = list;
        } else {
          _listDataRequest.addAll(list);
        }
      }
      if (Utils.isEmpty(_listDataRequest)) {
        return GetListRequestOpenStoreEmpty();
      } else {
        isScroll = true;
      }
      return GetListRequestOpenStoreSuccess();
    } catch (e) {
      return DMSFailure('Úi, ${e.toString()}');
    }
  }

  DMSState _handleGetDetailOpenStore(Object data,) {
    if (data is String) return DMSFailure('Úi, ${data.toString()}');
    try {
      DetailOpenStoreResponse response = DetailOpenStoreResponse.fromJson(data as Map<String,dynamic>);
      detailRequestOpenStore = response.detailRequestOpenStore!;
      Roles roles = response.roles!;
      userRoles = roles.userRole!;
      leadRoles = roles.leadRole!;
      return GetDetailRequestOpenStoreSuccess();
    } catch (e) {
      return DMSFailure('Úi, ${e.toString()}');
    }
  }

  DMSState _handleAddNewRequestOpenStore(Object data){
    if(data is String) return DMSFailure('Úi, ${data.toString()}');
    try{
      return AddNewRequestOpenStoreSuccess();
    }catch(e){
      return DMSFailure('Úi, ${e.toString()}');
    }
  }

  DMSState _handleGetListTaskOffLine(Object data, int nextScreen){
    if(data is String) return DMSFailure('Úi, ${data.toString()}');
    try{
      ListTaskOfflineResponse response = ListTaskOfflineResponse.fromJson(data as Map<String,dynamic>);
      db.deleteAllListCheckInOffline();
      listCheckInOffline.clear();
      db.deleteAllListAlbumOffline();
      listItemAlbum.clear();
      db.deleteAllListAlbumTicketOffLine();
      listAlbumTicketOffLine.clear();
      listCheckInToDay = response.listCheckInToDay!;
      // if(listSynCheckIn.isNotEmpty && listCheckInToDay.isNotEmpty){
      //         for (var elementSyn in listSynCheckIn) {
      //           bool anyCheck = listCheckInToDay.any((element) => (element.id.toString().trim() + element.maKh.toString().trim()).toString() == elementSyn.id.toString());
      //           if(anyCheck == true){
      //
      //             ListCheckIn itemCheckIn = listCheckInToDay.firstWhere((element) => (element.id.toString().trim() + element.maKh.toString().trim()).toString() == elementSyn.id.toString());
      //             if(itemCheckIn.id != null){
      //               int index = listCheckInToDay.indexWhere((element) => (element.id.toString().trim() + element.maKh.toString().trim()).toString() == elementSyn.id.toString());
      //               ListCheckIn itemCheckInUpdate = ListCheckIn(
      //                 id:itemCheckIn.id,
      //                 tieuDe: itemCheckIn.tieuDe,
      //                 ngayCheckin: elementSyn.timeCheckIn != '' ? elementSyn.timeCheckIn :  itemCheckIn.ngayCheckin,
      //                 maKh: itemCheckIn.maKh,
      //                 tenCh: itemCheckIn.tenCh,
      //                 diaChi: itemCheckIn.diaChi,
      //                 dienThoai: itemCheckIn.dienThoai,
      //                 gps: itemCheckIn.gps,
      //                 trangThai: elementSyn.timeCheckOut != '' ? 'Hoàn thành' : itemCheckIn.trangThai,
      //                 isCheckInSuccessful: itemCheckIn.trangThai == 'Hoàn thành' ? true : false,
      //                 tgHoanThanh: elementSyn.timeCheckOut ?? itemCheckIn.tgHoanThanh,
      //                 lastCheckOut: itemCheckIn.lastCheckOut,
      //                 numberTimeCheckOut: itemCheckIn.numberTimeCheckOut
      //               );
      //               listCheckInToDay[index] = itemCheckInUpdate;
      //             }
      //           }
      //         }
      //       }
      if(listCheckInToDay.isNotEmpty){
        for (var element in listCheckInToDay) {
          ItemCheckInOffline itemCheckInOffline = ItemCheckInOffline(
            id: (element.id.toString().trim() + element.maKh.toString().trim()),
            idCheckIn: element.id.toString(),
            tieuDe: element.tieuDe.toString(),
            ngayCheckin: element.ngayCheckin.toString(),
            maKh: element.maKh.toString(),
            tenCh: element.tenCh.toString(),
            diaChi: element.diaChi.toString(),
            dienThoai: element.dienThoai.toString(),
            gps: element.gps.toString(),
            trangThai: element.trangThai.toString(),
            tgHoanThanh: element.tgHoanThanh.toString(),
            lastChko: element.lastCheckOut.toString(),
            latlong: element.latLong.toString(),
            dateSave: Utils.parseDateToString(DateTime.now(), Const.DATE_SV_FORMAT_2),
            numberTimeCheckOut: element.timeCheckOut != null ? int.parse(element.timeCheckOut.toString()) : 0,
            isCheckInSuccessful: 0,
            isSynSuccessful: 0,
            timeCheckOut: '',
            openStore: '', timeCheckIn: '', note: '',
          );
          /// Cửa hàng tự chọn => Close
          /// Cơm tấm sài gòn
          listCheckInOffline.add(itemCheckInOffline);
          db.addListCheckInOffline(itemCheckInOffline);
        }
      } else if(nextScreen == 1){
        return DMSFailure('Úi, Liên hệ Sale Admin để nhận công việc mới');
      }
      if(response.listAlbum!.isNotEmpty){
        for (var element in response.listAlbum!) {
          ItemAlbum itemAlbum = ItemAlbum(
              maAlbum: element.maAlbum,
              tenAlbum: element.tenAlbum,
              ycAnhYN: element.ycAnhYn == true ? 1 : 0,
          );
          ListAlbum item = ListAlbum(
            maAlbum: element.maAlbum,
            tenAlbum: element.tenAlbum,
            ycAnhYn: element.ycAnhYn,
          );
          listItemAlbum.add(item);
          db.addListAlbumOffline(itemAlbum);
        }
      }
      if(response.listTicket!.isNotEmpty){
        for (var element in response.listTicket!) {
          ItemTicket itemTicket = ItemTicket(
            ticketId: element.maTicket,
            tenLoai: element.tenTicket,
          );
          ListAlbumTicketOffLine item = ListAlbumTicketOffLine(
            maTicket: element.maTicket,
            tenTicket: element.tenTicket,
          );
          listAlbumTicketOffLine.add(item);
          db.addListAlbumTicketOffLine(itemTicket);
        }
      }
      return GetListTaskOffLineSuccess(nextScreen: nextScreen);
    }catch(e){
      return DMSFailure('Úi, ${e.toString()}');
    }
  }

  List<ListInventoryRequestResponseData> listInventoryRequest = [];

  DMSState _handleGetListInventoryRequest(Object data){
    if(data is String) return DMSFailure('Úi, ${data.toString()}');
    try{
      ListInventoryRequestResponse response = ListInventoryRequestResponse.fromJson(data as Map<String,dynamic>);
      listInventoryRequest = response.data??[];
      totalPager = response.totalPage!;
      return GetListInventoryRequestSuccess();
    }catch(e){
      return DMSFailure('Úi, ${e.toString()}');
    }
  }
  List<ListItemInventoryResponseData> listItemInventory = [];

  DMSState _handleGetListItemInventory(Object data){
    if(data is String) return DMSFailure('Úi, ${data.toString()}');
    try{
      listItemInventory.clear();
      ListItemInventoryResponse response = ListItemInventoryResponse.fromJson(data as Map<String,dynamic>);
      listItemInventory = response.data??[];
      totalPager = response.totalPage??0;
      return GetListInventorySuccess();
    }catch(e){
      return DMSFailure('Úi, ${e.toString()}');
    }
  }
  List<ListsStockInventoryResponseData> listStockInventory = [];
  DMSState _handleGetListStoreFromSttRecEvent(Object data){
    if(data is String) return DMSFailure('Úi, ${data.toString()}');
    try{
      ListsStockInventoryResponse response = ListsStockInventoryResponse.fromJson(data as Map<String,dynamic>);
      listStockInventory = response.data??[];
      totalPager = response.totalPage??0;
      return GetListStockInventoryRequestSuccess();
    }catch(e){
      return DMSFailure('Úi, ${e.toString()}');
    }
  }

  List<ItemHistoryInventoryResponseData> listItemHistoryInventory = [];
  DMSState _handleGetListHistoryInventory(Object data){
    if(data is String) return DMSFailure('Úi, ${data.toString()}');
    try{
      listItemHistoryInventory.clear();
      ListsHistoryInventoryResponse response = ListsHistoryInventoryResponse.fromJson(data as Map<String,dynamic>);
      listItemHistoryInventory = response.data??[];
      return GetListGetListHistoryInventorySuccess();
    }catch(e){
      return DMSFailure('Úi, ${e.toString()}');
    }
  }

  DMSState _handleUpdateRequestOpenStore(Object data){
    if(data is String) return DMSFailure('Úi, ${data.toString()}');
    try{
      return UpdateNewRequestOpenStoreSuccess();
    }catch(e){
      return DMSFailure('Úi, ${e.toString()}');
    }
  }

  DMSState _handleCancelRequestOpenStore(Object data){
    if(data is String) return DMSFailure('Úi, ${data.toString()}');
    try{
      return CancelRequestOpenStoreSuccess();
    }catch(e){
      return DMSFailure('Úi, ${e.toString()}');
    }
  }

  DMSState _handleLoadListTax(Object data) {
    if (data is String) return DMSFailure('Úi, ${data.toString()}');
    try {

      GetListTaxResponse response = GetListTaxResponse.fromJson(data as Map<String,dynamic>);

      DataLocal.listTax = response.data!;
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
      return DMSFailure('Úi, ${e.toString()}');
    }
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  String namePhuongXa = '';
  String nameQuanHuyen = '';
  String nameTinhThanh = '';

  getUserLocation() async {
    currentLocation = await locateUser();
    List<Placemark> placePoint = await placemarkFromCoordinates(currentLocation.latitude,currentLocation.longitude);
    currentAddress = "${placePoint[0].name}, ${placePoint[0].thoroughfare}, ${placePoint[0].subAdministrativeArea}, ${placePoint[0].administrativeArea}";
    namePhuongXa = placePoint[0].thoroughfare.toString();
    nameQuanHuyen = placePoint[0].subAdministrativeArea.toString();
    nameTinhThanh = placePoint[0].administrativeArea.toString();
    print(currentAddress);
    //time = DateFormat("HH:mm:ss").format(DateTime.now()).toString();
  }

  DMSState _handleLoadListStatusOrder(Object data) {
    if (data is String) return DMSFailure('Úi, ${data.toString()}');
    try {
      DataLocal.listStatus.clear();
      ListStatusOrderResponse response = ListStatusOrderResponse.fromJson(data as Map<String,dynamic>);
      DataLocal.listStatus = response.data??[];
      return GetListStatus();
    } catch (e) {
      return DMSFailure('Úi, ${e.toString()}');
    }
  }
  DMSState _handleUpdateInventory(Object data) {
    if (data is String) return DMSFailure('Úi, ${data.toString()}');
    try {
      return UpdateInventorySuccess();
    } catch (e) {
      return DMSFailure('Úi, ${e.toString()}');
    }
  }
  DMSState _handleUpdateHistoryInventory(Object data) {
    if (data is String) return DMSFailure('Úi, ${data.toString()}');
    try {
      return UpdateHistoryInventory();
    } catch (e) {
      return DMSFailure('Úi, ${e.toString()}');
    }
  }

  void _getTotalUnreadNotification(GetTotalUnreadNotificationEvent event,
      Emitter<DMSState> emitter) async {
    emitter(DMSLoading());

    try {
      Object data = await networkFactory!.getTotalUnreadNotification(
        _accessToken!,
      );

      if (data is Map<String, dynamic>) {
        if (data['recordUnRead'] != null && data['recordUnRead'] is int) {
          int recordUnRead = data['recordUnRead'];
          totalUnreadNotification = recordUnRead;
          box.write(Const.TOTAL_UNREAD_NOTIFICATION, recordUnRead);
          emitter(GetTotalUnreadNotificationSuccess());
        } else {
          emitter(DMSFailure(''));
        }
      }
    } catch (e) {
      emitter(DMSFailure('Úi: ${e.toString()}'));
    }
  }
}