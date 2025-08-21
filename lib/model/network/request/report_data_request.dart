class ReportRequest{
  String? reportId;
  String? timeId;
  String? unitId;
  String? storeId;
  String? unitOfMeasure;
  String? reportType;


  ReportRequest({this.reportId,this.timeId,this.unitId,this.storeId,this.unitOfMeasure,this.reportType});

  ReportRequest.fromJson(Map<String, dynamic> json) {
    reportId = json['reportId'];
    timeId = json['timeId'];
    unitId = json['unitId'];
    storeId = json['storeId'];
    unitOfMeasure = json['UnitOfMeasure'];
    reportType = json['reportType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if(this.reportId != null){
      data['reportId'] = this.reportId;
    }
    if(this.timeId != null){
      data['timeId'] = this.timeId;
    }
    if(this.unitId != null){
      data['unitId'] = this.unitId;
    }if(this.storeId != null){
      data['storeId'] = this.storeId;
    }
    if(this.unitOfMeasure != null){
      data['UnitOfMeasure'] = this.unitOfMeasure;
    }
    if(this.reportType != null){
      data['reportType'] = this.reportType;
    }
    return data;
  }
}