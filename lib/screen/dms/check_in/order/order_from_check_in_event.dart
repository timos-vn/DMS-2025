import 'package:equatable/equatable.dart';

import '../../../../model/entity/product.dart';
import '../../../../model/network/request/create_order_request.dart';

abstract class OrderFromCheckInEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsOrderFromCheckIn extends OrderFromCheckInEvent {
  @override
  String toString() => 'GetPrefsAlbum';
}

class DeleteProductInCartEvent extends OrderFromCheckInEvent{

  final bool isBack;

  DeleteProductInCartEvent(this.isBack);

  @override
  String toString() {
    return 'DeleteProductInCartEvent{}';
  }
}

class GetListOrderFromCheckIn extends OrderFromCheckInEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String? idCustomer;
  final String? idCheckIn;
  final String? idAlbum;
  GetListOrderFromCheckIn({this.isRefresh = false, this.isLoadMore = false,this.idCustomer,this.idCheckIn, this.idAlbum});

  @override
  String toString() => 'GetListOrderFromCheckIn {}';
}

class AddListItemOrderFromCheckIn extends OrderFromCheckInEvent {

  @override
  String toString() => 'AddListItemOrderFromCheckIn {}';
}

class CreateOderFromCheckInEvent extends OrderFromCheckInEvent {
  final String? code;
  final String? storeCode;
  final String? currencyCode;
  final String? phoneCustomer;
  final String? addressCustomer;
  final List<Product>? listOrder;
  final ItemTotalMoneyRequestData? totalMoneys;

  CreateOderFromCheckInEvent({this.code,this.storeCode,this.currencyCode,this.listOrder,this.totalMoneys,this.phoneCustomer,this.addressCustomer});

  @override
  String toString() => 'CreateOderFromCheckInEvent';
}