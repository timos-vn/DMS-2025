class GetInformationItemFromBarResponse {
  InformationProduction? informationProduction;
  List<InformationProduction>? listItem;
  int? statusCode;
  String? message;

  GetInformationItemFromBarResponse(
      {this.informationProduction, this.listItem, this.statusCode, this.message});

  GetInformationItemFromBarResponse.fromJson(Map<String, dynamic> json) {
    // Try to get informationProduction first (old format)
    informationProduction = json['informationProduction'] != null
        ? InformationProduction.fromJson(json['informationProduction'])
        : null;
    
    // If informationProduction is null, try to get from listItem (new format)
    if (informationProduction == null && json['listItem'] != null) {
      List<dynamic> listItemData = json['listItem'];
      if (listItemData.isNotEmpty) {
        // Take the first item from listItem
        informationProduction = InformationProduction.fromJson(listItemData[0]);
      }
    }
    
    // Also store the full listItem for other uses
    if (json['listItem'] != null) {
      listItem = <InformationProduction>[];
      json['listItem'].forEach((v) {
        listItem!.add(InformationProduction.fromJson(v));
      });
    }
    
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (informationProduction != null) {
      data['informationProduction'] = informationProduction!.toJson();
    }
    if (listItem != null) {
      data['listItem'] = listItem!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class InformationProduction {
  String? maIn;
  String? maVt;
  String? tenVt;
  double? soLuong;
  String? hsd;
  String? nsx;
  String? maLo;
  String? maViTri;
  String? maPallet;

  InformationProduction({this.maIn, this.maVt, this.tenVt, this.soLuong, this.hsd, this.nsx, this.maLo, this.maViTri, this.maPallet});

  InformationProduction.fromJson(Map<String, dynamic> json) {
    maIn = json['ma_in'];
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    soLuong = json['so_luong'];
    hsd = json['hsd'];
    nsx = json['nsx'];
    maLo = json['ma_lo'];
    maViTri = json['ma_vi_tri'];
    maPallet = json['ma_pallet'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_in'] = maIn;
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;
    data['so_luong'] = soLuong;
    data['hsd'] = hsd;
    data['nsx'] = nsx;
    data['ma_lo'] = maLo;
    data['ma_vi_tri'] = maViTri;
    data['ma_pallet'] = maPallet;
    return data;
  }
}

