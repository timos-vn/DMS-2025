import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../model/network/request/manager_customer_request.dart';
import '../../../../model/network/response/manager_customer_response.dart';
import '../../../../model/network/services/network_factory.dart';
import '../../../../utils/const.dart';
import '../../../../utils/utils.dart';
import 'customer_all_event.dart';
import 'customer_all_sate.dart';


class ManagerCustomerAllBloc extends Bloc<ManagerCustomerAllEvent, ManagerCustomerAllState> {
  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String get accessToken => _accessToken!;
  String? _refreshToken;
  String get refreshToken => _refreshToken!;

  List<ManagerCustomerResponseData> _list = [];
  List<ManagerCustomerResponseData> get list => _list;
  int _currentPage = 1;
  int _maxPage = Const.MAX_COUNT_ITEM;
  bool isScroll = true;
  int get maxPage => _maxPage;



  int get currentPage => _currentPage;

  ManagerCustomerAllBloc(this.context) : super(ManagerCustomerAllInitial()){
    _networkFactory = NetWorkFactory(context);
    _currentPage = 1;
    on<GetPrefs>(_getPrefs);
    on<GetListCustomerAll>(_getListCustomerAll);
  }
  final box = GetStorage();
  void _getPrefs(GetPrefs event, Emitter<ManagerCustomerAllState> emitter)async{
    emitter(ManagerCustomerAllInitial());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsSuccess());
  }

  void _getListCustomerAll(GetListCustomerAll event, Emitter<ManagerCustomerAllState> emitter)async{
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter (!isRefresh && !isLoadMore
        ? ManagerCustomerAllLoading()
        : ManagerCustomerAllInitial());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        ManagerCustomerAllState state = await handleCallApi(i);
        if (state is! GetLisCustomerAllSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    ManagerCustomerAllState state = await handleCallApi(_currentPage);
    emitter(state);
  }

  Future<ManagerCustomerAllState> handleCallApi(int pageIndex) async {
    ManagerCustomerRequestBody request = ManagerCustomerRequestBody(
        type: 1,
        searchValue: '',
        pageIndex: pageIndex);
    ManagerCustomerAllState state = _handleLoadList(await _networkFactory!.searchListCustomer(request,_accessToken!), pageIndex);
    return state;
  }

  ManagerCustomerAllState _handleLoadList(Object data, int pageIndex) {
    if (data is String) return ManagerCustomerAllFailure('Úi, $data');
    try {
      ManagerCustomerResponse response = ManagerCustomerResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 20;
      List<ManagerCustomerResponseData> list = response.data!;
      if (!Utils.isEmpty(list) && _list.length >= (pageIndex - 1) * _maxPage + list.length) {
        _list.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          _list = list;
        } else {
          _list.addAll(list);
        }
      }
      if (Utils.isEmpty(_list)) {
        return GetLisCustomerAllEmpty();
      } else {
        isScroll = true;
        return GetLisCustomerAllSuccess();
      }
    } catch (e) {
      return ManagerCustomerAllFailure('Úi, ${e.toString()}');
    }
  }
}
