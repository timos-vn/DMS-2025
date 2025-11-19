import 'package:dms/model/network/response/new_store_approval_detail_response.dart';
import 'package:dms/model/network/services/network_factory.dart';
import 'package:dms/utils/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import 'new_store_approval_detail_event.dart';
import 'new_store_approval_detail_state.dart';

class NewStoreApprovalDetailBloc
    extends Bloc<NewStoreApprovalDetailEvent, NewStoreApprovalDetailState> {
  final NetWorkFactory _networkFactory;
  final GetStorage _box = GetStorage();
  String? _token;
  NewStoreApprovalDetailData? detail;

  NewStoreApprovalDetailBloc(BuildContext context)
      : _networkFactory = NetWorkFactory(context),
        super(NewStoreApprovalDetailInitial()) {
    _token = _box.read(Const.ACCESS_TOKEN);

    on<NewStoreApprovalDetailFetched>(_onFetched);
    on<NewStoreApprovalSubmitted>(_onSubmitted);
  }

  Future<void> _onFetched(
    NewStoreApprovalDetailFetched event,
    Emitter<NewStoreApprovalDetailState> emit,
  ) async {
    if (_token == null || _token!.isEmpty) {
      emit(const NewStoreApprovalDetailFailure('Không tìm thấy thông tin đăng nhập'));
      return;
    }

    emit(NewStoreApprovalDetailLoading());

    try {
      final Object response = await _networkFactory.getNewStoreApprovalDetail(
        token: _token!,
        idLead: event.idLead,
      );

      if (response is String) {
        emit(NewStoreApprovalDetailFailure('Úi, $response'));
      } else {
        final parsed =
            NewStoreApprovalDetailResponse.fromJson(response as Map<String, dynamic>);
        if (parsed.data != null) {
          detail = parsed.data;
          emit(NewStoreApprovalDetailLoaded(parsed.data!));
        } else {
          emit(const NewStoreApprovalDetailFailure('Không tìm thấy dữ liệu chi tiết'));
        }
      }
    } catch (e) {
      emit(NewStoreApprovalDetailFailure('Úi, ${e.toString()}'));
    }
  }

  Future<void> _onSubmitted(
    NewStoreApprovalSubmitted event,
    Emitter<NewStoreApprovalDetailState> emit,
  ) async {
    if (_token == null || _token!.isEmpty) {
      emit(const NewStoreApprovalDetailFailure('Không tìm thấy thông tin đăng nhập'));
      return;
    }

    emit(NewStoreApprovalDetailLoading());

    try {
      final Object response = await _networkFactory.approveNewStore(
        token: _token!,
        sttRec: event.sttRec,
        action: event.action,
        phanCap: event.phanCap,
      );

      if (response is String) {
        emit(NewStoreApprovalDetailFailure('Úi, $response'));
      } else {
        emit(const NewStoreApprovalActionSuccess('Đã duyệt điểm bán thành công'));
      }
    } catch (e) {
      emit(NewStoreApprovalDetailFailure('Úi, ${e.toString()}'));
    }
  }
}

