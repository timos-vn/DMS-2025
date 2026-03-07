import 'dart:async';
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
  int _previousTabIndex = -1;
  
  // Search functionality
  bool _isSearchMode = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  final FocusNode _searchFocusNode = FocusNode();
  
  // Animation controllers for search
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;
  late Animation<double> _bounceAnimation;

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
    
    // Initialize search animation controllers
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _searchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.elasticOut,
    ));
    
    // Add listener to search controller for suffix icon
    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    // Listener để gọi API khi chuyển tab
    tabController.addListener(_onTabChanged);

    // Gọi API cho tab đầu tiên khi khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (DataLocal.listStatusToOrder.isNotEmpty) {
        _previousTabIndex = 0;
        final initialStatus = int.parse(DataLocal.listStatusToOrder[0].status.toString());
        _bloc.statusOrderList = initialStatus;
        _bloc.list.clear();
        _bloc.add(GetListHistoryOrder(
          status: initialStatus,
          dateFrom: Const.dateFrom,
          dateTo: Const.dateTo,
          userId: widget.userId,
          typeLetterId: 'ORDERLIST',
        ));
      }
    });

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(GetListHistoryOrder(
            status: _bloc.statusOrderList,
            dateFrom: Const.dateFrom,
            dateTo: Const.dateTo,
            isLoadMore: true,
            userId:  widget.userId, 
            typeLetterId: 'ORDERLIST',
            firstElement: _isSearchMode && _searchController.text.trim().isNotEmpty 
                ? _searchController.text.trim() 
                : null,
        ));
      }
    });
  }

  void _onTabChanged() {
    if (!tabController.indexIsChanging) {
      // Chỉ gọi API khi đã chuyển tab xong và index thực sự thay đổi
      final newIndex = tabController.index;
      if (_previousTabIndex != newIndex) {
        _previousTabIndex = newIndex;
        final status = int.parse(DataLocal.listStatusToOrder[newIndex].status.toString());
        _bloc.statusOrderList = status;
        _bloc.list.clear();
        _bloc.add(GetListHistoryOrder(
          status: status,
          dateFrom: Const.dateFrom,
          dateTo: Const.dateTo,
          userId: widget.userId,
          typeLetterId: 'ORDERLIST',
          firstElement: _isSearchMode && _searchController.text.trim().isNotEmpty 
              ? _searchController.text.trim() 
              : null,
        ));
      }
    }
  }

  @override
  void dispose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    _searchAnimationController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      _performSearch(value);
    });
  }
  
  void _performSearch(String searchText) {
    if (mounted) {
      _bloc.list.clear();
      _bloc.add(GetListHistoryOrder(
        status: _bloc.statusOrderList,
        dateFrom: Const.dateFrom,
        dateTo: Const.dateTo,
        userId: widget.userId,
        typeLetterId: 'ORDERLIST',
        firstElement: searchText.trim().isEmpty ? null : searchText.trim(),
      ));
    }
  }
  
  void _toggleSearchMode() {
    setState(() {
      _isSearchMode = !_isSearchMode;
      if (_isSearchMode) {
        _searchAnimationController.forward();
        // Focus vào search field khi mở
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
        });
      } else {
        _searchAnimationController.reverse();
        // Clear search và reset khi đóng
        _searchController.clear();
        _debounceTimer?.cancel();
        _bloc.list.clear();
        _bloc.add(GetListHistoryOrder(
          status: _bloc.statusOrderList,
          dateFrom: Const.dateFrom,
          dateTo: Const.dateTo,
          userId: widget.userId,
          typeLetterId: 'ORDERLIST',
        ));
      }
    });
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
              _bloc.add(GetListHistoryOrder(
                status: 0,
                dateFrom: Const.dateFrom, 
                dateTo: Const.dateTo,
                userId: widget.userId, 
                typeLetterId: 'ORDERLIST',
                firstElement: _isSearchMode && _searchController.text.trim().isNotEmpty 
                    ? _searchController.text.trim() 
                    : null,
              ));
              _pageController.animateToPage(
                  0, duration: const Duration(milliseconds: 500), curve: Curves.ease);
            } else {
              _bloc.list.clear();
              _bloc.add(GetListHistoryOrder(
                status: 2,
                dateFrom: Const.dateFrom, 
                dateTo: Const.dateTo,
                userId: widget.userId, 
                typeLetterId: 'ORDERLIST',
                firstElement: _isSearchMode && _searchController.text.trim().isNotEmpty 
                    ? _searchController.text.trim() 
                    : null,
              ));
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
              child: SizedBox.expand(
                child: TabBarView(
                  controller: tabController,
                  children: List<Widget>.generate(
                    DataLocal.listStatusToOrder.length,
                    (int index) {
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
                    },
                  ),
                ),
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
                statusName: listOrder[index].statusname?.toString().trim(),
                approveOrder: true,
                dateOrder: listOrder[index].ngayCt.toString(),
                codeCustomer: listOrder[index].maKh.toString().trim(),
                nameCustomer:  listOrder[index].tenKh.toString().trim(),
                addressCustomer:  listOrder[index].diaChiKH.toString().trim(),
                phoneCustomer:  listOrder[index].dienThoaiKH.toString().trim(),
                dateEstDelivery: listOrder[index].dateEstDelivery.toString(),
              ),withNavBar: false).then((value){
                if(value == Const.REFRESH){
                  _bloc.add(GetListHistoryOrder(
                    status: i,
                    dateFrom: Const.dateFrom, 
                    dateTo: Const.dateTo,
                    userId: widget.userId, 
                    typeLetterId: 'ORDERLIST',
                    firstElement: _isSearchMode && _searchController.text.trim().isNotEmpty 
                        ? _searchController.text.trim() 
                        : null,
                  ));
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
                  child: AnimatedBuilder(
                    animation: _searchAnimation,
                    builder: (context, child) {
                      return _isSearchMode
                          ? Transform.scale(
                              scale: _bounceAnimation.value,
                              child: Opacity(
                                opacity: _searchAnimation.value,
                                child: Container(
                                  height: 40,
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    focusNode: _searchFocusNode,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Tìm kiếm đơn hàng...',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 16,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      suffixIcon: _searchController.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              onPressed: () {
                                                _searchController.clear();
                                                _onSearchChanged('');
                                              },
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: const EdgeInsets.only(top: 5.5),
                                    ),
                                    onChanged: _onSearchChanged,
                                  ),
                                ),
                              ),
                            )
                          : Opacity(
                              opacity: 1 - _searchAnimation.value,
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
                            );
                    },
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: _toggleSearchMode,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Icon(
                            _isSearchMode ? Icons.close_rounded : Icons.search_rounded,
                            key: ValueKey(_isSearchMode ? 'close' : 'search'),
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInOutCubic,
                      switchOutCurve: Curves.easeInOutCubic,
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: !_isSearchMode
                          ? InkWell(
                              key: const ValueKey('filter'),
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
                                    firstElement: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
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
                            )
                          : const SizedBox.shrink(key: ValueKey('empty')),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: show == true && !_isSearchMode
                ? Container(
                    key: const ValueKey('tabbar'),
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(4, 0, 4, 8),
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
                      isScrollable: DataLocal.listStatusToOrder.length > 6,
                      tabAlignment: DataLocal.listStatusToOrder.length <= 6
                          ? TabAlignment.fill 
                          : TabAlignment.start,
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
                  )
                : const SizedBox.shrink(key: ValueKey('tabbar_empty')),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalTab(dynamic statusItem, int index) {
    final status = statusItem.status?.toString().trim() ?? '';
    final statusName = statusItem.statusname?.toString() ?? '';
    final tabInfo = _getTabInfo(status);
    final totalTabs = DataLocal.listStatusToOrder.length;
    final isScrollable = totalTabs > 6;
    
    return Tab(
      height: 68,
      child: AnimatedBuilder(
        animation: tabController,
        builder: (context, child) {
          final isSelected = tabController.index == index;
          
          // Tối ưu padding dựa trên số lượng tab
          final horizontalPadding = isScrollable ? 16.0 : 12.0;
          
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  tabInfo['icon'] as IconData,
                  size: isSelected ? 24 : 22,
                  color: isSelected 
                      ? subColor 
                      : Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 5),
                Flexible(
                  child: Text(
                    statusName,
                    style: TextStyle(
                      fontSize: isScrollable ? 11.5 : 11.0,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected 
                          ? subColor 
                          : Colors.white.withOpacity(0.9),
                      letterSpacing: 0.1,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    softWrap: true,
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
