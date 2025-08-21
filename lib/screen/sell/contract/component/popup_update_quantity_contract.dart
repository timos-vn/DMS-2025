import 'package:flutter/material.dart';

Future<void> showChangeQuantityPopup({
  required BuildContext context,
  required double originalQuantity,
  required Function(double newQuantity) onConfirmed,
  required String maVt2,
  required List<dynamic> listOrder,
  required double currentQuantity,
  required double availableQuantity, // Số lượng khả dụng được truyền vào
}) async {
  final TextEditingController controller = TextEditingController(text: currentQuantity.toString());
  String? errorText;
  bool isValid = true;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.edit_note, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  'Cập nhật số lượng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin sản phẩm
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mã sản phẩm: $maVt2',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Số lượng hiện tại: ${currentQuantity.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Thông tin số lượng khả dụng
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: availableQuantity > 0 ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: availableQuantity > 0 ? Colors.green[300]! : Colors.red[300]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          availableQuantity > 0 ? Icons.check_circle : Icons.warning,
                          color: availableQuantity > 0 ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            availableQuantity > 0 
                              ? 'Số lượng khả dụng: ${availableQuantity.toStringAsFixed(0)}'
                              : 'Không còn số lượng khả dụng',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: availableQuantity > 0 ? Colors.green[700] : Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Input số lượng mới
                  Text(
                    'Số lượng mới:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Nhập số lượng...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[400]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      errorText: errorText,
                      errorMaxLines: 2,
                      prefixIcon: Icon(Icons.shopping_cart, color: Colors.grey[600]),
                      suffixIcon: isValid && controller.text.isNotEmpty
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    ),
                    onChanged: (value) {
                      final input = double.tryParse(value) ?? 0;
                      
                      setState(() {
                        if (input < 0) {
                          errorText = 'Số lượng không được âm';
                          isValid = false;
                        } else if (input > availableQuantity) {
                          errorText = 'Số lượng vượt quá giới hạn khả dụng (${availableQuantity.toStringAsFixed(0)})';
                          isValid = false;
                        } else if (input == 0) {
                          errorText = 'Số lượng phải lớn hơn 0';
                          isValid = false;
                        } else {
                          errorText = null;
                          isValid = true;
                        }
                      });
                    },
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Thông báo hướng dẫn
                  if (availableQuantity > 0)
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bạn có thể cập nhật số lượng từ 1 đến ${availableQuantity.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              // Nút Hủy
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                ),
                child: Text(
                  'Hủy',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              SizedBox(width: 8),
              
              // Nút Xác nhận
              ElevatedButton(
                onPressed: availableQuantity > 0 && isValid && controller.text.isNotEmpty
                  ? () {
                      final newQty = double.tryParse(controller.text) ?? 0;
                      if (newQty > 0 && newQty <= availableQuantity) {
                        Navigator.of(context).pop();
                        onConfirmed(newQty);
                      }
                    }
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Xác nhận',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
