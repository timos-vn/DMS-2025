class ReportLocationRequest {
  String? datetime;
  String? customer;
  String? latLong;
  String? location;
  String? description;
  String? note;
  String? image;
  String? namePath;
  String? nameFile;

  ReportLocationRequest(
      {
        this.datetime,
        this.customer,
        this.latLong,
        this.location,
        this.description,
        this.note,
        this.image,
        this.namePath,
        this.nameFile,
      });

  ReportLocationRequest.fromJson(Map<String, dynamic> json) {
    datetime = json['datetime'];
    customer = json['customer'];
    latLong = json['latLong'];
    location = json['location'];
    description = json['description'];
    note = json['note'];
    image = json['image'];
    namePath = json['namePath'];
    nameFile = json['nameFile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['namePath'] = namePath;
    data['nameFile'] = nameFile;
    if(datetime != null){
      data['datetime'] = datetime;
    }
    if(customer != null){
      data['customer'] = customer;
    }
    if(latLong != null){
      data['latLong'] = latLong;
    }
    if(location != null){
      data['location'] = location;
    }
    if(description != null){
      data['description'] = description;
    }
    if(note != null){
      data['note'] = note;
    }
    if(image != null){
      data['image'] = image;
    }

    return data;
  }
}