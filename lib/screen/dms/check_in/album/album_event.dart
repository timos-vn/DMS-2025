import 'package:dms/model/entity/image_check_in.dart';
import 'package:equatable/equatable.dart';

abstract class AlbumEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsAlbum extends AlbumEvent {
  @override
  String toString() => 'GetPrefsAlbum';
}

class AddImageLocalEvent extends AlbumEvent {

  final ImageCheckIn imageCheckInItem;

  AddImageLocalEvent({required this.imageCheckInItem});

  @override
  String toString() => 'AddImageLocalEvent';
}
class DeleteImageLocalEvent extends AlbumEvent {

  final String fileName;

  DeleteImageLocalEvent({required this.fileName});

  @override
  String toString() => 'DeleteImageLocalEvent';
}
class DeleteAllImageLocalEvent extends AlbumEvent {

  @override
  String toString() => 'DeleteAllImageLocalEvent';
}

class GetImageLocalEvent extends AlbumEvent {

  @override
  String toString() => 'GetImageLocalEvent';
}


class GetListImageStore extends AlbumEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String? idCustomer;
  final String? idCheckIn;
  final String? idAlbum;
  GetListImageStore({this.isRefresh = false, this.isLoadMore = false,this.idCustomer,this.idCheckIn, this.idAlbum});

  @override
  String toString() => 'GetListImageStore {}';
}

class GetCameraEvent extends AlbumEvent {

  @override
  String toString() {
    return 'GetCameraEvent{}';
  }
}

class PickAlbumImage extends AlbumEvent {

  final String idAlbumImage;
  final String nameAlbumImage;
  // final bool isToday;

  PickAlbumImage({required this.idAlbumImage,required this.nameAlbumImage, });

  @override
  String toString() {
    return 'PickAlbumImage{ idAlbumImage: $idAlbumImage,nameAlbumImage: $nameAlbumImage}';
  }
}
