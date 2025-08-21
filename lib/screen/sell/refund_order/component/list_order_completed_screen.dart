// ignore_for_file: library_private_types_in_public_api

import 'package:dms/model/database/data_local.dart';

import 'package:dms/utils/utils.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../model/network/response/detail_customer_response.dart';
import '../../../../model/network/response/get_list_refund_order_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../options_input/options_input_screen.dart';
import '../refund_order_bloc.dart';
import '../refund_order_event.dart';
import '../refund_order_screen.dart';
import '../refund_order_state.dart';
import 'detail_order_completed_screen.dart';


class OrderCompletedScreen extends StatefulWidget {
  final DetailCustomerResponseData detailCustomer;

  const OrderCompletedScreen({Key? key,required this.detailCustomer}) : super(key: key);

  @override
  _OrderCompletedScreenState createState() => _OrderCompletedScreenState();
}

class _OrderCompletedScreenState extends State<OrderCompletedScreen> {

  late RefundOrderBloc _bloc;

  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  bool _hasReachedMax = true;

  String dateFrom = Utils.parseDateToString(DateTime.now().add(const Duration(days: -7)), Const.DATE_SV_FORMAT_2);
  String dateTo = Utils.parseDateToString(DateTime.now(), Const.DATE_SV_FORMAT_2);


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
        _bloc.add(GetListRefundOrderEvent(isLoadMore:true,dateFrom:dateFrom.toString(),dateTo: dateTo,idCustomer: widget.detailCustomer.customerCode.toString()));
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
            codeTax: DataLocal.codeTaxLockRefundOrder,
            percentTax: DataLocal.percentTaxLockRefundOrder,
            tk: DataLocal.tkRefundOrder,
            ),withNavBar: false).then((value){
            _bloc.listRefundOrder.clear();
            _bloc.add(GetListRefundOrderEvent(dateFrom:dateFrom.toString(),dateTo: dateTo,idCustomer: widget.detailCustomer.customerCode.toString()));
          });
        },
        child: Icon(MdiIcons.skipNextCircleOutline,color: Colors.white,),
      ),
      body: BlocListener<RefundOrderBloc,RefundOrderState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsRefundOrderSuccess){
            _bloc.add(GetListRefundOrderEvent(dateFrom:dateFrom.toString(),dateTo: dateTo,idCustomer: widget.detailCustomer.customerCode.toString()));
          }else if(state is GetListDetailOrderCompletedSuccess){
            if(DataLocal.listDetailOrderCompletedSave.isEmpty){
              DataLocal.lockRefundOrder = false;
              DataLocal.sct = '';
              DataLocal.codeLockRefundOrder = '';
              DataLocal.codeTaxLockRefundOrder = '';
              DataLocal.codeSellLockRefundOrder = '';
              DataLocal.tkRefundOrder = '';
              DataLocal.percentTaxLockRefundOrder = 0;
            }
            _bloc.add(GetListRefundOrderEvent(dateFrom:dateFrom.toString(),dateTo: dateTo,idCustomer: widget.detailCustomer.customerCode.toString()));
          }
        },
        child: BlocBuilder<RefundOrderBloc,RefundOrderState>(
          bloc: _bloc,
          builder: (BuildContext context, RefundOrderState state){
            return Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is GetListRefundOrderEmpty,
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
    int length = _bloc.listRefundOrder.length;
    if (state is GetListRefundOrderSuccess) {
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
                _bloc.listRefundOrder.clear();
                _bloc.add(GetListRefundOrderEvent(dateFrom:dateFrom.toString(),dateTo: dateTo,idCustomer: widget.detailCustomer.customerCode.toString()));
              },
              child: SizedBox(
                height: double.infinity,width: double.infinity,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10,bottom: 10),
                      child: Row(
                        children: [
                          const Expanded(child: Divider()),
                          const SizedBox(width: 4,),
                          Text('Danh sách từ $dateFrom - $dateTo' ,style: const TextStyle(color:Colors.blueGrey,fontSize: 12),),
                          const SizedBox(width: 4,),
                          const Expanded(child: Divider()),
                        ],
                      ),
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
                                if(DataLocal.codeSellLockRefundOrder.toString().trim() == ''){
                                  checkLogic(context,_bloc.listRefundOrder[index]);
                                }else if(DataLocal.codeSellLockRefundOrder.toString().trim() == _bloc.listRefundOrder[index].codeSell.toString().trim()){
                                  checkLogic(context,_bloc.listRefundOrder[index]);
                                }
                                else{
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return WillPopScope(
                                          onWillPop: () async => false,
                                          child: const CustomQuestionComponent(
                                            showTwoButton: true,
                                            iconData: Icons.warning_amber_outlined,
                                            title: 'Cảnh báo đơn khác thuế',
                                            content: 'Chúng tôi không cho phép bạn chọn từ hai đơn hàng có NVBH là khác nhau, vui lòng tách đơn hay làm gì đó đi.',
                                          ),
                                        );
                                      });
                                }
                              },
                              child: Stack(
                                fit: StackFit.loose,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Card(
                                      shape: _bloc.listRefundOrder[index].isMark == false ? null : const  RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all( Radius.circular(10)),
                                          side: BorderSide(width: 1.8, color: Colors.red)),
                                      semanticContainer: true,
                                      margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                SizedBox(
                                                  height: 80,width: 40,
                                                  child: Transform.scale(
                                                    scale: 1,
                                                    alignment: Alignment.topLeft,
                                                    child: Checkbox(
                                                      value: _bloc.listRefundOrder[index].isMark,
                                                      onChanged: (b){
                                                        if(DataLocal.codeSellLockRefundOrder == ''){
                                                          if(DataLocal.codeTaxLockRefundOrder == ''){
                                                            if(_bloc.listRefundOrder[index].isMark == false){
                                                              _bloc.listRefundOrder[index].isMark = true;
                                                              DataLocal.lockRefundOrder = true;
                                                              // print('click');
                                                              DataLocal.sct = _bloc.listRefundOrder[index].soCt.toString().trim();
                                                              DataLocal.codeLockRefundOrder = _bloc.listRefundOrder[index].sttRec.toString().trim();
                                                              DataLocal.codeTaxLockRefundOrder = _bloc.listRefundOrder[index].codeTax.toString().trim();
                                                              DataLocal.percentTaxLockRefundOrder = _bloc.listRefundOrder[index].percentTax??0;
                                                              DataLocal.codeSellLockRefundOrder = _bloc.listRefundOrder[index].codeSell.toString();
                                                              DataLocal.tkRefundOrder = _bloc.listRefundOrder[index].tk.toString();

                                                              _bloc.add(GetDetailRefundOrderEvent(
                                                                  sctRec:_bloc.listRefundOrder[index].sttRec,
                                                                  invoiceDate: _bloc.listRefundOrder[index].ngayCt,
                                                                  allowAddOrDeleteInList: true,
                                                                  addOrDeleteInList: true
                                                              ));
                                                            }
                                                            else{
                                                              _bloc.listRefundOrder[index].isMark = false;
                                                              // print('UnClick');
                                                              DataLocal.sct = '';
                                                              _bloc.add(GetDetailRefundOrderEvent(
                                                                  sctRec:_bloc.listRefundOrder[index].sttRec,
                                                                  invoiceDate: _bloc.listRefundOrder[index].ngayCt,
                                                                  allowAddOrDeleteInList: true,
                                                                  addOrDeleteInList: false
                                                              ));
                                                            }
                                                          }
                                                          else{
                                                            if(DataLocal.codeTaxLockRefundOrder == _bloc.listRefundOrder[index].codeTax.toString().trim()){
                                                              if(_bloc.listRefundOrder[index].isMark == false){
                                                                _bloc.listRefundOrder[index].isMark = true;
                                                                print('click');
                                                                DataLocal.sct = _bloc.listRefundOrder[index].soCt.toString().trim();
                                                                _bloc.add(GetDetailRefundOrderEvent(
                                                                    sctRec:_bloc.listRefundOrder[index].sttRec,
                                                                    invoiceDate: _bloc.listRefundOrder[index].ngayCt,
                                                                    allowAddOrDeleteInList: true,
                                                                    addOrDeleteInList: true
                                                                ));
                                                              }else{
                                                                _bloc.listRefundOrder[index].isMark = false;
                                                                print('Unclick');
                                                                DataLocal.sct = '';
                                                                _bloc.add(GetDetailRefundOrderEvent(
                                                                    sctRec:_bloc.listRefundOrder[index].sttRec,
                                                                    invoiceDate: _bloc.listRefundOrder[index].ngayCt,
                                                                    allowAddOrDeleteInList: true,
                                                                    addOrDeleteInList: false
                                                                ));
                                                              }
                                                            }
                                                            else if(DataLocal.codeTaxLockRefundOrder == '00' && _bloc.listRefundOrder[index].codeTax.toString().trim() == '00'){
                                                              if(_bloc.listRefundOrder[index].isMark == false){
                                                                _bloc.listRefundOrder[index].isMark = true;
                                                                print('click');
                                                                DataLocal.sct = _bloc.listRefundOrder[index].soCt.toString().trim();
                                                                _bloc.add(GetDetailRefundOrderEvent(
                                                                    sctRec:_bloc.listRefundOrder[index].sttRec,
                                                                    invoiceDate: _bloc.listRefundOrder[index].ngayCt,
                                                                    allowAddOrDeleteInList: true,
                                                                    addOrDeleteInList: true
                                                                ));
                                                              }else{
                                                                _bloc.listRefundOrder[index].isMark = false;
                                                                print('Unclick');
                                                                DataLocal.sct = '';
                                                                _bloc.add(GetDetailRefundOrderEvent(
                                                                    sctRec:_bloc.listRefundOrder[index].sttRec,
                                                                    invoiceDate: _bloc.listRefundOrder[index].ngayCt,
                                                                    allowAddOrDeleteInList: true,
                                                                    addOrDeleteInList: false
                                                                ));
                                                              }
                                                            }
                                                            else{
                                                              showDialog(
                                                                  context: context,
                                                                  builder: (context) {
                                                                    return WillPopScope(
                                                                      onWillPop: () async => false,
                                                                      child: const CustomQuestionComponent(
                                                                        showTwoButton: true,
                                                                        iconData: Icons.warning_amber_outlined,
                                                                        title: 'Cảnh báo đơn khác thuế',
                                                                        content: 'Chúng tôi không cho phép bạn chọn từ hai đơn hàng có mã thuế là khác nhau, vui lòng tách đơn hay làm gì đó đi.',
                                                                      ),
                                                                    );
                                                                  });
                                                            }
                                                          }
                                                        }
                                                        else if(DataLocal.codeSellLockRefundOrder.toString().trim() == _bloc.listRefundOrder[index].codeSell.toString().trim()){
                                                          if(DataLocal.codeTaxLockRefundOrder == ''){
                                                            if(_bloc.listRefundOrder[index].isMark == false){
                                                              _bloc.listRefundOrder[index].isMark = true;
                                                              DataLocal.lockRefundOrder = true;
                                                              print('click');
                                                              DataLocal.sct = _bloc.listRefundOrder[index].soCt.toString().trim();
                                                              DataLocal.codeLockRefundOrder = _bloc.listRefundOrder[index].sttRec.toString().trim();
                                                              DataLocal.codeTaxLockRefundOrder = _bloc.listRefundOrder[index].codeTax.toString().trim();
                                                              DataLocal.percentTaxLockRefundOrder = _bloc.listRefundOrder[index].percentTax!;
                                                              DataLocal.codeSellLockRefundOrder = _bloc.listRefundOrder[index].codeSell.toString();
                                                              DataLocal.tkRefundOrder = _bloc.listRefundOrder[index].tk.toString();

                                                              _bloc.add(GetDetailRefundOrderEvent(
                                                                  sctRec:_bloc.listRefundOrder[index].sttRec,
                                                                  invoiceDate: _bloc.listRefundOrder[index].ngayCt,
                                                                  allowAddOrDeleteInList: true,
                                                                  addOrDeleteInList: true
                                                              ));
                                                            }
                                                            else{
                                                              _bloc.listRefundOrder[index].isMark = false;
                                                              print('Unclick');
                                                              DataLocal.sct = '';
                                                              _bloc.add(GetDetailRefundOrderEvent(
                                                                  sctRec:_bloc.listRefundOrder[index].sttRec,
                                                                  invoiceDate: _bloc.listRefundOrder[index].ngayCt,
                                                                  allowAddOrDeleteInList: true,
                                                                  addOrDeleteInList: false
                                                              ));
                                                            }
                                                          }
                                                          else{
                                                            if(DataLocal.codeTaxLockRefundOrder == _bloc.listRefundOrder[index].codeTax.toString().trim()){
                                                              if(_bloc.listRefundOrder[index].isMark == false){
                                                                _bloc.listRefundOrder[index].isMark = true;
                                                                print('click');
                                                                DataLocal.sct = _bloc.listRefundOrder[index].soCt.toString().trim();
                                                                _bloc.add(GetDetailRefundOrderEvent(
                                                                    sctRec:_bloc.listRefundOrder[index].sttRec,
                                                                    invoiceDate: _bloc.listRefundOrder[index].ngayCt,
                                                                    allowAddOrDeleteInList: true,
                                                                    addOrDeleteInList: true
                                                                ));
                                                              }else{
                                                                _bloc.listRefundOrder[index].isMark = false;
                                                                print('Unclick');
                                                                DataLocal.sct = '';
                                                                _bloc.add(GetDetailRefundOrderEvent(
                                                                    sctRec:_bloc.listRefundOrder[index].sttRec,
                                                                    invoiceDate: _bloc.listRefundOrder[index].ngayCt,
                                                                    allowAddOrDeleteInList: true,
                                                                    addOrDeleteInList: false
                                                                ));
                                                              }
                                                            }
                                                            else if(DataLocal.codeTaxLockRefundOrder == '00' && _bloc.listRefundOrder[index].codeTax.toString().trim() == '00'){
                                                              if(_bloc.listRefundOrder[index].isMark == false){
                                                                _bloc.listRefundOrder[index].isMark = true;
                                                                print('click');
                                                                DataLocal.sct = _bloc.listRefundOrder[index].soCt.toString().trim();
                                                                _bloc.add(GetDetailRefundOrderEvent(
                                                                    sctRec:_bloc.listRefundOrder[index].sttRec,
                                                                    invoiceDate: _bloc.listRefundOrder[index].ngayCt,
                                                                    allowAddOrDeleteInList: true,
                                                                    addOrDeleteInList: true
                                                                ));
                                                              }else{
                                                                _bloc.listRefundOrder[index].isMark = false;
                                                                print('Unclick');
                                                                DataLocal.sct = '';
                                                                _bloc.add(GetDetailRefundOrderEvent(
                                                                    sctRec:_bloc.listRefundOrder[index].sttRec,
                                                                    invoiceDate: _bloc.listRefundOrder[index].ngayCt,
                                                                    allowAddOrDeleteInList: true,
                                                                    addOrDeleteInList: false
                                                                ));
                                                              }
                                                            }
                                                            else{
                                                              showDialog(
                                                                  context: context,
                                                                  builder: (context) {
                                                                    return WillPopScope(
                                                                      onWillPop: () async => false,
                                                                      child: const CustomQuestionComponent(
                                                                        showTwoButton: true,
                                                                        iconData: Icons.warning_amber_outlined,
                                                                        title: 'Cảnh báo đơn khác thuế',
                                                                        content: 'Chúng tôi không cho phép bạn chọn từ hai đơn hàng có mã thuế là khác nhau, vui lòng tách đơn hay làm gì đó đi.',
                                                                      ),
                                                                    );
                                                                  });
                                                            }
                                                          }
                                                        }
                                                        else{
                                                          showDialog(
                                                              context: context,
                                                              builder: (context) {
                                                                return WillPopScope(
                                                                  onWillPop: () async => false,
                                                                  child: const CustomQuestionComponent(
                                                                    showTwoButton: true,
                                                                    iconData: Icons.warning_amber_outlined,
                                                                    title: 'Cảnh báo đơn khác thuế',
                                                                    content: 'Chúng tôi không cho phép bạn chọn từ hai đơn hàng có NVBH là khác nhau, vui lòng tách đơn hay làm gì đó đi.',
                                                                  ),
                                                                );
                                                              });
                                                        }
                                                      },
                                                      activeColor: mainColor,
                                                      hoverColor: Colors.orange,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(4)
                                                      ),
                                                      side: WidgetStateBorderSide.resolveWith((states){
                                                        if(states.contains(WidgetState.pressed)){
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
                                                    padding: const EdgeInsets.only(left: 10,right: 3,top: 5,bottom: 5),
                                                    width: double.infinity,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                const Icon(Icons.account_circle_outlined,color: subColor,size: 15,),
                                                                const SizedBox(width: 5,),
                                                                Text(
                                                                  _bloc.listRefundOrder[index].tenKh.toString().trim(),
                                                                  textAlign: TextAlign.left,
                                                                  style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold, fontSize: 12.5,),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              _bloc.listRefundOrder[index].dienThoai.toString().trim(),
                                                              textAlign: TextAlign.left,
                                                              style: const TextStyle(color: grey, fontSize: 11,),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Row(
                                                          children: [
                                                            Icon(MdiIcons.mapMarkerRadiusOutline,color: subColor,size: 15,),
                                                            const SizedBox(width: 5,),
                                                            Flexible(
                                                              child: Text(
                                                                _bloc.listRefundOrder[index].diaChi != '' ? _bloc.listRefundOrder[index].diaChi.toString().trim() : 'Đang cập nhật',
                                                                textAlign: TextAlign.left,
                                                                style: const TextStyle(color: grey, fontSize: 11,),maxLines: 2,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Row(
                                                          children: [
                                                            Flexible(
                                                              child: Row(
                                                                children: [
                                                                  Icon(MdiIcons.cubeOutline,color: subColor,size: 15,),
                                                                  const SizedBox(width: 5,),
                                                                  Flexible(
                                                                    child: Text(
                                                                      'Tổng SL: ${_bloc.listRefundOrder[index].tSoLuong?.toInt()??0} sản phẩm',
                                                                      textAlign: TextAlign.left,
                                                                      style: const TextStyle(color: grey, fontSize: 11,),maxLines: 2,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Text(
                                                              'Code: ${_bloc.listRefundOrder[index].soCt.toString().trim()}',
                                                              textAlign: TextAlign.left,
                                                              style: const TextStyle(color: grey, fontSize: 10,),maxLines: 1,overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Row(
                                                          children: [
                                                            Flexible(
                                                              child: Row(
                                                                children: [
                                                                  const Icon(Icons.date_range,color: subColor,size: 15,),
                                                                  const SizedBox(width: 5,),
                                                                  Text(
                                                                    'Ngày lập đơn: ${_bloc.listRefundOrder[index].ngayCt != null ? Utils.parseDateTToString(_bloc.listRefundOrder[index].ngayCt.toString(), Const.DATE_FORMAT_1).toString() : 'Đang cập nhật'}',
                                                                    textAlign: TextAlign.left,
                                                                    style: const TextStyle(color: grey, fontSize: 11,),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Text(
                                                              'NVBH: ${_bloc.listRefundOrder[index].codeSell.toString().trim()}',
                                                              textAlign: TextAlign.left,
                                                              style: const TextStyle(color: grey, fontSize: 10,),maxLines: 1,overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
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
                                                    'Tổng SL đã trả:  ${_bloc.listRefundOrder[index].tSlTra?.toInt()??0} SP',
                                                    textAlign: TextAlign.left,
                                                    style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 12.5,color:  Colors.blueGrey),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    'Tổng SL còn lại:  ${(_bloc.listRefundOrder[index].tSoLuong!.toInt() - _bloc.listRefundOrder[index].tSlTra!.toInt())} SP',
                                                    textAlign: TextAlign.left,
                                                    style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 12.5,color:  Colors.blueGrey),
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
                                                    'Tổng CK: ${Utils.formatMoneyStringToDouble(_bloc.listRefundOrder[index].tCkNt??0)}₫',
                                                    textAlign: TextAlign.left,
                                                    style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 12.5,color:  Colors.blueGrey),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    'Tổng Thanh toán: ${Utils.formatMoneyStringToDouble(_bloc.listRefundOrder[index].tTtNt??0)}₫',
                                                    textAlign: TextAlign.left,
                                                    style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 12.5,color:  Colors.blueGrey),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      top: 0,left: 5,
                                      child: Icon(MdiIcons.bookmark,color: _bloc.listRefundOrder[index].isMark == true ? Colors.red : Colors.transparent,)
                                  ),
                                ],
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

  void checkLogic(BuildContext context, GetListRefundOrderResponseData item){
    if(DataLocal.codeTaxLockRefundOrder == ''){
      pushNewScreenAction(context,item);
    }
    else{
      if(DataLocal.codeTaxLockRefundOrder == item.codeTax.toString().trim()){
        pushNewScreenAction(context,item);
      }
      else if(DataLocal.codeTaxLockRefundOrder == '00' && item.codeTax.toString().trim() == '00'){
        pushNewScreenAction(context,item);
      }
      else{
        showDialog(
            context: context,
            builder: (context) {
              return WillPopScope(
                onWillPop: () async => false,
                child: const CustomQuestionComponent(
                  showTwoButton: true,
                  iconData: Icons.warning_amber_outlined,
                  title: 'Cảnh báo đơn khác thuế',
                  content: 'Chúng tôi không cho phép bạn chọn từ hai đơn hàng có mã thuế là khác nhau, vui lòng tách đơn hay làm gì đó đi.',
                ),
              );
            });
      }
    }
  }

  pushNewScreenAction(BuildContext context,GetListRefundOrderResponseData item){
    PersistentNavBarNavigator.pushNewScreen(context, screen: DetailOrderCompletedScreen(
      sttRec: item.sttRec.toString().trim(),
      invoiceDate: item.ngayCt.toString().trim(),
      title: item.tenKh.toString().trim(),
      codeTax: item.codeTax.toString(),
      percentTax: item.percentTax??0,
      detailCustomer: widget.detailCustomer,
      codeSell: item.codeSell.toString(),
      sct: item.soCt.toString(),
      tk: item.tk.toString(),
    ),withNavBar: false).then((value){
      _bloc.listRefundOrder.clear();
      _bloc.add(GetListRefundOrderEvent(dateFrom:dateFrom.toString(),dateTo: dateTo,idCustomer: widget.detailCustomer.customerCode.toString()));
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
                "Danh sách đơn đã duyệt",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: ()=>showDialog(
                context: context,
                builder: (context) => OptionsFilterDate(dateFrom: dateFrom.toString(),dateTo: dateTo.toString(),)).then((value){
              if(value != null){
                if(value[1] != null && value[2] != null){
                  dateFrom = value[3];
                  dateTo = value[4];
                  if(_bloc.listRefundOrder.isNotEmpty){
                    _bloc.listRefundOrder.clear();
                  }
                  _bloc.add(GetListRefundOrderEvent(
                      dateFrom:dateFrom.toString(),
                      dateTo: dateTo,
                      idCustomer: widget.detailCustomer.customerCode.toString().trim() == 'null' ? '' :  widget.detailCustomer.customerCode.toString().trim()
                  ));
                }else{
                  Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Hãy chọn từ ngày đến ngày');
                }
              }
            }),
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.event,
                size: 25,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
