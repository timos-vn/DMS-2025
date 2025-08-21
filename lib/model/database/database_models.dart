import 'package:flutter/material.dart';

class ReportDataModels {
  final String times;
  final double values;

  ReportDataModels(this.times, this.values,);
}

class Task{
  String task;
  String taskValue;
  double percent;

  Task(this.task, this.taskValue,this.percent);
}

class ModalDB{
  String tile;
  String subtitle;

  ModalDB(this.tile, this.subtitle);
}

class DataPieChart {
  final String title;
  final double value;
  final Color color;

  DataPieChart({required this.title, required this.value, required this.color});
}

class ModelNews{
  final String image;
  final String title;
  final String subTitle;
  final String link;

  ModelNews({required this.image, required this.title, required this.subTitle, required this.link});

}