import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../../themes/colors.dart';

class CustomSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final String text;
  final IconData? icon;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const CustomSubmitButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.text = 'Tạo phiếu CSKH',
    this.icon,
    this.width,
    this.height = 56,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: margin ?? const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? subColor : Colors.grey[400],
          foregroundColor: Colors.white,
          elevation: isEnabled ? 4 : 0,
          shadowColor: isEnabled ? subColor.withOpacity(0.3) : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Đang xử lý...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 24,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class BottomSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final String text;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final double? buttonHeight;
  final double? bottomPadding;

  const BottomSubmitButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.text = 'Tạo phiếu CSKH',
    this.icon,
    this.padding,
    this.buttonHeight,
    this.bottomPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: bottomPadding ?? MediaQuery.of(context).padding.bottom,
        ),
        child: CustomSubmitButton(
          onPressed: onPressed,
          isLoading: isLoading,
          isEnabled: isEnabled,
          text: text,
          icon: icon,
          margin: EdgeInsets.zero,
          height: buttonHeight ?? 48,
        ),
      ),
    );
  }
}
