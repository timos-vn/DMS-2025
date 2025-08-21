import 'package:dio/dio.dart';
import 'package:dms/model/database/data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import 'package:dms/model/network/services/network_factory.dart';
import 'package:dms/utils/const.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../model/network/response/list_state_customer.dart';
import '../../../../model/network/response/list_tour_response.dart';
import '../../../../utils/utils.dart';
import 'search_tour_event.dart';
import 'search_tour_state.dart';


class SearchTourBloc extends Bloc<SearchTourEvent,SearchTourState>{
  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  int _currentPage = 1;
  int get currentPage => _currentPage;
  int _maxPage = 20;
  bool isScroll = true;
  int get maxPage => _maxPage;

  String idTour = '';
  String nameTour = '';

  bool isShowCancelButton = false;

  List<GetListTourResponseData> _searchResultsTour = <GetListTourResponseData>[];
  List<GetListTourResponseData> get searchResultsTour => _searchResultsTour;

  List<ListStateCustomerData> _searchResultsState = <ListStateCustomerData>[];
  List<ListStateCustomerData> get searchResultsState => _searchResultsState;

  late Position currentLocation;
  String currentAddress = '';



  SearchTourBloc(this.context) : super(InitialSearchState()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsSearchTour>(_getPrefs);
    on<GetListTourAndStateEvent>(_getListTourAndStateEvent);
    on<CheckShowCloseEvent>(_checkShowCloseEvent);


  }

  void _checkShowCloseEvent(CheckShowCloseEvent event, Emitter<SearchTourState> emitter)async{
    emitter(SearchLoading());
    isShowCancelButton = !Utils.isEmpty(event.text);
    emitter(InitialSearchState());
  }
  final box = GetStorage();
  void _getPrefs(GetPrefsSearchTour event, Emitter<SearchTourState> emitter)async{
    emitter(InitialSearchState());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);

    emitter(GetPrefsSuccess());
  }

  void _getListTourAndStateEvent(GetListTourAndStateEvent event, Emitter<SearchTourState> emitter)async{
    emitter(InitialSearchState());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? SearchLoading()
        : InitialSearchState());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        SearchTourState state = await handleCallApi(i,event.searchKey.toString(),event.isTour);
        if (state is! GetListSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    SearchTourState state = await handleCallApi(_currentPage,event.searchKey.toString(),event.isTour);
    emitter(state);
  }

  Future<SearchTourState> handleCallApi(int pageIndex,String searchKey,bool isTour) async {
    if(isTour == true){
      SearchTourState state = _handleLoadListTour(await _networkFactory!.getListTour(_accessToken!,searchKey.trim(),pageIndex,_maxPage), pageIndex);
      return state;
    }else{
      SearchTourState state = _handleLoadListState(await _networkFactory!.getListState(_accessToken!,searchKey.trim(),pageIndex,_maxPage), pageIndex);
      return state;
    }
  }

  SearchTourState _handleLoadListTour(Object data, int pageIndex) {
    if (data is String) return SearchFailure('Úi, ${data.toString()}');
    try {
      GetListTourResponse response = GetListTourResponse.fromJson(data as Map<String,dynamic>);
      if(searchResultsTour.isNotEmpty){
        searchResultsTour.clear();
      }
      _maxPage = 20;
      List<GetListTourResponseData> list = response.data!;
      if (!Utils.isEmpty(list) && _searchResultsTour.length >= (pageIndex - 1) * _maxPage + list.length) {
        _searchResultsTour.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          _searchResultsTour = list;
        } else {
          _searchResultsTour.addAll(list);
        }
      }
      if (Utils.isEmpty(_searchResultsTour)) {
        return GetListEmpty();
      } else {
        isScroll = true;
      }
      return GetListSuccess();
    } catch (e) {
      return SearchFailure('Úi, ${e.toString()}');
    }
  }

  SearchTourState _handleLoadListState(Object data, int pageIndex) {
    if (data is String) return SearchFailure('Úi, ${data.toString()}');
    try {
      ListStateCustomer response = ListStateCustomer.fromJson(data as Map<String,dynamic>);
      if(searchResultsState.isNotEmpty){
        searchResultsState.clear();
      }
      _maxPage = 20;
      List<ListStateCustomerData> list = response.data!;
      if (!Utils.isEmpty(list) && _searchResultsState.length >= (pageIndex - 1) * _maxPage + list.length) {
        _searchResultsState.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          _searchResultsState = list;
        } else {
          _searchResultsState.addAll(list);
        }
      }
      if (Utils.isEmpty(_searchResultsState)) {
        return GetListEmpty();
      } else {
        isScroll = true;
      }
      return GetListSuccess();
    } catch (e) {
      return SearchFailure('Úi, ${e.toString()}');
    }
  }
}