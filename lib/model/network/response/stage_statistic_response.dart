class StageStatisticResponse {
  List<StageStatisticResponseData>? data;
  int? statusCode;
  String? message;

  StageStatisticResponse({this.data, this.statusCode, this.message});

  StageStatisticResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <StageStatisticResponseData>[];
      json['data'].forEach((v) {
        data?.add(new StageStatisticResponseData.fromJson(v));
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

class StageStatisticResponseData {
  String? sttRec;
  String? soLsx;
  String? ngayCt;
  String? fcode1;
  String? dienGiai;
  String? comment;

  StageStatisticResponseData(
      {this.sttRec,
        this.soLsx,
        this.ngayCt,
        this.fcode1,
        this.dienGiai,
        this.comment});

  StageStatisticResponseData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    soLsx = json['so_lsx'];
    ngayCt = json['ngay_ct'];
    fcode1 = json['fcode1'];
    dienGiai = json['dien_giai'];
    comment = json['comment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stt_rec'] = this.sttRec;
    data['so_lsx'] = this.soLsx;
    data['ngay_ct'] = this.ngayCt;
    data['fcode1'] = this.fcode1;
    data['dien_giai'] = this.dienGiai;
    data['comment'] = this.comment;
    return data;
  }
}