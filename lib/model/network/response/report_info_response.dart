class GetListReportsResponse {
  String? message;
  int? statusCode;
  List<DetailDataReport>? reportData;

  GetListReportsResponse({ this.message,  this.statusCode, this.reportData});

  GetListReportsResponse.fromJson(Map<String, dynamic> json) {

    this.message = json['message'];

    this.statusCode = json['statusCode'];

    if (json['data'] != null) {
      reportData = <DetailDataReport>[];
      (json['data'] as List).forEach((v) { reportData?.add(new DetailDataReport.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['message'] = this.message;

    data['statusCode'] = this.statusCode;
    if (this.reportData != null) {
      data['data'] =  this.reportData?.map((v) => v.toJson()).toList();
    }
    return data;
  }

}

class DetailDataReport {
  String? id;
  String? name;
  String? name2;
  List<ListDetailReport>? reportList;

  DetailDataReport({this.id,this.name,this.name2,this.reportList,});

  DetailDataReport.fromJson(Map<String, dynamic> json) {
    this.id = json['id'];
    this.name = json['name'];
    this.name2 = json['name2'];
    this.reportList = (json['reportList'] as List)!=null?(json['reportList'] as List).map((i) => ListDetailReport.fromJson(i)).toList():null;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['name2'] = this.name2;
    data['reportList'] = this.reportList != null?this.reportList?.map((i) => i.toJson()).toList():null;

    return data;
  }
}


class ListDetailReport {
  String? id;
  String? groupId;
  String? name;
  String? name2;
  double? desc;
  String? iconUrl;


  ListDetailReport({this.id, this.groupId, this.name, this.name2, this.desc,this.iconUrl});

  ListDetailReport.fromJson(Map<String, dynamic> json) {
    this.id = json['id'];
    this.groupId = json['groupId'];
    this.name = json['name'];
    this.name2 = json['name2'];
    this.desc = json['desc'];
    this.iconUrl = json['iconUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['groupId'] = this.groupId;
    data['name'] = this.name;
    data['name2'] = this.name2;
    data['desc'] = this.desc;
    data['iconUrl'] = this.iconUrl;
    return data;
  }
}
