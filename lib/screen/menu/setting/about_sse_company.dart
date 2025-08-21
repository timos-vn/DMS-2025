import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:dms/screen/menu/menu_bloc.dart';
import 'package:dms/utils/images.dart';

import '../../../themes/colors.dart';
import '../menu_state.dart';

class AboutSSECompanyScreen extends StatefulWidget {
  const AboutSSECompanyScreen({Key? key}) : super(key: key);

  @override
  _AboutSSECompanyScreenState createState() => _AboutSSECompanyScreenState();
}

class _AboutSSECompanyScreenState extends State<AboutSSECompanyScreen> with TickerProviderStateMixin  {

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
          const Divider(height: 1,),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 16,),
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Image.asset(icLogo,fit: BoxFit.contain,),
                ),
                const SizedBox(height: 8,),
                const Padding(
                  padding: EdgeInsets.only(left: 16,right: 8),
                  child: Text('SSE Cloud ERP là hệ thống quản trị tổng thể doanh nghiệp trên nền điện toán đám mây, cung cấp nhiều dịch vụ tiện ích bao gồm:'
                      'xem báo cáo quản trị, doanh thu, công nợ, chi phí, lợi nhuận, đặt hàng, theo dõi tình trạng đơn hàng, duyệt các chứng từ, '
                      'tạo việc, giao việc, kiểm soát tiến độ thực hiện và báo cáo KPI, chấm công online, sale-in, sale-out dành cho sale thị trường.'
                    ,style: TextStyle(fontSize: 13,wordSpacing: 1.5,color: Colors.black),),
                ),
                const SizedBox(height: 20,),
                const Divider(),
                const SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.only(left: 16,right: 8,top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined,color: Colors.red,size: 17,),
                      const SizedBox(width: 5,),
                      Flexible(child: Text('supports@sse.net.vn',style: TextStyle(color: Colors.black.withOpacity(0.8),fontSize: 12),maxLines: 2,)),
                    ],
                  ),
                ),
                const SizedBox(height: 16,),
                const Padding(
                  padding: EdgeInsets.only(left: 16,right: 8),
                  child: Text('CHI NHÁNH HÀ NỘI',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12),maxLines: 2,),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16,right: 8,top: 8),
                  child: Row(
                    children: [
                      Icon(MdiIcons.mapMarkerRadiusOutline,color: Colors.red,size: 17,),
                      const SizedBox(width: 5,),
                      Flexible(child: Text('Tầng 2 tòa nhà 262 Nguyễn Huy Tưởng, Thanh Xuân, Hà Nội',style: TextStyle(color: Colors.black.withOpacity(0.8),fontSize: 12),maxLines: 2,)),
                    ],
                  ),
                ),
                const SizedBox(height: 16,),
                const Padding(
                  padding: EdgeInsets.only(left: 16,right: 8,),
                  child: Text('CHI NHÁNH TP. HỒ CHÍ MINH',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12),maxLines: 2,),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16,right: 8,top: 8),
                  child: Row(
                    children: [
                      Icon(MdiIcons.mapMarkerRadiusOutline,color: Colors.red,size: 17,),
                      const SizedBox(width: 5,),
                      Flexible(child: Text('Tầng 5 - Tòa nhà SOHUDE Tower, Số 29, Thăng Long, P04, Q.Tân Bình, TP HCM',style: TextStyle(color: Colors.black.withOpacity(0.8),fontSize: 12),maxLines: 2,)),
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: SizedBox(
                        height: 60,
                        width: 150,
                        child: Image.asset(icDKBCT,fit: BoxFit.contain,),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Container(
                    height: 10,
                    width: double.infinity,
                    color: Colors.grey.withOpacity(0.2)
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 16,right: 8,top: 12,bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Đánh giá ứng dụng'),
                      Icon(Icons.navigate_next,color: Colors.grey,),
                    ],
                  ),
                ),
              ],
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
                'About SSE Company',
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
