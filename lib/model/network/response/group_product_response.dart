class GroupProductResponse{
  int? pageIndex;
  int? statusCode;
  String? message;
  List<GroupProductResponseData>? data;


  GroupProductResponse({this.data,this.pageIndex,this.statusCode,this.message});

  GroupProductResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <GroupProductResponseData>[];for (var v in (json['data'] as List)) { data!.add( GroupProductResponseData.fromJson(v)); }
    }
    message = json['message'];
    statusCode = json['statusCode'];
    pageIndex = json['pageIndex'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (this.data != null) {
      data['data'] =  this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    data['pageIndex'] = pageIndex;
    data['statusCode'] = statusCode;
    return data;
  }
}

class GroupProductResponseData{
  int? groupType;
  String? groupCode;
  String? groupName;
  String? iconUrl;
  bool? isChecked = false;


  GroupProductResponseData({this.groupType,this.groupCode,this.groupName,this.iconUrl,this.isChecked});

  GroupProductResponseData.fromJson(Map<String, dynamic> json) {
    groupType = json['groupType'];
    groupCode = json['groupCode'];
    groupName = json['groupName'];
    iconUrl = json['iconUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['groupType'] = groupType;
    data['groupCode'] = groupCode;
    data['groupName'] = groupName;
    data['iconUrl'] = iconUrl;
    return data;
  }
}

