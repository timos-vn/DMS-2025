// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import '../../../model/network/request/manager_customer_request.dart';
import '../../../model/network/response/manager_customer_response.dart';
import '../../../model/network/services/network_factory.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import 'search_customer_event.dart';
import 'search_customer_state.dart';

class SearchCustomerBloc extends Bloc<SearchCustomerEvent, SearchCustomerState> {
  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String get accessToken => _accessToken!;
  String? _refreshToken;
  String get refreshToken => _refreshToken!;

  List<ManagerCustomerResponseData> _searchResults = <ManagerCustomerResponseData>[];
  bool isScroll = true;
  bool isShowCancelButton = false;
  int _currentPage = 1;
  int _maxPage = Const.MAX_COUNT_ITEM;
  String? _currentSearchText;

  int get maxPage => _maxPage;

  List<ManagerCustomerResponseData> get searchResults => _searchResults;

  int get currentPage => _currentPage;


  void reset() {
    _currentSearchText = "";
    _currentPage = 1;
    _searchResults.clear();
  }

  SearchCustomerBloc(this.context) : super(InitialSearchState()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefs>(_getPrefs);
    on<SearchCustomer>(_searchCustomer);
    on<CheckShowCloseEvent>(_checkShowCloseEvent);

  }

  bool allowCustomerSearch = false;
  final box = GetStorage();
  void _getPrefs(GetPrefs event, Emitter<SearchCustomerState> emitter)async{
    emitter(InitialSearchState());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsSuccess());
  }

  void _searchCustomer(SearchCustomer event, Emitter<SearchCustomerState> emitter)async{
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    String searchText = event.searchText;
    emitter(SearchLoading());
    if (_currentSearchText != searchText) {
      _currentSearchText = searchText;
      _currentPage = 1;
      _searchResults.clear();
    }
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        SearchCustomerState state = await handleCallApi(searchText, i, event.typeName??false);
        if (state is! SearchSuccess) return;
      }
      return;
    }
    else if (isLoadMore) {
      isScroll = false;
      _currentPage++;
      SearchCustomerState state = await handleCallApi(searchText, _currentPage, event.typeName??false);
      emitter(state);
    }
    // if (event.searchText != null && event.searchText != '') {
      else {
        SearchCustomerState state = await handleCallApi(searchText, _currentPage, event.typeName??false);
        emitter(state);
      }
        // else {
      //   emitter(EmptySearchState());
      // }
    // }
    // else {
    //   emitter(InitialSearchState());
    //   emitter(RequiredText());
    // }
  }

  void _checkShowCloseEvent(CheckShowCloseEvent event, Emitter<SearchCustomerState> emitter)async{
    emitter(SearchLoading());
    isShowCancelButton = !Utils.isEmpty(event.text);
    emitter(InitialSearchState());
  }

  Future<SearchCustomerState> handleCallApi(String searchText, int pageIndex, bool typeName) async {
    ManagerCustomerRequestBody request =  ManagerCustomerRequestBody(
        type: 1,
        searchValue: searchText,
        pageIndex: pageIndex,
        typeName: typeName == true ? 'AGENT' : ((Const.orderWithCustomerRegular == true && allowCustomerSearch == true) ? 'REGULAR' : '')
    );
    SearchCustomerState state = _handleSearch(await _networkFactory!.searchListCustomer(request,_accessToken!), pageIndex);
    return state;
  }

  SearchCustomerState _handleSearch(Object data, int pageIndex) {
    if (data is String) return SearchFailure('Úi, $data');
    try {
      ManagerCustomerResponse response = ManagerCustomerResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 20;//response.pageIndex ?? Const.MAX_COUNT_ITEM;
      List<ManagerCustomerResponseData> list = response.data ?? [];
      if (!Utils.isEmpty(list) && _searchResults.length >= (pageIndex - 1) * _maxPage + list.length) {
        _searchResults.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list); /// delete list cũ -> add data mới vào list đó.
      } else {
        if (_currentPage == 1) {
          _searchResults = list;
        } else {
          _searchResults.addAll(list);
        }
      }
      if (_searchResults.isNotEmpty) {
        isScroll = true;
        return SearchSuccess();
      } else {
        return EmptySearchState();
      }
    } catch (e) {
      return SearchFailure('Úi, ${e.toString()}');
    }
  }
}
