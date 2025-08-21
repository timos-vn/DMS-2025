import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dms/model/database/data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dms/model/network/services/network_factory.dart';
import 'package:dms/utils/const.dart';

import '../../../../model/database/dbhelper.dart';
import '../../../../model/entity/item_check_in.dart';
import '../../../../model/network/response/list_image_store_response.dart';
import '../../../../model/network/response/list_ticket_response.dart';
import '../../../../utils/utils.dart';
import 'ticket_event.dart';
import 'ticket_state.dart';


class TicketBloc extends Bloc<TicketEvent,TicketState>{
  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  DatabaseHelper db = DatabaseHelper();

  int _currentPage = 1;
  int _maxPage = 20;
  bool isScroll = true;
  int get maxPage => _maxPage;
  String userName = '';
  String idTicket = '';
  String nameTicket = '';
  bool isGrantCamera = false;

  List<ListImageFile> listFileTicket = [];

  List<ListTicketResponseData> _listTicket = <ListTicketResponseData>[];
  List<ListTicketResponseData> get listTicket => _listTicket;

  List<ItemListTicketOffLine> listTicketOffLine = [];

  TicketBloc(this.context) : super(InitialTicketState()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsTicket>(_getPrefs);
    on<GetListTicket>(_getListTicket);
    on<GetCameraEvent>(_getCameraEvent);
    on<AddNewTicketEvent>(_addNewTicketEvent);
    on<GetListTicketLocal>(_getListTicketLocal);
    on<PickAlbumTicket>(_pickAlbumTicket);
    on<DeleteOrUpdateTicketEvent>(_deleteOrUpdateTicketEvent);
  }
  final box = GetStorage();
  void _getPrefs(GetPrefsTicket event, Emitter<TicketState> emitter)async{
    emitter(InitialTicketState());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    userName = box.read(Const.USER_NAME);
    emitter(GetPrefsSuccess());
  }

  void _getListTicketLocal(GetListTicketLocal event, Emitter<TicketState> emitter)async{
    emitter(InitialTicketState());
    DataLocal.listTicketLocal = await db.getListTicketOffLine();
    List<ItemListTicketOffLine>  listTicketOffLines = DataLocal.listTicketLocal;
    emitter(GetListTicketOffLineSuccess(listTicketOffLine: listTicketOffLines));
  }

  void _pickAlbumTicket(PickAlbumTicket event, Emitter<TicketState> emitter){
    emitter(TicketLoading());
    idTicket = event.idAlbumTicket;
    nameTicket = event.nameAlbumTicket;
    if(listTicketOffLine.isNotEmpty){
      listTicketOffLine.clear();
    }
    for (var element in DataLocal.listTicketLocal) {
      if(element.idTicketType?.trim() == event.idAlbumTicket.trim() && element.id.toString().trim() == event.idCheckIn.toString().trim()){
        listTicketOffLine.add(element);
      }
    }
    emitter(PickAlbumTicketSuccess());
  }

  void _addNewTicketEvent(AddNewTicketEvent event, Emitter<TicketState> emitter)async{
    emitter(TicketLoading());
    if(event.addNew == false){
      db.deleteListTicketOffLine(event.idIncrement.toString());
    }
    String pathFile = '';
    String nameFile = '';
    if(listFileTicket.isNotEmpty){
      for (var element in listFileTicket) {
        pathFile = pathFile == '' ? element.fileImage!.path : '$pathFile,${element.fileImage!.path}';
        nameFile = nameFile == '' ? element.fileName.toString() : '$nameFile,${element.fileName}';
      }
    }
    ItemListTicketOffLine item = ItemListTicketOffLine (
      customerCode: event.idCustomer.trim(),
      idCheckIn: event.idCheckIn,
      nameTicketType: event.nameTicketType,
      idTicketType: event.idTicketType,
      id: event.idCheckIn.trim() + event.idCustomer.trim(),
      comment: event.comment,
      dateTimeCreate: DateTime.now().toString(),
      status: '0',
      filePath: pathFile,
      fileName: nameFile,
      listFileTicket: pathFile != '' ? pathFile.split(',') : []
    );

    db.addListTicketOffLine(item);
    listTicketOffLine.add(item);
    DataLocal.listTicketLocal.add(item);
    emitter(AddNewTicketSuccess());
    // var formData = FormData.fromMap(
    //     {
    //       "CustomerCode":event.idCustomer,
    //       "TicketType":event.idTicketType,
    //       "TaskId":event.idCheckIn,
    //       "Comment":event.comment,
    //     }
    // );
    // if(listFileTicket.isNotEmpty){
    //   for (var element in listFileTicket) {
    //     formData.files.addAll([
    //       MapEntry("ListFile",await MultipartFile.fromFile(element.fileImage!.path))
    //     ]);
    //   }
    // }
    // else{
    //   const MapEntry("ListFile","");
    // }
    // TicketState state = _handleAddNewTicket(await _networkFactory!.addNewTicket(formData,_accessToken!));
    // emitter(state);
  }

  void _deleteOrUpdateTicketEvent(DeleteOrUpdateTicketEvent event, Emitter<TicketState> emitter)async{
    emitter(TicketLoading());
    db.deleteListTicketOffLine(event.idIncrement.toString());
    if(event.deleteAction == true){
      emitter(DeleteTicketSuccess());
    }
    else{
      String pathFile = '';
      String nameFile = '';
      if(listFileTicket.isNotEmpty){
        for (var element in listFileTicket) {
          pathFile = pathFile == '' ? element.fileImage!.path : '$pathFile,${element.fileImage!.path}';
          nameFile = nameFile == '' ? element.fileName.toString() : '$nameFile,${element.fileName}';
        }
      }
      ItemListTicketOffLine item = ItemListTicketOffLine (
        customerCode: event.customerCode.toString().trim(),
        idCheckIn: event.idCheckIn.toString().trim(),
        nameTicketType: event.nameTicketType,
        idTicketType: event.idTicketType,
        id: event.idCheckIn.toString().trim() + event.customerCode.toString().trim(),
        idIncrement: event.idIncrement,
        comment: event.comment,
        dateTimeCreate: DateTime.now().toString(),
        status: '0',
        filePath: pathFile,
        fileName: nameFile,
        listFileTicket: pathFile != '' ? pathFile.split(',') : []
      );
      db.addListTicketOffLine(item);
      emitter(UpdateTicketSuccess());
    }
  }

  void _getCameraEvent(GetCameraEvent event, Emitter<TicketState> emitter)async{
    emitter(InitialTicketState());
    Map<Permission, PermissionStatus> permissionRequestResult = await [Permission.location,Permission.camera].request();
    if (permissionRequestResult[Permission.camera] == PermissionStatus.granted) {
      isGrantCamera = true;
      emitter(GrantCameraPermission());
    }
    else {
      if (await Permission.camera.isPermanentlyDenied) {
        emitter(InitialTicketState());
      } else {
        isGrantCamera = false;
        emitter(EmployeeScanFailure('Vui lòng cấp quyền truy cập Camera.'));
      }
    }
  }

  void _getListTicket(GetListTicket event, Emitter<TicketState> emitter)async{
    emitter(InitialTicketState());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? TicketLoading()
        : InitialTicketState());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        TicketState state = await handleCallApi(i,event.idCustomer.toString(),event.idCheckIn.toString(),event.idTypeTicket.toString());
        if (state is! GetListTicketSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    TicketState state = await handleCallApi(_currentPage,event.idCustomer.toString(),event.idCheckIn.toString(),event.idTypeTicket.toString());
    emitter(state);
  }


  Future<TicketState> handleCallApi(int pageIndex,String idCustomer, String idCheckIn, String idTypeTicket) async {

    TicketState state = _handleLoadList(await _networkFactory!.getListTicket(_accessToken!,idCustomer.trim(),idCheckIn,idTypeTicket.trim(),pageIndex,_maxPage), pageIndex);
    return state;
  }

  TicketState _handleLoadList(Object data, int pageIndex) {
    if (data is String) return TicketFailure('Úi, ${data.toString()}');
    try {
      ListTicketResponse response = ListTicketResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 20;
      List<ListTicketResponseData> list = response.data!;
      if (!Utils.isEmpty(list) && _listTicket.length >= (pageIndex - 1) * _maxPage + list.length) {
        _listTicket.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          _listTicket = list;
        } else {
          _listTicket.addAll(list);
        }
      }
      if (Utils.isEmpty(_listTicket)) {
        return GetListTicketEmpty();
      } else {
        isScroll = true;
      }
      return GetListTicketSuccess();
    } catch (e) {
      return TicketFailure('Úi, ${e.toString()}');
    }
  }


  TicketState _handleAddNewTicket(Object data){
    if(data is String) return TicketFailure('Úi, ${data.toString()}');
    try{
      return AddNewTicketSuccess();
    }catch(e){
      return TicketFailure('Úi, ${e.toString()}');
    }
  }

}