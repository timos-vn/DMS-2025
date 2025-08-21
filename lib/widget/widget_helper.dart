// import 'package:another_flushbar/flushbar.dart';
import 'package:dms/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Size? getWidgetSize(GlobalKey key) {
  final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
  return renderBox?.size;
}

void callPhoneNumber(String phoneNumber,BuildContext context) async {
  final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    Utils.showCustomToast(context, Icons.warning_amber, 'Không thể gọi đến số $phoneNumber');
  }
}
