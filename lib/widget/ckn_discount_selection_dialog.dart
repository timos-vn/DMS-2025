import 'package:flutter/material.dart';
import '../model/network/response/apply_discount_response.dart';

/// Popup Step 1: Chọn tên chiết khấu (ten_ck)
class CknDiscountSelectionDialog extends StatelessWidget {
  final List<ListCkMatHang> listCknDiscounts;
  final String? selectedDiscountName;

  const CknDiscountSelectionDialog({
    Key? key,
    required this.listCknDiscounts,
    this.selectedDiscountName,
  }) : super(key: key);

  // Group discounts by group_dk
  Map<String, List<ListCkMatHang>> _groupByDiscountGroup() {
    Map<String, List<ListCkMatHang>> grouped = {};
    for (var item in listCknDiscounts) {
      final groupDk = item.group_dk?.toString().trim() ?? 'default';
      if (!grouped.containsKey(groupDk)) {
        grouped[groupDk] = [];
      }
      grouped[groupDk]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedDiscounts = _groupByDiscountGroup();
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.discount, color: Colors.green, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Chọn chương trình khuyến mãi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 500),
        child: groupedDiscounts.isEmpty
            ? const Center(
                child: Text(
                  'Không có chương trình khuyến mãi nào',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: groupedDiscounts.keys.length,
                itemBuilder: (context, index) {
                  final groupDk = groupedDiscounts.keys.elementAt(index);
                  final discountItems = groupedDiscounts[groupDk]!;
                  
                  // Lấy tên chiết khấu từ item đầu tiên
                  final discountName = discountItems.first.ten_ck?.toString().trim() ?? 'Chương trình khuyến mãi';
                  final isSelected = selectedDiscountName == groupDk;
                  
                  // Lấy tổng số lượng có thể chọn từ item đầu tiên
                  final totalQuantity = discountItems.first.soLuong ?? 0;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected ? Colors.green.withOpacity(0.05) : Colors.white,
                    ),
                    child: InkWell(
                      onTap: () {
                        // Return: [discountName (ten_ck), groupDk (group_dk for API), totalQuantity, ListCkMatHang items]
                        Navigator.pop(context, {
                          'discountName': discountName,
                          'groupDk': groupDk,
                          'totalQuantity': totalQuantity,
                          'items': discountItems,
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.card_giftcard_rounded,
                                color: Colors.green,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    discountName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${discountItems.length} sản phẩm',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Tối đa: ${totalQuantity.toInt()}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Check icon
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}

