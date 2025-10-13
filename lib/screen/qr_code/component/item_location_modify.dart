
import 'package:dms/screen/qr_code/qr_code_bloc.dart';
import 'package:dms/screen/qr_code/qr_code_sate.dart';
import 'package:dms/widget/barcode_scanner_widget.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../model/network/response/get_info_card_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../qr_code_event.dart';

class ItemLocationModifyScreen extends StatefulWidget {
  final String nameCard;
  final FormatProvider formatProvider;
  final List<ListItem> listItemCard;
  final RuleActionInfoCard ruleActionInformationCard;
  final MasterInfoCard masterInformationCard;
  final String keyFunction;

  const ItemLocationModifyScreen({super.key, required this.formatProvider,required this.nameCard, required this.masterInformationCard, required this.ruleActionInformationCard,
    required this.listItemCard,
    required this.keyFunction});

  @override
  State<ItemLocationModifyScreen> createState() => _ItemLocationModifyScreenState();
}

class _ItemLocationModifyScreenState extends State<ItemLocationModifyScreen> {
  late QRCodeBloc _bloc;
  bool checkItemExits = false;

  String valuesBarcode = '';
  bool isProcessing = false;

  bool viewQRCode = true;
  List<ListItem> listItemCard = [];
  String licensePlates = '';
  int indexSelected = -1;
  
  // ✅ Camera instance riêng cho màn hình này
  final GlobalKey _cameraKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = QRCodeBloc(context);

    listItemCard.addAll(widget.listItemCard);
  }

  @override
  void dispose() {
    // ✅ Stop camera safely when leaving the screen
    try {
      (_cameraKey.currentState as dynamic)?.stopCamera();
      debugPrint('=== ItemLocationModify: Camera stopped in dispose ===');
    } catch (e) {
      debugPrint('=== ItemLocationModify: Error stopping camera in dispose: $e ===');
    }
    
    _bloc.close();
    super.dispose();
  }

  void handleBarcodeScan(String code) async {
    if (isProcessing) return;
    isProcessing = true;

    if(widget.keyFunction == '#4'){
      if(indexSelected >=0){
        String kg = "0";
        String expirationDate = '';
        if(widget.formatProvider.canYn == 1){
          kg = NumberFormat(widget.formatProvider.soThapPhan.toString()).format(double.parse(code.toString().substring(widget.formatProvider.canTu!.toInt(),widget.formatProvider.canDen!.toInt())));
        }
        if(widget.formatProvider.hsdYn == 1){
          expirationDate = code.toString().substring(widget.formatProvider.hsdTu!.toInt(),widget.formatProvider.hsdDen!.toInt());
          // DateTime dateTime = DateTime.parse(expirationDate);
          // var dateTime = Jiffy(expirationDate,'dd')
          // print('date cutting: $dateTime');
        }

        listItemCard[indexSelected].qrCode = code.toString();
        listItemCard[indexSelected].soLuong = double.parse(kg.toString());
        listItemCard[indexSelected].expirationDate = expirationDate;
        _bloc.add(RefreshUpdateItemBarCodeEvent());
        // List<UpdateItemBarCodeRequestDetail> _listItem = [];
        //
        // _listItem.add(UpdateItemBarCodeRequestDetail(
        //     maVt: listItemCard[indexSelected].maVt,
        //     barcode:  result!.code,
        //     maKho:  listItemCard[indexSelected].maKho,
        //     maLo:  listItemCard[indexSelected].maLo,
        //     soCan:  kg,
        //     hsd:  expirationDate
        // ));
        if(!valuesBarcode.contains(code.toString())){
          valuesBarcode = code.toString();
          _bloc.add(RefreshUpdateItemBarCodeEvent());
        }
      }
      else{
        Utils.showCustomToast(context, Icons.warning_amber, 'Vui lòng chọn 1 sản phẩm để cập nhật');
      }
    }
    else if(widget.keyFunction == '#3'){
      if(!valuesBarcode.contains(code)){
        valuesBarcode = code;
        _bloc.add(GetInformationItemFromBarCodeEvent(barcode: valuesBarcode.toString(), pallet: ''));
      }
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    isProcessing = false;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey_100,
      body: BlocListener<QRCodeBloc,QRCodeState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is UpdateQuantityInWarehouseDeliveryCardSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Cập nhật phiếu thành công');
            Navigator.pop(context);
          }else if(state is QRCodeFailure){
            Utils.showCustomToast(context, Icons.check_circle_outline, state.error.toString());
          }
          else if(state is CreateDeliverySuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Tạo phiếu thành công');
            Navigator.pop(context);
          }
          else if(state is UpdateItemBarCodeSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Cập nhật Barcode thành công');
          }
          else if(state is ConfirmPostPNFSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Cập nhật phiếu thành công');
            Navigator.pop(context);
          }
          else if(state is GetInformationItemFromBarCodeSuccess){
            valuesBarcode = '';
            if(listItemCard.isNotEmpty){
              for (var element in listItemCard) {
                if(element.maVt.toString().trim() == _bloc.informationProduction.maVt.toString().trim()){
                  checkItemExits = true;
                  break;
                }
              }
              if(checkItemExits == false){
                Utils.showCustomToast(context, Icons.warning_amber, 'Sản phẩm này của bạn không tồn tại');
              }else{
                Utils.showCustomToast(context, Icons.check_circle_outline, 'Kiểm tra thành công');
              }
            }else{
              Utils.showCustomToast(context, Icons.warning_amber, 'Phiếu của bạn đang trống');
            }
          }
        },
        child: BlocBuilder<QRCodeBloc,QRCodeState>(
            bloc: _bloc,
            builder: (BuildContext context,QRCodeState state){
              return  Stack(
                children: [
                  buildScreen(context, state),
                  Visibility(
                    visible: state is QRCodeLoading,
                    child: const PendingAction(),
                  ),
                ],
              );
            }
        ),
      ),
    );
  }

  buildScreen(context,QRCodeState state){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildAppBar(),
        Visibility(
          visible: viewQRCode == true,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
              height: 200, width: double.infinity,
              child: buildCamera(),
            ),
          ),
        ),

        // Expanded(
        //     child: SingleChildScrollView(
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.center,
        //         children: [
        //           Padding(
        //             padding: const EdgeInsets.only(left: 10,right: 10),
        //             child: Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //               children: <Widget>[
        //                 Row(
        //                   children: [
        //                     const Text(
        //                       'Danh sách sản phẩm',
        //                       style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),
        //                     ),
        //                     const SizedBox(width: 5,),
        //                     Text(
        //                       widget.keyFunction.toString(),
        //                       style: const TextStyle(fontSize: 12.0,color: subColor),
        //                     ),
        //                   ],
        //                 ),
        //                 Padding(
        //                   padding: const EdgeInsets.only(right: 3),
        //                   child: IconButton(
        //                     icon: const Icon(EneftyIcons.scan_outline,color: Colors.grey),
        //                     onPressed: () {
        //                       if(viewQRCode == true){
        //                         setState(() {
        //                           viewQRCode = false;
        //                           print(viewQRCode);
        //                           _controller?.pauseCamera();
        //                         });
        //                       }else{
        //                         setState(() {
        //                           viewQRCode = true;
        //                           print(viewQRCode);
        //                           _controller?.resumeCamera();
        //                         });
        //                       }
        //                     },
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ),
        //           SizedBox(
        //             height: listItemCard.length > 1 ? 200 : 140,
        //             width: double.infinity,
        //             child:  ListView.separated(
        //                 key: const Key('KeyList2'),
        //                 shrinkWrap: true,
        //                 physics: listItemCard.length > 1 ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
        //                 padding: EdgeInsets.zero,
        //                 itemBuilder: (_, index) {
        //                   if(index != indexSelected){
        //                     listItemCard[index].isMark = 0;
        //                   }
        //                   return Slidable(
        //                     key: const ValueKey(1),
        //                     endActionPane: ActionPane(
        //                       motion: const ScrollMotion(),
        //                       dragDismissible: false,
        //                       children: [
        //                         SlidableAction(
        //                           onPressed:(_) {
        //                             showDialog(
        //                                 barrierDismissible: true,
        //                                 context: context,
        //                                 builder: (context) {
        //                                   return UpdateBarCode(
        //                                     barcode: listItemCard[index].qrCode.toString(),
        //                                     hsd: listItemCard[index].expirationDate.toString(),
        //                                   );
        //                                 }).then((value){
        //                               if(value != null){
        //                                 setState(() {
        //                                   listItemCard[index].qrCode = value[0].toString();
        //                                   listItemCard[index].expirationDate = value[1].toString();
        //                                 });
        //                               }
        //                             });
        //                           },
        //                           borderRadius:const BorderRadius.all(Radius.circular(8)),
        //                           padding:const EdgeInsets.all(10),
        //                           backgroundColor: Colors.indigoAccent,
        //                           foregroundColor: Colors.white,
        //                           icon: EneftyIcons.card_edit_outline,
        //                           label: 'Sửa',
        //                         ),
        //                       ],
        //                     ),
        //                     child: GestureDetector(
        //                       onTap: (){
        //                         setState(() {
        //                           if(listItemCard[index].isMark == 1){
        //                             listItemCard[index].isMark = 0;
        //                             indexSelected = -1;
        //                           }
        //                           else{
        //                             listItemCard[index].isMark = 1;
        //                             indexSelected = index;
        //                           }
        //                         });
        //                       },
        //                       child: Card(
        //                         semanticContainer: true,
        //                         margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
        //                         child: Row(
        //                           children: [
        //                             Visibility(
        //                               visible: widget.keyFunction != '#4',
        //                               child: Container(
        //                                 width: 100,
        //                                 height: 130,
        //                                 decoration: const BoxDecoration(
        //                                     borderRadius:BorderRadius.all( Radius.circular(6),)
        //                                 ),
        //                                 child: Image.network('https://i.pinimg.com/564x/49/77/91/4977919321475b060fcdd89504cee992.jpg',fit: BoxFit.contain,),
        //                               ),),
        //                             Visibility(
        //                               visible: widget.keyFunction == '#4',
        //                               child: SizedBox(
        //                                 width: 50,
        //                                 child: Transform.scale(
        //                                   scale: 1,
        //                                   alignment: Alignment.topLeft,
        //                                   child: Checkbox(
        //                                     value: listItemCard[index].isMark == 0 ? false : true,
        //                                     onChanged: (b){
        //                                       setState(() {
        //                                         if(listItemCard[index].isMark == 1){
        //                                           listItemCard[index].isMark = 0;
        //                                           indexSelected = -1;
        //                                         }
        //                                         else{
        //                                           listItemCard[index].isMark = 1;
        //                                           indexSelected = index;
        //                                         }
        //                                       });
        //                                     },
        //                                     activeColor: mainColor,
        //                                     hoverColor: Colors.orange,
        //                                     shape: RoundedRectangleBorder(
        //                                         borderRadius: BorderRadius.circular(4)
        //                                     ),
        //                                     side: MaterialStateBorderSide.resolveWith((states){
        //                                       if(states.contains(MaterialState.pressed)){
        //                                         return BorderSide(color: mainColor);
        //                                       }else{
        //                                         return BorderSide(color: mainColor);
        //                                       }
        //                                     }),
        //                                   ),
        //                                 ),
        //                               ),
        //                             ),
        //                             Expanded(
        //                               child: Padding(
        //                                 padding: const EdgeInsets.only(top: 10,right: 6,bottom: 5),
        //                                 child: Column(
        //                                   crossAxisAlignment: CrossAxisAlignment.start,
        //                                   mainAxisAlignment: MainAxisAlignment.start,
        //                                   children: [
        //                                     Text(
        //                                       '[${listItemCard[index].maVt.toString().trim()}] ${listItemCard[index].tenVt.toString().toUpperCase()}',
        //                                       style:const TextStyle(color: subColor, fontSize: 12.5, fontWeight: FontWeight.w600,),
        //                                       maxLines: 2,overflow: TextOverflow.ellipsis,
        //                                     ),
        //                                     const SizedBox(height: 5,),
        //                                     Padding(
        //                                       padding: const EdgeInsets.only(right: 6,bottom: 5),
        //                                       child: Row(
        //                                         crossAxisAlignment: CrossAxisAlignment.center,
        //                                         children: [
        //                                           const Icon(EneftyIcons.scan_outline,color: Colors.grey,size: 15,),
        //                                           const SizedBox(width: 5,),
        //                                           Expanded(
        //                                             child: Text(listItemCard[index].qrCode??'Chưa cập nhật QRCode',
        //                                               textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
        //                                               maxLines: 1, overflow: TextOverflow.ellipsis,
        //                                             ),
        //                                           ),
        //                                         ],
        //                                       ),
        //                                     ),
        //                                     Padding(
        //                                       padding: const EdgeInsets.only(right: 6,bottom: 5),
        //                                       child: Row(
        //                                         crossAxisAlignment: CrossAxisAlignment.center,
        //                                         children: [
        //                                           const Icon(EneftyIcons.calendar_remove_outline,color: Colors.grey,size: 15,),
        //                                           const SizedBox(width: 5,),
        //                                           Text(listItemCard[index].expirationDate??'Chưa cập nhật hạn sử dụng',
        //                                             textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
        //                                             maxLines: 1, overflow: TextOverflow.ellipsis,
        //                                           ),
        //                                         ],
        //                                       ),
        //                                     ),
        //                                     Row(
        //                                       crossAxisAlignment: CrossAxisAlignment.center,
        //                                       children: [
        //                                         const Icon(EneftyIcons.shopping_cart_outline,size: 15,color: Colors.grey),
        //                                         const SizedBox(width: 7,),
        //                                         Expanded(
        //                                           child: Text(listItemCard[index].tenKho??'Kho đang cập nhật',
        //                                             textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
        //                                             maxLines: 1, overflow: TextOverflow.ellipsis,
        //                                           ),
        //                                         ),
        //                                         Container(
        //                                           height: 13,
        //                                           width: 1.5,
        //                                           color: Colors.grey,
        //                                         ),
        //                                         Expanded(
        //                                           child: Padding(
        //                                             padding: const EdgeInsets.only(right: 0),
        //                                             child: Align(
        //                                               alignment: Alignment.center,
        //                                               child: Text(
        //                                                 'Loại: ${listItemCard[index].cheBien == 1 ? 'Chế biến' : listItemCard[index].sanXuat == 1 ? 'Sản xuất' :'Thường'}',
        //                                                 style:const TextStyle(color: Colors.blueGrey,fontSize: 12),
        //                                                 textAlign: TextAlign.center,
        //                                               ),
        //                                             ),
        //                                           ),
        //                                         ),
        //                                         Container(
        //                                           height: 13,
        //                                           width: 1.5,
        //                                           color: Colors.grey,
        //                                         ),
        //                                         Expanded(
        //                                           child: Padding(
        //                                             padding: const EdgeInsets.only(right: 0),
        //                                             child: Align(
        //                                               alignment: Alignment.center,
        //                                               child: Text(
        //                                                 'Đơn vị: ${listItemCard[index].tenDvt}',
        //                                                 style:const TextStyle(color: Colors.blueGrey,fontSize: 12,),
        //                                                 textAlign: TextAlign.center,
        //                                               ),
        //                                             ),
        //                                           ),
        //                                         )
        //                                       ],
        //                                     ),
        //                                     Padding(
        //                                       padding: const EdgeInsets.only(top: 5,right: 0),
        //                                       child: Row(
        //                                         crossAxisAlignment: CrossAxisAlignment.start,
        //                                         children: [
        //                                           Expanded(
        //                                             child: Container(
        //                                               height: 35,
        //                                               padding: const EdgeInsets.only(left: 5),
        //                                               decoration: BoxDecoration(
        //                                                 borderRadius: BorderRadius.circular(16),
        //                                                 color: Colors.white,
        //                                               ),
        //                                               child: Row(
        //                                                 mainAxisAlignment: MainAxisAlignment.start,
        //                                                 children: [
        //                                                   Row(
        //                                                     children: [
        //                                                       Text(
        //                                                         '\$ ${Utils.formatMoneyStringToDouble(listItemCard[index].tien??0)}',
        //                                                         textAlign: TextAlign.left,
        //                                                         style: const TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
        //                                                       ),
        //                                                     ],
        //                                                   ),
        //                                                   Expanded(
        //                                                     child: Container(
        //                                                       color: Colors.transparent,
        //                                                       width: 40,
        //                                                     ),
        //                                                   ),
        //                                                 ],
        //                                               ),
        //                                             ),
        //                                           ),
        //                                           Container(
        //                                             height: 35,
        //                                             padding: const EdgeInsets.symmetric(horizontal: 10),
        //                                             decoration: BoxDecoration(
        //                                                 borderRadius: BorderRadius.circular(16),
        //                                                 color: grey_100
        //                                             ),
        //                                             child: Row(
        //                                               mainAxisAlignment: MainAxisAlignment.spaceAround,
        //                                               children: [
        //                                                 InkWell(
        //                                                     onTap: (){
        //                                                       double qty = 0;
        //                                                       qty = listItemCard[index].soLuong??0;
        //                                                       if(qty > 1){
        //                                                         setState(() {
        //                                                           qty = qty - 1;
        //                                                           listItemCard[index].soLuong = qty;
        //                                                         });
        //                                                       }
        //                                                     },
        //                                                     child: const SizedBox(width:25,child: Icon(FluentIcons.subtract_12_filled,size: 15,))),
        //                                                 GestureDetector(
        //                                                   onTap: (){
        //                                                     showDialog(
        //                                                         barrierDismissible: true,
        //                                                         context: context,
        //                                                         builder: (context) {
        //                                                           return const InputQuantityShipping(title: 'Vui lòng nhập số lượng thay đổi',desc: 'Nếu số lượng không thay đổi thì bạn không cần sửa.',);
        //                                                         }).then((quantity){
        //                                                       if(quantity != null){
        //                                                         setState(() {
        //                                                           print(quantity);
        //                                                           listItemCard[index].soLuong = double.parse(quantity??'0');
        //                                                         });
        //                                                       }
        //                                                     });
        //                                                   },
        //                                                   child: Row(
        //                                                     mainAxisAlignment: MainAxisAlignment.center,
        //                                                     crossAxisAlignment: CrossAxisAlignment.center,
        //                                                     children: [
        //                                                       Text("${listItemCard[index].soLuong??0} ",
        //                                                         style: const TextStyle(fontSize: 14, color: Colors.black),
        //                                                         textAlign: TextAlign.center,
        //                                                       ),
        //                                                     ],
        //                                                   ),
        //                                                 ),
        //                                                 InkWell(
        //                                                     onTap: (){
        //                                                       double qty = 0;
        //                                                       qty = listItemCard[index].soLuong??0;
        //                                                       setState(() {
        //                                                         qty = qty + 1;
        //                                                         listItemCard[index].soLuong = qty;
        //                                                       });
        //                                                     },
        //                                                     child: const SizedBox(width:25,child: Icon(FluentIcons.add_12_filled,size: 15))),
        //                                               ],
        //                                             ),
        //                                           ),
        //                                         ],
        //                                       ),
        //                                     ),
        //                                   ],
        //                                 ),
        //                               ),
        //                             )
        //                           ],
        //                         ),
        //                       ),
        //                     ),
        //                   );
        //                 },
        //                 separatorBuilder: (_, __) {
        //                   return const SizedBox(height: 8);
        //                 },
        //                 itemCount: listItemCard.length),
        //           ),
        //           const SizedBox(
        //             height: 5.0,
        //           ),
        //           const Divider(),
        //           Padding(
        //             padding: const EdgeInsets.only(top: 5,bottom: 15),
        //             child: Container(
        //               color: grey_100,
        //               child: Column(
        //                 children: [
        //                   const SizedBox(height: 5,),
        //                   Container(
        //                     height: 100,
        //                     width: double.infinity,
        //                     padding: const EdgeInsets.fromLTRB(8, 0, 8,0),
        //                     child: Row(
        //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                       crossAxisAlignment: CrossAxisAlignment.center,
        //                       children: [
        //                         const CircleAvatar(
        //                           radius: 38,
        //                           backgroundImage: AssetImage(avatarStore),
        //                           backgroundColor: Colors.transparent,
        //                         ),
        //                         Expanded(
        //                           child: Padding(
        //                             padding: const EdgeInsets.only(left: 12),
        //                             child: Column(
        //                               crossAxisAlignment: CrossAxisAlignment.start,
        //                               mainAxisAlignment: MainAxisAlignment.center,
        //                               children: [
        //                                 Flexible(child: Text(
        //                                   '[${!Utils.isEmpty(widget.masterInformationCard.maKh.toString()) && widget.masterInformationCard.maKh.toString().trim() != 'null' ? widget.masterInformationCard.maKh.toString().trim() :widget.masterInformationCard.maNcc.toString().trim()}]  '
        //                                       '${!Utils.isEmpty(widget.masterInformationCard.tenKh.toString()) && widget.masterInformationCard.tenKh.toString() != 'null' ? widget.masterInformationCard.tenNcc.toString().trim() : widget.masterInformationCard.tenKh.toString().trim()}',
        //                                   style: const TextStyle(color: subColor,fontWeight: FontWeight.bold,fontSize: 13),maxLines: 2,overflow: TextOverflow.ellipsis,),),
        //                                 const SizedBox(height: 5,),
        //                                 Row(
        //                                   children: [
        //                                     const Icon(EneftyIcons.card_pos_outline,color: Colors.blueGrey,size: 18,),
        //                                     const SizedBox(width: 8,),
        //                                     Text(
        //                                       '${widget.masterInformationCard.sttRec}'
        //                                       ,style: const TextStyle(color: Color(0xff0162c1)  ,fontWeight: FontWeight.w700,fontSize: 11),maxLines: 1,overflow: TextOverflow.ellipsis,),
        //                                   ],
        //                                 ),
        //                                 const SizedBox(height: 5,),
        //                                 Row(
        //                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                                   children: [
        //                                     Row(
        //                                       children: [
        //                                         const Icon(EneftyIcons.calendar_3_outline,color: Colors.blueGrey,size: 18,),
        //                                         const SizedBox(width: 8,),
        //                                         Text(
        //                                           '${widget.masterInformationCard.ngayCt}'
        //                                           ,style: const TextStyle(color: Color(0xff0162c1)  ,fontWeight: FontWeight.w700,fontSize: 11),maxLines: 1,overflow: TextOverflow.ellipsis,),
        //                                       ],
        //                                     ),
        //                                     Padding(
        //                                       padding: const EdgeInsets.only(right: 4),
        //                                       child: Text('${widget.masterInformationCard.statusname}',
        //                                           style: const TextStyle(color: Color(0xff0162c1)  ,fontWeight: FontWeight.w700,fontSize: 11)),
        //                                     ),
        //                                   ],
        //                                 ),
        //                               ],
        //                             ),
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                   const SizedBox(height: 5,),
        //                   customView(EneftyIcons.truck_fast_outline, 'Vận chuyển: ${widget.masterInformationCard.tenHtvc.toString().trim()}', true, FontWeight.normal),
        //                   customView(EneftyIcons.note_2_outline, 'Ghi chú: ${widget.masterInformationCard.dienGiai.toString().trim()}', false, FontWeight.normal),
        //                 ],
        //               ),
        //             ),
        //           ),
        //           customPayment(title: 'Code',value: '${widget.masterInformationCard.soCt}'),
        //           customPayment(title: 'Tổng số lượng',value: '${widget.masterInformationCard.tSoLuong}'),
        //           customPayment(title: 'Tổng thanh toán',value: '\$${Utils.formatMoneyStringToDouble(widget.masterInformationCard.tTT??0)}'.toString().trim()),
        //           const SizedBox(
        //             height: 5.0,
        //           ),
        //           Padding(
        //             padding: const EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 10),
        //             child: GestureDetector(
        //               onTap: (){
        //                 print(widget.keyFunction == '#1');
        //                 if(widget.keyFunction.toString().trim() == '#1'){
        //                   if(listItemCard.isNotEmpty){
        //                     print(widget.keyFunction);
        //                     List<UpdateQuantityInWarehouseDeliveryCardDetail> listItemUpdate = [];
        //                     for (var element in listItemCard) {
        //                       UpdateQuantityInWarehouseDeliveryCardDetail item = UpdateQuantityInWarehouseDeliveryCardDetail(
        //                           sttRec: element.sttRec,
        //                           sttRec0: element.sttRec0,
        //                           count: element.soLuong,
        //                           codeProduction: element.maVt
        //                       );
        //                       listItemUpdate.add(item);
        //                     }
        //                     _bloc.add(UpdateQuantityInWarehouseDeliveryCardEvent(
        //                         licensePlates: licensePlates,
        //                         listItem: listItemUpdate
        //                     ));
        //                   }
        //                   else{
        //                     Utils.showCustomToast(context, Icons.warning_amber, 'Phiếu của bạn không có gì để cập nhật cả');
        //                   }
        //                 }
        //                 else if(widget.keyFunction.toString().trim() == '#3'){
        //                   if(checkItemExits == false){
        //                     Utils.showCustomToast(context, Icons.warning_amber, 'Có SP Fake bạn không thể xác nhận phiếu này');
        //                   }else{
        //                     _bloc.add(ConfirmPostPNFEvent(sttRec: widget.masterInformationCard.sttRec.toString()));
        //                   }
        //                 }
        //                 else if(widget.keyFunction.toString().trim() == '#4'){
        //                   List<UpdateItemBarCodeRequestDetail> _listItem = [];
        //                   for (var element in listItemCard) {
        //                     if(!Utils.isEmpty(element.qrCode.toString()) && element.qrCode.toString().trim() != 'null'){
        //                       _listItem.add(UpdateItemBarCodeRequestDetail(
        //                           maVt: element.maVt,
        //                           barcode: element.qrCode,
        //                           maKho:  element.maKho,
        //                           maLo:  element.maLo,
        //                           soCan:  element.soLuong.toString(),
        //                           hsd:  element.expirationDate,
        //                           sttRec: widget.masterInformationCard.sttRec.toString()
        //                       ));
        //                     }
        //                   }
        //                   _bloc.add(UpdateItemBarCodeEvent(listItem: _listItem,sttRec: widget.masterInformationCard.sttRec.toString()));
        //                 }
        //                 else if(widget.keyFunction.toString().trim() == '#6'){
        //                   _bloc.add(CreateDeliveryEvent(sttRec: _bloc.masterInformationCard.sttRec.toString(),licensePlates: licensePlates));
        //                 }
        //               },
        //               child: Container(
        //                 height: 48,
        //                 width: double.infinity,
        //                 decoration: BoxDecoration(
        //                     color: Colors.black,
        //                     borderRadius: BorderRadius.circular(24)
        //                 ),
        //                 child: Row(
        //                   crossAxisAlignment: CrossAxisAlignment.center,
        //                   mainAxisAlignment: MainAxisAlignment.center,
        //                   children: [
        //                     Text(
        //                       widget.keyFunction == '#1' ?
        //                       'Cập nhật số lượng'
        //                           :
        //                       widget.keyFunction == '#3' ?  'Xác nhận'
        //                           :
        //                       widget.keyFunction == '#6' ?  'Lên phiếu giao hàng'
        //                           :
        //                       'Cập nhật thông tin phiếu'
        //                       ,style: TextStyle(color: Colors.white),),
        //                   ],
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ))
      ],
    );
  }

  customPayment({required String title,required String value}){
    return Padding(
      padding: const EdgeInsets.only(left: 12,right: 12,bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,style: const TextStyle(color: subColor,fontWeight: FontWeight.bold),),
          Text(value,style: const TextStyle(color: subColor,fontWeight: FontWeight.bold),),
        ],
      ),
    );
  }

  customView(IconData icon, String title, bool showDivider, FontWeight fontWeight){
    return Padding(
      padding: EdgeInsets.only(left: 12,right: 0,bottom: showDivider == true ? 5 : 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon),
              const SizedBox(width: 18,),
              Text(title,
                style: TextStyle(fontWeight: fontWeight,color: subColor),
              ),
            ],
          ),
          SizedBox(height: showDivider == true ? 5 : 10,),
          Visibility(
              visible: showDivider == true,
              child: const Divider(color: Colors.grey))
        ],
      ),
    );
  }

  buildCamera(){
    return BarcodeScannerWidget(
      key: _cameraKey,
      onBarcodeDetected: handleBarcodeScan,
    );
  }

  buildAppBar(){
    return Container(
      height: 83,
      width: double.infinity,
      decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [subColor,Color.fromARGB(255, 150, 185, 229)])),
      padding: const EdgeInsets.fromLTRB(5, 35, 12,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: (){

              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: InkWell(
                onTap: (){
                  setState(() {
                    viewQRCode = false;
                    // ✅ Camera sẽ được quản lý bởi widget riêng của màn hình
                  });
                  var formatter = NumberFormat('#,##,000');
                  print(formatter.format(16987));
                  print(NumberFormat('#,##0').format(231548));
                  print(NumberFormat('#,##0.00').format(231548));
                  print(NumberFormat('#,##0').format(231548));
                  print(NumberFormat('#,##0.00').format(231548));
                  print(NumberFormat('#,##0.00000').format(231548));
                  print(NumberFormat(Const.amountFormat).format(231548));
                  print('02315123555482B920231211'.substring(16,24));
                  DateTime dateTime = DateTime.parse('02315123555482B920231211'.substring(16,24));
                  print(dateTime.toString());
                },
                child: Text(
                  widget.nameCard.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                  maxLines: 1,overflow: TextOverflow.fade,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 40,
            height: 50,
            child: Icon(
              Icons.event,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }
}
