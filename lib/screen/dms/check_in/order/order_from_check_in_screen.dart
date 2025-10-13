import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/custom_widget.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../../model/database/data_local.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../../utils/utils.dart';
import '../../../sell/cart/confirm_order_screen.dart';
import '../../../sell/component/search_product.dart';
import 'order_from_check_in_bloc.dart';
import 'order_from_check_in_event.dart';
import 'order_from_check_in_state.dart';


class OrderFromCheckInScreen extends StatefulWidget {
  final bool isCheckInSuccess;
  final int idCheckIn;
  final String idCustomer;
  final bool view;
  final String nameCustomer;
  final String phoneCustomer;
  final String addressCustomer;
  final String nameStore;


  const OrderFromCheckInScreen(
      {Key? key,
        required this.isCheckInSuccess,
        required this.idCheckIn,
        required this.idCustomer,
        required this.view,
        required this.nameCustomer,
        required this.phoneCustomer,
        required this.addressCustomer,
        required this.nameStore
      }) : super(key: key);

  @override
  _OrderFromCheckInScreenState createState() => _OrderFromCheckInScreenState();
}

class _OrderFromCheckInScreenState extends State<OrderFromCheckInScreen> {

  late OrderFromCheckInBloc _bloc;
  String currencyCode = 'VND';
  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  final bool _hasReachedMax = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
    _bloc = OrderFromCheckInBloc(context);
    _bloc.add(GetPrefsOrderFromCheckIn());

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        //_bloc.add(GetListInventory(isLoadMore:true,idCustomer: widget.idCustomer,idCheckIn: widget.idCheckIn.toString()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<OrderFromCheckInBloc,OrderFromCheckInState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            if(widget.isCheckInSuccess == true && Const.orderCheckIn == true){
              //_bloc.add(GetListInventory(idCustomer: widget.idCustomer,idCheckIn: widget.idCheckIn.toString()));
            }
          }else if(state is CreateOrderFromCheckInSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Tạo đơn hàng thành công');
            DataLocal.listOrderProductIsChange = false;
          }
          else if(state is DeleteProductInCartSuccess){
            _bloc.add(AddListItemOrderFromCheckIn());
          }
          else if(state is AddListItemProductSuccess){
            Const.currencyCode = !Utils.isEmpty(currencyCode) ? currencyCode : Const.currencyList[0].currencyCode.toString();
            PersistentNavBarNavigator.pushNewScreen(context, screen: ConfirmScreen(
              orderFromCheckIn: true,
              viewUpdateOrder: false,
              viewDetail: false,
              listIdGroupProduct: Const.listGroupProductCode,
              itemGroupCode: Const.itemGroupCode,
              listOrder: DataLocal.listOrderProductLocal,
              nameCustomer: (widget.nameCustomer.isEmpty) ? widget.nameStore : widget.nameCustomer  ,
              phoneCustomer: widget.phoneCustomer,
              addressCustomer: widget.addressCustomer,
              codeCustomer: widget.idCustomer,
              title: 'Đặt hàng',
              currencyCode: !Utils.isEmpty(currencyCode) ? currencyCode : Const.currencyList[0].currencyCode.toString(), loadDataLocal: false,
            ),withNavBar: false).then((value){
              _bloc.add(DeleteProductInCartEvent(true));
            });
          }
        },
        child: BlocBuilder<OrderFromCheckInBloc,OrderFromCheckInState>(
          bloc: _bloc,
          builder: (BuildContext context, OrderFromCheckInState state){
            return Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is OrderFromCheckInLoading,
                  child: const PendingAction(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,OrderFromCheckInState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Const.orderCheckIn == true
          ?
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding:const EdgeInsets.symmetric(horizontal: 5),
                  child: Text('Danh sách sản phẩm lên đơn (${(widget.isCheckInSuccess == false && widget.view == false) ? DataLocal.listOrderProductLocal.length : '' // _bloc.listInventoryHistory.length
                  })',style:const TextStyle(color: Colors.blueGrey,fontSize: 10)),
                ),
                const Expanded(child: Divider()),
              ],
            ),
          ),
          Visibility(
            visible: (widget.isCheckInSuccess == false && widget.view == false) &&  DataLocal.listOrderProductLocal.isNotEmpty,
            child: Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.only(top: 6),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index){
                    var itemCheck = Const.kColorForAlphaB.firstWhere((item) => item.keyText == DataLocal.listOrderProductLocal[index].name?.substring(0,1).toUpperCase());
                    if(itemCheck != null){
                      DataLocal.listOrderProductLocal[index].kColorFormatAlphaB = itemCheck.color.value;
                    }
                    return GestureDetector(
                        onTap: (){
                          if(widget.isCheckInSuccess == false && widget.view == false){
                            showBottomSheet(index,DataLocal.listOrderProductLocal[index].name!);
                          }
                        },
                        child: Card(
                          semanticContainer: true,
                          margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none, children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: Color(DataLocal.listOrderProductLocal[index].kColorFormatAlphaB!),
                                        borderRadius: const BorderRadius.all(Radius.circular(6),)
                                    ),
                                    child: Center(child: Text('${DataLocal.listOrderProductLocal[index].name?.substring(0,1).toUpperCase()}',style: const TextStyle(color: Colors.white),),),
                                  ),
                                ],
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 10,right: 3,top: 5,bottom: 5),
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${DataLocal.listOrderProductLocal[index].name}',
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 10,),
                                            Column(
                                              children: [
                                                // Text(
                                                //   // ignore: unrelated_type_equality_checks
                                                //   double.parse((Const.currencyCode == "VND"
                                                //       ?
                                                //   NumberFormat(Const.amountFormat).format(DataLocal.listOrderProductLocal[index].price??0)
                                                //       :
                                                //   NumberFormat(Const.amountNtFormat).format(DataLocal.listOrderProductLocal[index].price??0)))
                                                //       == 0 ? 'Giá đang cập nhật' : (Const.currencyCode == "VND"
                                                //       ?
                                                //   NumberFormat(Const.amountFormat).format(DataLocal.listOrderProductLocal[index].price??0)
                                                //       :
                                                //   NumberFormat(Const.amountNtFormat).format(DataLocal.listOrderProductLocal[index].price??0))
                                                //   ,
                                                //   textAlign: TextAlign.left,
                                                //   style: TextStyle(color: grey, fontSize: 10, decoration: double.parse((Const.currencyCode == "VND"
                                                //       ?
                                                //   NumberFormat(Const.amountFormat).format(DataLocal.listOrderProductLocal[index].price??0)
                                                //       :
                                                //   NumberFormat(Const.amountNtFormat).format(DataLocal.listOrderProductLocal[index].price??0))) == 0 ? TextDecoration.none : TextDecoration.lineThrough),
                                                // ),
                                                // Text(
                                                //   '${Utils.formatMoneyStringToDouble(DataLocal.listOrderProductLocal[index].price??0)} ₫' ,
                                                //   textAlign: TextAlign.left,
                                                //   style: const TextStyle(color: Color(
                                                //       0xff067902), fontSize: 13,fontWeight: FontWeight.w700),
                                                // ),
                                                // const SizedBox(height: 3,),
                                                Visibility(
                                                  visible: DataLocal.listOrderProductLocal[index].price! > 0,
                                                  child: Text(
                                                    Const.currencyCode == "VND"
                                                        ?
                                                    NumberFormat(Const.amountFormat).format(DataLocal.listOrderProductLocal[index].priceAfter??0)
                                                        :
                                                    NumberFormat(Const.amountNtFormat).format(DataLocal.listOrderProductLocal[index].priceAfter??0),
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(color: Color(
                                                        0xff067902), fontSize: 13,fontWeight: FontWeight.w700),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Row(
                                                  children: [
                                                    const Text(
                                                      'Mã SP:',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10.5,color:  Color(
                                                          0xff358032)),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(width: 3,),
                                                    Text(
                                                      '${DataLocal.listOrderProductLocal[index].code}',
                                                      textAlign: TextAlign.left,
                                                      style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 10.5,color:  Color(
                                                          0xff358032)),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 8,),
                                                Visibility(
                                                  visible: DataLocal.listOrderProductLocal[index].discountPercent! > 0,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(4),
                                                        border: Border.all(color: Colors.red,width: 0.7)
                                                    ),
                                                    padding:const EdgeInsets.symmetric(horizontal: 7,vertical: 1),
                                                    child: Row(
                                                      children: [
                                                        const Text(
                                                          'SALE OFF',
                                                          textAlign: TextAlign.left,
                                                          style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10.5,color:  Color(
                                                              0xffe80000)),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(width: 3,),
                                                        Text(
                                                          '${Utils.formatNumber(DataLocal.listOrderProductLocal[index].discountPercent!)}%',
                                                          textAlign: TextAlign.left,
                                                          style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 10.5,color:  Color(
                                                              0xffe80000)),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'KH Đặt:',
                                                  style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 11),
                                                  textAlign: TextAlign.left,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text("${DataLocal.listOrderProductLocal[index].count?.toInt()??0}",
                                                  style:const TextStyle(color: blue, fontSize: 12),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                  },
                  itemCount: DataLocal.listOrderProductLocal.length
              ),
            ),
          ),
          // Visibility(
          //   visible: (widget.isToday != true && widget.view != false) && _bloc.listInventoryHistory.isNotEmpty,
          //   child: ListView.builder(
          //       padding: const EdgeInsets.only(top: 6),
          //       shrinkWrap: true,
          //       itemBuilder: (BuildContext context, int index){
          //         var itemCheck = Const.kColorForAlphaB.firstWhere((item) => item.keyText == _bloc.listInventoryHistory[index].tenVt?.substring(0,1).toUpperCase());
          //         if(itemCheck != null){
          //           _bloc.listInventoryHistory[index].kColorFormatAlphaB = itemCheck.color;
          //         }
          //         return
          //           Card(
          //             semanticContainer: true,
          //             margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
          //             child: Padding(
          //               padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
          //               child: Row(
          //                 mainAxisSize: MainAxisSize.max,
          //                 children: [
          //                   Stack(
          //                     clipBehavior: Clip.none, children: [
          //                     Container(
          //                       width: 50,
          //                       height: 50,
          //                       decoration: BoxDecoration(
          //                           color: Color(_bloc.listInventoryHistory[index].kColorFormatAlphaB!.value),
          //                           borderRadius: const BorderRadius.all(Radius.circular(6),)
          //                       ),
          //                       child: Center(child: Text('${_bloc.listInventoryHistory[index].tenVt?.substring(0,1).toUpperCase()}',style: const TextStyle(color: Colors.white),),),
          //                     ),
          //                   ],
          //                   ),
          //                   Expanded(
          //                     child: Container(
          //                       padding: const EdgeInsets.only(left: 10,right: 3,top: 5,bottom: 5),
          //                       width: double.infinity,
          //                       child: Column(
          //                         crossAxisAlignment: CrossAxisAlignment.start,
          //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                         children: [
          //                           Row(
          //                             children: [
          //                               Expanded(
          //                                 child: Text(
          //                                   '${_bloc.listInventoryHistory[index].tenVt}',
          //                                   textAlign: TextAlign.left,
          //                                   style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
          //                                   maxLines: 2,
          //                                   overflow: TextOverflow.ellipsis,
          //                                 ),
          //                               ),
          //                             ],
          //                           ),
          //                           const SizedBox(height: 10,),
          //                           Row(
          //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                             children: [
          //                               Row(
          //                                 children: [
          //                                   Text(
          //                                     'Hạn sử dụng:',
          //                                     style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 11),
          //                                     textAlign: TextAlign.left,
          //                                   ),
          //                                   const SizedBox(
          //                                     width: 5,
          //                                   ),
          //                                   const Text("Đang cập nhật",
          //                                     style: TextStyle(color: blue, fontSize: 12),
          //                                     textAlign: TextAlign.left,
          //                                   ),
          //                                 ],
          //                               ),
          //                               Row(
          //                                 children: [
          //                                   Text(
          //                                     'SL Tồn:',
          //                                     style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 11),
          //                                     textAlign: TextAlign.left,
          //                                   ),
          //                                   const SizedBox(
          //                                     width: 5,
          //                                   ),
          //                                   Text("${_bloc.listInventoryHistory[index].slTon?.toInt()??0} ${_bloc.listInventoryHistory[index].dvt}",
          //                                     style: const TextStyle(color: Colors.red, fontSize: 12),
          //                                     textAlign: TextAlign.left,
          //                                   ),
          //                                 ],
          //                               ),
          //                             ],
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           );
          //       },
          //       itemCount: _bloc.listInventoryHistory.length
          //   ),
          // ),
          Visibility(
            visible: DataLocal.listOrderProductLocal.isEmpty,// && _bloc.listInventoryHistory.isEmpty,
            child: const Expanded(
              child: Center(
                child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
              ),
            ),
          ),
          const SizedBox(height: 15,),
          buildMenu(),
          const SizedBox(height: 7,),
        ],
      )
          :
      lockModule(),
    );
  }

  buildMenu(){
    return Container(
      height: 50,width: double.infinity,
      padding:const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: (){
                PersistentNavBarNavigator.pushNewScreen(context, screen: SearchProductScreen(
                    idCustomer: widget.idCustomer, /// Chỉ có thêm tồn kho ở check-in mới thêm idCustomer
                    currency: Const.currencyCode ,
                    viewUpdateOrder: false,
                    listIdGroupProduct: Const.listGroupProductCode,
                    itemGroupCode: Const.itemGroupCode,
                    inventoryControl: false,
                    addProductFromCheckIn: true,
                    addProductFromSaleOut: false,
                    giftProductRe: false,
                    lockInputToCart: false,checkStockEmployee: Const.checkStockEmployee,
                    listOrder: const [], backValues: false, isCheckStock: false,),withNavBar: false).then((value){
                  setState(() {});
                });
              },
              child: Container(
                padding:const EdgeInsets.symmetric(horizontal: 8,vertical: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.red
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.addchart_outlined,color: Colors.white,size: 18,),
                    SizedBox(width: 5,),
                    Text('Thêm SP',style: TextStyle(color: Colors.white,fontSize: 13),),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8,),
          // Expanded(
          //   child: GestureDetector(
          //     onTap: (){
          //       Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Tính năng đang phát triển');
          //     },
          //     child: Container(
          //       padding:const EdgeInsets.symmetric(horizontal: 8,vertical: 12),
          //       decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(8),
          //           color: subColor
          //       ),
          //       child:Row(
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: const [
          //           Icon(Icons.qr_code_rounded,color: Colors.white,size: 16,),
          //           SizedBox(width: 5,),
          //           Text('Quét mã',style: TextStyle(color: Colors.white,fontSize: 12),),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // const SizedBox(width: 8,),
          Expanded(
            child: GestureDetector(
              onTap: (){
                if(DataLocal.listOrderProductLocal.isNotEmpty){
                  _bloc.add(DeleteProductInCartEvent(false));
                }else{
                  Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Vui lòng thêm sp vào đơn hàng');
                }
              },
              child: Container(
                padding:const EdgeInsets.symmetric(horizontal: 8,vertical: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: subColor
                ),
                child:const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart,color: Colors.white,size: 18,),
                    SizedBox(width: 5,),
                    Text('Đặt hàng',style: TextStyle(color: Colors.white,fontSize: 13),),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showBottomSheet(int index, String nameProduct){
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
        ),
        backgroundColor: Colors.white,
        builder: (builder){
          return Container(
            height: MediaQuery.of(context).copyWith().size.height * 0.32,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    topLeft: Radius.circular(25)
                )
            ),
            margin: MediaQuery.of(context).viewInsets,
            child: StatefulBuilder(
              builder: (BuildContext context,StateSetter myState){
                return Padding(
                  padding: const EdgeInsets.only(top: 10,bottom: 0),
                  child: Container(
                    decoration:const BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(25),
                            topLeft: Radius.circular(25)
                        )
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0,left: 8,right: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                  onTap: ()=> Navigator.pop(context),
                                  child: const Icon(Icons.close,color: Colors.white,)),
                              const Text('Thêm tuỳ chọn',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                              InkWell(
                                  onTap: ()=> Navigator.pop(context),
                                  child: Icon(Icons.clear,color: mainColor,)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5,),
                        const Divider(color: Colors.blueGrey,),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  // color: Colors.blueGrey,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10,top: 12),
                                      child: InkWell(
                                        onTap:()=>Navigator.pop(context,'1'),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                            side: BorderSide(color: Colors.blueGrey.withOpacity(0.1), width: 0.5),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.only(top: 12,bottom: 10,left: 10,right: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children:[
                                                Text('Xoá sản phẩm',style: TextStyle(color: Colors.black),),
                                                Icon(Icons.delete_forever,color: subColor,)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10,top: 10),
                                      child: InkWell(
                                        onTap:()=>Navigator.pop(context,'2'),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                            side: BorderSide(color: Colors.blueGrey.withOpacity(0.1), width: 0.5),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.only(top: 12,bottom: 10,left: 10,right: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children:[
                                                Text('Cập nhật lại số lượng sp',style: TextStyle(color: Colors.black),),
                                                Icon(Icons.stacked_bar_chart,color: subColor,)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
    ).then((value)async{
      if(value != null){
        switch (value){
          case '1':
            showDialog(
                context: context,
                builder: (context) {
                  return WillPopScope(
                    onWillPop: () async => false,
                    child: const CustomQuestionComponent(
                      showTwoButton: true,
                      iconData: Icons.delete_forever_outlined,
                      title: 'Bạn muốn xoá SP này?',
                      content: 'Lưu ý: Hãy chắc chắn bạn muốn điều này?',
                    ),
                  );
                }).then((value)async{
              if(value != null){
                if(!Utils.isEmpty(value) && value == 'Yeah'){
                  DataLocal.listOrderProductLocal.removeAt(index);
                  DataLocal.listOrderProductIsChange = true;
                  setState(() {});
                  Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Yeah, Xoá SP thành công');
                }
              }
            });

            break;
          case '2':

            break;
        }
      }
    });
  }

}
