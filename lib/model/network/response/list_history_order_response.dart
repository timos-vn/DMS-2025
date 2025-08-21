class ListHistoryOrderResponse {
  List<HeaderDesc>? headerDesc;
  List<Values>? values;
  int? pageIndex;
  int? statusCode;
  String? message;

  ListHistoryOrderResponse(
      {this.headerDesc,
        this.values,
        this.pageIndex,
        this.statusCode,
        this.message});

  ListHistoryOrderResponse.fromJson(Map<String, dynamic> json) {
    if (json['headerDesc'] != null) {
      headerDesc = <HeaderDesc>[];
      json['headerDesc'].forEach((v) {
        headerDesc?.add(new HeaderDesc.fromJson(v));
      });
    }
    if (json['values'] != null) {
      values = <Values>[];
      json['values'].forEach((v) {
        values?.add(new Values.fromJson(v));
      });
    }
    pageIndex = json['pageIndex'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.headerDesc != null) {
      data['headerDesc'] = this.headerDesc?.map((v) => v.toJson()).toList();
    }
    if (this.values != null) {
      data['values'] = this.values?.map((v) => v.toJson()).toList();
    }
    data['pageIndex'] = this.pageIndex;
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class HeaderDesc {
  String? field;
  String? name;
  String? name2;
  int? type;
  String? format;
  int? colWidth;

  HeaderDesc(
      {this.field,
        this.name,
        this.name2,
        this.type,
        this.format,
        this.colWidth});

  HeaderDesc.fromJson(Map<String, dynamic> json) {
    field = json['field'];
    name = json['name'];
    name2 = json['name2'];
    type = json['type'];
    format = json['format'];
    colWidth = json['colWidth'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['field'] = this.field;
    data['name'] = this.name;
    data['name2'] = this.name2;
    data['type'] = this.type;
    data['format'] = this.format;
    data['colWidth'] = this.colWidth;
    return data;
  }
}

class Values {
  String? sttRec;
  String? maDvcs;
  String? ngayCt;
  String? soCt;
  String? maKh;
  String? tenKh;
  double? tTtNt;
  String? maNt;
  String? maCt;
  String? status;
  String? userId0;
  String? userId2;
  String? datetime0;
  String? datetime2;
  String? statusname;
  String? comment;
  String? comment2;
  String? deptId;
  String? hash;
  String? diaChiKH;
  String? dienThoaiKH;
  String? codeStore;
  String? nameStore; String? dateEstDelivery;


  Values(
      {this.sttRec,
        this.maDvcs,
        this.ngayCt,
        this.soCt,
        this.maKh,
        this.tenKh,
        this.tTtNt,
        this.maNt,
        this.maCt,
        this.status,
        this.userId0,
        this.userId2,
        this.datetime0,
        this.datetime2,
        this.statusname,
        this.comment,
        this.comment2,
        this.deptId,
        this.hash,this.dienThoaiKH,this.diaChiKH,this.codeStore,this.nameStore,this.dateEstDelivery});

  Values.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    maDvcs = json['ma_dvcs'];
    ngayCt = json['ngay_ct'];
    soCt = json['so_ct'];
    maKh = json['ma_kh'];
    tenKh = json['ten_kh'];
    tTtNt = json['t_tien_nt2'];
    maNt = json['ma_nt'];
    maCt = json['ma_ct'];
    status = json['status'];
    userId0 = json['user_id0'];
    userId2 = json['user_id2'];
    datetime0 = json['datetime0'];
    datetime2 = json['datetime2'];
    statusname = json['statusname'];
    comment = json['comment'];
    comment2 = json['comment2'];
    deptId = json['dept_id'];
    hash = json['Hash'];
    dienThoaiKH = json['dien_thoai'];
    diaChiKH = json['dia_chi'];
    codeStore = json['dept_id'];
    nameStore = json['dept_name'];dateEstDelivery = json['dateEstDelivery'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['stt_rec'] = this.sttRec;
    data['ma_dvcs'] = this.maDvcs;
    data['ngay_ct'] = this.ngayCt;
    data['so_ct'] = this.soCt;
    data['ma_kh'] = this.maKh;
    data['ten_kh'] = this.tenKh;
    data['t_tien_nt2'] = this.tTtNt;
    data['ma_nt'] = this.maNt;
    data['ma_ct'] = this.maCt;
    data['status'] = this.status;
    data['user_id0'] = userId0;
    data['user_id2'] = userId2;
    data['datetime0'] = datetime0;
    data['datetime2'] = datetime2;
    data['statusname'] = statusname;
    data['comment'] = comment;
    data['comment2'] = comment2;
    data['dept_id'] = deptId;
    data['Hash'] = hash;
    data['dia_chi'] = diaChiKH;
    data['dien_thoai'] = dienThoaiKH;
    data['dept_id'] = codeStore;
    data['dept_name'] = nameStore;data['dateEstDelivery'] = dateEstDelivery;
    return data;
  }
}

