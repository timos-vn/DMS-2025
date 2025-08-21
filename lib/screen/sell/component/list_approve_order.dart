// ignore_for_file: library_private_types_in_public_api

import 'dart:math';

import 'package:dms/screen/sell/refund_order/component/list_history_refund_order_screen.dart';
import 'package:dms/screen/sell/sell_bloc.dart';
import 'package:dms/screen/sell/sell_event.dart';
import 'package:dms/screen/sell/sell_state.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../../options_input/options_input_screen.dart';
import 'history_order_detail_screen.dart';

class ListApproveOrderScreen extends StatefulWidget {
  const ListApproveOrderScreen({Key? key}) : super(key: key);

  @override
  _ListApproveOrderScreenState createState() => _ListApproveOrderScreenState();
}

class _ListApproveOrderScreenState extends State<ListApproveOrderScreen> {

  late SellBloc _bloc;

  String dateFrom = DateTime.now().add(const Duration(days: -30)).toString();
  String dateTo = DateTime.now().toString();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = SellBloc(context);
    _bloc.add(GetListApproveOrder(dateFrom: dateFrom, dateTo: dateTo, pageIndex: selectedPage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SellBloc,SellState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){

          }
        },
        child: BlocBuilder<SellBloc,SellState>(
          bloc: _bloc,
          builder: (BuildContext context, SellState state){
            return buildBody(context,state);
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,SellState state){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildAppBar(),
        Expanded(
            child: Stack(
              children: [
                buildListApproveOrder(),
                Visibility(
                  visible: state is GetListApproveOrderEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is SellLoading,
                  child: const PendingAction(),
                )
              ],
            )
        ),
      ],
    );
  }

  Widget buildListApproveOrder(){
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
              itemCount: _bloc.listApproveOrder.length,
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int index){
                return GestureDetector(
                    onTap: ()=>PersistentNavBarNavigator.pushNewScreen(context, screen: HistoryOrderDetailScreen(
                      sttRec: _bloc.listApproveOrder[index].sttRec,
                      title: _bloc.listApproveOrder[index].tenKh,
                      status:  false ,
                      approveOrder: true,
                      dateOrder: _bloc.listApproveOrder[index].ngayCt.toString(),
                      codeCustomer: _bloc.listApproveOrder[index].maKh.toString().trim(),
                      nameCustomer:  _bloc.listApproveOrder[index].tenKh.toString().trim(),
                      addressCustomer:  _bloc.listApproveOrder[index].diaChi.toString().trim(),
                      phoneCustomer:  _bloc.listApproveOrder[index].dienThoai.toString().trim(),
                      dateEstDelivery: _bloc.listApproveOrder[index].ngayCt.toString(),
                    ),withNavBar: false).then((value){
                      if(value == Const.REFRESH){
                        _bloc.listApproveOrder.clear();
                        _bloc.add(GetListApproveOrder(dateFrom: dateFrom, dateTo: dateTo, pageIndex: selectedPage));
                      }
                    }),
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
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text.rich(
                                              TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text:'[${_bloc.listApproveOrder[index].maKh.toString().trim()}]',
                                                      style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize: 11.5,overflow: TextOverflow.fade),
                                                    ),
                                                    TextSpan(
                                                      text:' ${_bloc.listApproveOrder[index].tenKh.toString().trim()}',
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12.5,),
                                                    )
                                                  ]
                                              )
                                          ),
                                        ),
                                        const SizedBox(width: 8,),
                                        Expanded(
                                          child: Text(
                                            'SCT: ${_bloc.listApproveOrder[index].soCt.toString().trim()}',
                                            textAlign: TextAlign.right,
                                            style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.blueGrey),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Tổng tiền: ${Utils.formatMoneyStringToDouble(_bloc.listApproveOrder[index].tTtNt??0)}đ',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: mainColor),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(width: 5,),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const Expanded(flex: 18,child: Divider()),
                                              Text('  ${_bloc.listApproveOrder[index].tSoLuong.toString().trim()} sản phẩm  ', style: const TextStyle(color: Colors.blueGrey,fontSize: 12),),
                                              const Expanded(child: Divider()),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        const Text('Ngày lên đơn:',style: TextStyle(color: Colors.black,fontSize: 12),),
                                        const SizedBox(width: 3,),
                                        Expanded(child: Text(Utils.parseDateTToString(_bloc.listApproveOrder[index].ngayCt.toString().trim(), Const.DATE_FORMAT_1).toString(), style: const TextStyle(color: Colors.black,fontSize: 12),maxLines: 3,overflow: TextOverflow.ellipsis,)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                );
              }
          ),
        ),
        _bloc.totalPager > 1 ? _getDataPager() : Container(),
        const SizedBox(height: 5,),
      ],
    );
  }

  int lastPage=0;
  int selectedPage=1;

  Widget _getDataPager() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Center(
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
                            _bloc.add(GetListApproveOrder(dateFrom: dateFrom, dateTo: dateTo, pageIndex: selectedPage));
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
                              _bloc.add(GetListApproveOrder(dateFrom: dateFrom, dateTo: dateTo, pageIndex: selectedPage));
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
                                  _bloc.add(GetListApproveOrder(dateFrom: dateFrom, dateTo: dateTo, pageIndex: selectedPage));
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
                              _bloc.add(GetListApproveOrder(dateFrom: dateFrom, dateTo: dateTo, pageIndex: selectedPage));
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
                            _bloc.add(GetListApproveOrder(dateFrom: dateFrom, dateTo: dateTo, pageIndex: selectedPage));
                          },
                          child: const Icon(Icons.skip_next_outlined,color: Colors.grey)),
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
            onTap: ()=> Navigator.of(context).pop(),
            child:const SizedBox(
              width: 40,
              height: 50,
              child:  Icon(
                Icons.arrow_back_rounded,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('Đơn hàng cần duyệt',
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: ()=>  showDialog(
                context: context,
                builder: (context) => const OptionsFilterDate()).then((value){
              if(value != null){
                if(value[1] != null && value[2] != null){
                  dateFrom = Utils.parseStringToDate(value[3], Const.DATE_SV_FORMAT).toString();
                  dateTo = Utils.parseStringToDate(value[4], Const.DATE_SV_FORMAT).toString();
                  _bloc.listApproveOrder.clear();
                  _bloc.add(GetListApproveOrder(dateFrom: dateFrom, dateTo: dateTo, pageIndex: selectedPage));
                }else{
                  Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Vui lòng nhập nội dung từ ngày đến ngày');
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
