import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import '../../model/database/data_local.dart';
import '../../model/database/database_models.dart';
import '../../model/network/request/report_data_request.dart';
import '../../model/network/response/bar_chart_response.dart';
import '../../model/network/response/data_default_response.dart';
import '../../model/network/response/get_list_slider_image_response.dart';
import '../../model/network/response/home_kpi_response.dart';
import '../../model/network/response/list_status_order_response.dart';
import '../../model/network/response/pie_chart_response.dart';
import '../../model/network/response/table_chart_response.dart';
import '../../model/network/services/network_factory.dart';
import '../../themes/colors.dart';
import '../../utils/const.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  BuildContext context;
  NetWorkFactory? _networkFactory;
  // String? userName;
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;
  List colors = [
    Colors.indigo,
    Colors.lightGreen,
    Colors.purple,
    mainColor,
    Colors.red,
    Colors.blueAccent,
    Colors.blueGrey,
    Colors.teal,
    Colors.green,
    subColor,
  ];

  Random random = Random();
  String? timeId;
  String? reportId;
  String? title;
  String? dataChartType;
  String? chartType;
  String? typeMoney;
  String? legend1;
  String? legend2;

  double tongDT = 0;
  double tongCP = 0;
  double totalProfit = 0;
  double totalMNPieChart = 0;
  double totalPercentPieChart = 0;

  List<ReportCategories> listReportCategories = <ReportCategories>[];
  ReportInfo? reportInfo;
  List<ReportData> listReportData = <ReportData>[];
  List<NumberFormatType> listNumberFormat = <NumberFormatType>[];
  List<PieChartReportResponseData> _listPieChart =
      <PieChartReportResponseData>[];
  List<HeaderData> listHeaderData = <HeaderData>[];

  List<ReportDataModels> valueCl1 = [];
  List<ReportDataModels> valueCl2 = [];
  List<DataPieChart> pieChart = [];
  String userId = '';
  List<Task> pieChart2 = [];

  List<dynamic> responseData = [];
  Map<String, dynamic> dataMap2 = Map();
  List<Map<String, dynamic>> listValuesCells = [];
  String userName = '';

  List<DoanhThuTheoNV> doanhThuTheoNV = [];
  List<DoanhThuTheoSP> doanhThuTheoSP = [];
  List<TopNVMoMoi> topNVMoMoi = [];
  List<KhachHangMoiGanDay> khachHangMoiGanDay = [];
  List<TyTrongDoanhThuTheoCuaHang> tyTrongDoanhThuTheoCuaHang = [];
  List<DoanhThuThuan> doanhThuThuan = [];
  List<LoiNhuanGop> loiNhuanGop = [];
  String storeName = '';
  String storeId = '';
  final box = GetStorage();
  int totalUnreadNotification = 0;

  HomeBloc(this.context) : super(InitialHomeState()) {
    _networkFactory = NetWorkFactory(context);

    on<GetPrefsHomeEvent>(_getPrefs);
    on<GetDataDefault>(_getDataDefault);
    on<ChangeValueTime>(_changeValueTime);
    on<GetReportData>(_getReportData);
    on<SetStateEvent>(_setStateEvent);
    on<GetListSliderImageEvent>(_getListSliderImageEvent);
    on<GetListStatusOrder>(_getListStatusOrder);
    on<GetKPIEvent>(_getKPIEvent);
    on<PickStoreEvent>(_pickStoreEvent);
    on<GetTotalUnreadNotificationEvent>(_getTotalUnreadNotification);
  }

  void _pickStoreEvent(PickStoreEvent event, Emitter<HomeState> emitter) {
    // emitter(HomeLoading());
    storeIndex = event.storeIndex;
    storeName = event.item.storeName.toString();
    storeId = event.item.storeId.toString();
    emitter(PickTransactionSuccess());
  }

  void _getPrefs(GetPrefsHomeEvent event, Emitter<HomeState> emitter) async {
    // emitter(HomeLoading());
    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    userName = box.read(Const.USER_NAME) ?? '';
    userId = box.read(Const.USER_ID) ?? '';
    totalUnreadNotification = box.read(Const.TOTAL_UNREAD_NOTIFICATION) ?? 0;
    emitter(GetPrefsSuccess());
  }

  void _getListStatusOrder(GetListStatusOrder event, Emitter<HomeState> emitter) async {
    // emitter(HomeLoading());
    HomeState state = _handleLoadListStatusOrder(
        await _networkFactory!.getListStatusOrder(_accessToken.toString(), ''));
    emitter(state);
  }

  void _getKPIEvent(GetKPIEvent event, Emitter<HomeState> emitter) async {
    // emitter(HomeLoading());
    HomeState state = _handleKPI(await _networkFactory!
        .getKPIHome(_accessToken.toString(), event.dateType, event.storeId));
    emitter(state);
  }

  void _setStateEvent(SetStateEvent event, Emitter<HomeState> emitter) async {
    emitter(DoNotPermissionViewState());
  }

  void _changeValueTime(ChangeValueTime event, Emitter<HomeState> emitter) {
    // emitter(HomeLoading());
    timeId = event.timeId;
    emitter(ChangeTimeValueSuccess());
  }

  void _getReportData(GetReportData event, Emitter<HomeState> emitter) async {
    // emitter(HomeLoading());
    ReportRequest request = ReportRequest(
      reportId: event.reportId,
      timeId: event.timeId,
    );
    HomeState state =
        _handleGetData(await _networkFactory!.getData(request, _accessToken!));
    emitter(state);
  }

  void _getListSliderImageEvent(
      GetListSliderImageEvent event, Emitter<HomeState> emitter) async {
    // emitter(HomeLoading());
    HomeState state = _handleGetListSliderImage(
        await _networkFactory!.getListSliderImage(_accessToken.toString()));
    emitter(state);
  }

  void _getDataDefault(GetDataDefault event, Emitter<HomeState> emitter) async {
    // emitter(HomeLoading());
    HomeState state = _handleGetDefaultData(
        await _networkFactory!.getDefaultData(_accessToken!));
    emitter(state);
  }

  HomeState _handleGetData(Object data) {
    if (data is String) return HomeFailure('Úi, ${data.toString()}');
    try {
      dataChartType = null;
      title = null;
      chartType = null;
      DataDefaultResponse dataDefaultResponse =
          DataDefaultResponse.fromJson(data as Map<String, dynamic>);
      reportInfo = dataDefaultResponse.reportInfo!;

      timeId = reportInfo?.timeId;
      reportId = reportInfo?.reportId;
      title = reportInfo?.title;
      dataChartType = reportInfo?.dataType;
      chartType = reportInfo?.chartType;
      typeMoney = reportInfo?.subtitle;

      if (dataChartType == Const.CHART) {
        if (chartType?.trim() == Const.BAR_CHART) {
          legend1 = reportInfo?.legend1;
          legend2 = reportInfo?.legend2;
          tongCP = 0;
          tongDT = 0;
          valueCl1.clear();
          valueCl2.clear();
          BarChartDataResponse barChartDataResponse =
              BarChartDataResponse.fromJson(data);
          List<BarChartReportData>? _listBarChartReportData =
              barChartDataResponse.data;
          _listBarChartReportData?.forEach((element) {
            tongDT = (tongDT + element.value1!);
            tongCP = (tongCP + element.value2!);
            valueCl1.add(ReportDataModels(
                element.colName.toString(), element.value1!)); //'6', 4000000
            valueCl2.add(
                ReportDataModels(element.colName.toString(), element.value2!));
          });
          totalProfit = tongDT - tongCP;
        } else if (chartType == Const.PIE_CHART) {
          totalMNPieChart = 0;
          totalPercentPieChart = 0;
          print('This is Pie chart');
          pieChart.clear();
          PieChartDataResponse pieChartDataResponse =
              PieChartDataResponse.fromJson(data);
          _listPieChart = pieChartDataResponse.data!;
          for (var element in _listPieChart) {
            totalMNPieChart = (totalMNPieChart + element.value!);
          }
          totalProfit = totalMNPieChart;
          for (int index = 0; index <= (_listPieChart.length - 1); index++) {
            Color _colors = colors[Random().nextInt(1)];
            if (typeMoney?.trim() == '%') {
              double percent = (_listPieChart[index].value! / totalMNPieChart);
              if (index == _listPieChart.length - 1) {
                pieChart.add(DataPieChart(
                    title: _listPieChart[index].colName.toString(),
                    value: ((1 - totalPercentPieChart) * 100),
                    color:
                        _listPieChart.length <= 10 ? colors[index] : _colors));
              } else {
                if (percent.toString().length >= 4) {
                  double newValues =
                      double.parse(percent.toString().substring(0, 4));
                  totalPercentPieChart += newValues;
                  double x = (newValues * 100);
                  if (x.toString().length >= 4) {
                    x = double.parse((x.toString().substring(0, 4)));
                  }
                  pieChart.add(DataPieChart(
                      title: _listPieChart[index].colName.toString(),
                      value: (x),
                      color: _listPieChart.length <= 10
                          ? colors[index]
                          : _colors));
                } else {
                  print('xxx1:$percent');
                  pieChart.add(DataPieChart(
                      title: _listPieChart[index].colName.toString(),
                      value: (percent * 100),
                      color: _listPieChart.length <= 10
                          ? colors[index]
                          : _colors));
                  totalPercentPieChart += (percent);
                }
              }
            } else {
              pieChart.add(DataPieChart(
                  title: _listPieChart[index].colName.toString(),
                  value: _listPieChart[index].value!,
                  color: _listPieChart.length <= 10 ? colors[index] : _colors));
            }
          }
        } else if (chartType == Const.LINE_CHART) {}
      } else if (dataChartType == Const.TABLE) {
        TableChartResponse response = TableChartResponse.fromJson(data);
        listHeaderData = response.headerDesc!;
        Map<String, dynamic> jsonMap = Map<String, dynamic>.from(data);
        responseData = jsonMap["reportData"];
        getDataPageList();
        return GetDefaultDataSuccess();
      }
      return GetDataSuccess();
    } catch (e) {
      return HomeFailure('Úi, ${e.toString()}');
    }
  }

  HomeState _handleGetListSliderImage(Object data) {
    if (data is String) return HomeFailure('Úi, ${data.toString()}');
    try {
      GetListSliderImageResponse dataResponse =
          GetListSliderImageResponse.fromJson(data as Map<String, dynamic>);
      DataLocal.listSliderImageActive =
          dataResponse.listSliderImageActive ?? [];
      DataLocal.listSliderImageDisable =
          dataResponse.listSliderImageDisable ?? [];
      return GetListSliderImageSuccess();
    } catch (e) {
      return HomeFailure('Úi, ${data.toString()}');
    }
  }

  HomeState _handleGetDefaultData(Object data) {
    if (data is String) return HomeFailure('Úi, ${data.toString()}');
    try {
      DataDefaultResponse dataDefaultResponse =
          DataDefaultResponse.fromJson(data as Map<String, dynamic>);
      Const.stockList = dataDefaultResponse.stockList ?? [];
      Const.currencyList = dataDefaultResponse.currencyList ?? [];
      if (Const.currencyList.isNotEmpty) {
        for (var element in Const.currencyList) {
          if (element.currencyCode.toString().contains('VND')) {
            Const.currencyCode = element.currencyCode.toString();
          }
        }
      }
      if (Const.reportHome == true) {
        listNumberFormat = dataDefaultResponse.numberFormat!;
        listReportCategories = dataDefaultResponse.reportCategories!;
        reportInfo = dataDefaultResponse.reportInfo!;

        for (var element in listNumberFormat) {
          if (element.name == 'quantity') {
            Const.quantityFormat = element.value!;
          } else if (element.name == 'quantity_nt') {
            Const.quantityNtFormat = element.value!;
          } else if (element.name == 'amount') {
            Const.amountFormat = element.value!;
          } else if (element.name == 'amount_nt') {
            Const.amountNtFormat = element.value!;
          } else if (element.name == 'rate') {
            Const.rateFormat = element.value!;
          }
        }

        timeId = reportInfo?.timeId;
        reportId = reportInfo?.reportId;
        title = reportInfo?.title;
        dataChartType = reportInfo?.dataType;
        chartType = reportInfo?.chartType;
        typeMoney = reportInfo?.subtitle;
        legend1 = reportInfo?.legend1;
        legend2 = reportInfo?.legend2;

        // _prefs.setStringList(Const.LIST_TIME_NAME, _listFilterTimeName);
        // _prefs.setStringList(Const.LIST_TIME_ID, _listFilterTimeId);

        // print(_prefs.getStringList(Const.LIST_TIME_NAME).length);
        // if(dataChartType == Const.CHART){
        //   if(chartType == Const.BAR_CHART){
        //
        //     BarChartDataResponse barChartDataResponse = BarChartDataResponse.fromJson(data);
        //     List<BarChartReportData>? _listBarChartReportData = barChartDataResponse.data;
        //     _listBarChartReportData?.forEach((element) {
        //       tongDT = (tongDT + element.value1!);
        //       tongCP = (tongCP + element.value2!);
        //       valueCl1.add( ReportDataModels(element.colName.toString(), element.value1!));//'6', 4000000
        //       valueCl2.add( ReportDataModels(element.colName.toString(), element.value2!));
        //     });
        //     totalProfit = tongDT - tongCP;
        //   }
        //   else if(chartType == Const.PIE_CHART){
        //     totalMNPieChart=0;
        //     totalPercentPieChart =0;
        //
        //     pieChart.clear();
        //     PieChartDataResponse pieChartDataResponse = PieChartDataResponse.fromJson(data);
        //     _listPieChart = pieChartDataResponse.data!;
        //     _listPieChart.forEach((element) {
        //       totalMNPieChart = (totalMNPieChart + element.value!);
        //     });
        //     totalProfit = totalMNPieChart;
        //     for(int index = 0;index <= (_listPieChart.length - 1);index++){
        //       Color _colors = colors[Random().nextInt(1)];
        //       if(typeMoney?.trim() == '%'){
        //         double percent = (_listPieChart[index].value!/totalMNPieChart);
        //         if(index == _listPieChart.length-1){
        //           pieChart.add(DataPieChart(
        //               title: _listPieChart[index].colName.toString(),
        //               value: ((1 - totalPercentPieChart )*100),
        //               color: _listPieChart.length <= 10 ? colors[index] : _colors
        //           ));
        //         }
        //         else{
        //           if(percent.toString().length >=4){
        //             double newValues = double.parse(percent.toString().substring(0,4));
        //             totalPercentPieChart += newValues;
        //             double x = (newValues*100);
        //             if(x.toString().length >=4)
        //             {
        //               x = double.parse((x.toString().substring(0,4)));
        //             }
        //             print('xxx:$x');
        //             pieChart.add(DataPieChart(
        //                 title:_listPieChart[index].colName.toString(),
        //                 value:(x),
        //                 color: _listPieChart.length <= 10 ? colors[index] : _colors
        //             ));
        //           }
        //           else{
        //             print('xxx1:$percent');
        //             pieChart.add(DataPieChart(
        //                 title:_listPieChart[index].colName.toString(),
        //                 value:(percent*100),
        //                 color: _listPieChart.length <= 10 ? colors[index] : _colors
        //             ));
        //             totalPercentPieChart += (percent);
        //           }
        //         }
        //       }
        //       else{
        //         pieChart.add( DataPieChart(
        //             title: _listPieChart[index].colName.toString(),
        //             value:_listPieChart[index].value!,
        //             color: _listPieChart.length <= 10 ? colors[index] : _colors));
        //       }
        //     }
        //   }
        //   else if(chartType == Const.LINE_CHART){
        //
        //   }
        // }
        // else if(dataChartType == Const.TABLE){
        //
        //   TableChartResponse response = TableChartResponse.fromJson(data);
        //   listHeaderData = response.headerDesc!;
        //   Map<String, dynamic> jsonMap =  Map<String, dynamic>.from(data);
        //   responseData = jsonMap["reportData"];
        //   getDataPageList();
        //   return GetDefaultDataSuccess();
        // }
        return GetDefaultDataSuccess();
      } else {
        return DoNotPermissionViewState();
      }
    } catch (e) {
      return HomeFailure('Úi, ${data.toString()}');
    }
  }

  Future<void> getDataPageList() async {
    int round = 0;
    for (var contentRow in responseData) {
      Map<String, dynamic> dataMap = Map();
      round++;
      for (var header in listHeaderData) {
        for (final name in contentRow.keys) {
          if (header.field.toString() == name) {
            var value;
            if (header.type == 2) {
              final formatter = NumberFormat(
                  header.format ?? '#,##0'); //### ##0,00 - ###,##0,00
              value = formatter.format(contentRow[name]);
            } else if (header.type == 3) {
              DateTime x = DateTime.parse(contentRow[name].toString());
              value = DateFormat("dd/MM/yyyy").format(x);
            } else {
              value = contentRow[name];
            }
            dataMap.putIfAbsent(name, () => value);
            if (round == 1) {
              dataMap2.putIfAbsent(name, () => value);
            }
          }
        }
      }
      listValuesCells.add(dataMap);
    }
  }

  HomeState _handleLoadListStatusOrder(Object data) {
    if (data is String) return HomeFailure('Úi, ${data.toString()}');
    try {
      ListStatusOrderResponse response =
          ListStatusOrderResponse.fromJson(data as Map<String, dynamic>);
      DataLocal.listStatusToOrder.clear();
      DataLocal.listStatusToOrderCustom.clear();
      DataLocal.listStatusToOrder = response.data ?? [];
      if (DataLocal.listStatusToOrder.isNotEmpty) {
        for (var element in DataLocal.listStatusToOrder) {
          if (element.status.toString().contains("0") ||
              element.status.toString().contains("1") ||
              element.status.toString().contains("2")) {
            DataLocal.listStatusToOrderCustom.add(element);
          }
        }
      }
      return GetListStatusOrderSuccess();
    } catch (e) {
      return HomeFailure('Úi, ${e.toString()}');
    }
  }

  DoanhThuThuan doanhThuThuanItem = DoanhThuThuan();
  LoiNhuanGop loiNhuanGopItem = LoiNhuanGop();
  double tongTyTrong = 0;
  int storeIndex = 0;
  List<PieChartSectionData> tyTrongDoanhThuTheoCuaHangChart = [];
  HomeState _handleKPI(Object data) {
    if (data is String) return HomeFailure('Úi, ${data.toString()}');
    try {
      tongTyTrong = 0;
      doanhThuTheoNV = [];
      doanhThuTheoSP = [];
      topNVMoMoi = [];
      khachHangMoiGanDay = [];
      tyTrongDoanhThuTheoCuaHang = [];
      doanhThuThuan = [];
      loiNhuanGop = [];
      GetKPIHome response = GetKPIHome.fromJson(data as Map<String, dynamic>);
      doanhThuTheoNV = response.doanhThuTheoNV ?? [];
      doanhThuTheoSP = response.doanhThuTheoSP ?? [];
      topNVMoMoi = response.topNVMoMoi ?? [];
      khachHangMoiGanDay = response.khachHangMoiGanDay ?? [];
      tyTrongDoanhThuTheoCuaHang = response.tyTrongDoanhThuTheoCuaHang ?? [];
      doanhThuThuan = response.doanhThuThuan ?? [];
      loiNhuanGop = response.loiNhuanGop ?? [];
      if (doanhThuThuan.isNotEmpty) {
        for (var element in doanhThuThuan) {
          if (element.type.toString().trim().toUpperCase().contains('NOW')) {
            doanhThuThuanItem = element;
            break;
          }
        }
      }
      if (loiNhuanGop.isNotEmpty) {
        for (var element in loiNhuanGop) {
          if (element.type.toString().trim().toUpperCase().contains('NOW')) {
            loiNhuanGopItem = element;
            break;
          }
        }
      }
      if (tyTrongDoanhThuTheoCuaHang.isNotEmpty) {
        for (var element in tyTrongDoanhThuTheoCuaHang) {
          tongTyTrong = tongTyTrong + element.value;
          element.color = Color.fromRGBO(random.nextInt(255),
              random.nextInt(255), random.nextInt(255), 100);
        }
      }
      return GetKPISuccess();
    } catch (e) {
      print(e.toString());
      return HomeFailure('Úi, ${e.toString()}');
    }
  }

  void _getTotalUnreadNotification(
      GetTotalUnreadNotificationEvent event, Emitter<HomeState> emitter) async {
    emitter(HomeLoading());
    try {
      Object data = await _networkFactory!.getTotalUnreadNotification(
        _accessToken!,
      );

      if (data is Map<String, dynamic>) {
        if (data['recordUnRead'] != null && data['recordUnRead'] is int) {
          int recordUnRead = data['recordUnRead'];
          totalUnreadNotification = recordUnRead;
          box.write(Const.TOTAL_UNREAD_NOTIFICATION, recordUnRead);
          emitter(GetDataSuccess());
        } else {
          emitter(HomeFailure(''));
        }
      }
    } catch (e) {
      emitter(HomeFailure('Úi: ${e.toString()}'));
    }
  }
}
