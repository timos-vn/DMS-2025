class ListInventoryRequestResponse {
  List<ListInventoryRequestResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  ListInventoryRequestResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  ListInventoryRequestResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListInventoryRequestResponseData>[];
      json['data'].forEach((v) {
        data!.add(new ListInventoryRequestResponseData.fromJson(v));
      });
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalPage'] = totalPage;
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ListInventoryRequestResponseData {
  String? sttRec;
  String? ngayCt;
  String? tgKk;
  String? soCt;
  String? dienGiai;

  ListInventoryRequestResponseData({this.sttRec, this.ngayCt, this.tgKk, this.soCt, this.dienGiai});

  ListInventoryRequestResponseData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    ngayCt = json['ngay_ct'];
    tgKk = json['tg_kk'];
    soCt = json['so_ct'];
    dienGiai = json['dien_giai'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['ngay_ct'] = ngayCt;
    data['tg_kk'] = tgKk;
    data['so_ct'] = soCt;
    data['dien_giai'] = dienGiai;
    return data;
  }
}

class ListItemInventoryResponse {
  List<ListItemInventoryResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  ListItemInventoryResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  ListItemInventoryResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListItemInventoryResponseData>[];
      json['data'].forEach((v) {
        data!.add(new ListItemInventoryResponseData.fromJson(v));
      });
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalPage'] = totalPage;
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ListItemInventoryResponseData {
  String? sttRec;
  String? maKho;
  String? maVt;
  String? maViTri;
  String? maLo;
  double tonHd;
  double so_luong_kk_tt;
  double chenh_lech;
  String? tenKho;
  String? tenVt;
  String? tenVt2;
  String? dvt;

  ListItemInventoryResponseData({
    this.sttRec,
    this.maKho,
    this.maVt,
    this.maViTri,
    this.maLo,
    this.tonHd = 0,
    this.so_luong_kk_tt = 0,
    this.chenh_lech = 0,
    this.tenKho,
    this.tenVt,
    this.tenVt2,
    this.dvt,
  });

  /// ✅ Hàm copyWith chuẩn — type-safe, IDE hỗ trợ autocomplete
  ListItemInventoryResponseData copyWith({
    String? sttRec,
    String? maKho,
    String? maVt,
    String? maViTri,
    String? maLo,
    double? tonHd,
    double? so_luong_kk_tt,
    double? chenh_lech,
    String? tenKho,
    String? tenVt,
    String? tenVt2,
    String? dvt,
  }) {
    return ListItemInventoryResponseData(
      sttRec: sttRec ?? this.sttRec,
      maKho: maKho ?? this.maKho,
      maVt: maVt ?? this.maVt,
      maViTri: maViTri ?? this.maViTri,
      maLo: maLo ?? this.maLo,
      tonHd: tonHd ?? this.tonHd,
      so_luong_kk_tt: so_luong_kk_tt ?? this.so_luong_kk_tt,
      chenh_lech: chenh_lech ?? this.chenh_lech,
      tenKho: tenKho ?? this.tenKho,
      tenVt: tenVt ?? this.tenVt,
      tenVt2: tenVt2 ?? this.tenVt2,
      dvt: dvt ?? this.dvt,
    );
  }

  /// ✅ Parse từ JSON với ép kiểu an toàn
  ListItemInventoryResponseData.fromJson(Map<String, dynamic> json)
      : tonHd = _parseDouble(json['ton_hd']),
        so_luong_kk_tt = _parseDouble(json['so_luong_kk_tt']),
        chenh_lech = _parseDouble(json['chenh_lech']) {
    sttRec = json['stt_rec'];
    maKho = json['ma_kho'];
    maVt = json['ma_vt'];
    maViTri = json['ma_vi_tri'];
    maLo = json['ma_lo'];
    tenKho = json['ten_kho'];
    tenVt = json['ten_vt'];
    tenVt2 = json['ten_vt2'];
    dvt = json['dvt'];
  }

  /// ✅ Convert về JSON
  Map<String, dynamic> toJson() {
    return {
      'stt_rec': sttRec,
      'ma_kho': maKho,
      'ma_vt': maVt,
      'ma_vi_tri': maViTri,
      'ma_lo': maLo,
      'ton_hd': tonHd,
      'so_luong_kk_tt': so_luong_kk_tt,
      'chenh_lech': chenh_lech,
      'ten_kho': tenKho,
      'ten_vt': tenVt,
      'ten_vt2': tenVt2,
      'dvt': dvt,
    };
  }

  /// ✅ Hàm helper ép kiểu an toàn từ dynamic → double
  static double _parseDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

class DSKhoKKResponse {
  List<DSKhoKKResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  DSKhoKKResponse({this.data, this.totalPage, this.statusCode, this.message});

  DSKhoKKResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <DSKhoKKResponseData>[];
      json['data'].forEach((v) {
        data!.add(new DSKhoKKResponseData.fromJson(v));
      });
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalPage'] = this.totalPage;
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class DSKhoKKResponseData {
  String? maKho;
  String? tenKho;

  DSKhoKKResponseData({this.maKho, this.tenKho});

  DSKhoKKResponseData.fromJson(Map<String, dynamic> json) {
    maKho = json['ma_kho'];
    tenKho = json['ten_kho'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_kho'] = this.maKho;
    data['ten_kho'] = this.tenKho;
    return data;
  }
}

class HistoryInventoryResponse {
  List<HistoryInventoryResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  HistoryInventoryResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  HistoryInventoryResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <HistoryInventoryResponseData>[];
      json['data'].forEach((v) {
        data!.add(new HistoryInventoryResponseData.fromJson(v));
      });
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalPage'] = this.totalPage;
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class HistoryInventoryResponseData {
  String? maIn;
  String? tenIn;
  String? maVt;
  String? maLo;
  String? maKho;
  String? maViTri;
  int? lineNbr;
  int? soLuongKk;
  String? dateTimeModify;
  String? sttRec;
  String? sttRec0;
  Null? userId;

  HistoryInventoryResponseData(
      {this.maIn,
        this.tenIn,
        this.maVt,
        this.maLo,
        this.maKho,
        this.maViTri,
        this.lineNbr,
        this.soLuongKk,
        this.dateTimeModify,
        this.sttRec,
        this.sttRec0,
        this.userId});

  HistoryInventoryResponseData.fromJson(Map<String, dynamic> json) {
    maIn = json['ma_in'];
    tenIn = json['ten_in'];
    maVt = json['ma_vt'];
    maLo = json['ma_lo'];
    maKho = json['ma_kho'];
    maViTri = json['ma_vi_tri'];
    lineNbr = json['line_nbr'];
    soLuongKk = json['so_luong_kk'];
    dateTimeModify = json['date_time_modify'];
    sttRec = json['stt_rec'];
    sttRec0 = json['stt_rec0'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_in'] = this.maIn;
    data['ten_in'] = this.tenIn;
    data['ma_vt'] = this.maVt;
    data['ma_lo'] = this.maLo;
    data['ma_kho'] = this.maKho;
    data['ma_vi_tri'] = this.maViTri;
    data['line_nbr'] = this.lineNbr;
    data['so_luong_kk'] = this.soLuongKk;
    data['date_time_modify'] = this.dateTimeModify;
    data['stt_rec'] = this.sttRec;
    data['stt_rec0'] = this.sttRec0;
    data['user_id'] = this.userId;
    return data;
  }
}

class ListsStockInventoryResponse {
  List<ListsStockInventoryResponseData>? data;
  int? totalPage;
  int? statusCode;
  Null? message;

  ListsStockInventoryResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  ListsStockInventoryResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListsStockInventoryResponseData>[];
      json['data'].forEach((v) {
        data!.add(new ListsStockInventoryResponseData.fromJson(v));
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

class ListsStockInventoryResponseData {
  String? maKho;
  String? tenKho;

  ListsStockInventoryResponseData({this.maKho, this.tenKho});

  ListsStockInventoryResponseData.fromJson(Map<String, dynamic> json) {
    maKho = json['ma_kho'];
    tenKho = json['ten_kho'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ma_kho'] = this.maKho;
    data['ten_kho'] = this.tenKho;
    return data;
  }
}

class ListsHistoryInventoryResponse {
  List<ItemHistoryInventoryResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  ListsHistoryInventoryResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  ListsHistoryInventoryResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ItemHistoryInventoryResponseData>[];
      json['data'].forEach((v) {
        data!.add(new ItemHistoryInventoryResponseData.fromJson(v));
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

class ItemHistoryInventoryResponseData {
  String? maIn;
  String? tenIn;
  String? maVt;
  String? tenVt;
  String? maLo;
  String? maKho;
  String? maViTri;
  int? lineNbr;
  double soLuongKk = 0;
  String? dateTimeModify;
  String? sttRec;
  int sttRec0 = 0;
  int? userId;

  ItemHistoryInventoryResponseData({
    this.maIn,
    this.tenIn,
    this.maVt,
    this.tenVt,
    this.maLo,
    this.maKho,
    this.maViTri,
    this.lineNbr,
    this.soLuongKk = 0,
    this.dateTimeModify,
    this.sttRec,
    this.sttRec0 = 0,
    this.userId,
  });

  ItemHistoryInventoryResponseData.fromJson(Map<String, dynamic> json) {
    maIn = json['ma_in'];
    tenIn = json['ten_in'];
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    maLo = json['ma_lo'];
    maKho = json['ma_kho'];
    maViTri = json['ma_vi_tri'];
    lineNbr = json['line_nbr'];
    soLuongKk = _parseDouble(json['so_luong_kk']);
    dateTimeModify = json['date_time_modify'];
    sttRec = json['stt_rec'];
    sttRec0 = _parseInt(json['stt_rec0']);
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_in': maIn,
      'ten_in': tenIn,
      'ma_vt': maVt,
      'ten_vt': tenVt,
      'ma_lo': maLo,
      'ma_kho': maKho,
      'ma_vi_tri': maViTri,
      'line_nbr': lineNbr,
      'so_luong_kk': soLuongKk,
      'date_time_modify': dateTimeModify,
      'stt_rec': sttRec,
      'stt_rec0': sttRec0,
      'user_id': userId,
    };
  }

  double _parseDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}