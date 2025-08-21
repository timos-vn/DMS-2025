// ignore_for_file: library_private_types_in_public_api
import 'dart:math';

import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../../utils/utils.dart';
import '../../../options_input/options_input_screen.dart';
import '../sale_out_bloc.dart';
import '../sale_out_event.dart';
import '../sale_out_screen.dart';
import '../sale_out_state.dart';
import 'detail_history_sale_out_screen.dart';


class HistorySaleOutScreen extends StatefulWidget {

  const HistorySaleOutScreen({Key? key,}) : super(key: key);

  @override
  _HistorySaleOutScreenState createState() => _HistorySaleOutScreenState();
}

class _HistorySaleOutScreenState extends State<HistorySaleOutScreen>with TickerProviderStateMixin{

  late SaleOutBloc _bloc;

  String dateFrom = Utils.parseDateToString(DateTime.now().add(const Duration(days: -7)), Const.DATE_SV_FORMAT_2);
  String dateTo = Utils.parseDateToString(DateTime.now(), Const.DATE_SV_FORMAT_2);

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
          _bloc.add(GetListHistorySaleOutEvent(dateFrom: dateFrom,dateTo: dateTo, pageIndex: selectedPage));
        }
      },
      bloc: _bloc,
      child: BlocBuilder<SaleOutBloc,SaleOutState>(
        bloc: _bloc,
        builder: (BuildContext context,SaleOutState state){
          return Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: Padding(
              padding: EdgeInsets.only(bottom:state is GetListHistorySaleOutEmpty ? 20 : 55),
              child: FloatingActionButton(
                backgroundColor: subColor,
                onPressed: ()async{
                  PersistentNavBarNavigator.pushNewScreen(context, screen: const SaleOutScreen()).then((value){
                    if(value != '' && value != null){
                      if(value[0] == 'ReloadScreen'){
                        _bloc.add(GetListHistorySaleOutEvent(dateFrom: dateFrom,dateTo: dateTo, pageIndex: selectedPage));
                      }
                    }
                  });
                },
                child: const Icon(Icons.add,color: Colors.white,),
              ),
            ),
            body: Stack(
              children: [
                buildScreen(context, state),
                Visibility(
                  visible: state is GetListHistorySaleOutEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                  ),
                ),
                Visibility(
                  visible: state is SaleOutLoading,
                  child: const PendingAction(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildScreen(BuildContext context,SaleOutState state){
    return Column(
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
              itemCount: _bloc.listHistorySaleOut.length,
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int index){
                return GestureDetector(
                  onTap: (){
                    PersistentNavBarNavigator.pushNewScreen(context, screen: DetailHistorySaleOutScreen(
                      sttRec:  _bloc.listHistorySaleOut[index].sttRec.toString().trim(),
                      invoiceDate: _bloc.listHistorySaleOut[index].ngayCt.toString().trim(),
                      title: _bloc.listHistorySaleOut[index].tenNguoiNhan.toString().trim(),
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
                                    'Người nhận: ${_bloc.listHistorySaleOut[index].tenNguoiNhan.toString().trim()}',
                                    textAlign: TextAlign.left,
                                    style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5,),
                                  Text(
                                    'NPP: ${_bloc.listHistorySaleOut[index].tenNpp.toString().trim()}',
                                    textAlign: TextAlign.left,
                                    style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.blueGrey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10,),
                                  Text(
                                    'Ngày lập: ${(_bloc.listHistorySaleOut[index].ngayCt.toString().isNotEmpty && _bloc.listHistorySaleOut[index].ngayCt.toString() != 'null') ? Utils.safeFormatDate(_bloc.listHistorySaleOut[index].ngayCt.toString().trim()).toString() : 'Đang cập nhật'}',
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
    );
  }

  int lastPage=0;
  int selectedPage=1;

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
                          _bloc.add(GetListHistorySaleOutEvent(dateFrom: dateFrom,dateTo: dateTo, pageIndex: selectedPage));
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
                            _bloc.add(GetListHistorySaleOutEvent(dateFrom: dateFrom,dateTo: dateTo, pageIndex: selectedPage));
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
                                _bloc.add(GetListHistorySaleOutEvent(dateFrom: dateFrom,dateTo: dateTo, pageIndex: selectedPage));
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
                            _bloc.add(GetListHistorySaleOutEvent(dateFrom: dateFrom,dateTo: dateTo, pageIndex: selectedPage));
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
                          _bloc.add(GetListHistorySaleOutEvent(dateFrom: dateFrom,dateTo: dateTo, pageIndex: selectedPage));
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
          const Expanded(
            child: Center(
              child: Text(
                'Danh sách lịch sử Sale Out',
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap:()=> showDialog(
                context: context,
                builder: (context) => OptionsFilterDate(dateFrom: dateFrom.toString(),dateTo: dateTo.toString(),)).then((value){
              if(value != null){
                if(value[1] != null && value[2] != null){
                  dateFrom = value[3];
                  dateTo = value[4];
                  if(_bloc.listHistorySaleOut.isNotEmpty){
                    _bloc.listHistorySaleOut.clear();
                  }
                  _bloc.add(GetListHistorySaleOutEvent(dateFrom: dateFrom,dateTo: dateTo, pageIndex: selectedPage));
                }else{
                  Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Hãy chọn từ ngày đến ngày');
                }
              }
            }),
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.filter_alt,
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
