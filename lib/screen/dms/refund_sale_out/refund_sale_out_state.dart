import 'package:equatable/equatable.dart';

abstract class RefundSaleOutState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialRefundSaleOutState extends RefundSaleOutState {

  @override
  String toString() {
    return 'InitialRefundSaleOutState{}';
  }
}

class GetPrefsRefundSaleOutSuccess extends RefundSaleOutState{

  @override
  String toString() {
    return 'GetPrefsSaleOutSuccess{}';
  }
}

class GetListRefundSaleOutSuccess extends RefundSaleOutState{

  @override
  String toString() {
    return 'GetListRefundSaleOutSuccess{}';
  }
}

class GetListDetailSaleOutCompletedSuccess extends RefundSaleOutState{

  final bool addOrDelete;

  GetListDetailSaleOutCompletedSuccess({required this.addOrDelete});

  @override
  String toString() {
    return 'GetListDetailSaleOutCompletedSuccess{}';
  }
}

class GetListDetailHistoryRefundSaleOutSuccess extends RefundSaleOutState{

  @override
  String toString() {
    return 'GetListDetailHistoryRefundSaleOutSuccess{}';
  }
}

class AddNewRefundSaleOutSuccess extends RefundSaleOutState{

  @override
  String toString() {
    return 'AddNewRefundSaleOutSuccess{}';
  }
}


class GetListRefundSaleOutEmpty extends RefundSaleOutState{

  @override
  String toString() {
    return 'GetListSaleOutEmpty{}';
  }
}

class ChangeHeightListSuccess extends RefundSaleOutState{

  @override
  String toString() {
    return 'ChangeHeightListSuccess{}';
  }
}
class GetListDetailSaleOutCompletedEmpty extends RefundSaleOutState{

  @override
  String toString() {
    return 'GetListDetailSaleOutEmpty{}';
  }
}

class RefundSaleOutLoading extends RefundSaleOutState {

  @override
  String toString() => 'RefundSaleOutLoading{}';
}
class AddNoteSuccess extends RefundSaleOutState {

  @override
  String toString() {
    return 'AddNoteSuccess{}';
  }
}
class CalculatorSuccess extends RefundSaleOutState {

  @override
  String toString() {
    return 'CalculatorSuccess{}';
  }
}
class PickInfoCustomerSuccess extends RefundSaleOutState {

  @override
  String toString() {
    return 'PickInfoCustomerSuccess{}';
  }
}

class RefundSaleOutFailure extends RefundSaleOutState {

  final String error;

  RefundSaleOutFailure(this.error);

  @override
  String toString() => 'RefundSaleOutFailure{}';
}
