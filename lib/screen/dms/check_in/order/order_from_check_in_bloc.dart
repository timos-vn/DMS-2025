

import 'package:dms/model/database/data_local.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../model/database/dbhelper.dart';
import '../../../../model/entity/product.dart';
import '../../../../model/network/services/network_factory.dart';
import '../../../../utils/const.dart';
import 'order_from_check_in_event.dart';
import 'order_from_check_in_state.dart';

class OrderFromCheckInBloc extends Bloc<OrderFromCheckInEvent,OrderFromCheckInState>{
  NetWorkFactory? _networkFactory;
  BuildContext context;

  String? userName;
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;
  String? idUser;

  final db = DatabaseHelper();

  int _currentPage = 1;
  int _maxPage = 20;
  bool isScroll = true;
  int get maxPage => _maxPage;

  List<Product> listItemLocal = [];


  OrderFromCheckInBloc(this.context) : super(InitialOrderFromCheckInState()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsOrderFromCheckIn>(_getPrefs);
    on<AddListItemOrderFromCheckIn>(_addListItemOrderFromCheckIn);
    on<DeleteProductInCartEvent>(_deleteProductInCartEvent);
  }
  final box = GetStorage();
  void _getPrefs(GetPrefsOrderFromCheckIn event, Emitter<OrderFromCheckInState> emitter)async{
    emitter(InitialOrderFromCheckInState());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    userName = box.read(Const.USER_NAME);
    idUser = box.read(Const.USER_ID);
    listItemLocal = await db.fetchAllProduct();
    emitter(GetPrefsSuccess());
  }

  void _deleteProductInCartEvent(DeleteProductInCartEvent event, Emitter<OrderFromCheckInState> emitter)async{
    emitter(OrderFromCheckInLoading());
    if(listItemLocal.isNotEmpty){
      db.deleteAllProduct().then((value) => print('delete success'));
    }
    if(event.isBack == false){
      emitter(DeleteProductInCartSuccess());
    }else{
      emitter(InitialOrderFromCheckInState());
    }

  }

  void _addListItemOrderFromCheckIn(AddListItemOrderFromCheckIn event, Emitter<OrderFromCheckInState> emitter)async{
    emitter(OrderFromCheckInLoading());
    for (var element in DataLocal.listOrderProductLocal) {
      Product production = Product(
          code: element.code,
          name: element.name,
          name2:element.name2,
          dvt: element.dvt,
          description: element.description,
          price: element.price,
          discountPercent: element.discountPercent,
          priceAfter: element.priceAfter,
          stockAmount: element.stockAmount,
          taxPercent: element.taxPercent,
          imageUrl: element.imageUrl,
          count: element.count,
          isMark:1,
          discountProduct: element.discountProduct,
          residualValue: element.residualValue,
          budgetForItem:'',
          budgetForProduct: '',
          discountMoney: '0',
          contentDvt:  '',
          unit: element.unit,
          dsCKLineItem: '',
          unitProduct: element.unitProduct,
          kColorFormatAlphaB:element.kColorFormatAlphaB,
          codeStock: element.codeStock.toString(),
          nameStock: element.nameStock.toString()
      );
      await db.addProduct(production);
    }
    emitter(AddListItemProductSuccess());
  }


  // void _createOderFromCheckInEvent(CreateOderFromCheckInEvent event, Emitter<OrderFromCheckInState> emitter)async{
  //   emitter(OrderFromCheckInLoading());
  //   List<SearchItemResponseData> draft = [];
  //   event.listOrder!.forEach((element) {
  //     SearchItemResponseData item = SearchItemResponseData(
  //         code: element.code,
  //         name: element.name,
  //         name2:element.name2,
  //         dvt: element.dvt,
  //         descript: element.description,
  //         price: element.price,
  //         discountPercent: element.discountPercent,
  //         priceAfter: element.priceAfter,
  //         stockAmount: element.stockAmount,
  //         taxPercent: element.taxPercent,
  //         imageUrl: element.imageUrl,
  //         count: element.count,
  //         isMark:0,
  //         discountMoney: element.discountMoney,
  //         discountProduct: element.discountProduct,
  //         budgetForItem: element.budgetForItem,
  //         budgetForProduct: element.budgetForProduct,
  //         residualValueProduct: element.residualValueProduct,
  //         residualValue: element.residualValue,
  //         unit: element.unit,
  //         unitProduct: element.unitProduct,
  //         dsCKLineItem: element.dsCKLineItem?.split(',')
  //     );
  //     draft.add(item);
  //   });
  //   CreateOrderFromCheckInRequest request = CreateOrderFromCheckInRequest(
  //       requestData: CreateOrderRequestBody(
  //           customerCode: event.code,
  //           saleCode: idUser,
  //           orderDate: DateTime.now().toString(),
  //           currency: event.currencyCode,
  //           stockCode: event.storeCode,
  //           descript: '',
  //           phoneCustomer: event.phoneCustomer,
  //           addressCustomer: event.addressCustomer,
  //           comment: '',
  //           dsCk: [],
  //           listStore: draft,
  //           listTotal: event.totalMoneys
  //       )
  //   );
  //   OrderFromCheckInState state = _handlerCreateOrder(await _networkFactory!.createOrderFromCheckIn(request, _accessToken!));
  //   emitter(state);
  // }

  OrderFromCheckInState _handlerCreateOrder(Object data){
    if (data is String) return OrderFromCheckInFailure('Úi, ${data.toString()}');
    try{
      return CreateOrderFromCheckInSuccess();
    }catch(e){
      return OrderFromCheckInFailure('Úi, ${e.toString()}');
    }
  }

  // void _getListImageStore(GetListImageStore event, Emitter<AlbumState> emitter)async{
  //   emitter(InitialAlbumState());
  //   bool isRefresh = event.isRefresh;
  //   bool isLoadMore = event.isLoadMore;
  //   emitter( (!isRefresh && !isLoadMore)
  //       ? AlbumLoading()
  //       : InitialAlbumState());
  //   if (isRefresh) {
  //     for (int i = 1; i <= _currentPage; i++) {
  //       AlbumState state = await handleCallApi(i,event.idCustomer.toString(),event.idCheckIn.toString(),event.idAlbum.toString());
  //       if (state is! GetListImageStoreSuccess) return;
  //     }
  //     return;
  //   }
  //   if (isLoadMore) {
  //     isScroll = false;
  //     _currentPage++;
  //   }
  //   AlbumState state = await handleCallApi(_currentPage,event.idCustomer.toString(),event.idCheckIn.toString(),event.idAlbum.toString());
  //   emitter(state);
  // }


  // Future<AlbumState> handleCallApi(int pageIndex,String idCustomer, String idCheckIn, String idAlbum) async {
  //
  //   AlbumState state = _handleLoadList(await _networkFactory!.getListImageStore(_accessToken!,idCustomer.trim(),idCheckIn,idAlbum.trim(),pageIndex,_maxPage), pageIndex);
  //   return state;
  // }
  //
  //
  // AlbumState _handleLoadList(Object data, int pageIndex) {
  //   if (data is String) return AlbumFailure('Úi, data');
  //   try {
  //     ListImageStoreResponse response = ListImageStoreResponse.fromJson(data as Map<String,dynamic>);
  //     if(listAlbum.isNotEmpty){
  //       listAlbum.clear();
  //     }
  //     if(listFileAlbumView.isNotEmpty){
  //       listFileAlbumView.clear();
  //     }
  //     listAlbum = response.listAlbum!;
  //     _maxPage = 20;
  //     List<ListImage> list = response.listImage!;
  //     if (!Utils.isEmpty(list) && _listImage.length >= (pageIndex - 1) * _maxPage + list.length) {
  //       _listImage.replaceRange((pageIndex - 1) * maxPage, pageIndex * maxPage, list);
  //     } else {
  //       if (_currentPage == 1) {
  //         _listImage = list;
  //       } else {
  //         _listImage.addAll(list);
  //       }
  //     }
  //     if (Utils.isEmpty(_listImage)) {
  //       return GetListImageStoreEmpty();
  //     } else {
  //       isScroll = true;
  //     }
  //     return GetListImageStoreSuccess();
  //   } catch (e) {
  //     return AlbumFailure('Úi, ${e.toString()}');
  //   }
  // }

}