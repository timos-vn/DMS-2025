import 'package:flutter/material.dart';
import '../model/network/response/gift_product_list_response.dart';
import '../utils/utils.dart';

/// Popup Step 2: Chọn sản phẩm tặng từ danh sách API
class CknGiftProductSelectionDialog extends StatefulWidget {
  final List<GiftProductItem> giftProducts;
  final String discountName;
  final double maxQuantity;
  final Map<String, double>? initialSelections; // Key: ma_vt, Value: quantity

  const CknGiftProductSelectionDialog({
    Key? key,
    required this.giftProducts,
    required this.discountName,
    required this.maxQuantity,
    this.initialSelections,
  }) : super(key: key);

  @override
  State<CknGiftProductSelectionDialog> createState() => _CknGiftProductSelectionDialogState();
}

class _CknGiftProductSelectionDialogState extends State<CknGiftProductSelectionDialog> {
  // Map để lưu số lượng đã chọn cho mỗi sản phẩm: key = ma_vt
  Map<String, double> selectedQuantities = {};
  
  // Map để lưu TextEditingController cho mỗi sản phẩm
  Map<String, TextEditingController> quantityControllers = {};

  @override
  void initState() {
    super.initState();
    
    // Load initial selections if provided
    if (widget.initialSelections != null) {
      selectedQuantities = Map.from(widget.initialSelections!);
      for (var entry in selectedQuantities.entries) {
        quantityControllers[entry.key] = TextEditingController(
          text: entry.value > 0 ? entry.value.toInt().toString() : ''
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateQuantity(String productCode, double quantity) {
    setState(() {
      if (quantity <= 0) {
        selectedQuantities.remove(productCode);
        quantityControllers[productCode]?.text = '';
      } else {
        // Check total quantity
        final totalSelected = _getTotalSelectedQuantity(excludeKey: productCode);
        if (totalSelected + quantity <= widget.maxQuantity) {
          selectedQuantities[productCode] = quantity;
          if (!quantityControllers.containsKey(productCode)) {
            quantityControllers[productCode] = TextEditingController(
              text: quantity.toInt().toString()
            );
          }
        } else {
          // Show error
          final remaining = widget.maxQuantity - totalSelected;
          Utils.showCustomToast(
            context,
            Icons.warning,
            'Vượt quá số lượng cho phép! Còn lại: ${remaining.toInt()}'
          );
        }
      }
    });
  }

  double _getTotalSelectedQuantity({String? excludeKey}) {
    double total = 0;
    for (var entry in selectedQuantities.entries) {
      if (entry.key != excludeKey) {
        total += entry.value;
      }
    }
    return total;
  }

  Widget _buildProductItem(GiftProductItem item) {
    final productCode = (item.maVt ?? '').trim();
    final currentQuantity = selectedQuantities[productCode] ?? 0;
    
    if (!quantityControllers.containsKey(productCode)) {
      quantityControllers[productCode] = TextEditingController(
        text: currentQuantity > 0 ? currentQuantity.toInt().toString() : ''
      );
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: currentQuantity > 0 ? Colors.green.withOpacity(0.5) : Colors.grey.shade300,
          width: currentQuantity > 0 ? 1.5 : 1,
        ),
        boxShadow: currentQuantity > 0 ? [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (currentQuantity > 0) {
              // If already selected, deselect
              _updateQuantity(productCode, 0);
              quantityControllers[productCode]?.text = '';
            } else {
              // Select with quantity 1
              final totalSelected = _getTotalSelectedQuantity(excludeKey: productCode);
              if (totalSelected + 1 <= widget.maxQuantity) {
                _updateQuantity(productCode, 1);
                quantityControllers[productCode]?.text = '1';
              } else {
                Utils.showCustomToast(
                  context,
                  Icons.warning,
                  'Đã đạt số lượng tối đa!'
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Checkbox - smaller and compact
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: currentQuantity > 0,
                    onChanged: (bool? value) {
                      if (value == true) {
                        final totalSelected = _getTotalSelectedQuantity(excludeKey: productCode);
                        if (totalSelected + 1 <= widget.maxQuantity) {
                          _updateQuantity(productCode, 1);
                          quantityControllers[productCode]?.text = '1';
                        } else {
                          Utils.showCustomToast(
                            context,
                            Icons.warning,
                            'Đã đạt số lượng tối đa!'
                          );
                        }
                      } else {
                        _updateQuantity(productCode, 0);
                        quantityControllers[productCode]?.text = '';
                      }
                    },
                    activeColor: Colors.green,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 10),
                // Product Info - Compact
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.tenVt ?? 'Sản phẩm tặng',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: currentQuantity > 0 ? FontWeight.w600 : FontWeight.w500,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        productCode,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Quantity Controls - Compact
                Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Minus button
                      InkWell(
                        onTap: currentQuantity > 0
                            ? () {
                                final newQuantity = (currentQuantity - 1).clamp(0.0, widget.maxQuantity);
                                _updateQuantity(productCode, newQuantity);
                                quantityControllers[productCode]?.text = 
                                    newQuantity > 0 ? newQuantity.toInt().toString() : '';
                              }
                            : null,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: currentQuantity > 0 ? Colors.red.shade50 : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(6),
                              bottomLeft: Radius.circular(6),
                            ),
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 16,
                            color: currentQuantity > 0 ? Colors.red : Colors.grey.shade400,
                          ),
                        ),
                      ),
                      // TextField - Compact
                      Container(
                        width: 40,
                        height: 32,
                        alignment: Alignment.center,
                        child: TextField(
                          controller: quantityControllers[productCode],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          onChanged: (value) {
                            final quantity = double.tryParse(value) ?? 0;
                            _updateQuantity(productCode, quantity);
                          },
                        ),
                      ),
                      // Plus button
                      InkWell(
                        onTap: () {
                          final newQuantity = currentQuantity + 1;
                          final totalSelected = _getTotalSelectedQuantity(excludeKey: productCode);
                          if (totalSelected + newQuantity <= widget.maxQuantity) {
                            _updateQuantity(productCode, newQuantity);
                            quantityControllers[productCode]?.text = newQuantity.toInt().toString();
                          } else {
                            final remaining = widget.maxQuantity - totalSelected;
                            Utils.showCustomToast(
                              context,
                              Icons.warning,
                              'Vượt quá! Còn: ${remaining.toInt()}'
                            );
                          }
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(6),
                              bottomRight: Radius.circular(6),
                            ),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSelected = _getTotalSelectedQuantity();
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - Compact
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.card_giftcard_rounded, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Chọn sản phẩm tặng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Info Row - Compact
          Row(
            children: [
              // Discount name
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_offer, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.discountName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Quantity indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: totalSelected >= widget.maxQuantity 
                      ? Colors.red.withOpacity(0.1) 
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 14,
                      color: totalSelected >= widget.maxQuantity ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${totalSelected.toInt()}/${widget.maxQuantity.toInt()}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: totalSelected >= widget.maxQuantity ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 450, // Fixed height for better space usage
        child: widget.giftProducts.isEmpty
            ? const Center(
                child: Text(
                  'Không có sản phẩm tặng nào',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              )
            : Column(
                children: [
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: widget.giftProducts.length,
                      itemBuilder: (context, index) {
                        return _buildProductItem(widget.giftProducts[index]);
                      },
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: selectedQuantities.isEmpty
              ? null
              : () {
                  // Return selected products with quantities
                  Navigator.pop(context, selectedQuantities);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedQuantities.isNotEmpty 
                ? Colors.green 
                : Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            selectedQuantities.isEmpty
                ? 'Chọn sản phẩm'
                : 'Xác nhận (${selectedQuantities.length} sp)',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

