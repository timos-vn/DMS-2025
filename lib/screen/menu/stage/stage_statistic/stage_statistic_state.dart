import 'package:equatable/equatable.dart';

abstract class StageStatisticState extends Equatable {
  @override
  List<Object> get props => [];
}

class StageStatisticInitial extends StageStatisticState {
  @override
  String toString() => 'StageStatisticInitial';
}
class StageStatisticLoading extends StageStatisticState {
  @override
  String toString() => 'StageStatisticLoading';
}

class StageStatisticFailure extends StageStatisticState {
  final String error;

  StageStatisticFailure(this.error);

  @override
  String toString() => 'StageStatisticFailure { error: $error }';
}

class GetListStageSuccess extends StageStatisticState{

  @override
  String toString() {
    return 'GetListStageSuccess';
  }
}class CreateManufacturingSuccess extends StageStatisticState{

  @override
  String toString() {
    return 'CreateManufacturingSuccess';
  }
}class GetListRequestSectionAndRouteItemSuccess extends StageStatisticState{

  @override
  String toString() {
    return 'GetListRequestSectionAndRouteItemSuccess';
  }
}
class GetItemMaterialsSuccess extends StageStatisticState{

  @override
  String toString() {
    return 'GetItemMaterialsSuccess';
  }
}
class VoucherTransactionSuccess extends StageStatisticState{

  final int type;

  VoucherTransactionSuccess({required this.type});

  @override
  String toString() {
    return 'VoucherTransactionSuccess';
  }
}

class GetListStageEmpty extends StageStatisticState {

  @override
  String toString() {
    return 'GetListStageEmpty{}';
  }
}class GetItemMaterialsEmpty extends StageStatisticState {

  @override
  String toString() {
    return 'GetItemMaterialsEmpty{}';
  }
}

class GetPrefsSuccess extends StageStatisticState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}
class RequiredText extends StageStatisticState {
  @override
  String toString() {
    // TODO: implement toString
    return 'RequiredText{}';
  }
}class SearchSemiProductionSuccess extends StageStatisticState {
  @override
  String toString() {
    // TODO: implement toString
    return 'SearchSuccess{}';
  }
}
class EmptySearchSemiProductionState extends StageStatisticState {
  @override
  String toString() {
    // TODO: implement toString
    return 'EmptySearchState{}';
  }
}