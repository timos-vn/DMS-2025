import 'package:dms/utils/utils.dart';
import 'package:flutter/material.dart';
import '../../../../themes/colors.dart';

class CreateOrderDialog extends StatelessWidget {
  final String contractNumber;
  final String customerName;
  final int availableQuantity;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const CreateOrderDialog({
    Key? key,
    required this.contractNumber,
    required this.customerName,
    required this.availableQuantity,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: isKeyboardVisible ? 10 : 40,
      ),
      child: _buildDialogContent(context, screenHeight, isKeyboardVisible),
    );
  }

  Widget _buildDialogContent(BuildContext context, double screenHeight, bool isKeyboardVisible) {
    final double verticalPadding = isKeyboardVisible ? 16 : 24;
    final double iconSize = isKeyboardVisible ? 60 : 80;
    
    return Container(
      constraints: BoxConstraints(
        maxWidth: 400,
        maxHeight: screenHeight * 0.85,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(verticalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Icon với gradient background - responsive
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [mainColor, subColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: mainColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: iconSize * 0.5,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: isKeyboardVisible ? 16 : 24),
          
          // Title - responsive
          Text(
            'Tạo đơn hàng',
            style: TextStyle(
              fontSize: isKeyboardVisible ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: isKeyboardVisible ? 6 : 8),
          
          // Subtitle
          Text(
            'Xác nhận tạo đơn hàng từ hợp đồng',
            style: TextStyle(
              fontSize: isKeyboardVisible ? 13 : 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: isKeyboardVisible ? 16 : 24),
          
          // Contract Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  mainColor.withOpacity(0.08),
                  subColor.withOpacity(0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: mainColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Contract Number
                _buildInfoRow(
                  icon: Icons.description_outlined,
                  label: 'Số HĐ',
                  value: contractNumber,
                  iconColor: mainColor,
                ),
                
                const SizedBox(height: 12),
                Divider(height: 1, color: Colors.grey[300]),
                const SizedBox(height: 12),
                
                // Customer Name
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: 'Khách hàng',
                  value: customerName,
                  iconColor: Colors.blue,
                ),
                
                const SizedBox(height: 12),
                Divider(height: 1, color: Colors.grey[300]),
                const SizedBox(height: 12),
                
                // Available Quantity
                _buildInfoRow(
                  icon: Icons.inventory_2_outlined,
                  label: 'SL khả dụng',
                  value: '${Utils.formatDecimal(availableQuantity,withSeparator: true)} vật tư',
                  iconColor: Colors.green,
                ),
              ],
            ),
          ),
          
          SizedBox(height: isKeyboardVisible ? 16 : 24),
          
          // Description
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bạn sẽ được chuyển đến màn hình đặt hàng',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: isKeyboardVisible ? 16 : 24),
          
          // Action Buttons
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                  ),
                  child: Text(
                    'Hủy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Confirm Button
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [mainColor, subColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onConfirm,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Xác nhận',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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
}

/// Helper function to show dialog
Future<bool?> showCreateOrderDialog({
  required BuildContext context,
  required String contractNumber,
  required String customerName,
  required int availableQuantity,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return CreateOrderDialog(
        contractNumber: contractNumber,
        customerName: customerName,
        availableQuantity: availableQuantity,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      );
    },
  );
}

