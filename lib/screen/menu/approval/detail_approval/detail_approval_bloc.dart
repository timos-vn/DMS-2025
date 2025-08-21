import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:dms/model/network/response/approval_detail_response.dart';
import 'package:dms/model/network/response/entity_response.dart';
import 'package:dms/model/network/response/get_html_approval_response.dart';
import 'package:dms/model/network/response/list_approval_detail_response.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';

import '../../../../model/network/request/atccept_approval_request.dart';
import '../../../../model/network/request/detail_approval_request.dart';
import '../../../../model/network/request/list_status_approval_request.dart';
import '../../../../model/network/response/list_status_response.dart';
import '../../../../model/network/services/network_factory.dart';
import 'detail_approval_event.dart';
import 'detail_approval_state.dart';

class DetailApprovalBloc extends Bloc<DetailApprovalEvent, DetailApprovalState> {
  NetWorkFactory? _networkFactory;
  BuildContext context;

  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  String? _htmlDetailApproval;
  List<ListValuesFilesView> listImage = [];

  List<ListApprovalDetailResponseData> listDetailApprovalDisplay = [];
  List<ListStatusApprovalResponseData> listStatusApproval = [];
  int totalMyPager = 0;

  DetailApprovalBloc(this.context) : super(DetailApprovalInitial()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsDetailApproval>(_getPrefs);
    on<SeenApprovalEvent>(_seenApprovalEvent);
    on<GetListDetailApprovalEvent>(_getListDetailApprovalEvent);
    on<AcceptDetailApprovalEvent>(_acceptDetailApprovalEvent);
    on<GetStatusApprovalEvent>(_getStatusApprovalEvent);
  }
  final box = GetStorage();

  void _getPrefs(GetPrefsDetailApproval event, Emitter<DetailApprovalState> emitter)async{
    emitter(DetailApprovalInitial());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsSuccess());
  }

  void _getStatusApprovalEvent(GetStatusApprovalEvent event, Emitter<DetailApprovalState> emitter)async{
    emitter(DetailApprovalLoading());
    print('Checking status');
    ListStatusApprovalRequest request = ListStatusApprovalRequest(
        loaiDuyet: event.idApproval.toString(),
        pageIndex: 1,
        pageCount: 20
    );
    DetailApprovalState state = _handlerListStatusApproval(await _networkFactory!.getStatusApprovalApproval(request,_accessToken!,));
    emitter(state);
  }

  void _seenApprovalEvent(SeenApprovalEvent event, Emitter<DetailApprovalState> emitter)async{
    emitter(DetailApprovalLoading());
    print('Checking');
    DetailApprovalState state = _handlerSeenApproval(await _networkFactory!.getHTMLApproval(_accessToken!,event.sttRec));
    emitter(state);
  }

    void _getListDetailApprovalEvent(GetListDetailApprovalEvent event, Emitter<DetailApprovalState> emitter)async{
    emitter(DetailApprovalLoading());
    ListApprovalDetailRequest request = new ListApprovalDetailRequest(
        option: event.option,
        status: event.status.toString(),
        loaiDuyet: event.idApproval,
        pageCount: 10,
        pageIndex: event.pageIndex);

    DetailApprovalState state = _handleGetListDetailApproval(
        await _networkFactory!.getListDetailApproval(request,_accessToken!));
    emitter(state);
  }

  void _acceptDetailApprovalEvent(AcceptDetailApprovalEvent event, Emitter<DetailApprovalState> emitter)async{
    emitter(DetailApprovalLoading());
    AcceptApprovalRequest request = AcceptApprovalRequest(
        loaiDuyet: event.idApproval,
        action: event.actionType.toString(),
        sttRec: event.sttRec,
        note: event.note
    );
    DetailApprovalState state = _handlerCallAPIApproval(await _networkFactory!.acceptApprovalApproval(request,_accessToken!,));
    emitter(state);
  }

  DetailApprovalState _handlerListStatusApproval(Object data) {
    if (data is String) return DetailApprovalFailure('Úi, ${data.toString()}');
    try {
      if(!Utils.isEmpty(listStatusApproval)){
        listStatusApproval.clear();
      }
      ListStatusApprovalResponse response = ListStatusApprovalResponse.fromJson(data as Map<String,dynamic>);
      listStatusApproval = response.data!;
      return GetListStatusApprovalSuccess();
    } catch (e) {
      return DetailApprovalFailure('Úi, ${e.toString()}');
    }
  }

  DetailApprovalState _handlerSeenApproval(Object data) {
    if (data is String) return DetailApprovalFailure('Úi, ${data.toString()}');
    try {
      GetHTMLApprovalResponse response = GetHTMLApprovalResponse.fromJson(data as Map<String,dynamic>);
      _htmlDetailApproval = response.data;
      List<ListValuesFile> listFiles = response.listValuesFile!;
      listFiles.forEach((element) {
        ListValuesFilesView item = ListValuesFilesView(
            fileName: element.fileName,
            fileData: Utils.hexToUint8List(element.fileData.toString()),
            fileExt: element.fileExt
        );
        listImage.add(item);
      });
      if(_htmlDetailApproval?.isNotEmpty == true){
        return GetHTMLApprovalSuccess(htmlDetailApproval: _htmlDetailApproval.toString(),listImage: listImage);
      }else {
        return GetHTMLApprovalFail();
      }
    } catch (e) {
      return DetailApprovalFailure('Úi, ${e.toString()}');
    }
  }

  DetailApprovalState _handlerCallAPIApproval(Object data) {
    if (data is String) return DetailApprovalFailure(data.toString());
    try {
      EntityResponse response = EntityResponse.fromJson(data as Map<String,dynamic>);
      return AcceptDetailApprovalSuccess(response.message!);
    } catch (e) {
      print(e);
      return DetailApprovalFailure(e.toString());
    }
  }

  DetailApprovalState _handleGetListDetailApproval(Object data) {
    if (data is String) return DetailApprovalFailure(data);
    try {
      if(!Utils.isEmpty(listDetailApprovalDisplay)){
        listDetailApprovalDisplay.clear();
      }
      ListApprovalDetailResponse response = ListApprovalDetailResponse.fromJson(data as Map<String,dynamic>);
      listDetailApprovalDisplay = response.data!;
      totalMyPager = response.totalPage!;
      if (Utils.isEmpty(listDetailApprovalDisplay))
        return GetListDetailApprovalEmpty();
      else
        return GetListDetailApprovalSuccess();
    } catch (e) {
      return DetailApprovalFailure('Úi, ${e.toString()}');
    }
  }


}
