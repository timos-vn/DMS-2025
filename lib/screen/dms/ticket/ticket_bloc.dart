import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dms/screen/dms/ticket/ticket_event.dart';
import 'package:dms/screen/dms/ticket/ticket_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dms/utils/const.dart';
import 'package:get_storage/get_storage.dart';

import '../../../model/network/response/ticket_detail_history_response.dart';
import '../../../model/network/response/ticket_history_response.dart';
import '../../../model/network/services/network_factory.dart';
import '../../../utils/utils.dart';




class TicketHistoryBloc extends Bloc<TicketHistoryEvent,TicketHistoryState>{
  NetWorkFactory? _networkFactory;
  BuildContext context;

  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  int get currentPage => _currentPage;
  final int _currentPage = 1;
  int _maxPage = 20;
  bool isScroll = true;
  int get maxPage => _maxPage;

  int totalPager = 0;

  List<TicketHistoryResponseData> _listHistoryTicket = [];
  List<TicketHistoryResponseData> get listHistoryTicket => _listHistoryTicket;

  TicketDetailHistoryResponseData detailHistory = TicketDetailHistoryResponseData();
  List<ImageListTicketDetailHistory> imageDetailList = [];

  TicketHistoryBloc(this.context) : super(InitialTicketHistoryState()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsTicketHistoryEvent>(_getPrefs);
    on<GetListTicketHistoryEvent>(_getListTicketEvent);
    on<GetDetailTicketHistoryEvent>(_getDetailTicketHistoryEvent);

  }

  final box = GetStorage();
  void _getPrefs(GetPrefsTicketHistoryEvent event, Emitter<TicketHistoryState> emitter)async{
    emitter(InitialTicketHistoryState());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsTicketHistorySuccess());
  }

  void _getListTicketEvent(GetListTicketHistoryEvent event, Emitter<TicketHistoryState> emitter)async{
    emitter(TicketHistoryLoading());
    TicketHistoryState state = _handleLoadList(
        await _networkFactory!.getListHistoryTicket(
            _accessToken!,
            event.dateFrom,
            event.dateTo,
            event.idCustomer.toString(),
            event.employeeCode.toString(),
            event.status,
            event.pageIndex,
            _maxPage
        ));
    emitter(state);
  }

  void _getDetailTicketHistoryEvent(GetDetailTicketHistoryEvent event, Emitter<TicketHistoryState> emitter)async{
    emitter(TicketHistoryLoading());
    TicketHistoryState state = _handleGetDetailTicket(
        await _networkFactory!.getListDetailHistoryTicket(_accessToken!,event.idTicketEvent));
    emitter(state);
  }

  TicketHistoryState _handleLoadList(Object data,) {
    if (data is String) return TicketHistoryFailure('Úi, $data');
    try {
      TicketHistoryResponse response = TicketHistoryResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 20;
      _listHistoryTicket = response.data!;
      totalPager = response.totalPage!;

      if (Utils.isEmpty(_listHistoryTicket)) {
        return GetListTicketHistoryEmpty();
      }else{
        return GetListTicketHistorySuccess();
      }
    } catch (e) {
      return TicketHistoryFailure('Úi, ${e.toString()}');
    }
  }

  TicketHistoryState _handleGetDetailTicket(Object data,) {
    if (data is String) return TicketHistoryFailure('Úi, ${data.toString()}');
    try {
      TicketDetailHistoryResponse response = TicketDetailHistoryResponse.fromJson(data as Map<String,dynamic>);
      detailHistory = response.data!;
      imageDetailList = detailHistory.imageList!;
      return GetTicketDetailHistorySuccess();
    } catch (e) {
      return TicketHistoryFailure('Úi, ${e.toString()}');
    }
  }
}