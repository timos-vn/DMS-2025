import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../themes/colors.dart';
import '../menu_bloc.dart';
import '../menu_state.dart';
import 'detail_help_center.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  _HelpCenterScreenState createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> with TickerProviderStateMixin  {

  late MenuBloc _bloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = MenuBloc(context);
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<MenuBloc,MenuState>(
        bloc: _bloc,
        listener: (context,state){

        },
        child: BlocBuilder<MenuBloc,MenuState>(
          bloc: _bloc,
          builder: (BuildContext context, MenuState state){
            return buildBody(context,state);
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,MenuState state){
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.grey.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildAppBar(),
          const SizedBox(height: 12,),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 12,right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),color: Colors.white,),
                      padding: const EdgeInsets.all(16),
                      child: buildSupport(),
                    ),
                    const SizedBox(
                        height: 10,
                        width: double.infinity,
                    ),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),color: Colors.white,),
                      padding: const EdgeInsets.all(16),
                      child: buildProblem(),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  buildSupport(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text('Bạn cần hỗ trợ vấn đề gì ?',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
        const SizedBox(height:8,),
        const Divider(),
        InkWell(
          onTap: ()=>FlutterEmailSender.send(Email(recipients: ['supports@sse.net.vn'],cc: ['sse.supports.10@gmail.com'],subject: 'Góp ý về tính năng của Ứng dụng SSE-Cloud')),
          child:buildItem('Tôi muốn góp ý về tính năng của Ứng dụng', true, true),
        ),
        InkWell(
          onTap: ()=>FlutterEmailSender.send(Email(recipients: ['supports@sse.net.vn'],cc: ['sse.supports.10@gmail.com'],subject: 'Đánh giá thái độ Nhân viên CSKH SSE')),
          child:buildItem('Tôi muốn đánh giá thái độ Nhân viên CSKH SSE', true, false),
        ),
      ],
    );
  }

  buildProblem(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text('Những vấn đề thường gặp ?',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
        const SizedBox(height:8,),
        const Divider(),
        InkWell(
          onTap: ()=>PersistentNavBarNavigator.pushNewScreen(context, screen: const DetailHelpCenterScreen(),withNavBar: false),
          child:buildItem('Xử lý lỗi Ứng dụng', true, false),
        ),
      ],
    );
  }

  buildItem(String title, bool showNextButton, bool lineEnd){
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(title,style: const TextStyle(color: Colors.black,fontSize: 13.5),)),
              Visibility(
                  visible: showNextButton == true,
                  child: const Icon(Icons.navigate_next,size: 20,color: Colors.blueGrey,))
            ],
          ),
          const SizedBox(height: 8,),
          Visibility(
              visible: lineEnd == true,
              child: const Divider())
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
                'Trung Tâm Trợ giúp',
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(
            height: 45,
            width: 40,
            child: Icon(Icons.how_to_reg,color: Colors.transparent,),
          )
        ],
      ),
    );
  }
}
