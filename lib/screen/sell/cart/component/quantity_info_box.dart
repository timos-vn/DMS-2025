import 'dart:async';

import 'package:dms/themes/colors.dart';
import 'package:dms/utils/utils.dart';
import 'package:flutter/material.dart';

class QuantityInfoBox extends StatefulWidget {
  final String quantity;
  final String unit;
  final bool isShowInfo;
  final String? contractQuantity; // Số lượng dạng a/b cho contract

  const QuantityInfoBox({
    super.key, 
    required this.quantity,
    required this.unit,
    required this.isShowInfo,
    this.contractQuantity,
  });

  @override
  State<QuantityInfoBox> createState() => _QuantityInfoBoxState();
}

class _QuantityInfoBoxState extends State<QuantityInfoBox> {
  bool _showTooltip = false;
  Timer? _hideTimer;

  void _showTooltipWithDelay() {
    setState(() {
      _showTooltip = true;
    });

    // Hủy timer cũ nếu có
    _hideTimer?.cancel();

    // Tạo timer ẩn sau 3 giây
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showTooltip = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: grey_100,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                widget.contractQuantity != null 
                  ? "SL: ${widget.contractQuantity} ${widget.unit}"
                  : "SL: ${Utils.formatQuantity(widget.quantity)} - ${widget.unit}",
                style: TextStyle(
                  fontSize: 12.5,
                  color: widget.contractQuantity != null ? Colors.green : Colors.black,
                  fontWeight: widget.contractQuantity != null ? FontWeight.bold : FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        // Dấu sao / icon info
        Visibility(
          visible: widget.isShowInfo,
          child: Positioned(
            top: -6,
            right: -2,
            child: GestureDetector(
              onTap: _showTooltipWithDelay,
              child: const Icon(Icons.info_outline, size: 16, color: Colors.red),
            ),
          ),
        ),
        // Tooltip hiển thị trong 3s
        if (_showTooltip)
          Positioned(
            top: -40,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(maxWidth: 200),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Số lượng khả dụng mà bạn có thể đặt hàng",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}
