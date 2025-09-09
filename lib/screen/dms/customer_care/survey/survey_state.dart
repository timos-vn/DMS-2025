import '../../../../model/entity/survey_question.dart';

abstract class SurveyState {}

class SurveyInitial extends SurveyState {}

class GetPrefsSurveySuccess extends SurveyState {}

class SurveyLoading extends SurveyState {}

class SurveyQuestionsLoaded extends SurveyState {
  final List<SurveyQuestion> questions;

  SurveyQuestionsLoaded(this.questions);
}

class SurveyAnswersLoaded extends SurveyState {
  final List<SurveyQuestion> questions;

  SurveyAnswersLoaded(this.questions);
}

class SurveySubmitted extends SurveyState {
  final List<SurveyQuestion> questions;

  SurveySubmitted(this.questions);
}

class SurveyFailure extends SurveyState {
  final String error;
  final bool canRetry;
  final String? retryAction;

  SurveyFailure(this.error, {this.canRetry = true, this.retryAction});

  SurveyFailure copyWith({
    String? error,
    bool? canRetry,
    String? retryAction,
  }) {
    return SurveyFailure(
      error ?? this.error,
      canRetry: canRetry ?? this.canRetry,
      retryAction: retryAction ?? this.retryAction,
    );
  }
}
