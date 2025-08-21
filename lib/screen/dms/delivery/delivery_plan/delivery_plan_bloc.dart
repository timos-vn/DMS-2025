import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:dms/model/network/request/delivery_plan_request.dart';
import 'package:dms/model/network/request/detail_delivery_plan_request.dart';
import 'package:dms/model/network/request/update_plan_delivery_request.dart';
import 'package:dms/model/network/response/delivery_plan_detail_response.dart';
import 'package:dms/model/network/response/delivery_response.dart';
import 'package:dms/model/network/services/network_factory.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';

import 'delivery_plan_event.dart';
import 'delivery_plan_state.dart';

class DeliveryPlanBloc extends Bloc<DeliveryPlanEvent,DeliveryPlanState>{
  NetWorkFactory? _networkFactory;
  BuildContext context;

  String? userName;
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  int _currentPage = 1;
  int _maxPage = 10;
  bool isScroll = true;
  int get maxPage => _maxPage;

  List<DeliveryPlanResponseData> _listDeliveryPlan = <DeliveryPlanResponseData>[];
  List<DeliveryPlanResponseData> get listDeliveryPlan => _listDeliveryPlan;

  List<DeliveryPlanDetailResponseData> listDetailDeliveryPlan = <DeliveryPlanDetailResponseData>[];

  DeliveryPlanBloc(this.context) : super(DeliveryPlanInitial()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsDeliveryPlan>(_getPrefs);
    on<GetListDeliveryPlan>(_getListDeliveryPlan);
    on<GetDetailDeliveryPlan>(_getDetailDeliveryPlan);
    on<UpdatePlanDeliveryDraft>(_updatePlanDeliveryDraft);on<CreatePlanDelivery>(_createPlanDelivery);
  }
  final box = GetStorage();
  void _getPrefs(GetPrefsDeliveryPlan event, Emitter<DeliveryPlanState> emitter)async{
    emitter(DeliveryPlanInitial());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    userName = box.read(Const.USER_NAME);
    emitter(GetPrefsSuccess());
  }

  void _getListDeliveryPlan(GetListDeliveryPlan event, Emitter<DeliveryPlanState> emitter)async{
    emitter(DeliveryPlanInitial());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? DeliveryPlanLoading()
        : DeliveryPlanInitial());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        DeliveryPlanState state = await handleCallApi(i,event.dateFrom.toString(),event.dateTo.toString());
        if (state is! GetListDeliveryPlanSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    DeliveryPlanState state = await handleCallApi(_currentPage,event.dateFrom.toString(),event.dateTo.toString());
    emitter(state);
  }

  Future<DeliveryPlanState> handleCallApi(int pageIndex,String dateFrom, String dateTo) async {
    DeliveryPlanRequest request = DeliveryPlanRequest(
        dateTimeFrom : dateFrom,
        dateTimeTo: dateTo,
        pageIndex: pageIndex,
        pageCount: 10
    );

    DeliveryPlanState state = _handleLoadList(
        await _networkFactory!.getListDeliveryPlan(request,_accessToken!), pageIndex);
    return state;
  }

  void _getDetailDeliveryPlan(GetDetailDeliveryPlan event, Emitter<DeliveryPlanState> emitter)async{
    emitter(DeliveryPlanLoading());
    DeliveryPlanDetailRequest request = DeliveryPlanDetailRequest(
        sttRec: event.soCt,
        ngayGiao: event.ngayGiao,
        maKH: event.maKH,
        maVc: event.maVc,
        nguoiGiao: event.nguoiGiao
    );

    DeliveryPlanState state = _handleGetDetailDeliveryPlan(
        await _networkFactory!.getDetailDeliveryPlan(request,_accessToken!));
    emitter(state);
  }

  void _updatePlanDeliveryDraft(UpdatePlanDeliveryDraft event, Emitter<DeliveryPlanState> emitter)async{
    emitter(DeliveryPlanLoading());
    UpdatePlanDeliveryRequest request = UpdatePlanDeliveryRequest(
      data: UpdatePlanDeliveryData(
          sttRec: event.sttRec,
          orderDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          ngayCt: '',
          soCt: '',
          detail: event.listDelivery
      ),
    );
    DeliveryPlanState state = _handleUpdatePlanDeliveryDraft(await _networkFactory!.updatePlanDeliveryDraft(request,_accessToken!));
    emitter(state);
  }

  void _createPlanDelivery(CreatePlanDelivery event, Emitter<DeliveryPlanState> emitter)async{
    emitter(DeliveryPlanLoading());
    UpdatePlanDeliveryRequest request = UpdatePlanDeliveryRequest(
      data: UpdatePlanDeliveryData(
          sttRec: event.sttRec,
          soCt: event.soCt,
          ngayCt: event.ngayCt,
          orderDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          detail: event.listDelivery
      ),
    );
    DeliveryPlanState state = _handleCreatePlanDelivery(await _networkFactory!.createPlanDelivery(request,_accessToken!));
    emitter(state);
  }

  DeliveryPlanState _handleLoadList(Object data, int pageIndex) {
    if (data is String) return DeliveryPlanFailure('Úi, ${data.toString()}');
    try {
      DeliveryPlanResponse response = DeliveryPlanResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 10;
      List<DeliveryPlanResponseData>? list = response.data;

      if (!Utils.isEmpty(list!) && _listDeliveryPlan.length >= (pageIndex - 1) * _maxPage + list.length) {
        _listDeliveryPlan.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          _listDeliveryPlan = list;
        } else {
          _listDeliveryPlan.addAll(list);
        }
      }
      if (Utils.isEmpty(_listDeliveryPlan)) {
        return GetListDeliveryPlanEmpty();
      } else {
        isScroll = true;
      }
      return GetListDeliveryPlanSuccess();
    } catch (e) {
      return DeliveryPlanFailure('Úi, ${e.toString()}');
    }
  }


  DeliveryPlanState _handleGetDetailDeliveryPlan(Object data) {
    if (data is String) return DeliveryPlanFailure('Úi, $data');
    try {
      listDetailDeliveryPlan.clear();
      DeliveryPlanDetailResponse response = DeliveryPlanDetailResponse.fromJson(data as Map<String,dynamic>);
      listDetailDeliveryPlan = response.data!;
      if (Utils.isEmpty(listDetailDeliveryPlan)) {
        return GetListDeliveryPlanEmpty();
      } else {
        isScroll = true;
      }
      return GetListDeliveryPlanSuccess();
    } catch (e) {
      return DeliveryPlanFailure('Úi, ${e.toString()}');
    }
  }

  DeliveryPlanState _handleUpdatePlanDeliveryDraft(Object data,) {
    if (data is String) return DeliveryPlanFailure('Úi, ${data.toString()}');
    try {
      return UpdateDeliveryPlanSuccess();
    } catch (e) {
      return DeliveryPlanFailure(e.toString());
    }
  }

  DeliveryPlanState _handleCreatePlanDelivery(Object data,) {
    if (data is String) return DeliveryPlanFailure('Úi, ${data.toString()}');
    try {
      return CreateDeliveryPlanSuccess();
    } catch (e) {
      return DeliveryPlanFailure(e.toString());
    }
  }

}