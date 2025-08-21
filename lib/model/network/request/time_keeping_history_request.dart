class TimeKeepingHistoryRequest {
  String? datetime;


  TimeKeepingHistoryRequest(
      {
        this.datetime,
      });

  TimeKeepingHistoryRequest.fromJson(Map<String, dynamic> json) {
    datetime = json['dateTime'];
  }



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['dateTime'] = datetime;
    return data;
  }
}