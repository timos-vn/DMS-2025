import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dms/extension/extension_compare_date.dart';
import 'package:dms/model/database/data_local.dart';
import 'package:dms/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import 'package:dms/model/entity/app_settings.dart';
import 'package:dms/model/network/request/get_list_checkin_request.dart';
import 'package:dms/model/network/response/list_checkin_response.dart';
import 'package:dms/model/network/services/network_factory.dart';
import 'package:dms/utils/const.dart';

import '../../../model/database/dbhelper.dart';
import '../../../model/entity/image_check_in.dart';
import '../../../model/entity/item_check_in.dart';
import '../../../model/network/response/detail_checkin_response.dart';
import '../../../model/network/response/list_image_store_response.dart';
import '../../../model/network/response/list_task_offline_response.dart';
import 'check_in_event.dart';
import 'check_in_state.dart';
import '../../../services/location_service.dart';


class CheckInBloc extends Bloc<CheckInEvent,CheckInState>{
  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? userName;
  String userId = '';
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;
  int indexBanner = 0;
  bool openStore = true;
  DatabaseHelper db = DatabaseHelper();

  int _currentPage = 1;
  int get currentPage => _currentPage;
  int _maxPage = 20;
  bool isScroll = true;
  int get maxPage => _maxPage;

  String idAlbum = '';
  String nameAlbum = '';
  bool isGrantCamera = false;



  List<AppSettings> listAppSettings = <AppSettings>[];

  List<ItemCheckInOffline> listSynCheckIn = <ItemCheckInOffline>[];

  // List<ItemCheckInOffline> listDataCheckIn = <ItemCheckInOffline>[];
  ItemCheckInOffline itemCurrentCheckIn = ItemCheckInOffline();

  // List<ListCheckIn> listCheckInToDay = <ListCheckIn>[];
  List<ListCheckIn> listCheckInOther = <ListCheckIn>[];

  List<ListAlbum> listAlbum = [];
  List<ListAlbumTicketOffLine> listTicket = [];

  List<ListImageFile> listFileAlbumView = <ListImageFile>[];

  final List<ListImage> _listImage = <ListImage>[];
  List<ListImage> get listImage => _listImage;

  List<ImageCheckIn> listImageCheckIn = <ImageCheckIn>[];

  int totalPager = 0;

  Position? currentLocation;
  String currentAddress = '';
  List<ItemCheckInOffline> listCheckInOffline = [];
  DetailCheckInMaster detailCheckInMaster = DetailCheckInMaster();

  List<ItemCheckInOffline> listDataCheckInCheck = <ItemCheckInOffline>[];

  Future<List<AppSettings>> getListFromDb() {
    return db.fetchAllAppSettings();
  }

  Future<List<ItemCheckInOffline>> getListDataCheckInFromDb() {
    return db.fetchAllListCheckIn();
  }

  String addressDifferent = '';
  double lat = 0;
  double long = 0;

  CheckInBloc(this.context) : super(InitialCheckInState()){
    listIdUploadTicket = [];
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsCheckIn>(_getPrefs);
    on<GetListCheckIn>(_getListCheckIn);
    on<GetDetailCheckIn>(_getDetailCheckIn);
    on<ChangeStatusStoreOpen>(_changeStatusStoreOpen);
    on<SaveTimeCheckOut>(_saveTimeCheckOut);
    on<GetTimeCheckOutSave>(_getTimeCheckOutSave);
    on<UpdateTimeCheckOutSave>(_updateTimeCheckOutSave);
    on<CheckOutInventoryStock>(_checkOutInventoryStock);
    // on<GetListImageStore>(_getListImageStore);
    on<GetListSynCheckInEvent>(_getListSynCheckInEvent);
    on<GetImageLocalEvent>(_getImageLocalEvent);
    on<SynCheckInEvent>(_synCheckInEvent);
    on<UpdateListCheckIn>(_updateListCheckIn);
    on<GetListTaskOffLineEvent>(_getListTaskOffLineEvent);
    on<GetDetailCheckInOnlineEvent>(_getDetailCheckInOnlineEvent);
    on<CheckOutInventoryStockOnline>(_checkOutInventoryStockOnline);
    on<GetLocationDifferent>(_getLocationDifferent);
    on<CheckingLocationDifferent>(_checkingLocationDifferent);
  }
  final box = GetStorage();
  void _getPrefs(GetPrefsCheckIn event, Emitter<CheckInState> emitter)async{
    emitter(InitialCheckInState());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    userName = box.read(Const.USER_NAME);
    userId = box.read(Const.USER_ID);
    listDataCheckInCheck = await getListDataCheckInFromDb();
    emitter(GetPrefsSuccess());
  }

  void _getLocationDifferent(GetLocationDifferent event, Emitter<CheckInState> emitter)async{
    emitter(InitialCheckInState());
    addressDifferent = event.addressDifferent.toString();
    lat = event.lat;
    long = event.long;
    emitter(GetLocationDifferentSuccessful());
  }

  void _checkingLocationDifferent(CheckingLocationDifferent event, Emitter<CheckInState> emitter)async{
    emitter(InitialCheckInState());
    addressDifferent = event.addressDifferent.toString();
    emitter(GetLocationDifferentSuccessful());
  }

  void _checkOutInventoryStock(CheckOutInventoryStock event, Emitter<CheckInState> emitter)async{
    emitter(CheckInLoading());
    // Đảm bảo DataLocal.idCurrentCheckIn được set đúng cho khách hàng hiện tại
    DataLocal.idCurrentCheckIn = (event.idCheckIn.toString() + event.idCustomer.trim());
    if(Const.checkInOnline == true){
      listImageCheckIn = await getListImageCheckInFromDb();
      listTicketOffLine = await db.getListTicketOffLine();
    }
    // Refresh listDataCheckInCheck từ database để đảm bảo có dữ liệu mới nhất
    listDataCheckInCheck = await getListDataCheckInFromDb();
    ItemCheckInOffline itemCheckIn = ItemCheckInOffline();
    // print('listDataCheckInCheck: ${listDataCheckInCheck.length}');
    // print('-----');
    // for (var element in listDataCheckInCheck) {
    //   print('${element.id} - ${DataLocal.idCurrentCheckIn}');
    // }
    // print('-----');
    if(listDataCheckInCheck.isNotEmpty){
      print("DataLocal.idCurrentCheckIn: ${DataLocal.idCurrentCheckIn}");
      bool checkIsExits = listDataCheckInCheck.any((element) => element.id == DataLocal.idCurrentCheckIn);
      if(checkIsExits == true){
        ItemCheckInOffline itemValue = listDataCheckInCheck.firstWhere((element) => element.id == DataLocal.idCurrentCheckIn);
        if(itemValue.id != null){
          print('isJoin');
          // Sử dụng DataLocal.dateTimeStartCheckIn thay vì itemValue.timeCheckIn để đảm bảo dùng đúng thời gian check-in của khách hàng hiện tại
          String timeCheckInToUse = DataLocal.dateTimeStartCheckIn.isNotEmpty 
              ? DataLocal.dateTimeStartCheckIn 
              : (itemValue.timeCheckIn ?? '');
          print('timeCheckInToUse: $timeCheckInToUse');
          print('DataLocal.dateTimeStartCheckIn: ${DataLocal.dateTimeStartCheckIn}');
          print('itemValue.timeCheckIn: ${itemValue.timeCheckIn}');
          itemCheckIn = ItemCheckInOffline(
              id: itemValue.id,
              tenCh: itemValue.tenCh,
              maKh: itemValue.maKh,
              latlong: itemValue.latlong,
              diaChi: itemValue.diaChi,
              idCheckIn: itemValue.idCheckIn,
              timeCheckIn: timeCheckInToUse,
              openStore: event.openStore.toString(),
              timeCheckOut: DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now()),
              tieuDe: itemValue.tieuDe,
              ngayCheckin: event.ngayCheckIn.toString(),
              gps: event.gps.toString().replaceAll('null', ''),
              lastChko: itemValue.lastChko,
              dienThoai: itemValue.dienThoai,
              trangThai: 'Hoàn thành',
              dateSave: itemValue.dateSave,
              numberTimeCheckOut: event.numberTimeCheckOut,
              tgHoanThanh: DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now()),
              note: event.note,
              isCheckInSuccessful: 1,
              isSynSuccessful: 1,
              addressDifferent: DataLocal.addressDifferent,
              latDifferent: DataLocal.latDifferent,
              longDifferent: DataLocal.longDifferent
          );
          if(Const.checkInOnline == false){
            await db.updateListCheckIn(itemCheckIn);
            await db.updateListCheckInOffline(itemCheckIn);
          }
        }
      }
    }
    if(Const.checkInOnline == true){
      emitter(CheckOutAddItemSuccess(itemCheckIn));
    }else{
      DataLocal.addressDifferent = '';
      DataLocal.latDifferent = 0;
      DataLocal.longDifferent = 0;
      db.deleteAllAppSettings();
      listAppSettings.clear();
      emitter(CheckOutSuccess());
    }
  }

  void _checkOutInventoryStockOnline(CheckOutInventoryStockOnline event, Emitter<CheckInState> emitter)async{
    emitter(CheckInLoading());
    // print('join');
    // print(listImageCheckIn.length);
    // print(listTicketOffLine.length);
    // print('----${event.itemCheckIn.id}');
    // print(event.itemCheckIn.id != null);
    // print(event.itemCheckIn.id != '');
    // print(event.itemCheckIn.id.toString().isNotEmpty);
    if(event.itemCheckIn.id != null && event.itemCheckIn.id != '' && event.itemCheckIn.id.toString().isNotEmpty){
      if(listFileAlbumView.isNotEmpty){
        listFileAlbumView.clear();
      }
      if(listImageCheckIn.isNotEmpty){
        for (var element in listImageCheckIn) {
          if(element.id == '${event.idCheckIn.toString().trim()}${event.idCustomer.toString().trim()}' && element.isSync == 0){
            ListImageFile itemFile = ListImageFile(
                id: element.id.toString(),
                fileImage: File(element.filePath.toString()),
                maAlbum: element.maAlbum.toString().trim(),
                tenAlbum: element.tenAlbum.toString(),
                fileName: element.fileName,
                isSync: true
            );
            ImageCheckIn imageCheckIn = ImageCheckIn(
                id: element.id,
                idCheckIn: element.idCheckIn.toString(),
                maAlbum: element.maAlbum.toString().trim(),
                tenAlbum: element.tenAlbum.toString().trim(),
                fileName: element.fileName,
                filePath: element.filePath,
                isSync: 1
            );
            db.updateImageCheckIn(imageCheckIn);
            listFileAlbumView.add(itemFile);
          }
        }
      }

      String jsonString = '';
      if(listFileAlbumView.isNotEmpty){
        jsonString = jsonEncode(listFileAlbumView);
      }
      // print('join2');
      // print(event.itemCheckIn.latlong.toString().replaceAll('null', '').isNotEmpty ?  event.itemCheckIn.latlong.toString() :  event.itemCheckIn.gps.toString());
      // Sử dụng DataLocal.dateTimeStartCheckIn nếu có, nếu không thì dùng từ event.itemCheckIn
      // Đảm bảo sử dụng đúng thời gian check-in của khách hàng hiện tại
      String timeCheckInToUse = DataLocal.dateTimeStartCheckIn.isNotEmpty 
          ? DataLocal.dateTimeStartCheckIn 
          : (event.itemCheckIn.timeCheckIn ?? '');
      
      var formData = FormData.fromMap(
          {
            "CustomerID": event.idCustomer,
            "LatLong": event.itemCheckIn.latlong.toString().replaceAll('null', '').isNotEmpty ?  event.itemCheckIn.latlong.toString() :  event.itemCheckIn.gps.toString(),
            "Location":event.itemCheckIn.diaChi,
            "Note": event.itemCheckIn.note,
            "IdAlbum": jsonString,
            "IdCheckIn": event.itemCheckIn.idCheckIn.toString(),
            "TimeStartCheckIn": timeCheckInToUse,
            "TimeCheckOut": event.itemCheckIn.timeCheckOut,  
            "OpenStore": event.itemCheckIn.openStore == 'true' ? 1 : 0,
            "Status": (event.itemCheckIn.timeCheckOut != '' && event.itemCheckIn.timeCheckOut != null) ? 1 : 0,
            "AddressDifferent" : DataLocal.addressDifferent,
            "LatDifferent" : DataLocal.latDifferent,
            "LongDifferent" : DataLocal.longDifferent,
          }
      );
      print('join3');
      print('DataLocal.dateTimeStartCheckIn: ${DataLocal.dateTimeStartCheckIn}');
      print('event.itemCheckIn.timeCheckIn: ${event.itemCheckIn.timeCheckIn}');
      print('timeCheckInToUse (sẽ gửi lên server): $timeCheckInToUse');
      print('TimeCheckOut: ${event.itemCheckIn.timeCheckOut.toString()}');
      print('join3');
      if(listFileAlbumView.isNotEmpty){
        for (var element in listFileAlbumView) {
          formData.files.addAll([
            MapEntry("ListFile",await MultipartFile.fromFile(element.fileImage!.path))
          ]);
        }
      }
      else{
        const MapEntry("ListFile","");
      }
      // print('done: $formData');
      CheckInState state = _handleCheckOutOnlineData(await _networkFactory!.checkOutStore(formData,_accessToken!),event.itemCheckIn.id.toString().trim(),event.itemCheckIn);
      emitter(state);
    }
    else{
      emitter(CheckInFailure('Úi, lỗi đẩy dữ liệu lên server'));
    }
  }

  CheckInState _handleCheckOutOnlineData(Object data, String id, ItemCheckInOffline itemCheckIn){
    if(data is String) return CheckInFailure('Úi, ${data.toString()}');
    try{
      uploadTicketComment(id);
      if(itemCheckIn.timeCheckOut != ''){
        db.removeImageCacheCheckIn(id.toString().trim());
        db.removeListCheckIn(id.toString());
      }
      db.deleteAllAppSettings();
      listAppSettings.clear();
      DataLocal.addressDifferent = '';
      DataLocal.latDifferent = 0;
      DataLocal.longDifferent = 0;
      return CheckOutSuccess();
    }catch(e){
      return CheckInFailure('Úi, ${e.toString()}');
    }
  }

  Future<List<ImageCheckIn>> getListImageCheckInFromDb() {
    return db.fetchAllImageCheckIn();
  }

  void _getImageLocalEvent(GetImageLocalEvent event, Emitter<CheckInState> emitter)async{
    emitter(CheckInLoading());
    listImageCheckIn = await getListImageCheckInFromDb();
    for(var element in listImageCheckIn){
      if(element.isSync == 1){
        db.removeImageCacheCheckIn(element.id.toString());
      }
    }
    print(listImageCheckIn.length);
    emitter(GetImageCheckInLocalSuccess());
  }

  int numberSync = 0;
  List<ItemListTicketOffLine> listTicketOffLine = [];

  void _synCheckInEvent(SynCheckInEvent event, Emitter<CheckInState> emitter)async{
    emitter(SyncLoading());
    if(listFileAlbumView.isNotEmpty){
      listFileAlbumView.clear();
    }
    if(listImageCheckIn.isNotEmpty){
      for (var element in listImageCheckIn) {
        if(element.id == (listSynCheckIn[numberSync - 1].id) && element.isSync == 0){
          ListImageFile itemFile = ListImageFile(
            id: element.id.toString(),
            fileImage: File(element.filePath.toString()),
            maAlbum: element.maAlbum.toString().trim(),
            tenAlbum: element.tenAlbum.toString(),
            fileName: element.fileName,
              isSync: true
          );
          ImageCheckIn imageCheckIn = ImageCheckIn(
              id: element.id,
              idCheckIn: element.idCheckIn.toString(),
              maAlbum: element.maAlbum.toString().trim(),
              tenAlbum: element.tenAlbum.toString().trim(),
              fileName: element.fileName,
              filePath: element.filePath,
              isSync: 1
          );
          db.updateImageCheckIn(imageCheckIn);
          listFileAlbumView.add(itemFile);
        }
      }
    }
    String jsonString = '';
     if(listFileAlbumView.isNotEmpty){
       jsonString = jsonEncode(listFileAlbumView);
     }

     var formData = FormData.fromMap(
       {
         "CustomerID":listSynCheckIn[numberSync - 1].maKh,
         "LatLong": listSynCheckIn[numberSync - 1].latlong,
         "Location":listSynCheckIn[numberSync - 1].diaChi,
         "Note": listSynCheckIn[numberSync - 1].note,
         "IdAlbum": jsonString,
         "IdCheckIn":listSynCheckIn[numberSync - 1].idCheckIn.toString(),
         "TimeStartCheckIn": listSynCheckIn[numberSync - 1].timeCheckIn,
         "TimeCheckOut": listSynCheckIn[numberSync - 1].timeCheckOut,
         "OpenStore": listSynCheckIn[numberSync - 1].openStore == 'true' ? 1 : 0,
         "Status": (listSynCheckIn[numberSync - 1].timeCheckOut != '' && listSynCheckIn[numberSync - 1].timeCheckOut != null) ? 1 : 0,
         "AddressDifferent" : listSynCheckIn[numberSync - 1].addressDifferent,
         "LatDifferent" : listSynCheckIn[numberSync - 1].latDifferent,
         "LongDifferent" : listSynCheckIn[numberSync - 1].longDifferent,
       }
     );
     if(listFileAlbumView.isNotEmpty){
       for (var element in listFileAlbumView) {
         formData.files.addAll([
           MapEntry("ListFile",await MultipartFile.fromFile(element.fileImage!.path))
         ]);
       }
     }
     else{
       const MapEntry("ListFile","");
     }
     CheckInState state = _handleSyncData(await _networkFactory!.checkOutStore(formData,_accessToken!),listSynCheckIn[numberSync - 1].id.toString().trim());
     emitter(state);

    // String jsonString = '';
    //  if(DataLocal.listFileAlbum.isNotEmpty){
    //    jsonString = jsonEncode(DataLocal.listFileAlbum);
    //  }
    //
    //  var formData = FormData.fromMap(
    //    {
    //      "CustomerID":event.idCustomer,
    //      "LatLong": DataLocal.latLongLocation,
    //      "Location":DataLocal.addressCheckInCustomer,
    //      "Note":"",
    //      "IdAlbum": jsonString,
    //      "IdCheckIn":event.idCheckIn.toString(),
    //      "TimeStartCheckIn": DataLocal.dateTimeStartCheckIn,
    //      "OpenStore": event.openStore == true ? 1 : 0,
    //    }
    //  );
    //  if(DataLocal.listFileAlbum.isNotEmpty){
    //    for (var element in DataLocal.listFileAlbum) {
    //      formData.files.addAll([
    //        MapEntry("ListFile",await MultipartFile.fromFile(element.fileImage!.path))
    //      ]);
    //    }
    //  }
    //  else{
    //    const MapEntry("ListFile","");
    //  }
  }

  List<String> listIdUploadTicket = [];

  Future<void> uploadTicketComment(String id)async{
    for (var element in listTicketOffLine) {
      print('1: ${element.id.toString()}');
      // print('2: ${listSynCheckIn[numberSync - 1].id.toString()}');
      if(element.id.toString().trim() == id.toString()){
        print('ok');
        // print(listSynCheckIn[numberSync - 1].id.toString());
        var formData = FormData.fromMap(
            {
              "CustomerCode":element.customerCode,
              "TicketType":element.idTicketType,
              "TaskId":element.idCheckIn,
              "Comment":element.comment,
            }
        );
        if(element.filePath!.isNotEmpty){
          for (var item in element.filePath!.split(',')) {
            formData.files.addAll([
              MapEntry("ListFile",await MultipartFile.fromFile(item))
            ]);
          }
        }
        else{
          const MapEntry("ListFile","");
        }
        await _networkFactory!.addNewTicket(formData,_accessToken!).whenComplete((){
          db.removeListTicketOffLine(element.idIncrement.toString().trim());
        });
      }
      else{
        print('not ok');
      }
    }
  }

  Future<void> updateListCheckIn()async{
    if(listCheckInOffline.isNotEmpty && listSynCheckIn.isNotEmpty){
      bool locked = false;
      for (var element in listCheckInOffline) {
        if(element.id.toString().trim() == listSynCheckIn[numberSync - 1].id.toString().trim()){
          locked = true;
          element.isSynSuccessful = 0;
          await db.updateListCheckInOffline(element);
        }
        if(locked == true){
          break;
        }
      }
    }
  }

  void _changeStatusStoreOpen(ChangeStatusStoreOpen event, Emitter<CheckInState> emitter)async{
    emitter(InitialCheckInState());
     if(openStore == true){
       openStore = false;
     }else{
       openStore = true;
     }
    // Const.selectedAlbumLock = openStore;
    emitter(ChangeStatusStoreOpenSuccess());
  }

  void _getListSynCheckInEvent(GetListSynCheckInEvent event, Emitter<CheckInState> emitter)async{
    emitter(CheckInLoading());
    listCheckInOffline.clear();
    listCheckInOffline = await db.getListCheckInOffline();
    listTicketOffLine = await db.getListTicketOffLine();
    listSynCheckIn = await db.getListCheckIn();

    numberSync = listSynCheckIn.length;
    print(numberSync);
    emitter(GetListSynCheckInSuccess());
  }

  void _getTimeCheckOutSave(GetTimeCheckOutSave event, Emitter<CheckInState> emitter)async{
    emitter(CheckInLoading());

    listAppSettings = await getListFromDb();
    print('Check time ${listDataCheckInCheck.length}');
    print('DataLocal.idCurrentCheckIn ${DataLocal.idCurrentCheckIn}');
    print('--------------');
    listDataCheckInCheck.forEach((element) {
      print('${element.id} - ${(event.idCheckIn.toString().trim() + event.idCustomer.toString().trim())}');
    });
    // listDataCheckIn = await getListDataCheckInFromDb();
    if(listDataCheckInCheck.isNotEmpty){
      for (var element in listDataCheckInCheck) {
        if(element.id.toString().trim() == (event.idCheckIn.toString().trim() + event.idCustomer.toString().trim())){
          itemCurrentCheckIn = element;
          DataLocal.dateTimeStartCheckIn = itemCurrentCheckIn.timeCheckIn.toString();
          AppSettings valuesCheckOut = AppSettings(
            (event.idCheckIn.toString().trim() + event.idCustomer.toString().trim()),
            element.tieuDe.toString(),
            element.timeCheckIn.toString(),
          );
          await db.updateAppSettings(valuesCheckOut);
          listAppSettings.clear();
          listAppSettings.add(valuesCheckOut);
        }
      }
    }
    emitter(GetTimeCheckOutSaveSuccess(itemSelect: event.itemSelect));
  }

  void _updateTimeCheckOutSave(UpdateTimeCheckOutSave event, Emitter<CheckInState> emitter)async{
    emitter(CheckInLoading());

    DataLocal.dateTimeStartCheckIn = event.dateTime.toString();
    DataLocal.idCurrentCheckIn = (event.idCheckIn.toString() + event.idCustomer.trim());
    ItemCheckInOffline itemCheckIn = ItemCheckInOffline();
    if(itemCurrentCheckIn.id != null){
      itemCheckIn = ItemCheckInOffline(
          id: itemCurrentCheckIn.id,
          tenCh: event.nameStore,
          maKh: itemCurrentCheckIn.maKh,
          latlong: itemCurrentCheckIn.latlong,
          diaChi: itemCurrentCheckIn.diaChi,
          idCheckIn: itemCurrentCheckIn.idCheckIn,
          timeCheckIn: event.dateTime.toString(),
          openStore: '',
          timeCheckOut: '',
          tieuDe: event.title,
          ngayCheckin: event.ngayCheckIn.toString()
      );
    }

    if(itemCheckIn.id != null){
      await db.updateListCheckIn(itemCheckIn);
    }

    AppSettings valuesCheckOut = AppSettings(
      (event.idCheckIn.toString() + event.idCustomer.trim()),
        event.title,
        event.dateTime.toString(),
    );
    await db.updateAppSettings(valuesCheckOut);
    listAppSettings.clear();
    listAppSettings.add(valuesCheckOut);

    emitter(UpdateTimeCheckOutSuccess());
  }

  void _saveTimeCheckOut(SaveTimeCheckOut event, Emitter<CheckInState> emitter)async{
    emitter(CheckInLoading());
    
    DataLocal.idCurrentCheckIn = (event.idCheckIn.toString() + event.idCustomer.trim());
    
    // Kiểm tra xem check-in đã tồn tại chưa để giữ lại thời gian check-in ban đầu
    String timeCheckInToUse = event.dateTime.toString();
    ItemCheckInOffline? existingCheckIn;
    
    if(listDataCheckInCheck.isNotEmpty){
      bool checkIsExits = listDataCheckInCheck.any((element) => element.id == DataLocal.idCurrentCheckIn);
      if(checkIsExits == true){
        existingCheckIn = listDataCheckInCheck.firstWhere((element) => element.id == DataLocal.idCurrentCheckIn);
        // Nếu check-in đã tồn tại, sử dụng thời gian check-in ban đầu từ database
        if(existingCheckIn.timeCheckIn != null && existingCheckIn.timeCheckIn!.isNotEmpty){
          timeCheckInToUse = existingCheckIn.timeCheckIn!;
        }
      }
    } else {
      // Load từ database nếu listDataCheckInCheck rỗng
      listDataCheckInCheck = await getListDataCheckInFromDb();
      if(listDataCheckInCheck.isNotEmpty){
        bool checkIsExits = listDataCheckInCheck.any((element) => element.id == DataLocal.idCurrentCheckIn);
        if(checkIsExits == true){
          existingCheckIn = listDataCheckInCheck.firstWhere((element) => element.id == DataLocal.idCurrentCheckIn);
          if(existingCheckIn.timeCheckIn != null && existingCheckIn.timeCheckIn!.isNotEmpty){
            timeCheckInToUse = existingCheckIn.timeCheckIn!;
          }
        }
      }
    }
    
    DataLocal.dateTimeStartCheckIn = timeCheckInToUse;
    
    // if(DataLocal.latLongLocation.isEmpty && event.latLong.isEmpty){
    //   // currentLocation = await locateUser();
    //   // List<Placemark> placePoint = await placemarkFromCoordinates(currentLocation!.latitude,currentLocation!.longitude);
    //   // currentAddress = "${placePoint[0].name}, ${placePoint[0].thoroughfare}, ${placePoint[0].subAdministrativeArea}, ${placePoint[0].administrativeArea}";
    //   // DataLocal.addressCheckInCustomer = currentAddress;
    //   // DataLocal.latLongLocation = '${currentLocation!.latitude},${currentLocation!.longitude}';
    //   getUserLocation();
    // }

    ItemCheckInOffline itemCheckIn = ItemCheckInOffline(
      id: (event.idCheckIn.toString() + event.idCustomer.trim()),
      maKh: event.idCustomer.toString().trim(),
      tenCh: event.nameStore,
      latlong: event.latLong.isEmpty == true ? DataLocal.latLongLocation : event.latLong,
      diaChi: DataLocal.addressCheckInCustomer,
      idCheckIn: event.idCheckIn.toString().trim(),
      timeCheckIn: timeCheckInToUse, // Sử dụng thời gian check-in ban đầu nếu đã tồn tại
      openStore: existingCheckIn?.openStore ?? '',
      timeCheckOut: existingCheckIn?.timeCheckOut ?? '',
      tieuDe: event.title,
      ngayCheckin: event.ngayCheckIn.toString(),
      numberTimeCheckOut: event.numberTimeCheckOut
    );

    itemCurrentCheckIn = itemCheckIn;

    if(listDataCheckInCheck.isNotEmpty){
      print('${itemCheckIn.id}');
       bool checkIsExits = listDataCheckInCheck.any((element) => element.id == itemCheckIn.id);
       if(checkIsExits == false){
         print('add1');
         listDataCheckInCheck.add(itemCheckIn);
         await db.addListCheckIn(itemCheckIn);
       } else {
         // Nếu đã tồn tại, update với thông tin mới nhưng giữ nguyên timeCheckIn ban đầu
         await db.updateListCheckIn(itemCheckIn);
       }
    }else {
      print('add2');
      listDataCheckInCheck.add(itemCheckIn);
      await db.addListCheckIn(itemCheckIn);
    }

    AppSettings valuesCheckOut = AppSettings(
      (event.idCheckIn.toString() + event.idCustomer.trim()),
        event.title,
        timeCheckInToUse, // Sử dụng thời gian check-in ban đầu nếu đã tồn tại
    );
    await db.addAppSettings(valuesCheckOut);
    listAppSettings = await getListFromDb();
    print('--------------2222');
    listDataCheckInCheck.forEach((element) {
      print('${element.id} - ${(event.idCheckIn.toString().trim() + event.idCustomer.toString().trim())}');
    });
    emitter(SaveTimeCheckOutSuccess());
  }

  // void _getListImageStore(GetListImageStore event, Emitter<CheckInState> emitter)async{
  //   emitter(InitialCheckInState());
  //   bool isRefresh = event.isRefresh;
  //   bool isLoadMore = event.isLoadMore;
  //   emitter( (!isRefresh && !isLoadMore)
  //       ? CheckInLoading()
  //       : InitialCheckInState());
  //   if (isRefresh) {
  //     for (int i = 1; i <= _currentPage; i++) {
  //       CheckInState state = await handleCallApi(i,event.idCustomer.toString(),event.idCheckIn.toString(),event.idAlbum.toString());
  //       if (state is! GetListImageStoreSuccess) return;
  //     }
  //     return;
  //   }
  //   if (isLoadMore) {
  //     isScroll = false;
  //     _currentPage++;
  //   }
  //   CheckInState state = await handleCallApi(_currentPage,event.idCustomer.toString(),event.idCheckIn.toString(),event.idAlbum.toString());
  //   emitter(state);
  // }


  // Future<CheckInState> handleCallApi(int pageIndex,String idCustomer, String idCheckIn, String idAlbum) async {
  //
  //   CheckInState state = _handleLoadList(
  //       await _networkFactory!.getListImageStore(_accessToken!,idCustomer,idCheckIn,idAlbum,pageIndex,_maxPage), pageIndex);
  //   return state;
  // }

  void _updateListCheckIn(UpdateListCheckIn event, Emitter<CheckInState> emitter)async{
    emitter(CheckInLoading());
    listSynCheckIn = await db.getListCheckIn();
    if(listCheckInOffline.isNotEmpty && listSynCheckIn.isNotEmpty){
      for (var elementSyn in listSynCheckIn) {
        bool anyCheck = listCheckInOffline.any((element) => (element.id.toString().trim() == elementSyn.id.toString()));
        if(anyCheck == true){
          int index = listCheckInOffline.indexWhere((element) => (element.id.toString().trim()) == elementSyn.id.toString());
          ItemCheckInOffline itemCheckInUpdate = ItemCheckInOffline(
            id:elementSyn.id,
            tieuDe: elementSyn.tieuDe,//DateTime parseDate =  DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(elementSyn.timeCheckIn);
            ngayCheckin: elementSyn.timeCheckIn != '' ? elementSyn.timeCheckIn.toString() :  elementSyn.ngayCheckin.toString(),
            maKh: elementSyn.maKh,
            tenCh: elementSyn.tenCh,
            diaChi: elementSyn.diaChi,
            dienThoai: elementSyn.dienThoai,
            gps: elementSyn.gps,
            trangThai: elementSyn.timeCheckOut != '' ? 'Hoàn thành' : elementSyn.trangThai,
            isCheckInSuccessful: elementSyn.trangThai == 'Hoàn thành' ? 1 : 0,
            isSynSuccessful: elementSyn.isSynSuccessful,
            tgHoanThanh: elementSyn.tgHoanThanh,
            lastChko: elementSyn.lastChko,
            timeCheckOut: elementSyn.timeCheckOut,
            idCheckIn: elementSyn.idCheckIn,
            timeCheckIn: elementSyn.timeCheckIn,
            numberTimeCheckOut: elementSyn.numberTimeCheckOut,
            openStore: elementSyn.openStore,
            latlong: elementSyn.latlong,
            dateSave: elementSyn.dateSave,
            note: elementSyn.note,
          );
          listCheckInOffline[index] = itemCheckInUpdate;
        }
      }
    }
    emitter(UpdateListCheckInSuccess());
  }

  void _getListCheckIn(GetListCheckIn event, Emitter<CheckInState> emitter)async{
    emitter(CheckInLoading());
    ListCheckInRequest request = ListCheckInRequest(
        datetime:  event.dateTime.toString(),
        pageIndex: event.pageIndex,
        pageCount: 20,
        userId: event.userId
    );
    listSynCheckIn = await db.getListCheckIn();
    if(Const.checkInOnline == false){
      listAppSettings = await getListFromDb();
    }
    CheckInState state = _handleGetListCheckIn(await _networkFactory!.getListCheckIn(request,_accessToken!),event.dateTime);
    emitter(state);
  }

  void _getDetailCheckIn(GetDetailCheckIn event, Emitter<CheckInState> emitter)async{
    emitter(InitialCheckInState());
    listSynCheckIn = await db.getListCheckIn();
    ItemCheckInOffline checkIsExits = ItemCheckInOffline();
    String id = event.idCheckIn.toString().trim() + event.idCustomer.toString().trim();
    if(listSynCheckIn.isNotEmpty){
      bool isExits = listSynCheckIn.any((element) => element.id == id);
      if(isExits == true){
        checkIsExits = listSynCheckIn.firstWhere((element) => element.id == id);
        if(checkIsExits.id != null){
          DataLocal.dateTimeStartCheckIn  = checkIsExits.timeCheckIn!;
        }
      }
    }
    // CheckInState state = _handleGetDetailCheckIn(await _networkFactory!.getDetailCheckIn(_accessToken!,event.idCheckIn,event.idCustomer), event.idCheckIn.toString(), event.idCustomer);
    emitter(GetDetailCheckInSuccess());
  }

  void _getDetailCheckInOnlineEvent(GetDetailCheckInOnlineEvent event, Emitter<CheckInState> emitter)async{
    emitter(CheckInLoading());
    CheckInState state = _handleGetDetailCheckInOnline(await _networkFactory!.getDetailCheckIn(_accessToken!,event.idCheckIn,event.idCustomer), event.idCheckIn.toString(), event.idCustomer);
    emitter(state);
  }

  // void _getListAlbumImageCheckIn(GetListAlbumImageCheckIn event, Emitter<CheckInState> emitter)async{
  //   emitter(CheckInLoading());
  //   CheckInState state = _handleGetListAlbumCheckIn(await _networkFactory!.getListAlbumImageCheckIn(_accessToken!,event.idAlbum));
  //   emitter(state);
  // }

  void _getListTaskOffLineEvent(GetListTaskOffLineEvent event, Emitter<CheckInState> emitter)async{
    emitter(CheckInLoading());
    CheckInState state = _handleGetListTaskOffLine(await _networkFactory!.getListListTaskOffLine(_accessToken!,DateTime.now().toString()),event.reloadData);
    emitter(state);
  }

  CheckInState _handleGetListTaskOffLine(Object data, bool reloadData){
    if(data is String) return CheckInFailure('Úi, ${data.toString()}');
    try{
      ListTaskOfflineResponse response = ListTaskOfflineResponse.fromJson(data as Map<String,dynamic>);
      List<ItemCheckInOffline> _list = [];
      List<ItemCheckInOffline> listCheckInOld = [] ;
      if(listCheckInOffline.isNotEmpty){
        _list.addAll(listCheckInOffline);
        // listCheckInOld.addAll(listCheckInOffline);

        for (var itemIndex in listCheckInOffline) {
          if(DateTime.now().isBeforeDay(Utils.parseStringToDate(itemIndex.dateSave.toString().trim(), Const.DATE_SV_FORMAT_2)) == false){
            _list.add(itemIndex);
          }
        }
        if(_list.isNotEmpty){
          for (var element in _list) {
            listCheckInOffline.remove(element);
            db.removeListCheckInOffline(element.id.toString());
          }
        }
        for (var element in response.listCheckInToDay!) {
          bool anyCheck = listCheckInOffline.any((elementSyn) => elementSyn.id.toString() == (element.id.toString().trim() + element.maKh.toString().trim()).toString());
          if(anyCheck == false){
            ItemCheckInOffline itemCheckInOffline = ItemCheckInOffline(
              id: (element.id.toString() + element.maKh.toString().trim()),
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
              timeCheckOut: '',
              openStore: '', timeCheckIn: '', note: '',
              isSynSuccessful: 0,
            );
            listCheckInOld.add(itemCheckInOffline);
            // db.addListCheckInOffline(itemCheckInOffline);
          }
        }

        for (var itemValues in listCheckInOffline) {
          bool anyCheck = response.listCheckInToDay!.any((elementSyn) => (elementSyn.id.toString().trim() + elementSyn.maKh.toString().trim()) == itemValues.id.toString().trim());
          if(anyCheck == true){
            ListCheckIn element = response.listCheckInToDay!.firstWhere((elementSyn) => (elementSyn.id.toString().trim() + elementSyn.maKh.toString().trim()) == itemValues.id.toString().trim());
            ItemCheckInOffline itemCheckInOffline = ItemCheckInOffline(
              id: itemValues.id,
              idCheckIn: itemValues.idCheckIn.toString(),
              tieuDe: itemValues.tieuDe.toString(),
              ngayCheckin: itemValues.ngayCheckin.toString(),
              maKh: itemValues.maKh.toString(),
              tenCh: element.tenCh.toString(),
              diaChi: element.diaChi.toString(),
              dienThoai: element.dienThoai.toString(),
              gps: element.gps.toString(),
              trangThai: itemValues.trangThai.toString(),
              tgHoanThanh: itemValues.tgHoanThanh.toString(),
              lastChko: itemValues.lastChko.toString(),
              latlong: element.latLong.toString(),
              dateSave: itemValues.dateSave,
              numberTimeCheckOut: element.timeCheckOut != null ? int.parse(element.timeCheckOut.toString()) : 0,
              isCheckInSuccessful: itemValues.isCheckInSuccessful,
              timeCheckOut: itemValues.timeCheckOut,
              openStore: itemValues.openStore, timeCheckIn: itemValues.timeCheckIn, note: itemValues.note,
              isSynSuccessful: itemValues.isSynSuccessful,
            );
            listCheckInOld.add(itemCheckInOffline);
            // db.addListCheckInOffline(itemCheckInOffline);
          }
        }
      }
      if(listCheckInOld.isNotEmpty){
        db.deleteAllListCheckInOffline();
        listCheckInOffline.clear();
        for (var element in listCheckInOld) {
          listCheckInOffline.add(element);
          db.addListCheckInOffline(element);
        }
      }
      return GetListTaskOffLineSuccess(reloadData: reloadData);
    }catch(e){
      return CheckInFailure('Úi, ${e.toString()}');
    }
  }

  CheckInState _handleSyncData(Object data, String id){
    if(data is String) return CheckInFailure('Úi, ${data.toString()}');
    try{
      // listIdUploadTicket.add(id.toString().trim());
      if(listSynCheckIn[numberSync - 1].timeCheckOut != ''){
        updateListCheckIn();
        uploadTicketComment(id);
        for (var element in listFileAlbumView) {
          db.removeImageCacheCheckIn(element.id.toString());
        }
        db.removeListCheckIn(listSynCheckIn[numberSync - 1].id.toString());
      }
      numberSync = numberSync - 1;
      // if(listFileAlbumView.isNotEmpty){
      //   for (var item in listFileAlbumView) {
      //     listImageCheckIn.removeWhere((element) => element.id == item.id);
      //   }
      //   listFileAlbumView.clear();
      // }
      // listSynCheckIn.removeAt(0);
      // add(GetListSynCheckInEvent());
      return SynCheckInSuccess();
    }catch(e){
      return CheckInFailure('Úi, ${e.toString()}');
    }
  }

  ///

  CheckInState _handleUploadTicketComment(Object data, String id){
    if(data is String) return CheckInFailure('Úi, ${data.toString()}');
    try{
      db.removeListTicketOffLine(id.toString());
      return CheckInLoading();
    }catch(e){
      return CheckInFailure('Úi, ${e.toString()}');
    }
  }

  CheckInState _handleGetListCheckIn(Object data, DateTime day){
    if(data is String) return CheckInFailure('Úi, ${data.toString()}');
    try{
      ListCheckInResponse response = ListCheckInResponse.fromJson(data as Map<String,dynamic>);
      // listCheckInToDay = response.listCheckInToDay!;
      // if(listSynCheckIn.isNotEmpty && listCheckInToDay.isNotEmpty){
      //   for (var elementSyn in listSynCheckIn) {
      //     bool anyCheck = listCheckInToDay.any((element) => (element.id.toString().trim() + element.maKh.toString().trim()).toString() == elementSyn.id.toString());
      //     if(anyCheck == true){
      //       ListCheckIn itemCheckIn = listCheckInToDay.firstWhere((element) => (element.id.toString().trim() + element.maKh.toString().trim()).toString() == elementSyn.id.toString());
      //       if(itemCheckIn.id != null){
      //         int index = listCheckInToDay.indexOf(itemCheckIn);
      //         ListCheckIn itemCheckInUpdate = ListCheckIn(
      //           id:itemCheckIn.id,
      //           tieuDe: itemCheckIn.tieuDe,//DateTime parseDate =  DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(elementSyn.timeCheckIn);
      //           ngayCheckin: elementSyn.timeCheckIn != '' ? elementSyn.timeCheckIn :  itemCheckIn.ngayCheckin,
      //           maKh: itemCheckIn.maKh,
      //           tenCh: itemCheckIn.tenCh,
      //           diaChi: itemCheckIn.diaChi,
      //           dienThoai: itemCheckIn.dienThoai,
      //           gps: itemCheckIn.gps,
      //           trangThai: elementSyn.timeCheckOut != '' ? 'Hoàn thành' : itemCheckIn.trangThai,
      //           isCheckInSuccessful: itemCheckIn.trangThai == 'Hoàn thành' ? true : false,
      //           tgHoanThanh: elementSyn.timeCheckOut ?? itemCheckIn.tgHoanThanh,
      //           lastCheckOut: itemCheckIn.lastCheckOut,
      //         );
      //         listCheckInToDay[index] = itemCheckInUpdate;
      //       }
      //     }
      //   }
      // }
      listCheckInOther = response.listCheckInToDay!;
      totalPager = response.totalPage!;
      if(listSynCheckIn.isNotEmpty && listCheckInOther.isNotEmpty && DateTime.now().isSameDate(day)){
        for (var elementSyn in listSynCheckIn) {
          bool anyCheck = listCheckInOther.any((element) => (element.id.toString().trim() + element.maKh.toString().trim()).toString() == elementSyn.id.toString());
          if(anyCheck == true){
            ListCheckIn itemCheckIn = listCheckInOther.firstWhere((element) => (element.id.toString().trim() + element.maKh.toString().trim()).toString() == elementSyn.id.toString());
            if(itemCheckIn.id != null){
              int index = listCheckInOther.indexOf(itemCheckIn);
              ListCheckIn itemCheckInUpdate = ListCheckIn(
                  id: itemCheckIn.id,
                  tieuDe: itemCheckIn.tieuDe,
                  ngayCheckin: elementSyn.timeCheckIn != '' ? elementSyn.timeCheckIn :  itemCheckIn.ngayCheckin,
                  maKh: itemCheckIn.maKh,
                  tenCh: itemCheckIn.tenCh,
                  diaChi: itemCheckIn.diaChi,
                  dienThoai: itemCheckIn.dienThoai,
                  gps: itemCheckIn.gps,
                  trangThai: (elementSyn.timeCheckOut != '') ? 'Hoàn thành' : itemCheckIn.trangThai,
                  isCheckInSuccessful: itemCheckIn.trangThai == 'Hoàn thành' ? true : false,
                  tgHoanThanh: elementSyn.timeCheckOut ?? itemCheckIn.tgHoanThanh,
                  lastCheckOut: itemCheckIn.lastCheckOut,
                  isSynSuccessful: elementSyn.isSynSuccessful == 1 ? true : false,
                  numberTimeCheckOut: elementSyn.numberTimeCheckOut,
                  latLong: itemCheckIn.latLong,
                  timeCheckOut: itemCheckIn.timeCheckOut,
                  ngayCv: elementSyn.ngayCheckin
              );
              listCheckInOther[index] = itemCheckInUpdate;
            }
          }
        }
      }
      if(listCheckInOther.isEmpty){
        return GetListSCheckInEmpty();
      }else{
        return GetListCheckInSuccess();
      }
    }catch(e){
      return CheckInFailure('Úi, ${e.toString()}');
    }
  }

  // CheckInState _handleGetListAlbumCheckIn(Object data){
  //   if(data is String) return CheckInFailure('Úi, ${data.toString()}');
  //   try{
  //     if(listAlbum.isNotEmpty){
  //       listAlbum.clear();
  //     }
  //     ListAlbumImageCheckInResponse response = ListAlbumImageCheckInResponse.fromJson(data as Map<String,dynamic>);
  //     listAlbum = response.data!;
  //     return GetListAlbumImageCheckInSuccess();
  //   }catch(e){
  //     return CheckInFailure('Úi, ${e.toString()}');
  //   }
  // }

  CheckInState _handleGetDetailCheckInOnline(Object data,String idCheckIn, String idCustomer){
    if(data is String) return CheckInFailure('Úi, ${data.toString()}');
    try{
      DataLocal.listItemAlbum.clear();
      DetailCheckInResponse response = DetailCheckInResponse.fromJson(data as Map<String,dynamic>);
      listAlbum = response.listAlbum!;
      DataLocal.listItemAlbum.addAll(response.listAlbum!);
      listTicket = response.listTicket!;
      ItemCheckInOffline checkIsExits = ItemCheckInOffline();
      String id = idCheckIn.toString().trim() + idCustomer.toString().trim();
      if(listSynCheckIn.isNotEmpty){
        bool isExits = listSynCheckIn.any((element) => element.id == id);
        if(isExits == true){
          checkIsExits = listSynCheckIn.firstWhere((element) => element.id == id);
          if(checkIsExits.id != null){
            DataLocal.dateTimeStartCheckIn  = checkIsExits.timeCheckIn!;
          }
        }
      }

      if(response.master!.isEmpty){
        return GetDetailCheckInEmpty();
      }
      else{
        detailCheckInMaster = DetailCheckInMaster(
          id: response.master![0].id,
          tieuDe: response.master![0].tieuDe,
          ngayCheckin: (checkIsExits.timeCheckIn != '' && checkIsExits.timeCheckIn != null) ? checkIsExits.timeCheckIn : response.master![0].ngayCheckin,
          maKh: response.master![0].maKh,
          tenKh: response.master![0].tenKh,
          tenCh: response.master![0].tenCh,
          diaChi: response.master![0].diaChi,
          dienThoai: response.master![0].dienThoai,
          gps: response.master![0].gps,
          trangThai: (checkIsExits.timeCheckOut != '' && checkIsExits.timeCheckOut != null) ? 'Hoàn thành' : response.master![0].trangThai,
          tgHoanThanh: (checkIsExits.timeCheckOut != '' && checkIsExits.timeCheckOut != null) ? checkIsExits.timeCheckOut : response.master![0].tgHoanThanh,
          hanMucCn: response.master![0].hanMucCn,
          timeCheckOut: response.master![0].timeCheckOut
        );
        return GetDetailCheckInOnlineSuccess();
      }
    }catch(e){
      return CheckInFailure('Úi, ${e.toString()}');
    }
  }

  CheckInState _handleGetDetailCheckIn(Object data,String idCheckIn, String idCustomer){
    if(data is String) return CheckInFailure('Úi, ${data.toString()}');
    try{
      DetailCheckInResponse response = DetailCheckInResponse.fromJson(data as Map<String,dynamic>);
      // listAlbum = response.listAlbum!;
      // listTicket = response.listTicket!;
      ItemCheckInOffline checkIsExits = ItemCheckInOffline();
      String id = idCheckIn.toString().trim() + idCustomer.toString().trim();
      if(listSynCheckIn.isNotEmpty){
        bool isExits = listSynCheckIn.any((element) => element.id == id);
        if(isExits == true){
          checkIsExits = listSynCheckIn.firstWhere((element) => element.id == id);
          if(checkIsExits.id != null){
            DataLocal.dateTimeStartCheckIn  = checkIsExits.timeCheckIn!;
          }
        }
      }

      if(response.master!.isEmpty){
        return GetDetailCheckInEmpty();
      }else{
        // detailCheckInMaster = DetailCheckInMaster(
        //   id: response.master![0].id,
        //   tieuDe: response.master![0].tieuDe,
        //   ngayCheckin: (checkIsExits.timeCheckIn != '' && checkIsExits.timeCheckIn != null) ? checkIsExits.timeCheckIn : response.master![0].ngayCheckin,
        //   maKh: response.master![0].maKh,
        //   tenKh: response.master![0].tenKh,
        //   tenCh: response.master![0].tenCh,
        //   diaChi: response.master![0].diaChi,
        //   dienThoai: response.master![0].dienThoai,
        //   gps: response.master![0].gps,
        //   trangThai: (checkIsExits.timeCheckOut != '' && checkIsExits.timeCheckOut != null) ? 'Hoàn thành' : response.master![0].trangThai,
        //   tgHoanThanh: (checkIsExits.timeCheckOut != '' && checkIsExits.timeCheckOut != null) ? checkIsExits.timeCheckOut : response.master![0].tgHoanThanh,
        //   hanMucCn: response.master![0].hanMucCn,
        //   timeCheckOut: response.master![0].timeCheckOut
        // );
        return GetDetailCheckInSuccess();
      }
    }catch(e){
      return CheckInFailure('Úi, ${e.toString()}');
    }
  }

  // CheckInState _handleLoadList(Object data, int pageIndex) {
  //   if (data is String) return CheckInFailure('Úi, $data');
  //   try {
  //     ListImageStoreResponse response = ListImageStoreResponse.fromJson(data as Map<String,dynamic>);
  //     if(listAlbum.isNotEmpty){
  //       listAlbum.clear();
  //     }
  //     if(listFileAlbumView.isNotEmpty){
  //       listFileAlbumView.clear();
  //     }
  //     listAlbum = response.listAlbum!;
  //     _maxPage = 20;
  //     List<ListImage> list = response.listImage!;
  //     if (!Utils.isEmpty(list) && _listImage.length >= (pageIndex - 1) * _maxPage + list.length) {
  //       _listImage.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
  //     } else {
  //       if (_currentPage == 1) {
  //         _listImage = list;
  //       } else {
  //         _listImage.addAll(list);
  //       }
  //     }
  //     if (Utils.isEmpty(_listImage)) {
  //       return GetListImageStoreEmpty();
  //     } else {
  //       isScroll = true;
  //     }
  //     return GetListImageStoreSuccess();
  //   } catch (e) {
  //     return CheckInFailure('Úi, ${e.toString()}');
  //   }
  // }
  late StreamSubscription<Position> positionStream;

  testLocation()async{
    List<Location> locations = await locationFromAddress("36, Phố Đặng Thai Mai, , Hà Nam");
    List<Placemark> placePoint = await placemarkFromCoordinates(locations[0].latitude,locations[0].longitude).catchError((err){
      stopListenLocation(err.toString());
      return <Placemark>[];
    });
    print(placePoint); print(placePoint);
  }

  getUserLocation({double? lat, double? long, bool isCheck = false}) async {
    print('📍 CheckInBloc: getUserLocation called - using LocationService...');
    
    try {
      LocationResult result = await LocationService.getLocationWithRetry(
        forceFresh: true,
        maxRetries: 3,
      );
      
      if (result.isSuccess) {
        currentLocation = result.position!;
        print('📍 LocationService success: accuracy=${result.accuracy}m, attempt=${result.attempt}');
        
        if (result.warning != null) {
          print('⚠️ ${result.warning}');
        }
        
        if(isCheck){
          // emit(CheckLocationSuccessState());
        }
      } else {
        print('❌ LocationService failed: ${result.error}');
        // emit(CheckInFailure(result.error ?? 'Không thể lấy vị trí GPS'));
      }
      
    } catch (e) {
      print('❌ getUserLocation error: $e');
      // emit(CheckInFailure('Lỗi hệ thống khi lấy vị trí GPS: $e'));
    }
  }

    // currentLocation = await locateUser();
    // List<Placemark> placePoint = await placemarkFromCoordinates(currentLocation.latitude,currentLocation.longitude);
    // currentAddress = "${placePoint[0].name}, ${placePoint[0].thoroughfare}, ${placePoint[0].subAdministrativeArea}, ${placePoint[0].administrativeArea}";
    // DataLocal.addressCheckInCustomer = currentAddress;
    // DataLocal.latLongLocation = '${currentLocation.latitude},${currentLocation.longitude}';
    // print('Checking-Location1: ${DataLocal.latLongLocation}');
    // print('Checking-AddressCheckInCustomer1: ${DataLocal.addressCheckInCustomer}');

  void stopListenLocation(String err){
    print(err);
    positionStream.cancel();
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  // Public method để các screen khác có thể gọi
  Future<void> getFreshLocation({bool isCheck = false}) async {
    await getUserLocation(isCheck: isCheck);
  }



}
