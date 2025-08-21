import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ColorForAlphaB extends Equatable {
  final String keyText;
  final Color color;

  ColorForAlphaB(
      this.keyText,
      this.color
      );

  ColorForAlphaB.fromDb(Map<String, dynamic> map)
      :
        keyText = map['keyText'],
        color = map['color'];

  Map<String, dynamic> toMapForDb() {
    var map = Map<String, dynamic>();
    map['keyText'] = keyText;
    map['color'] = color;
    return map;
  }

  @override
  List<Object> get props => [
    keyText,
    color,
  ];
}
