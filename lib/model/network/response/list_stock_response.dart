class ListStockAndGroupResponse {
  List<ListStore>? listStore;
  List<ListGroup>? listGroup;
  List<ListQDDVT>? listQuyDoiDonViTinh;
  int? statusCode;
  String? message;

  ListStockAndGroupResponse(
      {this.listStore, this.listGroup, this.listQuyDoiDonViTinh, this.statusCode, this.message});

  ListStockAndGroupResponse.fromJson(Map<String, dynamic> json) {
    if (json['listStore'] != null) {
      listStore = <ListStore>[];
      json['listStore'].forEach((v) {
        listStore!.add(ListStore.fromJson(v));
      });
    }
    if (json['listGroup'] != null) {
      listGroup = <ListGroup>[];
      json['listGroup'].forEach((v) {
        listGroup!.add(ListGroup.fromJson(v));
      });
    }
    if (json['listQuyDoi'] != null) {
      listQuyDoiDonViTinh = <ListQDDVT>[];
      json['listQuyDoi'].forEach((v) {
        listQuyDoiDonViTinh!.add(ListQDDVT.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listStore != null) {
      data['listStore'] = listStore!.map((v) => v.toJson()).toList();
    }
    if (listGroup != null) {
      data['listGroup'] = listGroup!.map((v) => v.toJson()).toList();
    }
    if (listQuyDoiDonViTinh != null) {
      data['listQuyDoi'] = listQuyDoiDonViTinh!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ListStore {
  String? maKho;
  String? tenKho;
  double? ton13;
  double? priceMin = 0;

  ListStore({this.maKho, this.tenKho, this.ton13, this.priceMin = 0});

  ListStore.fromJson(Map<String, dynamic> json) {
    maKho = json['ma_kho'];
    tenKho = json['ten_kho'];
    ton13 = json['ton13'];
    priceMin = json['gia_min'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_kho'] = maKho;
    data['ten_kho'] = tenKho;
    data['ton13'] = ton13;
    data['gia_min'] = priceMin;
    return data;
  }
}

class ListGroup {
  int? stt;
  String? loaiNhom;
  String? maNhom;

  ListGroup({this.stt, this.loaiNhom, this.maNhom});

  ListGroup.fromJson(Map<String, dynamic> json) {
    stt = json['stt'];
    loaiNhom = json['loai_nhom'];
    maNhom = json['ma_nhom'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt'] = stt;
    data['loai_nhom'] = loaiNhom;
    data['ma_nhom'] = maNhom;
    return data;
  }
}

class ListQDDVT {
  String? maVt;
  String? dvt;
  dynamic heSo;
  bool? isDefault;

  ListQDDVT({this.maVt, this.dvt, this.heSo, this.isDefault});

  ListQDDVT.fromJson(Map<String, dynamic> json) {
    maVt = json['ma_vt'];
    dvt = json['dvt'];
    heSo = json['he_so'];
    isDefault = json['default'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_vt'] = maVt;
    data['dvt'] = dvt;
    data['he_so'] = heSo;
    data['default'] = isDefault;
    return data;
  }
}

