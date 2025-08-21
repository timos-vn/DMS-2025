class NotificationResponse {
  int? statusCode;
  List<NotificationResponseData>? data;
  int? totalPage;
  String? message;

  NotificationResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  NotificationResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <NotificationResponseData>[];
      json['data'].forEach((v) {
        data!.add(NotificationResponseData.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    totalPage = json['totalPage'];
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

class NotificationResponseData {
  int? rowNum;
  String? code;
  String? title;
  String? title2;
  String? sttRec;
  String? linkDetail;
  String? loaiDuyet;
  String? datetime0;
  String? type;
  bool? isRead;

  NotificationResponseData({
    this.rowNum,
    this.code,
    this.title,
    this.title2,
    this.sttRec,
    this.linkDetail,
    this.loaiDuyet,
    this.datetime0,
    this.type,
    this.isRead,
  });

  NotificationResponseData.fromJson(Map<String, dynamic> json) {
    rowNum = json['RowNum'];
    code = json['code'];
    title = json['title'];
    title2 = json['title2'];
    sttRec = json['stt_rec'];
    linkDetail = json['LinkDetail'];
    loaiDuyet = json['loai_duyet'];
    datetime0 = json['datetime0'];
    type = json['type'];
    isRead = json['isRead'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['RowNum'] = rowNum;
    data['code'] = code;
    data['title'] = title;
    data['title2'] = title2;
    data['stt_rec'] = sttRec;
    data['LinkDetail'] = linkDetail;
    data['loai_duyet'] = loaiDuyet;
    data['datetime0'] = datetime0;
    data['type'] = type;
    data['isRead'] = isRead;
    return data;
  }
}
