class ManagerCustomerRequestBody {
  int? type;
  int? pageIndex;
  String? searchValue;
  String? typeName;

  ManagerCustomerRequestBody({this.type,this.pageIndex, this.searchValue,this.typeName});

  ManagerCustomerRequestBody.fromJson(Map<String, dynamic> json) {
    type = json['Type'];
    pageIndex = json['PageIndex'];
    searchValue = json['SearchValue'];
    typeName = json['TypeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if(type != null){
      data['Type'] = type;
    }
    if(pageIndex != null){
      data['PageIndex'] = pageIndex;
    }
    if(searchValue != null){
      data['SearchValue'] = searchValue;
    }
    data['TypeName'] = typeName;
    return data;
  }
}