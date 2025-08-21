
class PieChartDataResponse{

  List<PieChartReportResponseData>? data;

  PieChartDataResponse({this.data});

  PieChartDataResponse.fromJson(Map<String, dynamic> json) {

    if (json['reportData'] != null) {
      data = <PieChartReportResponseData>[];(json['reportData'] as List).forEach((v) { data!.add(new PieChartReportResponseData.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if (this.data != null) {
      data['reportData'] =  this.data?.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class PieChartReportResponseData{
  String? colId;
  String? colName;
  double? value;

  PieChartReportResponseData({this.colId,this.colName,this.value});

  PieChartReportResponseData.fromJson(Map<String, dynamic> json) {
    colId = json['colId'];
    colName = json['colName'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['colId'] = this.colId;
    data['colName'] = this.colName;
    data['value'] = this.value;
    return data;
  }
}

