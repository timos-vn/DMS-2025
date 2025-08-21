import 'package:equatable/equatable.dart';
import '../../../../model/network/response/detail_stage_statistic_response.dart';

abstract class DetailStageStatisticEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetListDetailStageStatistic extends DetailStageStatisticEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String soCt;
  GetListDetailStageStatistic({this.isRefresh = false, this.isLoadMore = false,required this.soCt});

  @override
  String toString() => 'GetListDetailStageStatistic {}';
}
class GetStoreList extends DetailStageStatisticEvent {

  final int idStage;

  GetStoreList({required this.idStage});

  @override
  String toString() => 'GetStoreList {}';
}

class ChooseStore extends DetailStageStatisticEvent {

  final String idStore;
  final String nameStore;

  ChooseStore({required this.idStore,required this.nameStore});

  @override
  String toString() => 'ChooseStore {}';
}

class CreateTKCD extends DetailStageStatisticEvent {

  final String sttRec;
  final int idStage;
  final List<DetailStageStatisticResponseData> listDetailStage;
  final String? takeNote;
  CreateTKCD({required this.sttRec,required this.idStage,required this.listDetailStage,this.takeNote});

  @override
  String toString() => 'CreateTKCD {}';
}

class GetPrefs extends DetailStageStatisticEvent {
  @override
  String toString() => 'GetPrefs';
}

class UpdateTKCDDraft extends DetailStageStatisticEvent {

  final String sttRec;
  final int idStage;
  final List<DetailStageStatisticResponseData> listDetailStage;


  UpdateTKCDDraft({required this.sttRec,required this.idStage,required this.listDetailStage,});

  @override
  String toString() => 'UpdateTKCDDraft {}';
}