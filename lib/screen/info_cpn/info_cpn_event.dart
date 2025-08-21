import 'package:equatable/equatable.dart';

abstract class InfoCPNEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsInfoCPN extends InfoCPNEvent {

  @override
  String toString() => 'GetPrefs';
}

class GetCompanyIF extends InfoCPNEvent {
  @override
  String toString() => 'GetCompanyIF {}';
}

class Config extends InfoCPNEvent{
  final String companyId;

  Config(this.companyId);

  @override
  String toString() => 'Config { companyId: $companyId}';
}

class GetUnits extends InfoCPNEvent{
  @override
  String toString() => 'GetUnits {}';
}


class GetStore extends InfoCPNEvent{
  final String unitId;

  GetStore(this.unitId);

  @override
  String toString() => 'GetStore { unitId: $unitId}';
}
class UpdateCacheStoreEvent extends InfoCPNEvent{
  final String storeId;

  UpdateCacheStoreEvent({required this.storeId});

  @override
  String toString() => 'UpdateCacheStoreEvent { storeId: $storeId}';
}

class UpdateTokenFCM extends InfoCPNEvent{

  @override
  String toString() => 'UpdateTokenFCM {}';
}

class GetSettingOption extends InfoCPNEvent{

  @override
  String toString() => 'GetSettingOption {}';
}


class GetLocationEvent extends InfoCPNEvent {

  @override
  String toString() => 'GetLocationEvent {}';
}