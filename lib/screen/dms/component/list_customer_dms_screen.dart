// ignore_for_file: library_private_types_in_public_api

import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../model/network/response/manager_customer_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/images.dart';
import '../../customer/detail_info_customer/detail_customer_screen.dart';
import '../../customer/manager_customer/customer_all_page/customer_all_bloc.dart';
import '../../customer/manager_customer/customer_all_page/customer_all_event.dart';
import '../../customer/manager_customer/customer_all_page/customer_all_sate.dart';
import '../../customer/search_customer/search_customer_screen.dart';


class ListCustomerDMSScreen extends StatefulWidget {
  const ListCustomerDMSScreen({Key? key}) : super(key: key);

  @override
  _ListCustomerDMSScreenState createState() => _ListCustomerDMSScreenState();
}

class _ListCustomerDMSScreenState extends State<ListCustomerDMSScreen> {

  late ManagerCustomerAllBloc _bloc;
  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  bool _hasReachedMax = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = ManagerCustomerAllBloc(context);
    _bloc.add(GetPrefs());
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(GetListCustomerAll(isLoadMore: true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ManagerCustomerAllBloc,ManagerCustomerAllState>(
        bloc: _bloc,
        listener: (context,state){
          if (state is ManagerCustomerAllFailure){}
          //Utils.showErrorSnackBar(context, state.error);

          if(state is GetPrefsSuccess){
            _bloc.add(GetListCustomerAll());
          }
        },
        child: BlocBuilder<ManagerCustomerAllBloc,ManagerCustomerAllState>(
          bloc: _bloc,
          builder: (BuildContext context, ManagerCustomerAllState state){
            return Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is GetLisCustomerAllEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả !!!',style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is ManagerCustomerAllLoading,
                  child: const PendingAction(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,ManagerCustomerAllState state){
    int length = _bloc.list.length;
    if (state is GetLisCustomerAllSuccess) {
      _hasReachedMax = length < _bloc.currentPage * 20;
    }
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              controller: _scrollController,
              // physics: const AlwaysScrollableScrollPhysics(),
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: const Divider(
                    height: 0.5,
                  ),
                );
              },
              shrinkWrap: true,
              itemCount: length == 0
                  ? length
                  : _hasReachedMax ? length : length + 1,
              itemBuilder: (context, index) {
                return index >= length
                    ? Container(
                  height: 100.0,
                  color: white,
                  child: const PendingAction(),
                )
                    : GestureDetector(
                      onTap: ()=>PersistentNavBarNavigator.pushNewScreen(context, screen: DetailInfoCustomerScreen(idCustomer: _bloc.list[index].customerCode.toString().trim(),),withNavBar: false),
                      child: Card(
                        elevation: 2,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16))
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8,right: 8,top: 16,bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 40,height: 40,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(22)),
                                  child: Hero(
                                      tag: index,
                                      /*semanticContainer: true,
                                                margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),*/
                                      child: Image.asset(avatarRequest,
                                        fit: BoxFit.cover,
                                        height: 40,
                                      )
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10,),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _bloc.list[index].customerName.toString(),
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(fontWeight: FontWeight.bold,color: blue),
                                    ),
                                    const SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,size: 12,color: grey,),
                                        const SizedBox(width: 4,),
                                        Flexible(
                                          child: Text(
                                            _bloc.list[index].address.toString(),
                                            style: const TextStyle(fontSize: 12,color: grey,),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone,size: 12,color: grey,),
                                        const SizedBox(width: 4,),
                                        Text(
                                          _bloc.list[index].phone.toString(),
                                          style: const TextStyle(fontSize: 12,color: grey,),
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
              },
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
                "Danh sách khách hàng",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: (){
              PersistentNavBarNavigator.pushNewScreen(context, screen: SearchCustomerScreen(selected: true,typeName: false,allowCustomerSearch: true, inputQuantity: false,),withNavBar: false).then((value){
                if(value != null){
                  ManagerCustomerResponseData infoCustomer = value;
                  PersistentNavBarNavigator.pushNewScreen(context, screen: DetailInfoCustomerScreen(idCustomer: infoCustomer.customerCode.toString().trim(),),withNavBar: false);
                }
              });
            },
            child:const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.search,
                size: 25,
                color:Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
