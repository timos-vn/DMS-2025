import 'package:equatable/equatable.dart';

import '../../../../model/entity/image_check_in.dart';

abstract class AlbumState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialAlbumState extends AlbumState {

  @override
  String toString() {
    return 'InitialAlbumState{}';
  }
}

class GetPrefsSuccess extends AlbumState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class GetListAlbumImageCheckInSuccess extends AlbumState{

  @override
  String toString() {
    return 'GetListAlbumImageCheckInSuccess{}';
  }
}

class AddImageCheckInSuccess extends AlbumState{

  @override
  String toString() {
    return 'AddImageCheckInSuccess{}';
  }
}
class DeleteImageCheckInSuccess extends AlbumState{

  @override
  String toString() {
    return 'DeleteImageCheckInSuccess{}';
  }
}
class DeleteAllImageCheckInSuccess extends AlbumState{

  @override
  String toString() {
    return 'DeleteAllImageCheckInSuccess{}';
  }
}

class GetImageCheckInLocalSuccess extends AlbumState{

  final List<ImageCheckIn> listImageCheckIn;

  GetImageCheckInLocalSuccess({required this.listImageCheckIn});

  @override
  String toString() {
    return 'GetImageCheckInLocalSuccess{}';
  }
}

class AlbumLoading extends AlbumState {

  @override
  String toString() => 'AlbumLoading';
}

class AlbumFailure extends AlbumState {
  final String error;

  AlbumFailure(this.error);

  @override
  String toString() => 'AlbumFailure { error: $error }';
}

class GetListImageStoreEmpty extends AlbumState {

  @override
  String toString() {
    return 'GetListImageStoreEmpty{}';
  }
}

class GetListImageStoreSuccess extends AlbumState {

  @override
  String toString() {
    return 'GetListImageStoreSuccess{}';
  }
}

class PickAlbumImageSuccess extends AlbumState {

  final String idAlbumImage;

  PickAlbumImageSuccess(this.idAlbumImage);

  @override
  String toString() {
    return 'PickAlbumImageSuccess{idAlbumImage: $idAlbumImage}';
  }
}


class EmployeeScanFailure extends AlbumState {
  final String error;

  EmployeeScanFailure(this.error);

  @override
  String toString() => 'EmployeeScanFailure { error: $error }';
}

class GrantCameraPermission extends AlbumState {

  @override
  String toString() {
    return 'GrantCameraPermission{}';
  }
}