import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../model/database/data_local.dart';
import '../../../model/network/response/list_history_order_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../../options_input/options_input_screen.dart';
import 'child_screen_order.dart';
import 'history_order_detail_screen.dart';
import '../sell_bloc.dart';
import '../sell_event.dart';
import '../sell_state.dart';


class HistoryOrderScreen extends StatefulWidget {

  final String userId;

  const HistoryOrderScreen({Key? key, required this.userId}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HistoryOrderScreenState createState() => _HistoryOrderScreenState();
}

class _HistoryOrderScreenState extends State<HistoryOrderScreen>  with TickerProviderStateMixin {

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
    // _bloc.dateFrom =  DateTime.now().add(const Duration(days: -7));
    // _bloc.dateTo =  DateTime.now();
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
            userId:  widget.userId, typeLetterId: 'ORDERLIST'
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
              _bloc.add(GetListHistoryOrder(status: 0,dateFrom: Const.dateFrom, dateTo: Const.dateTo,userId:  widget.userId, typeLetterId: 'ORDERLIST'));
              _pageController.animateToPage(
                  0, duration: const Duration(milliseconds: 500), curve: Curves.ease);
            } else {
              _bloc.list.clear();
              _bloc.add(GetListHistoryOrder(status: 2,dateFrom: Const.dateFrom, dateTo: Const.dateTo,userId:  widget.userId, typeLetterId: 'ORDERLIST'));
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
                          // tabController.addListener(() {
                          //   setState(() {
                          //     _bloc.statusOrderList = tabController.index;
                          //   });
                          //
                          // });
                          // _bloc.statusOrderList = int.parse(_bloc.listStatusOrder[i].status.toString());
                          // _bloc.add(GetListHistoryOrder(status: i,dateFrom: _bloc.dateFrom, dateTo: _bloc.dateTo,userId:  widget.userId));
                          return ChildScreenOrder(listOrder: _bloc.list,i: int.parse(DataLocal.listStatusToOrder[index].status.toString()),userId: widget.userId, bloc: _bloc,);
                          //   buildPageReport(context, _bloc.list, index);
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
              onTap: ()=>PersistentNavBarNavigator.pushNewScreen(context, screen: HistoryOrderDetailScreen(
                sttRec: listOrder[index].sttRec,
                title: listOrder[index].tenKh,
                status: (i != 0 && i != 1) ? false : true,
                dateOrder: listOrder[index].ngayCt.toString(),
                codeCustomer: listOrder[index].maKh.toString().trim(),
                nameCustomer:  listOrder[index].tenKh.toString().trim(),
                addressCustomer:  listOrder[index].diaChiKH.toString().trim(),
                phoneCustomer:  listOrder[index].dienThoaiKH.toString().trim(),
                dateEstDelivery: listOrder[index].dateEstDelivery.toString(),
              ),withNavBar: false).then((value){
                if(value == Const.REFRESH){
                  _bloc.add(GetListHistoryOrder(status: i,dateFrom: Const.dateFrom, dateTo: Const.dateTo,userId:  widget.userId, typeLetterId: 'ORDERLIST'));
                }
              }),
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
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(2, 4),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [subColor, Color.fromARGB(255, 150, 185, 229)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 12, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Lịch sử đơn hàng",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => OptionsFilterDate(
                      dateFrom: Const.dateFrom.toString(),
                      dateTo: Const.dateTo.toString(),
                    ),
                  ).then((value) {
                    if (value != 'CANCEL' && value != null) {
                      Const.dateFrom = Utils.parseStringToDate(value[3], Const.DATE_SV_FORMAT);
                      Const.dateTo = Utils.parseStringToDate(value[4], Const.DATE_SV_FORMAT);
                      _bloc.add(GetListHistoryOrder(
                        status: _bloc.statusOrderList,
                        dateFrom: Const.dateFrom,
                        dateTo: Const.dateTo,
                        userId: widget.userId,
                        typeLetterId: 'ORDERLIST',
                      ));
                    }
                  }),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.filter_list_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: show == true,
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(2),
                dividerColor: Colors.transparent,
                labelColor: subColor,
                unselectedLabelColor: Colors.white,
                labelPadding: EdgeInsets.zero,
                isScrollable: DataLocal.listStatusToOrder.length > 3,
                tabs: List<Widget>.generate(
                  DataLocal.listStatusToOrder.length,
                  (int index) {
                    return _buildVerticalTab(
                      DataLocal.listStatusToOrder[index],
                      index,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalTab(dynamic statusItem, int index) {
    final status = statusItem.status?.toString().trim() ?? '';
    final statusName = statusItem.statusname?.toString() ?? '';
    final tabInfo = _getTabInfo(status);
    
    return Tab(
      height: 48,
      child: AnimatedBuilder(
        animation: tabController,
        builder: (context, child) {
          final isSelected = tabController.index == index;
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  tabInfo['icon'] as IconData,
                  size: isSelected ? 18 : 16,
                  color: isSelected 
                      ? subColor 
                      : Colors.white.withOpacity(0.85),
                ),
                const SizedBox(height: 3),
                Flexible(
                  child: Text(
                    statusName,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected 
                          ? subColor 
                          : Colors.white.withOpacity(0.85),
                      letterSpacing: 0.05,
                      height: 1.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, dynamic> _getTabInfo(String status) {
    switch (status) {
      case '0':
        return {
          'icon': Icons.schedule_rounded,
          'color': const Color(0xFF2196F3),
        };
      case '1':
        return {
          'icon': Icons.autorenew_rounded,
          'color': const Color(0xFFFF9800),
        };
      case '2':
        return {
          'icon': Icons.check_circle_outline_rounded,
          'color': const Color(0xFF4CAF50),
        };
      case '3':
        return {
          'icon': Icons.cancel_outlined,
          'color': const Color(0xFF9E9E9E),
        };
      default:
        return {
          'icon': Icons.receipt_long_rounded,
          'color': Colors.grey,
        };
    }
  }
}
