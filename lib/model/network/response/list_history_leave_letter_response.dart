class ListHistoryLeaveLetterResponse {
  List<ListHistoryLeaveLetterResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  ListHistoryLeaveLetterResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  ListHistoryLeaveLetterResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListHistoryLeaveLetterResponseData>[];
      json['data'].forEach((v) {
        data!.add(ListHistoryLeaveLetterResponseData.fromJson(v));
      });
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalPage'] = totalPage;
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ListHistoryLeaveLetterResponseData {
  String? sttRec;
  int? stt;
  int? tag;
  String? ngayTu;
  String? ngayDen;
  String? tenLoai;
  String? loaiNghi;
  String? ghiChu;
  String? maNv;
  String? hoNv;
  String? tenNv;
  String? hoTen;
  String? boPhan;
  String? tenBp;
  String? status;
  String? bacDuyet;
  String? statusName;

  ListHistoryLeaveLetterResponseData(
      {this.sttRec,
        this.stt,
        this.tag,
        this.ngayTu,
        this.ngayDen,
        this.tenLoai,
        this.loaiNghi,
        this.ghiChu,
        this.maNv,
        this.hoNv,
        this.tenNv,
        this.hoTen,
        this.boPhan,
        this.tenBp,
        this.status,
        this.bacDuyet,
        this.statusName});

  ListHistoryLeaveLetterResponseData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    stt = json['stt'];
    tag = json['tag'];
    ngayTu = json['ngay_tu'];
    ngayDen = json['ngay_den'];
    tenLoai = json['ten_loai'];
    loaiNghi = json['loai_nghi'];
    ghiChu = json['ghi_chu'];
    maNv = json['ma_nv'];
    hoNv = json['ho_nv'];
    tenNv = json['ten_nv'];
    hoTen = json['ho_ten'];
    boPhan = json['bo_phan'];
    tenBp = json['ten_bp'];
    status = json['status'];
    bacDuyet = json['bac_duyet'];
    statusName = json['status_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['stt'] = stt;
    data['tag'] = tag;
    data['ngay_tu'] = ngayTu;
    data['ngay_den'] = ngayDen;
    data['ten_loai'] = tenLoai;
    data['loai_nghi'] = loaiNghi;
    data['ghi_chu'] = ghiChu;
    data['ma_nv'] = maNv;
    data['ho_nv'] = hoNv;
    data['ten_nv'] = tenNv;
    data['ho_ten'] = hoTen;
    data['bo_phan'] = boPhan;
    data['ten_bp'] = tenBp;
    data['status'] = status;
    data['bac_duyet'] = bacDuyet;
    data['status_name'] = statusName;
    return data;
  }
}