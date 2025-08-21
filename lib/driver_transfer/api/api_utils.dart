import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../model/network/request/confirm_shipping_request.dart';
import '../../model/network/services/host.dart';
import '../../utils/const.dart';
import '../../utils/log.dart';
import '../../utils/utils.dart';
import 'models/direction_data.dart';
import 'models/employee_model.dart';
import 'models/init_data.dart';
import 'models/order_detail_model.dart';
import 'models/order_model.dart';
import 'models/user_model.dart';

String? refToken;
// String baseUrl = 'https://sse.gover.vn/api/v1';
String baseUrl = 'https://api-node.sse.net.vn/api/v1';
Dio dio = Dio()
  ..options.headers = {
  'Content-Type': 'application/json',
    "Accept": "application/json",
  };

void _setupLoggingInterceptor(){
  int maxCharactersPerLine = 200;
  refToken = Const.REFRESH_TOKEN;
  dio.interceptors.clear();
  dio.interceptors.add(InterceptorsWrapper(
      onRequest:(RequestOptions options, handler){
        logger.d("--> ${options.method} ${options.path}");
        logger.d("Content type: ${options.contentType}");
        logger.d("Request body: ${options.data}");
        logger.d("<-- END HTTP");
        return handler.next(options);
      },
      onResponse: (Response response, handler) {
        // Do something with response data
        logger.d("<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}");
        String responseAsString = response.data.toString();
        if (responseAsString.length > maxCharactersPerLine) {
          int iterations = (responseAsString.length / maxCharactersPerLine).floor();
          for (int i = 0; i <= iterations; i++) {
            int endingIndex = i * maxCharactersPerLine + maxCharactersPerLine;
            if (endingIndex > responseAsString.length) {
              endingIndex = responseAsString.length;
            }
            print(responseAsString.substring(i * maxCharactersPerLine, endingIndex));
          }
        } else {
          logger.d(response.data);
        }
        logger.d("<-- END HTTP");
        return handler.next(response); // continue
      },
      onError: (DioError error,handler) async{
        // Do something with response error
        logger.e("DioError: ${error.message}");
        if(error.type == DioErrorType.connectionTimeout){
          // Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Đường truyền mạng không ổn định');
        }
        if (error.response?.statusCode == 402) {
          try {
            // await dio.post(
            //     "https://refresh.api",
            //     data: jsonEncode(
            //         {"refresh_token": refToken}))
            //     .then((value) async {
            //   if (value.statusCode == 201) {
            //     //get new tokens ...
            //     //set bearer
            //     error.requestOptions.headers["Authorization"] =
            //         "Bearer " + token!;
            //     //create request with new access token
            //     final opts = Options(
            //         method: error.requestOptions.method,
            //         headers: error.requestOptions.headers);
            //     final cloneReq = await dio.request(error.requestOptions.path,
            //         options: opts,
            //         data: error.requestOptions.data,
            //         queryParameters: error.requestOptions.queryParameters);
            //
            //     return handler.resolve(cloneReq);
            //   }
            //   return handler.next(error);
            // });
            return handler.next(error);
          } catch (e, st) {
            logger.e(e.toString());
          }
        }
        if (error.response?.statusCode == 401) {
          // Utils.showToast('Hết phiên làm việc');
          // libGetX.Get.offAll(LoginPage());
        }
        else{
          // ignore: use_build_context_synchronously
          // Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Có lỗi xảy, vui lòng liên hệ NCC');
          // pushNewScreen(context, screen: const LoginScreen(),withNavBar: false);
        }
        return handler.next(error); //continue
      })
  );
}

Future<Object> requestApi(Future<Response> request,{ bool isDownloadFile = false}) async {
  try {
    Response response = await request;
    var data = response.data;
    if(isDownloadFile == true){
      return data;
    }
    else if (data["statusCode"] == 200 || data["status"] == 200 || data["status"] == "OK") {
      return data;
    }
    else {
      if (data["statusCode"] == 423) {
        //showOverlay((context, t) => UpgradePopup(message: data["message"],));
      } else if (data["statusCode"] == 401) {
        try {
          // Authen authBloc =
          // BlocProvider.of<AuthenticationBloc>(context);
          // authBloc.add(LoggedOut());
        } catch (e) {
          debugPrint(e.toString());
        }
      }
      return data["message"];
    }
  } catch (error, stacktrace) {
    return _handleError(error);
  }
}

String _handleError(dynamic error) {
  String errorDescription = "";
  logger.e(error?.toString());
  if (error is DioError) {
    switch (error.type) {
      case DioErrorType.sendTimeout:
        errorDescription = 'Kiểm tra kết nối mạng của bạn';
        break;
      case DioErrorType.cancel:
        errorDescription = 'ErrorSWC';
        break;
      case DioErrorType.connectionTimeout:
        errorDescription = 'Kiểm tra kết nối mạng của bạn';
        break;
      case DioErrorType.unknown:
        if(error.message.toString().contains('No address associated with hostname')){
          errorDescription = 'Kiểm tra HostId của bạn';
        }else{
          errorDescription = error.message.toString();
        }
        break;
      case DioErrorType.receiveTimeout:
        errorDescription = 'Kiểm tra kết nối mạng của bạn';
        break;
      case DioErrorType.badResponse:
        var errorData = error.response?.data;
        String? message;
        int? code;
        if (!Utils.isEmpty(errorData)) {
          if(errorData is String){
            message = 'Không tìm thấy địa chỉ host server';
            code = 404;
          } else{
            message = errorData["message"].toString();
            code = errorData["statusCode"];
          }
        }
        else {
          code = error.response!.statusCode;
        }
        errorDescription = message ?? "ErrorCode" ': $code';
        print('OutNet 1');
        if (code == 401) {
          try {
           // PersistentNavBarNavigator.pushNewScreen(context, screen: const LoginScreen(),withNavBar: false);
            //libGetX.Get.offAll(LoginPage());
            // MainBloc mainBloc = BlocProvider.of<MainBloc>(context);
            // mainBloc.add(LogoutMainEvent());
          } catch (e) {
            debugPrint(e.toString());
          }
        }
        else if (code == 423) {
          try {
            // AuthenticationBloc authBloc =
            // BlocProvider.of<AuthenticationBloc>(context);
            // authBloc.add(ShowUpgradeDialogEvent(message ?? ""));
          } catch (e) {
            debugPrint(e.toString());
          }
          //showOverlay((context, t) => UpgradePopup(message: message ?? "",), duration: Duration.zero);
        }
        else if(code == 0){
          // HostSingleton? hostSingleton;
          // Const.HOST_URL = DataLocal.hotIdName;
          // hostSingleton = HostSingleton();
          // hostSingleton.host = Const.HOST_URL;
          // hostSingleton.port = Const.PORT_URL;
        //  Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Có lỗi xảy ra, vui lòng liên hệ nhà cung cấp');
          // pushNewScreen(context, screen: const LoginScreen(),withNavBar: false);
        }
        break;
      default:
        errorDescription = 'Có lỗi xảy ra.';
    }
  }
  else {
    errorDescription = 'Có lỗi xảy ra.';
  }
  return errorDescription;
}

Future<UserModel> login({String? account, String? pass}) async {
  final data = {"username": account, "password": pass};
  final result = await dio.post("$baseUrl/auth/login", data: data);
  final value = UserModel.fromJson(result.data!);
  return value;
}

// Future<InitData> getInit({String? token}) async {
//   _setupLoggingInterceptor();
//   final result = await dio.get("$baseUrl/init", options: Options(headers: {"Authorization": "Bearer $token"}));
//   if (result.data is String) {
//     return InitData(isStart: false,isEnd: false,isTimeCallApi: 0,target: Target());
//   }
//   else{
//     final value = InitData.fromJson(result.data!);
//     return value;
//   }
// }

// Future<List<OrderModel>> getMyOrderToday({String? token}) async {
//   final result = await dio.get(
//     "$baseUrl/order/my-order/list-address",
//     options: Options(headers: {"Authorization": "Bearer $token"},validateStatus: (_) => true,),
//   );
//   var value = List<OrderModel>.from(result.data!.map((x) => OrderModel.fromJson(x)));
//   return value;
// }

Future<List<OrderModel>> getMyOrder({
  String? fromdate,
  String? todate,
  String? token,
  int? page,
  int? limit,
}) async {
  final queryParameters = <String, dynamic>{
    r'fromdate': fromdate,
    r'todate': todate,
    r'page': page,
    r'limit': limit,
  };

  final result = await dio.get(
    "$baseUrl/order/my-order",
    queryParameters: queryParameters,
    options: Options(headers: {"Authorization": "Bearer $token"},validateStatus: (_) => true),
  );
  var value = List<OrderModel>.from(result.data!.map((x) => OrderModel.fromJson(x)));
  return value;
}

Future<OrderDetailModel> getOrderDetail({String? id, String? token}) async {
  final queryParameters = <String, dynamic>{};
  final result = await dio.get(
    "$baseUrl/order/my-order/detail/$id",
    queryParameters: queryParameters,
    options: Options(headers: {"Authorization": "Bearer $token"},validateStatus: (_) => true),
  );
  final value = OrderDetailModel.fromJson(result.data!);
  return value;
}

Future<dynamic> updateTarget({String? id, String? token}) async {
  print('update-target');
  final data = {"order_id": id};
  final headers = <String, dynamic>{r'token': token};
  final result = await dio.post(
    "$baseUrl/order/my-order/update-target",
    data: data,
    options: Options(headers: {"Authorization": "Bearer $token"},validateStatus: (_) => true),
  );
  return result.data;
}

Future<dynamic> updateOrder2({required ConfirmShippingRequest request,required String id, String? token}) async {
  final queryParameters = <String, dynamic>{};
  final headers = <String, dynamic>{r'token': token};
  final result = await dio.post(
    "$baseUrl/order/my-order/confirm/$id",
    queryParameters: queryParameters,data: request.toJson(),
    options: Options(headers: {"Authorization": "Bearer $token"},validateStatus: (_) => true),
  );
  return result.data;
}

//
// Future<DirectionData> getDirection({String? token}) async {
//   _setupLoggingInterceptor();
//   final result = await dio.get(
//     "$baseUrl/location/get-location-to-target",
//     options: Options(headers: {"Authorization": "Bearer $token"},validateStatus: (_) => true),
//   );
//   final value = DirectionData.fromJson(result.data!);
//   return value;
// }

Future<dynamic> startSession({double? lat, double? lng, String? token}) async {
  final headers = <String, dynamic>{r'token': token};
  final data = {"lat": lat, "lng": lng};
  final result =
      await dio.post("$baseUrl/session/start", data: data, options: Options(headers: {"Authorization": "Bearer $token"},validateStatus: (_) => true));
  return result.data;
}

Future<dynamic> updateLocation({double? lat, double? lng, String? token}) async {
  final headers = <String, dynamic>{r'token': token};
  final data = {"lat": lat, "lng": lng};
  final result = await dio.post("$baseUrl/location/update-my-location",
      data: data, options: Options(headers: {"Authorization": "Bearer $token"},validateStatus: (_) => true));
  return result.data;
}

/////////////////////////////////////////////////////
Future<List<EmployeeModel>> getEmployee({String? token}) async {
  _setupLoggingInterceptor();
  final queryParameters = <String, dynamic>{};
  final headers = <String, dynamic>{r'token': token};
  print("$baseUrl/manager/location-current-employee");
  print("${headers}");
  print("${token}");
  final result = await dio.get(
    "$baseUrl/manager/location-current-employee",
    queryParameters: queryParameters,
    options: Options(headers: {"Authorization": "Bearer $token"},validateStatus: (_) => true,),
  );

  var value = List<EmployeeModel>.from(result.data!.map((x) => EmployeeModel.fromJson(x)));
  return value;
}

Future<List<OrderModel>> getEmployeeOrder({String? date, String? id, String? token}) async {
  final queryParameters = <String, dynamic>{r'date': date, r'employee_id': id};
  final headers = <String, dynamic>{r'token': token};
  final result = await dio.get(
    "$baseUrl/manager/history-by-employee",
    queryParameters: queryParameters,
    options: Options(headers: {"Authorization": "Bearer $token"},validateStatus: (_) => true),
  );
  var value = List<OrderModel>.from(result.data!.map((x) => OrderModel.fromJson(x)));
  return value;
}

Future<List<EmployeeModel>> getEmployeeRoute({String? date, String? id, String? token}) async {
  final queryParameters = <String, dynamic>{r'date': date, r'employee_id': id};
  final headers = <String, dynamic>{r'token': token};
  final result = await dio.get(
    "$baseUrl/manager/history-route-employee",
    queryParameters: queryParameters,
    options: Options(headers: {"Authorization": "Bearer $token"},validateStatus: (_) => true),
  );
  var value = List<EmployeeModel>.from(result.data!.map((x) => EmployeeModel.fromJson(x)));
  return value;
}

Future<DirectionData> getEmployeeDirection({String? id, String? token}) async {
  final headers = <String, dynamic>{r'token': token};
  final queryParameters = <String, dynamic>{r'employee_id': id};
  final result = await dio.get(
    "$baseUrl/manager/route-target-employee",
    queryParameters: queryParameters,
    options: Options(headers: {"Authorization": "Bearer $token"},validateStatus: (_) => true),
  );
  final value = DirectionData.fromJson(result.data!);
  return value;
}
