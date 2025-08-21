class ListDNCResponse {
  List<ListDNCResponseData>? data;
  int? statusCode;
  String? message;

  ListDNCResponse({this.data, this.statusCode, this.message});

  ListDNCResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListDNCResponseData>[];
      json['data'].forEach((v) {
        data?.add(new ListDNCResponseData.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data?.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class ListDNCResponseData {
  String? sttRec;
  String? soLsx;
  String? ngayCt;
  String? dienGiai;
  String? comment;
  String? statusname;
  String? capDuyet;

  ListDNCResponseData(
      {this.sttRec,
        this.soLsx,
        this.ngayCt,
        this.dienGiai,
        this.comment,
        this.statusname,this.capDuyet});

  ListDNCResponseData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    soLsx = json['so_lsx'];
    ngayCt = json['ngay_ct'];
    dienGiai = json['dien_giai'];
    comment = json['comment'];
    statusname = json['statusname'];
    capDuyet = json['cap_duyet'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stt_rec'] = this.sttRec;
    data['so_lsx'] = this.soLsx;
    data['ngay_ct'] = this.ngayCt;
    data['dien_giai'] = this.dienGiai;
    data['comment'] = this.comment;
    data['statusname'] = this.statusname;
    data['cap_duyet'] = this.capDuyet;
    return data;
  }
}