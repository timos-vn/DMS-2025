// ignore_for_file: library_private_types_in_public_api

import 'package:dms/model/database/data_local.dart';
import 'package:dms/screen/sell/refund_order/refund_order_screen.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../model/network/response/detail_customer_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../options_input/options_input_screen.dart';
import '../refund_order_bloc.dart';
import '../refund_order_event.dart';
import '../refund_order_state.dart';
import 'detail_history_refund_oder_screen.dart';


class ListHistoryRefundOrderScreen extends StatefulWidget {
  final DetailCustomerResponseData? detailCustomer;

  const ListHistoryRefundOrderScreen({Key? key, this.detailCustomer}) : super(key: key);



  @override
  _ListHistoryRefundOrderScreenState createState() => _ListHistoryRefundOrderScreenState();
}

class _ListHistoryRefundOrderScreenState extends State<ListHistoryRefundOrderScreen> {

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
        _bloc.add(GetListHistoryRefundOrderEvent(isLoadMore:true,dateFrom:dateFrom.toString(),dateTo: dateTo,idCustomer: widget.detailCustomer?.customerCode.toString().trim() == 'null' ? '' :  widget.detailCustomer?.customerCode.toString().trim()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: subColor,
      //   onPressed: ()async{
      //     PersistentNavBarNavigator.pushNewScreen(context, screen: RefundOrderScreen(
      //       detailCustomer: widget.detailCustomer??DetailCustomerResponseData(),
      //       codeTax: DataLocal.codeTaxLockRefundOrder,
      //       percentTax: DataLocal.percentTaxLockRefundOrder,
      //       tk: DataLocal.tkRefundOrder,),withNavBar: false);
      //   },
        // child: Icon(MdiIcons.skipNextCircleOutline,color: Colors.white,),
      // ),
      body: BlocListener<RefundOrderBloc,RefundOrderState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsRefundOrderSuccess){
            _bloc.add(GetListHistoryRefundOrderEvent(dateFrom:dateFrom.toString(),dateTo: dateTo,
                idCustomer: widget.detailCustomer?.customerCode.toString().trim() == 'null' ? '' :  widget.detailCustomer?.customerCode.toString().trim()
            ));
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
    int length = _bloc.listHistoryRefundOrder.length;
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
                _bloc.listHistoryRefundOrder.clear();
                _bloc.add(GetListHistoryRefundOrderEvent(dateFrom:dateFrom.toString(),dateTo: dateTo,
                    idCustomer: widget.detailCustomer?.customerCode.toString().trim() == 'null' ? '' :  widget.detailCustomer?.customerCode.toString().trim()));
              },
              child:  SizedBox(
                height: double.infinity,width: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        const SizedBox(width: 4,),
                        Text('Danh sách từ $dateFrom - $dateTo' ,style: const TextStyle(color:Colors.blueGrey,fontSize: 12),),
                        const SizedBox(width: 4,),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        controller: _scrollController,
                        padding: EdgeInsets.zero,
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
                              PersistentNavBarNavigator.pushNewScreen(context, screen: DetailHistoryRefundOrderScreen(
                                sttRec: _bloc.listHistoryRefundOrder[index].sttRec.toString(),
                                invoiceDate: _bloc.listHistoryRefundOrder[index].ngayCt.toString(),
                                title: _bloc.listHistoryRefundOrder[index].tenKh.toString().trim(),
                                codeTax: _bloc.listHistoryRefundOrder[index].maThue.toString(),
                                percentTax: _bloc.listHistoryRefundOrder[index].tThueNt!,
                              ),withNavBar: false);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Card(
                                semanticContainer: true,
                                margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
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
                                                      _bloc.listHistoryRefundOrder[index].tenKh.toString().trim(),
                                                      textAlign: TextAlign.left,
                                                      style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold, fontSize: 12.5,),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  _bloc.listHistoryRefundOrder[index].dienThoai.toString().trim(),
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
                                                    _bloc.listHistoryRefundOrder[index].diaChi != '' ? _bloc.listHistoryRefundOrder[index].diaChi.toString().trim() : 'Đang cập nhật',
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(color: grey, fontSize: 11,),maxLines: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5,),
                                            Row(
                                              children: [
                                                Icon(MdiIcons.cubeOutline,color: subColor,size: 15,),
                                                const SizedBox(width: 5,),
                                                Flexible(
                                                  child: Text(
                                                    'Tổng SL: ${_bloc.listHistoryRefundOrder[index].tSoLuong??0} sản phẩm',
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(color: grey, fontSize: 11,),maxLines: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5,),
                                            Row(
                                              children: [
                                                const Icon(Icons.date_range,color: subColor,size: 15,),
                                                const SizedBox(width: 5,),
                                                Text(
                                                  'Ngày lập đơn: ${_bloc.listHistoryRefundOrder[index].ngayCt != null ? Utils.parseDateTToString(_bloc.listHistoryRefundOrder[index].ngayCt.toString(), Const.DATE_FORMAT_1).toString() : 'Đang cập nhật'}',
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(color: grey, fontSize: 11,),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'NVBH:  ${_bloc.listHistoryRefundOrder[index].tenNvbh}',
                                              textAlign: TextAlign.left,
                                              style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 12.5,color:  Colors.blueGrey),
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              'NVLHD:  ${_bloc.listHistoryRefundOrder[index].tenNvlhd}',
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
                                              'Tổng CK:  ${_bloc.listHistoryRefundOrder[index].tCkNt??0}',
                                              textAlign: TextAlign.left,
                                              style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 12.5,color:  Colors.blueGrey),
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              'Tổng Thanh toán:  ${_bloc.listHistoryRefundOrder[index].tTtNt??0}',
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
          const Expanded(
            child: Center(
              child: Text(
                "Danh sách phiếu hàng trả lại",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: ()=>showDialog(
                context: context,
                builder: (context) => OptionsFilterDate(dateFrom: dateFrom.toString(),dateTo: dateTo.toString())).then((value){
              if(value != null){
                if(value[1] != null && value[2] != null){
                  dateFrom = value[3];
                  dateTo = value[4];
                  if(_bloc.listRefundOrder.isNotEmpty){
                    _bloc.listRefundOrder.clear();
                  }
                  _bloc.add(GetListHistoryRefundOrderEvent(
                      dateFrom:dateFrom.toString(),
                      dateTo: dateTo,
                      idCustomer: widget.detailCustomer?.customerCode.toString().trim() == 'null' ? '' :  widget.detailCustomer?.customerCode.toString().trim()
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
