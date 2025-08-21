import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF20EF3D);
const kSecondaryColor = Color(0xFFFE9901);
const kContentColorLightTheme = Color(0xFF1D1D35);
const kContentColorDarkTheme = Color(0xFFF5FCF9);
const kWarningColor = Color(0xFFF3BB1C);
const kErrorColor = Color(0xFFF03738);

const Color transparent = Colors.transparent;
const Color accent = Color(0xff5c616e);
const Color black = Colors.black;
const Color blackBlur = Colors.black45;
const Color white = Colors.white;
const Color lightBlue = Colors.lightBlue;
const Color blueAccent = Colors.blueAccent;
const Color greenAccent = Colors.greenAccent;
const Color customLine = Colors.greenAccent;
const Color grey = Colors.grey;
Color? grey_200 = Colors.grey[200];
Color? grey_100 = Colors.grey[100];
const Color primaryColor = Color(0xFF330A30);
const Color redAccent = Colors.redAccent;
const Color blue = Color(0xff1F346D);
const Color orange =  Color(0xfffb9d14);
const Color backgroundColor = const Color(0xffeeeeee);
const Color greenColor = const Color(0xFF00c497);
const Color blackColor = const Color(0XFF242A37);
const Color whiteColor = const Color(0XFFFFFFFF);

const Color lightPink = Color(0xFFFAC0BE);
const Color cherryRed = Color(0xFFFA2424);

const Color app_main = Color(0xFF4688FA);

const Color bg_color = Color(0xFF280125);

const Color material_bg = Color(0xFFFFFFFF);

const Color text = Color(0xFF333333);
const Color dark_text = Color(0xFFB8B8B8);

const Color text_gray = Color(0xFF999999);

const Color text_gray_c = Color(0xFFcccccc);

const Color bg_gray = Color(0xFFF6F6F6);
const Color secondaryColor = Color(0xFF8E07E0);
const Color secondaryColor2 = Color(0xFF8E07E0);
const Color purple = Color(0xFFAA66CC);
const Color line = Color(0xFFEEEEEE);

const Color red = Color(0xFFFF4759);

const Color text_disabled = Color(0xff94A3B8);

const Color button_disabled = Color(0xffE2E8F0);

const Color bg_gray_ = Color(0xFFFAFAFA);
const Color dark_bg_gray_ = Color(0xFF242526);

const Color color_app = Color(0xfff39f58);

const Color color_sub = Color(0xff007bff);

const Color color_bg_gray = Color(0xff343A40);

final mainColor = HexColor("#ffF58220");

const subColor =  Color.fromARGB(255, 0, 51, 114);

final HexColor kWhite=  HexColor("#FFFFFF");
final HexColor kWhite_50 =  HexColor("#80FFFFFF");

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}




