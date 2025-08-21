class TableChartResponse {
  String? message;
  int? statusCode;
  List<HeaderData>? headerDesc;

  TableChartResponse({ this.message,  this.statusCode, this.headerDesc});

  TableChartResponse.fromJson(Map<String, dynamic> json) {

    this.message = json['message'];

    this.statusCode = json['statusCode'];

    if (json['headerDesc'] != null) {
      headerDesc = <HeaderData>[];
      (json['headerDesc'] as List).forEach((v) { headerDesc!.add(new HeaderData.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['message'] = this.message;

    data['statusCode'] = this.statusCode;
    if (this.headerDesc != null) {
      data['headerDesc'] =  this.headerDesc?.map((v) => v.toJson()).toList();
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

  HeaderData({this.field,this.name,this.name2,this.type,this.format});

  HeaderData.fromJson(Map<String, dynamic> json) {
    this.field = json['field'];
    this.name = json['name'];
    this.name2 = json['name2'];
    this.type = json['type'];
    this.format = json['format'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['field'] = this.field;
    data['name'] = this.name;
    data['name2'] = this.name2;
    data['type'] = this.type;
    data['format'] = this.format;

    return data;
  }
}


