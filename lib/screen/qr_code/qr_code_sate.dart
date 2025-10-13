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

class GetInformationItemFromBarCodeNotSuccess extends QRCodeState{

  final String barcode;

  GetInformationItemFromBarCodeNotSuccess({required this.barcode});

  @override
  String toString() {
    return 'GetInformationItemFromBarCodeNotSuccess{barcode: $barcode}';
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
  final int action;

  UpdateQuantityInWarehouseDeliveryCardSuccess({required this.action});

  @override
  String toString() {
    return 'UpdateQuantityInWarehouseDeliveryCardSuccess{action: $action}';
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

class StockTransferConfirmSuccess extends QRCodeState {
  final int action;

  StockTransferConfirmSuccess({required this.action});

  @override
  String toString() {
    return 'StockTransferConfirmSuccess{action: $action}';
  }
}

class DeleteItemSuccess extends QRCodeState {

  @override
  String toString() {
    return 'DeleteItemSuccess{}';
  }
}

class DeleteItemFailure extends QRCodeState {
  final String error;

  DeleteItemFailure(this.error);

  @override
  String toString() {
    return 'DeleteItemFailure{error: $error}';
  }
}

class GetRuleBarCodeSuccess extends QRCodeState{
  @override
  String toString() {
    return 'GetRuleBarCodeSuccess{}';
  }
}

class CreateRefundBarcodeHistorySuccess extends QRCodeState{
  @override
  String toString() {
    return 'CreateRefundBarcodeHistorySuccess{}';
  }
}

class GetValueBarcodeSuccess extends QRCodeState{
  @override
  String toString() {
    return 'GetValueBarcodeSuccess{}';
  }
}


class SearchSuggestSuccess extends QRCodeState{
  @override
  String toString() {
    return 'SearchSuggestSuccess{}';
  }
}

class CheckShowCloseSuccess extends QRCodeState{
  @override
  String toString() {
    return 'CheckShowCloseSuccess{}';
  }
}

class GetItemBarcodeFromDMINSuccess extends QRCodeState{
  @override
  String toString() {
    return 'GetItemBarcodeFromDMINSuccess{}';
  }
}

class GetListHistoryDNNKSuccess extends QRCodeState{
  @override
  String toString() {
    return 'GetListHistoryDNNKSuccess{}';
  }
}


class GetValueFromBarCodeSuccess extends QRCodeState{
  final double kilogram;
  final String expirationDate;
  final String valueScanBarcode;

  GetValueFromBarCodeSuccess({
    required this.kilogram,
    required this.expirationDate,
    required this.valueScanBarcode
  });

  @override
  String toString() {
    return 'GetValueFromBarCodeSuccess{kilogram: $kilogram, expirationDate: $expirationDate, valueScanBarcode: $valueScanBarcode}';
  }
}