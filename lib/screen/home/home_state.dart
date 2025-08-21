import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialHomeState extends HomeState {

  @override
  String toString() {
    return 'InitialHomeState{}';
  }
}

class GetPrefsSuccess extends HomeState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}
class GetPrefsFail extends HomeState{

  @override
  String toString() {
    return 'GetPrefsFail{}';
  }
}

class DoNotPermissionViewState extends HomeState{

  @override
  String toString() {
    return 'DoNotPermissionViewState{}';
  }
}

class HomeLoading extends HomeState {

  @override
  String toString() => 'HomeLoading';
}
class HomeFailure extends HomeState {
  final String error;

  HomeFailure(this.error);

  @override
  String toString() => 'HomeFailure { error: $error }';
}
class GetListStatusOrderSuccess extends HomeState {

  @override
  String toString() {
    return 'GetListStatusOrderSuccess{}';
  }
}
class PickTransactionSuccess extends HomeState {

  PickTransactionSuccess();

  @override
  String toString() {
    return 'PickTransactionSuccess{}';
  }
}
class GetKPISuccess extends HomeState {

  @override
  String toString() {
    return 'GetKPISuccess{}';
  }
}

class GetDefaultDataSuccess extends HomeState {

  @override
  String toString() => 'GetDefaultDataSuccess {}';
}class GetListSliderImageSuccess extends HomeState {

  @override
  String toString() => 'GetListSliderImageSuccess {}';
}
class ChangeTimeValueSuccess extends HomeState {

  @override
  String toString() => 'ChangeTimeValueSuccess {}';
}

class GetDataSuccess extends HomeState {

  @override
  String toString() => 'GetDataSuccess {}';
}

