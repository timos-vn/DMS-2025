// To parse this JSON data, do
//
//     final orderDetailModel = orderDetailModelFromJson(jsonString);

import 'dart:convert';
import 'dart:io';

OrderDetailModel orderDetailModelFromJson(String str) => OrderDetailModel.fromJson(json.decode(str));

String orderDetailModelToJson(OrderDetailModel data) => json.encode(data.toJson());

class OrderDetailModel {
  String? id;
  String? namePoint;
  DateTime? toTime;
  String? city;
  String? district;
  String? subDistrict;
  String? detailAddress;
  String? strAddress;
  int? poinNumber;
  String? employeeId;
  String? status;
  String? customerName;
  String? customerPhone;
  List<Detail>? details;
  dynamic totalQuantity;
  dynamic totalMoney;
  DateTime? timeFinished;
  List<File>? listFile;
  int? typePayment;
  int? xacNhanYN;
  int? statusTicket;
  String? desc;
  String? lat;
  String? long;
  String? address;

  OrderDetailModel({
    this.typePayment,
    this.statusTicket,
    this.desc,
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
    this.customerName,
    this.customerPhone,
    this.details,
    this.totalQuantity,
    this.totalMoney,
    this.timeFinished,
    this.strAddress,
    this.listFile,
    this.lat,
    this.long,
    this.address,this.xacNhanYN
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) => OrderDetailModel(
    id: json["id"],
    namePoint: json["name_point"],
    toTime: json["toTime"] == null ? null : DateTime.parse(json["toTime"]),
    city: json["city"],
    district: json["district"],
    subDistrict: json["sub_district"],
    detailAddress: json["detailAddress"],
    poinNumber: json["poinNumber"],
    employeeId: json["employeeId"],
    status: json["status"],
    customerName: json["customerName"],
    customerPhone: json["customerPhone"],
    details: json["details"] == null ? [] : List<Detail>.from(json["details"]!.map((x) => Detail.fromJson(x))),
    totalQuantity: json["totalQuantity"],
    totalMoney: json["totalMoney"],
    timeFinished: json["timeFinished"] == null ? null : DateTime.parse(json["timeFinished"]),
    strAddress: json["strAddress"],
    xacNhanYN: json["xacNhanYN"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name_point": namePoint,
    "toTime": toTime?.toIso8601String(),
    "city": city,
    "district": district,
    "sub_district": subDistrict,
    "detailAddress": detailAddress,
    "poinNumber": poinNumber,
    "employeeId": employeeId,
    "status": status,
    "customerName": customerName,
    "customerPhone": customerPhone,
    "details": details == null ? [] : List<dynamic>.from(details!.map((x) => x.toJson())),
    "totalQuantity": totalQuantity,
    "totalMoney": totalMoney,
    "timeFinished": timeFinished?.toIso8601String(),
    "strAddress": strAddress,
    "xacNhanYN": xacNhanYN,
  };
}

class ObjDateFunc {
  String? startDate;
  String? endDate;

  ObjDateFunc({
    this.startDate,
    this.endDate,});
}

class Detail {
  String? id;
  String? productName;
  dynamic productImage;
  String? unit;
  String? sttRec0;
  dynamic quantity;
  dynamic deliveryQuantity;
  dynamic deliveredQuantity;
  dynamic actualQuantity;
  dynamic total;
  dynamic orderId;

  Detail({
    this.id,
    this.productName,
    this.productImage,
    this.unit,
    this.sttRec0,
    this.quantity,
    this.deliveryQuantity,
    this.deliveredQuantity,
    this.actualQuantity,
    this.total,
    this.orderId,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    id: json["id"],
    productName: json["productName"],
    productImage: json["asproductImage"],
    unit: json["unit"],
    sttRec0: json["stt_rec0"],
    quantity: json["quantity"],
    deliveryQuantity: json["deliveryQuantity"],
    deliveredQuantity: json["deliveredQuantity"],
    actualQuantity: json["actualQuantity"],
    total: json["total"],
    orderId: json["orderId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "productName": productName,
    "asproductImage": productImage,
    "unit": unit,
    "stt_rec0": sttRec0,
    "quantity": quantity,
    "deliveryQuantity": deliveryQuantity,
    "deliveredQuantity": deliveredQuantity,
    "actualQuantity": actualQuantity,
    "total": total,
    "orderId": orderId,
  };
}
