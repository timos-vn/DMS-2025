// To parse this JSON data, do
//
//     final employeeModel = employeeModelFromJson(jsonString);

import 'dart:convert';

EmployeeModel employeeModelFromJson(String str) => EmployeeModel.fromJson(json.decode(str));

String employeeModelToJson(EmployeeModel data) => json.encode(data.toJson());

class EmployeeModel {
  int? id;
  String? employeeId;
  double? lng;
  double? lat;
  DateTime? timeUpdated;
  String? firstName;
  String? lastName;

  EmployeeModel({
    this.id,
    this.employeeId,
    this.lng,
    this.lat,
    this.timeUpdated,
    this.firstName,
    this.lastName,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
        id: json["id"],
        employeeId: json["employee_id"],
        lng: json["lng"]?.toDouble(),
        lat: json["lat"]?.toDouble(),
        timeUpdated: json["time_updated"] == null ? null : DateTime.parse(json["time_updated"]),
        firstName: json["first_name"],
        lastName: json["last_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "employee_id": employeeId,
        "lng": lng,
        "lat": lat,
        "time_updated": timeUpdated?.toIso8601String(),
        "first_name": firstName,
        "last_name": lastName,
      };

  @override
  String toString() {
    return "($id,$employeeId,$lat,$lng)";
  }
}
