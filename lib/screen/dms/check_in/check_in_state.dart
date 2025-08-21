import 'package:dms/model/network/response/list_checkin_response.dart';
import 'package:equatable/equatable.dart';

import '../../../model/entity/item_check_in.dart';

abstract class CheckInState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialCheckInState extends CheckInState {

  @override
  String toString() {
    return 'InitialCheckInState{}';
  }
}
class CheckLocationSuccessState extends CheckInState {

  @override
  String toString() {
    return 'CheckLocationSuccessState{}';
  }
}

class GetLocationDifferentSuccessful extends CheckInState {

  @override
  String toString() {
    return 'GetLocationDifferentSuccessful{}';
  }
}

class GetPrefsSuccess extends CheckInState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class CheckOutSuccess extends CheckInState{

  @override
  String toString() {
    return 'CheckOutSuccess{}';
  }
}

class CheckOutAddItemSuccess extends CheckInState{

  final ItemCheckInOffline itemCheckIn;

  CheckOutAddItemSuccess(this.itemCheckIn);

  @override
  String toString() {
    return 'CheckOutAddItemSuccess{}';
  }
}

class GetListAlbumImageCheckInSuccess extends CheckInState{

  @override
  String toString() {
    return 'GetListAlbumImageCheckInSuccess{}';
  }
}
class SynCheckInSuccess extends CheckInState{

  @override
  String toString() {
    return 'SynCheckInSuccess{}';
  }
}
class ChangeStatusStoreOpenSuccess extends CheckInState{

  @override
  String toString() {
    return 'ChangeStatusStoreOpenSuccess{}';
  }
}
class GetListSynCheckInSuccess extends CheckInState{

  @override
  String toString() {
    return 'GetListSynCheckInSuccess{}';
  }
}
class SaveTimeCheckOutSuccess extends CheckInState{

  @override
  String toString() {
    return 'SaveTimeCheckOutSuccess{}';
  }
}
class UpdateTimeCheckOutSuccess extends CheckInState{

  @override
  String toString() {
    return 'UpdateTimeCheckOutSuccess{}';
  }
}
class GetTimeCheckOutSaveSuccess extends CheckInState{

  final ListCheckIn itemSelect;

  // final int idCheckIn;
  // final String title;
  // final String idCustomer;
  // final bool isCheckInSuccess;
  // final String nameStore;
  // final DateTime? dateTimeCheckIn;
  // final String latLong;
  // final String tenKh;
  // final String trangThai;
  // final String dienThoai;
  // final String diaChi;
  // final String ngayCheckin;
  // final String tgHoanThanh;
  //
  GetTimeCheckOutSaveSuccess({required this.itemSelect
  //   required this.isCheckInSuccess, required this.title,this.dateTimeCheckIn, required this.latLong,
  //   required this.tenKh, required this.trangThai, required this.dienThoai, required this.diaChi, required this.ngayCheckin,
  //   required this.tgHoanThanh
  });

  @override
  String toString() {
    return 'GetTimeCheckOutSaveSuccess{}';
  }
}

class GetListCheckInSuccess extends CheckInState{

  @override
  String toString() {
    return 'GetListCheckInSuccess{}';
  }
}

class SyncLoading extends CheckInState{

  @override
  String toString() {
    return 'SyncLoading{}';
  }
}

class CheckInLoading extends CheckInState {

  @override
  String toString() => 'CheckInLoading';
}

class CheckInFailure extends CheckInState {
  final String error;

  CheckInFailure(this.error);

  @override
  String toString() => 'CheckInFailure { error: $error }';
}

class GetListSCheckInEmpty extends CheckInState {

  @override
  String toString() {
    return 'GetListSCheckInEmpty{}';
  }
}

class GetDetailCheckInEmpty extends CheckInState {

  @override
  String toString() {
    return 'GetDetailCheckInEmpty{}';
  }
}

class GetDetailCheckInSuccess extends CheckInState {

  @override
  String toString() {
    return 'GetDetailCheckInSuccess{}';
  }
}

class GetDetailCheckInOnlineSuccess extends CheckInState {

  @override
  String toString() {
    return 'GetDetailCheckInOnlineSuccess{}';
  }
}

class UpdateListCheckInSuccess extends CheckInState {

  @override
  String toString() {
    return 'UpdateListCheckInSuccess{}';
  }
}

class GetListImageStoreEmpty extends CheckInState {

  @override
  String toString() {
    return 'GetListImageStoreEmpty{}';
  }
}
class GetListImageStoreSuccess extends CheckInState {

  @override
  String toString() {
    return 'GetListImageStoreSuccess{}';
  }
}

class GetImageCheckInLocalSuccess extends CheckInState{

  @override
  String toString() {
    return 'GetImageCheckInLocalSuccess{}';
  }
}

class GetListTaskOffLineSuccess extends CheckInState{
  final bool reloadData;

  GetListTaskOffLineSuccess({required this.reloadData});
  @override
  String toString() {
    return 'GetListTaskOffLineSuccess{}';
  }
}
