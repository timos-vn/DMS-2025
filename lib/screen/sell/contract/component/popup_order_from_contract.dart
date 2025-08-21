import 'package:dms/model/network/response/contract_reponse.dart';
import 'package:dms/screen/sell/component/history_order_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class OrderListBottomSheet extends StatelessWidget {
  final List<ItemOrderFormContract> orders;
  final ContractItem contractMaster;

  const OrderListBottomSheet({super.key, required this.orders, required this.contractMaster});

  static void show(BuildContext context, List<ItemOrderFormContract> orders,ContractItem contractMaster) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderListBottomSheet(orders: orders, contractMaster: contractMaster,),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
              )
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Danh sách đơn hàng",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final delay = (index + 1) * 100;
                    return _AnimatedOrderItem(
                      order: orders[index],
                      delay: Duration(milliseconds: delay), contractMaster: contractMaster,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedOrderItem extends StatefulWidget {
  final ItemOrderFormContract order;
  final ContractItem contractMaster;
  final Duration delay;

  const _AnimatedOrderItem({required this.order,required this.contractMaster, required this.delay});

  @override
  State<_AnimatedOrderItem> createState() => _AnimatedOrderItemState();
}

class _AnimatedOrderItemState extends State<_AnimatedOrderItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);
    _offset = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(widget.delay, () => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return SlideTransition(
      position: _offset,
      child: FadeTransition(
        opacity: _opacity,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow("Số hợp đồng", order.soCt.toString()),
              _infoRow("Mã đơn hàng", order.hiddenSttRec),
              _infoRow("Ngày order", widget.contractMaster.ngayCt.toString().split('T').first),
              Row(
                children: [
                  const Text("Trạng thái: ",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Icon(order.statusIcon, size: 18, color: order.statusColor),
                  const SizedBox(width: 6),
                  Text(order.statusName.toString(), style: TextStyle(color: order.statusColor)),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _showOrderDetailDialog(context, order,widget.contractMaster),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text("Xem chi tiết"),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  void _showOrderDetailDialog(BuildContext context, ItemOrderFormContract order, ContractItem contractMaster) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Chi tiết đơn hàng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _detailRow("Số hợp đồng", order.soCt.toString()),
              _detailRow("Mã đơn hàng", order.hiddenSttRec.toString()),
              _detailRow("Ngày order", contractMaster.ngayCt.toString().split('T').first),
              _detailRow("Trạng thái", order.statusName.toString()),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text("Đóng"),
                    ),
                  ),
                  const SizedBox(width: 15,),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton.icon(
                      onPressed: () => PersistentNavBarNavigator.pushNewScreen(context, screen: HistoryOrderDetailScreen(
                        sttRec: order.sttRecDh,
                        title: contractMaster.tenKh,
                        status: contractMaster.status == 0 ? false : true,
                        dateOrder: contractMaster.ngayCt.toString(),
                        codeCustomer: contractMaster.maKh.toString().trim(),
                        nameCustomer:  contractMaster.tenKh.toString().trim(),
                        addressCustomer: '',
                        phoneCustomer:  '',
                        dateEstDelivery: '',
                      ),withNavBar: false),
                      icon: const Icon(Icons.remove_red_eye_outlined),
                      label: const Text("Xem đơn"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
