// import 'package:flutter/material.dart';
// // import "package:charts_flutter/flutter.dart" as charts;
// import 'package:google_fonts/google_fonts.dart';
// import 'package:dms/model/models/expense.dart';
//
// class ExpenseChart extends StatefulWidget {
//   final List<charts.Series<dynamic, String>> seriesList;
//   final bool animate;
//   const ExpenseChart({Key? key, required this.seriesList, required this.animate})
//       : super(key: key);
//
//   @override
//   State<ExpenseChart> createState() => _ExpenseChartState();
// }
//
// class _ExpenseChartState extends State<ExpenseChart> {
//   @override
//   Widget build(BuildContext context) {
//     return charts.PieChart<String>(
//       widget.seriesList,
//       animate: widget.animate,
//       animationDuration: Duration(seconds: 1),
//       defaultRenderer: charts.ArcRendererConfig(
//           arcWidth: 60,
//           strokeWidthPx: 6,
//           arcRendererDecorators: [
//             charts.ArcLabelDecorator(
//                 labelPadding: 0,
//                 showLeaderLines: true,
//                 outsideLabelStyleSpec: charts.TextStyleSpec(
//                     fontSize: 12,
//                     fontFamily: GoogleFonts.montserrat().toString(),
//                     color: charts.MaterialPalette.black))
//           ]
//       ),
//       behaviors: [
//         new charts.InitialSelection(selectedDataConfig: [
//           new charts.SeriesDatumConfig<String>('Purchases', 'Eating Out'),
//         ]),
//         new charts.DomainHighlighter(),
//         charts.DatumLegend(
//           position: charts.BehaviorPosition.end,
//           outsideJustification: charts.OutsideJustification.end,
//           horizontalFirst: false,
//           desiredMaxColumns: 1,
//           cellPadding: const EdgeInsets.only(
//             right: 4,
//             bottom: 4,
//           ),
//           entryTextStyle: charts.TextStyleSpec(
//               fontSize: 12, color: charts.MaterialPalette.black),
//         ),
//       ],
//     );
//   }
// }