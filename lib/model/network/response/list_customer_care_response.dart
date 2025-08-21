class GetListHistoryCustomerCareResponse {
  List<GetListHistoryCustomerCareResponseData>? listCustomerCare;
  int? totalPage;
  int? statusCode;
  String? message;

  GetListHistoryCustomerCareResponse(
      {this.listCustomerCare, this.totalPage, this.statusCode, this.message});

  GetListHistoryCustomerCareResponse.fromJson(Map<String, dynamic> json) {
    if (json['listCustomerCare'] != null) {
      listCustomerCare = <GetListHistoryCustomerCareResponseData>[];
      json['listCustomerCare'].forEach((v) {
        listCustomerCare!.add( GetListHistoryCustomerCareResponseData.fromJson(v));
      });
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listCustomerCare != null) {
      data['listCustomerCare'] =
          this.listCustomerCare!.map((v) => v.toJson()).toList();
    }
    data['totalPage'] = this.totalPage;
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class GetListHistoryCustomerCareResponseData {
  String? sttRec;
  String? ngayCt;
  String? maKh;
  String? tenKh;
  String? diaChi;
  String? dienThoai;
  String? dienGiai;
  String? loaiCs;
  String? khPh;
  List<ImageList>? imageList;

  GetListHistoryCustomerCareResponseData(
      {this.sttRec,
        this.ngayCt,
        this.maKh,
        this.tenKh,
        this.diaChi,
        this.dienThoai,
        this.dienGiai,
        this.loaiCs,
        this.khPh,
        this.imageList});

  GetListHistoryCustomerCareResponseData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    ngayCt = json['ngay_ct'];
    maKh = json['ma_kh'];
    tenKh = json['ten_kh'];
    diaChi = json['dia_chi'];
    dienThoai = json['dien_thoai'];
    dienGiai = json['dien_giai'];
    loaiCs = json['loai_cs'];
    khPh = json['kh_ph'];
    if (json['imageList'] != null) {
      imageList = <ImageList>[];
      json['imageList'].forEach((v) {
        imageList!.add(new ImageList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stt_rec'] = this.sttRec;
    data['ngay_ct'] = this.ngayCt;
    data['ma_kh'] = this.maKh;
    data['ten_kh'] = this.tenKh;
    data['dia_chi'] = this.diaChi;
    data['dien_thoai'] = this.dienThoai;
    data['dien_giai'] = this.dienGiai;
    data['loai_cs'] = this.loaiCs;
    data['kh_ph'] = this.khPh;
    if (this.imageList != null) {
      data['imageList'] = this.imageList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ImageList {
  String? pathL;
  String? maAlbum;
  String? tenAlbum;
  String? maKh;
  String? keyValue;

  ImageList(
      {this.pathL, this.maAlbum, this.tenAlbum, this.maKh, this.keyValue});

  ImageList.fromJson(Map<String, dynamic> json) {
    pathL = json['path_l'];
    maAlbum = json['ma_album'];
    tenAlbum = json['ten_album'];
    maKh = json['ma_kh'];
    keyValue = json['key_value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['path_l'] = this.pathL;
    data['ma_album'] = this.maAlbum;
    data['ten_album'] = this.tenAlbum;
    data['ma_kh'] = this.maKh;
    data['key_value'] = this.keyValue;
    return data;
  }
}

