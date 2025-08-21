import 'package:dms/widget/register_use.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../themes/colors.dart';
import '../../../utils/utils.dart';
import '../menu_bloc.dart';
import '../menu_state.dart';

class SupportCenterScreen extends StatefulWidget {
  const SupportCenterScreen({Key? key}) : super(key: key);

  @override
  _SupportCenterScreenState createState() => _SupportCenterScreenState();
}

class _SupportCenterScreenState extends State<SupportCenterScreen> with TickerProviderStateMixin  {

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 70),
      child: Column(
        children: [
          buildAppBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 14,right: 14,top: 10),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  InkWell(
                    onTap: ()=>Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Tính năng đang được cập nhật'),
                    child: buildItem('Hỗ trợ qua chat', true, true),
                  ),
                 InkWell(
                   onTap: (){
                     showDialog(
                         context: context,
                         builder: (context) {
                           return WillPopScope(
                             onWillPop: () async => true,
                             child: const RegisterUseComponent(
                               title: 'Liên hệ với chúng tôi',
                               content: 'Bạn muốn gọi tới số 0243 568 22 22',
                             ),
                           );
                         }).then((value)async{
                       if(value != null){
                         final Uri launchUri = Uri(
                           scheme: 'tel',
                           path: '02435682222',
                         );
                         await launchUrl(launchUri);
                       }
                     });
                   },
                   child: buildItem('Hỗ trợ qua điện thoại', false, true),
                 ),
                  InkWell(
                    onTap: ()=>FlutterEmailSender.send(Email(recipients: ['supports@sse.net.vn'],cc: ['sse.supports.10@gmail.com'],subject: 'Tôi cần hỗ trợ dịch vụ SSE-Cloud')),
                    child:buildItem('Hỗ trợ qua email', true, true),
                  ),
                  InkWell(
                    onTap: ()async{
                      const url = 'https://sse.net.vn';
                      if(await canLaunch(url)){
                        await launch(url);
                      }else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: buildItem('Website', true, false),
                  )
                ],
              ),
            ),
          )
        ],
      ),
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
              Text(title,style: const TextStyle(color: Colors.black,fontSize: 13.5),),
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
                'Trung Tâm Hỗ Trợ',
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
