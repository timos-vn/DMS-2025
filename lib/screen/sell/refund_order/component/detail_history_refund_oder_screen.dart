// ignore_for_file: library_private_types_in_public_api

import 'package:dms/utils/utils.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../themes/colors.dart';
import '../refund_order_bloc.dart';
import '../refund_order_event.dart';
import '../refund_order_state.dart';


class DetailHistoryRefundOrderScreen extends StatefulWidget {
  final String sttRec;
  final String invoiceDate;
  final String title;
  final String codeTax;
  final double percentTax;

  const DetailHistoryRefundOrderScreen({Key? key,required this.sttRec, required this.invoiceDate, required this.title, required this.codeTax, required this.percentTax}) : super(key: key);

  @override
  _DetailHistoryRefundOrderScreenState createState() => _DetailHistoryRefundOrderScreenState();
}

class _DetailHistoryRefundOrderScreenState extends State<DetailHistoryRefundOrderScreen> {

  late RefundOrderBloc _bloc;

  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  bool _hasReachedMax = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _bloc = RefundOrderBloc(context);
    _bloc.add(GetPrefsRefundOrderEvent(calculator: false));
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(GetDetailHistoryRefundOrderEvent(isLoadMore:true,sctRec:widget.sttRec,invoiceDate: widget.invoiceDate));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: subColor,
      //   onPressed: ()async{
      //     // pushNewScreen(context, screen: RefundOrderScreen(detailCustomer: widget.detailCustomer,codeTax: widget.codeTax,percentTax: widget.percentTax,),withNavBar: false);
      //   },
      //   child: const Icon(MdiIcons.skipNextCircleOutline,color: Colors.white,),
      // ),
      body: BlocListener<RefundOrderBloc,RefundOrderState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsRefundOrderSuccess){
            _bloc.add(GetDetailHistoryRefundOrderEvent(sctRec:widget.sttRec,invoiceDate: widget.invoiceDate));
          }
        },
        child: BlocBuilder<RefundOrderBloc,RefundOrderState>(
          bloc: _bloc,
          builder: (BuildContext context, RefundOrderState state){
            return Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is GetListDetailOrderCompletedEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is RefundOrderLoading,
                  child: const PendingAction(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,RefundOrderState state){
    int length = _bloc.listDetailHistoryRefundOrder.length;
    if (state is GetListDetailHistoryRefundOrderSuccess) {
      _hasReachedMax = length < _bloc.currentPage * 20;
    }
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          Expanded(
            child: RefreshIndicator(
              color: mainColor,
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 2));
                _bloc.listDetailHistoryRefundOrder.clear();
                _bloc.add(GetDetailHistoryRefundOrderEvent(sctRec:widget.sttRec,invoiceDate: widget.invoiceDate));
              },
              child: SizedBox(
                height: double.infinity,width: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        controller: _scrollController,
                        padding: EdgeInsets.zero,
                        separatorBuilder: (BuildContext context, int index)=>Container(),
                        itemBuilder: (BuildContext context, int index){
                          return index >= length ?
                          Container(
                            height: 100.0,
                            color: white,
                            child: const PendingAction(),
                          )
                              :
                          GestureDetector(
                            onTap: (){
                            },
                            child: Card(
                              semanticContainer: true,
                              margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                                child: Container(
                                  padding: const EdgeInsets.only(left: 10,right: 3,top: 6,bottom: 5),
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: '[${_bloc.listDetailHistoryRefundOrder[index].maVt.toString().trim()}] ',
                                                      style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                                          0xff555a55)),
                                                    ),
                                                    TextSpan(
                                                      text: _bloc.listDetailHistoryRefundOrder[index].tenVt.toString().trim(),
                                                      style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                                    ),
                                                    TextSpan(
                                                      text: _bloc.listDetailHistoryRefundOrder[index].tlCk! > 0 ? '  (-${_bloc.listDetailHistoryRefundOrder[index].tlCk!.toDouble()} %)'
                                                          :
                                                      '',
                                                      style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 11, color: Colors.red),
                                                    ),
                                                  ],
                                                ),
                                              )
                                          ),
                                          const SizedBox(width: 10,),
                                          (_bloc.listDetailHistoryRefundOrder[index].kmYn == 0) ?
                                          Column(
                                            children: [
                                              Text(
                                                ((_bloc.listDetailHistoryRefundOrder[index].giaNt2??0))
                                                    == 0 ? 'Giá đang cập nhật' : '${Utils.formatMoneyStringToDouble(_bloc.listDetailHistoryRefundOrder[index].giaNt2??0)} ₫'
                                                ,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(color:
                                                ((_bloc.listDetailHistoryRefundOrder[index].ckNt??0)) == 0
                                                    ?
                                                Colors.grey : Colors.red, fontSize: 10,
                                                    decoration: ((_bloc.listDetailHistoryRefundOrder[index].ckNt??0)) == 0 ? TextDecoration.none : TextDecoration.lineThrough),
                                              ) ,
                                              const SizedBox(height: 3,),
                                              Visibility(
                                                visible: _bloc.listDetailHistoryRefundOrder[index].ckNt! > 0,
                                                child: Text(
                                                  '${Utils.formatMoneyStringToDouble((_bloc.listDetailHistoryRefundOrder[index].giaNt2! - (_bloc.listDetailHistoryRefundOrder[index].ckNt!/_bloc.listDetailHistoryRefundOrder[index].soLuong!)))} ₫',
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(color: Color(
                                                      0xff067902), fontSize: 13,fontWeight: FontWeight.w700),
                                                ),
                                              ),
                                            ],
                                          )
                                              :
                                          Padding(
                                            padding: const EdgeInsets.only(left: 16,right: 30),
                                            child: Icon(
                                              MdiIcons.gift,
                                              size:18,
                                              color: _bloc.listDetailHistoryRefundOrder[index].kmYn == 1 ? const Color(0xFF0EBB00) : Colors.transparent,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Mã kho: ${(_bloc.listDetailHistoryRefundOrder[index].tenKho.toString().isNotEmpty && _bloc.listDetailHistoryRefundOrder[index].tenKho.toString() != 'null') ? _bloc.listDetailHistoryRefundOrder[index].tenKho : 'Đang cập nhật'}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color: Colors.red),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 20,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                _bloc.listDetailHistoryRefundOrder[index].kmYn == 0 ?'KH đặt:' : 'KL tặng:',
                                                style: TextStyle(
                                                    color: _bloc.listDetailHistoryRefundOrder[index].kmYn == 0 ? Colors.black.withOpacity(0.7) : const Color(0xFF0EBB00), fontSize: 11),
                                                textAlign: TextAlign.left,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text("${_bloc.listDetailHistoryRefundOrder[index].soLuong?.toInt()??0} (${_bloc.listDetailHistoryRefundOrder[index].dvt.toString().trim()})",
                                                style:TextStyle(color: _bloc.listDetailHistoryRefundOrder[index].kmYn == 0 ? blue : const Color(0xFF0EBB00), fontSize: 12),
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
                            ),
                          );
                        },
                        itemCount: length == 0 ? length : _hasReachedMax ? length : length + 1,
                      ),
                    ),
                    const SizedBox(height: 15,)
                  ],
                ),
              ),
            ),
          )
        ],
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
          Expanded(
            child: Center(
              child: Text(
                widget.title.toString().trim(),
                style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
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
