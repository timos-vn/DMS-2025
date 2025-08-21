class ListVVHDResponse {
  List<ListVv>? listVv;
  List<ListHd>? listHd;
  int? statusCode;
  String? message;

  ListVVHDResponse({this.listVv, this.listHd, this.statusCode, this.message});

  ListVVHDResponse.fromJson(Map<String, dynamic> json) {
    if (json['list_vv'] != null) {
      listVv = <ListVv>[];
      json['list_vv'].forEach((v) {
        listVv!.add( ListVv.fromJson(v));
      });
    }
    if (json['list_hd'] != null) {
      listHd = <ListHd>[];
      json['list_hd'].forEach((v) {
        listHd!.add(new ListHd.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listVv != null) {
      data['list_vv'] = this.listVv!.map((v) => v.toJson()).toList();
    }
    if (this.listHd != null) {
      data['list_hd'] = this.listHd!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class ListVv {
  String? maVv;
  String? tenVv;
  String? maDmhd;

  ListVv({this.maVv, this.tenVv, this.maDmhd});

  ListVv.fromJson(Map<String, dynamic> json) {
    maVv = json['ma_vv'];
    tenVv = json['ten_vv'];
    maDmhd = json['ma_dmhd'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ma_vv'] = this.maVv;
    data['ten_vv'] = this.tenVv;
    data['ma_dmhd'] = this.maDmhd;
    return data;
  }
}

class ListHd {
  String? maHd;
  String? tenHd;

  ListHd({this.maHd, this.tenHd});

  ListHd.fromJson(Map<String, dynamic> json) {
    maHd = json['ma_hd'];
    tenHd = json['ten_hd'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ma_hd'] = this.maHd;
    data['ten_hd'] = this.tenHd;
    return data;
  }
}

