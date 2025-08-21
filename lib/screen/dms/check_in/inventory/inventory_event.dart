import 'package:equatable/equatable.dart';

abstract class InventoryEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsInventory extends InventoryEvent {
  @override
  String toString() => 'GetPrefsInventory';
}

class SaveInventoryStock extends InventoryEvent {

  final int idCheckIn;
  final String idCustomer;

  SaveInventoryStock({required this.idCheckIn,required this.idCustomer});

  @override
  String toString() => 'SaveInventoryStock:';
}

class GetListInventory extends InventoryEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String? idCustomer;
  final String? idCheckIn;
  GetListInventory({this.isRefresh = false, this.isLoadMore = false,this.idCustomer,this.idCheckIn});

  @override
  String toString() => 'GetListInventory {}';
}
