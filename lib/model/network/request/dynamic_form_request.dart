class ViewDetailDynamicFormRequest {
  String? variable;
  String? type;
  String? value;

  ViewDetailDynamicFormRequest({this.variable, this.type, this.value});

  ViewDetailDynamicFormRequest.fromJson(Map<String, dynamic> json) {
    variable = json['variable'];
    type = json['type'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variable'] = variable;
    data['type'] = type;
    data['value'] = value;
    return data;
  }
}