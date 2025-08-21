import 'dart:convert';

import 'package:dms/utils/const.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/network/response/get_info_card_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/images.dart';
import '../../../utils/utils.dart';
import '../../filter/filter_page.dart';
import '../qr_code_bloc.dart';
import '../qr_code_event.dart';
import '../qr_code_sate.dart';

class ScannerPanelWidget extends StatefulWidget {
  final ScrollController scrollController;
  final List<ListItem> listItemCard;
  final RuleActionInfoCard ruleActionInformationCard;
  final MasterInfoCard masterInformationCard;
  final Function confirmInformationCard;
  final String keyFunction;
  final QRCodeBloc qrCodeBloc;

  const ScannerPanelWidget(
      { required this.masterInformationCard, required this.ruleActionInformationCard,
        required this.listItemCard, required this.scrollController,required this.qrCodeBloc,
        required this.confirmInformationCard, required this.keyFunction ,super.key});

  @override
  State<ScannerPanelWidget> createState() => _ScannerPanelWidgetState();
}

class _ScannerPanelWidgetState extends State<ScannerPanelWidget>{
  String currentDecodingTypeName = 'default';
  Encoding? currentDecodingType;
  String codeTransfer = '';String nameTransfer = '';


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<QRCodeBloc,QRCodeState>(
        bloc: widget.qrCodeBloc,
        listener: (context,state){
          if(state is CreateDeliverySuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Tạo phiếu thành công');
            widget.confirmInformationCard();
          }
        },
        child: BlocBuilder<QRCodeBloc,QRCodeState>(
            bloc: widget.qrCodeBloc,
            builder: (BuildContext context,QRCodeState state){
              return  buildBody(context, state);
            }
        ),
      ),
    );
  }

  buildBody(BuildContext context,QRCodeState state){
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: ListView(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.all(Radius.circular(12.0))),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Danh sách sản phẩm',
                      style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(
                          '${widget.ruleActionInformationCard.statusname.toString().trim()}  ',
                          style: const TextStyle(fontSize: 12.0,color: subColor),
                        ),Text(
                          widget.keyFunction.toString(),
                          style: const TextStyle(fontSize: 12.0,color: subColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ListView.builder(
                      key: Key(currentDecodingTypeName),
                      shrinkWrap: true,
                      physics:   const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 10),
                      itemBuilder: (_, index) {
                        return Card(
                          semanticContainer: true,
                          margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                          child: Row(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: const BoxDecoration(
                                    borderRadius:BorderRadius.all( Radius.circular(6),)
                                ),
                                child:const Icon(EneftyIcons.image_outline,size: 50,weight: 0.6,),
                                //Image.network('https://i.pinimg.com/564x/49/77/91/4977919321475b060fcdd89504cee992.jpg',fit: BoxFit.contain,),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 5,right: 6,bottom: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '[${widget.listItemCard[index].maVt.toString().trim()}] ${widget.listItemCard[index].tenVt.toString().toUpperCase()}',
                                        style:const TextStyle(color: subColor, fontSize: 12.5, fontWeight: FontWeight.w600,),
                                        maxLines: 2,overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5,),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Icon(FluentIcons.cart_16_regular,size: 20,),
                                          const SizedBox(width: 2,),
                                          Expanded(
                                            child: Text(widget.listItemCard[index].tenKho??'Kho đang cập nhật',
                                              textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                              maxLines: 1, overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            height: 13,
                                            width: 1.5,
                                            color: Colors.grey,
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 0),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'Loại: ${widget.listItemCard[index].cheBien == 1 ? 'Chế biến' : widget.listItemCard[index].sanXuat == 1 ? 'Sản xuất' :'Thường'}',
                                                  style:const TextStyle(color: Colors.blueGrey,fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 13,
                                            width: 1.5,
                                            color: Colors.grey,
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 0),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'Đơn vị: ${widget.listItemCard[index].tenDvt}',
                                                  style:const TextStyle(color: Colors.blueGrey,fontSize: 12,),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5,right: 0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 35,
                                                padding: const EdgeInsets.only(left: 5),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(16),
                                                  color: Colors.white,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '\$ ${Utils.formatMoneyStringToDouble(widget.listItemCard[index].tien??0)}',
                                                          textAlign: TextAlign.left,
                                                          style: const TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
                                                        ),
                                                      ],
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        color: Colors.transparent,
                                                        width: 40,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 35,
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(16),
                                                  color: grey_100
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  const SizedBox(width:25,child: Icon(FluentIcons.subtract_12_filled,size: 15,)),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text("${widget.listItemCard[index].soLuong?.toInt()??0} ",
                                                        style: const TextStyle(fontSize: 14, color: Colors.black),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width:25,child: Icon(FluentIcons.add_12_filled,size: 15)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      itemCount: widget.listItemCard.length),
                  const SizedBox(
                    height: 5.0,
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(top: 5,bottom: 15),
                    child: Container(
                      color: grey_100,
                      child: Column(
                        children: [
                          const SizedBox(height: 5,),
                          Container(
                            height: 100,
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(8, 0, 8,0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const CircleAvatar(
                                  radius: 38,
                                  backgroundImage: AssetImage(avatarStore),
                                  backgroundColor: Colors.transparent,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Flexible(child: Text('[${widget.masterInformationCard.maKh.toString().trim()}]  ${widget.masterInformationCard.tenKh.toString().trim()} 123 123 12',
                                          style: const TextStyle(color: subColor,fontWeight: FontWeight.bold,fontSize: 13),maxLines: 2,overflow: TextOverflow.ellipsis,),),
                                        const SizedBox(height: 5,),
                                        Row(
                                          children: [
                                            const Icon(EneftyIcons.card_pos_outline,color: Colors.blueGrey,size: 18,),
                                            const SizedBox(width: 8,),
                                            Text(
                                              '${widget.masterInformationCard.sttRec}'
                                              ,style: const TextStyle(color: Color(0xff0162c1)  ,fontWeight: FontWeight.w700,fontSize: 11),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                          ],
                                        ),
                                        const SizedBox(height: 5,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(EneftyIcons.calendar_3_outline,color: Colors.blueGrey,size: 18,),
                                                const SizedBox(width: 8,),
                                                Text(widget.masterInformationCard.ngayCt.toString().replaceAll('null', '').isNotEmpty ?
                                                Utils.parseDateTToString(widget.masterInformationCard.ngayCt.toString(), Const.DATE_FORMAT_1) : ''
                                                  ,style: const TextStyle(color: Color(0xff0162c1)  ,fontWeight: FontWeight.w700,fontSize: 11),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 4),
                                              child: Text('${widget.masterInformationCard.statusname}',
                                                  style: const TextStyle(color: Color(0xff0162c1)  ,fontWeight: FontWeight.w700,fontSize: 11)),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(EneftyIcons.truck_fast_outline),
                                      const SizedBox(width: 10,),
                                      Text('Vận chuyển: ${widget.masterInformationCard.tenHtvc.toString().trim()}',
                                        style: const TextStyle(fontWeight: FontWeight.normal,color: subColor),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: Const.allowChangeTransfer == true,
                                  child: InkWell(
                                    onTap: (){
                                      if(Const.allowChangeTransfer == true){
                                        showDialog(
                                            context: context,
                                            builder: (context) => const FilterScreen(controller: 'dmnvbh_lookup',
                                              listItem: null,show: false,)).then((value){
                                          if(value != null){
                                            setState(() {
                                              codeTransfer = value[0];
                                              nameTransfer = value[1];
                                            });
                                          }
                                        });
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          nameTransfer.isNotEmpty ? 'Tài xế: $nameTransfer' : 'Tài xế của bạn',
                                          style: const TextStyle(color: subColor),
                                        ),
                                        const SizedBox(width: 5,),
                                        const Icon(EneftyIcons.search_normal_outline,size: 15,color: accent,),
                                        const SizedBox(width: 5,),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.grey),
                          // customView(EneftyIcons.truck_fast_outline, 'Hình thức vận chuyển: ${widget.masterInformationCard.tenHtvc.toString().trim()}', true, FontWeight.normal),
                          customView(EneftyIcons.note_2_outline, 'Ghi chú: ${widget.masterInformationCard.dienGiai.toString().trim()}', false, FontWeight.normal),
                        ],
                      ),
                    ),
                  ),
                  customPayment(title: 'Code',value: '${widget.masterInformationCard.soCt}'),
                  customPayment(title: 'Tổng số lượng',value: '${widget.masterInformationCard.tSoLuong}'),
                  customPayment(title: 'Tổng thanh toán',value: '\$${Utils.formatMoneyStringToDouble(widget.masterInformationCard.tTT??0)}'.toString().trim()),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20,right: 20,top: 5,bottom: MediaQuery.of(context).size.height * .10),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                              onTap: (){
                                widget.confirmInformationCard();
                              },
                              child: Container(
                                height: 48,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(24)
                                ),
                                child: const Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                    'Huỷ bỏ',style: TextStyle(color: Colors.white),),
                                  ],
                                ),
                              )
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          child: GestureDetector(
                              onTap: (){
                                if( widget.ruleActionInformationCard.status  != 1){
                                  if(widget.keyFunction.toString().contains('#6')){
                                    widget.qrCodeBloc.add(CreateDeliveryEvent(sttRec: widget.masterInformationCard.sttRec.toString(),licensePlates: '', codeTransfer: codeTransfer));
                                  }else{
                                    widget.confirmInformationCard();
                                  }
                                }
                                else{
                                  Utils.showCustomToast(context, Icons.check_circle_outline, 'Trạng thái phiếu đang là xem');
                                  widget.confirmInformationCard();
                                }
                              },
                              child: Container(
                                height: 48,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: mainColor,
                                    borderRadius: BorderRadius.circular(24)
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text( widget.ruleActionInformationCard.status != 1 ? 'Tạo phiếu giao hàng' :
                                    'Xác nhận',style: const TextStyle(color: Colors.white),),
                                  ],
                                ),
                              )
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
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
}
