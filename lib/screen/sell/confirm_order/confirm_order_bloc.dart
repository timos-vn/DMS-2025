// import 'package:flutter/cupertino.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sse/model/entity/product.dart';
// import 'package:sse/utils/const.dart';
// import 'package:sse/utils/utils.dart';
// import 'package:sse/utils/validator.dart';
//
// import '../../../model/network/request/create_order_request.dart';
// import '../../../model/network/request/discount_request.dart';
// import '../../../model/network/request/update_order_request.dart';
// import '../../../model/network/response/cart_response.dart';
// import '../../../model/network/response/search_list_item_response.dart';
// import '../../../model/network/services/network_factory.dart';
// import 'confirm_order_event.dart';
// import 'confirm_order_state.dart';
//
// class ConfirmOrderBloc extends Bloc<ConfirmOrderEvent,ConfirmOrderState> with Validators{
//
//   NetWorkFactory? _networkFactory;
//   BuildContext context;
//   String? _accessToken;
//   String get accessToken => _accessToken!;
//   String? _refreshToken;
//   String get refreshToken => _refreshToken!;
//   SharedPreferences? _prefs;
//   SharedPreferences get prefs => _prefs!;
//
//   String? _errorPhoneNumber;
//   String? _errorName;
//   String? _errorCustomerAddress;
//   bool? _phoneVerification = true;
//
//   String? get errorCustomerAddress => _errorCustomerAddress;
//   String? get errorName => _errorName;
//   bool? get phoneVerification => _phoneVerification;
//   String? get errorPhoneNumber => _errorPhoneNumber;
//   int storeIndex = 0;
//
//   List<String> listCodeDisCount = [];
//
//   List<Product> _listItem = [];
//
//   String? customerName;
//   String? phone;
//   String? address;
//   String? codeCustomer;
//
//   double? totalMNProduct = 0;
//   double? totalMNDiscount = 0;
//   double? totalMNVAT = 0;
//   double? totalMNPayment = 0;
//
//   ConfirmOrderBloc(this.context) : super(ConfirmOrderInitial()){
//     _networkFactory = NetWorkFactory(context);
//     on<GetPrefs>(_getPrefs);
//     on<ValidateNameCustomer>(_validateNameCustomer);
//     on<ValidatePhoneNumber>(_validatePhoneNumber);
//     on<ValidateAddress>(_validateAddress);
//     on<PickStoreName>(_pickStoreName);
//     on<UpdateOderEvent>(_updateOderEvent);
//     on<CreateOderEvent>(_createOderEvent);
//     on<PickInfoCustomer>(_pickInfoCustomer);
//     on<CalculatorTotalMoney>(_calculatorTotalMoney);
//     on<CheckDisCountWhenUpdateEvent>(_checkDisCountWhenUpdateEvent);
//
//   }
//
//
//   void _getPrefs(GetPrefs event, Emitter<ConfirmOrderState> emitter)async{
//     emitter(ConfirmOrderInitial());
//     _prefs = await SharedPreferences.getInstance();
//     _accessToken = _prefs!.getString(Const.ACCESS_TOKEN) ?? "";
//     _refreshToken = _prefs!.getString(Const.REFRESH_TOKEN) ?? "";
//     emitter(GetPrefsSuccess());
//   }
//
//   void _validateNameCustomer(ValidateNameCustomer event, Emitter<ConfirmOrderState> emitter){
//     emitter(ConfirmOrderInitial());
//     _errorName = checkPhoneNumber2(context, event.nameCustomer);
//     emitter(ValidatePhoneNumberError(_errorPhoneNumber!));
//   }
//
//   void _validatePhoneNumber(ValidatePhoneNumber event, Emitter<ConfirmOrderState> emitter){
//     emitter(ConfirmOrderInitial());
//     _errorPhoneNumber = checkPhoneNumber2(context, event.phoneNumber);
//     emitter(ValidatePhoneNumberError(_errorPhoneNumber!));
//   }
//
//   void _validateAddress(ValidateAddress event, Emitter<ConfirmOrderState> emitter){
//     emitter(ConfirmOrderInitial());
//     if (Utils.isEmpty(event.address))
//       _errorCustomerAddress = 'Vui lòng nhập địa chỉ Đường, phố, xã, phường';
//     else
//       _errorCustomerAddress = null;
//     emitter(ValidateAddressError(_errorCustomerAddress!));
//   }
//
//   void _pickStoreName(PickStoreName event, Emitter<ConfirmOrderState> emitter){
//     emitter(ConfirmOrderInitial());
//     storeIndex = event.storeIndex;
//     emitter(PickStoreNameSuccess());
//   }
//
//   void _updateOderEvent(UpdateOderEvent event, Emitter<ConfirmOrderState> emitter)async{
//     emitter(CreateOrderLoading());
//     UpdateOrderRequest request = UpdateOrderRequest(
//         requestData: UpdateOrderRequestBody(
//             sstRec: event.sttRec,
//             customerCode: event.code,
//             saleCode: _prefs?.getString(Const.CODE),
//             orderDate: DateTime.now().toString(),
//             currency: event.currencyCode,
//             stockCode: event.storeCode,
//             descript: '',
//             dsCk: listCodeDisCount,
//             listStore: _listItem,
//             listTotalUpdate: event.totalMoney
//         )
//     );
//     ConfirmOrderState state = _handlerCreateOrder(await _networkFactory!.updateOrder(request, _accessToken!));
//     emitter(state);
//   }
//
//   void _createOderEvent(CreateOderEvent event, Emitter<ConfirmOrderState> emitter)async{
//     emitter(CreateOrderLoading());
//     CreateOrderRequest request = CreateOrderRequest(
//         requestData: CreateOrderRequestBody(
//             customerCode: event.code,
//             saleCode: _prefs?.getString(Const.CODE),
//             orderDate: DateTime.now().toString(),
//             currency: event.currencyCode,
//             stockCode: event.storeCode,
//             descript: '',
//             dsCk: listCodeDisCount,
//             listStore: !Utils.isEmpty(_listItem) ? _listItem : event.listOrder,
//             listTotal: event.totalMoney
//         )
//     );
//     ConfirmOrderState state = _handlerCreateOrder(await _networkFactory!.createOrder(request, _accessToken!));
//     emitter(state);
//   }
//
//   void _pickInfoCustomer(PickInfoCustomer event, Emitter<ConfirmOrderState> emitter){
//     emitter(ConfirmOrderInitial());
//     customerName = event.customerName;
//     phone = event.phone;
//     address = event.address;
//     codeCustomer = event.codeCustomer;
//     emitter(PickInfoCustomerSuccess());
//   }
//
//   void _calculatorTotalMoney(CalculatorTotalMoney event, Emitter<ConfirmOrderState> emitter)async{
//     emitter(CreateOrderLoading());
//     DiscountRequest requestBody = DiscountRequest(
//         maKh: event.maKH,
//         maKho: event.maKho,
//         lineItem: event.listItem
//     );
//     ConfirmOrderState state = _handleCalculator(await _networkFactory!.calculatorPayment(requestBody,_accessToken!),event.listItem);
//     emitter(state);
//   }
//
//   void _checkDisCountWhenUpdateEvent(CheckDisCountWhenUpdateEvent event, Emitter<ConfirmOrderState> emitter)async{
//     emitter(CreateOrderLoading());
//     DiscountRequest requestBody = DiscountRequest(
//         sttRec: event.sttRec,
//         maKh: event.codeCustomer,
//         maKho: event.codeStore,
//         lineItem: event.listItem
//     );
//     ConfirmOrderState state = _handleCalculator(await _networkFactory!.getDiscountWhenUpdate(requestBody,_accessToken!),event.listItem);
//     emitter(state);
//   }
//
//
//   ConfirmOrderState _handleCalculator(Object data,List<Product>? listItem){
//     if (data is String) return ConfirmOrderFailure('Úi, Có lỗi rồi Đại Vương ơi !!!');
//     try{
//       if (_listItem.isNotEmpty)
//         _listItem.clear();
//       CartResponse response = CartResponse.fromJson(data as Map<String,dynamic>);
//       List<LineItem>? _lineItemRes = response.data?.lineItem;
//       if(_lineItemRes!.isNotEmpty){
//         _lineItemRes.forEach((element) {
//           if(listItem!.isNotEmpty){
//             final valueUpdate = listItem.firstWhere((item) => item.code == element.maVt);
//             valueUpdate.discountPercent = element.tlCk;
//             _listItem.add( valueUpdate);
//           }
//         });
//       }
//
//       totalMNProduct = response.data?.order?.tTien;
//       totalMNDiscount = response.data?.order?.ck;
//       totalMNPayment = response.data?.order?.tTt;
//
//       return CalculatorMoneySuccess();
//     }catch(e){
//       return ConfirmOrderFailure(e.toString());
//     }
//   }
//
//    ConfirmOrderState _handlerCreateOrder(Object data){
//     if (data is String) return CreateOrderError('Úi, Có lỗi rồi Đại Vương ơi !!!');
//     try{
//       return CreateOrderSuccess();
//     }catch(e){
//       print(e);
//       return CreateOrderError('Úi, Có lỗi rồi Đại Vương ơi !!!');
//     }
//    }
// }