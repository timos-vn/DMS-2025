// ignore_for_file: library_private_types_in_public_api

import 'package:dms/model/database/data_local.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/custom_widget.dart';
import 'package:dms/widget/input_quantity_popup_order.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../../utils/const.dart';
import '../../../../utils/utils.dart';
import '../../../sell/component/search_product.dart';
import 'inventory_bloc.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';


class InventoryControlScreen extends StatefulWidget {
  // final bool isToday;
  final int idCheckIn;
  final String idCustomer;
  final bool view;
  final bool isCheckInSuccess;
  const InventoryControlScreen({Key? key,required this.idCheckIn, required this.idCustomer, required this.isCheckInSuccess,required this.view}) : super(key: key);

  @override
  _InventoryControlScreenState createState() => _InventoryControlScreenState();
}

class _InventoryControlScreenState extends State<InventoryControlScreen> {

  late InventoryBloc _bloc;
  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  bool _hasReachedMax = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
    _bloc = InventoryBloc(context);
    _bloc.add(GetPrefsInventory());

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(GetListInventory(isLoadMore:true,idCustomer: widget.idCustomer,idCheckIn: widget.idCheckIn.toString()));
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<InventoryBloc,InventoryState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            if(widget.isCheckInSuccess == true && Const.inventoryCheckIn == true){
              //_bloc.add(GetListInventory(idCustomer: widget.idCustomer,idCheckIn: widget.idCheckIn.toString()));
            }
          }else if(state is SaveInventoryStockSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Lưu phiếu thành công thành công');
            DataLocal.listInventoryIsChange = false;
          }
        },
        child: BlocBuilder<InventoryBloc,InventoryState>(
          bloc: _bloc,
          builder: (BuildContext context, InventoryState state){
            return Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is InventoryLoading,
                  child: const PendingAction(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,InventoryState state){
    int length = _bloc.listInventoryHistory.length;
    if (state is GetListInventorySuccess) {
      _hasReachedMax = length < _bloc.currentPage * 20;
    }
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Const.inventoryCheckIn == true
          ?
      Column(
        children: [
          Visibility(
            visible: DataLocal.listInventoryLocal.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding:const EdgeInsets.symmetric(horizontal: 5),
                    child: Text('Danh sách Tồn kho của Cửa Hàng (${( widget.isCheckInSuccess == false && widget.view == false) ? DataLocal.listInventoryLocal.length : _bloc.listInventoryHistory.length})',style:const TextStyle(color: Colors.blueGrey,fontSize: 10)),
                    // child: Text('Danh sách Tồn kho của Cửa Hàng (${(widget.isToday == true && widget.view == false) ? DataLocal.listInventoryLocal.length : _bloc.listInventoryHistory.length})',style:const TextStyle(color: Colors.blueGrey,fontSize: 10)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
            ),
          ),
          // Visibility(
          //   visible: ( widget.isCheckInSuccess == false && widget.view == false) &&  DataLocal.listInventoryLocal.isNotEmpty,
          //   // visible: (widget.isToday == true && widget.view == false) &&  DataLocal.listInventoryLocal.isNotEmpty,
          //   child: Expanded(
          //     child: ListView.builder(
          //         padding: const EdgeInsets.only(top: 6),
          //         shrinkWrap: true,
          //         itemBuilder: (BuildContext context, int index){
          //           var itemCheck = Const.kColorForAlphaB.firstWhere((item) => item.keyText == DataLocal.listInventoryLocal[index].nameProduct?.substring(0,1).toUpperCase());
          //           if(itemCheck != null){
          //             DataLocal.listInventoryLocal[index].kColorFormatAlphaB = itemCheck.color;
          //           }
          //           return GestureDetector(
          //               onTap: (){
          //                 if( widget.isCheckInSuccess == false){//if(widget.isToday == true && widget.view == false){
          //                   showBottomSheet(index,DataLocal.listInventoryLocal[index].nameProduct!);
          //                 }
          //               },
          //               child: Card(
          //                 semanticContainer: true,
          //                 margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
          //                 child: Padding(
          //                   padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
          //                   child: Row(
          //                     mainAxisSize: MainAxisSize.max,
          //                     children: [
          //                       Stack(
          //                         clipBehavior: Clip.none, children: [
          //                         Container(
          //                           width: 50,
          //                           height: 50,
          //                           decoration: BoxDecoration(
          //                               color: Color(DataLocal.listInventoryLocal[index].kColorFormatAlphaB!.value),
          //                               borderRadius: const BorderRadius.all(Radius.circular(6),)
          //                           ),
          //                           child: Center(child: Text('${DataLocal.listInventoryLocal[index].nameProduct?.substring(0,1).toUpperCase()}',style: const TextStyle(color: Colors.white),),),
          //                         ),
          //                       ],
          //                       ),
          //                       Expanded(
          //                         child: Container(
          //                           padding: const EdgeInsets.only(left: 10,right: 3,top: 5,bottom: 5),
          //                           width: double.infinity,
          //                           child: Column(
          //                             crossAxisAlignment: CrossAxisAlignment.start,
          //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                             children: [
          //                               Row(
          //                                 children: [
          //                                   Expanded(
          //                                     child: Text(
          //                                       '${DataLocal.listInventoryLocal[index].nameProduct}',
          //                                       textAlign: TextAlign.left,
          //                                       style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
          //                                       maxLines: 2,
          //                                       overflow: TextOverflow.ellipsis,
          //                                     ),
          //                                   ),
          //                                 ],
          //                               ),
          //                               const SizedBox(height: 10,),
          //                               Row(
          //                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                                 children: [
          //                                   Row(
          //                                     children: [
          //                                       Text(
          //                                         'Hạn sử dụng:',
          //                                         style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 11),
          //                                         textAlign: TextAlign.left,
          //                                       ),
          //                                       const SizedBox(
          //                                         width: 5,
          //                                       ),
          //                                       const Text("Đang cập nhật",
          //                                         style: TextStyle(color: blue, fontSize: 12),
          //                                         textAlign: TextAlign.left,
          //                                       ),
          //                                     ],
          //                                   ),
          //                                   Row(
          //                                     children: [
          //                                       Text(
          //                                         'SL Tồn:',
          //                                         style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 11),
          //                                         textAlign: TextAlign.left,
          //                                       ),
          //                                       const SizedBox(
          //                                         width: 5,
          //                                       ),
          //                                       Text("${DataLocal.listInventoryLocal[index].inventoryNumber?.toInt()??0} ${DataLocal.listInventoryLocal[index].dvt}",
          //                                         style: const TextStyle(color: Colors.red, fontSize: 12),
          //                                         textAlign: TextAlign.left,
          //                                       ),
          //                                     ],
          //                                   ),
          //                                 ],
          //                               ),
          //                             ],
          //                           ),
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             );
          //         },
          //         itemCount: DataLocal.listInventoryLocal.length
          //     ),
          //   ),
          // ),
          //Visibility(
          //visible: true, //( widget.isCheckInSuccess != false) && _bloc.listInventoryHistory.isNotEmpty,
          //visible: (widget.isToday != true && widget.view != false) && _bloc.listInventoryHistory.isNotEmpty,
          //  child:
          // ListView.builder(
          //     padding: const EdgeInsets.only(top: 6),
          //     shrinkWrap: true,
          //     controller: _scrollController,
          //     itemBuilder: (BuildContext context, int index){
          //       var itemCheck = Const.kColorForAlphaB.firstWhere((item) => item.keyText == _bloc.listInventoryHistory[index].tenVt?.substring(0,1).toUpperCase());
          //       if(itemCheck != null){
          //         _bloc.listInventoryHistory[index].kColorFormatAlphaB = itemCheck.color;
          //       }
          //       return index >= length ?
          //       Container(
          //         height: 100.0,
          //         color: white,
          //         child: const PendingAction(),
          //       )
          //           :
          //       Card(
          //         semanticContainer: true,
          //         margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
          //         child: Padding(
          //           padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
          //           child: Row(
          //             mainAxisSize: MainAxisSize.max,
          //             children: [
          //               Stack(
          //                 clipBehavior: Clip.none, children: [
          //                 Container(
          //                   width: 50,
          //                   height: 50,
          //                   decoration: BoxDecoration(
          //                       color: Color(_bloc.listInventoryHistory[index].kColorFormatAlphaB!.value),
          //                       borderRadius: const BorderRadius.all(Radius.circular(6),)
          //                   ),
          //                   child: Center(child: Text('${_bloc.listInventoryHistory[index].tenVt?.substring(0,1).toUpperCase()}',style: const TextStyle(color: Colors.white),),),
          //                 ),
          //               ],
          //               ),
          //               Expanded(
          //                 child: Container(
          //                   padding: const EdgeInsets.only(left: 10,right: 3,top: 5,bottom: 5),
          //                   width: double.infinity,
          //                   child: Column(
          //                     crossAxisAlignment: CrossAxisAlignment.start,
          //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                     children: [
          //                       Row(
          //                         children: [
          //                           Expanded(
          //                             child: Text(
          //                               '${_bloc.listInventoryHistory[index].tenVt}',
          //                               textAlign: TextAlign.left,
          //                               style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
          //                               maxLines: 2,
          //                               overflow: TextOverflow.ellipsis,
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                       const SizedBox(height: 10,),
          //                       Row(
          //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                         children: [
          //                           Row(
          //                             children: [
          //                               Text(
          //                                 'Hạn sử dụng:',
          //                                 style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 11),
          //                                 textAlign: TextAlign.left,
          //                               ),
          //                               const SizedBox(
          //                                 width: 5,
          //                               ),
          //                               const Text("Đang cập nhật",
          //                                 style: TextStyle(color: blue, fontSize: 12),
          //                                 textAlign: TextAlign.left,
          //                               ),
          //                             ],
          //                           ),
          //                           Row(
          //                             children: [
          //                               Text(
          //                                 'SL Tồn:',
          //                                 style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 11),
          //                                 textAlign: TextAlign.left,
          //                               ),
          //                               const SizedBox(
          //                                 width: 5,
          //                               ),
          //                               Text("${_bloc.listInventoryHistory[index].slTon?.toInt()??0} ${_bloc.listInventoryHistory[index].dvt}",
          //                                 style: const TextStyle(color: Colors.red, fontSize: 12),
          //                                 textAlign: TextAlign.left,
          //                               ),
          //                             ],
          //                           ),
          //                         ],
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       );
          //     },
          //     itemCount: _bloc.listInventoryHistory.length
          // ),
          //),
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.only(top: 6),
                shrinkWrap: true,
                // physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index){
                  bool exits = Const.kColorForAlphaB.any((element) => element.keyText == DataLocal.listInventoryLocal[index].nameProduct?.substring(0,1).toUpperCase());
                  if(exits == true){
                    var itemCheck = Const.kColorForAlphaB.firstWhere((item) => item.keyText == DataLocal.listInventoryLocal[index].nameProduct?.substring(0,1).toUpperCase());
                    if(itemCheck != null){
                      DataLocal.listInventoryLocal[index].kColorFormatAlphaB = itemCheck.color;
                    }
                  }
                  return GestureDetector(
                    onTap: (){
                      if( widget.isCheckInSuccess == false){//if(widget.isToday == true && widget.view == false){
                        showBottomSheet(index,DataLocal.listInventoryLocal[index].nameProduct!);
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
                                    color:DataLocal.listInventoryLocal[index].kColorFormatAlphaB == null ? Colors.blueGrey : Color(DataLocal.listInventoryLocal[index].kColorFormatAlphaB!.value),
                                    borderRadius: const BorderRadius.all(Radius.circular(6),)
                                ),
                                child: Center(child: Text('${DataLocal.listInventoryLocal[index].nameProduct?.substring(0,1).toUpperCase()}',style: const TextStyle(color: Colors.white),),),
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
                                            '${DataLocal.listInventoryLocal[index].nameProduct}',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Hạn sử dụng:',
                                              style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 11),
                                              textAlign: TextAlign.left,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            const Text("Đang cập nhật",
                                              style: TextStyle(color: blue, fontSize: 12),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'SL Tồn:',
                                              style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 11),
                                              textAlign: TextAlign.left,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text("${DataLocal.listInventoryLocal[index].inventoryNumber?.toInt()??0} ${DataLocal.listInventoryLocal[index].dvt}",
                                              style: const TextStyle(color: Colors.red, fontSize: 12),
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
                itemCount: DataLocal.listInventoryLocal.length
            ),
          ),
          Visibility(
            visible: DataLocal.listInventoryLocal.isEmpty && _bloc.listInventoryHistory.isEmpty,
            child: const Expanded(
              child: Center(
                child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
              ),
            ),
          ),
          //Visibility(
          // visible:true ,//widget.isCheckInSuccess == false  && widget.view == false,
          // visible: widget.isToday == true && widget.view == false && widget.isCheckInSuccess == false,
          // child:
          buildMenu()
          //)
        ],
      )
          :
      SingleChildScrollView(child: lockModule()),
    );
  }

  buildMenu(){
    return Container(
      height: 55,width: double.infinity,
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
                    inventoryControl: true,
                    addProductFromCheckIn: false,
                    addProductFromSaleOut: false,
                    giftProductRe: false,
                    lockInputToCart: false,checkStockEmployee: false,
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.addchart_outlined,color: Colors.white,size: 18,),
                    SizedBox(width: 5,),
                    Text('Thêm SP',style: TextStyle(color: Colors.white),),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12,),
          // Expanded(
          //   child: GestureDetector(
          //     onTap: ()async{
          //       // String code = await FlutterBarcodeScanner.scanBarcode(
          //       //     "#8CC63F",
          //       //     'Huỷ bỏ',
          //       //     true,
          //       //     ScanMode.DEFAULT
          //       // );
          //       // if(!Utils.isEmpty(code) && code != '-1'){
          //       //
          //       // }
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
          //           Icon(Icons.qr_code_rounded,color: Colors.white,size: 18,),
          //           SizedBox(width: 5,),
          //           Text('Quét mã',style: TextStyle(color: Colors.white),),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // const SizedBox(width: 12,),
          Expanded(
            child: GestureDetector(
              onTap: (){
               if(DataLocal.listInventoryIsChange == true){
                 if(DataLocal.listInventoryLocal.isNotEmpty){
                   _bloc.add(SaveInventoryStock(idCheckIn: widget.idCheckIn,idCustomer: widget.idCustomer));
                 }else{
                   Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Ở đây chẳng có gì để lưu cả');
                 }
               }else{
                 Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Yeah, Phiếu đã được lưu');
               }
              },
              child: Container(
                padding:const EdgeInsets.symmetric(horizontal: 8,vertical: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: DataLocal.listInventoryIsChange == true ? mainColor : Colors.grey
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.save_alt,color: Colors.white,size: 18,),
                    SizedBox(width: 5,),
                    Text('Lưu',style: TextStyle(color: Colors.white),),
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
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 12,bottom: 10,left: 10,right: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: const [
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
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 12,bottom: 10,left: 10,right: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: const [
                                                Text('Cập nhật lại số lượng tồn',style: TextStyle(color: Colors.black),),
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
                  DataLocal.listInventoryLocal.removeAt(index);
                  DataLocal.listInventoryIsChange = true;
                  setState(() {});
                  Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Xoá SP thành công');
                }
              }
            });

            break;
          case '2':
            showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) {
                  return InputQuantityPopupOrder(
                    title: 'Cập nhật số lượng',
                    //itemCode: DataLocal.listInventoryLocal[index].codeProduct.toString(),
                    quantity: 0,
                    quantityStock: DataLocal.listInventoryLocal[index].inventoryNumber??0,
                    listDvt: const [],
                    listStock: const [],
                    findStock: false,
                    allowDvt: false,inventoryStore: true,
                    nameProduction: DataLocal.listInventoryLocal[index].nameProduct.toString(),
                    price: DataLocal.listInventoryLocal[index].price??0,
                    codeProduction: DataLocal.listInventoryLocal[index].codeProduct.toString(),
                    listObjectJson: '', listQuyDoiDonViTinh: [], nuocsx: '',quycach: '',
                  );
                }).then((value){
              if(double.parse(value[0].toString()) > 0){
                DataLocal.listInventoryLocal[index].inventoryNumber = double.parse(value[0].toString());
                setState(() {});
              }
            });
            break;
        }
      }
    });
  }
}
