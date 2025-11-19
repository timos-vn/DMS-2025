// ignore_for_file: library_private_types_in_public_api

import 'dart:math';

import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../model/network/response/detail_customer_response.dart';
import '../../../../model/network/response/manager_customer_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../../utils/utils.dart';
import '../../../options_input/options_input_screen.dart';
import '../../sale_out/component/detail_history_sale_out_screen.dart';
import '../refund_sale_out_bloc.dart';
import '../refund_sale_out_event.dart';
import '../refund_sale_out_state.dart';
import 'list_sale_out_completed_screen.dart';
import '../../../../widget/customer_picker_dialog.dart';

class ListHistoryRefundSaleOutScreen extends StatefulWidget {
  final DetailCustomerResponseData? detailCustomer;

  const ListHistoryRefundSaleOutScreen({Key? key, this.detailCustomer}) : super(key: key);


  @override
  _ListHistoryRefundSaleOutScreenState createState() => _ListHistoryRefundSaleOutScreenState();
}

class _ListHistoryRefundSaleOutScreenState extends State<ListHistoryRefundSaleOutScreen> {

  late RefundSaleOutBloc _bloc;

  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  bool _hasReachedMax = true;

  String dateFrom = Utils.parseDateToString(DateTime.now().add(const Duration(days: -7)), Const.DATE_SV_FORMAT_2);
  String dateTo = Utils.parseDateToString(DateTime.now(), Const.DATE_SV_FORMAT_2);


  int lastPage=0;
  int selectedPage=1;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _bloc = RefundSaleOutBloc(context);
    _bloc.add(GetPrefsRefundSaleOutEvent(calculator: false));
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(GetListHistoryRefundSaleOutEvent(
            isLoadMore:true,
            dateFrom:dateFrom.toString(),
            dateTo: dateTo,
            idCustomer: widget.detailCustomer?.customerCode.toString().trim() == 'null' ? '' :  widget.detailCustomer?.customerCode.toString().trim(),
            pageIndex: selectedPage
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: subColor,
      //   onPressed: ()async{
      //     final selectedCustomer = await showDialog(
      //       context: context,
      //       barrierDismissible: true,
      //       builder: (context) => const CustomerPickerDialog(),
      //     );
      //     if(selectedCustomer != null){
      //       final ManagerCustomerResponseData info = selectedCustomer as ManagerCustomerResponseData;
      //       final DetailCustomerResponseData detail = DetailCustomerResponseData(
      //         customerCode: info.customerCode,
      //         customerName: info.customerName,
      //         phone: info.phone,
      //         address: info.address,
      //       );
      //       PersistentNavBarNavigator.pushNewScreen(
      //         context,
      //         screen: SaleOutCompletedScreen(detailAgency: detail),
      //         withNavBar: false,
      //       );
      //     }
      //   },
      //   child: Icon(MdiIcons.skipNextCircleOutline,color: Colors.white,),
      // ),
      body: BlocListener<RefundSaleOutBloc,RefundSaleOutState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsRefundSaleOutSuccess){
            _bloc.add(GetListHistoryRefundSaleOutEvent(dateFrom:dateFrom.toString(),dateTo: dateTo,
                idCustomer: widget.detailCustomer?.customerCode.toString().trim() == 'null' ? '' :  widget.detailCustomer?.customerCode.toString().trim()
                , pageIndex: selectedPage
            ));
          }
        },
        child: BlocBuilder<RefundSaleOutBloc,RefundSaleOutState>(
          bloc: _bloc,
          builder: (BuildContext context, RefundSaleOutState state){
            return Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is GetListRefundSaleOutEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is RefundSaleOutLoading,
                  child: const PendingAction(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,RefundSaleOutState state){
    int length = _bloc.listHistoryRefundOrder.length;
    if (state is GetListRefundSaleOutSuccess) {
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
                _bloc.add(GetListHistoryRefundSaleOutEvent(dateFrom:dateFrom.toString(),dateTo: dateTo,
                    idCustomer: widget.detailCustomer?.customerCode.toString().trim() == 'null' ? '' :  widget.detailCustomer?.customerCode.toString().trim(), pageIndex: selectedPage));
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
                          itemCount: _bloc.listHistoryRefundOrder.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (BuildContext context, int index){
                            return GestureDetector(
                              onTap: (){
                                PersistentNavBarNavigator.pushNewScreen(context, screen: DetailHistorySaleOutScreen(
                                  sttRec:  _bloc.listHistoryRefundOrder[index].sttRec.toString().trim(),
                                  invoiceDate: _bloc.listHistoryRefundOrder[index].ngayCt.toString().trim(),
                                  title: _bloc.listHistoryRefundOrder[index].tenNguoiNhan.toString().trim(),
                                ),withNavBar: false);
                              },
                              child: Card(
                                semanticContainer: true,
                                margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 70,
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
                                                'Người nhận: ${_bloc.listHistoryRefundOrder[index].tenNguoiNhan.toString().trim()}',
                                                textAlign: TextAlign.left,
                                                style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 5,),
                                              Text(
                                                'NPP: ${_bloc.listHistoryRefundOrder[index].tenNpp.toString().trim()}',
                                                textAlign: TextAlign.left,
                                                style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.blueGrey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 10,),
                                              Text(
                                                'Ngày lập: ${(_bloc.listHistoryRefundOrder[index].ngayCt.toString().isNotEmpty && _bloc.listHistoryRefundOrder[index].ngayCt.toString() != 'null') ? Utils.safeFormatDate(_bloc.listHistoryRefundOrder[index].ngayCt.toString().trim()).toString() : 'Đang cập nhật'}',
                                                textAlign: TextAlign.left,
                                                style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                          }
                      ),
                    ),
                    _bloc.totalPager > 1 ? _getDataPager() : Container(),
                    const SizedBox(height: 5,),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getDataPager() {
    return Center(
      child: SizedBox(
        height: 57,
        width: double.infinity,
        child: Column(
          children: [
            const Divider(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16,right: 16,bottom: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: (){
                          setState(() {
                            lastPage = selectedPage;
                            selectedPage = 1;
                          });
                          _bloc.add(GetListHistoryRefundSaleOutEvent(dateFrom: dateFrom,dateTo: dateTo, pageIndex: selectedPage));
                        },
                        child: const Icon(Icons.skip_previous_outlined,color: Colors.grey)),
                    const SizedBox(width: 10,),
                    InkWell(
                        onTap: (){
                          if(selectedPage > 1){
                            setState(() {
                              lastPage = selectedPage;
                              selectedPage = selectedPage - 1;
                            });
                            _bloc.add(GetListHistoryRefundSaleOutEvent(dateFrom: dateFrom,dateTo: dateTo, pageIndex: selectedPage));
                          }
                        },
                        child: const Icon(Icons.navigate_before_outlined,color: Colors.grey,)),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index){
                            return InkWell(
                              onTap: (){
                                setState(() {
                                  lastPage = selectedPage;
                                  selectedPage = index+1;
                                });
                                _bloc.add(GetListHistoryRefundSaleOutEvent(dateFrom: dateFrom,dateTo: dateTo, pageIndex: selectedPage));
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: selectedPage == (index + 1) ?  mainColor : Colors.white,
                                    borderRadius: const BorderRadius.all(Radius.circular(48))
                                ),
                                child: Center(
                                  child: Text((index + 1).toString(),style: TextStyle(color: selectedPage == (index + 1) ?  Colors.white : Colors.black),),
                                ),
                              ),
                            );
                          },
                          separatorBuilder:(BuildContext context, int index)=> Container(width: 6,),
                          itemCount: _bloc.totalPager > 10 ? 10 : _bloc.totalPager),
                    ),
                    const SizedBox(width: 10,),
                    InkWell(
                        onTap: (){
                          if(selectedPage < _bloc.totalPager){
                            setState(() {
                              lastPage = selectedPage;
                              selectedPage = selectedPage + 1;
                            });
                            _bloc.add(GetListHistoryRefundSaleOutEvent(dateFrom: dateFrom,dateTo: dateTo, pageIndex: selectedPage));
                          }
                        },
                        child: const Icon(Icons.navigate_next_outlined,color: Colors.grey)),
                    const SizedBox(width: 10,),
                    InkWell(
                        onTap: (){
                          setState(() {
                            lastPage = selectedPage;
                            selectedPage = _bloc.totalPager;
                          });
                          _bloc.add(GetListHistoryRefundSaleOutEvent(dateFrom: dateFrom,dateTo: dateTo, pageIndex: selectedPage));
                        },
                        child: const Icon(Icons.skip_next_outlined,color: Colors.grey)),
                  ],
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
                  _bloc.add(GetListHistoryRefundSaleOutEvent(
                      dateFrom:dateFrom.toString(),
                      dateTo: dateTo,
                      idCustomer: widget.detailCustomer?.customerCode.toString().trim() == 'null' ? '' :  widget.detailCustomer?.customerCode.toString().trim(), pageIndex: selectedPage
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
