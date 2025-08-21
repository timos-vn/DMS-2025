import 'package:dms/widget/custom_confirm.dart';
import 'package:dms/widget/input_quantity_shipping_popup.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../../options_input/options_input_screen.dart';
import '../sell_bloc.dart';
import '../sell_event.dart';
import '../sell_state.dart';

class GetItemHolderDetail extends StatefulWidget {

  final String sttRec;

  const GetItemHolderDetail({Key? key, required this.sttRec}) : super(key: key);

  @override
  State<GetItemHolderDetail> createState() => _GetItemHolderDetailState();
}

class _GetItemHolderDetailState extends State<GetItemHolderDetail> {

  late SellBloc _bloc;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = SellBloc(context);
    _bloc.add(GetItemHolderDetailEvent(sttRec: widget.sttRec));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SellBloc,SellState>(
        bloc: _bloc,
        listener: (context,state){

        },
        child: BlocBuilder<SellBloc,SellState>(
          bloc: _bloc,
          builder: (BuildContext context, SellState state){
            return Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is GetListHistoryOrderEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is SellLoading,
                  child: const PendingAction(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context, SellState state) {
    return Column(
      children: [
        buildAppBar(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin Phiếu',
                style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MSP: ${_bloc.masterItemHolderDetail?.sttRec.toString().trim()}',style: TextStyle(fontSize: 12,color: Colors.blueGrey),),
                  Text('Số: ${_bloc.masterItemHolderDetail?.soCt.toString().trim()}',style: TextStyle(fontSize: 12,color: Colors.blueGrey),),
                ],
              ),
              const SizedBox(height: 5,),
              Text('Nhân viên BH: ${_bloc.masterItemHolderDetail?.tenNvbh.toString().trim()}',style: TextStyle(fontSize: 12,color: Colors.blueGrey),),
              const SizedBox(height: 5,),
              Text('Ngày hết hạn: ${_bloc.masterItemHolderDetail?.ngayHetHan.toString().trim()}',style: TextStyle(fontSize: 12,color: Colors.blueGrey),),
              const SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tổng số lượng: ${_bloc.masterItemHolderDetail?.tSoLuong.toString().trim()}',style: TextStyle(fontSize: 12,color: Colors.blueGrey),),
                  Text('${_bloc.masterItemHolderDetail?.statusname.toString().trim()}',style: TextStyle(fontSize: 12,color: Colors.blueGrey),),
                ],
              ),
              const SizedBox(height: 5,),
              Text('Diễn giải: ${_bloc.masterItemHolderDetail?.dienGiai.toString().trim()}',style: TextStyle(fontSize: 12,color: Colors.blueGrey),),
            ],
          ),
        ),
        Divider(),
        Expanded(
          child: ListView.separated(
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  semanticContainer: true,
                  margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5,right: 6,bottom: 5,left: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '[${_bloc.listItemHolderDetail?[index].maVt.toString().trim()}] ${_bloc.listItemHolderDetail?[index].tenVt.toString().toUpperCase()}',
                                style:const TextStyle(color: subColor, fontSize: 12.5, fontWeight: FontWeight.w600,),
                                maxLines: 2,overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(EneftyIcons.card_pos_outline,size: 15,color: Colors.grey),
                                  const SizedBox(width: 7,),
                                  Expanded(
                                    child: Text(  _bloc.listItemHolderDetail?[index].sttRec??'đang cập nhật',
                                      textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 0,right: 0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 35,
                                        padding: const EdgeInsets.only(left: 0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(EneftyIcons.direct_outline,size: 15,color: Colors.grey),
                                                const SizedBox(width: 7,),
                                                Text(
                                                  'Đơn vị: ${  _bloc.listItemHolderDetail?[index].tenDvt}',
                                                  style:const TextStyle(color: Colors.blueGrey,fontSize: 12,),
                                                  textAlign: TextAlign.center,
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
                                          InkWell(
                                              onTap: (){
                                                if(_bloc.masterItemHolderDetail?.status.toString().trim() == "0"){
                                                  double qty = 0;
                                                  qty =   _bloc.listItemHolderDetail?[index].soLuong??0;
                                                  if(qty > 1){
                                                    setState(() {
                                                      qty = qty - 1;
                                                      _bloc.listItemHolderDetail?[index].soLuong = qty;
                                                    });
                                                  }
                                                }
                                              },
                                              child: const SizedBox(width:25,child: Icon(FluentIcons.subtract_12_filled,size: 15,))),
                                          GestureDetector(
                                            onTap: (){
                                              if(_bloc.masterItemHolderDetail?.status.toString().trim() == "0"){
                                                showDialog(
                                                    barrierDismissible: true,
                                                    context: context,
                                                    builder: (context) {
                                                      return const InputQuantityShipping(title: 'Vui lòng nhập số lượng thay đổi',desc: 'Nếu số lượng không thay đổi thì bạn không cần sửa.',);
                                                    }).then((quantity){
                                                  if(quantity != null){
                                                    setState(() {
                                                      _bloc.listItemHolderDetail?[index].soLuong = double.parse(quantity??'0');
                                                    });
                                                  }
                                                });
                                              }
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text("${  _bloc.listItemHolderDetail?[index].soLuong??0} ",
                                                  style: const TextStyle(fontSize: 14, color: Colors.black),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                              onTap: (){
                                                if(_bloc.masterItemHolderDetail?.status.toString().trim() == "0"){
                                                  double qty = 0;
                                                  qty =   _bloc.listItemHolderDetail?[index].soLuong??0;
                                                  setState(() {
                                                    qty = qty + 1;
                                                    _bloc.listItemHolderDetail?[index].soLuong = qty;
                                                  });
                                                }
                                              },
                                              child: const SizedBox(width:25,child: Icon(FluentIcons.add_12_filled,size: 15))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: _bloc.listItemHolderDetail?[index].listCustomer!.isNotEmpty == true,
                                child: SizedBox(
                                  height: 100,
                                  width: double.infinity,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _bloc.listItemHolderDetail?[index].listCustomer?.length??0,
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, indexItemCustomer) {
                                      return GestureDetector(
                                        onTap: (){
                                          if(_bloc.masterItemHolderDetail?.status.toString().trim() == "0"){
                                            showDialog(
                                                barrierDismissible: true,
                                                context: context,
                                                builder: (context) {
                                                  return const InputQuantityShipping(title: 'Vui lòng nhập số lượng thay đổi',desc: 'Nếu số lượng không thay đổi thì bạn không cần sửa.',);
                                                }).then((quantity){
                                              if(quantity != null){
                                                double sl = 0;
                                                double tSL = 0;
                                                tSL = _bloc.listItemHolderDetail?[index].soLuong??0;
                                                _bloc.listItemHolderDetail?[index].listCustomer?.forEach((element) {
                                                  if(element.maKh.toString().trim() != _bloc.listItemHolderDetail?[index].listCustomer?[indexItemCustomer].maKh.toString().trim()){
                                                    sl += element.soLuong??0;
                                                  }
                                                });
                                                if((double.parse(quantity??'0')) <= (tSL - sl)){
                                                  setState(() {
                                                    _bloc.listItemHolderDetail?[index].listCustomer?[indexItemCustomer].soLuong = double.parse(quantity??'0');
                                                  });
                                                  Utils.showCustomToast(context, Icons.check_circle_outline, 'Cập nhật số lượng thành công');
                                                }else{
                                                  Utils.showCustomToast(context, Icons.warning_amber, 'Số lượng vượt quá TSL cho phép');
                                                }
                                              }
                                            });
                                          }
                                        },
                                        child: SizedBox(
                                          height: double.infinity,width: 220,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(color: grey,width: 0.5)
                                            ),
                                            margin: const EdgeInsets.all(8),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${ _bloc.listItemHolderDetail?[index].listCustomer?[indexItemCustomer].tenKh.toString().toUpperCase()}',
                                                    style:const TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.w600,),
                                                    maxLines: 2,overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 3,),
                                                  Row(
                                                    children: [
                                                      const Icon(EneftyIcons.card_pos_outline,size: 15,color: Colors.grey),
                                                      const SizedBox(width: 7,),
                                                      Text(
                                                        '${  _bloc.listItemHolderDetail?[index].listCustomer?[indexItemCustomer].maKh.toString()}',
                                                        style:const TextStyle(color: subColor, fontSize: 10,),
                                                        maxLines: 1,overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 3,),
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 6),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        const Icon(EneftyIcons.shopping_bag_outline,color: Colors.grey,size: 15,),
                                                        const SizedBox(width: 5,),
                                                        Expanded(
                                                          child: Text('Số lượng: ${  _bloc.listItemHolderDetail?[index].listCustomer?[indexItemCustomer].soLuong.toString()??'0'}',
                                                            textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                                            maxLines: 1, overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 5,),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
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
              separatorBuilder: (BuildContext context, int index) => Container(),
              itemCount: _bloc.listItemHolderDetail?.length??0),
        ),
        Visibility(
          visible: _bloc.masterItemHolderDetail?.status.toString().trim() == "0",
          child: Padding(
            padding: const EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 10),
            child: GestureDetector(
              onTap: (){
                if(_bloc.masterItemHolderDetail?.status.toString().trim() == "0"){
                  checkOut();
                }else{
                  Utils.showCustomToast(context, Icons.warning_amber, 'Vui lòng thêm thông tin trước bạn êi');
                }
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
                    Text('Cập nhật thông tin phiếu'
                      ,style: TextStyle(color: Colors.white),),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void checkOut(){
    showDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: const CustomConfirm(
              title: 'Bạn đang tạo phiếu giữ hàng?',
              content: 'Hãy chắc chắn là bạn muốn điều này!',
              type: 0,
              expireDate: true,
            ),
          );
        }).then((value) {
      if(!Utils.isEmpty(value) && value[0] == 'confirm'){
        _bloc.add(CreateItemHolderEvent(
            sttRec: _bloc.masterItemHolderDetail?.sttRec.toString(),
            listItemHolderCreate: _bloc.listItemHolderDetail??[],
            comment: value[2],
            expireDate: Utils.parseStringToDate(value[1], Const.DATE_FORMAT_2).toString()
        ));
      }
    });
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
            onTap: ()=> Navigator.pop(context),
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
          const Expanded(
            child: Center(
              child: Text(
                "Chi tiết lịch sử giữ hàng",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
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
