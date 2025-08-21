import 'package:dms/widget/barcode_scanner_widget.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class BarcodeScannerPopup extends StatelessWidget {
  const BarcodeScannerPopup({key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[100],
        ),
        height: 300,
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Quét mã vạch',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: BarcodeScannerWidget(
                onBarcodeDetected: (values) async {
                  if ((await Vibration.hasVibrator()) ?? false) {
                    Vibration.vibrate();
                  }
                  // Trả về barcode và đóng popup
                  Navigator.of(context).pop(values);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
