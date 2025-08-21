class GetListHistoryActionEmployeeResponse {
  List<GetListHistoryActionEmployeeResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  GetListHistoryActionEmployeeResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  GetListHistoryActionEmployeeResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <GetListHistoryActionEmployeeResponseData>[];
      json['data'].forEach((v) {
        data!.add(new GetListHistoryActionEmployeeResponseData.fromJson(v));
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

class GetListHistoryActionEmployeeResponseData {
  String? tieuDe;
  String? ngay;
  String? maKh;
  String? tenKh;
  String? noiDung;
  String? loaiHinh;
  String? tenNv;

  GetListHistoryActionEmployeeResponseData(
      {this.tieuDe,
        this.ngay,
        this.maKh,
        this.tenKh,
        this.noiDung,
        this.loaiHinh,
        this.tenNv});

  GetListHistoryActionEmployeeResponseData.fromJson(Map<String, dynamic> json) {
    tieuDe = json['tieu_de'];
    ngay = json['ngay'];
    maKh = json['ma_kh'];
    tenKh = json['ten_kh'];
    noiDung = json['noi_dung'];
    loaiHinh = json['loai_hinh'];
    tenNv = json['ten_nv'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tieu_de'] = this.tieuDe;
    data['ngay'] = this.ngay;
    data['ma_kh'] = this.maKh;
    data['ten_kh'] = this.tenKh;
    data['noi_dung'] = this.noiDung;
    data['loai_hinh'] = this.loaiHinh;
    data['ten_nv'] = this.tenNv;
    return data;
  }
}

