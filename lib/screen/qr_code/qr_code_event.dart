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

  GetInformationItemFromBarCodeEvent({required this.barcode});

  @override
  String toString() => 'GetInformationItemFromBarCodeEvent: barcode $barcode';
}

class UpdateQuantityInWarehouseDeliveryCardEvent extends QRCodeEvent {

  final String licensePlates;
  final List<UpdateQuantityInWarehouseDeliveryCardDetail> listItem;

  UpdateQuantityInWarehouseDeliveryCardEvent({required this.licensePlates, required this.listItem});

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

  GetListHistoryDNNKEvent({required this.sttRec});

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
class UpdateItemBarCodeEvent extends QRCodeEvent {
  final String? sttRec;
  final int action;
  final List<UpdateItemBarCodeRequestDetail> listItem;

  UpdateItemBarCodeEvent({required this.listItem,required this.action,this.sttRec});

  @override
  String toString() => 'UpdateItemBarCodeEvent: listItem $listItem';
}

class RefreshUpdateItemBarCodeEvent extends QRCodeEvent {

  @override
  String toString() => 'RefreshUpdateItemBarCodeEvent';
}

class ConfirmPostPNFEvent extends QRCodeEvent {

  final String sttRec;

  ConfirmPostPNFEvent({required this.sttRec});

  @override
  String toString() => 'ConfirmPostPNFEvent: sttRec $sttRec';
}
class ItemLocationModifyEvent extends QRCodeEvent {

  final List<ItemLocationModifyRequestDetail> listItem;

  ItemLocationModifyEvent({required this.listItem});

  @override
  String toString() => 'ItemLocationModifyEvent: listItem $listItem';
}

