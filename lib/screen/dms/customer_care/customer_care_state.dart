import 'package:equatable/equatable.dart';

abstract class CustomerCareState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialCustomerCareState extends CustomerCareState {

  @override
  String toString() {
    return 'InitialCustomerCareState{}';
  }
}

class GetPrefsCustomerCareSuccess extends CustomerCareState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class GetListHistoryCustomerCareSuccess extends CustomerCareState{

  @override
  String toString() {
    return 'GetListHistoryCustomerCareSuccess{}';
  }
}

class AddNoteSuccess extends CustomerCareState {

  @override
  String toString() {
    return 'AddNoteSuccess{}';
  }
}

class AddNewCustomerCareSuccess extends CustomerCareState{

  @override
  String toString() {
    return 'AddNewRequestOpenStoreSuccess{}';
  }
}
class ChooseTypeCareSuccess extends CustomerCareState {

  @override
  String toString() {
    return 'ChooseTypeCareSuccess{}';
  }
}

class PickInfoCustomerSuccess extends CustomerCareState {

  @override
  String toString() {
    return 'PickInfoCustomerSuccess{}';
  }
}

class GetListCustomerCareEmpty extends CustomerCareState{

  @override
  String toString() {
    return 'GetListCustomerCareEmpty{}';
  }
}

class CustomerCareLoading extends CustomerCareState {

  @override
  String toString() => 'CustomerCareLoading{}';
}

class CustomerCareFailure extends CustomerCareState {

  final String error;

  CustomerCareFailure(this.error);

  @override
  String toString() => 'CustomerCareFailure{}';
}

class EmployeeScanFailure extends CustomerCareState {
  final String error;

  EmployeeScanFailure(this.error);

  @override
  String toString() => 'EmployeeScanFailure { error: $error }';
}

class GrantCameraPermission extends CustomerCareState {

  @override
  String toString() {
    return 'GrantCameraPermission{}';
  }
}
