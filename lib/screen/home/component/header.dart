import 'package:flutter/material.dart';
import 'package:dms/model/database/database_models.dart' as models;
// import 'package:charts_flutter/flutter.dart' as charts;


import '../../../model/models/expense.dart';
import 'expense_chart.dart';

class Header extends StatefulWidget {
  const Header({Key? key,
    // required this.series ,
    this.addTransaction}) : super(key: key);

  // final List<charts.Series<Expense, String>> series;
  final Function? addTransaction;



  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 8,right: 8,bottom: 2),
      // height: 200,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(right: 30),
        // child: ExpenseChart(
        //   seriesList: widget.series,
        //   animate: true,
        // ),
      ),
    );
  }
}