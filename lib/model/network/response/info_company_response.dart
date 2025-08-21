class InfoCompanyResponse {
  List<InfoCompanyResponseCompanies>? companies;
  int? statusCode;
  String? message;

  InfoCompanyResponse({this.companies, this.statusCode, this.message});

  InfoCompanyResponse.fromJson(Map<String, dynamic> json) {
    if (json['companies'] != null) {
      companies = <InfoCompanyResponseCompanies>[];
      json['companies'].forEach((v) {
        companies!.add(new InfoCompanyResponseCompanies.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.companies != null) {
      data['companies'] = this.companies!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class InfoCompanyResponseCompanies {
  String? companyId;
  String? companyName;

  InfoCompanyResponseCompanies({this.companyId, this.companyName});

  InfoCompanyResponseCompanies.fromJson(Map<String, dynamic> json) {
    companyId = json['companyId'];
    companyName = json['companyName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['companyId'] = this.companyId;
    data['companyName'] = this.companyName;
    return data;
  }
}

