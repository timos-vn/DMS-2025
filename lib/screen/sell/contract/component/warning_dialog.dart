import 'package:flutter/material.dart';

/// Professional Warning Dialog
class WarningDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onConfirm;

  const WarningDialog({
    Key? key,
    required this.title,
    required this.message,
    this.icon = Icons.warning_amber_rounded,
    this.iconColor = Colors.orange,
    this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 380,
          maxHeight: screenHeight * 0.7,
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon header với màu warning
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor.withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 45,
                  color: iconColor,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Message Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: iconColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: iconColor,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onConfirm ?? () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Đã hiểu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper functions to show different warning types

/// Warning cho trạng thái "Chờ duyệt"
Future<void> showPendingStatusWarning(BuildContext context, String contractNumber) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => WarningDialog(
      title: 'Hợp đồng chờ duyệt',
      message: 'Không thể tạo đơn hàng khi hợp đồng "$contractNumber" đang ở trạng thái "Chờ duyệt". Vui lòng chờ hợp đồng được phê duyệt.',
      icon: Icons.schedule_rounded,
      iconColor: Colors.orange,
    ),
  );
}

/// Warning cho hết số lượng khả dụng
Future<void> showNoQuantityWarning(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => WarningDialog(
      title: 'Hết số lượng khả dụng',
      message: 'Không còn số lượng khả dụng để đặt hàng. Tất cả vật tư trong hợp đồng đã được đặt hết.',
      icon: Icons.inventory_2_outlined,
      iconColor: Colors.red,
    ),
  );
}

/// Generic error dialog
Future<void> showErrorDialog({
  required BuildContext context,
  required String title,
  required String message,
  IconData icon = Icons.error_outline,
  Color iconColor = Colors.red,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => WarningDialog(
      title: title,
      message: message,
      icon: icon,
      iconColor: iconColor,
    ),
  );
}

