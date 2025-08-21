/// Một item chi tiết cho API
class InventoryRequestItem {
  final String sttRec;
  final String ngayCt;
  final String maKho;
  final String maViTri;
  final String maVt;
  final String dvt;
  final String maLo;
  final double soLuong;
  final String ghiChu;
  final String datetime0;
  final String datetime2;

  InventoryRequestItem({
    required this.sttRec,
    required this.ngayCt,
    required this.maKho,
    required this.maViTri,
    required this.maVt,
    required this.dvt,
    required this.maLo,
    required this.soLuong,
    required this.ghiChu,
    required this.datetime0,
    required this.datetime2,
  });

  Map<String, dynamic> toJson() {
    return {
      'stt_rec': sttRec,
      'ngay_ct': ngayCt,
      'ma_kho': maKho,
      'ma_vi_tri': maViTri,
      'ma_vt': maVt,
      'dvt': dvt,
      'ma_lo': maLo,
      'so_luong': soLuong,
      'ghi_chu': ghiChu,
      'datetime0': datetime0,
      'datetime2': datetime2,
    };
  }
}

/// Payload tổng gửi API
class InventoryRequest {
  final String sttRec;
  final String namYc;
  final List<InventoryRequestItem> data;

  InventoryRequest({
    required this.sttRec,
    required this.namYc,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'stt_rec': sttRec,
      'nam_yc': namYc,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class HistoryRequestItem {
  final String sttRec;
  final int sttRec0;
  final String maIn;
  final String tenIn;
  final String maVt;
  final String tenVt;
  final String maLo;
  final String maKho;
  final String maViTri;
  final String dateTimeModify;
  final double soLuongKk;
  final int userId;

  HistoryRequestItem({
    required this.sttRec,
    required this.sttRec0,
    required this.maIn,
    required this.tenIn,
    required this.maVt,
    required this.tenVt,
    required this.maLo,
    required this.maKho,
    required this.maViTri,
    required this.dateTimeModify,
    required this.soLuongKk,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'stt_rec': sttRec,
      'stt_rec0': sttRec0,
      'ma_in': maIn,
      'ten_in': tenIn,
      'ma_vt': maVt,
      'ten_vt': tenVt,
      'ma_lo': maLo,
      'ma_kho': maKho,
      'ma_vi_tri': maViTri,
      'date_time_modify': dateTimeModify,
      'so_luong_kk': soLuongKk,
      'user_id': userId,
    };
  }
}

class HistoryRequest {
  final String sttRec;
  final String ngayYc;
  final List<HistoryRequestItem> data;

  HistoryRequest({
    required this.sttRec,
    required this.ngayYc,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'stt_rec': sttRec,
      'ngay_yc': ngayYc,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

