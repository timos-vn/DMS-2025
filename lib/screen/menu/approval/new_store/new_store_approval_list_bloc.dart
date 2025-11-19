import 'package:dms/model/network/response/new_store_approval_list_response.dart';
import 'package:dms/model/network/services/network_factory.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import 'new_store_approval_list_event.dart';
import 'new_store_approval_list_state.dart';

class NewStoreApprovalListBloc
    extends Bloc<NewStoreApprovalListEvent, NewStoreApprovalListState> {
  final NetWorkFactory _networkFactory;
  final GetStorage _box = GetStorage();
  final int _pageSize = 20;
  String? _token;

  final List<NewStoreApprovalItem> _items = [];
  int _pageIndex = 1;
  int _totalPage = 1;
  bool _isFetching = false;

  DateTime _dateFrom = DateTime.now().add(const Duration(days: -7));
  DateTime _dateTo = DateTime.now();
  int? _status = 0;
  String _keySearch = '';

  List<NewStoreApprovalItem> get items => List.unmodifiable(_items);
  DateTime get dateFrom => _dateFrom;
  DateTime get dateTo => _dateTo;
  int? get status => _status;
  String get keySearch => _keySearch;
  bool get canLoadMore => _pageIndex < _totalPage;

  NewStoreApprovalListBloc(BuildContext context)
      : _networkFactory = NetWorkFactory(context),
        super(NewStoreApprovalListInitial()) {
    _token = _box.read(Const.ACCESS_TOKEN);

    on<NewStoreApprovalListFetch>(_onFetch);
    on<NewStoreApprovalListUpdateFilter>(_onUpdateFilter);
    on<NewStoreApprovalListSearch>(_onSearch);
  }

  Future<void> _onFetch(
    NewStoreApprovalListFetch event,
    Emitter<NewStoreApprovalListState> emit,
  ) async {
    if (_token == null || _token!.isEmpty) {
      emit(const NewStoreApprovalListFailure('Không tìm thấy thông tin đăng nhập'));
      return;
    }

    if (_isFetching) return;

    if (event.isLoadMore && !canLoadMore) return;

    _isFetching = true;

    if (event.isRefresh) {
      _pageIndex = 1;
      _totalPage = 1;
      emit(const NewStoreApprovalListLoading(isRefresh: true));
    } else if (_items.isEmpty) {
      emit(const NewStoreApprovalListLoading());
    }

    final int requestPage =
        event.isLoadMore ? _pageIndex + 1 : _pageIndex;

    try {
      final Object response = await _networkFactory.getNewStoreApprovalList(
        token: _token!,
        keySearch: _keySearch,
        dateFrom: Utils.parseDateToString(_dateFrom, Const.DATE_SV_FORMAT_2),
        dateTo: Utils.parseDateToString(_dateTo, Const.DATE_SV_FORMAT_2),
        status: _status,
        pageIndex: requestPage,
        pageCount: _pageSize,
      );

      if (response is String) {
        emit(NewStoreApprovalListFailure('Úi, $response'));
      } else {
        final NewStoreApprovalListResponse parsed =
            NewStoreApprovalListResponse.fromJson(response as Map<String, dynamic>);
        final List<NewStoreApprovalItem> data = parsed.data ?? [];
        _totalPage = parsed.totalPage ?? requestPage;

        if (event.isRefresh) {
          _items
            ..clear()
            ..addAll(data);
        } else if (event.isLoadMore) {
          _items.addAll(data);
        } else {
          _items
            ..clear()
            ..addAll(data);
        }

        if (_items.isEmpty) {
          emit(NewStoreApprovalListEmpty());
        } else {
          _pageIndex = requestPage;
          emit(NewStoreApprovalListSuccess(
            items: List.unmodifiable(_items),
            canLoadMore: canLoadMore,
            isRefresh: event.isRefresh,
          ));
        }
      }
    } catch (e) {
      emit(NewStoreApprovalListFailure('Úi, ${e.toString()}'));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onUpdateFilter(
    NewStoreApprovalListUpdateFilter event,
    Emitter<NewStoreApprovalListState> emit,
  ) async {
    if (event.dateFrom != null) {
      _dateFrom = event.dateFrom!;
    }
    if (event.dateTo != null) {
      _dateTo = event.dateTo!;
    }
    if (event.status != null) {
      _status = event.status;
    }
    add(const NewStoreApprovalListFetch(isRefresh: true));
  }

  Future<void> _onSearch(
    NewStoreApprovalListSearch event,
    Emitter<NewStoreApprovalListState> emit,
  ) async {
    _keySearch = event.keySearch;
    add(const NewStoreApprovalListFetch(isRefresh: true));
  }
}

