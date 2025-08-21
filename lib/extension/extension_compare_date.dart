import 'package:flutter/material.dart';

extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay add({int hour = 0, int minute = 0}) {
    return replacing(hour: this.hour + hour, minute: this.minute + minute);
  }
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month
        && day == other.day;
  }

  bool isBeforeMont(DateTime other){
    // print('${month.toString() + " - "  + day.toString()}');
    // print('${other.month.toString() + " - "  + other.day.toString()}');
    if(year == other.year){
      if(month == other.month){
        if(day > other.day){
          return true;
        }
        else{
          return false;
        }
      }else if(month > other.month) {
        return true;
      }else{
        return false;
      }
    }else{
      return false;
    }
    // return year == other.year && month >= other.month
    //     && day > other.day;
  }

  bool isBeforeDay(DateTime other){
    // print('${month.toString() + " - "  + day.toString()}');
    // print('${other.month.toString() + " - "  + other.day.toString()}');
    if(day == other.day){
      return true;
    }else{
      return false;
    }
    // return year == other.year && month >= other.month
    //     && day > other.day;
  }
}