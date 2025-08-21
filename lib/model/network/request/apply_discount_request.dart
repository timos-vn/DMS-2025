class ApplyDiscountRequest {
  String? listCKVT;
  String? listPromo;
  String? listItem;
  String? listQty;
  String? listPrice;
  String? listMoney;
  String? warehouseId;
  String? customerId;

  ApplyDiscountRequest(
      {this.listCKVT,this.listPromo,
        this.listItem,
        this.listQty,
        this.listPrice,
        this.listMoney,
        this.warehouseId,
        this.customerId});

  ApplyDiscountRequest.fromJson(Map<String, dynamic> json) {
    listCKVT = json['List_ckvt'];
    listPromo = json['List_promo'];
    listItem = json['List_item'];
    listQty = json['List_qty'];
    listPrice = json['List_price'];
    listMoney = json['List_money'];
    warehouseId = json['Warehouse_id'];
    customerId = json['Customer_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['List_ckvt'] = listCKVT;
    data['List_promo'] = listPromo;
    data['List_item'] = listItem;
    data['List_qty'] = listQty;
    data['List_price'] = listPrice;
    data['List_money'] = listMoney;
    data['Warehouse_id'] = warehouseId;
    data['Customer_id'] = customerId;
    return data;
  }
}