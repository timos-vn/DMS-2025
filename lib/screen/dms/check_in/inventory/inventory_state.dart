import 'package:equatable/equatable.dart';

abstract class InventoryState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialInventoryState extends InventoryState {

  @override
  String toString() {
    return 'InitialInventoryState{}';
  }
}

class GetPrefsSuccess extends InventoryState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class GetListInventorySuccess extends InventoryState{

  @override
  String toString() {
    return 'GetListInventorySuccess{}';
  }
}


class InventoryLoading extends InventoryState {

  @override
  String toString() => 'AlbumLoading';
}

class InventoryFailure extends InventoryState {
  final String error;

  InventoryFailure(this.error);

  @override
  String toString() => 'InventoryFailure { error: $error }';
}

class GetListInventoryEmpty extends InventoryState {

  @override
  String toString() {
    return 'GetListInventoryEmpty{}';
  }
}


class GrantCameraPermission extends InventoryState {

  @override
  String toString() {
    return 'GrantCameraPermission{}';
  }
}

class SaveInventoryStockSuccess extends InventoryState{

  @override
  String toString() {
    return 'SaveInventoryStockSuccess{}';
  }
}