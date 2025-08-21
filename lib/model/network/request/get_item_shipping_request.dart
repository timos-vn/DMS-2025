class GetItemShippingRequest {
  String? sttRec;

  GetItemShippingRequest({this.sttRec});

  GetItemShippingRequest.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stt_rec'] = this.sttRec;
    return data;
  }
}
