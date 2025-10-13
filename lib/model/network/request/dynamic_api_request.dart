class DynamicApiRequest {
  String? store;
  Map<String, dynamic>? param;
  Map<String, dynamic>? data;
  List<String>? resultSetNames;

  DynamicApiRequest({
    this.store,
    this.param,
    this.data,
    this.resultSetNames,
  });

  DynamicApiRequest.fromJson(Map<String, dynamic> json) {
    store = json['store'];
    param = json['param'] != null ? Map<String, dynamic>.from(json['param']) : null;
    data = json['data'] != null ? Map<String, dynamic>.from(json['data']) : null;
    resultSetNames = json['resultSetNames'] != null ? List<String>.from(json['resultSetNames']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['store'] = store;
    data['param'] = param;
    data['data'] = this.data;
    data['resultSetNames'] = resultSetNames;
    return data;
  }
}
