class AcceptApprovalRequest {
  String? loaiDuyet;
  String? action;
  String? sttRec;
  String? note;

  AcceptApprovalRequest({this.loaiDuyet, this.action, this.sttRec, this.note});

  AcceptApprovalRequest.fromJson(Map<String, dynamic> json) {
    loaiDuyet = json['loai_duyet'];
    action = json['action'];
    sttRec = json['stt_rec'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['loai_duyet'] = this.loaiDuyet;
    data['action'] = this.action;
    data['stt_rec'] = this.sttRec;
    data['note'] = this.note;
    return data;
  }
}