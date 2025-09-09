import '../../entity/survey_question.dart';
import '../../entity/survey_answer.dart';

class SurveyQuestionsResponse {
  final List<SurveyQuestionData>? data;
  final int? totalPage;
  final int? statusCode;
  final String? message;

  SurveyQuestionsResponse({
    this.data,
    this.totalPage,
    this.statusCode,
    this.message,
  });

  factory SurveyQuestionsResponse.fromJson(Map<String, dynamic> json) {
    return SurveyQuestionsResponse(
      data: json['data'] != null 
          ? List<SurveyQuestionData>.from(json['data'].map((x) => SurveyQuestionData.fromJson(x)))
          : null,
      totalPage: json['totalPage'],
      statusCode: json['statusCode'] ?? 0,
      message: json['message'],
    );
  }
}

class SurveyQuestionData {
  final String maCauHoi;
  final String tenCauHoi;

  SurveyQuestionData({
    required this.maCauHoi,
    required this.tenCauHoi,
  });

  factory SurveyQuestionData.fromJson(Map<String, dynamic> json) {
    return SurveyQuestionData(
      maCauHoi: json['ma_cau_hoi'] ?? '',
      tenCauHoi: json['ten_cau_hoi'] ?? '',
    );
  }

  SurveyQuestion toSurveyQuestion() {
    return SurveyQuestion(
      maCauHoi: maCauHoi,
      tenCauHoi: tenCauHoi,
    );
  }
}

class SurveyAnswersResponse {
  final List<SurveyAnswerData>? data;
  final int? totalPage;
  final int? statusCode;
  final String? message;

  SurveyAnswersResponse({
    this.data,
    this.totalPage,
    this.statusCode,
    this.message,
  });

  factory SurveyAnswersResponse.fromJson(Map<String, dynamic> json) {
    return SurveyAnswersResponse(
      data: json['data'] != null 
          ? List<SurveyAnswerData>.from(json['data'].map((x) => SurveyAnswerData.fromJson(x)))
          : null,
      totalPage: json['totalPage'],
      statusCode: json['statusCode'] ?? 0,
      message: json['message'],
    );
  }
}

class SurveyAnswerData {
  final String sttRec;
  final String sttRec0;
  final List<AnswerItem>? answers;

  SurveyAnswerData({
    required this.sttRec,
    required this.sttRec0,
    this.answers,
  });

  factory SurveyAnswerData.fromJson(Map<String, dynamic> json) {
    return SurveyAnswerData(
      sttRec: json['sttRec'] ?? '',
      sttRec0: json['sttRec0'] ?? '',
      answers: json['answers'] != null 
          ? List<AnswerItem>.from(json['answers'].map((x) => AnswerItem.fromJson(x)))
          : null,
    );
  }
}

class AnswerItem {
  final String maTraLoi;
  final String tenCauTraLoi;

  AnswerItem({
    required this.maTraLoi,
    required this.tenCauTraLoi,
  });

  factory AnswerItem.fromJson(Map<String, dynamic> json) {
    return AnswerItem(
      maTraLoi: json['maTraLoi'] ?? '',
      tenCauTraLoi: json['tenCauTraLoi'] ?? '',
    );
  }

  SurveyAnswer toSurveyAnswer() {
    return SurveyAnswer(
      maTraLoi: maTraLoi,
      tenCauTraLoi: tenCauTraLoi,
    );
  }
}
