import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';




class ChartBarSells extends StatefulWidget {

  const ChartBarSells({Key? key}) : super(key: key);

  @override
  _ChartBarSellsState createState() => _ChartBarSellsState();
}

class _ChartBarSellsState extends State<ChartBarSells> {
  late List<_ChartData> data;
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    data = [
      _ChartData('Sun', 2),
      _ChartData('Mon', 2),
      _ChartData('Tue', 4),
      _ChartData('Wed', 3),
      _ChartData('Thu', 8),
      _ChartData('Fri', 5),
      _ChartData('Sta', 5),
    ];
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
        primaryXAxis: const CategoryAxis(borderWidth: 0,axisLine: AxisLine(color: Colors.transparent, width: 0),
          majorGridLines: MajorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
          // majorTickLines: MinorTickLines(width: 0),
          // minorTicksPerInterval:2,labelPlacement: LabelPlacement.betweenTicks
        ),
        primaryYAxis: const NumericAxis(borderWidth: 0,minimum: 0,
            isVisible: false,
            majorGridLines: MajorGridLines(width: 0)
        ),
        tooltipBehavior: _tooltip,
        // plotAreaBackgroundColor: Colors.transparent,
        borderColor: Colors.transparent,
        borderWidth: 0,
        plotAreaBorderWidth: 0,
        series: <CartesianSeries<_ChartData, String>>[
          ColumnSeries<_ChartData, String>(
            dataSource: data,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            name: 'Gold',
            animationDuration: 4500,
            animationDelay: 2000,
            color: const Color.fromRGBO(236, 0, 225, 1.0),
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            // Width of the columns
            width: 0.38,
            // Spacing between the columns
            spacing: 0.2,
          )
        ]);
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
