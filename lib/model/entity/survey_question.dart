import 'package:dms/model/entity/survey_answer.dart';

class SurveyQuestion {
  final String maCauHoi;
  final String tenCauHoi;
  final bool isRequired;
  final bool allowMultipleAnswers;
  final int maxAnswers;
  final String? validationRule;
  List<SurveyAnswer>? answers;
  List<String>? selectedAnswers;
  String? customAnswer;
  bool isAnswered;
  bool isAnswersLoaded;

  SurveyQuestion({
    required this.maCauHoi,
    required this.tenCauHoi,
    this.isRequired = false,
    this.allowMultipleAnswers = true,
    this.maxAnswers = 5,
    this.validationRule,
    this.answers,
    this.selectedAnswers,
    this.customAnswer,
    this.isAnswered = false,
    this.isAnswersLoaded = false,
  });

  SurveyQuestion copyWith({
    String? maCauHoi,
    String? tenCauHoi,
    bool? isRequired,
    bool? allowMultipleAnswers,
    int? maxAnswers,
    String? validationRule,
    List<SurveyAnswer>? answers,
    List<String>? selectedAnswers,
    String? customAnswer,
    bool? isAnswered,
    bool? isAnswersLoaded,
  }) {
    return SurveyQuestion(
      maCauHoi: maCauHoi ?? this.maCauHoi,
      tenCauHoi: tenCauHoi ?? this.tenCauHoi,
      isRequired: isRequired ?? this.isRequired,
      allowMultipleAnswers: allowMultipleAnswers ?? this.allowMultipleAnswers,
      maxAnswers: maxAnswers ?? this.maxAnswers,
      validationRule: validationRule ?? this.validationRule,
      answers: answers ?? this.answers,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      customAnswer: customAnswer ?? this.customAnswer,
      isAnswered: isAnswered ?? this.isAnswered,
      isAnswersLoaded: isAnswersLoaded ?? this.isAnswersLoaded,
    );
  }

  bool get isValid {
    // ✅ Kiểm tra cả selectedAnswers và customAnswer
    final hasSelectedAnswers = selectedAnswers != null && selectedAnswers!.isNotEmpty;
    final hasCustomAnswer = customAnswer != null && customAnswer!.isNotEmpty;
    final isAnswered = hasSelectedAnswers || hasCustomAnswer;
    
    if (isRequired && !isAnswered) {
      return false;
    }
    if (allowMultipleAnswers && selectedAnswers != null && selectedAnswers!.length > maxAnswers) {
      return false;
    }
    return true;
  }

  String? get validationError {
    // ✅ Kiểm tra cả selectedAnswers và customAnswer
    final hasSelectedAnswers = selectedAnswers != null && selectedAnswers!.isNotEmpty;
    final hasCustomAnswer = customAnswer != null && customAnswer!.isNotEmpty;
    final isAnswered = hasSelectedAnswers || hasCustomAnswer;
    
    if (isRequired && !isAnswered) {
      return 'Vui lòng chọn ít nhất một câu trả lời hoặc nhập câu trả lời tùy chỉnh';
    }
    if (allowMultipleAnswers && selectedAnswers != null && selectedAnswers!.length > maxAnswers) {
      return 'Chỉ được chọn tối đa $maxAnswers câu trả lời';
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'maCauHoi': maCauHoi,
      'tenCauHoi': tenCauHoi,
      'isRequired': isRequired,
      'allowMultipleAnswers': allowMultipleAnswers,
      'maxAnswers': maxAnswers,
      'validationRule': validationRule,
      'selectedAnswers': selectedAnswers,
      'customAnswer': customAnswer,
      'isAnswered': isAnswered,
      'isAnswersLoaded': isAnswersLoaded,
    };
  }

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      maCauHoi: json['ma_cau_hoi'] ?? '',
      tenCauHoi: json['ten_cau_hoi'] ?? '',
      isRequired: json['isRequired'] ?? false,
      allowMultipleAnswers: json['allowMultipleAnswers'] ?? true,
      maxAnswers: json['maxAnswers'] ?? 5,
      validationRule: json['validationRule'],
      answers: json['answers'] != null 
          ? List<SurveyAnswer>.from(json['answers'].map((x) => SurveyAnswer.fromJson(x)))
          : null,
      selectedAnswers: json['selectedAnswers'] != null 
          ? List<String>.from(json['selectedAnswers'])
          : null,
      customAnswer: json['customAnswer'],
      isAnswered: json['isAnswered'] ?? false,
      isAnswersLoaded: json['isAnswersLoaded'] ?? false,
    );
  }
}
