// // ignore_for_file: unnecessary_null_comparison
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
// import 'package:sse/model/database/data_local.dart';
// import 'package:sse/model/entity/product.dart';
// import 'package:sse/themes/colors.dart';
// import 'package:sse/utils/const.dart';
// import 'package:sse/utils/utils.dart';
//
// import '../../../model/network/request/create_order_request.dart';
// import '../../../model/network/request/update_order_request.dart';
// import '../../../model/network/response/entity_stock_response.dart';
// import '../../../model/network/response/manager_customer_response.dart';
// import '../../../model/network/response/search_list_item_response.dart';
// import '../../search_customer/search_customer_screen.dart';
// import '../../widget/pending_action.dart';
// import '../../widget/text_field_widget.dart';
// import 'confirm_order_bloc.dart';
// import 'confirm_order_event.dart';
// import 'confirm_order_state.dart';
//
// class ConfirmOrderScreen extends StatefulWidget {
//   final String? sstRec;
//   final String? currencyCode;
//   final double? totalMNProduct;
//   final double? totalMNDiscount;
//   final double? totalMNPayment;
//   final List<String>? listCodeDisCount;
//   final bool? viewUpdateOrder;
//   final String? phoneCustomer;
//   final String? addressCustomer;
//   final String? nameCustomer;
//   final String? nameStore;
//   final String? codeStore;
//   final String? codeCustomer;
//   final List<Product>? listProductOrderAndUpdate;
//
//   const ConfirmOrderScreen({Key? key,this.sstRec, this.currencyCode,this.totalMNProduct,this.totalMNDiscount,this.totalMNPayment,this.listCodeDisCount,this.viewUpdateOrder,
//       this.nameCustomer,this.phoneCustomer,this.addressCustomer,this.nameStore,this.codeStore,this.codeCustomer,this.listProductOrderAndUpdate
//   }) : super(key: key);
//   @override
//   _ConfirmOrderScreenState createState() => _ConfirmOrderScreenState();
// }
//
// class _ConfirmOrderScreenState extends State<ConfirmOrderScreen> {
//
//   TextEditingController _customerNameController = new TextEditingController();
//   bool validateNameCustomer = false;
//   TextEditingController _phoneNumberController = new TextEditingController();
//
//   TextEditingController _employeeController = new TextEditingController();
//   TextEditingController _customerDetailAddressController = new TextEditingController();
//
//
//   FocusNode _phoneNumberFocus = FocusNode(),
//       _customerNameFocus = FocusNode(),
//       _employee = FocusNode(),
//       _customerDetailAddressFocus = FocusNode();
//
//   String? codeCustomer;
//   late ConfirmOrderBloc _bloc;
//   String? storeCode;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _bloc = ConfirmOrderBloc(context);
//     _bloc.totalMNProduct = widget.totalMNProduct;
//     _bloc.totalMNDiscount = widget.totalMNDiscount;
//     _bloc.totalMNPayment = widget.totalMNPayment;
//     _bloc.listCodeDisCount = widget.listCodeDisCount!;
//     _bloc.add(GetPrefs());
//
//     if(widget.viewUpdateOrder == true){
//       codeCustomer = widget.codeCustomer;
//       storeCode = widget.codeStore;
//       if(DataLocal.stockList.isNotEmpty){
//         final valueItem = DataLocal.stockList.firstWhere((item) => item.stockCode.toString().trim() ==  widget.codeStore,);
//         if(valueItem != null){
//           _bloc.storeIndex = DataLocal.stockList.indexOf(valueItem);
//         }
//       }
//       _customerNameController.text = widget.nameCustomer!;
//       _phoneNumberController.text = widget.phoneCustomer!;
//       _customerDetailAddressController.text = widget.addressCustomer!;
//     }else{
//       if(DataLocal.stockList.isNotEmpty){
//         storeCode = DataLocal.stockList[_bloc.storeIndex].stockCode;
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return buildPage(context);
//   }
//
//   Widget buildPage(BuildContext context){
//     return Scaffold(
//       body: BlocListener<ConfirmOrderBloc,ConfirmOrderState>(
//           bloc: _bloc,
//           listener: (context,state){
//             if(state is CreateOrderSuccess){
//               if(widget.viewUpdateOrder == true){
//                 Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeahh, Cập nhật đơn thành công');
//                 Navigator.of(context).pop(Const.REFRESH);
//               }else{
//                 //remove db
//                 // DataLocal.listStore.clear();
//                 Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeahh, Tạo đơn thành công');
//                 Navigator.of(context).pop(Const.REFRESH);
//               }
//             }
//             else if(state is PickInfoCustomerSuccess){
//               _customerNameController.text = _bloc.customerName!;
//               _phoneNumberController.text = _bloc.phone!;
//               _customerDetailAddressController.text = _bloc.address.toString();
//               codeCustomer = _bloc.codeCustomer;
//               if(widget.viewUpdateOrder == true){
//                 _bloc.add(CheckDisCountWhenUpdateEvent(widget.listProductOrderAndUpdate!,widget.sstRec.toString(),codeCustomer: widget.codeCustomer,codeStore: widget.codeStore));
//               }else{
//                 _bloc.add(CalculatorTotalMoney(listItem: widget.listProductOrderAndUpdate,maKH: codeCustomer,maKho: storeCode));
//               }
//             }
//             else if(state is PickStoreNameSuccess){
//               if(widget.viewUpdateOrder == true){
//                 _bloc.add(CheckDisCountWhenUpdateEvent(widget.listProductOrderAndUpdate!,widget.sstRec.toString(),codeCustomer: widget.codeCustomer,codeStore: widget.codeStore));
//               }else{
//                 _bloc.add(CalculatorTotalMoney(listItem: widget.listProductOrderAndUpdate,maKH: codeCustomer,maKho: storeCode));
//               }
//             }
//           },
//           child: BlocBuilder(
//               bloc: _bloc,
//               builder: (BuildContext context,ConfirmOrderState state){
//                 return Stack(
//                   children: [
//                     buildBody(context, state),
//                     Visibility(
//                       visible: state is CreateOrderLoading,
//                       child: PendingAction(),
//                     ),
//                   ],
//                 );
//               },
//           )
//       ) ,
//     );
//   }
//
//   buildBody(BuildContext context,ConfirmOrderState state){
//     return Container(
//       height: double.infinity,
//       width: double.infinity,
//       child: Column(
//         children: [
//           buildAppBar(),
//           Expanded(
//             child: Column(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
//                     child: ListView(
//                       shrinkWrap: true,
//                       children: [
//                         buildInputCustomerName(context),
//                         buildInputPhoneNumber(context),
//                         buildInputCustomerSpecifiedAddress(context),
//                         Padding(
//                           padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 18.0,bottom: 5),
//                           child: Text('Kho',
//                             style: TextStyle(color: grey, fontSize: 11.0),
//                           ),
//                         ),
//                         genderWidget(),
//                         Padding(
//                           padding:
//                           const EdgeInsets.symmetric(horizontal: 20.0),
//                           child: Divider(height: 1,thickness: 1,color: grey,),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.only(left: 16,right: 16),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Tổng tiền',style: TextStyle(color: Colors.black,fontSize: 12),),
//                           Text('${NumberFormat(Const.amountFormat).format(_bloc.totalMNProduct??0)} ₫',style: TextStyle(color: Colors.black,fontSize: 12),),
//                         ],
//                       ),
//                       Divider(),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Chiết khấu',style: TextStyle(color: Colors.black,fontSize: 12),),
//                           Text('${NumberFormat(Const.amountFormat).format(_bloc.totalMNDiscount??0)} ₫',style: TextStyle(color: Colors.black,fontSize: 12),),
//                         ],
//                       ),
//                       Divider(),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Tổng thanh toán',style: TextStyle(color: Colors.black,fontSize: 12),),
//                           Text('${NumberFormat(Const.amountFormat).format(_bloc.totalMNPayment??0)} ₫',style: TextStyle(color: Colors.black,fontSize: 12),),
//                         ],
//                       ),
//                       Visibility(
//                         visible: widget.listProductOrderAndUpdate!.length>0 || widget.listProductOrderAndUpdate!.length > 0,
//                         child: Padding(
//                           padding: EdgeInsets.only(top: 20,bottom: 20),
//                           child: InkWell(
//                             onTap: (){
//                               if (codeCustomer != null && !Utils.isEmpty(DataLocal.stockList)){
//                                 if(widget.viewUpdateOrder == true){
//                                   ItemTotalMoneyUpdateRequestData val = new ItemTotalMoneyUpdateRequestData();
//                                   val.preAmount = _bloc.totalMNProduct.toString();
//                                   val.discount = _bloc.totalMNDiscount.toString();
//                                   val.totalMNProduct = _bloc.totalMNProduct.toString();
//                                   val.totalMNDiscount = _bloc.totalMNDiscount.toString();
//                                   val.totalMNPayment = _bloc.totalMNPayment.toString();
//                                   _bloc.add(UpdateOderEvent(
//                                       sttRec: widget.sstRec,
//                                       code: codeCustomer,
//                                       storeCode: storeCode != null ? storeCode :  DataLocal.stockList[0].stockCode,
//                                       currencyCode: widget.currencyCode,
//                                       listOrder: widget.listProductOrderAndUpdate,
//                                       totalMoney: val,
//                                       viewUpdateOrder: widget.viewUpdateOrder
//                                   ));
//                                 }
//                                 else {
//                                   ItemTotalMoneyRequestData val = new ItemTotalMoneyRequestData();
//                                   val.preAmount = _bloc.totalMNProduct.toString();
//                                   val.discount = _bloc.totalMNDiscount.toString();
//                                   val.totalMNProduct = _bloc.totalMNProduct.toString();
//                                   val.totalMNDiscount = _bloc.totalMNDiscount.toString();
//                                   val.totalMNPayment = _bloc.totalMNPayment.toString();
//                                   _bloc.add(CreateOderEvent(
//                                     code: codeCustomer,
//                                     storeCode: storeCode != null ? storeCode :  DataLocal.stockList[0].stockCode,
//                                     currencyCode: widget.currencyCode,
//                                     listOrder: widget.listProductOrderAndUpdate,//_mainBloc.listStore,
//                                     totalMoney: val,
//                                   ));
//                                 }
//                               }
//                               else{
//                                 Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Hãy nhập đủ thông tin');
//                               }
//                             },
//                             child: Container(
//                               padding: EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
//                               height: 45,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12),
//                                   color: Colors.orange
//                               ),
//                               child:Center(child: Text(widget.viewUpdateOrder == true ? 'Cập nhật đơn hàng' :'Tạo đơn',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 14),)),
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 50,)
//         ],
//       ),
//     );
//   }
//
//   buildAppBar(){
//     return Container(
//       height: 83,
//       width: double.infinity,
//       decoration: BoxDecoration(
//           boxShadow: <BoxShadow>[
//             BoxShadow(
//                 color: Colors.grey.shade200,
//                 offset: Offset(2, 4),
//                 blurRadius: 5,
//                 spreadRadius: 2)
//           ],
//           gradient: LinearGradient(
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//               colors: [subColor,Color.fromARGB(255, 150, 185, 229)])),
//       padding: const EdgeInsets.fromLTRB(5, 35, 12,0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           InkWell(
//             onTap: ()=>Navigator.pop(context,'ToBackViewCart'),
//             child: Container(
//               width: 40,
//               height: 50,
//               child: Icon(
//                 Icons.arrow_back_rounded,
//                 size: 25,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Center(
//               child: Text(
//                 "Xác nhận đơn hàng",
//                 style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
//                 maxLines: 1,overflow: TextOverflow.fade,
//               ),
//             ),
//           ),
//           const SizedBox(width: 10,),
//           Container(
//             width: 40,
//             height: 50,
//             child: Icon(
//               Icons.event,
//               size: 25,
//               color: Colors.transparent,
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   Padding buildInputCustomerName(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0.0),
//       child: Stack(
//         children: [
//           TextFieldWidget(
//             isEnable: false,
//             controller: _customerNameController,
//             textInputAction: TextInputAction.next,
//             keyboardType: TextInputType.text,
//             labelText: 'Tên khách hàng',
//             focusNode: _customerNameFocus,
//             onChanged: (text) => _bloc.add(ValidateNameCustomer(text!)),
//             onSubmitted: (text) => Utils.navigateNextFocusChange(context,_customerNameFocus , _phoneNumberFocus),
//             errorText:_bloc.errorName, readOnly: false,
//           ),
//           Positioned(
//             top: 0,
//               right: 5,
//               bottom: 0,
//               child: InkWell(
//                   onTap:()=>pushNewScreen(context, screen: SearchCustomerScreen(selected: true,),withNavBar: false).then((value){
//                     if(!Utils.isEmpty(value)){
//                       ManagerCustomerResponseData infoCustomer = value;
//                       _bloc.add(PickInfoCustomer(customerName: infoCustomer.customerName,phone: infoCustomer.phone,address: infoCustomer.address,codeCustomer: infoCustomer.customerCode));
//                     }
//                   }),
//                   child: Icon(Icons.search)),
//           )
//         ],
//       ),
//     );
//   }
//
//   Padding buildInputPhoneNumber(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
//       child: TextFieldWidget(
//         isEnable: false,
//         controller: _phoneNumberController,
//         textInputAction: TextInputAction.next,
//         keyboardType: TextInputType.phone,
//         labelText: 'Số điện thoại',
//         errorText: _bloc.errorPhoneNumber,
//         onChanged: (text) => _bloc.add(ValidatePhoneNumber(text!)),
//         focusNode: _phoneNumberFocus,
//         readOnly: false,
//         onSubmitted: (text) {
//           Utils.navigateNextFocusChange(context, _phoneNumberFocus, _customerDetailAddressFocus);
//         },
//       ),
//     );
//   }
//
//   Padding buildInputCustomerSpecifiedAddress(BuildContext context) {
//     return Padding(
//         padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
//         child: TextFieldWidget(
//           isEnable: false,
//           controller: _customerDetailAddressController,
//           textInputAction: TextInputAction.done,
//           keyboardType: TextInputType.text,
//           labelText: 'Địa chỉ',
//           readOnly: false,
//           focusNode: _customerDetailAddressFocus,)
//       // onSubmitted: (text) => Utils.navigateNextFocusChange(
//       //     context, _customerDetailAddressFocus, _customerAddressFocus)),
//     );
//   }
//
//   Widget genderWidget() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 7.0),
//       child: Utils.isEmpty(DataLocal.stockList)
//           ? Container(child: Text('Không có dữ liệu'),)
//           : DropdownButtonHideUnderline(
//         child: DropdownButton<StockResponseData>(
//             isDense: true,
//             isExpanded: true,
//             style: TextStyle(
//               color: black,
//               fontSize: 12.0,
//             ),
//             value: DataLocal.stockList[_bloc.storeIndex],
//             items: DataLocal.stockList.map((value) => DropdownMenuItem<StockResponseData>(
//               child: Text(value.stockName.toString(), style: TextStyle(fontSize: 14.0, color: black),),
//               value: value,
//             )).toList(),
//             onChanged: (value) {
//               StockResponseData stocks = value!;
//               storeCode = stocks.stockCode;
//               _bloc.add(PickStoreName(DataLocal.stockList.indexOf(value)));
//             }),
//       ),
//     );
//   }
//
//   Padding buildInputEmployee(BuildContext context) {
//     return Padding(
//         padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0.0),
//         child: TextFieldWidget(
//           isEnable: false,
//           controller: _employeeController,
//           textInputAction: TextInputAction.done,
//           keyboardType: TextInputType.text,
//           labelText: 'Nhân viên bán hàng',
//           readOnly: false,
//           focusNode: _employee,)
//       // onSubmitted: (text) => Utils.navigateNextFocusChange(
//       //     context, _customerDetailAddressFocus, _customerAddressFocus)),
//     );
//   }
//
//
//
// }
//
