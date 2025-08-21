class ResultReportRequest {
  String? reportId;
  List<dynamic>? values;

  ResultReportRequest({this.reportId,this.values,});

  ResultReportRequest.fromJson(Map<String, dynamic> json) {
    reportId = json['ReportId'];
    values = json['Values'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if(this.reportId != null){
      data['ReportId'] = this.reportId;
    }
    if(this.values != null){
      data['Values'] = this.values;
    }
    return data;
  }
}