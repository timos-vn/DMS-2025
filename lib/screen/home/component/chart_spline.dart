import 'package:dms/model/models/chart_spline_data.dart';
import 'package:dms/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartSpline extends StatelessWidget {
  const ChartSpline({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      plotAreaBackgroundColor: Colors.transparent,
      borderColor: Colors.transparent,
      borderWidth: 0,
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(isVisible: false),
      primaryYAxis: NumericAxis(isVisible: false),
      series:
      <CartesianSeries<ChartSplineData,String>>[
        SplineSeries(
          color: secondaryColor,
            dataSource: chartData,
            xValueMapper: (ChartSplineData data,_) => data.month,
            yValueMapper: (ChartSplineData data,_) => data.amount,
        ),
        SplineAreaSeries(
            dataSource: chartData,
            xValueMapper: (ChartSplineData data,_) => data.month,
            yValueMapper: (ChartSplineData data,_) => data.amount,
            gradient: LinearGradient(
              colors: [
                secondaryColor.withAlpha(150),
                secondaryColor.withAlpha(23)
              ],
              begin: Alignment.topCenter,end: Alignment.bottomCenter
            )
        )
      ],
    );
  }

  static final List<ChartSplineData> chartData = <ChartSplineData>[
    ChartSplineData('Mo', 2),
    ChartSplineData('Tu', 4),
    ChartSplineData('Wo', 3),
    ChartSplineData('Th', 8),
    ChartSplineData('Fr', 5),
  ];
}
