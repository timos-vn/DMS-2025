import 'package:dio/dio.dart';

import '../../../utils/const.dart';

var dioGoogle = Dio(BaseOptions(
  baseUrl: Const.HOST_GOOGLE_MAP_URL,
  receiveTimeout: Duration(milliseconds: 20000),
  connectTimeout: Duration(milliseconds: 20000),
));