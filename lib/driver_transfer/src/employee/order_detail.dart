import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:dms/widget/custom_camera.dart';
import 'package:dms/widget/input_quantity_shipping_popup.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../custom_lib/view_only_image.dart';
import '../../../model/database/data_local.dart';
import '../../../model/network/request/order_create_checkin_request.dart';
import '../../../model/network/response/list_status_order_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/utils.dart';
import '../../api/api_utils.dart';
import '../../api/models/order_detail_model.dart';
import '../../helper/constant.dart';

class OrderDetail extends StatefulWidget {
  const OrderDetail({
    key,
    required this.height,
    required this.id,
    this.confirmOrder,
  });

  final double height;
  final String id;
  final Function(OrderDetailModel)? confirmOrder;

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  bool load = true;
  late OrderDetailModel order;

  @override
  void initState() {
    if(DataLocal.listStatus.isNotEmpty == true){
      currentCodecStatus = DataLocal.listStatus[0];
      idStatus = currentCodecStatus.status.toString();
    }
    getData();
    super.initState();
  }

  void getData() {
    getOrderDetail(id: widget.id, token: user.token).then((value) {
      if (mounted) {
        setState(() {
          order = value;
          load = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: widget.height,
        decoration: const BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
        child: load
            ? const Center(child: CupertinoActivityIndicator())
            : Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            setText('Điểm dừng số ${order.poinNumber}', 14,
                                fontWeight: FontWeight.w600, color: gray),
                            const Spacer(),
                            GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Image(image: clearAsset, height: 24))
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image(image: pinAsset, height: 28),
                            const SizedBox(width: 15),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: setText(order.namePoint ?? '', 18,
                                            fontWeight: FontWeight.w600, color: Colors.black)),
                                    order.timeFinished == null
                                        ? const SizedBox()
                                        : setText(
                                            DateFormat('HH:mm').format(order.timeFinished!), 14,
                                            fontWeight: FontWeight.w600, color: green)
                                  ],
                                ),
                                const SizedBox(height: 2),
                                setText(order.strAddress ?? '', 12, color: gray),

                              ],
                            ))
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Image(image: customerAsset, height: 18),
                            const SizedBox(width: 15),
                            setText(order.customerName ?? '', 13, color: Colors.black),
                            const Spacer(),
                            Image(image: phoneAsset, height: 18),
                            const SizedBox(width: 15),
                           Flexible(child: InkWell(
                               onTap: ()async{
                                 if(order.customerPhone.toString().replaceAll('null', '').isNotEmpty){
                                   final Uri launchUri = Uri(
                                     scheme: 'tel',
                                     path: order.customerPhone.toString(),
                                   );
                                   await launchUrl(launchUri);
                                 }
                               },
                               child: setText(order.customerPhone ?? '', 13, color: Colors.black))),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            setText('Nghiệp vụ', 14, color: Colors.blue, fontWeight: FontWeight.w700),
                            InkWell(
                                onTap: (){
                                  if(listFileInvoice.isNotEmpty){
                                    openImageFullScreen(0,listFileInvoice[0]);
                                  }
                                },
                                child: setText('${listFileInvoice.length} Ảnh đính kèm', 14, color: Colors.blue, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Container(
                          decoration:
                              BoxDecoration(border: Border.all(color: const Color(0xff777777))),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                      height: 36,
                                      width: 110,
                                      alignment: Alignment.center,
                                      child: setText('Tổng số lượng', 12, color: Colors.black)),
                                  Container(height: 36, width: 1, color: const Color(0xff777777)),
                                  Expanded(
                                      child: Center(
                                          child: setText('${order.totalQuantity} SP', 12,
                                              color: Colors.black)))
                                ],
                              ),
                              Container(height: 1, color: const Color(0xff777777)),
                              Row(
                                children: [
                                  Container(
                                      height: 36,
                                      width: 110,
                                      alignment: Alignment.center,
                                      child: setText('Tổng thanh toán', 12, color: Colors.black)),
                                  Container(height: 36, width: 1, color: const Color(0xff777777)),
                                  Expanded(
                                      child: Center(
                                          child: setText(
                                              '${formatMoney(order.totalMoney!)} VNĐ', 12,
                                              color: Colors.black)))
                                ],
                              ),
                              Container(height: 1, color: const Color(0xff777777)),
                              Row(
                                children: [
                                  Container(
                                      height: 36,
                                      width: 110,
                                      alignment: Alignment.center,
                                      child: setText('Trạng thái', 12, color: Colors.black)),
                                  Container(height: 36, width: 1, color: const Color(0xff777777)),
                                  Expanded(
                                      child: Center(child: setText(
                                          order.status == "0" ? 'Chờ giao' : order.status == "1" ? 'Đã giao' : order.status == "3" ? "Thất bại" : "Huỷ",
                                          12,
                                          color: (order.status == "3" || order.status == "4") ? Colors.red : order.status == "0" ? gray : Colors.purple)))
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: Container(height: 0.5, color: gray.withOpacity(0.5))),
                            setText('  Danh sách chi tiết  ', 12, color: gray),
                            Expanded(child: Container(height: 0.5, color: gray.withOpacity(0.5)))
                          ],
                        ),
                        const SizedBox(height: 15),
                        ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) => _item(index),
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemCount: order.details!.length)
                      ],
                    ),
                  )),
                  if (order.status == "0" )// && order.employeeId == user.dataUser!.id)
                    GestureDetector(
                      onTap: ()=> confirmShippingEvent(context: context,title: 'Xác nhận phiếu giao vận'),
                      child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        height: 45,
                        decoration:
                            BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: setText('Xác nhận giao hàng', 16,
                            fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    )
                ],
              ),
      ),
    );
  }

  _item(int index) {
    final Detail item = order.details![index];
    return GestureDetector(
      onTap: (){
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              return InputQuantityShipping(quantity: double.parse(item.quantity.toString().replaceAll('null', '').isNotEmpty ? item.quantity.toString() : '0') ,title: 'Vui lòng nhập số lượng thay đổi',desc: 'Nếu số lượng không thay đổi thì bạn không cần sửa.',);
            }).then((values){
          if(values != null){
            for (var element in order.details!) {
              if(element.sttRec0.toString().trim() == item.sttRec0.toString().trim()){
                setState(() {
                  order.details![index].deliveryQuantity = double.parse(values[0]??'0');
                });
              }
            }
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.25), offset: const Offset(0, 3), blurRadius: 4)
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          CachedNetworkImage(
            imageUrl:
                'https://scontent.fhan15-1.fna.fbcdn.net/v/t39.30808-6/457253000_927577462453943_5420400558096620779_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=aa7b47&_nc_ohc=CzZ9Pf-og9kQ7kNvgE6BWxv&_nc_ht=scontent.fhan15-1.fna&oh=00_AYAG211Pt4q-g5k8ck6D1T1e9NSlWL6wJuTJUCABqmyVIg&oe=66D71B91',
            height: 80,
            width: 80,
            errorWidget: (context, url, error) => const Icon(Icons.error),
            placeholder: (context, url) => const CupertinoActivityIndicator(),
          ),
          const SizedBox(width: 15),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              setText(item.productName ?? '', 14, color: Colors.black, fontWeight: FontWeight.bold),
              const SizedBox(height: 2),
              setText('Số lượng: ${item.quantity.toString().replaceAll('null', '0')} ${item.unit}', 12, color: gray),
              const SizedBox(height: 2),
              setText('Số lượng giao: ${item.deliveryQuantity.toString().replaceAll('null', '0')} ${item.unit}', 12, color: gray),
              const SizedBox(height: 2),
              setText('Số lượng đã giao: ${item.deliveredQuantity.toString().replaceAll('null', '0')} ${item.unit}', 12, color: gray),
              const SizedBox(height: 2),
              setText('Số lượng thực giao: ${item.actualQuantity.toString().replaceAll('null', '0')} ${item.unit}', 12, color: gray),
              const SizedBox(height: 2),
              setText('Tổng thanh toán: ${formatMoney(item.total!)} VNĐ', 12, color: gray),
            ],
          ))
        ]),
      ),
    );
  }

  final List<String> codeTypePayment = [
    'Công nợ',
    'Tiền mặt',
    'Chuyển khoản'
  ];

  String currentCodeTypePayment = 'Công nợ';
  ListStatusOrderResponseData currentCodecStatus = ListStatusOrderResponseData();
  int idTypePayment = 2;
  String idStatus = "";
  final _noteController = TextEditingController();
  final FocusNode _noteFocus = FocusNode();
  bool isCheckRequest = false;

  void confirmShippingEvent({
    required BuildContext context,
    required String title
  }){
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (builder){
          return StatefulBuilder(
            builder: (BuildContext context,StateSetter myState){
              return Container(
                height: (MediaQuery.of(context).size.height * 0.80) + (MediaQuery.of(context).viewInsets.bottom/1.5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                ),
                child:  Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0))),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding:const EdgeInsets.only(left: 16,right: 16,top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 5,
                                width: 60,
                                decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.all(Radius.circular(24))
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: ()=>Navigator.pop(context),
                                      child: const SizedBox(
                                          height: 30,
                                          width: 40,
                                          child: Icon(Icons.clear,color: Colors.transparent,)),
                                    ),
                                    Text(title.toString(),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                    GestureDetector(
                                      onTap: ()=>Navigator.pop(context),
                                      child: const SizedBox(
                                          height: 30,
                                          width: 40,
                                          child: Icon(Icons.clear,color: Colors.black,)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 5,),
                                Container(
                                  height: 35,
                                  margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  padding: const EdgeInsets.only(left: 8,right: 20),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(7),),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Expanded(child: Text('Loại thanh toán',
                                          style: TextStyle(fontSize: 13,color: accent)),),
                                      PopupMenuButton<String>(
                                        itemBuilder: (context){
                                          return codeTypePayment.map((e) => PopupMenuItem<String>(
                                            value: e,
                                            child: Text(
                                              e.toString().trim(),
                                              style: const TextStyle(color:subColor,fontSize: 13),
                                            ),
                                          ))
                                              .toList();
                                        },
                                        iconSize: 24, elevation: 16,
                                        onSelected: (data) {
                                          currentCodeTypePayment = data;
                                          if(currentCodeTypePayment.contains('Công nợ')){
                                            idTypePayment = 2;
                                          }else if(currentCodeTypePayment.contains('Tiền mặt')){
                                            idTypePayment = 1;
                                          }else{
                                            idTypePayment = 3;
                                          }
                                          myState(() {});
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              currentCodeTypePayment.toString().trim(),
                                              style: const TextStyle(color:subColor,fontSize: 13),
                                            ),
                                            const Icon(Icons.arrow_drop_down, color: subColor),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataLocal.listStatus.isNotEmpty == true
                                    ?
                                Container(
                                  height: 35,
                                  margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  padding: const EdgeInsets.only(left: 8,right: 20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Expanded(child: Text('Trạng thái phiếu',
                                          style: TextStyle(fontSize: 13,color: accent)),),
                                      PopupMenuButton<ListStatusOrderResponseData>(
                                        itemBuilder: (context){
                                          return DataLocal.listStatus.map((e) => PopupMenuItem<ListStatusOrderResponseData>(
                                            value: e,
                                            child: Text(
                                              e.statusname.toString().trim(),
                                              style: const TextStyle(color:subColor,fontSize: 13),
                                            ),
                                          ))
                                              .toList();
                                        },
                                        iconSize: 24, elevation: 16,
                                        onSelected: (data) {
                                          currentCodecStatus = data;
                                          idStatus = currentCodecStatus.status.toString();
                                          myState(() {
                                          });
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              currentCodecStatus.statusname.toString().trim(),
                                              style: const TextStyle(color:subColor,fontSize: 13),
                                            ),
                                            const Icon(Icons.arrow_drop_down, color: subColor),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                                    :
                                Container(),
                                const SizedBox(height: 7,),
                                Row(
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.location_history,size: 22,color: Colors.blue,),
                                        SizedBox(width: 5,),
                                        Text('Location: ')
                                      ],
                                    ),
                                    Expanded(child: Text(currentAddress.toString().replaceAll('null', ''),style: const TextStyle(color: Colors.blueGrey,fontSize: 13),))
                                  ],
                                ),
                                buildAttachFileInvoice(myState),
                                InkWell(
                                  onTap: (){
                                    myState(() {
                                      isCheckRequest = !isCheckRequest;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 12,horizontal: 12),
                                    height: 45,
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: isCheckRequest,
                                          onChanged: (bool? newValue){
                                            myState(() {
                                              isCheckRequest = newValue ?? false;
                                            });
                                          },
                                        ),
                                        const Text('    Chờ xác nhận     '),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12,),
                                  height: 45,
                                  width: double.infinity,
                                  child:  TextField(
                                    maxLines: 1,
                                    controller: _noteController,
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(borderSide: BorderSide(color: grey, width: 1),),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: grey, width: 1),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: grey, width: 1),
                                      ),
                                      contentPadding: EdgeInsets.only(left: 8,bottom: 15),
                                      hintText: 'Hãy ghi lại điều gì đó của bạn vào đây',
                                      hintStyle: TextStyle(fontStyle: FontStyle.italic,color: Colors.grey,fontSize: 12,),
                                    ),
                                    focusNode: _noteFocus,
                                    keyboardType: TextInputType.text,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(fontSize: 14),
                                    //textInputAction: TextInputAction.none,
                                  ) ,
                                ),
                                const SizedBox(height: 22,),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16,right: 16,top: 30,bottom: 30),
                                  child: GestureDetector(
                                    onTap: (){
                                      if(listFileInvoice.isNotEmpty){
                                        Navigator.pop(context,'Accepted');
                                      }else{
                                        Utils.showCustomToast(context, Icons.warning_amber, 'Vui lòng chụp ảnh trước khi xác nhận phiếu');
                                      }
                                    },
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        height: 45.0,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(18.0),
                                            color: subColor
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Xác nhận',
                                            style: TextStyle(fontSize: 16, color: Colors.white,),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    )),
              );
            },
          );
        }
    ).then((value) {
      if(value != null){
        if(value == 'Accepted'){
          order.xacNhanYN = isCheckRequest == true ? 1 : 0;
          order.statusTicket = int.parse(idStatus);
          order.typePayment = int.parse(idTypePayment.toString());
          order.desc = _noteController.text;
          widget.confirmOrder!(order);
        }
      }
    });
  }

  late Timer _timer = Timer(const Duration(milliseconds: 1), () {});
  int start = 3;

  bool waitingLoad = false;


  buildAttachFileInvoice(StateSetter myState){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: subColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: (){
                getImage(myState);
                // _bloc.add(GetCameraEvent());
              },
              child: Container(padding: const EdgeInsets.only(left: 10,right: 15,top: 8,bottom: 8),
                height: 40,
                width: double.infinity,
                color: Colors.amber.withOpacity(0.4),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ảnh của bạn',style: TextStyle(color: Colors.black,fontSize: 13),),
                    Icon(Icons.add_a_photo_outlined,size: 20,),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16,),
            listFileInvoice.isEmpty ? const SizedBox(height: 100,width: double.infinity,child: Center(child: Text('Hãy chọn thêm hình ảnh của bạn từ thư viện ảnh hoặc từ camera',style: TextStyle(color: Colors.blueGrey,fontSize: 12),textAlign: TextAlign.center,),),) :
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: listFileInvoice.length,
                    itemBuilder: (context,index){
                      return (start > 1 && waitingLoad == true && listFileInvoice.length == (index + 1)) ? const SizedBox(height: 100,width: 100,child: PendingAction()) : GestureDetector(
                        onTap: (){
                          openImageFullScreen(index,listFileInvoice[index]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: 115,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  child: Hero(
                                    tag: index,
                                    /*semanticContainer: true,
                                    margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),*/
                                    child: Image.file(
                                      listFileInvoice[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 6,right: 6,
                                child: InkWell(
                                  onTap: (){
                                    myState(() {
                                      listFileInvoice.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    height: 20,width: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.black.withOpacity(.7),
                                    ),
                                    child: const Icon(Icons.clear,color: Colors.white,size: 12,),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // to open gallery image in full screen
  void openImageFullScreen(final int indexOfImage, File fileImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryImageViewWrapperViewOnly(
          titleGallery: "Zoom Image",
          galleryItemsFile: fileImage,
          viewNetWorkImage: false,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: indexOfImage,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }


  void startTimer(StateSetter myState) {
    const oneSec = Duration(seconds: 1);
    _timer =  Timer.periodic(
      oneSec,
          (Timer timer) {
        if (start == 0) {
          waitingLoad = false;
          myState(() {});
          timer.cancel();
        } else {
          start--;
        }
      },
    );
  }
  List<File> listFileInvoice = [];
  String? currentAddress;
  Position? position2;
  Position? currentLocation;

  Future getImage(StateSetter myState)async {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: const CameraCustomUI(),
    ).then((value) {
      if (value != null && value is XFile) {
        final XFile image = value;
        myState(() {
          start = 2;
          waitingLoad = true;
          startTimer(myState);

          final file = File(image.path);
          listFileInvoice.add(file);
          order.listFile = [file];

          if (currentAddress.toString().isNotEmpty) {
            getUserLocation();
          } else {
            // Xử lý khi không có địa chỉ
          }
        });
      }
    });

  }

  late StreamSubscription<Position> positionStream;

  getUserLocation() async {
    positionStream =
        Utils.getPositionStream().listen((Position position) async{
          List<Placemark> placePoint = await placemarkFromCoordinates(position.latitude,position.longitude);
          String currentAddress1 = "${placePoint[0].name}, ${placePoint[0].thoroughfare}, ${placePoint[0].subAdministrativeArea}, ${placePoint[0].administrativeArea}";
          currentAddress = currentAddress1;
          order.address = currentAddress.toString();
          order.lat = position.latitude.toString();
          order.long = position.longitude.toString();
          currentLocation = position;
          stopListenLocation();
        });
  }

  void stopListenLocation(){
    positionStream.cancel();
  }
}
