import 'package:equatable/equatable.dart';

import '../../model/network/request/item_location_modify_requset.dart';
import '../../model/network/request/update_item_barcode_request.dart';
import '../../model/network/request/update_quantity_warehouse_delivery_card_request.dart';

abstract class QRCodeEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class GetCameraEvent extends QRCodeEvent {

  @override
  String toString() {
    return 'GetCameraEvent{}';
  }
}
class GetPrefs extends QRCodeEvent {
  @override
  String toString() => 'GetPrefs';
}

class GetInformationCardEvent extends QRCodeEvent {

  final String idCard;
  final String key;
  final bool? updateLocation;

  GetInformationCardEvent({required this.idCard,required this.key,this.updateLocation});

  @override
  String toString() => 'GetInformationCardEvent: idCard $idCard';
}
class GetKeyBySttRecEvent extends QRCodeEvent {

  final String sttRec;

  GetKeyBySttRecEvent({required this.sttRec});

  @override
  String toString() => 'GetKeyBySttRecEvent: sttRec $sttRec';
}
class GetInformationItemFromBarCodeEvent extends QRCodeEvent {

  final String barcode;
  final String pallet;
  final bool? check;
  final bool isPallet;

  GetInformationItemFromBarCodeEvent({required this.barcode,required this.pallet, this.isPallet = false, this.check});

  @override
  String toString() => 'GetInformationItemFromBarCodeEvent: barcode $barcode';
}

class UpdateQuantityInWarehouseDeliveryCardEvent extends QRCodeEvent {

  final String licensePlates;
  final List<UpdateQuantityInWarehouseDeliveryCardDetail> listItem;
  final List<UpdateQuantityInWarehouseDeliveryCardDetail> listBarcode;
  final int action;

  UpdateQuantityInWarehouseDeliveryCardEvent({required this.licensePlates, required this.listItem, required this.listBarcode, required this.action});

  @override
  String toString() => 'UpdateQuantityInWarehouseDeliveryCardEvent: licensePlates $licensePlates';
}


class CreateDeliveryEvent extends QRCodeEvent {

  final String sttRec;
  final String licensePlates;
  final String codeTransfer;

  CreateDeliveryEvent({required this.sttRec,required this.licensePlates,required this.codeTransfer});

  @override
  String toString() => 'CreateDeliveryEvent: sttRec $sttRec';
}class GetListHistoryDNNKEvent extends QRCodeEvent {

  final String sttRec;
  final String keyFunc;

  GetListHistoryDNNKEvent({required this.sttRec, required this.keyFunc});

  @override
  String toString() => 'GetListHistoryDNNKEvent: sttRec $sttRec';
}
class GetQuantityForTicketEvent extends QRCodeEvent {

  final String sttRec;
  final String key;

  GetQuantityForTicketEvent({required this.sttRec,required this.key});

  @override
  String toString() => 'GetQuantityForTicketEvent: sttRec $sttRec';
}

class GetRuleBarCodeEvent extends QRCodeEvent {
  @override
  String toString() => 'GetRuleBarCodeEvent';
}

class CreateRefundBarcodeHistoryEvent extends QRCodeEvent {

  final String sttRec;
  final List<UpdateQuantityInWarehouseDeliveryCardDetail> listBarcode;

  CreateRefundBarcodeHistoryEvent({required this.sttRec, required this.listBarcode});

  @override
  String toString() => 'CreateRefundBarcodeHistoryEvent: sttRec $sttRec';
}

class GetValueBarcodeEvent extends QRCodeEvent {

  final String barcode;

  GetValueBarcodeEvent({required this.barcode});

  @override
  String toString() => 'GetValueBarcodeEvent: barcode $barcode';
}

class DeleteItemEvent extends QRCodeEvent {

  final String sttRec;
  final String sttRec0;
  final String pallet;
  final String barcode;

  DeleteItemEvent({required this.sttRec, required this.sttRec0, required this.pallet, required this.barcode});

  @override
  String toString() => 'DeleteItemEvent: sttRec $sttRec, pallet $pallet, barcode $barcode';
}

class SearchSuggestEvent extends QRCodeEvent {

  final String query;

  SearchSuggestEvent({required this.query});

  @override
  String toString() => 'SearchSuggestEvent: query $query';
}

class CheckShowCloseEvent extends QRCodeEvent {

  final String text;

  CheckShowCloseEvent({required this.text});

  @override
  String toString() => 'CheckShowCloseEvent: text $text';
}

class GetItemBarcodeFromDMINEvent extends QRCodeEvent {

  final String itemCode;

  GetItemBarcodeFromDMINEvent({required this.itemCode});

  @override
  String toString() => 'GetItemBarcodeFromDMINEvent: itemCode $itemCode';
}
class UpdateItemBarCodeEvent extends QRCodeEvent {
  final String? sttRec;
  final int action;
  final List<UpdateItemBarCodeRequestDetail> listItem;
  final List<UpdateItemBarCodeRequestDetail>? listConfirm; // ✅ Thêm listConfirm từ SSE-Scanner

  UpdateItemBarCodeEvent({
    required this.listItem,
    required this.action,
    this.sttRec,
    this.listConfirm, // ✅ Thêm listConfirm parameter
  });

  @override
  String toString() => 'UpdateItemBarCodeEvent: listItem $listItem, listConfirm $listConfirm';
}

class RefreshUpdateItemBarCodeEvent extends QRCodeEvent {

  @override
  String toString() => 'RefreshUpdateItemBarCodeEvent';
}

class ConfirmPostPNFEvent extends QRCodeEvent {

  final String sttRec;
  final List<UpdateQuantityInWarehouseDeliveryCardDetail> listDetail;
  final List<UpdateQuantityInWarehouseDeliveryCardDetail> listBarcode;
  final int action;

  ConfirmPostPNFEvent({required this.sttRec, required this.listDetail, required this.listBarcode, required this.action});

  @override
  String toString() => 'ConfirmPostPNFEvent: sttRec $sttRec';
}

class StockTransferConfirmEvent extends QRCodeEvent {
  final String sttRec;
  final List<UpdateItemBarCodeRequestDetail> listItem;
  final List<UpdateItemBarCodeRequestDetail> listConfirm;

  StockTransferConfirmEvent({required this.sttRec, required this.listItem, required this.listConfirm});

  @override
  String toString() => 'StockTransferConfirmEvent: sttRec $sttRec';
}
class ItemLocationModifyEvent extends QRCodeEvent {

  final List<ItemLocationModifyRequestDetail> listItem;
  final String typeFunction;

  ItemLocationModifyEvent({required this.listItem, required this.typeFunction});

  @override
  String toString() => 'ItemLocationModifyEvent: listItem $listItem, typeFunction $typeFunction';
}

class ResetDataEvent extends QRCodeEvent {
  @override
  String toString() => 'ResetDataEvent: Reset old data to allow new scan';
}

