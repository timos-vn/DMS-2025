class InfoUnitsResponse{
  int? statusCode;
  String? message;
  List<InfoUnitsResponseUnits>? units;

  InfoUnitsResponse({this.statusCode,this.message,this.units});

  InfoUnitsResponse.fromJson(Map<String, dynamic> json) {
    if (json['units'] != null) {
      units = <InfoUnitsResponseUnits>[];
      (json['units'] as List).forEach((v) {
        units!.add(new InfoUnitsResponseUnits.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.units != null) {
      data['units'] =  this.units!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class InfoUnitsResponseUnits{
  String? unitId;
  String? unitName;

  InfoUnitsResponseUnits({this.unitId,this.unitName});

  InfoUnitsResponseUnits.fromJson(Map<String, dynamic> json) {
    unitId = json['unitId'];
    unitName = json['unitName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['unitId'] = this.unitId;
    data['unitName'] = this.unitName;
    return data;
  }
}