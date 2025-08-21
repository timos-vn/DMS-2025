// ignore_for_file: library_private_types_in_public_api

import 'package:dms/model/database/data_local.dart';

import 'package:dms/utils/utils.dart';
import 'package:dms/widget/input_quantity_popup_refund_order.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../model/network/response/detail_customer_response.dart';
import '../../../../themes/colors.dart';
import '../refund_order_bloc.dart';
import '../refund_order_event.dart';
import '../refund_order_screen.dart';
import '../refund_order_state.dart';


class DetailOrderCompletedScreen extends StatefulWidget {
  final String sct;
  final String sttRec;
  final String invoiceDate;
  final String title;
  final String codeTax;
  final double percentTax;
  final String codeSell;
  final DetailCustomerResponseData detailCustomer;
  final String tk;

  const DetailOrderCompletedScreen({Key? key,required this.sct,required this.sttRec, required this.invoiceDate,
    required this.title, required this.codeTax, required this.percentTax,
    required this.detailCustomer, required this.codeSell, required this.tk}) : super(key: key);

  @override
  _DetailOrderCompletedScreenState createState() => _DetailOrderCompletedScreenState();
}

class _DetailOrderCompletedScreenState extends State<DetailOrderCompletedScreen> {

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
        _bloc.add(GetDetailRefundOrderEvent(isLoadMore:true,sctRec:widget.sttRec,invoiceDate: widget.invoiceDate,allowAddOrDeleteInList: false, addOrDeleteInList: false));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: subColor,
        onPressed: ()async{
          PersistentNavBarNavigator.pushNewScreen(context, screen: RefundOrderScreen(
            detailCustomer: widget.detailCustomer,
            codeTax: widget.codeTax,
            percentTax: widget.percentTax,
            tk: DataLocal.tkRefundOrder,
          ),withNavBar: false).then((value) => Navigator.pop(context));
        },
        child: Icon(MdiIcons.skipNextCircleOutline,color: Colors.white,),
      ),
      body: BlocListener<RefundOrderBloc,RefundOrderState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsRefundOrderSuccess){
            _bloc.add(GetDetailRefundOrderEvent(sctRec:widget.sttRec,invoiceDate: widget.invoiceDate,allowAddOrDeleteInList: false, addOrDeleteInList: false));
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
    int length = _bloc.listDetailOrderCompleted.length;
    if (state is GetListDetailOrderCompletedSuccess) {
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
                _bloc.listDetailOrderCompleted.clear();
                _bloc.add(GetDetailRefundOrderEvent(sctRec:widget.sttRec,invoiceDate: widget.invoiceDate,allowAddOrDeleteInList: false, addOrDeleteInList: false));
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
                                setState(() {
                                  if(_bloc.listDetailOrderCompleted[index].isMark == false){
                                    if(_bloc.listDetailOrderCompleted[index].soLuong! > _bloc.listDetailOrderCompleted[index].slTra!){
                                      showDialog(
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (context) {
                                            return InputQuantityPopupRefundOrder(
                                              title: 'Bạn chỉ được phép trả tối đa ${_bloc.listDetailOrderCompleted[index].slCl!.toInt()} SP',
                                              quantity: _bloc.listDetailOrderCompleted[index].slCl??0,
                                            );
                                          }).then((value){
                                        if(double.parse(value[0].toString()) > 0){
                                          _bloc.listDetailOrderCompleted[index].isMark = true;
                                          if(widget.codeTax.isNotEmpty && widget.codeTax != 'null' && widget.codeTax != '' && DataLocal.lockRefundOrder == false){
                                            DataLocal.lockRefundOrder = true;
                                            print('click');
                                            DataLocal.sct = widget.sct.toString();
                                            DataLocal.codeLockRefundOrder = widget.sttRec.toString().trim();
                                            DataLocal.codeTaxLockRefundOrder = widget.codeTax.toString().trim();
                                            DataLocal.percentTaxLockRefundOrder = widget.percentTax;
                                            DataLocal.codeSellLockRefundOrder = widget.codeSell.toString();
                                            DataLocal.tkRefundOrder = widget.tk.toString();
                                          }
                                          _bloc.listDetailOrderCompleted[index].slSt = value[0];
                                          DataLocal.listDetailOrderCompletedSave.add(_bloc.listDetailOrderCompleted[index]);
                                          Utils.showCustomToast(context, Icons.check_circle_outline, 'Thêm vào phiếu trả lại thành công');
                                          setState(() {});
                                        }
                                      });
                                    }else{
                                      Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Đã hết hàng để trả lại');
                                    }
                                  }
                                  else{
                                    _bloc.listDetailOrderCompleted[index].isMark = false;
                                    _bloc.listDetailOrderCompleted[index].slSt = 0;
                                    if(DataLocal.listDetailOrderCompletedSave.isNotEmpty){
                                      DataLocal.listDetailOrderCompletedSave.removeWhere((element) => (element.sttRec.toString().trim() == _bloc.listDetailOrderCompleted[index].sttRec.toString().trim() && element.sttRec0.toString().trim() == _bloc.listDetailOrderCompleted[index].sttRec0.toString().trim()));
                                    }
                                    if(DataLocal.listDetailOrderCompletedSave.isEmpty && DataLocal.lockRefundOrder == true){
                                      DataLocal.lockRefundOrder = false;
                                      print('Unclick');
                                      DataLocal.sct = '';
                                      DataLocal.codeLockRefundOrder = '';
                                      DataLocal.codeTaxLockRefundOrder = '';
                                      DataLocal.codeSellLockRefundOrder = '';
                                      DataLocal.tkRefundOrder = '';
                                      DataLocal.percentTaxLockRefundOrder = 0;
                                    }
                                    Utils.showCustomToast(context, Icons.check_circle_outline, 'Đã huỷ hàng trả lại');
                                  }
                                });
                              },
                              child: Card(
                                semanticContainer: true,
                                margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      SizedBox(
                                        height: 10,width: 40,
                                        child: Transform.scale(
                                          scale: 1,
                                          alignment: Alignment.topLeft,
                                          child: Checkbox(
                                            value: _bloc.listDetailOrderCompleted[index].isMark,
                                            onChanged: (b){
                                              // if(_bloc.listDetailOrderCompleted[index].isMark == false){
                                              //   showDialog(
                                              //       barrierDismissible: true,
                                              //       context: context,
                                              //       builder: (context) {
                                              //         return InputQuantityPopupRefundOrder(
                                              //           title: 'Bạn chỉ được phép trả tối đa ${_bloc.listDetailOrderCompleted[index].slCl!.toInt()} SP',
                                              //           quantity: _bloc.listDetailOrderCompleted[index].slCl??0,
                                              //         );
                                              //       }).then((value){
                                              //     if(double.parse(value[0].toString()) > 0){
                                              //       _bloc.listDetailOrderCompleted[index].isMark = true;
                                              //       if(widget.codeTax.isNotEmpty && widget.codeTax != 'null' && widget.codeTax != '' && DataLocal.lockRefundOrder == false){
                                              //         DataLocal.lockRefundOrder = true;
                                              //         DataLocal.codeLockRefundOrder = widget.sttRec.toString().trim();
                                              //         DataLocal.codeTaxLockRefundOrder = widget.codeTax.toString().trim();
                                              //         DataLocal.percentTaxLockRefundOrder = widget.percentTax;
                                              //         DataLocal.codeSellLockRefundOrder = widget.codeSell.toString();
                                              //       }
                                              //       _bloc.listDetailOrderCompleted[index].slSt = value[0];
                                              //       DataLocal.listDetailOrderCompletedSave.add(_bloc.listDetailOrderCompleted[index]);
                                              //       Utils.showCustomToast(context, Icons.check_circle_outline, 'Thêm vào phiếu trả lại thành công');
                                              //       setState(() {});
                                              //     }
                                              //   });
                                              // }
                                              // else{
                                              //   _bloc.listDetailOrderCompleted[index].isMark = false;
                                              //   _bloc.listDetailOrderCompleted[index].slSt = 0;
                                              //   if(DataLocal.listDetailOrderCompletedSave.isNotEmpty){
                                              //     DataLocal.listDetailOrderCompletedSave.removeWhere((element) => (element.sttRec.toString().trim() == _bloc.listDetailOrderCompleted[index].sttRec.toString().trim() && element.sttRec0.toString().trim() == _bloc.listDetailOrderCompleted[index].sttRec0.toString().trim()));
                                              //   }
                                              //   if(DataLocal.listDetailOrderCompletedSave.isEmpty && DataLocal.lockRefundOrder == true){
                                              //     DataLocal.lockRefundOrder = false;
                                              //     DataLocal.codeLockRefundOrder = '';
                                              //     DataLocal.codeTaxLockRefundOrder = '';
                                              //     DataLocal.percentTaxLockRefundOrder = 0;
                                              //     DataLocal.codeSellLockRefundOrder = '';
                                              //   }
                                              //   Utils.showCustomToast(context, Icons.check_circle_outline, 'Đã huỷ hàng trả lại');
                                              // }
                                            },
                                            activeColor: mainColor,
                                            hoverColor: Colors.orange,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(4)
                                            ),
                                            side: MaterialStateBorderSide.resolveWith((states){
                                              if(states.contains(MaterialState.pressed)){
                                                return BorderSide(color: mainColor);
                                              }else{
                                                return BorderSide(color: mainColor);
                                              }
                                            }),
                                          ),
                                        ),
                                      ),
                                      Expanded(
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
                                                              text: '[${_bloc.listDetailOrderCompleted[index].maVt.toString().trim()}] ',
                                                              style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                                                  0xff555a55)),
                                                            ),
                                                            TextSpan(
                                                              text: _bloc.listDetailOrderCompleted[index].tenVt.toString().trim(),
                                                              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                                            ),
                                                            TextSpan(
                                                              text: _bloc.listDetailOrderCompleted[index].tlCk! > 0 ? '  (-${_bloc.listDetailOrderCompleted[index].tlCk!.toDouble()} %)'
                                                                  :
                                                              '',
                                                              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 11, color: Colors.red),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                  ),
                                                  const SizedBox(width: 10,),
                                                  (_bloc.listDetailOrderCompleted[index].kmYn == 0) ?
                                                  Column(
                                                    children: [
                                                      Text(
                                                        ((_bloc.listDetailOrderCompleted[index].giaNt2??0))
                                                            == 0 ? 'Giá đang cập nhật' : '${Utils.formatMoneyStringToDouble(_bloc.listDetailOrderCompleted[index].giaNt2??0)} ₫'
                                                        ,
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(color:
                                                        ((_bloc.listDetailOrderCompleted[index].ckNt??0)) == 0
                                                            ?
                                                        Colors.grey : Colors.red, fontSize: 10,
                                                            decoration: ((_bloc.listDetailOrderCompleted[index].ckNt??0)) == 0 ? TextDecoration.none : TextDecoration.lineThrough),
                                                      ) ,
                                                      const SizedBox(height: 3,),
                                                      Visibility(
                                                        visible: _bloc.listDetailOrderCompleted[index].ckNt! > 0,
                                                        child: Text(
                                                          '${Utils.formatMoneyStringToDouble((_bloc.listDetailOrderCompleted[index].giaNt2! - (_bloc.listDetailOrderCompleted[index].ckNt!/_bloc.listDetailOrderCompleted[index].soLuong!)))} ₫',
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
                                                      color: _bloc.listDetailOrderCompleted[index].kmYn == 1 ? const Color(0xFF0EBB00) : Colors.transparent,
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
                                                      'Mã kho: ${(_bloc.listDetailOrderCompleted[index].nameStore.toString().isNotEmpty && _bloc.listDetailOrderCompleted[index].nameStore.toString() != 'null') ? _bloc.listDetailOrderCompleted[index].nameStore : 'Đang cập nhật'}',
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
                                                        _bloc.listDetailOrderCompleted[index].kmYn == 0 ?'KH đặt:' : 'KL tặng:',
                                                        style: TextStyle(
                                                            color: _bloc.listDetailOrderCompleted[index].kmYn == 0 ? Colors.black.withOpacity(0.7) : const Color(0xFF0EBB00), fontSize: 11),
                                                        textAlign: TextAlign.left,
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text("${_bloc.listDetailOrderCompleted[index].soLuong?.toInt()??0} (${_bloc.listDetailOrderCompleted[index].dvt.toString().trim()})",
                                                        style:TextStyle(color: _bloc.listDetailOrderCompleted[index].kmYn == 0 ? blue : const Color(0xFF0EBB00), fontSize: 12),
                                                        textAlign: TextAlign.left,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 3,),
                                              const Divider(),
                                              const SizedBox(height: 3,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'SL sẽ trả:',
                                                          style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 12),
                                                          textAlign: TextAlign.left,
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text("${_bloc.listDetailOrderCompleted[index].slSt.toInt()} (${_bloc.listDetailOrderCompleted[index].dvt.toString().trim()})",
                                                          style:const TextStyle(color: blue, fontSize: 12),
                                                          textAlign: TextAlign.left,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 20,),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'SL đã trả  :',
                                                        style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 12),
                                                        textAlign: TextAlign.left,
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text("${_bloc.listDetailOrderCompleted[index].slTra?.toInt()??0} (${_bloc.listDetailOrderCompleted[index].dvt.toString().trim()})",
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
