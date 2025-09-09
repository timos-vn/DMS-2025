// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dms/model/network/request/apply_discount_request.dart';
import 'package:dms/model/network/request/get_list_notification_request.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../utils/const.dart';
import '../../../utils/log.dart';
import '../../../utils/utils.dart';
import '../../database/data_local.dart';
import '../../entity/entity_request.dart';
import '../request/atccept_approval_request.dart';
import '../request/config_request.dart';
import '../request/confirm_dnc_request.dart';
import '../request/confirm_shipping_request.dart';
import '../request/create_delivery_request.dart';
import '../request/create_dnc_request.dart';
import '../request/create_item_holder_request.dart';
import '../request/create_leave_letter_request.dart';
import '../request/create_manufacturing_request.dart';
import '../request/create_order_request.dart';
import '../request/create_order_suggest_request.dart';
import '../request/create_refund_order_request.dart';
import '../request/create_refund_sale_out_request.dart';
import '../request/create_tkcd_request.dart';
import '../request/delivery_plan_request.dart';
import '../request/detail_approval_request.dart';
import '../request/detail_delivery_plan_request.dart';
import '../request/discount_request.dart';
import '../request/dynamic_form_request.dart';
import '../request/get_item_shipping_request.dart';
import '../request/get_list_checkin_request.dart';
import '../request/inventory_request.dart';
import '../request/item_location_modify_requset.dart';
import '../request/list_dnc_request.dart';
import '../request/list_history_order_request.dart';
import '../request/list_shipping_request.dart';
import '../request/list_status_approval_request.dart';
import '../request/login_request.dart';
import '../request/manager_customer_request.dart';
import '../request/new_customer_request.dart';
import '../request/order_create_checkin_request.dart';
import '../request/report_data_request.dart';
import '../request/report_field_lookup_request.dart';
import '../request/report_location_request.dart';
import '../request/result_report_request.dart';
import '../request/save_inventory_control_request.dart';
import '../request/search_list_item_request.dart';
import '../request/stage_statistic_request.dart';
import '../request/store_list_request.dart';
import '../request/time_keeping_history_request.dart';
import '../request/time_keeping_request.dart';
import '../request/update_item_barcode_request.dart';
import '../request/update_order_request.dart';
import '../request/update_plan_delivery_request.dart';
import '../request/update_quantity_warehouse_delivery_card_request.dart';
import 'host.dart';

class NetWorkFactory{
  BuildContext context;
  Dio? _dio;
  bool? isGoogle;
  String? refToken;
  String? token;

  NetWorkFactory(this.context) {
    HostSingleton hostSingleton = HostSingleton();
    hostSingleton.showError();
    String host = hostSingleton.host;
    int port = hostSingleton.port;
    // if (!host.contains("https")) {
    //   host = "https://" + host;
    // }
    _dio = Dio(BaseOptions(
      baseUrl: "$host${port!=0?":$port":""}",
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

  Future<Object> login(LoginRequest request) async {
    return await requestApi(_dio!.post('/api/v1/users/signin', data: request.toJson()));
  }

  Future<Object> getCompanies(String token) async {
    return await requestApi(_dio!.get('/api/v1/users/companies', options: Options(headers: {"Authorization": "Bearer $token"}))); //["Authorization"] = "Bearer " + token
  }

  Future<Object> updateCacheStore(String token, String storeID) async {
    return await requestApi(_dio!.get('/api/v1/users/stores/cached', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
    "storeId": storeID,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> config(ConfigRequest request) async {
    return await requestApi(_dio!.post('/api/v1/users/config', data: request.toJson()));
  }

  Future<Object> getUnits(String token) async {
    return await requestApi(_dio!.get('/api/v1/users/units', options: Options(headers: {"Authorization": "Bearer $token"}))); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getStore(String token, String unitId) async {
    return await requestApi(_dio!.get('/api/v1/users/stores', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "unitId": unitId,
    }));
  }

  Future<Object> updateUId(String token,String uId) async {
    return await requestApi(_dio!.post('/api/v1/users/update-uid-user', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "UIdUser": uId,
    }));
  }

  Future<Object> getDefaultData(String token) async {
    return await requestApi(_dio!.get('/api/v1/home', options: Options(headers: {"Authorization": "Bearer $token"}))); //["Authorization"] = "Bearer " + token
  }
  Future<Object> getListSliderImage(String token) async {
    return await requestApi(_dio!.get('/api/v1/home/get-slider-images', options: Options(headers: {"Authorization": "Bearer $token"}))); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getData(ReportRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/home/reports', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  ///order
  Future<Object> getItemMainGroup(String token) async {
    return await requestApi(_dio!.get('/api/v1/order/item-main-group', options: Options(headers: {"Authorization": "Bearer $token"}))); //["Authorization"] = "Bearer " + token
  }
  Future<Object> getListItemScanRequest(String token, String itemCode,String currency) async {
    return await requestApi(_dio!.get('/api/v1/order/scan-item', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "ItemCode": itemCode,
      "Currency": currency
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListStock({required String token,required String itemCode,required String listKeyGroup,required int checkStock,required int checkGroup,required bool checkStockEmployee}) async {
    return await requestApi(_dio!.get('/api/v1/order/get-list-store-and-group', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "codeProduct": itemCode,
      "checkStock":checkStock,
      "checkGroup":checkGroup,
      "listKeyGroup":listKeyGroup,
      "checkStockEmployee": checkStockEmployee == true ? 1 : 0,
    }));
  }

  Future<Object> getListHistorySaleOut(String token, String dateFrom, String dateTo, String idCustomer,String idTransaction, int pageIndex, int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/todos/list-history-sale-out', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "dateFrom": dateFrom,
      "dateTo": dateTo,
      "idCustomer" : idCustomer,
      "idTransaction" : idTransaction,
      "page_index" : pageIndex,
      "page_count": pageCount
    }));
  }

  Future<Object> getDetailHistorySaleOut(String token, String sttRec, String invoiceDate) async {
    return await requestApi(_dio!.get('/api/v1/todos/detail-history-sale-out', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "stt_rec": sttRec,
      "invoice_date": invoiceDate
    }));
  }
  Future<Object> getListSuggest(String token, String keyWord, String pageIndex, String pageCount) async {
    return await requestApi(_dio!.get('/api/v1/order/list-production-suggest', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "keyWord": keyWord,
      "page_index": pageIndex,
      "page_count": pageCount
    }));
  }

  Future<Object> getItemListSearchOrder(SearchListItemRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/order/search-item-v2', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getItemGroup(String token, int groupType,int level) async {
    return await requestApi(_dio!.get('/api/v1/order/item-group', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "GroupType": groupType,
      "Level":level
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> confirmDNC(ConfirmDNCRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/order/DNC-authorize', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> createLeaveLetter(CreateLeaveLetterRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/hr/create-leave-letter', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> deleteLeaveLetter(String sttRec,String stt, String token) async {
    return await requestApi(_dio!.delete('/api/v1/hr/cancel-leave-letter', options: Options(headers: {"Authorization": "Bearer $token"}),
        queryParameters: {
          "sctRec": sttRec,
          "stt":stt
        }
    ));
  }

  Future<Object> createDNC(CreateDNCRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/order/TaoPhieuDNC', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getDetailDNC(String token, String sttRec) async {
    return await requestApi(_dio!.post('/api/v1/order/DNC-detail', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "stt_rec": sttRec
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListDNCHistory(ListDNCRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/order/DNC_list_history', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getListLeaveLetterHistory(String dateFrom, String dateTo, int pageIndex, int pageCount, String token) async {
    return await requestApi(_dio!.get('/api/v1/hr/history-list-leave-letter', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "page_index": pageIndex,
      "page_count": pageCount,"dateFrom": dateFrom,"dateTo": dateTo,
    }));
  }

  Future<Object> reportFieldLookup(ReportFieldLookupRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/report/report-field-lookup', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> timeKeeping(TimeKeepingRequest request,String token) async {
    return await requestApi(_dio!.post('/api/v1/todos/time-keeping', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getListShipping(ListShippingRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/fulfillment/getlist', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getItemDetailShipping(GetItemShippingRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/fulfillment/detail', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> confirmDetailShipping(ConfirmShippingRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/fulfillment/cofirm',
        options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getProductDetail(String token, String itemCode,String currency) async {
    return await requestApi(_dio!.get('/api/v1/order/item-detail', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "ItemCode": itemCode,
      "Currency":currency
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getDiscountWhenUpdate(DiscountRequest request,String token) async {
    return await requestApi(_dio!.post('/api/v1/discount/get-discount-when-update', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getItemDetailOrder(String token,String sttRec) async {
    return await requestApi(_dio!.post('/api/v1/order/order-detail', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "stt_rec": sttRec,
    }));
  }

  Future<Object> calculatorPayment(DiscountRequest request,String token) async {
    return await requestApi(_dio!.post('/api/v1/discount/checkdiscount', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> updateOrder(UpdateOrderRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/order/update-order-v2', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> createOrder(CreateOrderV3Request request, String token) async {
    return await requestApi(_dio!.post('/api/v1/order/create-order-v3', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> createRefundOrder(CreateRefundOrderRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/order/create-refund-order-v1', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> createRefundSaleOut(CreateRefundSaleOutRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/todos/create-refund-sale-out-v1', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> searchListCustomer(ManagerCustomerRequestBody request, String token) async {
    return await requestApi(_dio!.post('/api/v1/customer/search-customer-list-v2', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getListCustomer(ManagerCustomerRequestBody request, String token) async {
    return await requestApi(_dio!.post('/api/v1/customer/customer-list', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getDetailCustomer(String token, String idCustomer) async {
    return await requestApi(_dio!.get('/api/v1/customer/customer-info', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "CustomerCode": idCustomer
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListHistoryOrder(ListHistoryOrderRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/order/order-list', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }
  Future<Object> getListHistoryOrderV2(ListHistoryOrderRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/order/get-history-order', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getListStageStatistic(StageStatisticRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/order/command_list', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getStoreList(StoreListRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/order/site_list', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> updateTKCDDraft(CreateTKCDRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/order/UpdateTKCDDrafts', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> createTKCD(CreateTKCDRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/order/TaoPhieuTKCD', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getDetailListStageStatistic(String token, String soCT) async {
    return await requestApi(_dio!.get('/api/v1/order/command_detail', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "stt_rec": soCT
    })); //["Authorization"] = "Bearer " + token
  }

  // Future<Object> getListApproval(String token) async {
  //   return await requestApi(_dio!.get('/api/v1/letter-authority/letter-display', options: Options(headers: {"Authorization": "Bearer $token"}))); //["Authorization"] = "Bearer " + token
  // }

  Future<Object> getListApproval(EntityRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/fulfillment/authorize_type_list', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getHTMLApproval(String token, String letterId) async {
    return await requestApi(_dio!.get('/api/v1/letter-authority/detail', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "LetterId": letterId,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListDetailApproval(ListApprovalDetailRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/fulfillment/authorize_list', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getStatusApprovalApproval(ListStatusApprovalRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/fulfillment/authorize_status_list', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> acceptApprovalApproval(AcceptApprovalRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/fulfillment/authorize', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getListReports(String token) async {
    return await requestApi(_dio!.get('/api/v1/report/report-list', options: Options(headers: {"Authorization": "Bearer $token"}))); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListReportLayout(String token, String reportId) async {
    return await requestApi(_dio!.get('/api/v1/report/report-layout', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "ReportId": reportId,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getResultReport(ResultReportRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/report/report-result', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  /// Survey API Methods
  Future<Object> getSurveyQuestions(String token, {
    String? searchKey,
    int pageIndex = 1,
    int pageCount = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'page_index': pageIndex,
      'page_count': pageCount,
    };
    
    if (searchKey != null && searchKey.isNotEmpty) {
      queryParams['searchKey'] = searchKey;
    }

    return await requestApi(_dio!.get(
      '/api/v1/todos/danh-sach-cau-hoi',
      queryParameters: queryParams,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    ));
  }

  Future<Object> getSurveyAnswers(String token, {
    required String sttRec,
    required String maCauHoi,
  }) async {
    final queryParams = <String, dynamic>{
      'stt_rec': sttRec,
      'ma_cau_hoi': maCauHoi,
    };

    return await requestApi(_dio!.get(
      '/api/v1/todos/danh-sach-cau-tra-loi',
      queryParameters: queryParams,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    ));
  }

  Future<Object> submitSurvey(String token, {
    required String customerId,
    required Map<String, dynamic> surveyResults,
  }) async {
    return await requestApi(_dio!.post(
      '/api/v1/todos/submit-survey',
      data: {
        'customerId': customerId,
        'surveyResults': surveyResults,
        'timestamp': DateTime.now().toIso8601String(),
      },
      options: Options(headers: {"Authorization": "Bearer $token"}),
    ));
  }

  Future<Object> getPermissionUser(String token) async {
    return await requestApi(_dio!.get('/api/v1/users/get-permission-user-v2', options: Options(headers: {"Authorization": "Bearer $token"}))); //["Authorization"] = "Bearer " + token
    //return await requestApi(_dio!.get('/api/v1/users/get-permission-user-v2', options: Options(headers: {"Authorization": "Bearer $token"}))); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getSettingOption(String token) async {
    return await requestApi(_dio!.get('/api/v1/users/get-setting-options-v2', options: Options(headers: {"Authorization": "Bearer $token"}))); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListDeliveryPlan(DeliveryPlanRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/fulfillment/list_delivery_plan', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getDetailDeliveryPlan(DeliveryPlanDetailRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/fulfillment/detail_delivery_plan', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> updatePlanDeliveryDraft(UpdatePlanDeliveryRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/fulfillment/update_delivery_plan', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> createPlanDelivery(UpdatePlanDeliveryRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/fulfillment/create_delivery_plan', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getListCheckIn(ListCheckInRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/todos/list-check-in', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getDetailCheckIn(String token, int idCheckIn, String idCustomer) async {
    return await requestApi(_dio!.get('/api/v1/todos/detail-check-in', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "idCheckIn": idCheckIn,
      "idCustomer": idCustomer,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListAlbumImageCheckIn(String token, String idAlbum) async {
    return await requestApi(_dio!.get('/api/v1/todos/list-album-check-in', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "idAlbum": idAlbum,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> saveInventoryControl(InventoryControlAndSaleOutRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/todos/save-inventory-control', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> updateSaleOut(InventoryControlAndSaleOutRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/todos/update-sale-out', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> checkOutStore(FormData request, String token) async {
    return await requestApi(_dio!.post('/api/v1/todos/check-out',
        options: Options(
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "multipart/form-data"
            }),
        data: request
    ));
  }
  Future<Object> checkOutInTimeKeeping(FormData request, String token) async {
    return await requestApi(_dio!.post('/api/v1/todos/time-keeping-meet-customer',
        options: Options(
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "multipart/form-data"
            }),
        data: request,
      onSendProgress: (sent,total){
        print("Upload: ${(sent / total * 100).toStringAsFixed(0)}%");
      }
    ));
  }
  Future<Object> uploadFile({required FormData request,required String controller,required String code,required String token}) async {
    return await requestApi(_dio!.post('/api/v1/general-layout/upload-file',
        options: Options(
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "multipart/form-data"
            }),
        queryParameters: {
        "controller": controller,
        "code": code
        },
        data: request,
      onSendProgress: (sent,total){
        print("Upload: ${(sent / total * 100).toStringAsFixed(0)}%");
      }
    ));
  }

  Future<Object> checkOutInTimeKeepingType2(TimeKeepingRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/todos/time-keeping', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> updateLocationAndImageTransit(FormData request, String token) async {
    return await requestApi(_dio!.post('/api/v1/todos/image-delivery',
        options: Options(
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "multipart/form-data"
            }),
        data: request
    ));
  }

  Future<Object> addNewRequestOpenStore(FormData request, String token) async {
    return await requestApi(_dio!.post('/api/v1/todos/create-request-open-store',
        options: Options(
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "multipart/form-data"
            }),
        data: request
    ));
  }

  Future<Object> addNewCustomerCare(FormData request, String token) async {
    return await requestApi(_dio!.post('/api/v1/customer/customer-care-create',
        options: Options(
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "multipart/form-data"
            }),
        data: request
    ));
  }

  Future<Object> updateRequestOpenStore(FormData request, String token) async {
    return await requestApi(_dio!.post('/api/v1/todos/update-request-open-store',
        options: Options(
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "multipart/form-data"
            }),
        data: request
    ));
  }

  Future<Object> addNewTicket(FormData request, String token) async {
    return await requestApi(_dio!.post('/api/v1/todos/create-new-ticket',
        options: Options(
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "multipart/form-data"
            }),
        data: request
    ));
  }

  Future<Object> getListImageStore(String token, String idCustomer, String idCheckIn, String idAlbum, int pageIndex, int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/todos/list-image-check-in', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "idCustomer": idCustomer,
      "idCheckIn": idCheckIn,
      "idAlbum": idAlbum,
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> cancelRequestOpenStore(String token, String idTour, String idRequestOpenStore,) async {
    return await requestApi(_dio!.get('/api/v1/todos/cancel-request-open-store', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "idTour": idTour,
      "idRequestOpenStore": idRequestOpenStore,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListTour(String token, String searchKey ,int pageIndex, int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/todos/tour-check-in', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "searchKey": searchKey,
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListState(String token, String searchKey ,int pageIndex, int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/todos/list-state-open-store', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "searchKey": searchKey,
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> searchItemTask(String token, String searchKey,String dateTime, int pageIndex, int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/todos/search-list-check-in', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "searchKey": searchKey,
      "dateTime": dateTime,
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListProvince(String token, String idProvince,String idDistrict, int pageIndex, int pageCount, String idArea) async {
    print("idArea");
    print(idArea);

    return await requestApi(_dio!.get('/api/v1/todos/list-province', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "idProvince": idProvince,
      "idDistrict": idDistrict,
      "page_index": pageIndex,
      "page_count": pageCount,
      "idArea": idArea
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListInventory(String token, String idCustomer, String idCheckIn, int pageIndex, int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/todos/list-inventory-check-in', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "idCustomer": idCustomer,
      "idCheckIn": idCheckIn,
      "page_index": pageIndex,
      "page_count": pageCount,

    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListArea(String token,int pageIndex, int pageCount, String keySearch) async {
    return await requestApi(_dio!.get('/api/v1/todos/list-area', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "page_index": pageIndex,
      "page_count": pageCount,
      "searchKey": keySearch,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListTypeStore(String token,int pageIndex, int pageCount, String keySearch) async {
    return await requestApi(_dio!.get('/api/v1/todos/list-type-store', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "page_index": pageIndex,
      "page_count": pageCount,
      "searchKey": keySearch,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListStoreForm(String token,int pageIndex, int pageCount, String keySearch) async {
    return await requestApi(_dio!.get('/api/v1/todos/list-store-form', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "page_index": pageIndex,
      "page_count": pageCount,
      "searchKey": keySearch,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> createOrderFromCheckIn(CreateOrderFromCheckInRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/todos/order-create-from-checkin', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getListTicket(String token, String idCustomer, String idCheckIn, String ticketType, int pageIndex, int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/todos/list-ticket', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "idCustomer": idCustomer,
      "idCheckIn": idCheckIn,
      "ticketType": ticketType,
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListRequestOpenStore(String token, String dateForm,String dateTo, String dateTime,String idKhuVuc,int pageIndex, int pageCount, int status) async {
    return await requestApi(_dio!.get('/api/v1/todos/list-request-open-store', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "dateTime": dateTime,
      "district": idKhuVuc,
      "status": status,
      "page_index": pageIndex,
      "page_count": pageCount,
      "dateForm": dateForm,
      "dateTo": dateTo,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListHistoryCustomerCare(String token, String dateForm,String dateTo,String idCustomer,int pageIndex, int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/customer/list-history-customer-care', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "dateForm": dateForm,
      "dateTo": dateTo,
      "idCustomer": idCustomer,
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListHistoryTicket(String token, String dateForm,String dateTo,String idCustomer,String employeeCode,int status,int pageIndex, int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/todos/list-history-ticket', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "dateForm": dateForm,
      "dateTo": dateTo,
      "status": status,
      "idCustomer": idCustomer,"employeeCode": employeeCode,
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListDetailHistoryTicket(String token, String idTicket) async {
    return await requestApi(_dio!.get('/api/v1/todos/detail-history-ticket', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "idTicket": idTicket,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListOrderCompleted(String token, String dateForm,String dateTo,String idCustomer,int pageIndex, int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/order/list-order-completed', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "dateForm": dateForm,
      "dateTo": dateTo,
      "idCustomer": idCustomer,
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListSaleOutCompleted(String token, String dateForm,String dateTo,String idAgency,int pageIndex, int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/todos/list-sale-out-completed', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "dateForm": dateForm,
      "dateTo": dateTo,
      "idAgency": idAgency,
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListHistoryActionEmployee(String token, String dateForm,String dateTo,String idCustomer,int pageIndex, int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/todos/list-history-action-employee', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "dateForm": dateForm,
      "dateTo": dateTo,
      "idCustomer": idCustomer,
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListHistoryRefundOrder(String token, String dateForm,String dateTo,String idCustomer,int pageIndex, int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/order/list-history-refund-order', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "dateForm": dateForm,
      "dateTo": dateTo,
      "idCustomer": idCustomer,
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }



  Future<Object> getDetailOrderCompleted(String token, String sctRec,String invoiceDate,int pageIndex, int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/order/detail-order-completed', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "sct": sctRec,
      "invoiceDate": invoiceDate,
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getDetailSaleOutCompleted(String token, String sctRec,String invoiceDate,int pageIndex, int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/todos/detail-sale-out-completed', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "sct": sctRec,
      "invoiceDate": invoiceDate,
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getDetailHistoryRefundOrder(String token, String sctRec,String invoiceDate,int pageIndex, int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/order/detail-history-refund-order', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "sct": sctRec,
      "invoiceDate": invoiceDate,
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> deleteAccount(String token) async {
    return await requestApi(_dio!.get('/api/v1/users/delete-account', options: Options(headers: {"Authorization": "Bearer $token"}),)); //["Authorization"] = "Bearer " + token
  }

  Future<Object> addNewCustomer(NewCustomerRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/customer/customer-create', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getDetailRequestOpenStore(String token, String idRequestOpenStore) async {
    return await requestApi(_dio!.get('/api/v1/todos/list-request-open-store-detail', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "idRequestOpenStore": idRequestOpenStore,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> reportLocation(ReportLocationRequest request,String token) async {
    return await requestApi(_dio!.post('/api/v1/todos/report-location', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> reportLocationV2(FormData request, String token) async {
    return await requestApi(_dio!.post('/api/v1/todos/report-location-v2',
        options: Options(
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "multipart/form-data"
            }),
        data: request
    ));
  }

  Future<Object> listTimeKeepingHistory(TimeKeepingHistoryRequest request,String token) async {
    return await requestApi(_dio!.post('/api/v1/todos/time-keeping-history', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getListListTaskOffLine(String token,String dateTime) async {
    return await requestApi(_dio!.get('/api/v1/todos/daily-job-offline', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "dateTime": dateTime,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> applyDiscountV2(ApplyDiscountRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/discount/apply-discount-v2', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> createOrderV3(ApplyDiscountRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/discount/apply-discount-v2', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getListMDC(GetListItemSearchInOrderRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/order/get-list-dispatch-code', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getListNVKD(GetListItemSearchInOrder2Request request, String token) async {
    return await requestApi(_dio!.post('/api/v1/order/get-list-sales-staff-code', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }

  Future<Object> getListVVHD(String token, String idCustomer) async {
    return await requestApi(_dio!.get('/api/v1/order/list-vvhd', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "idCustomer": idCustomer
    })); //["Authorization"] = "Bearer " + token
  }
  Future<Object> getListDVTC(String token, int pageIndex,int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/order/get-list-financial-unit', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }
  Future<Object> getListInventoryRequest(String token,String searchKey ,int pageIndex,int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/todos/danh-sach-kiem-ke-yeu-cau', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "searchKey": searchKey,
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListItemInventory(String token,String sttRec ,String searchKey ,int pageIndex,int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/todos/danh-sach-vat-tu-kiem-ke-yeu-cau', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "stt_rec": sttRec,
      "searchKey": searchKey,
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListContract(String token,String searchKey ,int pageIndex,int pageCount) async {
    return await requestApi(_dio!.get('/api/v1/order/danh-sach-hop-dong', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "searchKey": searchKey,
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }
  Future<Object> getDetailContract(String token,String sttRec,String dateTime ,int pageIndex,int pageCount,String searchKey) async {
    return await requestApi(_dio!.get('/api/v1/order/chi-tiet-hop-dong', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "sttRec": sttRec,
      "ngayCT": dateTime,
      "page_index": pageIndex,
      "page_count": pageCount,
      "searchKey": searchKey,
    })); //["Authorization"] = "Bearer " + token
  }
  Future<Object> getListOrderFormContract(String token, String soCt) async {
    return await requestApi(_dio!.get('/api/v1/order/danh-sach-don-hang-theo-hop-dong', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "so_ct": soCt
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListTax(String token) async {
    return await requestApi(_dio!.get('/api/v1/order/get-list-tax', options: Options(headers: {"Authorization": "Bearer $token"}))); //["Authorization"] = "Bearer " + token
  }
  Future<Object> getListStoreFromSttRec(String sttRec ,String token) async {
    return await requestApi(_dio!.get('/api/v1/todos/danh-sach-kho-kiem-ke-yeu-cau', options: Options(headers: {"Authorization": "Bearer $token"}),
        queryParameters: {
        "stt_rec": sttRec,
          "page_index": 1,
          "page_count": 50,
        }
    ));
  }
  Future<Object> getListHistoryInventoryFromSttRec(String sttRec ,String token) async {
    return await requestApi(_dio!.get('/api/v1/todos/lich-su-kiem-ke-yeu-cau', options: Options(headers: {"Authorization": "Bearer $token"}),
        queryParameters: {
        "stt_rec": sttRec,
        }
    ));
  }

  Future<Object> getListStatusOrder(String token, String vcCode) async {
    return await requestApi(_dio!.get('/api/v1/order/list-status-order', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "vcCode": vcCode
    })); //["Authorization"] = "Bearer " + token
  }
  Future<Object> getKPIHome(String token, String dateType, String storeId) async {
    return await requestApi(_dio!.get('/api/v1/home/KPI', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "dateType": dateType,
      "storeId": storeId,
    })); //["Authorization"] = "Bearer " + token
  }
  Future<Object> getListKPISummaryByDay(String token, String dateForm,String dateTo,) async {
    return await requestApi(_dio!.get('/api/v1/todos/list-kpi-summary', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "dateForm": dateForm,
      "dateTo": dateTo
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListEmployee(String token, int pageIndex, int pageCount, String userCode, String keySearch, int typeAction) async {
    return await requestApi(_dio!.get('/api/v1/users/get-list-employee', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "page_index": pageIndex,
      "page_count": pageCount,
      "userCode": userCode,
      "keySearch": keySearch,
      "typeAction": typeAction,
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getListApproveOrder(String token, String dateForm,String dateTo,int pageIndex,int pageCount,) async {
    return await requestApi(_dio!.get('/api/v1/order/list-approve-order', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "dateForm": dateForm,
      "dateTo": dateTo,
      "page_index": pageIndex,
      "page_count": pageCount,
    })); //["Authorization"] = "Bearer " + token
  }
  Future<Object> deleteOrderHistory(String token,String sttRec) async {
    return await requestApi(_dio!.post('/api/v1/order/order-cancel', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "stt_rec": sttRec,
    }));
  }
  downloadFile(String token,String sttRec) async {
    return await requestApi(_dio!.get('/api/v1/letter-authority/letter-download',
        options: Options(responseType: ResponseType.bytes,headers: {"Authorization": "Bearer $token",'Content-Type': 'application/json'}), queryParameters: {
      "LetterId": sttRec,
    }),isDownloadFile: true);
  }
  Future<Object> approveOrder(String token,String sttRec) async {
    return await requestApi(_dio!.post('/api/v1/order/approve-order', options: Options(headers: {"Authorization": "Bearer $token"}),
        queryParameters: {
          "stcRec": sttRec,
        }
    ));
  }

  Future<Object> createTaskFromCustomer(String token, String idCustomer) async {
    return await requestApi(_dio!.get('/api/v1/todos/create-task-from-customer', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "idCustomer": idCustomer
    })); //["Authorization"] = "Bearer " + token
  }

  Future<Object> getInformationCard({required String token,required String idCard,required String key}) async {
    return await requestApi(_dio!.get('/api/v1/order/get-list-info-card', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "stt_rec": idCard,
      "key": key
    }));
  }
  Future<Object> getKeyBySttRec({required String token,required String sttRec}) async {
    return await requestApi(_dio!.get('/api/v1/order/get-key-by-sttRec', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "stt_rec": sttRec
    }));
  }
  Future<Object> updateQuantityInWarehouseDeliveryCard(UpdateQuantityInWarehouseDeliveryCardRequest request,String token,) async {
    return await requestApi(_dio!.post('/api/v1/order/update-quantity-warehouse-delivery', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }
  Future<Object> createDelivery(CreateDeliveryRequest request,String token,) async {
    return await requestApi(_dio!.post('/api/v1/order/create-delivery-card', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }
  Future<Object> updateItemBarCode(UpdateItemBarCodeRequest request,String token,) async {
    return await requestApi(_dio!.post('/api/v1/order/update-item-barcode', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }
  Future<Object> updatePostPNF(String token,String sttRec) async {
    return await requestApi(_dio!.post('/api/v1/order/update-post-pnf', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "stt_rec": sttRec,
    }));
  }
  Future<Object> getInformationItemFromBarCode({required String token,required String barcode}) async {
    return await requestApi(_dio!.get('/api/v1/order/get-info-item-for-barcode', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "barcode": barcode
    }));
  }
  Future<Object> getItemHolderDetail({required String token,required String sttRec}) async {
    return await requestApi(_dio!.get('/api/v1/order/get-item-holer-detail', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "stt_rec": sttRec
    }));
  }  Future<Object> getListHistoryDNNK({required String token,required String sttRec}) async {
    return await requestApi(_dio!.get('/api/v1/order/get-history-dnnk', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "stt_rec": sttRec
    }));
  }
  Future<Object> getQuantityForTicket({required String token,required String sttRec,required String key,}) async {
    return await requestApi(_dio!.get('/api/v1/fulfillment/kiem-tra-so-luong-thuc-giao', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "stt_rec": sttRec,
      "key_ticket": key,
    }));
  }
  Future<Object> searchListSemiProduction({required String token,required String lsx,required String section,required String searchValue,required int pageIndex,required int pageCount}) async {
    return await requestApi(_dio!.get('/api/v1/manufacturing/get-semi-products', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "lsx": lsx,
      "section": section,
      "searchValue": searchValue,
      "page_index": pageIndex,
      "page_count": pageCount,
    }));
  }
  Future<Object> itemLocationModify(ItemLocationModifyRequest request,String token,) async {
    return await requestApi(_dio!.post('/api/v1/order/item-location-modify', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }
  Future<Object> createItemHolder(CreateItemHolderRequest request,String token,) async {
    return await requestApi(_dio!.post('/api/v1/order/create-item-holder', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }
  Future<Object> deleteItemHolder(String token,String sttRec) async {
    return await requestApi(_dio!.post('/api/v1/order/delete-item-holder', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "stt_rec": sttRec,
    }));
  }
  Future<Object> getListVoucherTransaction({required String token,required String vcCode}) async {
    return await requestApi(_dio!.get('/api/v1/manufacturing/get-voucher-transaction', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "vCCode": vcCode
    }));
  }  Future<Object> getItemMaterials({required String token,required String item}) async {
    return await requestApi(_dio!.get('/api/v1/manufacturing/get-item-materials', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "item": item
    }));
  }
  Future<Object> getListRequestSectionItem({required String token,required String request, required String route, required int pageIndex, required int pageCount}) async {
    return await requestApi(_dio!.get('/api/v1/manufacturing/request-section-item', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "request": request,
      "route": route,
      "page_index": pageIndex,
      "page_count": pageCount,
    }));
  }
  Future<Object> createManufacturing(CreateManufacturingRequest request,String token,) async {
    return await requestApi(_dio!.post('/api/v1/manufacturing/create-factory-transaction-voucher-modify', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }
  Future<Object> createOrderSuggest(CreateOrderSuggestRequest request,String token,) async {
    return await requestApi(_dio!.post('/api/v1/order/create-order-suggest', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }
  Future<Object> getListTypeVoucher(String token, String dateFrom,String dateTo,String voucherCode,String status) async {
    return await requestApi(_dio!.get('/api/v1/order/get-dynamic-list', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "dateFrom": dateFrom,
      "dateTo": dateTo,
      "voucher_code": voucherCode,
      "status": status,
    }));
  }
  Future<Object> getDetailOrderSuggest(String token, String letterId) async {
    return await requestApi(_dio!.get('/api/v1/order/get-detail-order-suggest', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "letterId": letterId,
    }));
  }
  Future<Object> getOrderInfo(String token, String location,String item,String keyType) async {
    return await requestApi(_dio!.get('/api/v1/order/get-advance-order-info', options: Options(headers: {"Authorization": "Bearer $token"}), queryParameters: {
      "location": location,
      "item": item,
      "keyType": keyType,
    }));
  }
  Future<Object> getListNotification(GetListNotificationRequest request, String token) async {
    return await requestApi(_dio!.post('/api/v1/thongbao/get-list-notification', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }
  
  Future<Object> getDetailNotification(String token, String linkDetail, String code, String sttRec, String loaiDuyet, String fcmToken) async {
    return await requestApi(_dio!.post('/api/v1/thongbao/DetailNotify', options: Options(headers: {"Authorization": "Bearer $token"}),data: {
      "code": code,
      "stt_rec": sttRec,
      "loai_duyet": loaiDuyet,
      "token": fcmToken,
    }));
  }

  Future<Object> readOneNotification(String token, String notificationId) async {
    return await requestApi(_dio!.post('/api/v1/thongbao/read-notification', options: Options(headers: {"Authorization": "Bearer $token"}), data: {"code": notificationId}));
  }

  Future<Object> readAllNotification(String token) async {
    return await requestApi(_dio!.post('/api/v1/thongbao/read-all-notification', options: Options(headers: {"Authorization": "Bearer $token"}), data: {}));
  }

  Future<Object> getTotalUnreadNotification(String token) async {
    return await requestApi(_dio!.post('/api/v1/thongbao/get-notification-unRead', options: Options(headers: {"Authorization": "Bearer $token"}), data: {}));
  }

  Future<Object> changePassword(String token, String newPass) async {
    return await requestApi(_dio!.post('/api/v1/users/ChangePassword', options: Options(headers: {"Authorization": "Bearer $token"}), data: {"new_pass": newPass}));
  }


   Future<Object> getListProposal(String token, int pageSize, int pageIndex, String controller,var request) async {
    return await requestApi(_dio!.post('/api/v1/general-layout/get-grid-viewpage', options: Options(headers: {"Authorization": "Bearer $token", "Content-Type": "application/json",}),
        data: request, queryParameters: {
      "pageSize": pageSize,
      "pageIndex": pageIndex,
      "controller": controller,
    }));
  }

  Future<Object> getListLookupDynamicForm(String token, int pageSize, int pageIndex, String controller,var request) async {
    return await requestApi(_dio!.post('/api/v1/general-layout/get-lookup-viewpage', options: Options(headers: {"Authorization": "Bearer $token", "Content-Type": "application/json",}),
        data: request, queryParameters: {
      "pageSize": pageSize,
      "pageIndex": pageIndex,
      "controller": controller,
    }));
  }

  Future<Object> getFormDynamic({required String token,required String controller}) async {
    return await requestApi(_dio!.post('/api/v1/general-layout/get-form-viewpage', options: Options(headers: {"Authorization": "Bearer $token", "Content-Type": "application/json",}),data: [

    ], queryParameters: {

      "controller": controller,
    }));
  }

  Future<Object> getSearchFormDynamic({required String token,required String controller}) async {
    return await requestApi(_dio!.post('/api/v1/general-layout/get-grid-view-filter', options: Options(headers: {"Authorization": "Bearer $token", "Content-Type": "application/json",}),data: [
    ], queryParameters: {
      "controller": controller,
    }));
  }

  Future<Object> viewDetailFormDynamic({required String token,required String controller, var request}) async {
    return await requestApi(_dio!.post('/api/v1/general-layout/get-form-viewpage', options: Options(headers: {"Authorization": "Bearer $token", "Content-Type": "application/json",}),
        data: request, queryParameters: {
      "controller": controller,
    }));
  }

  Future<Object> actionDynamic({required String token,required String controller, var request, required String action}) async {
    return await requestApi(_dio!.post('/api/v1/general-layout/execute-action-page', options: Options(headers: {"Authorization": "Bearer $token", "Content-Type": "application/json",}),
        data: request, queryParameters: {
      "controller": controller,
      "action": action,
      "controllerType": "Form",
    }));
  }

  Future<Object> proposalAction(String token, String controller, String action, String variable, String value)async{
    return await requestApi(_dio!.post('/api/v1/generalLayout/execute-action-page', options: Options(headers: {"Authorization": "Bearer $token"}), data: {
      "formValues": [
      {
        "variable": variable,
        "type": "Text",
        "value": value,
      }
    ]
    },queryParameters: {
      "controller": controller,
      "action": action,
      "controllerType": "Form",
    }));
  }
  Future<Object> updateInventory(InventoryRequest request,String token,) async {
    return await requestApi(_dio!.post('/api/v1/todos/cap-nhat-kiem-ke', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }
  Future<Object> updateHistoryInventory(HistoryRequest request,String token,) async {
    return await requestApi(_dio!.post('/api/v1/todos/cap-nhat-lich-su-kiem-ke', options: Options(headers: {"Authorization": "Bearer $token"}), data: request.toJson()));
  }
} 