import 'package:dms/model/database/data_local.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dms/model/network/response/stage_statistic_response.dart';
import 'package:dms/screen/menu/stage/stage_statistic/stage_statistic_event.dart';
import 'package:dms/screen/menu/stage/stage_statistic/stage_statistic_state.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../model/network/request/create_manufacturing_request.dart';
import '../../../../model/network/request/stage_statistic_request.dart';
import '../../../../model/network/response/get_item_materials_response.dart';
import '../../../../model/network/response/get_voucher_transaction_response.dart';
import '../../../../model/network/response/request_section_route_item_response.dart';
import '../../../../model/network/response/semi_product_response.dart';
import '../../../../model/network/services/network_factory.dart';

class StageStatisticBloc extends Bloc<StageStatisticEvent,StageStatisticState>{
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
  bool isShowCancelButton = false;
  List<VoucherTransactionResponseData> listVoucherTransaction =  <VoucherTransactionResponseData>[];
  List<GetItemMaterialsResponseData> listItemMaterialsResponse =  <GetItemMaterialsResponseData>[];
  List<RequestSectionRouteItemResponseData> listRequestSectionAndRouteItem =  <RequestSectionRouteItemResponseData>[];
  List<StageStatisticResponseData> _listStage =  <StageStatisticResponseData>[];
  List<StageStatisticResponseData> get listStage => _listStage;
  List<SemiProductionResponseData> searchResults = <SemiProductionResponseData>[];


  int valueChange = 0;

  StageStatisticBloc(this.context) : super(StageStatisticInitial()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefs>(_getPrefs);
    on<GetListStageStatistic>(_getListStageStatistic);
    on<SearchSemiProduction>(_searchSemiProduction);
    on<CheckShowCloseEvent>(_checkShowCloseEvent);
    on<GetListVoucherTransaction>(_getListVoucherTransaction);
    on<GetListRequestSectionItemEvent>(_getListRequestSectionItem);
    on<RefreshUpdateItemBarCodeEvent>(_refreshUpdateItemBarCodeEvent);
    on<GetItemMaterialsEvent>(_getItemMaterialsEvent);
    on<DeleteSemiItemEvent>(_deleteSemiItemEvent);
    on<CreateManufacturingEvent>(_createManufacturingEvent);
  }
  void reset() {
    _currentPage = 1;
    searchResults.clear();
    _listStage.clear();
    listVoucherTransaction.clear();
    listRequestSectionAndRouteItem.clear();
  }
  final box = GetStorage();
  void _getPrefs(GetPrefs event, Emitter<StageStatisticState> emitter)async{
    emitter(StageStatisticInitial());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsSuccess());
  }
  void _refreshUpdateItemBarCodeEvent(RefreshUpdateItemBarCodeEvent event, Emitter<StageStatisticState> emitter)async{
    emitter(StageStatisticLoading());
    emitter(StageStatisticInitial());
  }

  void _createManufacturingEvent(CreateManufacturingEvent event, Emitter<StageStatisticState> emitter)async{
    emitter(StageStatisticLoading());

    List<CreateManufacturingRequestDetail> listDetail = <CreateManufacturingRequestDetail>[];
    List<RawTable> listRawTable = <RawTable>[];
    List<WasteTable> listWasteTable = <WasteTable>[];
    List<MachineTable> listMachineTable = <MachineTable>[];

    if(DataLocal.listSemiProduction.isNotEmpty){

      for (var element in DataLocal.listSemiProduction) {
        CreateManufacturingRequestDetail itemDetail = CreateManufacturingRequestDetail(
            maVt: element.maVt,
            dvt: element.dvt,soLuong: element.soLuong,maNc: element.codeWorker,
          nhNc: element.codeGWorker,ghiChu: '',maLo: element.ma_lo
        );
        listDetail.add(itemDetail);
      }
    }

    if(DataLocal.listGetItemMaterialsResponse.isNotEmpty){
      for (var element in DataLocal.listGetItemMaterialsResponse) {
        RawTable itemRawTable = RawTable(
          maVt: element.maVt,dvt: element.dvt,soLuong: element.soLuong,rework: 0,
          slCl: element.soLuongConLai,slSd: element.soLuongSuDung,maLo: '',slTn: element.soLuongTiepNhan
        );
        listRawTable.add(itemRawTable);
      }
    }

    if(DataLocal.listWaste.isNotEmpty){
      for (var element in DataLocal.listWaste) {
        WasteTable itemWasteTable = WasteTable(
          maVt: element.maVt,dvt: element.dvt,soLuong: element.soLuong,
          codeStore: element.codeStore
        );
        listWasteTable.add(itemWasteTable);
      }
    }

    if(DataLocal.listMachine.isNotEmpty){
      for (var element in DataLocal.listMachine) {
        MachineTable itemMachineTable = MachineTable(
          maMay: element.maMay,gioBd: element.gioBd.toString().replaceAll('AM', '').replaceAll('PM', ''),gioKt: element.gioKt.toString().replaceAll('AM', '').replaceAll('PM', ''),soGio: element.soGio,ghiChu: ''
        );
        listMachineTable.add(itemMachineTable);
      }
    }

    CreateManufacturingRequest request = CreateManufacturingRequest(
      data: CreateManufacturingRequestData(
        sttRec: '',
        maDvcs: '',
        maGd: event.giaoDich.maGd,
        ngayCt: Utils.parseDateToString(DateTime.now(), Const.DATE_SV_FORMAT_2),
        ghiChu: event.ghiChu,
        tSoLuong: DataLocal.listSemiProduction.length,
        maNc: event.codeWorker,
        maPx: event.codePX,
        maLsx: event.codeLsx,
        maCd: event.codeCD,maCa: event.codeCa,slNc: event.quantityWorker,
          gioBd: event.timeStart.replaceAll(' ', ''),
        gioKt: event.timeEnd.replaceAll(' ', ''),
        detail: listDetail,
        rawTable: listRawTable,
        wasteTable: listWasteTable,
        machineTable: listMachineTable
      )
    );
    StageStatisticState state = _handleCreateManufacturing(await _networkFactory!.createManufacturing(
        request,_accessToken.toString()));
    emitter(state);
  }
  void _deleteSemiItemEvent(DeleteSemiItemEvent event, Emitter<StageStatisticState> emitter)async{
    emitter(StageStatisticLoading());
    if(DataLocal.listGetItemMaterialsResponse.isNotEmpty){
      List<GetItemMaterialsResponseData> itemClear = <GetItemMaterialsResponseData>[];
      for (var element in DataLocal.listGetItemMaterialsResponse) {
        double slDinhMuc = element.soLuongBanDau;
        double slXL = 0;
        if(event.item.maVt.toString().trim() == element.maVtSemi.toString().trim()){
          slXL = slDinhMuc * event.item.soLuong;
          element.soLuong = element.soLuong! - slXL;
          if(element.soLuong == 0){
            itemClear.add(element);
          }
        }
      }
      if(itemClear.isNotEmpty){
        for (var element in itemClear) {
          DataLocal.listGetItemMaterialsResponse.remove(element);
        }
        itemClear.clear();
      }
    }
    DataLocal.listSemiProduction.remove(event.item);
    emitter(StageStatisticInitial());
  }

  void _checkShowCloseEvent(CheckShowCloseEvent event, Emitter<StageStatisticState> emitter)async{
    emitter(StageStatisticLoading());
    isShowCancelButton = !Utils.isEmpty(event.text);
    emitter(StageStatisticInitial());
  }

  void _getListVoucherTransaction(GetListVoucherTransaction event, Emitter<StageStatisticState> emitter)async{
    emitter(StageStatisticLoading());
    StageStatisticState state = _handleGetListVoucherTransaction(await _networkFactory!.getListVoucherTransaction(
        token: _accessToken.toString(), vcCode: event.vcCode),event.type);
    emitter(state);
  }

  void _getItemMaterialsEvent(GetItemMaterialsEvent event, Emitter<StageStatisticState> emitter)async{
    emitter(StageStatisticLoading());
    StageStatisticState state = _handleGetItemMaterials(await _networkFactory!.getItemMaterials(
        token: _accessToken.toString(), item: event.item),event.itemValues);
    emitter(state);
  }

  void _getListStageStatistic(GetListStageStatistic event, Emitter<StageStatisticState> emitter)async{
    // emitter(StageStatisticInitial());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? StageStatisticLoading()
        : StageStatisticInitial());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        StageStatisticState state = await handleCallApi(i,event.idStageStatistic,event.unitId);
        if (state is! GetListStageSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    StageStatisticState state = await handleCallApi(_currentPage,event.idStageStatistic,event.unitId,);
    emitter(state);
  }

  void _getListRequestSectionItem(GetListRequestSectionItemEvent event, Emitter<StageStatisticState> emitter)async{
    // emitter(StageStatisticInitial());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    emitter( (!isRefresh && !isLoadMore)
        ? StageStatisticLoading()
        : StageStatisticInitial());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        StageStatisticState state = await handleGetListRequestSectionItem(i,event.request,event.route);
        if (state is! GetListStageSuccess) return;
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    StageStatisticState state = await handleGetListRequestSectionItem(_currentPage,event.request,event.route,);
    emitter(state);
  }

  void _searchSemiProduction(SearchSemiProduction event, Emitter<StageStatisticState> emitter)async{
    // emitter(StageStatisticInitial());
    bool isRefresh = event.isRefresh;
    bool isLoadMore = event.isLoadMore;
    print(!isRefresh);
    print(!isLoadMore);
    emitter( (!isRefresh && !isLoadMore)
        ? StageStatisticLoading()
        : StageStatisticLoading());
    if (isRefresh) {
      for (int i = 1; i <= _currentPage; i++) {
        StageStatisticState state = await handleSearchSemiProduction(event.searchText,event.lsx,event.section, i);
        emitter(state);
      }
      return;
    }
    if (isLoadMore) {
      isScroll = false;
      _currentPage++;
    }
    StageStatisticState state = await handleSearchSemiProduction(event.searchText,event.lsx,event.section, _currentPage);
    emitter(state);
  }

  Future<StageStatisticState> handleSearchSemiProduction(String searchText,String lsx,String section, int pageIndex) async {
    StageStatisticState state = _handleSearch(await _networkFactory!.searchListSemiProduction(
        token: _accessToken.toString(),
        lsx: (lsx != 'null' && lsx.isNotEmpty) ? lsx : '',
        section: (section != 'null' && section.isNotEmpty) ? section : '',
        searchValue: searchText,
        pageIndex: pageIndex, pageCount: 10), pageIndex);
    return state;
  }

  StageStatisticState _handleSearch(Object data, int pageIndex) {
    if (data is String) return StageStatisticFailure('Úi, $data');
    try {
      SemiProductionResponse response = SemiProductionResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 20;
      List<SemiProductionResponseData> list = response.data ?? [];
      if (!Utils.isEmpty(list) && searchResults.length >= (pageIndex - 1) * _maxPage + list.length) {
        searchResults.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list); /// delete list cũ -> add data mới vào list đó.
      } else {
        if (_currentPage == 1) {
          searchResults = list;
        } else {
          searchResults.addAll(list);
        }
      }
      if (searchResults.isNotEmpty) {
        isScroll = true;
        return SearchSemiProductionSuccess();
      } else {
        return EmptySearchSemiProductionState();
      }
    } catch (e) {
      return StageStatisticFailure('Úi, ${e.toString()}');
    }
  }

  Future<StageStatisticState> handleCallApi(int pageIndex,String idStageStatistic, String unitId) async {
    StageStatisticRequest request = StageStatisticRequest(
        to: idStageStatistic,
      unitId: unitId,
      pageIndex: pageIndex,
      pageCount: 10
    );

    StageStatisticState state = _handleLoadList(
        await _networkFactory!.getListStageStatistic(request,_accessToken!), pageIndex);
    return state;
  }

  Future<StageStatisticState> handleGetListRequestSectionItem(int pageIndex,String request, String route) async {
    StageStatisticState state = _handleLoadListRequestSectionItem(
        await _networkFactory!.getListRequestSectionItem(
          token: _accessToken!,
          request: (request != 'null' && request.isNotEmpty) ? request : '',
          route: (route != 'null' && route.isNotEmpty) ? route : '',
          pageIndex: pageIndex,
          pageCount: 10,
        ), pageIndex);
    return state;
  }

  StageStatisticState _handleLoadList(Object data, int pageIndex) {
    if (data is String) return StageStatisticFailure('Úi, ${data.toString()}');
    try {
      StageStatisticResponse response = StageStatisticResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 10;
      List<StageStatisticResponseData>? list = response.data;

      if (!Utils.isEmpty(list!) && _listStage.length >= (pageIndex - 1) * _maxPage + list.length) {
        _listStage.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          _listStage = list;
        } else {
          _listStage.addAll(list);
        }
      }
      if (Utils.isEmpty(_listStage)) {
        return GetListStageEmpty();
      } else {
        isScroll = true;
      }
      return GetListStageSuccess();
    } catch (e) {
      return StageStatisticFailure('Úi, ${e.toString()}');
    }
  }

  StageStatisticState _handleLoadListRequestSectionItem(Object data, int pageIndex) {
    if (data is String) return StageStatisticFailure('Úi, ${data.toString()}');
    try {
      RequestSectionRouteItemResponse response = RequestSectionRouteItemResponse.fromJson(data as Map<String,dynamic>);
      _maxPage = 10;
      List<RequestSectionRouteItemResponseData>? list = response.data;

      if (!Utils.isEmpty(list!) && _listStage.length >= (pageIndex - 1) * _maxPage + list.length) {
        listRequestSectionAndRouteItem.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
      } else {
        if (_currentPage == 1) {
          listRequestSectionAndRouteItem = list;
        } else {
          listRequestSectionAndRouteItem.addAll(list);
        }
      }
      if (Utils.isEmpty(listRequestSectionAndRouteItem)) {
        return GetListStageEmpty();
      } else {
        isScroll = true;
        return GetListRequestSectionAndRouteItemSuccess();
      }
    } catch (e) {
      return StageStatisticFailure('Úi, ${e.toString()}');
    }
  }

  StageStatisticState _handleGetListVoucherTransaction(Object data, int type) {
    if (data is String) return StageStatisticFailure('Úi, ${data.toString()}');
    try {
      VoucherTransactionResponse response = VoucherTransactionResponse.fromJson(data as Map<String,dynamic>);
      listVoucherTransaction = response.data!;
      if (Utils.isEmpty(listVoucherTransaction)) {
        return GetListStageEmpty();
      } else {
        return VoucherTransactionSuccess(type: type);
      }
    } catch (e) {
      return StageStatisticFailure('Úi, ${e.toString()}');
    }
  }

  StageStatisticState _handleGetItemMaterials(Object data,SemiProductionResponseData itemValues) {
    if (data is String) return StageStatisticFailure('Úi, ${data.toString()}');
    try {
      GetItemMaterialsResponse response = GetItemMaterialsResponse.fromJson(data as Map<String,dynamic>);
      listItemMaterialsResponse = response.data!;
      // DataLocal.listGetItemMaterialsResponse = response.data!;

      if (Utils.isEmpty(listItemMaterialsResponse)) {
        return GetItemMaterialsEmpty();
      } else {
        List<GetItemMaterialsResponseData> listGetItemMaterial = [];
        listGetItemMaterial.addAll(DataLocal.listGetItemMaterialsResponse);
        for (var element in listItemMaterialsResponse) {
          double sl = 0;sl = element.soLuong??0;
          element.soLuongBanDau = sl;
          element.maVtSemi = itemValues.maVt;
          element.soLuong = sl * itemValues.soLuong;
          if(listGetItemMaterial.isNotEmpty){
            for (var elementMaterial in listGetItemMaterial) {
              if(element.maVt.toString().trim() == elementMaterial.maVt.toString() && itemValues.maVt.toString().trim() == elementMaterial.maVtSemi.toString()){
                elementMaterial.soLuong = element.soLuong!;
                break;
              }else if(element.maVt.toString().trim() == elementMaterial.maVt.toString() && itemValues.maVt.toString().trim() != elementMaterial.maVtSemi.toString()){
                elementMaterial.soLuong = sl + element.soLuong!;
                break;
              }
            }
          }
          else{
            DataLocal.listGetItemMaterialsResponse.add(element);
          }
        }
        return GetItemMaterialsSuccess();
      }
    } catch (e) {
      return StageStatisticFailure('Úi, ${e.toString()}');
    }
  }

  StageStatisticState _handleCreateManufacturing(Object data){
    if (data is String) return StageStatisticFailure('Úi, ${data.toString()}');
    try{
      return CreateManufacturingSuccess();
    }catch(e){
      return StageStatisticFailure('Úi, ${e.toString()}');
    }
  }
}