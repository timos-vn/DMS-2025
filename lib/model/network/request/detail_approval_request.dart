class ListApprovalDetailRequest {
  String? loaiDuyet;
  String? status;
  String? option;
  int? pageIndex;
  int? pageCount;

  ListApprovalDetailRequest(
      {this.loaiDuyet,
        this.status,
        this.option,
        this.pageIndex,
        this.pageCount});

  ListApprovalDetailRequest.fromJson(Map<String, dynamic> json) {
    loaiDuyet = json['loai_duyet'];
    status = json['status'];
    option = json['option'];
    pageIndex = json['page_Index'];
    pageCount = json['page_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['loai_duyet'] = this.loaiDuyet;
    data['status'] = this.status;
    data['option'] = this.option;
    data['page_Index'] = this.pageIndex;
    data['page_count'] = this.pageCount;
    return data;
  }
}