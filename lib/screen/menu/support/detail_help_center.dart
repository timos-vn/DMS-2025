import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import '../../../themes/colors.dart';
import '../menu_bloc.dart';
import '../menu_state.dart';

class DetailHelpCenterScreen extends StatefulWidget {
  const DetailHelpCenterScreen({Key? key}) : super(key: key);

  @override
  _DetailHelpCenterScreenState createState() => _DetailHelpCenterScreenState();
}

class _DetailHelpCenterScreenState extends State<DetailHelpCenterScreen> with TickerProviderStateMixin  {

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
                      height: 18,
                      width: double.infinity,
                    ),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),color: Colors.white,),
                      padding: const EdgeInsets.all(16),
                      child: buildRequestProblem(),
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
        const Text('Xử lý lỗi ứng dụng',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
        const SizedBox(height:18,),
        Text('Nếu bạn không thể mở ứng dụng, ứng dụng bị treo, thoát ra đột ngột hoặc xuất hiện thông báo lỗi, bạn có thể thực hiện những bước sau: ',
          style: TextStyle(color: Colors.black.withOpacity(0.7),fontSize: 14,height: 1.5),),
        const SizedBox(height: 22,),
        Text('1. Kiểm tra kết nối mạng',
          style: TextStyle(color: Colors.black.withOpacity(0.7),fontSize: 14),),
        const SizedBox(height: 8,),
        Text('Mở trình duyệt internet và thử truy cập trang www.google.com. Nếu không thể truy cập được, bạn có thể đang gặp vấn đề về kết nối mạng. Bạn có thể kiểm tra hướng dẫn sử dụng thiết bị của mình hoặc nhà mạng để khôi phục lại kết nối trước khi thử mở lại ứng dụng SSE-Cloud.',
          style: TextStyle(color: Colors.black.withOpacity(0.7),fontSize: 14,height: 1.5),),
        const SizedBox(height: 16,),
        Text('2. Cập nhật Ứng dụng lên phiên bản mới nhất',
          style: TextStyle(color: Colors.black.withOpacity(0.7),fontSize: 14),),
        const SizedBox(height: 16,),
        Text('3. Thoát ứng dụng & khởi động lại',
          style: TextStyle(color: Colors.black.withOpacity(0.7),fontSize: 14),),
        const SizedBox(height: 16,),
        Text('4. Xoá Ứng dụng & cài đặt lại',
          style: TextStyle(color: Colors.black.withOpacity(0.7),fontSize: 14),),
        const SizedBox(height: 22,),
        Text('Trong trường hợp bạn đã thử các bước hướng dẫn trên nhưng ứng dụng vẫn không khắc phục lỗi, vui lòng Gửi báo cáo để SSE hỗ trợ bạn kịp thời.',
          style: TextStyle(color: Colors.black.withOpacity(0.7),fontSize: 14,height: 1.5),),
      ],
    );
  }

  buildRequestProblem(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text('Yêu cầu trợ giúp về vấn đề này',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
        const SizedBox(height:8,),
        const Divider(),
        InkWell(
          onTap: ()=>FlutterEmailSender.send(Email(recipients: ['supports@sse.net.vn'],cc: ['sse.supports.10@gmail.com'],subject: 'Hỗ trợ lỗi Ứng dụng')),
          child: const Row(
            children: [
              Icon(Icons.mail_outline,color: Colors.red,size: 22,),
              SizedBox(width: 10,),
              Flexible(child: Text('Gửi báo cáo',style: TextStyle(color: Colors.black,fontSize: 13.5),)),
            ],
          ),
        ),
      ],
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
