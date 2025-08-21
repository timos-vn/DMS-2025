import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/models/init_data.dart';
import '../api/models/user_model.dart';

late UserModel user;
double kPadding = 16;
late InitData initData;

double get bottomPadding {
  double a = EdgeInsets.fromViewPadding(
          WidgetsBinding.instance.platformDispatcher.views.first.viewPadding,
          WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio)
      .bottom;
  if (a == 0) {
    return 15;
  } else {
    return a;
  }
}

const Color blue = Color(0xFF013370);
const Color orange = Color(0xFFFD9800);
const Color green = Color(0xFFB0D646);
const Color white = Color(0xFFffffff);
const Color gray = Color(0xFF6C7F9B);
const Color black = Color(0xFF040404);
const Color red = Color(0xFFE53434);
const Color purple = Color(0xFFb168be);

Text setText(String text, double size, {Color? color, FontWeight? fontWeight, double? height}) {
  return Text(text,
      style: TextStyle(
        fontSize: size,
        color: color ?? black,
        height: height,
        fontWeight: fontWeight ?? FontWeight.normal,
      ));
}

String formatMoney(int value){
  return NumberFormat("#,###", "vi_VI").format(value);
}

var avatarAsset = const AssetImage('assets/icons/avatar.png');
var calendarAsset = const AssetImage('assets/icons/calendar.png');
var locationAsset = const AssetImage('assets/icons/location-pin.png');
var userAsset = const AssetImage('assets/icons/user.png');
var searchAsset = const AssetImage('assets/icons/search.png');
var clearAsset = const AssetImage('assets/icons/clear.png');
var phoneAsset = const AssetImage('assets/icons/phone.png');
var customerAsset = const AssetImage('assets/icons/customer.png');
var pinAsset = const AssetImage('assets/icons/location.png');
var welcomeAsset = const AssetImage('assets/icons/welcome.png');
var i2Asset = const AssetImage('assets/icons/i2.png');
var noResultAsset = const AssetImage('assets/icons/no-result.png');
var circleAsset = const AssetImage('assets/icons/circle.png');

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension DateUtils on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }
}

void showLoaderDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: black.withOpacity(0.4),
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
            child: Container(
                decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(5)),
                height: 70,
                width: 70,
                alignment: Alignment.center,
                child: const CupertinoActivityIndicator(color: blue, radius: 12))),
      );
    },
  );
}

void cancelLoaderDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}
