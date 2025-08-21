import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../themes/colors.dart';
import '../../../utils/functions/get_barcode_icon.dart';
import '../../../utils/functions/get_barcode_widgets.dart';

class ScannerBarcodeWidget extends StatelessWidget {
  final Barcode barcode;
  final Encoding? codec;

  const ScannerBarcodeWidget(
      {required this.barcode, this.codec, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: purple, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(getBarcodeIcon(barcode.type), color: Colors.white, size: 24),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: getBarcodeWidgets(barcode, codec),
              ),
            ),
              Container(),
          ],
        ));
  }
}
