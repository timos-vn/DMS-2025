import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Login extends LoginEvent {
  final String hostURL;
  final String username;
  final String password;

  Login(this.hostURL,this.username, this.password);

  @override
  String toString() => 'Login {hostURL: $hostURL, username: $username, password: $password}';
}

class GetPrefsLoginEvent extends LoginEvent {

  @override
  String toString() => 'GetPrefsLoginEvent';
}

class GetListNews extends LoginEvent {

  @override
  String toString() => 'GetListNews';
}

class GetVersionApp extends LoginEvent {

  @override
  String toString() => 'GetVersionApp';
}

class UpdateVersionApp extends LoginEvent {

  @override
  String toString() => 'UpdateVersionApp';
}class GetListNewSuccess extends LoginEvent {

  @override
  String toString() => 'GetListNewSuccess';
}