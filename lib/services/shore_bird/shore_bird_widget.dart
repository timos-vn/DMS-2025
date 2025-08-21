import 'package:flutter/material.dart';

import '../../themes/colors.dart';

class UtilsWidget {
  static Widget buildText(
      String text, {
        FontWeight? fontWeight,
        TextAlign? textAlign,
        Color? textColor,
        int? maxLines,
        double? fontSize,
        TextStyle? style,
      }) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.center,
      style: style ??
          TextStyle(
            color: textColor ?? const Color(0xFF111111),
            fontWeight: fontWeight,
            overflow: TextOverflow.ellipsis,
            fontSize: fontSize ?? 14,
          ),
      maxLines: maxLines ?? 1,
    );
  }

  static Widget dialogUpdateShorebird({
    required String contentNotification,
    required Function() fuc,
  }) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 12,
          ),
          buildText(
            "Ứng dụng cần cập nhật",
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(
            height: 12,
          ),
          buildText(
            contentNotification,
            fontSize: 14,
            maxLines: 4,
            // fontWeight: FontWeight.w700,
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => fuc(),
                    child: UtilsWidget.buildText("Đồng ý",
                        textColor: white, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


}
