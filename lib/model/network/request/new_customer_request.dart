class NewCustomerRequest {
  String? customerCode;
  String? customerName;
  String? customerName2;
  int? gender;
  String? phone;
  String? address;
  String? email;
  String? birthday;

  NewCustomerRequest({this.customerCode,this.customerName,this.customerName2, this.gender,this.phone,this.address,this.email,this.birthday});

  NewCustomerRequest.fromJson(Map<String, dynamic> json) {
    customerCode = json['CustomerCode'];
    customerName = json['CustomerName'];
    customerName2 = json['CustomerName2'];

    gender = json['Gender'];
    phone = json['Phone'];
    address = json['Address'];
    email = json['Email'];
    birthday = json['Birthday'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if(customerCode != null){
      data['CustomerCode'] = customerCode;
    }
    if(customerName != null){
      data['CustomerName'] = customerName;
    }
    if(customerName2 != null){
      data['CustomerName2'] = customerName2;
    }
    if(gender != null){
      data['Gender'] = gender;
    }
    if(phone != null){
      data['Phone'] = phone;
    }
    if(address != null){
      data['Address'] = address;
    }
    if(email != null){
      data['Email'] = email;
    }
    if(birthday != null){
      data['Birthday'] = birthday;
    }
    return data;
  }
}