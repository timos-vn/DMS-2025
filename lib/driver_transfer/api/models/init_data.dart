// To parse this JSON data, do
//
//     final initData = initDataFromJson(jsonString);

import 'dart:convert';

InitData initDataFromJson(String str) => InitData.fromJson(json.decode(str));

String initDataToJson(InitData data) => json.encode(data.toJson());

class InitData {
  bool isStart = false;
  bool? isEnd;
  int? isTimeCallApi;
  Target? target;

  InitData({
    this.isStart = false,
    this.isEnd,
    this.isTimeCallApi,
    this.target,
  });

  factory InitData.fromJson(Map<String, dynamic> json) => InitData(
    isStart: json["is_start"],
    isEnd: json["is_end"],
    isTimeCallApi: json["is_time_call_api"],
    target: json["target"] == null ? null : Target.fromJson(json["target"]),
    // target: json["target"] == null
    //     ? null
    //     : (json["target"]),
  );

  Map<String, dynamic> toJson() => {
    "is_start": isStart,
    "is_end": isEnd,
    "is_time_call_api": isTimeCallApi,
    // "target": target?.toJson(),
    "target": target,
  };
}

class Target {
  dynamic id;
  dynamic employeeId;
  double? lng;
  double? lat;
  String? orderId;
  DateTime? timeUpdated;

  Target({
    this.id,
    this.employeeId,
    this.lng,
    this.lat,
    this.orderId,
    this.timeUpdated,
  });

  factory Target.fromJson(Map<String, dynamic> json) => Target(
    id: json["id"],
    employeeId: json["employee_id"],
    lng: json["lng"]?.toDouble(),
    lat: json["lat"]?.toDouble(),
    orderId: json["order_id"],
    timeUpdated: json["time_updated"] == null ? null : DateTime.parse(json["time_updated"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "employee_id": employeeId,
    "lng": lng,
    "lat": lat,
    "order_id": orderId,
    "time_updated": timeUpdated?.toIso8601String(),
  };
}



// class Target {
//   String? id;
//   String? employeeId;
//   String? lng;
//   String? lat;
//
//   Target({this.id, this.employeeId, this.lng, this.lat});
//
//   Target.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     employeeId = json['employee_id'];
//     lng = json['lng'];
//     lat = json['lat'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['employee_id'] = this.employeeId;
//     data['lng'] = this.lng;
//     data['lat'] = this.lat;
//     return data;
//   }
// }

