import 'dart:convert';

import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final String id;
  final String name;
  final String values;

  const AppSettings(
      this.id,
      this.name,
      this.values
      );

  AppSettings.fromDb(Map<String, dynamic> map)
      :
        id = map['id'],
        name = map['name'],
        values = map['value'];

  Map<String, dynamic> toMapForDb() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['value'] = values;
    return map;
  }

  @override
  List<Object> get props => [
    id,
    name,
    values,
  ];
}
