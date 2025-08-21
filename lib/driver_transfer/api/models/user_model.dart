// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  DataUser? dataUser;
  String? token;

  UserModel({
    this.dataUser,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    dataUser: json["data_user"] == null ? null : DataUser.fromJson(json["data_user"]),
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "data_user": dataUser?.toJson(),
    "token": token,
  };
}

class DataUser {
  String? id;
  String? firstName;
  String? lastName;
  String? userName;
  bool? isManager;

  DataUser({
    this.id,
    this.firstName,
    this.lastName,
    this.userName,
    this.isManager,
  });

  factory DataUser.fromJson(Map<String, dynamic> json) => DataUser(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    userName: json["user_name"],
    isManager: json["is_manager"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "user_name": userName,
    "is_manager": isManager,
  };
}
