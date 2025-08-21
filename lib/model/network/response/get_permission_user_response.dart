class GetPermissionUserResponse {
  List<UserPermission>? userPermission;
  List<UserPermissionAccount>? userPermissionAccount;
  int? statusCode;
  String? message;

  GetPermissionUserResponse(
      {this.userPermission,
        this.userPermissionAccount,
        this.statusCode,
        this.message});

  GetPermissionUserResponse.fromJson(Map<String, dynamic> json) {
    if (json['userPermission'] != null) {
      userPermission = <UserPermission>[];
      json['userPermission'].forEach((v) {
        userPermission!.add( UserPermission.fromJson(v));
      });
    }
    if (json['userPermissionAccount'] != null) {
      userPermissionAccount = <UserPermissionAccount>[];
      json['userPermissionAccount'].forEach((v) {
        userPermissionAccount!.add( UserPermissionAccount.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (this.userPermission != null) {
      data['userPermission'] =
          this.userPermission!.map((v) => v.toJson()).toList();
    }
    if (this.userPermissionAccount != null) {
      data['userPermissionAccount'] =
          this.userPermissionAccount!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class UserPermission {
  String? menuId;
  String? name;
  String? description;
  String? icon;
  String? parentMenuId;

  UserPermission(
      {this.menuId, this.name, this.description, this.icon, this.parentMenuId});

  UserPermission.fromJson(Map<String, dynamic> json) {
    menuId = json['menuId'];
    name = json['name'];
    description = json['description'];
    icon = json['icon'];
    parentMenuId = json['parentMenuId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['menuId'] = this.menuId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['icon'] = this.icon;
    data['parentMenuId'] = this.parentMenuId;
    return data;
  }
}

class UserPermissionAccount {
  String? name;
  int? value;

  UserPermissionAccount({this.name, this.value});

  UserPermissionAccount.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['value'] = this.value;
    return data;
  }
}

