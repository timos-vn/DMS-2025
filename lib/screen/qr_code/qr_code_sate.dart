import 'package:equatable/equatable.dart';

import '../../model/network/response/get_information_item_from_barcode_response.dart';

abstract class QRCodeState extends Equatable {
  @override
  List<Object> get props => [];
}
class GrantCameraPermission extends QRCodeState {

  @override
  String toString() {
    return 'GrantCameraPermission{}';
  }
}
class InitialQRCodeState extends QRCodeState {

  @override
  String toString() {
    return 'InitialQRCodeState{}';
  }
}

class GetPrefsSuccess extends QRCodeState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class GetInformationCardSuccess extends QRCodeState{

  final bool updateLocation;

  GetInformationCardSuccess({required this.updateLocation});

  @override
  String toString() {
    return 'GetInformationCardSuccess{}';
  }
}class GetKeyBySttRecSuccess extends QRCodeState{

  final String valuesKey;
  final String sttRec;
  final String title;

  GetKeyBySttRecSuccess( {required this.valuesKey,required this.sttRec,required  this.title,});

  @override
  String toString() {
    return 'GetKeyBySttRecSuccess{}';
  }
}
class GetInformationItemFromBarCodeSuccess extends QRCodeState{

  final InformationProduction informationProduction;

  GetInformationItemFromBarCodeSuccess({required this.informationProduction});

  @override
  String toString() {
    return 'GetInformationItemFromBarCodeSuccess{}';
  }
}
class GetQuantityForTicketSuccess extends QRCodeState{

  final bool allowCreate;

  GetQuantityForTicketSuccess({required this.allowCreate});

  @override
  String toString() {
    return 'GetQuantityForTicketSuccess{}';
  }
}

class QRCodeLoading extends QRCodeState {

  @override
  String toString() => 'QRCodeLoading';
}

class QRCodeFailure extends QRCodeState {
  final String error;

  QRCodeFailure(this.error);

  @override
  String toString() => error;
}
class UpdateQuantityInWarehouseDeliveryCardSuccess extends QRCodeState {

  @override
  String toString() {
    return 'UpdateQuantityInWarehouseDeliveryCardSuccess{}';
  }
}class UpdateItemBarCodeSuccess extends QRCodeState {

  final int action;

  UpdateItemBarCodeSuccess({required this.action});

  @override
  String toString() {
    return 'UpdateItemBarCodeSuccess{}';
  }
}class CreateDeliverySuccess extends QRCodeState {

  @override
  String toString() {
    return 'CreateDeliverySuccess{}';
  }
}class ItemLocationModifySuccess extends QRCodeState {

  @override
  String toString() {
    return 'ItemLocationModifySuccess{}';
  }
}class ConfirmPostPNFSuccess extends QRCodeState {

  @override
  String toString() {
    return 'ConfirmPostPNFSuccess{}';
  }
}