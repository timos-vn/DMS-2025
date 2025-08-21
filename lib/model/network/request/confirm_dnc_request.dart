class ConfirmDNCRequest {
  String? action;
  String? capDuyet;
  String? sttRec;

  ConfirmDNCRequest({this.action, this.capDuyet, this.sttRec});

  ConfirmDNCRequest.fromJson(Map<String, dynamic> json) {
    action = json['action'];
    capDuyet = json['cap_duyet'];
    sttRec = json['stt_rec'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['action'] = this.action;
    data['cap_duyet'] = this.capDuyet;
    data['stt_rec'] = this.sttRec;
    return data;
  }
}