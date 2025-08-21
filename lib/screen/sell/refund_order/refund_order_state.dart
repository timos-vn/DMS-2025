import 'package:equatable/equatable.dart';

abstract class RefundOrderState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialRefundOrderState extends RefundOrderState {

  @override
  String toString() {
    return 'InitialRefundOrderState{}';
  }
}

class GetPrefsRefundOrderSuccess extends RefundOrderState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class GetListRefundOrderSuccess extends RefundOrderState{

  @override
  String toString() {
    return 'GetListRefundOrderSuccess{}';
  }
}

class GetListDetailOrderCompletedSuccess extends RefundOrderState{

  final bool addOrDelete;

  GetListDetailOrderCompletedSuccess({required this.addOrDelete});

  @override
  String toString() {
    return 'GetListDetailOrderCompletedSuccess{}';
  }
}

class GetListDetailHistoryRefundOrderSuccess extends RefundOrderState{

  @override
  String toString() {
    return 'GetListDetailHistoryRefundOrderSuccess{}';
  }
}

class AddNewRefundOrderSuccess extends RefundOrderState{

  @override
  String toString() {
    return 'AddNewRefundOrderSuccess{}';
  }
}


class GetListRefundOrderEmpty extends RefundOrderState{

  @override
  String toString() {
    return 'GetListCustomerCareEmpty{}';
  }
}

class ChangeHeightListSuccess extends RefundOrderState{

  @override
  String toString() {
    return 'ChangeHeightListSuccess{}';
  }
}
class GetListDetailOrderCompletedEmpty extends RefundOrderState{

  @override
  String toString() {
    return 'GetListCustomerCareEmpty{}';
  }
}

class RefundOrderLoading extends RefundOrderState {

  @override
  String toString() => 'RefundOrderLoading{}';
}
class AddNoteSuccess extends RefundOrderState {

  @override
  String toString() {
    return 'AddNoteSuccess{}';
  }
}
class CalculatorSuccess extends RefundOrderState {

  @override
  String toString() {
    return 'CalculatorSuccess{}';
  }
}
class PickInfoCustomerSuccess extends RefundOrderState {

  @override
  String toString() {
    return 'PickInfoCustomerSuccess{}';
  }
}

class RefundOrderFailure extends RefundOrderState {

  final String error;

  RefundOrderFailure(this.error);

  @override
  String toString() => 'RefundOrderFailure{}';
}
