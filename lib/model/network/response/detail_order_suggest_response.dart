class DetailOrderSuggestResponse {
  List<ListTableOne>? listTableOne;
  List<ListTableTwo>? listTableTwo;
  int? statusCode;
  String? message;

  DetailOrderSuggestResponse(
      {this.listTableOne, this.listTableTwo, this.statusCode, this.message});

  DetailOrderSuggestResponse.fromJson(Map<String, dynamic> json) {
    if (json['listTableOne'] != null) {
      listTableOne = <ListTableOne>[];
      json['listTableOne'].forEach((v) {
        listTableOne!.add(new ListTableOne.fromJson(v));
      });
    }
    if (json['listTableTwo'] != null) {
      listTableTwo = <ListTableTwo>[];
      json['listTableTwo'].forEach((v) {
        listTableTwo!.add(new ListTableTwo.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listTableOne != null) {
      data['listTableOne'] = listTableOne!.map((v) => v.toJson()).toList();
    }
    if (listTableTwo != null) {
      data['listTableTwo'] = listTableTwo!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ListTableOne {
  String? sttRec;
  String? maDvcs;
  String? soCt;
  String? maCt;
  String? ngayCt;
  String? maKho;
  String? tenKho;
  String? maKhon;
  String? tenKhoNhap;
  String? deptId;
  String? dienGiai;
  String? status;
  String? statusname;

  ListTableOne(
      {this.sttRec,
        this.maDvcs,
        this.soCt,
        this.maCt,
        this.ngayCt,
        this.maKho,
        this.tenKho,
        this.maKhon,
        this.tenKhoNhap,
        this.deptId,
        this.dienGiai,
        this.status,
        this.statusname});

  ListTableOne.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    maDvcs = json['ma_dvcs'];
    soCt = json['so_ct'];
    maCt = json['ma_ct'];
    ngayCt = json['ngay_ct'];
    maKho = json['ma_kho'];
    tenKho = json['ten_kho'];
    maKhon = json['ma_khon'];
    tenKhoNhap = json['ten_kho_nhap'];
    deptId = json['dept_id'];
    dienGiai = json['dien_giai'];
    status = json['status'];
    statusname = json['statusname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['ma_dvcs'] = maDvcs;
    data['so_ct'] = soCt;
    data['ma_ct'] = maCt;
    data['ngay_ct'] = ngayCt;
    data['ma_kho'] = maKho;
    data['ten_kho'] = tenKho;
    data['ma_khon'] = maKhon;
    data['ten_kho_nhap'] = tenKhoNhap;
    data['dept_id'] = deptId;
    data['dien_giai'] = dienGiai;
    data['status'] = status;
    data['statusname'] = statusname;
    return data;
  }
}

class ListTableTwo {
  String? sttRec;
  String? sttRec0;
  String? maVt;
  String? tenVt;
  String? dvt;
  dynamic soLuong;

  ListTableTwo(
      {this.sttRec, this.sttRec0, this.maVt, this.tenVt, this.soLuong, this.dvt});

  ListTableTwo.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    sttRec0 = json['stt_rec0'];
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    dvt = json['dvt'];
    soLuong = json['so_luong'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['stt_rec0'] = sttRec0;
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;
    data['dvt'] = dvt;
    data['so_luong'] = soLuong;
    return data;
  }
}