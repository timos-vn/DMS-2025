class ConfirmShippingRequest {
  List<DsLine>? dsLine;
  dynamic lat;
  dynamic lng;
  int? typePayment;
  int? status;
  int? isCheckConfirm;
  String? desc;
  String? soPhieuXuat;

  ConfirmShippingRequest({this.dsLine,this.lat,this.lng,this.typePayment,this.status,this.desc,this.isCheckConfirm,this.soPhieuXuat});

  ConfirmShippingRequest.fromJson(Map<String, dynamic> json) {
    if (json['ds_line'] != null) {
      dsLine = <DsLine>[];
      json['ds_line'].forEach((v) {
        dsLine!.add(DsLine.fromJson(v));
      });
      typePayment = json['TypePayment'];
      if(lat.toString().replaceAll('null', '').isNotEmpty){
        lat = json['lat'];
      }
      if(lng.toString().replaceAll('null', '').isNotEmpty){
        lng = json['lng'];
      }
      status = json['status'];
      isCheckConfirm = json['isCheckConfirm'];
      desc = json['desc'];
      soPhieuXuat = json['SoPhieuXuat'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (dsLine != null) {
      data['ds_line'] = dsLine!.map((v) => v.toJson()).toList();
    }
    data['TypePayment'] = typePayment;
    if(lat.toString().replaceAll('null', '').isNotEmpty){
      data['lat'] = lat;
    }
    if(lng.toString().replaceAll('null', '').isNotEmpty){
      data['lng'] = lng;
    }
    data['status'] = status;
    data['isCheckConfirm'] = isCheckConfirm;
    data['desc'] = desc;
    data['SoPhieuXuat'] = soPhieuXuat;
    return data;
  }
}

class DsLine {
  String? sttRec;
  String? sttRec0;
  dynamic soLuong;

  DsLine({this.sttRec, this.sttRec0, this.soLuong});

  DsLine.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    sttRec0 = json['stt_rec0'];
    soLuong = json['so_luong'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['stt_rec0'] = sttRec0;
    data['so_luong'] = soLuong;
    return data;
  }
}
