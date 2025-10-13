class UpdateItemBarCodeRequest {
  UpdateItemBarCodeRequestData? data;

  UpdateItemBarCodeRequest({this.data});

  UpdateItemBarCodeRequest.fromJson(Map<String, dynamic> json) {
    data = json['Data'] != null ? UpdateItemBarCodeRequestData.fromJson(json['Data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['Data'] = this.data!.toJson();
    }
    return data;
  }
}

class UpdateItemBarCodeRequestData {
  String? sttRec;
  int? action;
  List<UpdateItemBarCodeRequestDetail>? detail;
  List<UpdateItemBarCodeRequestDetail>? listConfirm; // ✅ Thêm listConfirm từ SSE-Scanner

  UpdateItemBarCodeRequestData({
    this.sttRec,
    this.detail,
    this.action,
    this.listConfirm, // ✅ Thêm listConfirm parameter
  });

  UpdateItemBarCodeRequestData.fromJson(Map<String, dynamic> json) {
    sttRec = json["stt_rec"];
    action = json["action"];
    if (json['Detail'] != null) {
      detail = <UpdateItemBarCodeRequestDetail>[];
      json['Detail'].forEach((v) {
        detail!.add(UpdateItemBarCodeRequestDetail.fromJson(v));
      });
    }
    // ✅ Parse listConfirm từ JSON
    if (json['listConfirm'] != null) {
      listConfirm = <UpdateItemBarCodeRequestDetail>[];
      json['listConfirm'].forEach((v) {
        listConfirm!.add(UpdateItemBarCodeRequestDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['action'] = action;
    if (detail != null) {
      data['Detail'] = detail!.map((v) => v.toJson()).toList();
    }
    // ✅ Thêm listConfirm vào JSON output
    if (listConfirm != null) {
      data['listConfirm'] = listConfirm!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UpdateItemBarCodeRequestDetail {
  String? sttRec;
  String? sttRec0;      // ✅ Thêm sttRec0 từ SSE-Scanner
  int? indexItem;
  String? maVt;
  String? barcode;
  String? maKho;
  String? maLo;
  String? soCan;
  String? hsd;
  // ✅ Thêm các trường từ SSE-Scanner
  String? tenVt;        // Tên vật tư
  String? dvt;          // Đơn vị tính
  String? pallet;       // Pallet
  String? maViTri;      // Mã vị trí
  String? nsx;          // Ngày sản xuất
  String? timeScan;     // Thời gian scan
  double? soLuong;      // Số lượng
  bool? isCallAPI;      // Đã gọi API

  UpdateItemBarCodeRequestDetail({
    this.sttRec,
    this.sttRec0,        // ✅ Thêm sttRec0 parameter
    this.maVt, 
    this.barcode, 
    this.maKho, 
    this.maLo, 
    this.soCan, 
    this.hsd, 
    this.indexItem,
    // ✅ Thêm parameters
    this.tenVt,
    this.dvt,
    this.pallet,
    this.maViTri,
    this.nsx,
    this.timeScan,
    this.soLuong,
    this.isCallAPI,
  });

  UpdateItemBarCodeRequestDetail.fromJson(Map<String, dynamic> json) {
    sttRec = json['sttRec']; 
    sttRec0 = json['sttRec0']; // ✅ Parse sttRec0
    maVt = json['ma_vt']; 
    indexItem = json['index_item'];
    barcode = json['barcode'];
    maKho = json['ma_kho'];
    maLo = json['ma_lo'];
    soCan = json['so_can'];
    hsd = json['hsd'];
    // ✅ Parse các trường mới từ SSE-Scanner
    tenVt = json['ten_vt'];
    dvt = json['dvt'];
    pallet = json['pallet'];
    maViTri = json['ma_vi_tri'];
    nsx = json['nsx'];
    timeScan = json['time_scan'];
    soLuong = json['so_luong']?.toDouble();
    isCallAPI = json['is_call_api'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_vt'] = maVt;  
    data['sttRec'] = sttRec; 
    data['sttRec0'] = sttRec0; // ✅ Serialize sttRec0
    data['index_item'] = indexItem;
    data['barcode'] = barcode;
    data['ma_kho'] = maKho;
    data['ma_lo'] = maLo;
    data['so_can'] = soCan;
    data['hsd'] = hsd;
    // ✅ Serialize các trường mới từ SSE-Scanner
    data['ten_vt'] = tenVt;
    data['dvt'] = dvt;
    data['pallet'] = pallet;
    data['ma_vi_tri'] = maViTri;
    data['nsx'] = nsx;
    data['time_scan'] = timeScan;
    data['so_luong'] = soLuong;
    data['is_call_api'] = isCallAPI;
    return data;
  }
}

