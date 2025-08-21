import 'package:dms/model/network/response/list_checkin_response.dart';
import 'package:equatable/equatable.dart';

import '../../../model/entity/item_check_in.dart';

abstract class CheckInEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsCheckIn extends CheckInEvent {
  @override
  String toString() => 'GetPrefsCheckIn';
}

class GetLocationDifferent extends CheckInEvent {

  final String addressDifferent;
  final double lat;
  final double long;

  GetLocationDifferent({required this.addressDifferent,required this.lat,required this.long});

  @override
  String toString() => 'GetLocationDifferent';
}

class CheckingLocationDifferent extends CheckInEvent {

  final String addressDifferent;

  CheckingLocationDifferent({required this.addressDifferent});

  @override
  String toString() => 'CheckingLocationDifferent';
}

class GetListCheckIn extends CheckInEvent {
  final DateTime dateTime;
  final int pageIndex;
  final String userId;

  GetListCheckIn({required this.dateTime, required this.pageIndex,required this.userId});
  @override
  String toString() => 'GetListCheckIn: $dateTime';
}

class UpdateListCheckIn extends CheckInEvent {

  @override
  String toString() => 'UpdateListCheckIn';
}

class GetDetailCheckInOnlineEvent extends CheckInEvent {
  final int idCheckIn;
  final String idCustomer;

  GetDetailCheckInOnlineEvent({required this.idCheckIn, required this.idCustomer});
  @override
  String toString() => 'GetDetailCheckInOnlineEvent: $idCheckIn';
}

class GetDetailCheckIn extends CheckInEvent {
  final int idCheckIn;
  final String idCustomer;

  GetDetailCheckIn({required this.idCheckIn, required this.idCustomer});
  @override
  String toString() => 'GetDetailCheckIn: $idCheckIn';
}

class ChangeStatusStoreOpen extends CheckInEvent {
  @override
  String toString() => 'ChangeStatusStoreOpen:';
}

class GetListImage extends CheckInEvent {
  @override
  String toString() => 'ChangeStatusStoreOpen:';
}

class SaveTimeCheckOut extends CheckInEvent {
  final int idCheckIn;
  final String idCustomer;
  final String nameStore;
  final String dateTime;
  final String title;
  final String latLong;
  final DateTime ngayCheckIn;
  final int numberTimeCheckOut;

  SaveTimeCheckOut({required this.idCheckIn,required this.idCustomer,required this.nameStore,required this.dateTime, required this.title, required this.latLong, required this.ngayCheckIn, required this.numberTimeCheckOut});

  @override
  String toString() => 'SaveTimeCheckOut:';
}

class GetTimeCheckOutSave extends CheckInEvent {

  final int idCheckIn;
  // final String title;
  final String idCustomer;
  final ListCheckIn itemSelect;
  // final bool isCheckInSuccess;
  // final String nameStore;
  // final DateTime? dateCheckIn;
  // final String latLong;
  // final String tenKh;
  // final String trangThai;
  // final String dienThoai;
  // final String diaChi;
  // final String ngayCheckin;
  // final String tgHoanThanh;
  //
  GetTimeCheckOutSave({required this.idCheckIn, required this.idCustomer, required this.itemSelect
  //   required this.isCheckInSuccess, required this.nameStore, this.dateCheckIn, required this.latLong,required this.title,
  //   required this.tenKh, required this. trangThai, required this.diaChi, required this.dienThoai, required this.ngayCheckin,
  //   required this.tgHoanThanh
  });

  @override
  String toString() => 'GetTimeCheckOutSave';
}

class GetListSynCheckInEvent extends CheckInEvent {

  @override
  String toString() => 'GetListSynCheckInEvent';
}

class SynCheckInEvent extends CheckInEvent {

  @override
  String toString() => 'SynCheckInEvent';
}


class GetImageLocalEvent extends CheckInEvent {

  @override
  String toString() => 'GetImageLocalEvent';
}


class UpdateTimeCheckOutSave extends CheckInEvent {

  final int idCheckIn;
  final String idCustomer;
  final String nameStore;
  final String dateTime;
  final String title;
  final DateTime ngayCheckIn;

  UpdateTimeCheckOutSave({required this.idCheckIn,required this.idCustomer ,required this.nameStore, required this.dateTime,required this.title, required this.ngayCheckIn});

  @override
  String toString() => 'UpdateTimeCheckOutSave:';
}

class CheckOutInventoryStock extends CheckInEvent {

  final int idCheckIn;
  final String idCustomer;
  final bool openStore;
  final DateTime ngayCheckIn;
  final String note;
  final String? gps;
  final int numberTimeCheckOut;
  final ListCheckIn item;

  CheckOutInventoryStock({required this.idCheckIn,required this.idCustomer,required this.openStore,
    required this.ngayCheckIn, required this.note, required this.numberTimeCheckOut, required this.item,
    this.gps});

  @override
  String toString() => 'SaveInventoryStock:';
}

class CheckOutInventoryStockOnline extends CheckInEvent {
  final int idCheckIn;
  final String idCustomer;
  final ItemCheckInOffline itemCheckIn;

  CheckOutInventoryStockOnline({required this.idCheckIn,required this.idCustomer, required this.itemCheckIn});

  @override
  String toString() => 'CheckOutInventoryStockOnline:';
}

class GetListAlbumImageCheckIn extends CheckInEvent {

  final String idAlbum;

  GetListAlbumImageCheckIn({required this.idAlbum});

  @override
  String toString() => 'GetListAlbumImageCheckIn:';
}
//
// class GetListImageStore extends CheckInEvent {
//
//   final bool isRefresh;
//   final bool isLoadMore;
//   final String? idCustomer;
//   final String? idCheckIn;
//   final String? idAlbum;
//   GetListImageStore({this.isRefresh = false, this.isLoadMore = false,this.idCustomer,this.idCheckIn, this.idAlbum});
//
//   @override
//   String toString() => 'GetListImageStore {}';
// }

class GetListTaskOffLineEvent extends CheckInEvent {

  final bool reloadData;

  GetListTaskOffLineEvent({required this.reloadData});

  @override
  String toString() {
    return 'GetListTaskOffLineEvent{}';
  }
}