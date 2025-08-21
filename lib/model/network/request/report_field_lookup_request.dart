class ReportFieldLookupRequest {
  String? controller;
  int? pageIndex;
  String? filterValueCode;
  String? filterValueName;

  ReportFieldLookupRequest({this.controller,this.pageIndex, this.filterValueCode,this.filterValueName});

  ReportFieldLookupRequest.fromJson(Map<String, dynamic> json) {
    controller = json['Controller'];
    pageIndex = json['PageIndex'];
    filterValueCode = json['FilterValueCode'];
    filterValueName = json['FilterValueName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if(this.controller != null){
      data['Controller'] = this.controller;
    }
    if(this.pageIndex != null){
      data['PageIndex'] = this.pageIndex;
    }
    if(this.filterValueCode != null){
      data['FilterValueCode'] = this.filterValueCode;
    }
    if(this.filterValueName != null){
      data['FilterValueName'] = this.filterValueName;
    }
    return data;
  }
}