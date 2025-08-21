// ignore_for_file: library_private_types_in_public_api
import 'dart:math';

import 'package:dms/screen/dms/ticket/ticket_bloc.dart';
import 'package:dms/screen/dms/ticket/ticket_event.dart';
import 'package:dms/screen/dms/ticket/ticket_state.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../model/network/response/manager_customer_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../../customer/search_customer/search_customer_screen.dart';
import '../../filter/filter_page.dart';
import '../../options_input/options_input_screen.dart';
import 'component/ticket_detail_screen.dart';


class TicketHistoryScreen extends StatefulWidget {

  const TicketHistoryScreen({Key? key}) : super(key: key);

  @override
  _TicketHistoryScreenState createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen>with TickerProviderStateMixin{

  late TicketHistoryBloc _bloc;

  String employeeCode = '';
  String employeeName = '';
  String idCustomer = '';
  String nameCustomer = '';
  int status = 0;
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

    _bloc = TicketHistoryBloc(context);
    _bloc.add(GetPrefsTicketHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(bottom: 55),
      //   child: FloatingActionButton(
      //     backgroundColor: subColor,
      //     onPressed: ()async{
      //       pushNewScreen(context, screen: const SaleOutScreen()).then((value){
      //         if(value != '' && value != null){
      //           if(value[0] == 'ReloadScreen'){
      //             _bloc.add(GetListHistorySaleOutEvent(dateFrom: dateFrom,dateTo: dateTo, pageIndex: selectedPage));
      //           }
      //         }
      //       });
      //     },
      //     child: const Icon(Icons.add,color: Colors.white,),
      //   ),
      // ),
      body: BlocListener<TicketHistoryBloc,TicketHistoryState>(
        listener: (context,state){
          if(state is GetPrefsTicketHistorySuccess){
            _bloc.add(GetListTicketHistoryEvent(dateFrom: dateFrom,dateTo: dateTo,idCustomer: idCustomer.toString(),status: status, pageIndex: selectedPage));
          }
        },
        bloc: _bloc,
        child: BlocBuilder<TicketHistoryBloc,TicketHistoryState>(
          bloc: _bloc,
          builder: (BuildContext context,TicketHistoryState state){
            return Stack(
              children: [
                buildScreen(context, state),
                Visibility(
                  visible: state is GetListTicketHistoryEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is TicketHistoryLoading,
                  child: const PendingAction(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildScreen(BuildContext context,TicketHistoryState state){
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
              itemCount: _bloc.listHistoryTicket.length,
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int index){
                return GestureDetector(
                  onTap: (){
                    PersistentNavBarNavigator.pushNewScreen(context, screen: TicketDetailHistoryScreen(
                      nameCustomer:  _bloc.listHistoryTicket[index].tenKh.toString().trim(),
                      titleTicket: _bloc.listHistoryTicket[index].tenLoaiTk.toString().trim(),
                      idTicket: _bloc.listHistoryTicket[index].idTicket.toString().trim(),
                      dateFeedback: _bloc.listHistoryTicket[index].time.toString().trim(),
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Ticket: ${_bloc.listHistoryTicket[index].tenLoaiTk.toString().trim()}',
                                          textAlign: TextAlign.left,
                                          style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        'Ngày lập: ${(_bloc.listHistoryTicket[index].time.toString().replaceAll('null', '').isNotEmpty) ? _bloc.listHistoryTicket[index].time.toString().toString() : 'Đang cập nhật'}',
                                        textAlign: TextAlign.left,
                                        style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10,),
                                  Text(
                                    'Khách hàng: ${_bloc.listHistoryTicket[index].tenKh.toString().trim()}',
                                    textAlign: TextAlign.left,
                                    style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.blueGrey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10,),
                                  Text(
                                    'Nội dung: ${_bloc.listHistoryTicket[index].dienGiai.toString().trim()}',
                                    textAlign: TextAlign.left,
                                    style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                    maxLines: 5,
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
                          _bloc.add(GetListTicketHistoryEvent(dateFrom: dateFrom,dateTo: dateTo,idCustomer: idCustomer.toString(),status: status, pageIndex: selectedPage));
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
                            _bloc.add(GetListTicketHistoryEvent(dateFrom: dateFrom,dateTo: dateTo,idCustomer: idCustomer.toString(),status: status, pageIndex: selectedPage));
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
                                _bloc.add(GetListTicketHistoryEvent(dateFrom: dateFrom,dateTo: dateTo,idCustomer: idCustomer.toString(),status: status, pageIndex: selectedPage));
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
                            _bloc.add(GetListTicketHistoryEvent(dateFrom: dateFrom,dateTo: dateTo,idCustomer: idCustomer.toString(),status: status, pageIndex: selectedPage));
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
                          _bloc.add(GetListTicketHistoryEvent(dateFrom: dateFrom,dateTo: dateTo,idCustomer: idCustomer.toString(),status: status, pageIndex: selectedPage));
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
                'Danh sách lịch sử Ticket',
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: (){
              showModalBottomSheet(
                  context: context,
                  isDismissible: true,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
                  ),
                  backgroundColor: Colors.white,
                  builder: (builder){
                    return Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(25),
                              topLeft: Radius.circular(25)
                          )
                      ),
                      margin: MediaQuery.of(context).viewInsets,
                      child: FractionallySizedBox(
                        heightFactor: 0.35,
                        child: StatefulBuilder(
                          builder: (BuildContext context,StateSetter myState){
                            return Padding(
                              padding: const EdgeInsets.only(top: 10,bottom: 0),
                              child: Container(
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(25),
                                        topLeft: Radius.circular(25)
                                    )
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0,left: 16,right: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(Icons.check,color: Colors.white,),
                                          const Text('Tuỳ chọn',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w800),),
                                          InkWell(
                                              onTap: ()=> Navigator.pop(context),
                                              child: const Icon(Icons.close,color: Colors.black,)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 5,),
                                    const Divider(color: Colors.blueGrey,),
                                    const SizedBox(height: 5,),
                                    Expanded(
                                      child: ListView(
                                        padding: const EdgeInsets.only(left: 16,right: 16,bottom: 0),
                                        children: [
                                          SizedBox(
                                            height: 30,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Flexible(child: Text('Khách hàng:',style: TextStyle(color: Colors.black),)),
                                                Row(
                                                  children: [
                                                    InkWell(
                                                        onTap:(){
                                                          PersistentNavBarNavigator.pushNewScreen(context, screen: SearchCustomerScreen(
                                                              selected: true,typeName: false,allowCustomerSearch: false, inputQuantity: false,
                                                          ),withNavBar: false).then((value){
                                                            if(!Utils.isEmpty(value)){
                                                              ManagerCustomerResponseData infoCustomer = value;
                                                              nameCustomer = infoCustomer.customerName.toString().trim();
                                                              idCustomer = infoCustomer.customerCode.toString().trim();
                                                            }
                                                          });
                                                        },
                                                        child: Text(idCustomer != '' ? nameCustomer :'Tìm kiếm khách hàng',style: const TextStyle(color: Colors.blueGrey,fontSize: 12))),
                                                    const SizedBox(width: 5,),
                                                    InkWell(
                                                        onTap: (){
                                                          nameCustomer = '';
                                                          idCustomer = '';
                                                          myState(() {});
                                                        },
                                                        child: const Icon(Icons.delete_forever,color: Colors.grey,size: 20,))
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(top: 5,bottom: 9),
                                            child: Divider(),
                                          ),
                                          SizedBox(
                                            height: 30,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Flexible(child: Text('Nhân viên:',style: TextStyle(color: Colors.black),)),
                                                Row(
                                                  children: [
                                                    InkWell(
                                                        onTap:()async{
                                                          showDialog(
                                                              context: context,
                                                              builder: (context) => const FilterScreen(controller: 'dmnvbhbnvql_lookup',
                                                                listItem: null,show: false,)).then((value){
                                                            if(value != null){
                                                              myState(() {
                                                                employeeCode = value[0];
                                                                employeeName = value[1];
                                                              });
                                                            }
                                                          });
                                                        },
                                                        child: Text(employeeName != '' ? employeeName :'Tìm kiếm nhân viên',style: const TextStyle(color: Colors.blueGrey,fontSize: 12))),
                                                    const SizedBox(width: 5,),
                                                    InkWell(
                                                        onTap: (){
                                                          employeeName = '';
                                                          employeeCode = '';
                                                          myState(() {});
                                                        },
                                                        child: const Icon(Icons.delete_forever,color: Colors.grey,size: 20,))
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(top: 5,bottom: 9),
                                            child: Divider(),
                                          ),
                                          SizedBox(
                                            height: 30,
                                            width: double.infinity,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Flexible(child: Text('Thời gian:',style: TextStyle(color: Colors.black),)),
                                                InkWell(
                                                    onTap: (){
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) => OptionsFilterDate(dateFrom: dateFrom.toString(),dateTo: dateTo.toString(),)).then((value){
                                                        if(value != null){
                                                          if(value[1] != null && value[2] != null){
                                                            dateFrom = value[3];
                                                            dateTo = value[4];
                                                          }else{
                                                            Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Hãy chọn từ ngày đến ngày');
                                                          }
                                                        }
                                                      });
                                                    },
                                                    child: Center(child: Text('Từ $dateFrom đến $dateTo',style: const TextStyle(color: Colors.blueGrey,fontSize: 12))))
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16,right: 16,bottom: 12),
                                      child: GestureDetector(
                                        onTap: (){
                                          if(_bloc.listHistoryTicket.isNotEmpty){
                                            _bloc.listHistoryTicket.clear();
                                          }
                                          _bloc.add(GetListTicketHistoryEvent(
                                              dateFrom: dateFrom,
                                              dateTo: dateTo,
                                              idCustomer: idCustomer.toString(),
                                              employeeCode: employeeCode.toString(),
                                              status: status,
                                              pageIndex: selectedPage
                                          ));
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          height: 45, width: double.infinity,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              color: subColor
                                          ),
                                          child: const Center(
                                            child: Text('Áp dụng', style: TextStyle(color: Colors.white,fontSize: 12.5),),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
              ).then((value){

              });
            },
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(Icons.filter_list, color: Colors.white,size: 20,),
            ),
          )
        ],
      ),
    );
  }
}
