import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialLoginState extends LoginState {

  @override
  String toString() {
    return 'InitialLoginState{}';
  }
}

class GetPrefsLoginSuccess extends LoginState{

  @override
  String toString() {
    return 'GetPrefsLoginSuccess{}';
  }
}

class SaveDataUserSuccess extends LoginState{

  @override
  String toString() {
    return 'SaveDataUserSuccess{}';
  }
}

class UpdateAppFail extends LoginState{

  @override
  String toString() {
    return 'UpdateAppFail{}';
  }
}

class LoginLoading extends LoginState {

  @override
  String toString() => 'LoginLoading';
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure(this.error);

  @override
  String toString() => 'LoginFailure { error: $error }';
}

class LoginSuccess extends LoginState {

  @override
  String toString() {
    return 'LoginSuccess{}';
  }
}

class LoginAgainSuccess extends LoginState {

  @override
  String toString() {
    return 'LoginAgainSuccess{}';
  }
}

class GetVersionGoLiveSuccess extends LoginState {
  @override
  String toString() => 'GetVersionGoLiveSuccess }';
}