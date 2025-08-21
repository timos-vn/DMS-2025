import 'package:equatable/equatable.dart';

import '../../model/network/response/inventory_response.dart';

abstract class DMSState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitialDMSState extends DMSState {

  @override
  String toString() {
    return 'InitialDMSState{}';
  }
}

class GetPrefsSuccess extends DMSState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}
class GetListStatus extends DMSState {

  @override
  String toString() {
    return 'GetListStatus{}';
  }
}
class GetValuesClientSuccess extends DMSState{

  @override
  String toString() {
    return 'GetValuesClientSuccess{}';
  }
}

class GetListTaskOffLineSuccess extends DMSState{

  final int nextScreen;

  GetListTaskOffLineSuccess({required this.nextScreen});

  @override
  String toString() {
    return 'GetListTaskOffLineSuccess{}';
  }
}
class AddNewRequestOpenStoreSuccess extends DMSState{

  @override
  String toString() {
    return 'AddNewRequestOpenStoreSuccess{}';
  }
}class GetListInventoryRequestSuccess extends DMSState{

  @override
  String toString() {
    return 'GetListInventoryRequestSuccess{}';
  }
}class GetListInventorySuccess extends DMSState{

  @override
  String toString() {
    return 'GetListInventorySuccess{}';
  }
}class GetListStockInventoryRequestSuccess extends DMSState{

  @override
  String toString() {
    return 'GetListStockInventoryRequestSuccess{}';
  }
}
class GetListGetListHistoryInventorySuccess extends DMSState{

  @override
  String toString() {
    return 'GetListGetListHistoryInventorySuccess{}';
  }
}

class UpdateNewRequestOpenStoreSuccess extends DMSState{

  @override
  String toString() {
    return 'UpdateNewRequestOpenStoreSuccess{}';
  }
}
class CancelRequestOpenStoreSuccess extends DMSState{

  @override
  String toString() {
    return 'CancelRequestOpenStoreSuccess{}';
  }
}

class GetListRequestOpenStoreSuccess extends DMSState{

  @override
  String toString() {
    return 'GetListRequestOpenStoreSuccess{}';
  }
}

class UpdateRequestOpenStoreSuccess extends DMSState{

  @override
  String toString() {
    return 'UpdateRequestOpenStoreSuccess{}';
  }
}

class GetDetailRequestOpenStoreSuccess extends DMSState{

  @override
  String toString() {
    return 'GetDetailRequestOpenStoreSuccess{}';
  }
}
class GetListRequestOpenStoreEmpty extends DMSState{

  @override
  String toString() {
    return 'GetListRequestOpenStoreEmpty{}';
  }
}

class DMSLoading extends DMSState {

  @override
  String toString() => 'DMSLoading';
}

class DMSFailure extends DMSState {

  final String error;

  DMSFailure(this.error);

  @override
  String toString() => 'DMSFailure';
}
class EmployeeScanFailure extends DMSState {
  final String error;

  EmployeeScanFailure(this.error);

  @override
  String toString() => 'EmployeeScanFailure { error: $error }';
}

class GrantCameraPermission extends DMSState {

  @override
  String toString() {
    return 'GrantCameraPermission{}';
  }
}

class GetListVvHdSuccess extends DMSState {

  @override
  String toString() {
    return 'GetListVvHdSuccess{}';
  }
}
class GetListTaxSuccess extends DMSState {

  @override
  String toString() {
    return 'GetListTaxSuccess{}';
  }
}class UpdateInventorySuccess extends DMSState {

  @override
  String toString() {
    return 'UpdateInventorySuccess{}';
  }
}
class UpdateHistoryInventory extends DMSState {

  @override
  String toString() {
    return 'UpdateHistoryInventory{}';
  }
}

class GetTotalUnreadNotificationSuccess extends DMSState {

  @override
  String toString() {
    return 'GetTotalUnreadNotificationSuccess{}';
  }
}
class DMSInventoryState extends DMSState {
  final List<ListItemInventoryResponseData> listItemInventory;
  final int? selectedIndex;

  DMSInventoryState({
    this.listItemInventory = const [],
    this.selectedIndex,
  });

  DMSInventoryState copyWith({
    List<ListItemInventoryResponseData>? listItemInventory,
    int? selectedIndex,
  }) {
    return DMSInventoryState(
      listItemInventory: listItemInventory ?? this.listItemInventory,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object?> get props => [listItemInventory, selectedIndex];
}
