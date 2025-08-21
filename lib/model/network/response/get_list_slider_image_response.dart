class GetListSliderImageResponse {
  List<ListSliderImage>? listSliderImageActive;
  List<ListSliderImage>? listSliderImageDisable;
  int? statusCode;
  String? message;

  GetListSliderImageResponse(
      {this.listSliderImageActive,
        this.listSliderImageDisable,
        this.statusCode,
        this.message});

  GetListSliderImageResponse.fromJson(Map<String, dynamic> json) {
    if (json['listSliderImageActive'] != null) {
      listSliderImageActive = <ListSliderImage>[];
      json['listSliderImageActive'].forEach((v) {
        listSliderImageActive!.add(ListSliderImage.fromJson(v));
      });
    }
    if (json['listSliderImageDisable'] != null) {
      listSliderImageDisable = <ListSliderImage>[];
      json['listSliderImageDisable'].forEach((v) {
        listSliderImageDisable!.add(ListSliderImage.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listSliderImageActive != null) {
      data['listSliderImageActive'] =
          listSliderImageActive!.map((v) => v.toJson()).toList();
    }
    if (listSliderImageDisable != null) {
      data['listSliderImageDisable'] =
          listSliderImageDisable!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ListSliderImage {
  int? id;
  String? link;
  String? hyperlink;
  String? description;
  String? status;
  String? maDvcs;

  ListSliderImage(
      {this.id,
        this.link,
        this.hyperlink,
        this.description,
        this.status,
        this.maDvcs});

  ListSliderImage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    link = json['link'];
    hyperlink = json['hyperlink'];
    description = json['description'];
    status = json['status'];
    maDvcs = json['ma_dvcs'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['link'] = link;
    data['hyperlink'] = hyperlink;
    data['description'] = description;
    data['status'] = status;
    data['ma_dvcs'] = maDvcs;
    return data;
  }
}
class ListMember {
  int? userId;
  bool? type;

  ListMember(
      {this.userId,
        this.type});

  ListMember.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['type'] = type;
    return data;
  }
}