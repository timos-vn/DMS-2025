import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dms/model/network/response/proprosal.dart';
import 'package:dms/model/network/services/network_factory.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../../../model/network/request/dynamic_form_request.dart';
import '../../../model/network/response/dynamic_form_fix_response.dart';
import '../../../model/network/response/report_layout_response.dart';

part 'proposal_event.dart';
part 'proposal_state.dart';

class ProposalBloc extends Bloc<ProposalEvent, ProposalState> {
  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String get accessToken => _accessToken!;
  String? _refreshToken;
  String get refreshToken => _refreshToken!;
  List<File> listFileImage = [];
  int so_luong_anh = 0;
  int _currentPage = 1;
  int _maxPage = 10;
  bool isScroll = true;
  int get maxPage => _maxPage;

  bool isShowCancelButton = false;
  final box = GetStorage();
  int totalPager = 0;

  ProposalResponse _proposalResponse = ProposalResponse();
  ProposalResponse get proposalResponse => _proposalResponse;
  ProposalBloc(this.context) : super(ProposalInitial()) {
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsProposal>(_getPrefs);
    on<GetListProposalEvent>(_getListProposal);
    on<ActionDynamicEvent>(_actionDynamicEvent);
    on<GetFormDynamicEvent>(_getFormDynamicEvent);
    on<GetLookUpFormDynamicEvent>(_getLookUpFormDynamicEvent);
    on<ViewDetailFormDynamicEvent>(_viewDetailFormDynamicEvent);
    on<GetLayoutSearchEvent>(_getLayoutSearchEvent);
    on<UploadFileEvent>(_uploadFileEvent);
  }

  void _getPrefs(GetPrefsProposal event, Emitter<ProposalState> emitter) async {
    emitter(ProposalInitial());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsSuccess());
  }

  void _getFormDynamicEvent(GetFormDynamicEvent event, Emitter<ProposalState> emitter) async {
    emitter(ProposalLoading());
    ProposalState state = _handleGetFormDynamic(await _networkFactory!.getFormDynamic(token: _accessToken.toString(),controller: event.controller.toString()),0);
    emitter(state);
  }
  void _uploadFileEvent(UploadFileEvent event, Emitter<ProposalState> emitter) async {
    emitter(ProposalLoading());
    var formData = FormData.fromMap(
        {
          "files": await Future.wait(
              listFileImage.map((file) async {
                XFile compress = await compressImage(file);
                return await MultipartFile.fromFile(compress.path,filename: compress.path);
              })
          ),
        }
    );
    ProposalState state = _handleActionUploadFile(await _networkFactory!.uploadFile(
        token: _accessToken.toString(),
        controller: event.controller.toString(),
        code: event.keyUpload, request: formData
    ));
    emitter(state);
  }

  Future<XFile> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // giảm chất lượng xuống ~70%
    );

    return result!;
  }

  void _getLayoutSearchEvent(GetLayoutSearchEvent event, Emitter<ProposalState> emitter) async {
    emitter(ProposalLoading());
    ProposalState state = _handleGetListReportLayout(await _networkFactory!.getSearchFormDynamic(token: _accessToken.toString(),controller: event.controller.toString()));
    emitter(state);
  }

  void _viewDetailFormDynamicEvent(ViewDetailFormDynamicEvent event, Emitter<ProposalState> emitter) async {
    emitter(ProposalLoading());
    List<ViewDetailDynamicFormRequest> listRequest = [];
    for (var element in event.listRequestDetail) {
      ViewDetailDynamicFormRequest request = ViewDetailDynamicFormRequest(
          variable: element['variable'].toString().trim(),
          type: element['type'].toString().trim(),
          value: element['value'].toString().trim()
      );
      listRequest.add(request);
    }
    ProposalState state = _handleGetFormDynamic(await _networkFactory!.viewDetailFormDynamic(
        token: _accessToken.toString(),
        controller: event.controller.toString(),
        request: listRequest), 4);
    emitter(state);
  }

  void _actionDynamicEvent(ActionDynamicEvent event, Emitter<ProposalState> emitter) async {
    emitter(ProposalLoading());
    ProposalState state = _handleActionDynamic(await _networkFactory!.actionDynamic(
        token: _accessToken.toString(),
        controller: event.controller.toString(),
        request: event.request, action: event.action),event.controller);
    emitter(state);
  }

  void _getListProposal(GetListProposalEvent event, Emitter<ProposalState> emitter) async {
    emitter(ProposalLoading());
    ProposalState state = _handleLoadList(
      await _networkFactory!.getListProposal(
        accessToken,
        10,
        event.pageIndex,
        event.controller,event.listRequestDetail
      ),
    );
    emitter(state);
  }

  void _getLookUpFormDynamicEvent(GetLookUpFormDynamicEvent event, Emitter<ProposalState> emitter) async {
    emitter(ProposalLoading());
    ProposalState state = _handleLoadLookUpDynamicForm(await _networkFactory!.getListLookupDynamicForm(accessToken, 10, event.pageIndex, event.controller,event.listRequestDetail),);
    emitter(state);
  }

  Map<String,dynamic> jsonListData = {};
  ProposalState _handleLoadList(Object data) {
    if (data is String) return ProposalFailure(data);
    try {
      jsonListData = data as Map<String, dynamic>;
      if (Utils.isEmpty(jsonListData)) {
        return GetListProposalEmpty();
      } else {
        totalPager = jsonListData['totalPage'];
        return GetListProposalSuccess();
      }
    } catch (e) {
      return ProposalFailure('Úi, ${e.toString()}');
    }
  }

  Map<String,dynamic> jsonListLookUpDynamicForm = {};

  List<Map<String,dynamic>> listFieldsLookup = [];
  ProposalState _handleLoadLookUpDynamicForm(Object data) {
    if (data is String) return ProposalFailure(data);
    try {
      jsonListLookUpDynamicForm = data as Map<String, dynamic>;
      if (Utils.isEmpty(jsonListLookUpDynamicForm)) {
        return LookUpDynamicFormEmpty();
      } else {
        totalPager = jsonListLookUpDynamicForm['totalPage'];
        final List<dynamic> rawFields = jsonListLookUpDynamicForm['data']['lookupDefine']['fields'];
        if(rawFields.isNotEmpty){
          listFieldsLookup = List<Map<String,dynamic>>.from(rawFields);
        }
        return LookUpDynamicFormSuccess();
      }
    } catch (e) {
      return ProposalFailure('Úi, ${e.toString()}');
    }
  }

  FormDataFix formFixData = FormDataFix();

  ProposalState _handleGetFormDynamic(Object data, int actionView) {
    if (data is String) return ProposalFailure(data);
    try {
      jsonListData = data as Map<String, dynamic>;
      if(actionView == 4){
        formFixData = FormDataFix.fromJson(jsonListData['data']['formDatas']['formDataFix']);
      }
      values = "${formFixData.stt_rec_nv.toString().trim()},${formFixData.ma_nv.toString().trim()},${formFixData.ngayDn.toString().trim().split('T').first}";
      print(values);
      if (Utils.isEmpty(jsonListData)) {
        return GetListProposalEmpty();
      } else {
        return GetFormDynamicSuccess();
      }
    } catch (e) {
      return ProposalFailure('Úi, ${e.toString()}');
    }
  }
  String? values;
  ProposalState _handleActionDynamic(Object data, String controller) {
    if (data is String) return ProposalFailure(data);
    try {

      ActionDynamicResponse response = ActionDynamicResponse.fromJson(data as Map<String, dynamic>);
      if(controller.contains('CheckinExplan')){
         String? x = (response.data as List?)?.first?['data'] as String?;
         if(x.toString().replaceAll('null', '').isNotEmpty){
           values = (response.data as List?)?.first?['data'] as String?;
         }
      }
      if (response.statusCode == 200) {
        return ActionDynamicSuccess(values: values.toString());
      } else {
        return ProposalFailure('Úi, ${response.message.toString()}');
      }
    } catch (e) {
      print(e.toString());
      return ProposalFailure('Úi, ${e.toString()}');
    }
  }
  ProposalState _handleActionUploadFile(Object data) {
    if (data is String) return ProposalFailure(data);
    try {
      ActionDynamicResponse response = ActionDynamicResponse.fromJson(data as Map<String, dynamic>);


      if (response.statusCode == 200) {
        return ActionUploadFileSuccess();
      } else {
        return ProposalFailure('Úi, ${response.message.toString()}');
      }
    } catch (e) {
      return ProposalFailure('Úi, ${e.toString()}');
    }
  }
  List<DataReportLayout> listDataReportLayout = <DataReportLayout>[];
  ProposalState _handleGetListReportLayout(Object data){
    if (data is String) return ProposalFailure('Úi, ${data.toString()}');
    try{
      ReportLayoutResponse response = ReportLayoutResponse.fromJson(data as Map<String,dynamic>);
      listDataReportLayout = response.reportLayoutData!;
      return GetListReportLayoutSuccess();
    }
    catch(e){
      return ProposalFailure('Úi, ${e.toString()}');
    }
  }
}
