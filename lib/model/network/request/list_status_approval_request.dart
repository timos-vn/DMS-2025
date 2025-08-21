class ListStatusApprovalRequest {
  String? loaiDuyet;
  int? pageIndex;
  int? pageCount;

  ListStatusApprovalRequest({this.loaiDuyet, this.pageIndex, this.pageCount});

  ListStatusApprovalRequest.fromJson(Map<String, dynamic> json) {
    loaiDuyet = json['loai_duyet'];
    pageIndex = json['page_Index'];
    pageCount = json['page_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['loai_duyet'] = this.loaiDuyet;
    data['page_Index'] = this.pageIndex;
    data['page_count'] = this.pageCount;
    return data;
  }
}

