// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'dart:ui' as ui;
import 'package:dms/widget/custom_toast.dart';
import 'package:dms/widget/custom_upgrade.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oktoast/oktoast.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../model/models/login_user_type.dart';
import '../themes/colors.dart';
import 'dart:math' show Random, asin, atan2, cos, pi, pow, sin, sqrt;
import 'package:vector_math/vector_math.dart' as vector;

class Utils{
  static String formatToTime(String inputDate, {String outputPattern = 'HH:mm'}) {
    try {
      final inputFormat = DateFormat('dd-MM-yyyy HH:mm');
      final dateTime = inputFormat.parseStrict(inputDate);
      final outputFormat = DateFormat(outputPattern);
      return outputFormat.format(dateTime);
    } catch (e) {
      return inputDate; // Trả lại chuỗi gốc nếu parse lỗi
    }
  }

  static String safeFormatDate(String input) {
    DateTime date;

    try {
      // ISO format (e.g. "2025-06-29T12:34:56Z" or "2025-06-29")
      date = DateTime.parse(input);
    } catch (_) {
      try {
        // Try dd/MM/yyyy
        date = DateFormat('dd/MM/yyyy').parseStrict(input);
      } catch (_) {
        try {
          // Try dd-MM-yyyy
          date = DateFormat('dd-MM-yyyy').parseStrict(input);
        } catch (e) {
          // Nếu tất cả đều sai, trả lại chuỗi gốc
          return input;
        }
      }
    }

    return DateFormat('dd-MM-yyyy').format(date);
  }

  static String extractSttRec(String input) {
    try {
      // Kiểm tra có phải JSON không
      final data = json.decode(input);

      // Kiểm tra có phải Map và chứa "stt_rec"
      if (data is Map<String, dynamic> && data.containsKey('stt_rec')) {
        final stt = data['stt_rec'];
        if (stt is String && stt.trim().isNotEmpty) {
          return stt;
        }
      }
    } catch (e) {
      // Không làm gì, trả về ""
    }

    return ''; // Không hợp lệ hoặc không có stt_rec
  }

  static DateTime generateSmartRandomTime({
    required DateTime date,
    String? timeIn,
    String? timeOut,
  }) {
    final now = DateTime.now();
    final random = Random();
    final isSameDay = now.year == date.year && now.month == date.month && now.day == date.day;
    final weekday = date.weekday;
    final isSaturday = weekday == DateTime.saturday;

    bool isBlank(String? s) => s == null || s.toString().replaceAll('null', '').trim().isEmpty;

    DateTime? parseTime(String? input) {
      if (isBlank(input)) return null;
      try {
        // Nếu có dạng ISO-8601: 2025-07-14T08:06:17
        if (input!.contains('T')) {
          final dt = DateTime.parse(input);
          return DateTime(date.year, date.month, date.day, dt.hour, dt.minute, dt.second);
        }

        // Nếu dạng HH:mm hoặc HH:mm:ss
        final parts = input.split(':');
        if (parts.length < 2 || parts.length > 3) return null;
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final second = parts.length == 3 ? int.parse(parts[2]) : 0;
        return DateTime(date.year, date.month, date.day, hour, minute, second);
      } catch (_) {
        return null;
      }
    }


    // TIME-IN
    final parsedTimeIn = parseTime(timeIn);
    final timeInStart = DateTime(date.year, date.month, date.day, 7, 0);
    final timeInEnd = DateTime(date.year, date.month, date.day, 8, 14);
    final isTimeInInvalid = parsedTimeIn == null ||
        parsedTimeIn.isBefore(timeInStart) ||
        parsedTimeIn.isAfter(timeInEnd);

    if (isTimeInInvalid) {
      if (isSameDay && now.isAfter(timeInStart) && now.isBefore(timeInEnd)) {
        return now;
      }
      final fakeStart = DateTime(date.year, date.month, date.day, 8, 0);
      final fakeEnd = DateTime(date.year, date.month, date.day, 8, 14);
      final diff = fakeEnd.difference(fakeStart).inSeconds;
      return fakeStart.add(Duration(seconds: random.nextInt(diff)));
    }

    // TIME-OUT
    final parsedTimeOut = parseTime(timeOut);
    final timeOutStart = isSaturday
        ? DateTime(date.year, date.month, date.day, 12, 0)
        : DateTime(date.year, date.month, date.day, 17, 30);
    final timeOutEnd = isSaturday
        ? DateTime(date.year, date.month, date.day, 13, 0)
        : DateTime(date.year, date.month, date.day, 18, 0);
    final isTimeOutInvalid = parsedTimeOut == null ||
        parsedTimeOut.isBefore(timeOutStart) ||
        parsedTimeOut.isAfter(timeOutEnd);

    if (isTimeOutInvalid) {
      if (isSameDay && now.isAfter(timeOutStart) && now.isBefore(timeOutEnd)) {
        return now;
      }
      final fakeStart = isSaturday
          ? DateTime(date.year, date.month, date.day, 12, 0)
          : DateTime(date.year, date.month, date.day, 17, 35);
      final diff = timeOutEnd.difference(fakeStart).inSeconds;
      return fakeStart.add(Duration(seconds: random.nextInt(diff)));
    }

    // Cả hai đều hợp lệ → return time-out
    return parsedTimeOut;
  }






  static Map<String, double> generateRandomCoordinateNearby({
    required double originLat,
    required double originLon,
    double maxDistanceInMeters = 150,
  }) {
    final Random _random = Random();
    const double earthRadius = 6371000; // Bán kính Trái Đất (m)

    double toRadians(double degree) => degree * pi / 180;
    double toDegrees(double radian) => radian * 180 / pi;

    // Tạo khoảng cách và góc ngẫu nhiên
    final double distance = _random.nextDouble() * maxDistanceInMeters;
    final double bearing = _random.nextDouble() * 2 * pi;

    // Chuyển tọa độ gốc sang radian
    final double originLatRad = toRadians(originLat);
    final double originLonRad = toRadians(originLon);

    // Tính toán tọa độ mới
    final double newLatRad = asin(
      sin(originLatRad) * cos(distance / earthRadius) +
          cos(originLatRad) * sin(distance / earthRadius) * cos(bearing),
    );

    final double newLonRad = originLonRad +
        atan2(
          sin(bearing) * sin(distance / earthRadius) * cos(originLatRad),
          cos(distance / earthRadius) - sin(originLatRad) * sin(newLatRad),
        );

    return {
      'lat': toDegrees(newLatRad),
      'lon': toDegrees(newLonRad),
    };
  }

  static double haversine(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000; // Bán kính Trái Đất (m)

    // Chuyển đổi độ sang radian
    double toRadians(double degree) => degree * pi / 180;
    lat1 = toRadians(lat1);
    lon1 = toRadians(lon1);
    lat2 = toRadians(lat2);
    lon2 = toRadians(lon2);

    // Chênh lệch tọa độ
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    // Công thức Haversine
    double a = pow(sin(dLat / 2), 2) +
        cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Khoảng cách (km)
  }

  static TimeOfDay parseTimeOfDay(String timeString) {
    try {
      // Tách chuỗi "hh:mm"
      List<String> parts = timeString.split(":");
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print("Lỗi: Định dạng thời gian không hợp lệ.");
      return const TimeOfDay(hour: 0, minute: 0); // Giá trị mặc định nếu lỗi
    }
  }

  static double? calculateHoursDifference(String? fromDateString, String? toDateString,BuildContext context) {
    // Kiểm tra nếu dữ liệu null hoặc rỗng
    if (fromDateString == null || toDateString == null ||
        fromDateString.isEmpty || toDateString.isEmpty) {
      print("Lỗi: Dữ liệu đầu vào không hợp lệ. $fromDateString - $toDateString");
      return 0;
    }

    try {
      // Định dạng ngày giờ
      DateFormat format = DateFormat("yyyy-MM-dd hh:mm a");

      // Chuyển đổi chuỗi thành DateTime
      DateTime fromDate = format.parse(fromDateString);
      DateTime toDate = format.parse(toDateString);

      // Kiểm tra nếu ngày bắt đầu lớn hơn ngày kết thúc
      if (fromDate.isAfter(toDate)) {
        showCustomToast(context, Icons.warning_amber, 'Lỗi: Ngày bắt đầu phải nhỏ hơn hoặc bằng ngày kết thúc.');
        print("Lỗi: Ngày bắt đầu phải nhỏ hơn hoặc bằng ngày kết thúc.");
        return null;
      }

      double hoursDifference = toDate.difference(fromDate).inMinutes / 60.0;

      // Tính số giờ giữa hai mốc thời gian
      return double.parse(hoursDifference.toStringAsFixed(2));
    } catch (e) {
      print("Lỗi: Định dạng ngày giờ không hợp lệ.  $fromDateString - $toDateString");
      return 0;
    }
  }

  // Hàm kiểm tra kiểu DateTime và chuyển đổi nếu cần
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return "Không có dữ liệu";
    }
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return "Dữ liệu không hợp lệ";
    }
  }

  static buildLine(){
    return Padding(
      padding: const EdgeInsets.only(top: 10,bottom: 10),
      child: Container(
        height: 8,
        width: double.infinity,
        color: grey_200,
      ),
    );
  }

  static Future<DateTime?> dateTimePickerCustom(BuildContext context) async {
    DateTime? dateTime = DateTime.now();
    dateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      lastDate: DateTime.now().add(
        const Duration(days: 3652),
      ),
      is24HourMode: false,
      isShowSeconds: false,
      type: OmniDateTimePickerType.date,
      minutesInterval: 1,
      secondsInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      // constraints: const BoxConstraints(
      //   maxWidth: 350,
      //   maxHeight: 650,
      // ),
      theme: ThemeData(
        useMaterial3: false,
        colorSchemeSeed: subColor,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(
            Tween(
              begin: 0,
              end: 1,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: false,
      selectableDayPredicate: (dateTime) {
        // Disable 25th Feb 2023
        if (dateTime == DateTime(2023, 2, 25)) {
          return false;
        } else {
          return true;
        }
      },
    );
    return dateTime;
  }

  static Stream<Position> getPositionStream(
      {LocationSettings? locationSettings,}
      )=> GeolocatorPlatform.instance.getPositionStream(
      locationSettings: locationSettings ?? const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // Không filter, lấy mọi vị trí mới
        timeLimit: Duration(seconds: 30),
      )
  );

  static double getDistance(pLat, pLng, _currentPosition){
    double earthRadius = 6371000;
    var dLat = vector.radians(pLat - _currentPosition.latitude);
    var dLng = vector.radians(pLng - _currentPosition.longitude);
    var a = sin(dLat/2) * sin(dLat/2) + cos(vector.radians(_currentPosition.latitude))
        * cos(vector.radians(pLat)) * sin(dLng/2) * sin(dLng/2);
    var c = 2 * atan2(sqrt(a), sqrt(1-a));
    var d = earthRadius * c;
    print("$d met =<<<<<<,");
    return d;
  }

  /// Kiểm tra độ chính xác của GPS
  static bool isGpsAccurate(Position? position, {double maxAccuracy = 100}) {
    if (position == null || position.accuracy == null) return false;
    return position.accuracy <= maxAccuracy;
  }

  /// Lấy vị trí với retry mechanism - BẮT BUỘC lấy vị trí mới, không cache
  static Future<Position?> getLocationWithRetry({
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 30),
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        print('GPS attempt ${i + 1}/$maxRetries - Getting fresh location');
        
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: accuracy,
          timeLimit: timeout,
          forceAndroidLocationManager: true, // Bắt buộc sử dụng GPS mới
        );
        
        // Kiểm tra accuracy
        if (isGpsAccurate(position)) {
          print('GPS success: accuracy ${position.accuracy}m');
          return position;
        } else {
          print('GPS accuracy low: ${position.accuracy}m, retrying...');
          if (i == maxRetries - 1) {
            // Lần cuối cùng, chấp nhận vị trí dù accuracy thấp
            print('Final attempt: accepting GPS with accuracy ${position.accuracy}m');
            return position;
          }
        }
      } catch (e) {
        print('GPS attempt ${i + 1} failed: $e');
        if (i == maxRetries - 1) {
          print('All GPS attempts failed - no cached location used');
          return null;
        }
        // Đợi trước khi thử lại
        await Future.delayed(Duration(seconds: 2 * (i + 1)));
      }
    }
    return null;
  }

  static double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  static String getNewLineString(List<String> readLines) {
    StringBuffer sb = StringBuffer();
    for (String line in readLines) {
      sb.write(line + "\n");
    }
    return sb.toString();
  }

  static void selectDatePicker(
      BuildContext context, ValueChanged<DateTime> chooseDate,
      {required DateTime initDate}) async {
    // DatePicker.showDatePicker(context,
    //     currentTime: initDate,
    //     showTitleActions: true,
    //     minTime: DateTime.utc(1899, 12, 31),
    //     maxTime: DateTime.now(),
    //     locale: LocaleType.vi, onConfirm: (date) {
    //       chooseDate(date);
    //     });
  }

  static String convertKeySearch(String keySearch) {
    String convertString = '';
    if(keySearch.toString() != null && keySearch.toString() != ''){
      if(keySearch.contains(' ')){
        convertString = '';
        List<String> listConvert = keySearch.split(' ');
        print(listConvert.length);
        for (int index = 0;index < listConvert.length; index++) {
          if(index == 0){
            convertString = "{i} like N'%${listConvert[index]}%'";
          }else{
            convertString += " and {i} like N'%${listConvert[index]}%'";
          }
        }}
      else{
        convertString = convertString = "{i} like N'%$keySearch%'";
      }
    }else{
      convertString = '';
    }
    return convertString.toString();
  }

  static String? base64Image(File file) {
    if (file == null) return null;
    List<int> imageBytes = file.readAsBytesSync();
    return base64Encode(imageBytes);
  }

  static bool isEmpty(Object text) {
    if (text is String) return text.isEmpty;
    if (text is List) return  text.isEmpty;
    // ignore: unnecessary_null_comparison
    return text == null;
  }

  static Uint8List hexToUint8List(String hex) {
    // ignore: unnecessary_type_check
    if (hex is! String) {
      throw 'Expected string containing hex digits';
    }
    if (hex.length % 2 != 0) {
      throw 'Odd number of hex digits';
    }
    var l = hex.length ~/ 2;
    var result =  Uint8List(l);
    for (var i = 0; i < l; ++i) {
      var x = int.parse(hex.substring(i * 2, (2 * (i + 1))), radix: 16);
      if (x.isNaN) {
        throw 'Expected hex string';
      }
      result[i] = x;
    }
    return result;
  }

  static String getAutoFillHints(LoginUserType userType) {
    switch (userType) {
      case LoginUserType.hostId:
        return AutofillHints.jobTitle;
      case LoginUserType.name:
        return AutofillHints.username;
      case LoginUserType.phone:
        return AutofillHints.telephoneNumber;
      case LoginUserType.email:
      default:
        return AutofillHints.email;
    }
  }


  static void showDialogTwoButton(
      {required BuildContext context,
        String? title,
        required Widget contentWidget,
        required List<Widget> actions,
        bool dismissible = false}) =>
      showDialog(
          barrierDismissible: dismissible,
          context: context,
          builder: (context) {
            return AlertDialog(
                title: title != null ? Text(title) : null,
                content: contentWidget,
                actions: actions);
          });


  static TextInputType getKeyboardType(LoginUserType userType) {
    switch (userType) {
      case LoginUserType.name:
        return TextInputType.name;
      case LoginUserType.phone:
        return TextInputType.number;
      case LoginUserType.email:
      default:
        return TextInputType.emailAddress;
    }
  }

  static Icon getPrefixIcon(LoginUserType userType) {
    switch (userType) {
      case LoginUserType.name:
        return const Icon(FontAwesomeIcons.circleUser);
      case LoginUserType.phone:
        return const Icon(FontAwesomeIcons.squarePhoneFlip);
      case LoginUserType.email:
      default:
        return const Icon(FontAwesomeIcons.squareEnvelope);
    }
  }

  static String getLabelText(LoginUserType userType) {
    switch (userType) {
      case LoginUserType.hostId:
        return "Host Id";
      case LoginUserType.name:
        return "Tài khoản";
      case LoginUserType.phone:
        return "Phone";
      case LoginUserType.pass:
      default:
        return "Mật khẩu";
    }
  }

  static bool isNullOrEmpty(String? value) => value == '' || value == null;

  static void showUpgradeAccount(BuildContext context){
    showDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child:const CustomUpgradeComponent(
              showTwoButton: true,
              iconData: Icons.warning_amber_outlined,
              title: 'Nâng cấp tài khoản !!!',
              content: 'Tính năng bị hạn chế. Vui lòng nâng cấp tài khoản để sử dụng tính năng này!',
            ),
          );
        }).then((value)async{
      if(value == 'Yeah'){
        // PersistentNavBarNavigator.pushNewScreen(context, screen: const SupportCenterScreen(),withNavBar: false);
      }
    });
  }

  static void showForegroundNotification(BuildContext context, String title, String text, {VoidCallback? onTapNotification}) {
    showOverlayNotification((context) {
      return Padding(
        padding: const EdgeInsets.only(top: 38,left: 8,right: 8),
        child: Material(
          color: Colors.transparent,
          child: Card(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.white70, width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: InkWell(
                onTap: () {
                  OverlaySupportEntry.of(context)!.dismiss();
                  onTapNotification!();
                },
                child: ListTile(
                  leading: Container(
                    height: 50,
                    width: 50,
                    padding: const EdgeInsets.all(1.5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(60)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60.0),
                      child: Image.asset("assets/icons/logo_dms.png",fit: BoxFit.contain,scale: 1,),
                    ),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black),
                  ),
                  subtitle: Text(text,style:  const TextStyle(color: Colors.black),),
                ),
              ),
            ),
          ),
        ),
      );
    }, duration: const Duration(milliseconds: 4000));
  }

  // static void saveDataLogin(SharedPreferences prefs, LoginResponseUser user,String accessToken, String refreshToken) {
  //   prefs.setString(Const.USER_ID, user.userId!.toString());
  //   // prefs.setString(Const.ACCESS_TOKEN, accessToken);
  //   prefs.setString(Const.REFRESH_TOKEN, refreshToken);
  //   prefs.setString(Const.USER_NAME, user.userName??"");
  //   prefs.setString(Const.PHONE_NUMBER, user.phoneNumber??"");
  //   prefs.setString(Const.CODE, user.code.toString());
  //   prefs.setString(Const.CODE_NAME, user.codeName??"");
  //   prefs.setString(Const.EMAIL, user.email??"");
  // }
  //
  // static void saveDataUser({required SharedPreferences prefs,required String accessToken,required String refreshToken,required String userId,
  //   required String userName,required String fullName}) {
  //   prefs.setString(Const.USER_ID, userId.toString());
  //   prefs.setString(Const.ACCESS_TOKEN, accessToken);
  //   prefs.setString(Const.REFRESH_TOKEN, refreshToken);
  //   prefs.setString(Const.USER_NAME, userName);
  //   prefs.setString(Const.FULL_NAME, fullName);
  // }
  //
  // static void removeData(SharedPreferences prefs) {
  //   prefs.remove(Const.USER_ID);
  //   prefs.remove(Const.USER_NAME);
  //   prefs.remove(Const.ACCESS_TOKEN);
  //   prefs.remove(Const.REFRESH_TOKEN);
  //   prefs.remove(Const.PHONE_NUMBER);
  //   prefs.remove(Const.EMAIL);
  //   prefs.remove(Const.CODE);
  //   prefs.remove(Const.CODE_NAME);
  // }

  static navigateNextFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static String formatMoney(dynamic amount) {
    return NumberFormat.simpleCurrency(locale: "vi_VN").format(amount)
        .replaceAll(' ', '').replaceAll('.', ',')
        .replaceAll('₫', '');
  }

  static String formatMoneyStringToDouble(dynamic amount) {
    if (amount == null) return '0';
    try {
      double value = double.parse(amount.toString());
      // Nếu là số nguyên, không hiển thị phần thập phân
      if (value == value.roundToDouble()) {
        final formatter = NumberFormat('#,##0', 'en_US');
        return formatter.format(value);
      }
      // Nếu có phần thập phân
      final formatter = NumberFormat('#,##0.##', 'en_US');
      return formatter.format(value);
    } catch (e) {
      return '0';
    }
  }

  static String formatQuantity(dynamic value) {
    if (value == null) return '0';
    try {
      double amount = double.parse(value.toString());
      // Nếu là số nguyên
      if (amount == amount.roundToDouble()) {
        final formatter = NumberFormat('#,##0', 'en_US');
        return formatter.format(amount);
      }
      // Nếu có phần thập phân
      final formatter = NumberFormat('#,##0.##', 'en_US');
      return formatter.format(amount);
    } catch (e) {
      return value.toString();
    }
  }

  static String formatDecimal(dynamic value, {bool withSeparator = false}) {
    if (value == null) return '0';
    try {
      double amount = double.parse(value.toString());
      
      // Nếu cần separator (cho số lượng)
      if (withSeparator) {
        // Nếu là số nguyên
        if (amount == amount.roundToDouble()) {
          final formatter = NumberFormat('#,##0', 'en_US');
          return formatter.format(amount);
        }
        // Nếu có phần thập phân
        final formatter = NumberFormat('#,##0.##', 'en_US');
        return formatter.format(amount);
      }
      
      // Không cần separator (cho phần trăm)
      // Nếu là số nguyên, không hiển thị .0
      if (amount == amount.roundToDouble()) {
        return amount.toInt().toString();
      }
      // Nếu có phần thập phân, hiển thị (tối đa 2 chữ số)
      String result = amount.toStringAsFixed(2);
      // Loại bỏ số 0 thừa ở cuối
      result = result.replaceAll(RegExp(r'0*$'), '');
      result = result.replaceAll(RegExp(r'\.$'), '');
      return result;
    } catch (e) {
      return '0';
    }
  }

  static bool isTablet() {

    final double devicePixelRatio = ui.window.devicePixelRatio;
    final ui.Size size = ui.window.physicalSize;
    final double width = size.width;
    final double height = size.height;

    if(devicePixelRatio < 2 && (width >= 1000 || height >= 1000)) {
      return true;
    }
    else if(devicePixelRatio == 2 && (width >= 1920 || height >= 1920)) {
      return true;
    }
    else {
      return false;
    }

  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static getCountByScreen(BuildContext context) {
    if (isTablet()) {
      return isPortrait(context) ? 2 : 5;
    } else {
      return /*isPortrait(context) ? 2 : 3*/ 2;
    }
  }

  static bool isInteger(num value) => value is int || value == value.roundToDouble();

  static String formatNumber(num amount) {
    return isInteger(amount) ? amount.toStringAsFixed(0) : amount.toString();
  }

  static String formatDecimalNumber(dynamic amount) {
    if (amount == null) return '';
    
    try {
      double value = double.parse(amount.toString());
      // Nếu là số nguyên (không có phần thập phân)
      if (value == value.roundToDouble()) {
        return value.toInt().toString();
      }
      // Nếu có phần thập phân, loại bỏ .0 ở cuối
      String result = value.toString();
      if (result.endsWith('.0')) {
        return result.substring(0, result.length - 2);
      }
      return result;
    } catch (e) {
      return amount.toString();
    }
  }

  static void showCustomToast(BuildContext context,IconData icon, String title){
    showToastWidget(
      customToast(context, icon, title),
      duration: const Duration(seconds: 3),
      onDismiss: () {},
    );
  }

  static String parseDateToString(DateTime dateTime, String format) {
    String date = "";

    if (dateTime != null) {
      try {
        date = DateFormat(format).format(dateTime);
      } on FormatException catch (e) {
        print(e);
      }
    }
    return date;
  }

  static String parseStringDateToString(String dateSv, String fromFormat, String toFormat) {
    String date = "";
    if (dateSv != null) {
      try {
        date = DateFormat(toFormat, "en_US")
            .format(DateFormat(fromFormat).parse(dateSv));
      } on FormatException catch (e) {
        print(e);
      }
    }
    return date;
  }

  static DateTime parseStringToDate(String dateStr, String format) {
    DateTime date = DateTime.now();
    if (dateStr != null) {
      try {
        date = DateFormat(format).parse(dateStr);
      } on FormatException catch (e) {
        print(e);
      }
    }
    return date;
  }

  static String parseDateTToString(String dateInput,String format){
    String date = "";
    DateTime parseDate =  DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(dateInput);
    var inputDate = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat(format);
    date = outputFormat.format(inputDate);
    return date;
  }

  static String formatTotalMoney(dynamic amount) {

    String totalMoney = NumberFormat.simpleCurrency(locale: "vi_VN").format(amount)
        .replaceAll(' ', '').replaceAll('.', ' ')
        .replaceAll('₫', '').toString();
    if(totalMoney.split(' ').length == 1 || totalMoney.split(' ').length == 2){
      return totalMoney;
    }else{
      return '${totalMoney.split(' ')[0]} ${totalMoney.split(' ')[1]}';
    }
  }
}