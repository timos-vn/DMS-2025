class ListRequestOpenStoreResponse {
  ListRequestOpenStoreResponseData? data;
  int? statusCode;
  String? message;

  ListRequestOpenStoreResponse({this.data, this.statusCode, this.message});

  ListRequestOpenStoreResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ?  ListRequestOpenStoreResponseData.fromJson(json['data']) : null;
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ListRequestOpenStoreResponseData {
  List<DataRequest>? dataRequest;

  ListRequestOpenStoreResponseData({this.dataRequest});

  ListRequestOpenStoreResponseData.fromJson(Map<String, dynamic> json) {
    if (json['dataRequest'] != null) {
      dataRequest = <DataRequest>[];
      json['dataRequest'].forEach((v) {
        dataRequest!.add( DataRequest.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (dataRequest != null) {
      data['dataRequest'] = dataRequest!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DataRequest {
  Master? master;
  List<ImageListRequestOpenStore>? imageListRequestOpenStore;

  DataRequest({this.master, this.imageListRequestOpenStore});

  DataRequest.fromJson(Map<String, dynamic> json) {
    master =
    json['master'] != null ?  Master.fromJson(json['master']) : null;
    if (json['imageListRequestOpenStore'] != null) {
      imageListRequestOpenStore = <ImageListRequestOpenStore>[];
      json['imageListRequestOpenStore'].forEach((v) {
        imageListRequestOpenStore!
            .add( ImageListRequestOpenStore.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (master != null) {
      data['master'] = master!.toJson();
    }
    if (imageListRequestOpenStore != null) {
      data['imageListRequestOpenStore'] =
          imageListRequestOpenStore!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Master {
  String? keyValue;
  String? tenCh;
  String? tenKh;
  String? dienThoai;
  String? diaChi;
  String? tenTinh;
  String? tenQuan;
  String? email;
  String? nguoiTao;
  String? ghiChu;
  int? trangThai;
  String? ngayTao;
  String? latlong;

  Master(
      {this.keyValue,
        this.tenCh,
        this.tenKh,
        this.dienThoai,
        this.diaChi,
        this.tenTinh,
        this.tenQuan,
        this.email,
        this.nguoiTao,
        this.ghiChu,
        this.trangThai,
        this.ngayTao,
        this.latlong});

  Master.fromJson(Map<String, dynamic> json) {
    keyValue = json['key_value'];
    tenCh = json['ten_ch'];
    tenKh = json['ten_kh'];
    dienThoai = json['dien_thoai'];
    diaChi = json['dia_chi'];
    tenTinh = json['ten_tinh'];
    tenQuan = json['ten_quan'];
    email = json['email'];
    nguoiTao = json['nguoi_tao'];
    ghiChu = json['ghi_chu'];
    trangThai = json['trang_thai'];
    ngayTao = json['ngay_tao'];
    latlong = json['latlong'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['key_value'] = keyValue;
    data['ten_ch'] = tenCh;
    data['ten_kh'] = tenKh;
    data['dien_thoai'] = dienThoai;
    data['dia_chi'] = diaChi;
    data['ten_tinh'] = tenTinh;
    data['ten_quan'] = tenQuan;
    data['email'] = email;
    data['nguoi_tao'] = nguoiTao;
    data['ghi_chu'] = ghiChu;
    data['trang_thai'] = trangThai;
    data['ngay_tao'] = ngayTao;
    data['latlong'] = latlong;
    return data;
  }
}

class ImageListRequestOpenStore {
  String? pathL;
  String? maAlbum;
  String? tenAlbum;
  String? maKh;
  String? keyValue;

  ImageListRequestOpenStore(
      {this.pathL, this.maAlbum, this.tenAlbum, this.maKh, this.keyValue});

  ImageListRequestOpenStore.fromJson(Map<String, dynamic> json) {
    pathL = json['path_l'];
    maAlbum = json['ma_album'];
    tenAlbum = json['ten_album'];
    maKh = json['ma_kh'];
    keyValue = json['key_value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['path_l'] = pathL;
    data['ma_album'] = maAlbum;
    data['ten_album'] = tenAlbum;
    data['ma_kh'] = maKh;
    data['key_value'] = keyValue;
    return data;
  }
}

