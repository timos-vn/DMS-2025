import 'package:dms/model/network/response/contract_reponse.dart';
import 'package:dms/screen/sell/component/history_order_detail_screen.dart';
import 'package:dms/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class OrderListBottomSheet extends StatefulWidget {
  final List<ItemOrderFormContract> orders;
  final ContractItem contractMaster;

  const OrderListBottomSheet({super.key, required this.orders, required this.contractMaster});

  static void show(BuildContext context, List<ItemOrderFormContract> orders, ContractItem contractMaster) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (_) => OrderListBottomSheet(orders: orders, contractMaster: contractMaster),
    );
  }

  @override
  State<OrderListBottomSheet> createState() => _OrderListBottomSheetState();
}

class _OrderListBottomSheetState extends State<OrderListBottomSheet> {
  String searchQuery = '';
  String? selectedStatus; // null = All
  
  List<ItemOrderFormContract> get filteredOrders {
    return widget.orders.where((order) {
      // Filter by search
      bool matchSearch = searchQuery.isEmpty || 
          order.soCt.toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          order.hiddenSttRec.toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          order.statusName.toString().toLowerCase().contains(searchQuery.toLowerCase());
      
      // Filter by status
      bool matchStatus = selectedStatus == null || order.statusName.toString() == selectedStatus;
      
      return matchSearch && matchStatus;
    }).toList();
  }
  
  // Lấy danh sách các status unique
  List<String> get uniqueStatuses {
    return widget.orders.map((e) => e.statusName.toString()).toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              // Header với gradient
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [mainColor.withOpacity(0.1), subColor.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: mainColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt_long, color: mainColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Danh sách đơn hàng',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hợp đồng: ${widget.contractMaster.soCt ?? '---'}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: mainColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.orders.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Button X để đóng
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.close, size: 20, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Search & Filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Search bar
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) => setState(() => searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm theo số HĐ, mã đơn...',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () => setState(() => searchQuery = ''),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    
              const SizedBox(height: 12),
                    
                    // Status filter chips
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildFilterChip('Tất cả', null),
                          ...uniqueStatuses.map((status) => _buildFilterChip(status, status)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Orders list
              Expanded(
                child: filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                          final delay = (index + 1) * 50;
                    return _AnimatedOrderItem(
                            order: filteredOrders[index],
                            delay: Duration(milliseconds: delay),
                            contractMaster: widget.contractMaster,
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
  
  Widget _buildFilterChip(String label, String? status) {
    final isSelected = selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedStatus = selected ? status : null;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: mainColor.withOpacity(0.2),
        checkmarkColor: mainColor,
        labelStyle: TextStyle(
          color: isSelected ? mainColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? mainColor : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy đơn hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thử tìm kiếm với từ khóa khác',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

class _AnimatedOrderItem extends StatefulWidget {
  final ItemOrderFormContract order;
  final ContractItem contractMaster;
  final Duration delay;

  const _AnimatedOrderItem({required this.order, required this.contractMaster, required this.delay});

  @override
  State<_AnimatedOrderItem> createState() => _AnimatedOrderItemState();
}

class _AnimatedOrderItemState extends State<_AnimatedOrderItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _offset = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
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
        child: ScaleTransition(
          scale: _scale,
        child: Container(
            margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
              color: Colors.white,
            borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: order.statusColor.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _navigateToOrderDetail(context, order),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Order number & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                                    Icon(Icons.receipt, size: 16, color: mainColor),
                  const SizedBox(width: 6),
                                    const Text(
                                      'Mã đơn hàng',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order.sttRecDh?.toString() ?? '---',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: mainColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(order),
                        ],
                      ),
                      
                      const SizedBox(height: 14),
                      const Divider(height: 1, thickness: 1),
                      const SizedBox(height: 12),
                      
                      // Info rows
                      _buildCompactInfoRow(
                        icon: Icons.description_outlined,
                        label: 'Số HĐ',
                        value: order.soCt?.toString() ?? '---',
                        iconColor: Colors.blue,
                      ),
                      
                      const SizedBox(height: 10),
                      
                      _buildCompactInfoRow(
                        icon: Icons.calendar_today,
                        label: 'Ngày tạo',
                        value: _formatDate(widget.contractMaster.ngayCt?.toString()),
                        iconColor: Colors.orange,
                      ),
                      
                      const SizedBox(height: 14),
                      
                      // Action button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [mainColor.withOpacity(0.9), subColor.withOpacity(0.9)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: mainColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _navigateToOrderDetail(context, order),
                                borderRadius: BorderRadius.circular(18),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.visibility, size: 18, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      'Xem chi tiết',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ItemOrderFormContract order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: order.statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: order.statusColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            order.statusIcon,
            size: 12,
            color: order.statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            order.statusName.toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: order.statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '---';
    try {
      return dateString.split('T').first;
    } catch (e) {
      return dateString;
    }
  }
  
  void _navigateToOrderDetail(BuildContext context, ItemOrderFormContract order) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: HistoryOrderDetailScreen(
        sttRec: order.sttRecDh,
        title: widget.contractMaster.tenKh,
        status: widget.contractMaster.status == 0 ? false : true,
        dateOrder: widget.contractMaster.ngayCt.toString(),
        codeCustomer: widget.contractMaster.maKh.toString().trim(),
        nameCustomer: widget.contractMaster.tenKh.toString().trim(),
        addressCustomer: '',
        phoneCustomer: '',
        dateEstDelivery: '',
      ),
      withNavBar: false,
    );
  }

}
