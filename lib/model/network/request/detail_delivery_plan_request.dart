class DeliveryPlanDetailRequest {
  String? sttRec;
  String? ngayGiao;
  String? maKH;
  String? maVc;
  String? nguoiGiao;

  DeliveryPlanDetailRequest({this.sttRec,this.nguoiGiao,this.ngayGiao,this.maKH,this.maVc});

  DeliveryPlanDetailRequest.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    ngayGiao = json['ngay_giao'];
    maKH = json['ma_kh'];
    maVc = json['ma_vc'];
    nguoiGiao = json['nguoi_giao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stt_rec'] = this.sttRec;
    data['ngay_giao'] = this.ngayGiao;
    data['ma_kh'] = this.maKH;
    data['ma_vc'] = this.maVc;
    data['nguoi_giao'] = this.nguoiGiao;
    return data;
  }
}

