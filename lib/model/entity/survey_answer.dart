class SurveyAnswer {
  final String maTraLoi;
  final String tenCauTraLoi;
  final bool isCustomAnswer;
  final String? customInputHint;
  bool isSelected;

  SurveyAnswer({
    required this.maTraLoi,
    required this.tenCauTraLoi,
    this.isCustomAnswer = false,
    this.customInputHint,
    this.isSelected = false,
  });

  SurveyAnswer copyWith({
    String? maTraLoi,
    String? tenCauTraLoi,
    bool? isCustomAnswer,
    String? customInputHint,
    bool? isSelected,
  }) {
    return SurveyAnswer(
      maTraLoi: maTraLoi ?? this.maTraLoi,
      tenCauTraLoi: tenCauTraLoi ?? this.tenCauTraLoi,
      isCustomAnswer: isCustomAnswer ?? this.isCustomAnswer,
      customInputHint: customInputHint ?? this.customInputHint,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maTraLoi': maTraLoi,
      'tenCauTraLoi': tenCauTraLoi,
      'isCustomAnswer': isCustomAnswer,
      'customInputHint': customInputHint,
      'isSelected': isSelected,
    };
  }

  factory SurveyAnswer.fromJson(Map<String, dynamic> json) {
    return SurveyAnswer(
      maTraLoi: json['maTraLoi'] ?? '',
      tenCauTraLoi: json['tenCauTraLoi'] ?? '',
      isCustomAnswer: json['isCustomAnswer'] ?? false,
      customInputHint: json['customInputHint'],
      isSelected: json['isSelected'] ?? false,
    );
  }
}
