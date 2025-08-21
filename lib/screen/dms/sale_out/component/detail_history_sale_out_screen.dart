// ignore_for_file: library_private_types_in_public_api
import 'dart:math';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../../utils/utils.dart';
import '../sale_out_bloc.dart';
import '../sale_out_event.dart';
import '../sale_out_state.dart';


class DetailHistorySaleOutScreen extends StatefulWidget {
  final String sttRec;
  final String invoiceDate;
  final String title;
  const DetailHistorySaleOutScreen({Key? key,required this.sttRec,required this.invoiceDate, required this.title}) : super(key: key);

  @override
  _DetailHistorySaleOutScreenState createState() => _DetailHistorySaleOutScreenState();
}

class _DetailHistorySaleOutScreenState extends State<DetailHistorySaleOutScreen>with TickerProviderStateMixin{

  late SaleOutBloc _bloc;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = SaleOutBloc(context);
    _bloc.add(GetSaleOutPrefs());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaleOutBloc,SaleOutState>(
      listener: (context,state){
        if(state is GetPrefsSuccess){
          _bloc.add(GetDetailHistorySaleOutEvent(sttRec: widget.sttRec,invoiceDate: widget.invoiceDate));
        }
      },
      bloc: _bloc,
      child: BlocBuilder<SaleOutBloc,SaleOutState>(
        bloc: _bloc,
        builder: (BuildContext context,SaleOutState state){
          return Stack(
            children: [
              buildScreen(context, state),
              Visibility(
                visible: state is SaleOutLoading,
                child: const PendingAction(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildScreen(BuildContext context,SaleOutState state){

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildAppBar(),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              width: double.infinity,
              height: 1,
              color: Colors.blueGrey.withOpacity(0.5),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: _bloc.listDetailItemSaleOut.length,
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context, int index){
                  return Card(
                    semanticContainer: true,
                    margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: 5,
                            height: 90,
                            decoration: BoxDecoration(
                                color: Color(Random().nextInt(0xffffffff)).withAlpha(0xff),
                                borderRadius:const BorderRadius.all( Radius.circular(6),)
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding:const EdgeInsets.only(left: 10,right: 3,top: 6,bottom: 5),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    _bloc.listDetailItemSaleOut[index].maVt.toString().trim(),
                                    textAlign: TextAlign.left,
                                    style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5,),
                                  Text(
                                    _bloc.listDetailItemSaleOut[index].tenVt.toString().trim(),
                                    textAlign: TextAlign.left,
                                    style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.blueGrey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'SL: ${_bloc.listDetailItemSaleOut[index].soLuong!.toInt().toString()} (${_bloc.listDetailItemSaleOut[index].dvt.toString().trim()})',
                                          textAlign: TextAlign.left,
                                          style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          'Giá gốc: ${Utils.formatMoneyStringToDouble(_bloc.listDetailItemSaleOut[index].giaSan)} ₫',
                                          textAlign: TextAlign.left,
                                          style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Giá sửa đổi: ${Utils.formatMoneyStringToDouble(_bloc.listDetailItemSaleOut[index].giaNt2)} ₫',
                                          textAlign: TextAlign.left,
                                          style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          'Tổng đơn giá: ${Utils.formatMoneyStringToDouble(_bloc.listDetailItemSaleOut[index].tienNt2)} ₫',
                                          textAlign: TextAlign.left,
                                          style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
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
                  );
                }
            ),
          ),
          const SizedBox(height: 2,),
          buildUpdate()
        ],
      ),
    );
  }

  buildUpdate(){
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text('${NumberFormat(Const.amountFormat).format(_bloc.totalMNProduct??0)} đ',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.normal,decoration: TextDecoration.lineThrough),),
            // const SizedBox(width: 8,),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tổng sản phẩm/\$',style: TextStyle(color: Colors.black,fontSize: 12),),
                Text('${_bloc.totalProduct} sản phẩm / ${Utils.formatMoneyStringToDouble(_bloc.totalMoneyNT2)} ₫',style: const TextStyle(color: subColor,fontWeight: FontWeight.bold),),
              ],
            ),
            const SizedBox(width: 18,),
            GestureDetector(
              onTap: ()=> Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: mainColor
                ),
                child: const Center(
                  child: Text('Xác nhận',style: TextStyle(color: Colors.white),),
                ),
              ),
            ),
          ],
        ),
      ),
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
          gradient:const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [subColor, Color.fromARGB(255, 150, 185, 229)])),
      padding: const EdgeInsets.fromLTRB(5, 35, 12,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: ()=> Navigator.of(context).pop(Const.currencyCode),
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
              child: Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          const SizedBox(
            width: 40,
            height: 50,
            child: Icon(
              Icons.update,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }
}
