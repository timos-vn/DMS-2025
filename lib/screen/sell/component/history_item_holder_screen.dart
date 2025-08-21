import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../model/database/data_local.dart';
import '../../../model/network/response/list_history_order_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../../options_input/options_input_screen.dart';
import 'child_item_holder_screen.dart';
import 'create_item_holder_screen.dart';
import 'get_item_holder_detail_screen.dart';
import '../sell_bloc.dart';
import '../sell_event.dart';
import '../sell_state.dart';


class HistoryItemHolderScreen extends StatefulWidget {

  final String userId;

  const HistoryItemHolderScreen({Key? key, required this.userId}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HistoryItemHolderScreenState createState() => _HistoryItemHolderScreenState();
}

class _HistoryItemHolderScreenState extends State<HistoryItemHolderScreen>  with TickerProviderStateMixin {

  late SellBloc _bloc;
  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  final bool _hasReachedMax = true;
  late PageController _pageController;
  late TabController tabController;
  bool show = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 0, vsync: this);
    _bloc = SellBloc(context);
    //Const.dateFrom =  DateTime.now().add(const Duration(days: -7));
    // Const.dateTo =  DateTime.now();
    tabController = TabController(vsync: this, length: DataLocal.listStatusToOrder.length);
    show = true;

    _scrollController = ScrollController();
    _pageController = PageController();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(GetListHistoryOrder(
            status: _bloc.statusOrderList,
            dateFrom: Const.dateFrom,
            dateTo: Const.dateTo,
            isLoadMore: true,
            userId:  widget.userId, typeLetterId: 'ITEMHOLDER'
        ));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton:Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          backgroundColor: subColor,
          onPressed: ()async{
            Navigator.push(context, MaterialPageRoute(builder: (context)=>const CreateItemHolderScreen())).then((value){
              _bloc.add(GetListHistoryOrder(status: 0,dateFrom:  Const.dateFrom, dateTo:  Const.dateTo,userId:  _bloc.userCode, typeLetterId: 'ITEMHOLDER'));
            });
          },
          child: const Icon(Icons.add,color: Colors.white,),
        ),
      ),
      body: BlocListener<SellBloc,SellState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            // _bloc.add(GetListStatusOrder());
          }
          else if(state is GetListStatusOrderSuccess){
            // tabController = TabController(vsync: this, length: _bloc.listStatusOrder.length);
            // show = true;
          }

          else if(state is GetListHistoryOrderSuccess){
            show = true;
          }
          else if(state is ChangePageViewSuccess) {
            if (state.valueChange == 0) {
              _bloc.list.clear();
              _bloc.add(GetListHistoryOrder(status: 0,dateFrom:Const.dateFrom, dateTo: Const.dateTo,userId:  widget.userId, typeLetterId: 'ITEMHOLDER'));
              _pageController.animateToPage(
                  0, duration: const Duration(milliseconds: 500), curve: Curves.ease);
            } else {
              _bloc.list.clear();
              _bloc.add(GetListHistoryOrder(status: 2,dateFrom:Const.dateFrom, dateTo: Const.dateTo,userId:  widget.userId, typeLetterId: 'ITEMHOLDER'));
              _pageController.animateToPage(
                  1, duration: const Duration(milliseconds: 500), curve: Curves.ease);
            }
          }
          else if(state is SellFailure){
            Utils.showCustomToast(context, Icons.warning_amber_outlined, state.error);
          }
        },
        child: BlocBuilder(
          bloc: _bloc,
          builder: (BuildContext context, SellState state){
            return  Stack(
              children: [
                buildBody(context,state),
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,SellState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          const SizedBox(height: 10,),
          Expanded(
            child: RefreshIndicator(
              color: mainColor,
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 2));
                // _bloc.add(GetListStageStatistic(unitId: widget.unitId,idStageStatistic:idStageStatistic.toString(),));
              },
              child: SizedBox(
                height: double.infinity,width: double.infinity,
                child: TabBarView(
                    controller: tabController,
                    children: List<Widget>.generate(DataLocal.listStatusToOrder.length, (int index) {
                      for (int i = 0; i <= DataLocal.listStatusToOrder.length; i++) {
                        if (i == index) {
                          return ChildItemHolderScreen(listOrder: _bloc.list,
                            i: int.parse(DataLocal.listStatusToOrder[index].status.toString()),
                            userId: widget.userId, bloc: _bloc,);
                        }
                      }
                      return const Text('');
                    })),
              ),
            ),
          ),const SizedBox(height: 10,),
        ],
      ),
    );
  }

  Widget buildPageReport(BuildContext context,  List<Values> listOrder, int i) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: ListView.separated(
          padding: EdgeInsets.zero,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: (){
                PersistentNavBarNavigator.pushNewScreen(context, screen: GetItemHolderDetail(
                  sttRec: _bloc.list[index].sttRec.toString(),
                ),withNavBar: false).then((value){
                  if(value == Const.REFRESH){
                    _bloc.add(GetListHistoryOrder(status: i,dateFrom:Const.dateFrom, dateTo: Const.dateTo,userId:  widget.userId, typeLetterId: 'ITEMHOLDER'));
                  }
                });
            },
              child: Card(
                elevation: 10,
                shadowColor: Colors.blueGrey.withOpacity(0.5),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text('${_bloc.list[index].tenKh}', style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 13),)),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Ngày tạo ',
                                            style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                                0xff555a55)),
                                          ),
                                          TextSpan(
                                            text: Utils.parseStringDateToString('${_bloc.list[index].ngayCt}', Const.DATE_SV, Const.DATE_FORMAT_1),
                                            style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3,),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.phone_iphone_rounded,color: Colors.grey,size: 12,),
                                          const SizedBox(width: 3,),
                                          Text(_bloc.list[index].dienThoaiKH??'null', style: const TextStyle(color: Colors.grey,fontSize: 12),),
                                        ],
                                      ),
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Ngày giao ',
                                            style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                                0xff555a55)),
                                          ),
                                          TextSpan(
                                            text: Utils.parseStringDateToString('${_bloc.list[index].dateEstDelivery}', Const.DATE_SV, Const.DATE_FORMAT_1),
                                            style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3,),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,color: Colors.grey,size: 12,),
                                    const SizedBox(width: 3,),
                                    Expanded(child: Text('${_bloc.list[index].diaChiKH}', style:const  TextStyle(color: Colors.grey,fontSize: 12),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tổng tiền: ${Utils.formatMoneyStringToDouble(_bloc.list[index].tTtNt??0)} VNĐ', style: const TextStyle(color: Colors.red,fontSize: 12),),
                          Text('${_bloc.list[index].statusname}', style: const TextStyle(color: Colors.black,fontSize: 12),),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) => Container(),
          itemCount: _bloc.list.length),
    );
  }

  buildAppBar(){
    return Container(
      height: 153,
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
      child: Column(
        children: [
          Row(
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
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 16),
                  child: const Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Lịch sử phiếu giữ hàng",
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                      maxLines: 1,overflow: TextOverflow.fade,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: ()=>  showDialog(
                    context: context,
                    builder: (context) => const OptionsFilterDate()).then((value){
                  if(value != 'CANCEL'){
                    Const.dateFrom =  Utils.parseStringToDate(value[3], Const.DATE_SV_FORMAT);
                    Const.dateTo =  Utils.parseStringToDate(value[4], Const.DATE_SV_FORMAT);
                    _bloc.add(GetListHistoryOrder(status: _bloc.statusOrderList,dateFrom:Const.dateFrom, dateTo: Const.dateTo,userId:  widget.userId, typeLetterId: 'ITEMHOLDER'));
                  }
                }),
                child: const SizedBox(
                  width: 40,
                  height: 50,
                  child: Icon(
                    Icons.event,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
          Visibility(
            visible: show == true,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Container(
                  padding: const EdgeInsets.all(4),
                  height: 43,
                  width: double.infinity,
                  decoration: BoxDecoration(border: Border.all(width: 0.8, color: white), borderRadius: const BorderRadius.all(Radius.circular(16))),
                  child: TabBar(
                    controller: tabController,
                    unselectedLabelColor: white,
                    labelColor: orange,
                    labelStyle: const TextStyle(fontWeight: FontWeight.normal),
                    isScrollable: DataLocal.listStatusToOrder.length <= 3 ? false : true,
                    indicator:const BoxDecoration(color: white, borderRadius:  BorderRadius.all(Radius.circular(12))),
                    tabs: List<Widget>.generate(DataLocal.listStatusToOrder.length, (int index) {
                      return  Tab(
                        text: DataLocal.listStatusToOrder[index].statusname.toString(),
                      );
                    }),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
