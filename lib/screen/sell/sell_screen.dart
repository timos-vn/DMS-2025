// ignore_for_file: library_private_types_in_public_api

import 'dart:math';

import 'package:dms/screen/sell/refund_order/component/list_history_refund_order_screen.dart';
import 'package:dms/screen/sell/sell_bloc.dart';
import 'package:dms/screen/sell/sell_event.dart';
import 'package:dms/screen/sell/sell_state.dart';
import 'package:dms/widget/custom_slider.dart';
import 'package:dms/widget/custom_widget.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../model/database/data_local.dart';
import '../../themes/colors.dart';
import '../../utils/const.dart';
import '../../utils/images.dart';
import '../../utils/utils.dart';
import '../customer/manager_customer/manager_customer_screen.dart';
import '../home/component/chart_bar.dart';
import '../personnel/component/employee_screen.dart';
import 'component/history_item_holder_screen.dart';
import 'component/history_order.dart';
import 'component/order_for_suggest/history_order_for_suggest.dart';
import 'component/product_screen.dart';
import 'contract/contract_screen.dart';
import 'order/order_sceen.dart';

class SellScreen extends StatefulWidget {
  final String userName;
  const SellScreen({Key? key,  required this.userName}) : super(key: key);

  @override
  _SellScreenState createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> with TickerProviderStateMixin{

  late SellBloc _bloc;
  late TabController tabController;
  List<String> listFilter = ['Tuần','Tháng','Năm'];
  List<String> slider = [
    'https://images.unsplash.com/photo-1465408953385-7c4627c29435?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MzV8fGZhc2hpb258ZW58MHx8MHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/flagged/photo-1574876242429-3164fb8bf4bc?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=60',
    'https://images.unsplash.com/photo-1480455624313-e29b44bbfde1?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=400&q=60',
    'https://images.unsplash.com/photo-1483118714900-540cf339fd46?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=400&q=60'
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = SellBloc(context);
    tabController = TabController(vsync: this, length: listFilter.length);
    _bloc.add(GetSellPrefsEvent());
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(.0),
      body: BlocListener<SellBloc,SellState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            print(DataLocal.listTax.length);
              if(Const.useTax == true && DataLocal.listTax.isEmpty){
                _bloc.add(GetListTax());
              }

            // if((Const.isVvHd == true || Const.isVv == true || Const.isHd == true) && (DataLocal.listVv.isEmpty || DataLocal.listHd.isEmpty)){
              // _bloc.add(GetListVVHD());
            // }
          }else if(state is GetListStatusOrderSuccess){

          }
        },
        child: BlocBuilder<SellBloc,SellState>(
          bloc: _bloc,
          builder: (BuildContext context, SellState state){
            return buildBodySells(context,state);
          },
        ),
      ),
    );
  }

  buildBodySells(BuildContext context,SellState state){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 35,bottom: 0,left: 4),
          child:  Container(
            height: 70,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(8, 0, 8,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(avatarStore),
                  backgroundColor: Colors.transparent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 5,),
                        Flexible(child: Text(
                          'Seller ${_bloc.userName}',
                          style: const TextStyle(color: subColor,fontWeight: FontWeight.bold,fontSize: 18),maxLines: 2,overflow: TextOverflow.ellipsis,),),
                        const SizedBox(height: 5,),
                        Text(
                          'ID 9368288${Random().nextInt(1000)}'
                          ,style: const TextStyle(color: Colors.grey ,fontWeight: FontWeight.normal,fontSize: 12),maxLines: 1,overflow: TextOverflow.ellipsis,),
                        const SizedBox(height: 5,),
                      ],
                    ),
                  ),
                ),
                const Icon(Icons.navigate_next,color: Colors.grey,)
              ],
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16,right: 16,top: 6,bottom: 12),
                    child: Container(
                      height: 230,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                          border: Border.all(color: grey,width: .8)
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 40,
                            width: double.infinity,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: SizedBox(
                                    height: 40,
                                    width: 210,
                                    child: TabBar(
                                      controller: tabController,
                                      unselectedLabelColor: Colors.grey.withOpacity(0.8),
                                      labelColor: Colors.red,
                                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                                      isScrollable: false,
                                      indicatorPadding: const EdgeInsets.all(0),
                                      indicatorColor: Colors.red,
                                      dividerColor: Colors.red,automaticIndicatorColorAdjustment: true,
                                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                                      indicator: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            style: BorderStyle.solid,
                                            color: Colors.red,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      tabs: List<Widget>.generate(listFilter.length, (int index) {
                                        return Tab(
                                          child: Text(listFilter[index].toString(),style: const TextStyle(fontSize: 12),),
                                        );
                                      }),
                                      onTap: (index){
                                        // setState(() {
                                        //   tabIndex = index;
                                        // });
                                      },
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const Padding(
                                  padding: EdgeInsets.only(right: 12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('10600',style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),
                                      SizedBox(width: 5,),
                                      Text('view',style: TextStyle(color: Colors.grey,fontSize: 13),),
                                    ],),
                                )
                              ],
                            ),
                          ),
                          const Expanded(child: ChartBarSells()),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16,top: 10,bottom: 10),
                    child: Text('Danh mục menu'.toUpperCase(),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                  ),
                  buildTitle('Đặt đơn'),
                  buildButton(title: 'Tạo đơn hàng mới',icons:  MdiIcons.cartOutline,lock:  Const.createNewOrder == true ? false : true, onTap: (){
                    if(Const.createNewOrder == true){
                      PersistentNavBarNavigator.pushNewScreen(context, screen: const OrderScreen(),withNavBar: false);
                    }else{
                      Utils.showUpgradeAccount(context);
                    }
                  },),
                  buildButton(title:  _bloc.accessCode > 0 ? 'Quản lý nhân viên đặt hàng' : 'Lịch sử đặt hàng',icons:  int.parse(_bloc.accessCode.toString()) > 0 ? MdiIcons.orderBoolAscendingVariant :MdiIcons.history ,lock: Const.historyOrder == true ? false : true, onTap: (){
                    if(Const.historyOrder == true){
                      if(int.parse(_bloc.accessCode.toString()) > 0){
                        PersistentNavBarNavigator.pushNewScreen(context, screen:const EmployeeScreen(typeView: 1,),withNavBar: true);
                      }else{
                        PersistentNavBarNavigator.pushNewScreen(context, screen: HistoryOrderScreen(userId:  _bloc.userCode.toString()),withNavBar: true);
                      }
                    }else{
                      Utils.showUpgradeAccount(context);
                    }
                  },),
                  buildButton(title: 'Đề nghị xuất bán hàng cho CH',icons: MdiIcons.storeCheckOutline, lock:  Const.createOrderFormStore == true ? false : true, onTap: (){
                    if(Const.createNewOrderForSuggest == true){
                      PersistentNavBarNavigator.pushNewScreen(context, screen: HistoryOrderForSuggestScreen(userId: _bloc.userCode.toString(),),withNavBar: false);
                    }else{
                      Utils.showUpgradeAccount(context);
                    }
                  },),
                  const SizedBox(height: 10,),
                  buildTitle('Hàng bán trả lại & Phiếu giữ hàng'),
                  buildButton(title: 'Hàng bán trả lại',icons:  MdiIcons.arrangeSendToBack,lock:  Const.refundOrder == true? false : true,onTap: (){
                    if(Const.refundOrder == true){
                      PersistentNavBarNavigator.pushNewScreen(context, screen: const ListHistoryRefundOrderScreen(),withNavBar: false);
                    }else{
                      Utils.showUpgradeAccount(context);
                    }
                  },),
                  buildButton(title: 'Phiếu giữ hàng',icons: EneftyIcons.save_2_outline,lock: Const.infoProduction == true ? false : true,onTap: (){
                    if(Const.historyKeepCardList == true){
                      PersistentNavBarNavigator.pushNewScreen(context, screen: HistoryItemHolderScreen(userId: _bloc.userCode.toString(),),withNavBar: true);
                    }else{
                      Utils.showUpgradeAccount(context);
                    }
                  },),
                  const SizedBox(height: 10,),
                  buildTitle('Hợp đồng'),
                  buildButton(title: 'Hợp đồng',icons: EneftyIcons.ticket_star_outline,lock: Const.contract == true ? false : true,onTap: (){
                    if(Const.contract == true){
                      PersistentNavBarNavigator.pushNewScreen(context, screen: ContractScreen(),withNavBar: true);
                    }else{
                      Utils.showUpgradeAccount(context);
                    }
                  },),
                  const SizedBox(height: 10,),
                  buildTitle('Khách hàng & Sản phẩm'),
                  buildButton(title: 'Thông tin khách hàng',icons:  Icons.account_box_outlined,lock:  Const.infoCustomerSell == true? false : true, onTap: (){
                    if(Const.infoCustomerSell == true){
                      PersistentNavBarNavigator.pushNewScreen(context, screen:const ManagerCustomerScreen(),withNavBar: false);
                    }else{
                      Utils.showUpgradeAccount(context);
                    }
                  },),
                  buildButton(title: 'Thông tin sản phẩm',icons: MdiIcons.professionalHexagon,lock: Const.infoProduction == true ? false : true,onTap: (){
                    if(Const.infoProduction == true){
                      PersistentNavBarNavigator.pushNewScreen(context, screen:const ProductScreen(),withNavBar: true);
                    }else{
                      Utils.showUpgradeAccount(context);
                    }
                  },),
                  const SizedBox(height: 75,)
                ],
            ),
          ),
        ),
        const SizedBox(height: 40,)
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
      padding: const EdgeInsets.fromLTRB(16, 35, 16,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: InkWell(
                          onTap: (){
                            // Utils.pushAndRemoveUtilKeepFirstPage(context, InfoCompanyPage(
                            //   username:  _mainBloc.userName,
                            //   listInfoUnitsID: _mainBloc.listInfoUnitsID,
                            //   listInfoUnitsName: _mainBloc.listInfoUnitsName,
                            //   currentCompanyName: _mainBloc.currentCompanyName,
                            //   currentCompanyID: _mainBloc.currentCompanyID,
                            //   getDF: true,
                            // ));
                          },
                          child: Text(
                            Const.companyName != '' ? Const.companyName : "Công ty ABC - Demo Công ty ABC - Demo Công ty ABC - Demo".toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                            maxLines: 1,overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5,),
                Text(
                  Const.storeName != '' ? Const.storeName : Const.unitName,
                  style: const TextStyle(fontSize: 11,color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            //onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (context)=> NotificationPage())),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Stack(
                clipBehavior: Clip.none, alignment: Alignment.center,
                children: <Widget>[
                  Icon(
                    MdiIcons.bellOutline,
                    size: 25,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  buildSlider(){
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: slider.isEmpty ? Container() : CustomCarousel(items: slider,),
    );
  }
}
