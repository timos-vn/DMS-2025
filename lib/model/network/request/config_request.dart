class ConfigRequest {
  String? companyId;

  ConfigRequest({this.companyId});

  ConfigRequest.fromJson(Map<String, dynamic> json) {
    companyId = json['CompanyId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if(this.companyId != null){
      data['CompanyId'] = this.companyId;
    }
    return data;
  }
}
