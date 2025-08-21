class ListApprovalDetailResponse {
  List<ListApprovalDetailResponseData>? data;
  int? statusCode;
  int? totalPage;
  String? message;

  ListApprovalDetailResponse({this.data, this.statusCode, this.message,this.totalPage});

  ListApprovalDetailResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListApprovalDetailResponseData>[];
      json['data'].forEach((v) {
        data!.add(new ListApprovalDetailResponseData.fromJson(v));
      });
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalPage'] = this.totalPage;
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class ListApprovalDetailResponseData {
  int? sysorder;
  int? systotal;
  int? sysprint;
  bool? tag;
  String? sttRec;
  String? maCt;
  String? ngayCt;
  String? dateFrom;
  String? dateTo;
  String? desc;
  String? soCt;
  String? status;
  int? userId0;
  String? statusname;
  String? userName;

  ListApprovalDetailResponseData(
      {this.sysorder,
        this.systotal,
        this.sysprint,
        this.tag,
        this.sttRec,
        this.maCt,
        this.ngayCt,
        this.soCt,
        this.status,
        this.userId0,this.dateFrom,this.dateTo,this.desc,
        this.statusname,this.userName});

  ListApprovalDetailResponseData.fromJson(Map<String, dynamic> json) {
    sysorder = json['sysorder'];
    systotal = json['systotal'];
    sysprint = json['sysprint'];
    tag = json['tag'];
    sttRec = json['stt_rec'];
    maCt = json['ma_ct'];
    ngayCt = json['ngay_ct'];
    soCt = json['so_ct'];
    status = json['status'];
    userId0 = json['user_id0'];
    statusname = json['statusname'];
    userName = json['user_name'];
    dateTo = json['ngay_den'];
    dateFrom = json['ngay_tu'];
    desc = json['dien_giai'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sysorder'] = this.sysorder;
    data['systotal'] = this.systotal;
    data['sysprint'] = this.sysprint;
    data['tag'] = this.tag;
    data['stt_rec'] = this.sttRec;
    data['ma_ct'] = this.maCt;
    data['ngay_ct'] = this.ngayCt;
    data['so_ct'] = this.soCt;
    data['status'] = this.status;
    data['user_id0'] = this.userId0;
    data['statusname'] = this.statusname;
    data['user_name'] = this.userName;
    data['ngay_tu'] = dateFrom;
    data['ngay_den'] = dateTo;
    data['dien_giai'] = desc;
    return data;
  }
}