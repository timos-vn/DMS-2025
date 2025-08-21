class DeliveryPlanResponse {
  List<DeliveryPlanResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  DeliveryPlanResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  DeliveryPlanResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <DeliveryPlanResponseData>[];
      json['data'].forEach((v) {
        data!.add(new DeliveryPlanResponseData.fromJson(v));
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

class DeliveryPlanResponseData {
  String? sttRec;
  String? maDvcs;
  String? ngayCt;
  String? soCt;
  String? dienGiai;
  String? maCt;
  String? status;
  String? userId0;
  String? userId2;
  String? datetime0;
  String? datetime2;
  String? deptId;
  String? ngayGiao;
  String? maVc;
  String? maKH;
  String? tenKH;
  String? nguoiGiao;
  String? tenNguoiGiao;

  DeliveryPlanResponseData(
      {this.sttRec,
        this.maDvcs,
        this.ngayCt,
        this.soCt,
        this.dienGiai,
        this.maCt,
        this.status,
        this.userId0,
        this.userId2,
        this.datetime0,
        this.datetime2,
        this.deptId,this.tenKH,this.nguoiGiao,this.ngayGiao,this.maVc,this.maKH,this.tenNguoiGiao});

  DeliveryPlanResponseData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    maDvcs = json['ma_dvcs'];
    ngayCt = json['ngay_ct'];
    soCt = json['so_ct'];
    dienGiai = json['dien_giai'];
    maCt = json['ma_ct'];
    status = json['status'];
    userId0 = json['user_id0'];
    userId2 = json['user_id2'];
    datetime0 = json['datetime0'];
    datetime2 = json['datetime2'];
    deptId = json['dept_id'];
    tenKH = json['ten_kh'];
    nguoiGiao = json['nguoi_giao'];

    maVc = json['ma_vc'];
    maKH = json['ma_kh'];
    ngayGiao = json['ngay_giao'];
    tenNguoiGiao = json['ten_nguoi_giao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stt_rec'] = this.sttRec;
    data['ma_dvcs'] = this.maDvcs;
    data['ngay_ct'] = this.ngayCt;
    data['so_ct'] = this.soCt;
    data['dien_giai'] = this.dienGiai;
    data['ma_ct'] = this.maCt;
    data['status'] = this.status;
    data['user_id0'] = this.userId0;
    data['user_id2'] = this.userId2;
    data['datetime0'] = this.datetime0;
    data['datetime2'] = this.datetime2;
    data['dept_id'] = this.deptId;
    data['ten_kh'] = this.tenKH;
    data['nguoi_giao'] = this.nguoiGiao;

    data['ma_vc'] = this.maVc;
    data['ma_kh'] = this.maKH;
    data['ngay_giao'] = this.ngayGiao;
    data['ten_nguoi_giao'] = this.tenNguoiGiao;
    return data;
  }
}

