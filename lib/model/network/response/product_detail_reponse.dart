class ProducDetailReponse {
  List<ProducDetailReponseData>? data;
  int? statusCode;
  String? message;

  ProducDetailReponse({this.data, this.statusCode, this.message});

  ProducDetailReponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ProducDetailReponseData>[];
      json['data'].forEach((v) {
        data!.add(new ProducDetailReponseData.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class ProducDetailReponseData {
  String? maVt;
  String? tenVt;
  String? nuocSx;
  String? xsize;
  String? xstyle;
  String? xcolor;
  double? length0;
 // int length0;
  double? width0;
  // int width0;
  // int weight0;
  double? weight0;
  double? volume0;
  double? height0;
 // int height0;
  double? weight2;
  double? diameter;
  double? density;
  double? volume;
  String? imageUrl;

  ProducDetailReponseData({this.maVt, this.tenVt, this.height0, this.length0, this.volume, this.weight0, this.width0, this.density, this.diameter, this.volume0, this.xsize, this.xstyle, this.xcolor, this.weight2, this.nuocSx,this.imageUrl});

  ProducDetailReponseData.fromJson(Map<String, dynamic> json) {
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    height0 = json['height0'];// == null ? 0.0 : json['height'].toDouble();
    length0 = json['length0'];// == null ? 0.0 : json['length'].toDouble();
    volume = json['volume'];// == null ? 0.0 : json['volume'].toDouble();
    weight0 = json['weight0'] ;//== null ? 0.0 : json['weight'].toDouble();
    width0 = json['width0'] ;//== null ? 0.0 : json['width'].toDouble();
    density = json['density'];// == null ? 0.0 : json['density'].toDouble();
    diameter = json['diameter'] ;//== null ? 0.0 : json['diameter'].toDouble();
    // height0 = json['height0'] ;//== null ? 0.0 : json['height0'].toDouble();
    // length0 = json['length0'] ;//== null ? 0.0 : json['length0'].toDouble();
    volume0 = json['volume0'] ;//== null ? 0.0 : json['volume0'].toDouble();
    // weight0 = json['weight0'] ;//== null ? 0.0 : json['weight0'].toDouble();
    // width0 = json['width0'] ;//== null ? 0.0 : json['width0'].toDouble();
    weight2 = json['weight2'] ;//== null ? 0.0 : json['weight2'].toDouble();
    xsize = json['xsize'];
    xstyle = json['xstyle'];
    xcolor = json['xcolor'];
    nuocSx = json['nuoc_sx'];
    imageUrl = json['ImageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ma_vt'] = this.maVt;
    data['ten_vt'] = this.tenVt;
    data['height0'] = this.height0;
    data['length0'] = this.length0;
    data['volume'] = this.volume;
    data['weight0'] = this.weight0;
    data['width0'] = this.width0;
    data['density'] = this.density;
    data['diameter'] = this.diameter;
    // data['height0'] = this.height0;
    // data['length0'] = this.length0;
    data['volume0'] = this.volume0;
    // data['weight0'] = this.weight0;
    // data['width0'] = this.width0;
    data['xsize'] = this.xsize;
    data['xstyle'] = this.xstyle;
    data['xcolor'] = this.xcolor;
    data['weight2'] = this.weight2;
    data['nuoc_sx'] = this.nuocSx;
    data['ImageUrl'] = this.imageUrl;
    return data;
  }
}