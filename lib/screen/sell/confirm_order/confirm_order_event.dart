import 'package:equatable/equatable.dart';
import '../../../model/entity/product.dart';
import '../../../model/network/request/create_order_request.dart';
import '../../../model/network/request/update_order_request.dart';

abstract class ConfirmOrderEvent extends Equatable {
  @override
  List<Object> get props => [];
}


class GetPrefs extends ConfirmOrderEvent {
  @override
  String toString() => 'GetPrefs';
}

class CreateOderEvent extends ConfirmOrderEvent {
  final String? code;
  final String? storeCode;
  final String? currencyCode;
  final List<Product>? listOrder;
  final ItemTotalMoneyRequestData? totalMoney;

  CreateOderEvent({this.code,this.storeCode,this.currencyCode,this.listOrder,this.totalMoney});

  @override
  String toString() => 'CreateOderEvent';
}

class UpdateOderEvent extends ConfirmOrderEvent {
  final bool? viewUpdateOrder;
  final String? sttRec;
  final String? code;
  final String? storeCode;
  final String? currencyCode;
  final List<Product>? listOrder;
  final ItemTotalMoneyUpdateRequestData? totalMoney;

  UpdateOderEvent({this.viewUpdateOrder,this.sttRec,this.code,this.storeCode,this.currencyCode,this.listOrder,this.totalMoney});

  @override
  String toString() => 'UpdateOderEvent';
}

class CalculatorTotalMoney extends ConfirmOrderEvent {

  final String? maKho;
  final String? maKH;
  final List<Product>? listItem;

  CalculatorTotalMoney({this.listItem,this.maKho,this.maKH});

  @override
  String toString() => 'CalculatorTotalMoney {listItem: $listItem,}';
}

class PickInfoCustomer extends ConfirmOrderEvent{

  final String? customerName;
  final String? phone;
  final String? address;
  final String? codeCustomer;

  PickInfoCustomer({this.customerName, this.phone, this.address, this.codeCustomer});

  @override
  String toString() => 'PickInfoCustomer {}';
}

class PickStoreName extends ConfirmOrderEvent {

  final int storeIndex;

  PickStoreName(this.storeIndex);

  @override
  String toString() {
    return 'PickStoreName{ storeIndex: $storeIndex}';
  }
}

class ValidateNameCustomer extends ConfirmOrderEvent {
  final String nameCustomer;

  ValidateNameCustomer(this.nameCustomer);

  @override
  String toString() => 'ValidateNameCustomer { nameCustomer: $nameCustomer }';
}

class ValidatePhoneNumber extends ConfirmOrderEvent {
  final String phoneNumber;

  ValidatePhoneNumber(this.phoneNumber);

  @override
  String toString() =>
      'ValidatePhoneNumber { phoneNumber: $phoneNumber }';
}

class ValidateEmail extends ConfirmOrderEvent {
  final String email;

  ValidateEmail(this.email);

  @override
  String toString() =>
      'ValidateEmail { email: $email }';
}


class ValidateAddress extends ConfirmOrderEvent {
  final String address;

  ValidateAddress(this.address);

  @override
  String toString() =>
      'ValidateAddress { address: $address }';
}

class CheckDisCountWhenUpdateEvent extends ConfirmOrderEvent {

  final List<Product> listItem;
  final String sttRec;
  final String? codeCustomer;
  final String? codeStore;

  CheckDisCountWhenUpdateEvent(this.listItem,this.sttRec,{this.codeCustomer,this.codeStore,});

  @override
  String toString() => 'CheckDisCountWhenUpdateEvent {listItem: $listItem,sttRec$sttRec}';
}