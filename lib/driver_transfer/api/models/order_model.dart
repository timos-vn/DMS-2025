// To parse this JSON data, do
//
//     final orderModel = orderModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';

OrderModel orderModelFromJson(String str) => OrderModel.fromJson(json.decode(str));

String orderModelToJson(OrderModel data) => json.encode(data.toJson());

class OrderModel {
  String? id;
  String? namePoint;
  DateTime? toTime;
  String? city;
  String? district;
  String? subDistrict;
  String? detailAddress;
  int? poinNumber;
  int? employeeId;
  String? status;
  DateTime? timeFinished;
  String? customerName;
  String? customerPhone;
  dynamic ctNumber;
  dynamic ctDate;
  int? totalQuantity;
  int? totalMoney;
  String? strDistance;
  String? strDuration;
  String? strAddress;
  double? lng;
  double? lat;
  List<PointLatLng>? overviewPolyline;
  bool? isTarget;
  Distance? distance;
  Distance? duration;

  OrderModel({
    this.id,
    this.namePoint,
    this.toTime,
    this.city,
    this.district,
    this.subDistrict,
    this.detailAddress,
    this.poinNumber,
    this.employeeId,
    this.status,
    this.timeFinished,
    this.customerName,
    this.customerPhone,
    this.ctNumber,
    this.ctDate,
    this.totalQuantity,
    this.totalMoney,
    this.strDistance,
    this.strDuration,
    this.strAddress,
    this.lng,
    this.lat,
    this.overviewPolyline,
    this.isTarget,
    this.distance,
    this.duration,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json["id"],
        namePoint: json["namePoint"],
        toTime: json["to_time"] == null ? null : DateTime.parse(json["to_time"]),
        city: json["city"],
        district: json["district"],
        subDistrict: json["sub_district"],
        detailAddress: json["detailAddress"],
        poinNumber: json["poinNumber"],
        employeeId: json["employee_id"],
        status: json["status"],
        timeFinished: json["timeFinished"] == null ? null : DateTime.parse(json["timeFinished"]),
        customerName: json["customerName"],
        customerPhone: json["customerPhone"],
        ctNumber: json["so_ct"],
        ctDate: json["ngay_ct"],
        totalQuantity: json["totalQuantity"],
        totalMoney: json["totalMoney"],
        strDistance: json["str_distance"],
        strDuration: json["str_duration"],
        strAddress: json["strAddress"],
        isTarget: json["is_target"],
        lng: json["lng"]?.toDouble(),
        lat: json["lat"]?.toDouble(),
        overviewPolyline: json["overview_polyline"] == null
            ? null
            : PolylinePoints().decodePolyline(json["overview_polyline"]),
        distance: json["distance"] == null ? null : Distance.fromJson(json["distance"]),
        duration: json["duration"] == null ? null : Distance.fromJson(json["duration"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "is_target": isTarget,
        "namePoint": namePoint,
        "to_time": toTime?.toIso8601String(),
        "city": city,
        "district": district,
        "sub_district": subDistrict,
        "detailAddress": detailAddress,
        "poinNumber": poinNumber,
        "employee_id": employeeId,
        "status": status,
        "timeFinished": timeFinished?.toIso8601String(),
        "customerName": customerName,
        "customerPhone": customerPhone,
        "so_ct": ctNumber,
        "ngay_ct": ctDate,
        "totalQuantity": totalQuantity,
        "totalMoney": totalMoney,
        "str_distance": strDistance,
        "str_duration": strDuration,
        "strAddress": strAddress,
        "lng": lng,
        "lat": lat,
        "overview_polyline": overviewPolyline,
        "distance": distance?.toJson(),
        "duration": duration?.toJson(),
      };
}

class Distance {
  String? text;
  double? value;

  Distance({
    this.text,
    this.value,
  });

  factory Distance.fromJson(Map<String, dynamic> json) => Distance(
        text: json["text"],
        value: json["value"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "text": text,
        "value": value,
      };
}
