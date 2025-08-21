class ProposalResponse {
  ProposalData? data;
  int? totalPage;
  int? statusCode;
  String? message;

  ProposalResponse({this.data, this.totalPage, this.statusCode, this.message});

  ProposalResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = ProposalData.fromJson(json['data']);
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['totalPage'] = totalPage;
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ProposalData {
  GridDefine? gridDefine;
  GridDataDetails? gridData;

  ProposalData({this.gridDefine, this.gridData});

  ProposalData.fromJson(Map<String, dynamic> json) {
    gridDefine = json['gridDefine'] != null
        ? GridDefine.fromJson(json['gridDefine'])
        : null;
    gridData = json['gridData'] != null
        ? GridDataDetails.fromJson(json['gridData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (gridDefine != null) {
      data['gridDefine'] = gridDefine!.toJson();
    }
    if (gridData != null) {
      data['gridData'] = gridData!.toJson();
    }
    return data;
  }
}

class GridDefine {
  String? controller;
  String? keys;
  List<Fields>? fields;

  GridDefine({this.controller, this.keys, this.fields});

  GridDefine.fromJson(Map<String, dynamic> json) {
    controller = json['controller'];
    keys = json['keys'];
    if (json['fields'] != null) {
      fields = <Fields>[];
      json['fields'].forEach((v) {
        fields!.add(Fields.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['controller'] = controller;
    data['keys'] = keys;
    if (fields != null) {
      data['fields'] = fields!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Fields {
  String? name;
  String? type;
  String? style;
  String? header;

  Fields({this.name, this.type, this.style, this.header});

  Fields.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    style = json['style'];
    header = json['header'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    data['style'] = style;
    data['header'] = header;
    return data;
  }
}

class GridDataDetails {
  List<GridData>? data;
  int? totals;

  GridDataDetails({this.data, this.totals});

  GridDataDetails.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <GridData>[];
      json['data'].forEach((v) {
        data!.add(GridData.fromJson(v));
      });
    }
    totals = json['totals'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totals'] = totals;
    return data;
  }
}

class GridData {
  int? id;
  String? nguoiDeXuat;
  String? tuNgay;
  int? status;

  GridData({this.id, this.nguoiDeXuat, this.tuNgay, this.status});

  GridData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nguoiDeXuat = json['nguoi_de_xuat'];
    tuNgay = json['tu_ngay'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nguoi_de_xuat'] = nguoiDeXuat;
    data['tu_ngay'] = tuNgay;
    data['status'] = status;
    return data;
  }
}
