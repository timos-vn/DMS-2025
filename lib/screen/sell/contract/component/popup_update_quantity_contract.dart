import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/utils.dart';

/// Custom formatter để format số với dấu phẩy
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    } 

    // Remove all non-digits
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    // Format with thousands separator
    final number = int.tryParse(digitsOnly);
    if (number == null) {
      return oldValue;
    }
    
    final formatter = NumberFormat('#,##0', 'en_US');
    final formatted = formatter.format(number);

    // Calculate new cursor position
    int newOffset = formatted.length;
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}

Future<void> showChangeQuantityPopup({
  required BuildContext context,
  required double originalQuantity,
  required Function(double newQuantity) onConfirmed,
  required String maVt2,
  required List<dynamic> listOrder,
  required double currentQuantity,
  required double availableQuantity, // Số lượng khả dụng được truyền vào
  String? productName, // Thêm tên sản phẩm
}) async {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return UpdateQuantityDialog(
        maVt2: maVt2,
        productName: productName,
        currentQuantity: currentQuantity,
        availableQuantity: availableQuantity,
        onConfirmed: onConfirmed,
      );
    },
  );
}

class UpdateQuantityDialog extends StatefulWidget {
  final String maVt2;
  final String? productName;
  final double currentQuantity;
  final double availableQuantity;
  final Function(double newQuantity) onConfirmed;

  const UpdateQuantityDialog({
    Key? key,
    required this.maVt2,
    this.productName,
    required this.currentQuantity,
    required this.availableQuantity,
    required this.onConfirmed,
  }) : super(key: key);

  @override
  State<UpdateQuantityDialog> createState() => _UpdateQuantityDialogState();
}

class _UpdateQuantityDialogState extends State<UpdateQuantityDialog> {
  late TextEditingController controller;
  late FocusNode focusNode;
  String? errorText;
  bool isValid = false;
  double inputQuantity = 0;

  @override
  void initState() {
    super.initState();
    // Format số lượng ban đầu với dấu phẩy
    final initialValue = widget.currentQuantity == 0 
        ? '' 
        : Utils.formatQuantity(widget.currentQuantity.toInt());
    
    controller = TextEditingController(text: initialValue);
    focusNode = FocusNode();
    inputQuantity = widget.currentQuantity;
    
    // Auto focus vào TextField khi dialog mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
      // Select all text nếu có
      if (controller.text.isNotEmpty) {
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      }
    });
    
    if (widget.currentQuantity > 0 && widget.currentQuantity <= widget.availableQuantity) {
      isValid = true;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _validateInput(String value) {
    // Remove commas trước khi parse
    final cleanValue = value.replaceAll(',', '');
    final input = double.tryParse(cleanValue) ?? 0;
    
    setState(() {
      inputQuantity = input;
      
      if (value.isEmpty) {
        errorText = 'Vui lòng nhập số lượng';
        isValid = false;
      } else if (input <= 0) {
        errorText = 'Số lượng phải lớn hơn 0';
        isValid = false;
      } else if (input > widget.availableQuantity) {
        errorText = 'Vượt quá số lượng khả dụng (${Utils.formatQuantity(widget.availableQuantity)})';
        isValid = false;
      } else {
        errorText = null;
        isValid = true;
      }
    });
  }

  void _incrementQuantity() {
    // Remove commas trước khi parse
    final cleanText = controller.text.replaceAll(',', '');
    double current = double.tryParse(cleanText) ?? 0;
    if (current < widget.availableQuantity) {
      current++;
      controller.text = current.toInt().toString();
      _validateInput(controller.text);
    }
  }

  void _decrementQuantity() {
    // Remove commas trước khi parse
    final cleanText = controller.text.replaceAll(',', '');
    double current = double.tryParse(cleanText) ?? 0;
    if (current > 1) {
      current--;
      controller.text = current.toInt().toString();
      _validateInput(controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final isKeyboardVisible = keyboardHeight > 0;
    
    // Responsive spacing - giảm khi keyboard hiện
    final double verticalPadding = isKeyboardVisible ? 16 : 24;
    final double iconSize = isKeyboardVisible ? 60 : 70;
    final double titleSize = isKeyboardVisible ? 20 : 22;
    
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
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: screenHeight * 0.85, // Tối đa 85% màn hình
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
            // Icon header với gradient - responsive size
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
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.edit_note_rounded,
                size: iconSize * 0.5,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: isKeyboardVisible ? 12 : 20),
            
            // Title - responsive size
            Text(
              'Cập nhật số lượng',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: isKeyboardVisible ? 12 : 20),
            
            // Product Info Card - compact
            Container(
              padding: EdgeInsets.all(isKeyboardVisible ? 12 : 16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Code + Name (gộp lại cho gọn)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          size: 20,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Mã vật tư
                            Text(
                              widget.maVt2,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            // Tên vật tư (nếu có)
                            if (widget.productName != null && widget.productName!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.productName!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: isKeyboardVisible ? 8 : 12),
                  Divider(height: 1, color: Colors.grey[300]),
                  SizedBox(height: isKeyboardVisible ? 8 : 12),
                  
                  // Available Quantity
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 20,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tối đa có thể đặt',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              Utils.formatQuantity(widget.availableQuantity),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: isKeyboardVisible ? 16 : 24),
            
            // Quantity Input với Plus/Minus buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhập số lượng',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Minus button
                    Material(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _decrementQuantity,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 48,
                          height: 48,
                          child: const Icon(
                            Icons.remove_rounded,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // TextField với format tự động
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThousandsSeparatorInputFormatter(), // ← Format tự động
                        ],
                        decoration: InputDecoration(
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: mainColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          errorText: errorText,
                          errorMaxLines: 2,
                          errorStyle: const TextStyle(fontSize: 11),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: _validateInput,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Plus button
                    Material(
                      color: mainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _incrementQuantity,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 48,
                          height: 48,
                          child: Icon(
                            Icons.add_rounded,
                            color: mainColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: isKeyboardVisible ? 12 : 16),
            
            // Progress indicator - ẩn khi keyboard hiện để tiết kiệm không gian
            if (!isKeyboardVisible && isValid && inputQuantity > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đã chọn',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${Utils.formatQuantity(inputQuantity)} / ${Utils.formatQuantity(widget.availableQuantity)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: inputQuantity / widget.availableQuantity,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                        minHeight: 6,
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
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                    ),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        fontSize: 15,
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
                      gradient: isValid
                          ? LinearGradient(
                              colors: [mainColor, subColor],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      color: isValid ? null : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isValid
                          ? [
                              BoxShadow(
                                color: mainColor.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isValid
                            ? () {
                                // Remove commas trước khi parse
                                final cleanText = controller.text.replaceAll(',', '');
                                final newQty = double.tryParse(cleanText) ?? 0;
                                if (newQty > 0 && newQty <= widget.availableQuantity) {
                                  Navigator.of(context).pop();
                                  widget.onConfirmed(newQty);
                                }
                              }
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: isValid ? Colors.white : Colors.grey[500],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Xác nhận',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isValid ? Colors.white : Colors.grey[500],
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
      ),
    );
  }
}
