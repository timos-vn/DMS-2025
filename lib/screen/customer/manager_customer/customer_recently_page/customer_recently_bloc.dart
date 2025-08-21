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
import 'customer_recently_event.dart';
import 'customer_recently_sate.dart';


class CustomerRecentlyBloc extends Bloc<CustomerRecentlyEvent, CustomerRecentlyState> {
  NetWorkFactory? _networkFactory;
  BuildContext context;

  String? _accessToken;
  String get accessToken => _accessToken!;
  String? _refreshToken;
  String get refreshToken => _refreshToken!;

  List<ManagerCustomerResponseData> _list = [];
  int _currentPage = 1;
  int _maxPage = Const.MAX_COUNT_ITEM;
  bool isScroll = true;
  int get maxPage => _maxPage;

  List<ManagerCustomerResponseData> get list => _list;

  int get currentPage => _currentPage;

  CustomerRecentlyBloc(this.context) : super(CustomerRecentlyInitial()){
    _networkFactory = NetWorkFactory(context);
    _currentPage = 1;
    on<GetPrefs>(_getPrefs);
    on<GetListCustomerRecently>(_getListCustomerRecently);
  }
  final box = GetStorage();
  void _getPrefs(GetPrefs event, Emitter<CustomerRecentlyState> emitter)async{
    emitter(CustomerRecentlyInitial());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsSuccess());
  }

  void _getListCustomerRecently(GetListCustomerRecently event, Emitter<CustomerRecentlyState> emitter)async{
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter (!isRefresh && !isLoadMore
        ? CustomerRecentlyLoading()
        : CustomerRecentlyInitial());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        CustomerRecentlyState state = await handleCallApi(i);
        if (state is! GetLisCustomerRecentlySuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    CustomerRecentlyState state = await handleCallApi(_currentPage);
    emitter(state);
  }

  Future<CustomerRecentlyState> handleCallApi(int pageIndex) async {
    ManagerCustomerRequestBody request =  ManagerCustomerRequestBody(
        type: 0,
        searchValue: '',
        pageIndex: pageIndex);

    CustomerRecentlyState state = _handleLoadList(await _networkFactory!.searchListCustomer(request,_accessToken!), pageIndex);
    return state;
  }

  CustomerRecentlyState _handleLoadList(Object data, int pageIndex) {
    if (data is String) return CustomerRecentlyFailure('Úi, $data');
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
        return GetLisCustomerRecentlyEmpty();
      } else {
        isScroll = true;
        return GetLisCustomerRecentlySuccess();
      }
    } catch (e) {
      return CustomerRecentlyFailure('Úi, ${e.toString()}');
    }
  }
}
