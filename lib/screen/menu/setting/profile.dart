// ignore_for_file: library_private_types_in_public_api

import 'package:dms/screen/menu/setting/change_password_screen.dart';
import 'package:dms/widget/custom_profile.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:dms/screen/menu/menu_bloc.dart';
import 'package:dms/screen/menu/menu_state.dart';
import 'package:dms/utils/const.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../model/database/data_local.dart';
import '../../../model/database/dbhelper.dart';
import '../../../model/entity/info_login.dart';
import '../../../themes/colors.dart';
import '../../../utils/utils.dart';
import '../../login/login_screen.dart';
import '../menu_event.dart';



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin  {

  late MenuBloc _bloc;
  DatabaseHelper db = DatabaseHelper();
  late Animation<double> fadeAnimation;
  late AnimationController fadeController;
  late Animation<double> editAnimation;
  late AnimationController editController;
  final _controllerWoPrice = ValueNotifier<bool>(Const.isWoPrice);
  final _controllerAutoAddDiscount = ValueNotifier<bool>(Const.autoAddDiscount);
  final _controllerAddProductFollowStore = ValueNotifier<bool>(Const.addProductFollowStore);
  final _controllerAllowViewPriceAndTotalPriceProductGift = ValueNotifier<bool>(Const.allowViewPriceAndTotalPriceProductGift);


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = MenuBloc(context);
    _bloc.add(GetPrefsMenuEvent());

    _controllerWoPrice.addListener(() {
      if(_controllerWoPrice.value){
        Const.isWoPrice = true;
        updateIF();
        Utils.showCustomToast(context, Icons.monetization_on_outlined, 'Áp dụng giá bán buôn');
      }
      else{
        Const.isWoPrice = false;
        updateIF();
        Utils.showCustomToast(context, Icons.monetization_on_outlined, 'Áp dụng giá bán lẻ');
      }
    });

    _controllerAutoAddDiscount.addListener(() {
      if(_controllerAutoAddDiscount.value){
        Const.autoAddDiscount = true;
        updateIF();
        Utils.showCustomToast(context, Icons.lock_open_outlined, 'Tự động thêm chiết khấu theo mặt hàng trước đó');
      }
      else{
        Const.autoAddDiscount = false;
        updateIF();
        Utils.showCustomToast(context, Icons.lock_outline, 'Tắt tính năng tự động thêm chiết khấu');
      }
    });

    _controllerAddProductFollowStore.addListener(() {
      if(_controllerAddProductFollowStore.value){
        Const.addProductFollowStore = true;
        updateIF();
        Utils.showCustomToast(context, Icons.lock_open_outlined, 'ON');
      }
      else{
        Const.addProductFollowStore = false;
        updateIF();
        Utils.showCustomToast(context, Icons.lock_outline, 'OFF');
      }
    });

    _controllerAllowViewPriceAndTotalPriceProductGift.addListener(() {
      if(_controllerAllowViewPriceAndTotalPriceProductGift.value){
        Const.allowViewPriceAndTotalPriceProductGift = true;
        updateIF();
        Utils.showCustomToast(context, Icons.lock_open_outlined, 'ON');
      }
      else{
        Const.allowViewPriceAndTotalPriceProductGift = false;
        updateIF();
        Utils.showCustomToast(context, Icons.lock_outline, 'OFF');
      }
    });

    editController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    editAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: editController,
        curve: const Interval(
          0.0,
          1.0,
          curve: Curves.easeIn,
        ),
      ),
    );
    fadeController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: fadeController,
        curve: const Interval(
          0.0,
          1.0,
          curve: Curves.easeOut,
        )));

    fadeController.forward();
  }

  void updateIF()async{

    InfoLogin infoLogin = InfoLogin(
      'vi',
      'Tiếng Việt',
      DataLocal.hotIdName,
      DataLocal.accountName,
      DataLocal.passwordAccount,
      DateTime.now().toString(),
      '',
      '',
      DataLocal.userId,
      DataLocal.userName,
      DataLocal.fullName,
      Const.isWoPrice == true ? 1 : 0,
      Const.autoAddDiscount == true ? 1 : 0,
      Const.addProductFollowStore == true ? 1 : 0,
      Const.allowViewPriceAndTotalPriceProductGift == true ? 1 : 0,
    );

    await db.updateInfoLogin(infoLogin);
    // infoAccountCache = await db.fetchAllInfoLogin();
    // if (!Utils.isEmpty(infoAccountCache)) {
    //   print(infoAccountCache[0].addProductFollowStore);
    // }
  }
  // List<InfoLogin> infoAccountCache =  <InfoLogin>[];
  @override
  void dispose() {
    fadeController.dispose();
    editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<MenuBloc,MenuState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is DeleteAccountSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Cảm ơn bạn đã đồng hành cùng chúng tôi. Chúc bạn thành công trên chặng đường mới');
            PersistentNavBarNavigator.pushNewScreen(context, screen: const LoginScreen(),withNavBar: false);
          }
        },
        child: BlocBuilder<MenuBloc,MenuState>(
          bloc: _bloc,
          builder: (BuildContext context, MenuState state){
            return buildBody(state);
          },
        ),
      ),
    );
  }

  Widget buildBody(MenuState state){
    return Column(children: <Widget>[
      FadeTransition(
        opacity: fadeAnimation,
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(bottom: 15.0),
          child: Stack(children: <Widget>[
            CustomPaint(
              painter: ProfileHeader(deviceSize: MediaQuery.of(context).size),
            ),
            Container(
                width: 150.0,
                height: 150.0,
                margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 2,
                    top: MediaQuery.of(context).size.height * 0.1),
                decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black45,
                          blurRadius: 4.0,
                          offset: Offset(0.0, 5.0)),
                    ],
                    shape: BoxShape.circle,
                    image:  DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage('assets/images/background_erp.jpg'),
                    ))),
            Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width - 50,
                  top: MediaQuery.of(context).size.height * 0.03),
              child: IconButton(
                  icon: Icon(
                      MdiIcons.clipboardAccountOutline
                  ),
                  iconSize: 20.0,
                  color: Colors.white.withOpacity(0.8),
                  onPressed: () {

                  }),
            ),
            Container(
                margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.05,
                    top: MediaQuery.of(context).size.height * 0.10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        Const.userName != '' ? Const.userName.toUpperCase() : "Đối tác - SSE".toUpperCase(),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Hạng - Đang cập nhật',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14.0,
                        ),
                      ),
                    ])),
          ]),
        ),
      ),
      const SizedBox(height: 30,),
      Expanded(
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Visibility(
                  visible: Const.woPrice == true,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                        child: Row(
                          children: [
                            const Center(
                              child: Icon(Icons.price_change_outlined,size: 24,color: subColor,),
                            ),
                            const SizedBox(width: 10,),
                            const Expanded(
                              child: Text('Loại giá',style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal),),
                            ),
                            AdvancedSwitch(
                              controller: _controllerWoPrice,
                              activeColor: subColor,
                              inactiveColor: Colors.blueGrey,
                              borderRadius:const BorderRadius.all(Radius.circular(15)),
                              width: 70,
                              height: 22,
                              enabled: true,
                              activeChild: const Text('Bán buôn',style: TextStyle(fontSize: 9.5,color: Colors.white),),
                              inactiveChild: const Text('Bán lẻ',style: TextStyle(fontSize: 9.5,color: Colors.white),),
                              disabledOpacity: 0.3,
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
                Visibility(
                  visible: Const.enableProductFollowStore == true,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                        child: Row(
                          children: [
                            Center(
                              child: Icon(MdiIcons.orderBoolAscendingVariant,size: 24,color: subColor,),
                            ),
                            const SizedBox(width: 10,),
                            const Expanded(
                              child: Text('Thêm 1 mặt hàng nhiều kho',style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal),),
                            ),
                            AdvancedSwitch(
                              controller: _controllerAddProductFollowStore,
                              activeColor: subColor,
                              inactiveColor: Colors.blueGrey,
                              borderRadius:const BorderRadius.all(Radius.circular(15)),
                              width: 70,
                              height: 22,
                              enabled: true,
                              activeChild: const Text('ON',style: TextStyle(fontSize: 9.5,color: Colors.white),),
                              inactiveChild: const Text('OFF',style: TextStyle(fontSize: 9.5,color: Colors.white),),
                              disabledOpacity: 0.3,
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
                Visibility(
                  visible: Const.enableViewPriceAndTotalPriceProductGift == true,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                        child: Row(
                          children: [
                            Center(
                              child: Icon(MdiIcons.walletGiftcard,size: 24,color: subColor,),
                            ),
                            const SizedBox(width: 10,),
                            const Expanded(
                              child: Text('Xem giá và tổng tiền hàng tặng',style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal),),
                            ),
                            AdvancedSwitch(
                              controller: _controllerAllowViewPriceAndTotalPriceProductGift,
                              activeColor: subColor,
                              inactiveColor: Colors.blueGrey,
                              borderRadius:const BorderRadius.all(Radius.circular(15)),
                              width: 70,
                              height: 22,
                              enabled: true,
                              activeChild: const Text('ON',style: TextStyle(fontSize: 9.5,color: Colors.white),),
                              inactiveChild: const Text('OFF',style: TextStyle(fontSize: 9.5,color: Colors.white),),
                              disabledOpacity: 0.3,
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
                Visibility(
                  visible: Const.enableAutoAddDiscount == true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                    child: Row(
                      children: [
                        const Center(
                          child: Icon(Icons.discount_outlined,size: 24,color: subColor,),
                        ),
                        const SizedBox(width: 10,),
                        const Expanded(
                          child: Text('Tự động thêm chiết khấu',style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal),),
                        ),
                        AdvancedSwitch(
                          controller: _controllerAutoAddDiscount,
                          activeColor: subColor,
                          inactiveColor: Colors.blueGrey,
                          borderRadius:const BorderRadius.all(Radius.circular(15)),
                          width: 70,
                          height: 22,
                          enabled: true,
                          activeChild: const Text('Auto',style: TextStyle(fontSize: 9.5,color: Colors.white),),
                          inactiveChild: const Text('Manual',style: TextStyle(fontSize: 9.5,color: Colors.white),),
                          disabledOpacity: 0.3,
                        ),
                      ],
                    ),
                  ),
                ),
                // Container(
                //     height: 10,
                //     width: double.infinity,
                //     color: Colors.grey.withOpacity(0.2)
                // ),
                // const SizedBox(height: 5,),
                // InkWell(
                //   onTap: ()=>Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Tính năng đang được nâng cấp'),
                //   child: buildButton('Mật khẩu',MdiIcons.lockOutline,'0',false,subColor),
                // ),
                // const Divider(),
                // InkWell(
                //   onTap: ()=>Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Tính năng đang được nâng cấp'),
                //   child: buildButton('Đổi ngôn ngữ',MdiIcons.earth,'Tiếng việt',true,subColor),
                // ),
                // const Divider(),
                // InkWell(
                //   onTap: ()=>Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Tính năng đang được nâng cấp'),
                //   child: buildButton('Cài đặt thông báo',MdiIcons.bellRingOutline,'0',false,subColor),
                // ),
                Container(
                    height: 10,
                    width: double.infinity,
                    color: Colors.grey.withOpacity(0.2)
                ),
                const SizedBox(height: 7,),
                InkWell(
                  onTap: (){
                    PersistentNavBarNavigator.pushNewScreen(context, screen: const ChangePasswordScreen(),withNavBar: true);
                  },
                  child:  buildButton('Đổi mật khẩu',Icons.lock_outline,'0',false,subColor),
                ),
                const SizedBox(height: 7,),
                InkWell(
                  onTap: (){
                    showDialog(
                        context: context,
                        builder: (context) {
                          return WillPopScope(
                            onWillPop: () async => false,
                            child: const CustomQuestionComponent(
                              showTwoButton: true,
                              iconData: Icons.delete_forever_outlined,
                              title: 'Bạn muốn xoá tài khoản?',
                              content: 'Điều gì khi bạn chọn "Đồng Ý"?\n Tài khoản của bạn sẽ bị xoá vĩnh viễn!',
                            ),
                          );
                        }).then((value)async{
                      if(value != null){
                        if(!Utils.isEmpty(value) && value == 'Yeah'){
                          _bloc.add(DeleteAccount());
                        }
                      }
                    });
                  },
                  child:  buildButton('Xoá tài khoản',Icons.person_remove_alt_1_outlined,'0',false,Colors.red),
                ),
                const SizedBox(height: 2,),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  buildButton(String title, IconData icons, String number, bool showNumber,Color colorIcon){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
      child: Row(
        children: [
          Center(
            child: Icon(icons,size: 24,color: colorIcon,),
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: Text(title,style: const TextStyle(color: Colors.black,fontWeight: FontWeight.normal),),
          ),
          Visibility(
            visible: showNumber==true,
            child: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Text(number,style: const TextStyle(color: Colors.blueGrey),),
            ),),
          const Icon(Icons.navigate_next),
        ],
      ),
    );
  }

}
