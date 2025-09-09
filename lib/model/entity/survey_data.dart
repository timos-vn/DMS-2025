class SurveyData {
  final String sttRec0; // maCauHoi
  final String? dienGiai; // customAnswer
  final String? maTd2; // maTraLoi (multiple answers: "001,002,003")

  const SurveyData({
    required this.sttRec0,
    this.dienGiai,
    this.maTd2,
  });

  Map<String, dynamic> toJson() {
    return {
      'stt_rec0': sttRec0,
      'dien_giai': dienGiai ?? '',
      'ma_td2': maTd2 ?? '',
    };
  }

  factory SurveyData.fromJson(Map<String, dynamic> json) {
    return SurveyData(
      sttRec0: json['stt_rec0'] ?? '',
      dienGiai: json['dien_giai']?.isEmpty == true ? null : json['dien_giai'],
      maTd2: json['ma_td2']?.isEmpty == true ? null : json['ma_td2'],
    );
  }

  @override
  String toString() {
    return 'SurveyData(sttRec0: $sttRec0, dienGiai: $dienGiai, maTd2: $maTd2)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SurveyData &&
        other.sttRec0 == sttRec0 &&
        other.dienGiai == dienGiai &&
        other.maTd2 == maTd2;
  }

  @override
  int get hashCode {
    return sttRec0.hashCode ^ dienGiai.hashCode ^ maTd2.hashCode;
  }
}

/// Wrapper class cho danh sách SurveyData
class SurveyDataList {
  final List<SurveyData> data;

  const SurveyDataList({required this.data});

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
    };
  }

  factory SurveyDataList.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'] ?? [];
    return SurveyDataList(
      data: dataList.map((e) => SurveyData.fromJson(e)).toList(),
    );
  }

  @override
  String toString() {
    return 'SurveyDataList(data: $data)';
  }
}

