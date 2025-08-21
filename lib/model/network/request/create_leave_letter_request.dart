class CreateLeaveLetterRequest {
  String? dateFrom;
  String? dateTo;
  String? timeFrom;
  String? timeTo;
  String? leaveType;
  String? description;
  String? maCong;
  double? date;

  CreateLeaveLetterRequest(
      {this.timeFrom, this.timeTo, this.dateFrom, this.dateTo, this.leaveType, this.description, this.maCong, this.date});

  CreateLeaveLetterRequest.fromJson(Map<String, dynamic> json) {
    dateFrom = json['dateFrom'];
    dateTo = json['dateTo'];
    timeFrom = json['timeFrom'];
    timeTo = json['timeTo'];
    leaveType = json['leaveType'];
    description = json['description'];
    maCong = json['maCong'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dateFrom'] = dateFrom;
    data['dateTo'] = dateTo;
    data['timeFrom'] = timeFrom;
    data['timeTo'] = timeTo;
    data['leaveType'] = leaveType;
    data['description'] = description;
    data['maCong'] = maCong;
    data['date'] = date;
    return data;
  }
}