import 'package:dms/model/database/data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dms/model/network/services/network_factory.dart';
import 'package:dms/utils/const.dart';

import '../../../../model/database/dbhelper.dart';
import '../../../../model/network/request/save_inventory_control_request.dart';
import '../../../../model/network/response/list_inventory_history_response.dart';
import '../../../../utils/utils.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';


class InventoryBloc extends Bloc<InventoryEvent,InventoryState>{
  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? userName;
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;
  int indexBanner = 0;
  bool openStore = true;
  DatabaseHelper db = DatabaseHelper();

  int _currentPage = 1;
  int get currentPage => _currentPage;
  int _maxPage = 20;
  bool isScroll = true;
  int get maxPage => _maxPage;

  List<GetListInventoryHistoryResponseData> _listInventoryHistory = <GetListInventoryHistoryResponseData>[];
  List<GetListInventoryHistoryResponseData> get listInventoryHistory => _listInventoryHistory;

  late Position currentLocation;
  String currentAddress = '';



  InventoryBloc(this.context) : super(InitialInventoryState()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsInventory>(_getPrefs);
    on<GetListInventory>(_getListInventory);
    on<SaveInventoryStock>(_saveInventoryStock);
  }
  final box = GetStorage();
  void _getPrefs(GetPrefsInventory event, Emitter<InventoryState> emitter)async{
    emitter(InitialInventoryState());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    userName = box.read(Const.USER_NAME);
    emitter(GetPrefsSuccess());
  }

  void _saveInventoryStock(SaveInventoryStock event, Emitter<InventoryState> emitter)async{
    emitter(InventoryLoading());
    InventoryControlAndSaleOutRequest request = InventoryControlAndSaleOutRequest(
        data: InventoryControlAndSaleOutRequestData(
            customerID: event.idCustomer,
            orderDate: Utils.parseDateToString(DateTime.now(), Const.DATE_FORMAT_2),
            idCheckIn: event.idCheckIn.toString(),
            detail: DataLocal.listInventoryLocal
        )
    );

    InventoryState state = _handleSaveInventoryControl(await _networkFactory!.saveInventoryControl(request,_accessToken!));
    emitter(state);
  }

  void _getListInventory(GetListInventory event, Emitter<InventoryState> emitter)async{
    emitter(InitialInventoryState());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? InventoryLoading()
        : InitialInventoryState());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        InventoryState state = await handleCallApi(i,event.idCustomer.toString(),event.idCheckIn.toString());
        if (state is! GetListInventorySuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    InventoryState state = await handleCallApi(_currentPage,event.idCustomer.toString(),event.idCheckIn.toString(),);
    emitter(state);
  }


  Future<InventoryState> handleCallApi(int pageIndex,String idCustomer, String idCheckIn) async {

    InventoryState state = _handleLoadList(await _networkFactory!.getListInventory(_accessToken!,idCustomer,idCheckIn,pageIndex,_maxPage), pageIndex);
    return state;
  }

  InventoryState _handleLoadList(Object data, int pageIndex) {
    if (data is String) return InventoryFailure('Úi, ${data.toString()}');
    try {
      GetListInventoryHistoryResponse response = GetListInventoryHistoryResponse.fromJson(data as Map<String,dynamic>);

      _maxPage = 20;
      List<GetListInventoryHistoryResponseData> list = response.data!;
      if (!Utils.isEmpty(list) && _listInventoryHistory.length >= (pageIndex - 1) * _maxPage + list.length) {
        _listInventoryHistory.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          _listInventoryHistory = list;
        } else {
          _listInventoryHistory.addAll(list);
        }
      }
      if (Utils.isEmpty(_listInventoryHistory)) {
        return GetListInventoryEmpty();
      } else {
        isScroll = true;
      }
      return GetListInventorySuccess();
    } catch (e) {
      return InventoryFailure('Úi, ${e.toString()}');
    }
  }

  InventoryState _handleSaveInventoryControl(Object data){
    if(data is String) return InventoryFailure('Úi, ${data.toString()}');
    try{
      return SaveInventoryStockSuccess();
    }catch(e){
      return InventoryFailure('Úi, ${e.toString()}');
    }
  }
}