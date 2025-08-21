import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dms/model/database/data_local.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:dms/utils/const.dart';

import '../../../model/network/response/list_kpi_summary_response.dart';
import '../../../model/network/services/network_factory.dart';
import 'kpi_event.dart';
import 'kpi_state.dart';


class KPIBloc extends Bloc<KPIEvent,KPIState>{
  NetWorkFactory? _networkFactory;
  BuildContext context;

  String? userName;
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  List<ListKPISummaryResponseData> listKPISummary = [];

  KPIBloc(this.context) : super(InitialKPIState()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsKPIEvent>(_getPrefs);
    on<GetListKPISummary>(_getListKPISummary);

  }

  final box = GetStorage();
  void _getPrefs(GetPrefsKPIEvent event, Emitter<KPIState> emitter)async{
    emitter(InitialKPIState());
    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsSuccess());
  }

  void _getListKPISummary(GetListKPISummary event, Emitter<KPIState> emitter)async{
    emitter(KPILoading());
    KPIState state = _handleLoadListVVHD(await _networkFactory!.getListKPISummaryByDay(
        _accessToken!,
        // '2023-01-16',
        event.dateFrom,
        event.dateTo
    ));
    emitter(state);
  }

  KPIState _handleLoadListVVHD(Object data) {
    if (data is String) return KPIFailure('Úi, ${data.toString()}');
    try {

      ListKPISummaryResponse response = ListKPISummaryResponse.fromJson(data as Map<String,dynamic>);
      listKPISummary = response.data!;

      return GetKPISummarySuccess();
    } catch (e) {
      return KPIFailure('Úi, ${e.toString()}');
    }
  }

}