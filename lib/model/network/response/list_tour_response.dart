class GetListTourResponse {
  List<GetListTourResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  GetListTourResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  GetListTourResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <GetListTourResponseData>[];
      json['data'].forEach((v) {
        data!.add( GetListTourResponseData.fromJson(v));
      });
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalPage'] = this.totalPage;
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class GetListTourResponseData {
  String? maTuyen;
  String? tenTuyen;

  GetListTourResponseData({this.maTuyen, this.tenTuyen});

  GetListTourResponseData.fromJson(Map<String, dynamic> json) {
    maTuyen = json['ma_tuyen'];
    tenTuyen = json['ten_tuyen'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ma_tuyen'] = this.maTuyen;
    data['ten_tuyen'] = this.tenTuyen;
    return data;
  }
}

