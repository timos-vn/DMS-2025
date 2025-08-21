import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dms/screen/menu/report/report_layout/report_event.dart';
import 'package:dms/screen/menu/report/report_layout/report_sate.dart';
import 'package:dms/utils/const.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../model/network/response/report_info_response.dart';
import '../../../../model/network/response/report_layout_response.dart';
import '../../../../model/network/services/network_factory.dart';
import '../../../../utils/utils.dart';

class ReportBloc extends Bloc<ReportEvent,ReportState>{

  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  List<DetailDataReport> _listDetailDataReport = <DetailDataReport>[];
  List<DetailDataReport> get listDetailDataReport => _listDetailDataReport;
  List<String> listTabViewReport = [];
  List<DataReportLayout> listDataReportLayout = <DataReportLayout>[];


  ReportBloc(this.context) : super(ReportInitial()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefs>(_getPrefs);
    on<GetListReports>(_getListReports);
    on<GetListReportLayout>(_getListReportLayout);

  }
  final box = GetStorage();
  void _getPrefs(GetPrefs event, Emitter<ReportState> emitter)async{
    emitter(ReportInitial());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsSuccess());
  }

  void _getListReports(GetListReports event, Emitter<ReportState> emitter)async{
    emitter(LoadingReport());
    ReportState state = _handleGetListReports(await _networkFactory!.getListReports(_accessToken!));
    emitter(state);
  }

  void _getListReportLayout(GetListReportLayout event, Emitter<ReportState> emitter)async{
    emitter(LoadingReport());
    ReportState state = _handleGetListReportLayout(await _networkFactory!.getListReportLayout(_accessToken!, event.reportId),event.reportId,event.reportTitle);
    emitter(state);
  }

  ReportState _handleGetListReports(Object data){
    if (data is String) return ReportFailure('Úi, ${data.toString()}');
    try{
      GetListReportsResponse response = GetListReportsResponse.fromJson(data as Map<String,dynamic>);
      _listDetailDataReport = response.reportData!;
      for (var element in _listDetailDataReport) {
        listTabViewReport.add(element.name!);
      }
      return GetListReportSuccess();
    }
    catch(e){
      return ReportFailure('Úi, ${e.toString()}');
    }
  }

  ReportState _handleGetListReportLayout(Object data,String idReport,String titleReport){
    if (data is String) return ReportFailure('Úi, ${data.toString()}');
    try{
      ReportLayoutResponse response = ReportLayoutResponse.fromJson(data as Map<String,dynamic>);
      listDataReportLayout = response.reportLayoutData!;
      return GetListReportLayoutSuccess(idReport,titleReport);
    }
    catch(e){
      return ReportFailure('Úi, ${e.toString()}');
    }
  }
}
