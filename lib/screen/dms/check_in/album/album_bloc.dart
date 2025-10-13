import 'dart:async';
import 'package:dms/model/database/data_local.dart';
import 'package:dms/model/entity/image_check_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:dms/model/network/services/network_factory.dart';
import 'package:dms/services/location_service.dart';
import 'package:dms/utils/const.dart';

import '../../../../model/database/dbhelper.dart';
import '../../../../model/entity/item_check_in.dart';
import '../../../../model/network/response/detail_checkin_response.dart';
import '../../../../model/network/response/list_image_store_response.dart';
import '../../../../utils/utils.dart';
import 'album_event.dart';
import 'album_state.dart';


class AlbumBloc extends Bloc<AlbumEvent,AlbumState>{
  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? userName;
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



  List<ListAlbum> listAlbum = [];

  List<ListImageFile> listFileAlbumView = <ListImageFile>[];
  List<ListImageFile> listFileAlbumCloseStoreView = <ListImageFile>[];

  List<ListImage> _listImage = <ListImage>[];
  List<ListImage> get listImage => _listImage;

  late Position currentLocation;
  String currentAddress = '';


  Future<List<ImageCheckIn>> getListImageCheckInFromDb() {
    return db.fetchAllImageCheckIn();
  }

  AlbumBloc(this.context) : super(InitialAlbumState()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsAlbum>(_getPrefs);
    on<GetListImageStore>(_getListImageStore);
    on<PickAlbumImage>(_pickAlbumImage);
    on<GetCameraEvent>(_getCameraEvent);
    on<AddImageLocalEvent>(_addImageLocalEvent);
    on<GetImageLocalEvent>(_getImageLocalEvent);
    on<DeleteImageLocalEvent>(_deleteImageLocalEvent);
    on<DeleteAllImageLocalEvent>(_deleteAllImageLocalEvent);
  }
  final box = GetStorage();
  void _getPrefs(GetPrefsAlbum event, Emitter<AlbumState> emitter)async{
    emitter(InitialAlbumState());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    userName = box.read(Const.USER_NAME);

    if(DataLocal.listItemAlbum.isEmpty){
      List<ItemAlbum> list = await db.getListAlbumOffline();
      if(list.isNotEmpty){
        for (var element in list) {
          ListAlbum item = ListAlbum(
            maAlbum: element.maAlbum,
            tenAlbum: element.tenAlbum,
            ycAnhYn: element.ycAnhYN == 1 ? true : false,
          );
          DataLocal.listItemAlbum.add(item);
        }
      }
    }
    emitter(GetPrefsSuccess());
  }

  void _getCameraEvent(GetCameraEvent event, Emitter<AlbumState> emitter)async{
    emitter(InitialAlbumState());
    Map<Permission, PermissionStatus> permissionRequestResult = await [Permission.location,Permission.camera].request();
    if (permissionRequestResult[Permission.camera] == PermissionStatus.granted) {
      isGrantCamera = true;
      emitter(GrantCameraPermission());
    }
    else {
      if (await Permission.camera.isPermanentlyDenied) {
        emitter(InitialAlbumState());
      } else {
        isGrantCamera = false;
        emitter(EmployeeScanFailure('Vui lòng cấp quyền truy cập Camera.'));
      }
    }
  }

  void _addImageLocalEvent(AddImageLocalEvent event, Emitter<AlbumState> emitter)async{
    emitter(AlbumLoading());
    await db.addImageCheckIn(event.imageCheckInItem);
    DataLocal.addImageToAlbum = true;
    emitter(AddImageCheckInSuccess());
  }

  void _deleteImageLocalEvent(DeleteImageLocalEvent event, Emitter<AlbumState> emitter)async{
    emitter(AlbumLoading());
    await db.deleteImageCheckIn(event.fileName.toString());
    emitter(DeleteImageCheckInSuccess());
  }

  void _deleteAllImageLocalEvent(DeleteAllImageLocalEvent event, Emitter<AlbumState> emitter)async{
    emitter(AlbumLoading());
    await db.deleteAllImageCheckIn();
    DataLocal.addImageToAlbum = false;
    emitter(DeleteAllImageCheckInSuccess());
  }

  void _getImageLocalEvent(GetImageLocalEvent event, Emitter<AlbumState> emitter)async{
    emitter(AlbumLoading());
    List<ImageCheckIn> listImageCheckIn = await getListImageCheckInFromDb();
    emitter(GetImageCheckInLocalSuccess(listImageCheckIn: listImageCheckIn));
  }


  void _getListImageStore(GetListImageStore event, Emitter<AlbumState> emitter)async{
    emitter(InitialAlbumState());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? AlbumLoading()
        : InitialAlbumState());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        AlbumState state = await handleCallApi(i,event.idCustomer.toString(),event.idCheckIn.toString(),event.idAlbum.toString());
        if (state is! GetListImageStoreSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    AlbumState state = await handleCallApi(_currentPage,event.idCustomer.toString(),event.idCheckIn.toString(),event.idAlbum.toString());
    emitter(state);
  }


  Future<AlbumState> handleCallApi(int pageIndex,String idCustomer, String idCheckIn, String idAlbum) async {

    AlbumState state = _handleLoadList(await _networkFactory!.getListImageStore(_accessToken!,idCustomer.trim(),idCheckIn,idAlbum.trim(),pageIndex,_maxPage), pageIndex);
    return state;
  }

  void _pickAlbumImage(PickAlbumImage event, Emitter<AlbumState> emitter){
    emitter(AlbumLoading());
    if(idAlbum.trim() != event.idAlbumImage){
      idAlbum = event.idAlbumImage;
      nameAlbum = event.nameAlbumImage;
      if(listFileAlbumView.isNotEmpty){
        listFileAlbumView.clear();
      }
      for (var element in DataLocal.listFileAlbum) {
        if(element.maAlbum?.trim() == event.idAlbumImage.trim()){
          listFileAlbumView.add(element);
        }
      }
    }
    emitter(PickAlbumImageSuccess(event.idAlbumImage));
  }

  AlbumState _handleLoadList(Object data, int pageIndex) {
    if (data is String) return AlbumFailure('Úi, ${data.toString()}');
    try {
      ListImageStoreResponse response = ListImageStoreResponse.fromJson(data as Map<String,dynamic>);

      if(response.listAlbum!.isNotEmpty){
        // if(listAlbum.isNotEmpty){
        //   listAlbum.clear();
        // }
        if(listFileAlbumView.isNotEmpty){
          listFileAlbumView.clear();
        }
        listAlbum = response.listAlbum!;
        _maxPage = 20;
        List<ListImage> list = response.listImage!;

        if (!Utils.isEmpty(list) && _listImage.length >= (pageIndex - 1) * _maxPage + list.length) {
          _listImage.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
        } else {
          if (_currentPage == 1) {
            _listImage = list;
          } else {
            _listImage.addAll(list);
          }
        }
        if (Utils.isEmpty(_listImage)) {
          return GetListImageStoreEmpty();
        } else {
          isScroll = true;
        }
      }
      return GetListImageStoreSuccess();
    } catch (e) {
      return AlbumFailure('Úi, ${e.toString()}');
    }
  }

  // getUserLocation() async {
  //   currentLocation = await locateUser();
  //   List<Placemark> placePoint = await placemarkFromCoordinates(currentLocation.latitude,currentLocation.longitude);
  //   currentAddress = "${placePoint[0].name}, ${placePoint[0].thoroughfare}, ${placePoint[0].subAdministrativeArea}, ${placePoint[0].administrativeArea}";
  //   DataLocal.addressCheckInCustomer = currentAddress;
  //   DataLocal.latLongLocation = '${currentLocation.latitude},${currentLocation.longitude}';
  //   print('Checking-Location1: ${DataLocal.latLongLocation}');
  //   print('Checking-AddressCheckInCustomer1: ${DataLocal.addressCheckInCustomer}');
  // }

  late StreamSubscription<Position> positionStream;

  getUserLocation() async {
    print('📍 AlbumBloc: Getting location using LocationService...');
    
    try {
      // Sử dụng LocationService thay vì logic cũ
      LocationResult result = await LocationService.getLocationWithRetry(
        forceFresh: true,
        maxRetries: 3,
      );
      
      if (result.isSuccess) {
        currentLocation = result.position!;
        currentAddress = result.address ?? 'Địa chỉ không xác định';
        DataLocal.addressCheckInCustomer = currentAddress;
        DataLocal.latLongLocation = '${result.position!.latitude},${result.position!.longitude}';
        print('📍 AlbumBloc: Location success - accuracy=${result.accuracy}m');
      } else {
        print('❌ AlbumBloc: Location failed - ${result.error}');
        // Fallback: sử dụng vị trí mặc định hoặc thông báo lỗi
        // emit(AlbumFailure(result.error ?? 'Không thể lấy vị trí GPS'));
      }
    } catch (e) {
      print('❌ AlbumBloc: Location error - $e');
      // emit(AlbumFailure('Lỗi hệ thống khi lấy vị trí GPS: $e'));
    }
  }

  void stopListenLocation(){
    print('Checking-Location12: ${DataLocal.latLongLocation}');
    print('Checking-AddressCheckInCustomer12: ${DataLocal.addressCheckInCustomer}');
    positionStream.cancel();
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }
}