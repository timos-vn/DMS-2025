import 'package:dms/model/database/dbhelper.dart';
import 'package:dms/model/entity/product.dart';
import 'package:dms/model/network/response/contract_reponse.dart';
import 'package:dms/screen/sell/contract/contract_event.dart';
import 'package:dms/screen/sell/contract/contract_state.dart';
import 'package:dms/utils/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import '../../../model/network/services/network_factory.dart';


class ContractBloc extends Bloc<ContractEvent,ContractState>{

  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  final box = GetStorage();
  bool isScroll = true;
  int _currentPage = 1;
  int _maxPage = 10;
  int get maxPage => _maxPage;
  int totalPager = 0;
  DatabaseHelper db = DatabaseHelper();
  List<ContractItem> listContract = [];
  List<ItemOrderFormContract> listOrderFormContract = [];
  List<ListItem> listItemProduct = [];
  List<ListKD> listKD = [];
  Payment payment = Payment();
  List<Product> listProduct = <Product>[];

  ContractBloc(this.context) : super(InitialContractState()){
    _networkFactory = NetWorkFactory(context);

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    on<GetContractPrefsEvent>(_getContractPrefsEvent);
    on<GetListContractEvent>(_getListContractEvent);
    on<GetDetailContractEvent>(_getDetailContractEvent);
    on<AddCartEvent>(_addCartEvent);
    on<AddCartWithSttRec0ReplaceEvent>(_addCartWithSttRec0ReplaceEvent);
    on<DeleteProductInCartEvent>(_deleteProductInCartEvent);
    on<GetCountProductEvent>(_getCountProductEvent);
    on<GetListOrderFormContractEvent>(_getListOrderFormContractEvent);
  }

  Future<List<Product>> getListFromDb() {
    return db.fetchAllProduct();
  }

  void _getCountProductEvent(GetCountProductEvent event, Emitter<ContractState> emitter)async{
    // Smart loading cho search mode
    if (listItemProduct.isEmpty) {
      emitter(ContractInitialLoading());
    } else {
      emitter(ContractPaginationLoading());
    }
    
    listProduct = await getListFromDb();
    Const.numberProductInCart = listProduct.length;
    emitter(GetCountProductSuccess(event.isNextScreen));
  }

  void _deleteProductInCartEvent(DeleteProductInCartEvent event, Emitter<ContractState> emitter)async{
    emitter(ContractLoading());
    db.deleteAllProduct().then((value) => print('delete success'));
    emitter(DeleteProductInCartSuccess());
  }

  void _addCartEvent(AddCartEvent event, Emitter<ContractState> emitter)async{
    emitter(ContractLoading());
    await db.addProduct(event.productItem!);
    emitter(AddCartSuccess());
  }

  void _addCartWithSttRec0ReplaceEvent(AddCartWithSttRec0ReplaceEvent event, Emitter<ContractState> emitter)async{
    emitter(ContractLoading());
    await db.addProductWithSttRec0Replace(event.productItem!);
    emitter(AddCartSuccess());
  }


  void _getContractPrefsEvent(GetContractPrefsEvent event, Emitter<ContractState> emitter)async{
    emitter(InitialContractState());
    emitter(GetPrefsSuccess());
  }

  void _getListContractEvent(GetListContractEvent event, Emitter<ContractState> emitter)async{
    // Smart loading: Initial (skeleton) hoặc Pagination (shimmer overlay)
    if (listContract.isEmpty && event.pageIndex == 1) {
      emitter(ContractInitialLoading());
    } else {
      emitter(ContractPaginationLoading());
    }
    
    ContractState state = _handleGetListContract(await _networkFactory!.getListContract(_accessToken.toString(),event.searchKey,event.pageIndex,20));
    emitter(state);
  }

  void _getListOrderFormContractEvent(GetListOrderFormContractEvent event, Emitter<ContractState> emitter)async{
    emitter(ContractOrderListLoading());
    ContractState state = _handleGetListOrderFormContract(await _networkFactory!.getListOrderFormContract(_accessToken.toString(),event.soCt));
    emitter(state);
  }

  void _getDetailContractEvent(GetDetailContractEvent event, Emitter<ContractState> emitter)async{
    // Smart loading: Initial (skeleton) hoặc Pagination (progress bar)
    if (listItemProduct.isEmpty && event.pageIndex == 1) {
      emitter(ContractInitialLoading());
    } else {
      emitter(ContractPaginationLoading());
    }

    ContractState state = _handleGetDetailContract(await _networkFactory!.
    getDetailContract(_accessToken.toString(),event.sttRec,event.date,event.pageIndex,20,event.searchKey, event.isSearchItem == true ? 1 : 0));
    emitter(state);
  }


  ContractState _handleGetListContract(Object data){
    if(data is String) return ContractFailure('Úi, ${data.toString()}');
    try{
      listContract.clear();
      GetListContractResponse response = GetListContractResponse.fromJson(data as Map<String,dynamic>);
      listContract = response.data??[];
      totalPager = response.totalPage??0;
      return GetListContractSuccess();
    }catch(e){
      return ContractFailure('Úi, ${e.toString()}');
    }
  }

  ContractState _handleGetDetailContract(Object data){
    if(data is String) return ContractFailure('Úi, ${data.toString()}');
    try{
      listContract.clear();
      GetDetailContractResponse response = GetDetailContractResponse.fromJson(data as Map<String,dynamic>);
      listKD = response.data?.listKD??[];
      listItemProduct = response.data?.listItem??[];

      // Tính toán so_luong_kd cho từng ListItem dựa trên ListKD
      for (var item in listItemProduct) {
        // Tìm ListKD tương ứng với maVt2
        var kdItem = listKD.firstWhere(
          (kd) => kd.maVt2 == item.maVt2,
          orElse: () => ListKD(maVt2: item.maVt2, totalOrder: 0, totalAllowsOrder: 0),
        );
        
        // Tính số lượng cho phép đặt hàng = totalAllowsOrder - totalOrder
        double soLuongChoPhep = (kdItem.totalAllowsOrder ?? 0) - (kdItem.totalOrder ?? 0);
        item.so_luong_kd = soLuongChoPhep > 0 ? soLuongChoPhep : 0;
      }
      payment = response.data?.payment??Payment();
      totalPager = response.totalPage??0;
      return GetDetailContractSuccess();
    }catch(e){
      print(e.toString());
      return ContractFailure('Úi, ${e.toString()}');
    }
  }

  ContractState _handleGetListOrderFormContract(Object data){
    if(data is String) return ContractFailure('Úi, ${data.toString()}');
    try{
      listOrderFormContract.clear();
      ListItemOrderFormContractResponse response = ListItemOrderFormContractResponse.fromJson(data as Map<String,dynamic>);
      listOrderFormContract = response.data??[];
      return GetListOrderFormContractSuccess();
    }catch(e){
      print(e.toString());
      return ContractFailure('Úi, ${e.toString()}');
    }
  }
}