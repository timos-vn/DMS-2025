import 'package:equatable/equatable.dart';

abstract class DetailStageStatisticState extends Equatable {
  @override
  List<Object> get props => [];
}

class DetailStageStatisticInitial extends DetailStageStatisticState {
  @override
  String toString() => 'DetailStageStatisticInitial';
}
class DetailStageStatisticLoading extends DetailStageStatisticState {
  @override
  String toString() => 'DetailStageStatisticLoading';
}

class DetailStageStatisticFailure extends DetailStageStatisticState {
  final String error;

  DetailStageStatisticFailure(this.error);

  @override
  String toString() => 'DetailStageStatisticFailure { error: $error }';
}

class GetListDetailStageSuccess extends DetailStageStatisticState{

  @override
  String toString() {
    return 'GetListDetailStageSuccess';
  }
}

class GetListStoreSuccess extends DetailStageStatisticState{

  @override
  String toString() {
    return 'GetListStoreSuccess';
  }
}

class CreateTKCDSuccess extends DetailStageStatisticState{

  @override
  String toString() {
    return 'CreateTKCDSuccess';
  }
}

class CreateTKCDFailed extends DetailStageStatisticState{

  final String error;

  CreateTKCDFailed(this.error);

  @override
  String toString() {
    return 'CreateTKCDFailed';
  }
}

class ChooseStoreSuccess extends DetailStageStatisticState{

  @override
  String toString() {
    return 'ChooseStoreSuccess';
  }
}

class GetListDetailStageEmpty extends DetailStageStatisticState {

  @override
  String toString() {
    return 'GetListDetailStageEmpty{}';
  }
}
class GetPrefsSuccess extends DetailStageStatisticState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class UpdateTKCDDraftSuccess extends DetailStageStatisticState{

  @override
  String toString() {
    return 'UpdateTKCDDraftSuccess';
  }
}

class UpdateTKCDDraftFailed extends DetailStageStatisticState{

  final String error;

  UpdateTKCDDraftFailed(this.error);

  @override
  String toString() {
    return 'UpdateTKCDDraftFailed';
  }
}