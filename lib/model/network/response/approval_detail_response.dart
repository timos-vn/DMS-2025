class ResultReportResponse {
  String? message;
  int? statusCode;
  int? pageIndex;
  int? totalCount;
  int? totalPage;
  List<HeaderData>? headerDesc;
  List<StatusData>? statusData;

  ResultReportResponse({this.message, this.statusCode, this.headerDesc, this.pageIndex,this.totalCount,this.totalPage});

  ResultReportResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    pageIndex = json['pageIndex'];
    totalCount = json['totalCount'];
    statusCode = json['statusCode'];totalPage = json['totalPage'];

    if (json['headerDesc'] != null) {
      headerDesc = <HeaderData>[];
      for (var v in (json['headerDesc'] as List)) {
        headerDesc!.add(HeaderData.fromJson(v));
      }
    }
    if (json['status'] != null) {
      statusData = <StatusData>[];
      for (var v in (json['status'] as List)) {
        statusData!.add(StatusData.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['pageIndex'] = pageIndex;
    data['totalCount'] = totalCount;
    data['statusCode'] = statusCode;data['totalPage'] = totalPage;
    if (headerDesc != null) {
      data['headerDesc'] = headerDesc!.map((v) => v.toJson()).toList();
    }
    if (statusData != null) {
      data['status'] = statusData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class HeaderData {
  String? field;
  String? name;
  String? name2;
  int? type;
  String? format;

  HeaderData({this.field, this.name, this.name2, this.type,this.format});

  HeaderData.fromJson(Map<String, dynamic> json) {
    field = json['field'];
    name = json['name'];
    name2 = json['name2'];
    type = json['type'];
    format = json['format'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['field'] = field;
    data['name'] = name;
    data['name2'] = name2;
    data['type'] = type;
    data['format'] = format;

    return data;
  }
}

class StatusData {
  String? status;
  String? statusName;
  String? statusName2;

  StatusData({this.status, this.statusName, this.statusName2});

  StatusData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusName = json['statusName'];
    statusName2 = json['statusName2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['statusName'] = statusName;
    data['statusName2'] = statusName2;

    return data;
  }
}
