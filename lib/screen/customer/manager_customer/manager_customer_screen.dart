// ignore_for_file: library_private_types_in_public_api

import 'package:dms/screen/customer/manager_customer/customer_recently_page/customer_recently_screen.dart';
import 'package:dms/screen/customer/search_customer/search_customer_screen.dart';
import 'package:dms/themes/colors.dart';
import 'package:flutter/material.dart';

import '../add_new_customer/new_customer_screen.dart';
import 'customer_all_page/customer_all_screen.dart';


class ManagerCustomerScreen extends StatefulWidget {
  const ManagerCustomerScreen({Key? key}) : super(key: key);

  @override
  _ManagerCustomerScreenState createState() => _ManagerCustomerScreenState();
}

class _ManagerCustomerScreenState extends State<ManagerCustomerScreen> with TickerProviderStateMixin{

  List<String> categories = ["Recently", "All"];
  late TabController tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(vsync:this,length: categories.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildPage(context),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(bottom: 60),
      //   child: FloatingActionButton(
      //     onPressed:()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> const AddNewCustomerScreen())),
      //     backgroundColor: subColor,
      //     tooltip: 'Increment',
      //     child: const Icon(Icons.add,color: Colors.white,),
      //   ),
      // ),
    );
  }
  Widget buildPage(BuildContext context){
    return Column(
      children: [
        Container(
          color: subColor,
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
          child: Row(
            children: [
              InkWell(
                  onTap:()=>Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white,size: 25,)),
              const Expanded(
                child: Center(
                  child: Text('Quản lý khách hàng',
                    style: TextStyle(
                      color: white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              InkWell(
                  onTap:()=>Navigator.of(context).push(MaterialPageRoute(builder: (context)=> SearchCustomerScreen(allowCustomerSearch: false, inputQuantity: false,))),
                  child: const Icon(Icons.search,color: white,)),
            ],
          ),
        ),
        Container(
          color: subColor,
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 8),
          child: Container(
              padding: const EdgeInsets.all(2),
              height: 45,
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 0.8,
                      color: white
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  color: subColor
              ),
              child: TabBar(
                controller: tabController,
                unselectedLabelColor: white,

                labelColor: orange,
                labelStyle: const TextStyle(fontWeight: FontWeight.normal),
                isScrollable: false,
                indicatorPadding: const EdgeInsets.all(4),
                indicator: const BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.all(Radius.circular(16))
                ),
                tabs:  List<Widget>.generate(categories.length, (int index){
                  return Tab(
                    text: categories[index].toString(),);
                }),
              )
          ),
        ),
        // const SizedBox(height: 10,),
        Expanded(
          child: TabBarView(
              controller: tabController,
              children: List<Widget>.generate(categories.length, (int index){
                if(index == 0){
                  return const CustomerRecentlyScreen();
                }else {
                  return const ManagerCustomerAllScreen();
                }
              })
          ),
        ),
      ],
    );
  }
}
