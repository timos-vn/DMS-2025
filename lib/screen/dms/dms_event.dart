import 'package:equatable/equatable.dart';

import 'inventory/model/draft_ticket.dart';


abstract class DMSEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsDMSEvent extends DMSEvent {
  @override
  String toString() => 'GetPrefsDMSEvent';
}

class GetListStatusOrder extends DMSEvent {
  final String vcCode;

  GetListStatusOrder({required this.vcCode});
  @override
  String toString() => 'GetListStatusOrder {}';
}

class GetListInventoryRequest extends DMSEvent {
  final String searchKey;
  final int pageIndex;

  GetListInventoryRequest({required this.searchKey, required this.pageIndex});


  @override
  String toString() => 'GetListInventoryRequest {}';
}

class FindProvinceEvent extends DMSEvent {

  final String? province;
  final String? district;
  final int typeGetList;
  final String keysText;
  final String? idArea;

  FindProvinceEvent({this.province,this.district,required this.typeGetList, required this.keysText, this.idArea});

  @override
  String toString() => 'FindProvinceEvent {}';
}

class AutoMapAddressFromGPSEvent extends DMSEvent {
  @override
  String toString() => 'AutoMapAddressFromGPSEvent';
}

class GetListItemInventoryEvent extends DMSEvent {
  final String searchKey;
  final String sttRec;
  final int pageIndex;

  GetListItemInventoryEvent({required this.sttRec, required this.searchKey,required this.pageIndex});


  @override
  String toString() => 'GetListItemInventoryEvent {}';
}class GetListStoreFromSttRecEvent extends DMSEvent {
  final String sttRec;
  GetListStoreFromSttRecEvent({required this.sttRec});


  @override
  String toString() => 'GetListStoreFromSttRecEvent {}';
}
class GetListHistoryInventoryEvent extends DMSEvent {
  final String sttRec;
  final int pageIndex;
  GetListHistoryInventoryEvent({required this.sttRec,required this.pageIndex});


  @override
  String toString() => 'GetListHistoryInventoryEvent {}';
}

class GetValuesClient extends DMSEvent {
  @override
  String toString() => 'GetValuesClient';
}

class GetListRequestOpenStore extends DMSEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String? dateTime;
  final String? dateFrom;
  final String? dateTo;
  final int? status;
  final String? idKhuVuc;
  GetListRequestOpenStore({this.isRefresh = false, this.isLoadMore = false,
    this.dateTime,this.status,this.idKhuVuc, this.dateFrom,this.dateTo});

  @override
  String toString() => 'GetListRequestOpenStore {}';
}
class GetCameraEvent extends DMSEvent {

  @override
  String toString() {
    return 'GetCameraEvent{}';
  }
}

class GetDetailOpenStoreEvent extends DMSEvent {

  final String idRequestOpenStore;

  GetDetailOpenStoreEvent(this.idRequestOpenStore);

  @override
  String toString() {
    return 'GetCameraEvent{}';
  }
}

class CancelOpenStoreEvent extends DMSEvent {

  final String idRequestOpenStore;
  final String idTour;

  CancelOpenStoreEvent(this.idRequestOpenStore,this.idTour);

  @override
  String toString() {
    return 'CancelOpenStoreEvent{}';
  }
}



class UpdateRequestOpenStoreEvent extends DMSEvent {

  final String idRequestOpenStore;
  final String nameCustomer ;
  final String phoneCustomer;
  final String nameStore;
  final String address;
  final String idTour;
  final String email;
  final String birthDay;
  final String note;
  final String? mst;
  final String? desc;
  final String? phoneStore;
  final String idProvince;
  final String idDistrict;
  final String idCommune;
  final String? gps;
  final String idArea;
  final String idTypeStore;
  final String idStoreForm;
  final String idState;

  UpdateRequestOpenStoreEvent({ required this.idRequestOpenStore,
    required this.nameCustomer,required  this.phoneCustomer,required  this.nameStore,required  this.address,
    required  this.idTour,required  this.email, required this.birthDay,
    required  this.note, this.mst,this.desc,this.phoneStore,
    required this.idCommune,required this.idProvince,required this.idDistrict,this.gps,required this.idArea,
    required this.idTypeStore,required this.idStoreForm,required this.idState
});

  @override
  String toString() {
    return 'UpdateRequestOpenStoreEvent{}';
  }
}

class AddNewRequestOpenStoreEvent extends DMSEvent {

  final String nameCustomer ;
  final String phoneCustomer;
  final String nameStore;
  final String address;
  final String idTour;
  final String email;
  final String birthDay;
  final String note;
  final String? mst;
  final String? desc;
  final String? phoneStore;
  final String idProvince;
  final String idDistrict;
  final String idCommune;
  final String? gps;
  final String idArea;
  final String idTypeStore;
  final String idStoreForm;
  final String idState;

  AddNewRequestOpenStoreEvent({
    required this.nameCustomer,required  this.phoneCustomer,required  this.nameStore,required  this.address,
    required  this.idTour,required  this.email, required this.birthDay,
    required  this.note, this.mst,this.desc,this.phoneStore,
    required this.idCommune,required this.idProvince,required this.idDistrict,this.gps,required this.idArea,
    required this.idTypeStore,required this.idStoreForm,required this.idState
  });

  @override
  String toString() {
    return 'AddNewRequestOpenStoreEvent{}';
  }
}

class GetListTaskOffLineEvent extends DMSEvent {

  final int nextScreen;

  GetListTaskOffLineEvent({required this.nextScreen});

  @override
  String toString() {
    return 'GetListTaskOffLineEvent{}';
  }
}

class GetListVVHD extends DMSEvent {
  @override
  String toString() => 'GetListVVHD';
}

class GetListTax extends DMSEvent {
  @override
  String toString() => 'GetListTax';
}

class GetTotalUnreadNotificationEvent extends DMSEvent {
  @override
  String toString() {
    return 'GetTotalUnreadNotificationEvent{}';
  }
}
class UpdateInventoryEvent extends DMSEvent {
  final DraftTicket currentDraft;
  final String sttRec;

  UpdateInventoryEvent({required this.currentDraft,required this.sttRec});
  @override
  String toString() {
    return 'UpdateInventoryEvent{}';
  }
}
class UpdateHistoryInventoryEvent extends DMSEvent {
  final DraftTicket currentDraft;
  final String sttRec;

  UpdateHistoryInventoryEvent({required this.currentDraft,required this.sttRec});
  @override
  String toString() {
    return 'UpdateHistoryInventoryEvent{}';
  }
}
class SelectItemInventory extends DMSEvent {
  final int? index;

  SelectItemInventory(this.index);
}
class UpdateUIEvent extends DMSEvent {
  // final bool? dMSInventoryState;
  //
  // UpdateUIEvent(this.dMSInventoryState);
}