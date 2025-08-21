import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../../model/network/request/new_customer_request.dart';
import '../../../model/network/response/entity_response.dart';
import '../../../model/network/services/network_factory.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../../../utils/validator.dart';
import 'new_customer_event.dart';
import 'new_customer_state.dart';

class NewCustomerBloc extends Bloc<NewCustomerEvent, NewCustomerState> implements Validators {

  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String get accessToken => _accessToken!;
  String? _refreshToken;
  String get refreshToken => _refreshToken!;
  File? _file;
  File get file => _file!;
  String? _errorPhoneNumber;
  String? _errorEmail;
  String? _errorName;
  String? _errorCustomerAddress;
  final bool _phoneVerification = true;

  String _dob = '';
  String get dob => Utils.parseStringDateToString(_dob, Const.DATE_SV_FORMAT, Const.DATE_FORMAT);
  String get errorEmail => _errorEmail!;
  String get errorCustomerAddress => _errorCustomerAddress!;
  String get errorName => _errorName!;
  bool get phoneVerification => _phoneVerification;
  String get errorPhoneNumber => _errorPhoneNumber!;
  // Contact _contact;
  // Contact get contact => _contact;
  // ContactPicker _contactPicker;
  DateTime? _dobDate;
  DateTime get dobDate => _dobDate!;
  int _sex = 0;
  int get sex => _sex;
  String? _avatar;
  String get avatar => _avatar!;

  NewCustomerBloc(this.context) : super(InitialNewCustomerState()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefs>(_getPrefs);
    on<AddNewCustomerEvent>(_addNewCustomerEvent);
    on<ValidatePhoneNumber>(_validatePhoneNumber);
    on<ValidateEmail>(_validateEmail);

    on<ValidateAddress>(_validateAddress);
    on<UploadAvatarEvent>(_uploadAvatarEvent);
    on<PickDate>(_pickDate);
    on<PickGender>(_pickGender);

  }
  final box = GetStorage();
  void _getPrefs(GetPrefs event, Emitter<NewCustomerState> emitter)async{
    emitter(InitialNewCustomerState());
    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsSuccess());
  }

  void _addNewCustomerEvent(AddNewCustomerEvent event, Emitter<NewCustomerState> emitter)async{
    emitter(NewCustomerLoading());
    String codeId = event.code.toString().trim();
    String name = event.name.toString().trim();
    String phoneNumber = event.phoneNumber.toString().trim();
    String email = event.email.toString().trim();
    String address = event.address.toString().trim();


    if (Utils.isEmpty(name) && name.length > 5) {
      _errorName = 'Tên Khách Hàng phải có ít nhất 4 ký tự';
      emitter(NewCustomerFailure(_errorName!));
      emitter(FocusName());
      return;
    }

    _errorPhoneNumber = checkPhoneNumber2(context, phoneNumber)!;
    if (!_phoneVerification && !Utils.isEmpty(errorPhoneNumber)) {
      emitter(NewCustomerFailure(errorPhoneNumber));
      emitter(FocusPhoneNumber());
      return;
    }
    _errorEmail = checkEmail(context, email)!;
    if (!Utils.isEmpty(_errorEmail!)) {
      emitter(NewCustomerFailure(_errorEmail!));
      emitter(FocusEmail());
      return;
    }
    InitialNewCustomerState();
    int cvSex;
    if(_sex == -1){
      cvSex =1;
    }else if(_sex == 0){
      cvSex = 2;
    }else{
      cvSex = _sex;
    }
    NewCustomerRequest request = NewCustomerRequest(
        customerCode: codeId,
        customerName: name,
        customerName2: name,
        gender: cvSex,
        phone: phoneNumber,
        address: address,
        email: email,
        birthday: !Utils.isEmpty(_dob) ? _dob : null
    );
    NewCustomerState state = _handleGetProfile(await _networkFactory!.addNewCustomer(request,_accessToken!));
    emitter(state);
  }

  void _validatePhoneNumber(ValidatePhoneNumber event, Emitter<NewCustomerState> emitter)async{
    emitter(InitialNewCustomerState());
    _errorPhoneNumber = checkPhoneNumber2(context, event.phoneNumber)!;
    emitter(ValidatePhoneNumberError(_errorPhoneNumber!));
  }

  void _validateEmail(ValidateEmail event, Emitter<NewCustomerState> emitter)async{
    emitter(InitialNewCustomerState());
    _errorEmail = checkEmail(context, event.email)!;
    emitter(ValidatePhoneNumberError(_errorEmail!));
  }

  void _validateAddress(ValidateAddress event, Emitter<NewCustomerState> emitter)async{
    emitter(InitialNewCustomerState());
    if (Utils.isEmpty(event.address)) {
      _errorCustomerAddress = 'PleaseEnterAddress';
    } else {
      _errorCustomerAddress = "";
    }
    emitter(ValidatePhoneNumberError(_errorCustomerAddress!));
  }

  void _uploadAvatarEvent(UploadAvatarEvent event, Emitter<NewCustomerState> emitter)async{
    emitter(InitialNewCustomerState());
    // _file = (await ImagePicker.pickImage(
    //     source: event.isUploadFromCamera
    //         ? ImageSource.camera
    //         : ImageSource.gallery,
    //     imageQuality: 80,
    //     maxHeight: 300,
    //     maxWidth: 300)) as File;
    //emitter(PickAvatarSuccess());
  }

  void _pickDate(PickDate event, Emitter<NewCustomerState> emitter)async{
    emitter(InitialNewCustomerState());
    _dobDate = event.dateTime;
    _dob = Utils.parseDateToString(_dobDate!, Const.DATE_SV_FORMAT);
    emitter(PickDateSuccess());
  }

  void _pickGender(PickGender event, Emitter<NewCustomerState> emitter)async{
    emitter(InitialNewCustomerState());
    _sex = event.sex;
    emitter(PickGenderSuccess());
  }


  NewCustomerState _handleGetProfile(Object data,) {
    if (data is String) return NewCustomerFailure(data);
    try {
      /// gui len thanh cong mai lam tiep :)))
      // EntityResponse response = EntityResponse.fromJson(data);
        Navigator.pop(context,'Success');
        return AddNewCustomerSuccess();
    } catch (e) {
      return NewCustomerFailure('Error:${e.toString()}');
    }
  }

  @override
  String? checkEmail(BuildContext context, String email) {
    // TODO: implement checkEmail
    throw UnimplementedError();
  }

  @override
  String? checkHotId(BuildContext context, String username) {
    // TODO: implement checkHotId
    throw UnimplementedError();
  }

  @override
  String? checkPass(BuildContext context, String password) {
    // TODO: implement checkPass
    throw UnimplementedError();
  }

  @override
  String? checkPhoneNumber2(BuildContext context, String phoneNumber) {
    // TODO: implement checkPhoneNumber2
    throw UnimplementedError();
  }

  @override
  String? checkUsername(BuildContext context, String username) {
    // TODO: implement checkUsername
    throw UnimplementedError();
  }
}
