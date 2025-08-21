class EntityClass {
  String? key;
  String? values;

  EntityClass({this.key, this.values});
}

class ListObjectJson {
  String? key;
  String? values;

  ListObjectJson({this.key, this.values});

  ListObjectJson.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    values = json['values'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['values'] = values;
    return data;
  }
}

class ObjectDiscount {
  String itemProduct;
  String itemDiscountNew;
  String itemDiscountOld;

  ObjectDiscount({required this.itemProduct,required this.itemDiscountNew,required this.itemDiscountOld});
}