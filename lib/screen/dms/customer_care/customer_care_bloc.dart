import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dms/utils/const.dart';

import '../../../model/network/response/list_customer_care_response.dart';
import '../../../model/network/services/network_factory.dart';
import '../../../utils/utils.dart';
import '../../../model/entity/survey_data.dart'; // ✅ Import SurveyDataList
import 'customer_care_event.dart';
import 'customer_care_state.dart';


class CustomerCareBloc extends Bloc<CustomerCareEvent,CustomerCareState>{
  NetWorkFactory? _networkFactory;
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


  String? customerName;
  String? phoneCustomer;
  String? addressCustomer;
  String? codeCustomer;
  String? noteSell;

  List<GetListHistoryCustomerCareResponseData> _listHistoryCustomerCare = <GetListHistoryCustomerCareResponseData>[];
  List<GetListHistoryCustomerCareResponseData> get listHistoryCustomerCare => _listHistoryCustomerCare;

  List<String> listImage = [];

  List<File> listFileInvoice = [];

  bool isPhone = false;
  bool isEmail =false;
  bool isSMS =false;
  bool isMXH =false;
  bool isOther =false;
  List<String> typeCare = [];


  CustomerCareBloc(this.context) : super(InitialCustomerCareState()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsCustomerCareEvent>(_getPrefs);
    on<AddNewCustomerCareEvent>(_addNewCustomerCareEvent);
    on<GetCameraEvent>(_getCameraEvent);
    on<GetListCustomerCareEvent>(_getListCustomerCareEvent);
    on<PickInfoCustomer>(_pickInfoCustomer);
    on<CheckInTransferEvent>(_checkInTransferEvent);
    on<AddNote>(_addNote);
  }

  final box = GetStorage();
  void _getPrefs(GetPrefsCustomerCareEvent event, Emitter<CustomerCareState> emitter)async{
    emitter(InitialCustomerCareState());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    userName = box.read(Const.USER_NAME);
    emitter(GetPrefsCustomerCareSuccess());
  }

  void _checkInTransferEvent(CheckInTransferEvent event, Emitter<CustomerCareState> emitter)async{
    emitter(InitialCustomerCareState());
    switch (event.index){
      case 1:
        if(isPhone == true){
          isPhone = false;
          typeCare.remove('Phone');
        }else{
          isPhone = true;
          typeCare.add('Phone');
        }
        break;
      case 2:
        if(isEmail == true){
          isEmail = false;
          typeCare.remove('Email');
        }else{
          isEmail = true;
          typeCare.add('Email');
        }
        break;
      case 3:
        if(isSMS == true){
          isSMS = false;
          typeCare.remove('SMS');
        }else{
          isSMS = true;
          typeCare.add('SMS');
        }
        break;
      case 4:
        if(isMXH == true){
          isMXH = false;
          typeCare.remove('MXH');
        }else{
          isMXH = true;
          typeCare.add('MXH');
        }
        break;
      case 5:
        if(isOther == true){
          // isOther = false;
          typeCare.remove('isOther');
        }else{
          // isOther = true;
          typeCare.add('isOther');
        }
        break;
    }
    emitter(ChooseTypeCareSuccess());
  }

  void _addNote(AddNote event, Emitter<CustomerCareState> emitter){
    emitter(InitialCustomerCareState());
    noteSell = event.note;
    emitter(AddNoteSuccess());
  }

  void _pickInfoCustomer(PickInfoCustomer event, Emitter<CustomerCareState> emitter){
    emitter(InitialCustomerCareState());
    customerName = event.customerName;
    phoneCustomer = event.phone;
    addressCustomer = event.address;
    codeCustomer = event.codeCustomer;
    emitter(PickInfoCustomerSuccess());
  }

  void _addNewCustomerCareEvent(AddNewCustomerCareEvent event, Emitter<CustomerCareState> emitter)async{
    emitter(CustomerCareLoading());

    List<String> valuesTypeCare = [];

    if(isPhone == true){
     valuesTypeCare.add('Phone');
    }
    if(isEmail == true){
      valuesTypeCare.add('Email');
    }
    if(isSMS == true){
      valuesTypeCare.add('SMS');
    }
    if(isMXH == true){
      valuesTypeCare.add('MXH');
    }
    if(isOther == true){
      valuesTypeCare.add(event.otherTypeCare);
    }

    // ✅ Lấy dữ liệu khảo sát đã lưu theo customerId
    final surveyData = _getSavedSurveyData(event.idCustomer);
    final surveyJsonString = surveyData != null ? jsonEncode(surveyData.toJson()) : jsonEncode([]);

    var formData = FormData.fromMap(
        {
          "CustomerCode":event.idCustomer.toString(),
          "TypeCare": valuesTypeCare.join(','),
          "Description":event.description.toString().replaceAll("'", "''"),
          "Feedback":event.feedback.toString().replaceAll("'", "''"),
          "ListSurvey": surveyJsonString // ✅ Thay thế "yourSurveyList"
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

    CustomerCareState state = _handleAddNewRequestOpenStore(await _networkFactory!.addNewCustomerCare(formData,_accessToken!));
    emitter(state);
  }

  void _getCameraEvent(GetCameraEvent event, Emitter<CustomerCareState> emitter)async{
    emitter(InitialCustomerCareState());
    Map<Permission, PermissionStatus> permissionRequestResult = await [Permission.location,Permission.camera].request();
    if (permissionRequestResult[Permission.camera] == PermissionStatus.granted) {
      isGrantCamera = true;
      emitter(GrantCameraPermission());
    }
    else {
      if (await Permission.camera.isPermanentlyDenied) {
        emitter(InitialCustomerCareState());
      } else {
        isGrantCamera = false;
        emitter(EmployeeScanFailure('Vui lòng cấp quyền truy cập Camera.'));
      }
    }
  }


  void _getListCustomerCareEvent(GetListCustomerCareEvent event, Emitter<CustomerCareState> emitter)async{
    emitter(InitialCustomerCareState());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? CustomerCareLoading()
        : InitialCustomerCareState());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        CustomerCareState state = await handleCallApi(i,event.dateFrom.toString(),event.dateTo.toString(),event.idCustomer.toString());
        if (state is! GetListHistoryCustomerCareSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    CustomerCareState state = await handleCallApi(_currentPage,event.dateFrom.toString(),event.dateTo.toString(),event.idCustomer.toString());
    emitter(state);
  }


  Future<CustomerCareState> handleCallApi(int pageIndex,String dateForm, String dateTo, String idCustomer) async {

    CustomerCareState state = _handleLoadList(
        await _networkFactory!.getListHistoryCustomerCare(_accessToken!,dateForm,dateTo,idCustomer == 'null' ? '' : idCustomer ,pageIndex,_maxPage), pageIndex);
    return state;
  }

  CustomerCareState _handleLoadList(Object data, int pageIndex) {
    if (data is String) return CustomerCareFailure('Úi, $data');
    try {
      GetListHistoryCustomerCareResponse response = GetListHistoryCustomerCareResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 20;
      List<GetListHistoryCustomerCareResponseData> list = response.listCustomerCare!;
      if (!Utils.isEmpty(list) && _listHistoryCustomerCare.length >= (pageIndex - 1) * _maxPage + list.length) {
        _listHistoryCustomerCare.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          _listHistoryCustomerCare = list;
        } else {
          _listHistoryCustomerCare.addAll(list);
        }
      }
      if (Utils.isEmpty(_listHistoryCustomerCare)) {
        return GetListCustomerCareEmpty();
      } else {
        isScroll = true;
      }
      return GetListHistoryCustomerCareSuccess();
    } catch (e) {
      return CustomerCareFailure('Úi, ${e.toString()}');
    }
  }

  /// ✅ Lấy dữ liệu khảo sát đã lưu theo customerId
  SurveyDataList? _getSavedSurveyData(String customerId) {
    try {
      final storageKey = '${Const.SURVEY_DATA}_$customerId';
      final jsonData = box.read(storageKey);
      if (jsonData != null) {
        return SurveyDataList.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      print('❌ Lỗi khi lấy survey data: $e');
      return null;
    }
  }

  CustomerCareState _handleAddNewRequestOpenStore(Object data){
    if(data is String) return CustomerCareFailure('Úi, ${data.toString()}');
    try{
      return AddNewCustomerCareSuccess();
    }catch(e){
      return CustomerCareFailure('Úi, ${e.toString()}');
    }
  }
}