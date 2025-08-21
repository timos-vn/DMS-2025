import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dms/model/entity/entity_request.dart';
import 'package:dms/model/network/response/approval_display_response.dart';
import 'package:dms/utils/const.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../model/network/services/network_factory.dart';
import '../../../../utils/utils.dart';
import 'approval_event.dart';
import 'approval_sate.dart';

class ApprovalBloc extends Bloc<ApprovalEvent,ApprovalState>{
  NetWorkFactory? _networkFactory;
  BuildContext context;

  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  int _currentPage = 1;
  int get currentPage => _currentPage;
  int _maxPage = 10;
  bool isScroll = true;
  int get maxPage => _maxPage;

  List<ApprovalResponseData> listApprovalDisplay = <ApprovalResponseData>[];

  int countApproval = 0;

  ApprovalBloc(this.context) : super(ApprovalInitial()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefs>(_getPrefs);
    on<GetListApprovalEvent>(_getListApprovalEvent);
  }
  final box = GetStorage();
  void _getPrefs(GetPrefs event, Emitter<ApprovalState> emitter)async{
    emitter(ApprovalInitial());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsSuccess());
  }

  void _getListApprovalEvent(GetListApprovalEvent event, Emitter<ApprovalState> emitter)async{
    emitter(ApprovalLoading());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter((!isRefresh && !isLoadMore)
        ? ApprovalLoading()
        : ApprovalInitial());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        ApprovalState state = await handleCallApi(i);
        if (state is! GetListApprovalSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    ApprovalState state = await handleCallApi(_currentPage);
    emitter(state);
  }

  Future<ApprovalState> handleCallApi(int pageIndex) async {
    EntityRequest request = EntityRequest(
        pageCount: 20,
        pageIndex: pageIndex);

    ApprovalState state = _handleGetListApproval(
        await _networkFactory!.getListApproval(request,_accessToken!), pageIndex);
    return state;
  }

  ApprovalState _handleGetListApproval(Object data, int pageIndex){
    if (data is String) return ApprovalFailure('Úi, ${data.toString()}');
    try {
      ApprovalResponse response = ApprovalResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 20;
      List<ApprovalResponseData> list = response.data!;

      if (!Utils.isEmpty(list) && listApprovalDisplay.length >= (pageIndex - 1) * _maxPage + list.length) {
        listApprovalDisplay.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1)
          listApprovalDisplay = list;
        else
          listApprovalDisplay.addAll(list);
      }
      if (Utils.isEmpty(listApprovalDisplay))
        return GetListApprovalEmpty();
      else
        isScroll = true;
      return GetListApprovalSuccess();
    } catch (e) {
      return ApprovalFailure('Úi, ${e.toString()}');
    }
  }
}