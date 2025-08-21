class DetailStageStatisticResponse {
  List<DetailStageStatisticResponseData>? data;
  int? statusCode;
  String? message;

  DetailStageStatisticResponse({this.data, this.statusCode, this.message});

  DetailStageStatisticResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <DetailStageStatisticResponseData>[];
      json['data'].forEach((v) {
        data?.add(new DetailStageStatisticResponseData.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data?.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class DetailStageStatisticResponseData {
  String? maVt;
  String? soLsx;
  double? soLuongDonHang;
  double? slSongTt;
  double? slSongCp;
  double? slSongTd;
  double? slSongDat;
  double? slSongPp;
  double? slInTt;
  double? slInHong;
  double? slInSong;
  double? slInDat;
  double? slInCsx;
  double? slCbTt;
  double? slCbIn;
  double? slCbSong;
  double? slCbBx;
  double? slCbDat;
  double? slCbCsx;
  double? slLvTt;
  double? slLvIn;
  double? slLvSong;
  double? slLvBx;
  double? slLvDat;
  double? slLvCsx;
  double? slHtTt;
  double? slHtIn;
  double? slHtSong;
  double? slHtCb;
  double? slHtHt;
  double? slHtDat;
  double? slHtCl;
  String? maBp;
  String? maKho;
  String? tenVt;

  DetailStageStatisticResponseData(
      {this.maVt,
        this.soLsx,
        this.soLuongDonHang,
        this.slSongTt,
        this.slSongCp,
        this.slSongTd,
        this.slSongDat,
        this.slSongPp,
        this.slInTt,
        this.slInHong,
        this.slInSong,
        this.slInDat,
        this.slInCsx,
        this.slCbTt,
        this.slCbIn,
        this.slCbSong,
        this.slCbBx,
        this.slCbDat,
        this.slCbCsx,
        this.slLvTt,
        this.slLvIn,
        this.slLvSong,
        this.slLvBx,
        this.slLvDat,
        this.slLvCsx,
        this.slHtTt,
        this.slHtIn,
        this.slHtSong,
        this.slHtCb,
        this.slHtHt,
        this.slHtDat,
        this.slHtCl,
        this.maBp,
        this.maKho,
        this.tenVt});

  DetailStageStatisticResponseData.fromJson(Map<String, dynamic> json) {
    maVt = json['ma_vt'];
    soLsx = json['so_lsx'];
    soLuongDonHang = json['sl_td3'];
    slSongTt = json['sl_song_tt'];
    slSongCp = json['sl_song_cp'];
    slSongTd = json['sl_song_td'];
    slSongDat = json['sl_song_dat'];
    slSongPp = json['sl_song_pp'];
    slInTt = json['sl_in_tt'];
    slInHong = json['sl_in_hong'];
    slInSong = json['sl_in_song'];
    slInDat = json['sl_in_dat'];
    slInCsx = json['sl_in_csx'];
    slCbTt = json['sl_cb_tt'];
    slCbIn = json['sl_cb_in'];
    slCbSong = json['sl_cb_song'];
    slCbBx = json['sl_cb_bx'];
    slCbDat = json['sl_cb_dat'];
    slCbCsx = json['sl_cb_csx'];
    slLvTt = json['sl_lv_tt'];
    slLvIn = json['sl_lv_in'];
    slLvSong = json['sl_lv_song'];
    slLvBx = json['sl_lv_bx'];
    slLvDat = json['sl_lv_dat'];
    slLvCsx = json['sl_lv_csx'];
    slHtTt = json['sl_ht_tt'];
    slHtIn = json['sl_ht_in'];
    slHtSong = json['sl_ht_song'];
    slHtCb = json['sl_ht_cb'];
    slHtHt = json['sl_ht_ht'];
    slHtDat = json['sl_ht_dat'];
    slHtCl = json['sl_ht_cl'];
    maBp = json['ma_bp'];
    maKho = json['ma_kho'];
    tenVt = json['ten_vt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ma_vt'] = this.maVt;
    data['sl_lsx'] = this.soLsx;
    data['sl_td3'] = this.soLuongDonHang;
    data['sl_song_tt'] = this.slSongTt;
    data['sl_song_cp'] = this.slSongCp;
    data['sl_song_td'] = this.slSongTd;
    data['sl_song_dat'] = this.slSongDat;
    data['sl_song_pp'] = this.slSongPp;
    data['sl_in_tt'] = this.slInTt;
    data['sl_in_hong'] = this.slInHong;
    data['sl_in_song'] = this.slInSong;
    data['sl_in_dat'] = this.slInDat;
    data['sl_in_csx'] = this.slInCsx;
    data['sl_cb_tt'] = this.slCbTt;
    data['sl_cb_in'] = this.slCbIn;
    data['sl_cb_song'] = this.slCbSong;
    data['sl_cb_bx'] = this.slCbBx;
    data['sl_cb_dat'] = this.slCbDat;
    data['sl_cb_csx'] = this.slCbCsx;
    data['sl_lv_tt'] = this.slLvTt;
    data['sl_lv_in'] = this.slLvIn;
    data['sl_lv_song'] = this.slLvSong;
    data['sl_lv_bx'] = this.slLvBx;
    data['sl_lv_dat'] = this.slLvDat;
    data['sl_lv_csx'] = this.slLvCsx;
    data['sl_ht_tt'] = this.slHtTt;
    data['sl_ht_in'] = this.slHtIn;
    data['sl_ht_song'] = this.slHtSong;
    data['sl_ht_cb'] = this.slHtCb;
    data['sl_ht_ht'] = this.slHtHt;
    data['sl_ht_dat'] = this.slHtDat;
    data['sl_ht_cl'] = this.slHtCl;
    data['ma_bp'] = this.maBp;
    data['ma_kho'] = this.maKho;
    data['ten_vt'] = this.tenVt;
    return data;
  }
}