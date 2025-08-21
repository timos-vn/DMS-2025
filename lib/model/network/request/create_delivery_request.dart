class CreateDeliveryRequest {
  CreateDeliveryRequestData? data;

  CreateDeliveryRequest({this.data});

  CreateDeliveryRequest.fromJson(Map<String, dynamic> json) {
    data = json['Data'] != null ? CreateDeliveryRequestData.fromJson(json['Data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['Data'] = this.data!.toJson();
    }
    return data;
  }
}

class CreateDeliveryRequestData {
  String? sttRec;
  String? licensePlates;
  String? codeTransfer;

  CreateDeliveryRequestData({this.sttRec, this.licensePlates, this.codeTransfer});

  CreateDeliveryRequestData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    licensePlates = json['licensePlates'];
    codeTransfer = json['codeTransfer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['licensePlates'] = licensePlates;
    data['codeTransfer'] = codeTransfer;
    return data;
  }
}

