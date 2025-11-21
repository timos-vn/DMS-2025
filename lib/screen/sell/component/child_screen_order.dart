import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../model/network/response/list_history_order_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../sell_bloc.dart';
import '../sell_event.dart';
import '../sell_state.dart';
import 'history_order_detail_screen.dart';

class ChildScreenOrder extends StatefulWidget {
  final List<Values> listOrder;
  final int i;
  final String userId;
  final SellBloc bloc;

  const ChildScreenOrder({Key? key, required this.listOrder,required this.i,required this.userId,required this.bloc}) : super(key: key);

  @override
  State<ChildScreenOrder> createState() => _ChildScreenOrderState();
}

class _ChildScreenOrderState extends State<ChildScreenOrder> {

  // late SellBloc _bloc;
  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  final bool _hasReachedMax = true;

  @override
  void initState() {
    super.initState();
    widget.bloc.statusOrderList = widget.i;
    widget.bloc.list.clear();
    widget.bloc.add(GetListHistoryOrder(
      status: widget.i,
      dateFrom: Const.dateFrom,
      dateTo: Const.dateTo,
      userId: widget.userId,
      typeLetterId: 'ORDERLIST',
    ));

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && widget.bloc.isScroll == true) {
        widget.bloc.add(GetListHistoryOrder(
          status: widget.bloc.statusOrderList,
          dateFrom: Const.dateFrom,
          dateTo: Const.dateTo,
          isLoadMore: true,
          userId: widget.userId,
          typeLetterId: 'ORDERLIST',
        ));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SellBloc,SellState>(
        bloc: widget.bloc,
        listener: (context, state){
          if(state is GetPrefsSuccess){
          }
          else if(state is DeleteOrderSuccess){
            // widget.bloc.add(GetListHistoryOrder(status: widget.i,dateFrom: Const.dateFrom, dateTo: Const.dateTo,userId:  widget.userId));
          }
        },
        child: BlocBuilder(
          bloc: widget.bloc,
          builder: (BuildContext context, SellState state){
            return Stack(
              children: [
                ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return _buildOrderCard(context, index);
                  },
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
                  itemCount: widget.bloc.list.length,
                ),
                Visibility(
                  visible: state is GetListHistoryOrderEmpty,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Chưa có đơn hàng nào',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Danh sách đơn hàng sẽ hiển thị ở đây',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: state is SellLoading,
                  child: const PendingAction(),
                ),
              ],
            );
          },
        ),
      ) ,
    );
  }

  Widget _buildOrderCard(BuildContext context, int index) {
    final order = widget.bloc.list[index];
    final statusColor = _getStatusColor(order.status.toString());
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: HistoryOrderDetailScreen(
            sttRec: order.sttRec,
            title: order.tenKh,
            status: (order.status.toString().trim() != "0" && order.status.toString().trim() != "1") ? false : true,
            approveOrder: true,
            dateOrder: order.ngayCt.toString(),
            codeCustomer: order.maKh.toString().trim(),
            nameCustomer: order.tenKh.toString().trim(),
            addressCustomer: order.diaChiKH.toString().trim(),
            phoneCustomer: order.dienThoaiKH.toString().trim(),
            dateEstDelivery: order.dateEstDelivery.toString(),
            statusName: order.statusname?.toString().trim(),
          ),
          withNavBar: false,
        ).then((value) {
          if (value == Const.REFRESH) {
            widget.bloc.add(GetListHistoryOrder(
              status: widget.i,
              dateFrom: Const.dateFrom,
              dateTo: Const.dateTo,
              userId: widget.userId,
              typeLetterId: 'ORDERLIST',
            ));
          }
        }),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                offset: const Offset(0, 1),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section - Compact
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon Avatar - Smaller
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getStatusIcon(order.status.toString()),
                        color: statusColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Customer Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.tenKh ?? 'N/A',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              letterSpacing: 0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 11,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                Utils.parseStringDateToString(
                                  order.ngayCt.toString(),
                                  Const.DATE_SV,
                                  Const.DATE_FORMAT_1,
                                ),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status Badge - Compact
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.statusname ?? 'N/A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content Section - Compact
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone Number - Inline
                    _buildCompactInfoRow(
                      icon: Icons.phone_rounded,
                      value: order.dienThoaiKH ?? 'N/A',
                    ),
                    const SizedBox(height: 6),
                    // Address - Inline
                    _buildCompactInfoRow(
                      icon: Icons.location_on_rounded,
                      value: order.diaChiKH ?? 'N/A',
                      maxLines: 1,
                    ),
                    // Delivery Date - Inline
                    if (order.dateEstDelivery != null && order.dateEstDelivery.toString().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _buildCompactInfoRow(
                        icon: Icons.local_shipping_rounded,
                        value: Utils.parseStringDateToString(
                          order.dateEstDelivery.toString(),
                          Const.DATE_SV,
                          Const.DATE_FORMAT_1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Footer with Total Amount - Compact
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng tiền',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${Utils.formatMoneyStringToDouble(order.tTtNt ?? 0)} VNĐ',
                      style: TextStyle(
                        color: subColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactInfoRow({
    required IconData icon,
    required String value,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.trim()) {
      case '0':
        return Icons.schedule_rounded;
      case '1':
        return Icons.autorenew_rounded;
      case '2':
        return Icons.check_circle_rounded;
      case '3':
        return Icons.cancel_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }


  Color _getStatusColor(String status) {
    switch (status.trim()) {
      case '0':
        return const Color(0xFF2196F3); // Blue - Chờ xử lý
      case '1':
        return const Color(0xFFFF9800); // Orange - Đang xử lý
      case '2':
        return const Color(0xFF4CAF50); // Green - Hoàn thành
      case '3':
        return const Color(0xFF9E9E9E); // Grey - Đã hủy
      default:
        return Colors.grey;
    }
  }
}
