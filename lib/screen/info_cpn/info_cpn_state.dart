import 'package:equatable/equatable.dart';

abstract class InfoCPNState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialInfoCPNState extends InfoCPNState {

  @override
  String toString() {
    return 'InitialInfoCPNState{}';
  }
}

class GetPrefsSuccess extends InfoCPNState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class InfoCPNLoading extends InfoCPNState {

  @override
  String toString() => 'InfoCPNLoading';
}

class InfoCPNFailure extends InfoCPNState {
  final String error;

  InfoCPNFailure(this.error);

  @override
  String toString() => 'InfoCPNFailure { error: $error }';
}

class GetStoreCPNFailure extends InfoCPNState {
  final String error;

  GetStoreCPNFailure(this.error);

  @override
  String toString() => 'GetStoreCPNFailure { error: $error }';
}

class InfoCPNSuccess extends InfoCPNState {

  @override
  String toString() {
    return 'InfoCPNSuccess{}';
  }
}

class GetInfoCompanySuccessful extends InfoCPNState {
  @override
  String toString() => 'GetInfoCompanySuccessful';
}

class GetInfoUnitsSuccessful extends InfoCPNState {
  @override
  String toString() => 'GetInfoUnitsSuccessful';
}

class GetInfoStoreSuccessful extends InfoCPNState {
  @override
  String toString() => 'GetInfoStoreSuccessful';
}

class ConfigSuccessful extends InfoCPNState {
  @override
  String toString() => 'ConfigSuccessful';
}
class UpdateCacheStoreSuccessful extends InfoCPNState {
  @override
  String toString() => 'UpdateCacheStoreSuccessful';
}

class GetPermissionLocationSuccessful extends InfoCPNState {
  @override
  String toString() => 'GetPermissionLocationSuccessful';
}

class UpdateUIdSuccess extends InfoCPNState{

  @override
  String toString() {
    return 'UpdateUIdSuccess{}';
  }
}

class GetPermissionSuccess extends InfoCPNState{

  @override
  String toString() {
    return 'GetPermissionSuccess{}';
  }
}

class GetPermissionFail extends InfoCPNState{

  @override
  String toString() {
    return 'GetPermissionFail{}';
  }
}

class GetSettingsSuccessful extends InfoCPNState {
  @override
  String toString() => 'GetSettingsSuccessful';
}