import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dms/screen/menu/report/result_report/result_report_event.dart';
import 'package:dms/screen/menu/report/result_report/result_report_state.dart';
import 'package:dms/utils/const.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import '../../../../model/network/request/result_report_request.dart';
import '../../../../model/network/response/approval_detail_response.dart';
import '../../../../model/network/services/network_factory.dart';
import '../../../../utils/utils.dart';

class ResultReportBloc extends Bloc<ResultReportEvent, ResultReportState> {
  NetWorkFactory? _networkFactory;
  BuildContext context;

  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  List<String> dataInsideHeader = [];
  List<String> dataInsideColFist = [];
  List<HeaderData> listHeaderData = <HeaderData>[];
  List<List<String>> output = [];
  List<Map<String,dynamic>> listValuesCells = [];
  List<dynamic> responseData = [];
  Map<String,dynamic> dataMap2 = new Map();
  int page = 1;
  int totalPage = 0;


  ResultReportBloc(this.context) : super(ResultReportInitial()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefs>(_getPrefs);
    on<GetResultReportEvent>(_getResultReportEvent);
    on<NextPageResultReportEvent>(_nextPageResultReportEvent);
    on<PrevPageResultReportEvent>(_prevPageResultReportEvent);
  }
  final box = GetStorage();
  void _getPrefs(GetPrefs event, Emitter<ResultReportState> emitter)async{
    emitter(ResultReportInitial());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsSuccess());
  }

  void _getResultReportEvent(GetResultReportEvent event, Emitter<ResultReportState> emitter)async{
    emitter(ResultLoadingReport());
    ResultReportRequest request = ResultReportRequest(
        reportId: event.idReport,
        values:event.listRequest
    );
    ResultReportState state = _handleLoadListResult(await _networkFactory!.getResultReport(request, _accessToken!));
    emitter(state);
  }

  void _nextPageResultReportEvent(NextPageResultReportEvent event, Emitter<ResultReportState> emitter)async{
    emitter(ResultLoadingReport());
    if (page < totalPage) {
      page++;
      await getDataPageList();
    }
    emitter(NextPageResultReportSuccess());
  }

  void _prevPageResultReportEvent(PrevPageResultReportEvent event, Emitter<ResultReportState> emitter)async{
    emitter(ResultLoadingReport());
    if (page > 1) {
      page--;
      await getDataPageList();
    }
    emitter(PrevPageResultReportSuccess());
  }

  ResultReportState _handleLoadListResult(Object data) {
    if (data is String) return ResultReportFailure('Úi, ${data.toString()}');
    try {
      ResultReportResponse response = ResultReportResponse.fromJson(data as Map<String,dynamic>);
      listHeaderData = response.headerDesc!;
      Map<String, dynamic> jsonMap =  Map<String, dynamic>.from(data);
      responseData = jsonMap["values"];
      if(responseData.isNotEmpty){
        getDataPageList();
        return GetResultReportSuccess();
      }else{
        return GetResultReportEmpty();
      }
    } catch (e) {
      return ResultReportFailure('Úi, ${e.toString()}');
    }
  }

  Future<void> getDataPageList() async {
    int round = 0;
    for (var contentRow in responseData) {
      Map<String,dynamic> dataMap =  Map();
      round++;
      for (var header in listHeaderData) {
        for (final name in contentRow.keys){
          if (header.field.toString() == name){
            var value;
            if(header.type == 2){
              final formatter =  NumberFormat(header.format??'#,##0');//### ##0,00 - ###,##0,00
              if(contentRow[name] == null || contentRow[name] == 'null' || contentRow[name].toString().isEmpty){
                value = 0;
              }else {
                value = formatter.format(contentRow[name]);
              }
            }else if(header.type == 3){
              if(contentRow[name].toString().isNotEmpty && contentRow[name].toString() != '' && contentRow[name].toString() != 'null'){
                DateTime x = DateTime.parse(contentRow[name].toString());
                value =DateFormat("dd/MM/yyyy").format(x);
              }else {
                value = '';
              }
            } else{
              value = contentRow[name];
            }
            dataMap.putIfAbsent(name, () => value);
            if(round == 1){
              dataMap2.putIfAbsent(name, () => value);
            }
          }
        }
      }
      listValuesCells.add(dataMap);
    }
  }
}