import '../response/get_item_holder_detail_response.dart';

class CreateItemHolderRequest {
  CreateItemHolderRequestData? data;

  CreateItemHolderRequest({this.data});

  CreateItemHolderRequest.fromJson(Map<String, dynamic> json) {
    data = json['Data'] != null ? CreateItemHolderRequestData.fromJson(json['Data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['Data'] = this.data!.toJson();
    }
    return data;
  }
}

class CreateItemHolderRequestData {
  String? sttRec;
  String? comment;
  String? ngayHetHan;
  List<ListItemHolderDetailResponse>? listItem;

  CreateItemHolderRequestData({this.sttRec, this.comment, this.ngayHetHan, this.listItem});

  CreateItemHolderRequestData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    comment = json['comment'];
    ngayHetHan = json['ngay_het_han'];
    if (json['listItem'] != null) {
      listItem = <ListItemHolderDetailResponse>[];
      json['listItem'].forEach((v) {
        listItem!.add(ListItemHolderDetailResponse.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['comment'] = comment;
    data['ngay_het_han'] = ngayHetHan;
    if (listItem != null) {
      data['listItem'] = listItem!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}