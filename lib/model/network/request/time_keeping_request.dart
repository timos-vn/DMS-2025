class TimeKeepingRequest {
  String? datetime;
  bool? isWifi;
  bool? isUserVIP;
  String? latLong;
  String? address;
  String? note;
  String? qrCode;
  String? uId;


  TimeKeepingRequest(
      {
        this.datetime,
        this.isWifi,
        this.isUserVIP,
        this.latLong,
        this.address,
        this.note,
        this.qrCode,
        this.uId
      });

  TimeKeepingRequest.fromJson(Map<String, dynamic> json) {
    datetime = json['datetime'];
    isWifi = json['isWifi'];
    isUserVIP = json['isUserVIP'];
    latLong = json['latLong'];
    address = json['address'];
    note = json['note'];
    qrCode = json['qrCode'];
    uId = json['uId'];
  }



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if(datetime != null){
      data['datetime'] = datetime;
    }
    if(address != null){
      data['address'] = address;
    }
    if(latLong != null){
      data['latLong'] = latLong;
    }
    if(isWifi != null){
      data['isWifi'] = isWifi;
    }
    if(isUserVIP != null){
      data['isUserVIP'] = isUserVIP;
    }
    if(note != null){
      data['note'] = note;
    }
    if(qrCode != null){
      data['qrCode'] = qrCode;
    }
    data['uId'] = uId;
    return data;
  }
}