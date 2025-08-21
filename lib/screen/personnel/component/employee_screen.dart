// ignore_for_file: library_private_types_in_public_api

import 'dart:math';

import 'package:dms/screen/personnel/component/search_employee_screen.dart';
import 'package:dms/screen/personnel/personnel_bloc.dart';
import 'package:dms/screen/personnel/personnel_event.dart';
import 'package:dms/screen/personnel/personnel_state.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../model/entity/item_check_in.dart';
import '../../../model/network/response/detail_checkin_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/utils.dart';
import '../../dms/check_in/check_in_screen.dart';
import '../../sell/component/history_order.dart';
import 'employee_case_screen.dart';

class EmployeeScreen extends StatefulWidget {
  final int typeView;
  final List<ItemCheckInOffline>? listCheckInToDay;
  final List<ListAlbum>? listAlbumOffline;
  final List<ListAlbumTicketOffLine>? listAlbumTicketOffLine;
  final bool? reloadData;

  const EmployeeScreen({Key? key, required this.typeView,
    this.listCheckInToDay, this.listAlbumOffline, this.listAlbumTicketOffLine, this.reloadData}) : super(key: key);

  @override
  _EmployeeScreenState createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {

  late PersonnelBloc _bloc;
  int lastPage=0;
  int selectedPage=1;

  Color colorTotalOrder = Color(Random().nextInt(0xffffffff)).withAlpha(0xff);
  Color colorTotalMyOrder = Color(Random().nextInt(0xffffffff)).withAlpha(0xff);
  Color colorTotalEmployeeOrder = Color(Random().nextInt(0xffffffff)).withAlpha(0xff);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = PersonnelBloc(context);
    _bloc.add(GetListEmployeeEvent(pageIndex: selectedPage,userId: _bloc.userId,keySearch: '',typeAction: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<PersonnelBloc,PersonnelState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is TimeKeepingFailure){
            Utils.showCustomToast(context, Icons.warning_amber_outlined, state.error);
          }
        },
        child: BlocBuilder<PersonnelBloc,PersonnelState>(
          bloc: _bloc,
          builder: (BuildContext context, PersonnelState state){
            return Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is PersonnelLoading,
                  child: const PendingAction(),
                )
              ],
            );

          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,PersonnelState state){
    return Padding(
      padding: const EdgeInsets.only(bottom: 70),
      child: Column(
        children: [
          buildAppBar(),
          const Divider(height: 1,),
          Padding(
            padding: const EdgeInsets.only(left: 10,top: 12),
            child: Row(
              children: const [
                Text('KPI STATISTICS [QTY]',style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          Container(color: Colors.transparent,
            height: 160,width: double.infinity,
            padding: const EdgeInsets.only(top: 15),
            child: Padding(
              padding: const EdgeInsets.only(left: 70),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                   fit: StackFit.passthrough,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 80,width: 80,
                        decoration: const BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(50))
                        ),
                      ),
                      Positioned(
                        right: -35,bottom: -20,
                        child: Container(
                          height: 100,width: 100,
                          decoration: BoxDecoration(
                              color: colorTotalOrder,
                              borderRadius: const BorderRadius.all(Radius.circular(80))
                          ),
                          child: Center(
                            child: Text('${_bloc.totalEmployeeOder + _bloc.totalMyOder}',style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -55,top: -25,
                        child: Container(
                          height: 90,width: 90,
                          decoration:  BoxDecoration(
                              color: colorTotalEmployeeOrder,
                              borderRadius:const BorderRadius.all(Radius.circular(50))
                          ),
                          child: Center(
                            child: Text(_bloc.totalEmployeeOder.toString(),style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -40,right: 5,
                        child: Container(
                          height: 60,width: 60,
                          decoration:  BoxDecoration(
                              color: colorTotalMyOrder,
                              borderRadius:const BorderRadius.all(Radius.circular(50))
                          ),
                          child: Center(
                            child: Text(_bloc.totalMyOder.toString(),style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                      child: Container(
                        color: Colors.transparent,
                        padding:const EdgeInsets.only(left: 50,bottom: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap:(){
                                if(widget.typeView == 1){
                                  PersistentNavBarNavigator.pushNewScreen(context, screen: HistoryOrderScreen(userId: _bloc.userId.toString(),),withNavBar: true);
                                }
                                else if(widget.typeView == 2){
                                  if (widget.listCheckInToDay != null && widget.listAlbumTicketOffLine != null && widget.listAlbumOffline != null) {
                                    PersistentNavBarNavigator.pushNewScreen(context, screen: CheckInScreen(
                                      reloadData: false,
                                      listCheckInToDay: widget.listCheckInToDay??[],
                                      listAlbumTicketOffLine: widget.listAlbumTicketOffLine??[],
                                      listAlbumOffline: widget.listAlbumOffline??[],
                                        userId: _bloc.userId.toString()
                                    ), withNavBar: false);
                                  }else{
                                    Navigator.pop(context,['GetOffline']);
                                  }

                                }else if(widget.typeView == 3){

                                }else if(widget.typeView == 4){

                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  textLine('${
                                      (widget.typeView == 1 || widget.typeView == 3 || widget.typeView == 4) ? 'Đơn' : 'Lượt check-in'
                                  } của bạn', colorTotalMyOrder),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Icon(Icons.navigate_next,color: colorTotalMyOrder,size: 20,),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10,),
                            textLine('${
                                (widget.typeView == 1 || widget.typeView == 3 || widget.typeView == 4) ? 'Đơn' : 'Lượt check-in'
                            } của nhân viên', colorTotalEmployeeOrder,),
                            const SizedBox(height: 10,),
                            textLine('Tổng số ${
                                (widget.typeView == 1 || widget.typeView == 3 || widget.typeView == 4) ? 'đơn' : 'lượt check-in'
                            }', colorTotalOrder),
                    ],
                  ),))
                ],
              ),
            ),
          ),
          Row(
            children: [
              const Expanded(child: Divider()),
              Text('Danh sách ${
                  (widget.typeView == 1 || widget.typeView == 3 || widget.typeView == 4) ? 'Đơn' : 'Lượt check-in'
              } Tháng ${DateTime.now().month} của nhân viên',style:const TextStyle(color: Colors.blueGrey,fontSize: 12),),
              const Expanded(child: Divider()),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                    itemCount: _bloc.listEmployee.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (BuildContext context, int index){
                      return GestureDetector(
                        onTap: (){
                          if(_bloc.listEmployee[index].capQl == 0){
                            if(widget.typeView == 1){
                              PersistentNavBarNavigator.pushNewScreen(context, screen: HistoryOrderScreen(userId: _bloc.listEmployee[index].userId.toString(),),withNavBar: true);
                            }
                            else if(widget.typeView == 2){
                              PersistentNavBarNavigator.pushNewScreen(context, screen: CheckInScreen(
                                reloadData: false,
                                listCheckInToDay: widget.listCheckInToDay??[],
                                listAlbumTicketOffLine: widget.listAlbumTicketOffLine??[],
                                listAlbumOffline: widget.listAlbumOffline??[],
                                userId: _bloc.listEmployee[index].userId.toString(),
                              ), withNavBar: false);
                              // if (widget.listCheckInToDay != null && widget.listAlbumTicketOffLine != null && widget.listAlbumOffline != null) {
                              //
                              // }else{
                              //   Navigator.pop(context,['GetOffline']);
                              // }

                            }else if(widget.typeView == 3){

                            }else if(widget.typeView == 4){

                            }
                          }else{
                            PersistentNavBarNavigator.pushNewScreen(context, screen: EmployeeCaseScreen(
                              userId: _bloc.listEmployee[index].userId.toString(),
                              userName: _bloc.listEmployee[index].tenNvbh.toString(),
                              colorTotalOrder: colorTotalOrder,
                              colorTotalMyOrder: colorTotalMyOrder,
                              colorTotalEmployeeOrder: colorTotalEmployeeOrder,
                              typeView: widget.typeView,
                              reloadData: false,
                              listCheckInToDay: widget.listCheckInToDay??[] ,
                              listAlbumTicketOffLine: widget.listAlbumTicketOffLine??[],
                              listAlbumOffline: widget.listAlbumOffline??[],
                            ));
                          }
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
                                          'Quản lý: ${_bloc.listEmployee[index].tenNvql.toString().trim()}',
                                          textAlign: TextAlign.left,
                                          style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6,),
                                        Text(
                                          'Tên nhân viên: ${_bloc.listEmployee[index].tenNvbh.toString().trim()}',
                                          textAlign: TextAlign.left,
                                          style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.blueGrey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6,),
                                        Text(
                                          'Bộ phận: ${_bloc.listEmployee[index].tenCapql.toString()}',
                                          textAlign: TextAlign.left,
                                          style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                    visible: _bloc.listEmployee[index].soLuong.toString() != 'null' && _bloc.listEmployee[index].soLuong.toString().isNotEmpty && _bloc.listEmployee[index].soLuong.toString() != '',
                                    child: Text('${_bloc.listEmployee[index].soLuong.toString()} ${(widget.typeView == 1 || widget.typeView == 3 || widget.typeView == 4) ? 'đơn' : 'lượt'}',style:const TextStyle(color: Colors.black,fontSize: 12),)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                ),
                Visibility(
                  visible: state is EmptyEmployeeState,
                  child: const Center(
                    child: Text('Úi, Có vẻ bạn chưa quản lý thành viên nào cả',style: TextStyle(color: Colors.blueGrey,fontSize: 12),textAlign: TextAlign.center,),
                  ),
                ),
              ],
            ),
          ),
          _bloc.totalPager > 1 ? _getDataPager() : Container(),
          const SizedBox(height: 5,),
        ],
      ),
    );
  }

  Widget textLine(String title, Color colors){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 10,height: 10,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            color: colors
          ),
        ),
        const SizedBox(width: 10,),
        Text(title,style: TextStyle(color: colors,fontSize: 13,),maxLines: 1,overflow: TextOverflow.visible,),
      ],
    );
  }

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
                            _bloc.add(GetListEmployeeEvent(pageIndex: selectedPage,userId: _bloc.userId,keySearch: '',typeAction: 1));
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
                              _bloc.add(GetListEmployeeEvent(pageIndex: selectedPage,userId: _bloc.userId,keySearch: '',typeAction: 1));
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
                                  _bloc.add(GetListEmployeeEvent(pageIndex: selectedPage,userId: _bloc.userId,keySearch: '',typeAction: 1));
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
                              _bloc.add(GetListEmployeeEvent(pageIndex: selectedPage,userId: _bloc.userId,keySearch: '',typeAction: 1));
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
                            _bloc.add(GetListEmployeeEvent(pageIndex: selectedPage,userId: _bloc.userId,keySearch: '',typeAction: 1));
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
                'Thông tin',
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          InkWell(
            onTap: (){
              PersistentNavBarNavigator.pushNewScreen(context, screen: SearchEmployeeScreen(userId: _bloc.userId.toString(), userName: 'Bạn',typeView: widget.typeView,)).then((value){
                if(value != null){
                  if(value[0] == 'Yeah'){
                    if(value[1] == 0){
                      if(widget.typeView == 1){
                        PersistentNavBarNavigator.pushNewScreen(context, screen: HistoryOrderScreen(userId: value[2].toString(),),withNavBar: true);
                      }
                      else if(widget.typeView == 2){
                        if (widget.listCheckInToDay != null && widget.listAlbumTicketOffLine != null && widget.listAlbumOffline != null) {
                          PersistentNavBarNavigator.pushNewScreen(context, screen: CheckInScreen(
                            reloadData: false,
                            listCheckInToDay: widget.listCheckInToDay??[],
                            listAlbumTicketOffLine: widget.listAlbumTicketOffLine??[],
                            listAlbumOffline: widget.listAlbumOffline??[],
                            userId: value[2].toString(),
                          ), withNavBar: false);
                        }else{
                          Navigator.pop(context,['GetOffline']);
                        }

                      }else if(widget.typeView == 3){

                      }else if(widget.typeView == 4){

                      }
                    }else{
                      PersistentNavBarNavigator.pushNewScreen(context, screen: EmployeeCaseScreen(
                        userId: value[2].toString(),
                        userName: value[3].toString(),
                        colorTotalOrder: colorTotalOrder,
                        colorTotalEmployeeOrder: colorTotalEmployeeOrder,
                        colorTotalMyOrder: colorTotalMyOrder,
                        typeView: widget.typeView,
                        reloadData: false,
                        listCheckInToDay: widget.listCheckInToDay??[],
                        listAlbumTicketOffLine: widget.listAlbumTicketOffLine??[],
                        listAlbumOffline: widget.listAlbumOffline??[],
                      ));
                    }
                  }
                }
              });
            },
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.search,
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
