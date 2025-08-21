// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dms/model/network/request/apply_discount_request.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../screen/login/login_screen.dart';
import '../../../utils/const.dart';
import '../../../utils/log.dart';
import '../../../utils/utils.dart';
import '../../model/network/request/confirm_shipping_request.dart';
import '../../model/network/response/entity_response.dart';
import '../../model/network/services/host.dart';
import 'models/direction_data.dart';
import 'models/init_data.dart';
import 'models/order_model.dart';

class NetWorkFactoryApi{
  BuildContext context;
  Dio? _dio;
  bool? isGoogle;
  String? refToken;
  String? token;

  NetWorkFactoryApi(this.context) {
    HostSingleton hostSingleton = HostSingleton();
    hostSingleton.showError();


    _dio = Dio(BaseOptions(
      baseUrl: "https://api-node.sse.net.vn",
      receiveTimeout: Duration(milliseconds:20000),
      connectTimeout: Duration(milliseconds:20000),
    ));
    _setupLoggingInterceptor();
  }

  void _setupLoggingInterceptor(){
    int maxCharactersPerLine = 200;
    refToken = Const.REFRESH_TOKEN;
    _dio!.interceptors.clear();
    _dio!.interceptors.add(InterceptorsWrapper(
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
            Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Đường truyền mạng không ổn định');
          }
          if (error.response?.statusCode == 402) {
            try {
              await _dio!.post(
                  "https://refresh.api",
                  data: jsonEncode(
                      {"refresh_token": refToken}))
                  .then((value) async {
                if (value.statusCode == 201) {
                  //get new tokens ...
                  //set bearer
                  error.requestOptions.headers["Authorization"] =
                      "Bearer " + token!;
                  //create request with new access token
                  final opts = Options(
                      method: error.requestOptions.method,
                      headers: error.requestOptions.headers);
                  final cloneReq = await _dio!.request(error.requestOptions.path,
                      options: opts,
                      data: error.requestOptions.data,
                      queryParameters: error.requestOptions.queryParameters);

                  return handler.resolve(cloneReq);
                }
                return handler.next(error);
              });
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
            Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Có lỗi xảy, vui lòng liên hệ NCC');
            // pushNewScreen(context, screen: const LoginScreen(),withNavBar: false);
          }
          return handler.next(error); //continue
        })
    );
  }

  Future<Object> requestApi(Future<Response> request) async {
    try {
      Response response = await request;
      var data = response.data;
      if (!data.toString().contains("statusCode"))
      {
        if(response.statusCode == 200 && response.statusMessage == 'OK'){
          return data;
        }
        else if(response.statusCode == 204){ /// No content
          EntityResponse res = EntityResponse(
              statusCode: response.statusCode,
              message: response.statusMessage.toString(),
          );
          data = res;
          return data;
        }
      }
      if (data["statusCode"] == 200 || data["status"] == 200 || data["status"] == "OK") {
        return data;
      } else {
        if (data["statusCode"] == 423) {
        }
        else if (data["statusCode"] == 401) {
          try {
            Utils.showCustomToast(context,Icons.warning,data["message"].toString());
            try {
              if(data["message"] == "Phiên làm việc đã hết hạn vui lòng đăng nhập lại để tiếp tục sử dụng dịch vụ"){
                // libGetX.Get.offAll(LoginScreen());
                // MainBloc mainBloc = BlocProvider.of<MainBloc>(context);
                // mainBloc.add(LogoutMainEvent());
              }
              // MainBloc mainBloc = BlocProvider.of<MainBloc>(context);
              // mainBloc.add(LogoutMainEvent());
            } catch (e) {
              debugPrint(e.toString());
            }
          } catch (e) {
            debugPrint(e.toString());
          }
        }
        return data["message"];
      }
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
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
              PersistentNavBarNavigator.pushNewScreen(context, screen: const LoginScreen(),withNavBar: false);
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
            Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Có lỗi xảy ra, vui lòng liên hệ nhà cung cấp');
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

  /// List API
  Future<Object> getConnection() async {
    return await requestApi(_dio!.get('api/check-connect'));
  }


  Future<InitData> getInit(String token) async {
    final result =  await requestApi(_dio!.get('/api/v1/init', options: Options(headers: {"Authorization": "Bearer $token"})));
    if (result is String) {
      return InitData(isStart: false,isEnd: false,isTimeCallApi: 0,target: Target());
    }
    else{
      final value = InitData.fromJson(result as Map<String,dynamic>);
      return value;
    }
  }

  Future<List<OrderModel>> getMyOrderToday({String? token,String? dateForm, String? dateTo}) async {
    final result = await requestApi(_dio!.get('/api/v1/order/my-order/list-address',
        options: Options(headers: {"Authorization": "Bearer $token"}),queryParameters: {
          "start_date": dateForm,
          "end_date":dateTo,
        }));
    if (result is String) {
      return [];
    }
    else{
      List<OrderModel> listOrder = [];
      listOrder.addAll((result as List).map((e) => OrderModel.fromJson(e)).toList());
      return listOrder;
    }
  }


  Future<DirectionData> getDirection({String? token}) async {
    final result = await requestApi(_dio!.get('/api/v1/location/get-location-to-target',
        options: Options(headers: {"Authorization": "Bearer $token"})));
    if (result is String) {
      return DirectionData(data: null,status: 500);
    }
    else{
      final value = DirectionData.fromJson(result as Map<String,dynamic>);
      return value;
    }
  }

  Future<dynamic> updateOrder({required ConfirmShippingRequest request,required String id, String? token}) async {
    final result = await requestApi(_dio!.post('/api/v1/order/my-order/confirm/$id', options: Options(headers: {"Authorization": "Bearer $token"}),data: request.toJson()));
    return result;
  }

  // Future<Object> updateLocationAndImageTransit({required FormData request,required String token}) async {
  //   return await requestApi(_dio!.post('/api/v1/todos/image-delivery',
  //       options: Options(
  //           headers: {
  //             "Authorization": "Bearer $token",
  //             "Content-Type": "multipart/form-data"
  //           }),
  //       data: request
  //   ));
  // }

}