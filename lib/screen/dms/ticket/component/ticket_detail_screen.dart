// ignore_for_file: library_private_types_in_public_api
import 'dart:math';

import 'package:dms/screen/dms/ticket/ticket_bloc.dart';
import 'package:dms/screen/dms/ticket/ticket_event.dart';
import 'package:dms/screen/dms/ticket/ticket_state.dart';
import 'package:dms/widget/custom_slider.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../themes/colors.dart';
import '../../../../utils/images.dart';


class TicketDetailHistoryScreen extends StatefulWidget {

  final String idTicket;
  final String titleTicket;
  final String nameCustomer;
  final String dateFeedback;

  const TicketDetailHistoryScreen({Key? key, required this.idTicket,required this.titleTicket,required this.nameCustomer, required this.dateFeedback}) : super(key: key);

  @override
  _TicketDetailHistoryScreenState createState() => _TicketDetailHistoryScreenState();
}

class _TicketDetailHistoryScreenState extends State<TicketDetailHistoryScreen>with TickerProviderStateMixin{

  late TicketHistoryBloc _bloc;



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
    return BlocListener<TicketHistoryBloc,TicketHistoryState>(
      listener: (context,state){
        if(state is GetPrefsTicketHistorySuccess){
          _bloc.add(GetDetailTicketHistoryEvent(widget.idTicket.toString()));
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
                visible: state is TicketHistoryLoading,
                child: const PendingAction(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildScreen(BuildContext context,TicketHistoryState state){
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
          buildSlider(),
          const Row(
            children: [
               Expanded(flex: 1, child: Divider()),
              Text(
                'Phản hồi',
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
               Expanded(flex: 8, child: Divider()),
            ],
          ),
          Expanded(
            child: ListView.builder(
                itemCount: 1,
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
                                    widget.titleTicket.toString().trim(),
                                    textAlign: TextAlign.left,
                                    style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10,),
                                  Text(
                                    (_bloc.detailHistory.feedBack.toString().trim() != 'null' && _bloc.detailHistory.feedBack.toString().trim() != '') ? _bloc.detailHistory.feedBack.toString().trim() : 'Chưa có phản hồi từ KH',
                                    textAlign: TextAlign.left,
                                    style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.blueGrey),
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10,),
                                  Text(
                                    'Ngày phản hồi: ${(widget.dateFeedback.toString().replaceAll('null', '').isNotEmpty) ? widget.dateFeedback.toString().toString() : 'Đang cập nhật'}',
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
                  );
                }
            ),
          ),
          const SizedBox(height: 5,),
        ],
      ),
    );
  }

  buildSlider(){
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: _bloc.imageDetailList.isEmpty ? Image.asset(noWallpaper, fit: BoxFit.cover,) : CustomCarouselObject(items: _bloc.imageDetailList,),
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
              colors: [subColor, Color.fromARGB(255, 150, 185, 229)])),
      padding: const EdgeInsets.fromLTRB(5, 35, 12,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: ()=> Navigator.of(context).pop(),
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
                widget.nameCustomer.toString().trim(),
                style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          const SizedBox(
            width: 40,
            height: 50,
            child: Icon(Icons.filter_list, color: Colors.transparent,size: 20,),
          )
        ],
      ),
    );
  }
}
