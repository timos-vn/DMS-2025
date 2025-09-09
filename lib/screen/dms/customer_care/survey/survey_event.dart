abstract class SurveyEvent {}

class LoadSurveyQuestionsEvent extends SurveyEvent {
  final String? searchKey;
  final int pageIndex;
  final int pageCount;

  LoadSurveyQuestionsEvent({
    this.searchKey,
    this.pageIndex = 1,
    this.pageCount = 10,
  });
}

class LoadSurveyAnswersEvent extends SurveyEvent {
  final String sttRec;
  final String maCauHoi;

  LoadSurveyAnswersEvent({
    required this.sttRec,
    required this.maCauHoi,
  });
}

class SelectSurveyAnswerEvent extends SurveyEvent {
  final String questionId;
  final String answerId;
  final bool isSelected;

  SelectSurveyAnswerEvent({
    required this.questionId,
    required this.answerId,
    required this.isSelected,
  });
}

class UpdateCustomAnswerEvent extends SurveyEvent {
  final String questionId;
  final String customAnswer;

  UpdateCustomAnswerEvent({
    required this.questionId,
    required this.customAnswer,
  });
}

class SubmitSurveyEvent extends SurveyEvent {
  final String customerId;

  SubmitSurveyEvent({
    required this.customerId,
  });
}

class ResetSurveyEvent extends SurveyEvent {}

class GetPrefsSurveyEvent extends SurveyEvent {}

class RetryLoadQuestionsEvent extends SurveyEvent {
  final String? searchKey;
  final int pageIndex;
  final int pageCount;

  RetryLoadQuestionsEvent({
    this.searchKey,
    this.pageIndex = 1,
    this.pageCount = 10,
  });
}

class RetryLoadAnswersEvent extends SurveyEvent {
  final String sttRec;
  final String maCauHoi;

  RetryLoadAnswersEvent({
    required this.sttRec,
    required this.maCauHoi,
  });
}

class RestoreOriginalQuestionsEvent extends SurveyEvent {}

class SaveSurveyDataEvent extends SurveyEvent {
  final String customerId;
  
  SaveSurveyDataEvent({
    required this.customerId,
  });
}

class LoadSurveyDataEvent extends SurveyEvent {
  final String customerId;
  
  LoadSurveyDataEvent({
    required this.customerId,
  });
}
