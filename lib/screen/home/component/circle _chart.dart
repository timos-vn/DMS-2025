import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../model/network/response/home_kpi_response.dart';
import '../../../utils/utils.dart';
import 'app_color.dart';
import 'indicator.dart';




class PieChartTyTrongDoanhThu extends StatefulWidget {
  final List<TyTrongDoanhThuTheoCuaHang> tyTrongDoanhThuTheoCuaHang;
  const PieChartTyTrongDoanhThu({Key? key, required this.tyTrongDoanhThuTheoCuaHang}) : super(key: key);

  @override
  State<PieChartTyTrongDoanhThu> createState() => _PieChartTyTrongDoanhThuState();
}

class _PieChartTyTrongDoanhThuState extends State<PieChartTyTrongDoanhThu> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[

          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: showingSections(widget.tyTrongDoanhThuTheoCuaHang),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(List<TyTrongDoanhThuTheoCuaHang> tyTrongDoanhThuTheoCuaHang) {
    return
      List.generate(tyTrongDoanhThuTheoCuaHang.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      return PieChartSectionData(
        color: tyTrongDoanhThuTheoCuaHang[i].color,
        // value: Utils.formatMoneyStringToDouble(tyTrongDoanhThuTheoCuaHang[i].value),
        title: '${tyTrongDoanhThuTheoCuaHang[i].ratio}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.mainTextColor1,
          shadows: shadows,
        ),
      );
      // switch (i) {
      //   case 0:
      //     return PieChartSectionData(
      //       color: AppColors.contentColorBlue,
      //       value: 40,
      //       title: '40%',
      //       radius: radius,
      //       titleStyle: TextStyle(
      //         fontSize: fontSize,
      //         fontWeight: FontWeight.bold,
      //         color: AppColors.mainTextColor1,
      //         shadows: shadows,
      //       ),
      //     );
      //   case 1:
      //     return PieChartSectionData(
      //       color: tyTrongDoanhThuTheoCuaHang[i].color,
      //       // value: Utils.formatMoneyStringToDouble(tyTrongDoanhThuTheoCuaHang[i].value),
      //       title: '${tyTrongDoanhThuTheoCuaHang[i].ratio}%',
      //       radius: radius,
      //       titleStyle: TextStyle(
      //         fontSize: fontSize,
      //         fontWeight: FontWeight.bold,
      //         color: AppColors.mainTextColor1,
      //         shadows: shadows,
      //       ),
      //     );
      //   case 2:
      //     return PieChartSectionData(
      //       color: AppColors.contentColorPurple,
      //       value: 15,
      //       title: '15%',
      //       radius: radius,
      //       titleStyle: TextStyle(
      //         fontSize: fontSize,
      //         fontWeight: FontWeight.bold,
      //         color: AppColors.mainTextColor1,
      //         shadows: shadows,
      //       ),
      //     );
      //   case 3:
      //     return PieChartSectionData(
      //       color: AppColors.contentColorGreen,
      //       value: 15,
      //       title: '15%',
      //       radius: radius,
      //       titleStyle: TextStyle(
      //         fontSize: fontSize,
      //         fontWeight: FontWeight.bold,
      //         color: AppColors.mainTextColor1,
      //         shadows: shadows,
      //       ),
      //     );
      //   default:
      //     throw Error();
      // }
    });
  }
}