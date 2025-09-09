import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:async';
import '../../../../model/entity/survey_question.dart';
import '../../../../model/entity/survey_answer.dart';
import '../../../../model/entity/survey_data.dart';
import '../../../../model/network/services/network_factory.dart';
import '../../../../model/network/response/survey_response.dart';
import '../../../../utils/const.dart';
import 'survey_event.dart';
import 'survey_state.dart';

class SurveyBloc extends Bloc<SurveyEvent, SurveyState> {
  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  SurveyBloc(this.context) : super(SurveyInitial()) {
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsSurveyEvent>(_getPrefs);
    on<LoadSurveyQuestionsEvent>(_onLoadQuestions);
    on<LoadSurveyAnswersEvent>(_onLoadAnswers);
    on<SelectSurveyAnswerEvent>(_onSelectAnswer);
    on<UpdateCustomAnswerEvent>(_onUpdateCustomAnswer);
    on<SubmitSurveyEvent>(_onSubmitSurvey);
    on<ResetSurveyEvent>(_onResetSurvey);
    on<RetryLoadQuestionsEvent>(_onRetryLoadQuestions);
    on<RetryLoadAnswersEvent>(_onRetryLoadAnswers);
    on<RestoreOriginalQuestionsEvent>(_onRestoreOriginalQuestions);
    on<SaveSurveyDataEvent>(_onSaveSurveyData);
    on<LoadSurveyDataEvent>(_onLoadSurveyData);
  }

  final box = GetStorage();
  void _getPrefs(GetPrefsSurveyEvent event, Emitter<SurveyState> emitter) async {
    emitter(SurveyInitial());
    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsSurveySuccess());
  }

  List<SurveyQuestion> _questions = [];
  List<SurveyQuestion> get questions => _questions;
  
  // ✅ Cache danh sách câu hỏi gốc để restore khi clear search
  List<SurveyQuestion> _originalQuestions = [];
  List<SurveyQuestion> get originalQuestions => _originalQuestions;

  Future<void> _onLoadQuestions(
    LoadSurveyQuestionsEvent event,
    Emitter<SurveyState> emit,
  ) async {
    try {
      emit(SurveyLoading());
      
      if (_accessToken == null) {
        emit(SurveyFailure('Token không tồn tại, vui lòng đăng nhập lại', canRetry: false));
        return;
      }

      // ✅ Thêm timeout 30 giây để tránh loading vô hạn
      final data = await _networkFactory!.getSurveyQuestions(
        _accessToken!,
        searchKey: event.searchKey,
        pageIndex: event.pageIndex,
        pageCount: event.pageCount,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Yêu cầu bị timeout sau 30 giây. Vui lòng kiểm tra kết nối mạng.');
        },
      );

      if (data is String) {
        emit(SurveyFailure('Úi, $data', retryAction: 'Thử lại'));
        return;
      }

      try {
        final response = SurveyQuestionsResponse.fromJson(data as Map<String, dynamic>);
        if (response.statusCode == 200 && response.data != null) {
          // ✅ Preserve các câu trả lời đã load trước đó
          final newQuestions = response.data!.map((q) => q.toSurveyQuestion()).toList();
          
          // ✅ Merge với cả câu hỏi hiện tại và câu hỏi gốc để giữ lại câu trả lời đã load
          final allExistingQuestions = [..._questions, ..._originalQuestions];
          
          for (final newQuestion in newQuestions) {
            final existingQuestion = allExistingQuestions.firstWhere(
              (q) => q.maCauHoi == newQuestion.maCauHoi,
              orElse: () => newQuestion,
            );
            
            if (existingQuestion.isAnswersLoaded || existingQuestion.isAnswered) {
              // Giữ lại câu trả lời đã load hoặc đã trả lời
              final index = newQuestions.indexWhere((q) => q.maCauHoi == newQuestion.maCauHoi);
              if (index != -1) {
                newQuestions[index] = existingQuestion;
              }
            }
          }
          
          _questions = newQuestions;
          
          // ✅ Cache danh sách gốc nếu đây là lần load đầu tiên (không có searchKey)
          if (event.searchKey == null || event.searchKey!.isEmpty) {
            _originalQuestions = List.from(newQuestions);
          }
          
          emit(SurveyQuestionsLoaded(_questions));
          
          // ✅ Auto-load dữ liệu đã lưu sau khi load questions xong (chỉ khi không có searchKey)
          if ((event.searchKey == null || event.searchKey!.isEmpty) && 
              _currentCustomerId != null && _currentCustomerId!.isNotEmpty) {
            add(LoadSurveyDataEvent(customerId: _currentCustomerId!));
          }
        } else {
          emit(SurveyFailure('Không thể tải danh sách câu hỏi', retryAction: 'Thử lại'));
        }
      } catch (e) {
        emit(SurveyFailure('Lỗi parse dữ liệu: $e', retryAction: 'Thử lại'));
      }
    } on TimeoutException catch (e) {
      emit(SurveyFailure('${e.message}', retryAction: 'Thử lại'));
    } catch (e) {
      emit(SurveyFailure('Lỗi: $e', retryAction: 'Thử lại'));
    }
  }

  Future<void> _onLoadAnswers(
    LoadSurveyAnswersEvent event,
    Emitter<SurveyState> emit,
  ) async {
    try {
      // Kiểm tra xem câu hỏi đã có câu trả lời chưa
      final questionIndex = _questions.indexWhere(
        (q) => q.maCauHoi == event.maCauHoi,
      );
      
              if (questionIndex == -1) {
          emit(SurveyFailure('Không tìm thấy câu hỏi', canRetry: false));
          return;
        }
      
      final question = _questions[questionIndex];
      
      // Nếu đã load câu trả lời rồi, không cần call API nữa
      if (question.isAnswersLoaded) {
        emit(SurveyAnswersLoaded(_questions));
        return;
      }
      
      emit(SurveyLoading());
      
      if (_accessToken == null) {
        emit(SurveyFailure('Token không tồn tại, vui lòng đăng nhập lại', canRetry: false));
        return;
      }

      // ✅ Thêm timeout 20 giây cho việc load câu trả lời
      final data = await _networkFactory!.getSurveyAnswers(
        _accessToken!,
        sttRec: event.sttRec,
        maCauHoi: event.maCauHoi,
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw TimeoutException('Yêu cầu bị timeout sau 20 giây. Vui lòng kiểm tra kết nối mạng.');
        },
      );

      if (data is String) {
        emit(SurveyFailure('Úi, $data', retryAction: 'Thử lại'));
        return;
      }

      try {
        final response = SurveyAnswersResponse.fromJson(data as Map<String, dynamic>);
        if (response.statusCode == 200 && response.data != null) {
          // Tìm dữ liệu câu trả lời cho câu hỏi này
          SurveyAnswerData? questionData;
          try {
            questionData = response.data!.firstWhere(
              (d) => d.sttRec0 == event.maCauHoi,
            );
          } catch (e) {
            // Nếu không tìm thấy, sử dụng dữ liệu đầu tiên hoặc tạo mới
            questionData = response.data!.isNotEmpty ? response.data!.first : null;
          }
          
          // ✅ Process loaded answers với merge logic
          final answers = questionData?.answers?.map((a) => a.toSurveyAnswer()).toList();
          _processLoadedAnswers(questionIndex, event.maCauHoi, answers);
          
          emit(SurveyAnswersLoaded(_questions));
        } else {
          emit(SurveyFailure('Không thể tải danh sách câu trả lời', retryAction: 'Thử lại'));
        }
      } catch (e) {
        emit(SurveyFailure('Lỗi parse dữ liệu: $e', retryAction: 'Thử lại'));
      }
    } on TimeoutException catch (e) {
      emit(SurveyFailure('${e.message}', retryAction: 'Thử lại'));
    } catch (e) {
      emit(SurveyFailure('Lỗi: $e', retryAction: 'Thử lại'));
    }
  }

  void _onSelectAnswer(
    SelectSurveyAnswerEvent event,
    Emitter<SurveyState> emit,
  ) {
    try {
      // ✅ Cập nhật cả _questions và _originalQuestions
      final questionIndex = _questions.indexWhere(
        (q) => q.maCauHoi == event.questionId,
      );
      
      if (questionIndex != -1) {
        final question = _questions[questionIndex];
        final answers = List<SurveyAnswer>.from(question.answers ?? []);
        
        // Tìm và cập nhật trạng thái câu trả lời
        for (int i = 0; i < answers.length; i++) {
          if (answers[i].maTraLoi == event.answerId) {
            answers[i] = answers[i].copyWith(isSelected: event.isSelected);
            break;
          }
        }
        
        // Cập nhật danh sách câu trả lời đã chọn
        final selectedAnswers = answers
            .where((a) => a.isSelected)
            .map((a) => a.maTraLoi)
            .toList();
        
        final updatedQuestion = question.copyWith(
          answers: answers,
          selectedAnswers: selectedAnswers,
          isAnswered: selectedAnswers.isNotEmpty,
        );
        
        // ✅ Cập nhật _questions
        _questions[questionIndex] = updatedQuestion;
        
        // ✅ Cập nhật _originalQuestions nếu có
        if (_originalQuestions.isNotEmpty) {
          final originalIndex = _originalQuestions.indexWhere(
            (q) => q.maCauHoi == event.questionId,
          );
          if (originalIndex != -1) {
            _originalQuestions[originalIndex] = updatedQuestion;
          }
        }
        
        emit(SurveyAnswersLoaded(_questions));
        
        // ✅ Tự động lưu sau khi cập nhật câu trả lời
        _autoSaveSurveyData();
      }
    } catch (e) {
      emit(SurveyFailure('Lỗi cập nhật câu trả lời: $e'));
    }
  }

  void _onUpdateCustomAnswer(
    UpdateCustomAnswerEvent event,
    Emitter<SurveyState> emit,
  ) {
    try {
      // ✅ Cập nhật cả _questions và _originalQuestions
      final questionIndex = _questions.indexWhere(
        (q) => q.maCauHoi == event.questionId,
      );
      
      if (questionIndex != -1) {
        final question = _questions[questionIndex];
        final hasCustomAnswer = event.customAnswer.isNotEmpty;
        
        // ✅ Cập nhật isAnswered dựa trên cả selectedAnswers và customAnswer
        final isAnswered = (question.selectedAnswers?.isNotEmpty ?? false) || hasCustomAnswer;
        
        final updatedQuestion = question.copyWith(
          customAnswer: event.customAnswer,
          isAnswered: isAnswered,
        );
        
        // ✅ Cập nhật _questions
        _questions[questionIndex] = updatedQuestion;
        
        // ✅ Cập nhật _originalQuestions nếu có
        if (_originalQuestions.isNotEmpty) {
          final originalIndex = _originalQuestions.indexWhere(
            (q) => q.maCauHoi == event.questionId,
          );
          if (originalIndex != -1) {
            _originalQuestions[originalIndex] = updatedQuestion;
          }
        }
        
        emit(SurveyAnswersLoaded(_questions));
        
        // ✅ Tự động lưu sau khi cập nhật custom answer
        _autoSaveSurveyData();
      }
    } catch (e) {
      emit(SurveyFailure('Lỗi cập nhật câu trả lời tùy chỉnh: $e'));
    }
  }

  Future<void> _onSubmitSurvey(
    SubmitSurveyEvent event,
    Emitter<SurveyState> emit,
  ) async {
    try {
      emit(SurveyLoading());
      
      if (_accessToken == null) {
        emit(SurveyFailure('Token không tồn tại, vui lòng đăng nhập lại', canRetry: false));
        return;
      }
      
      // Kiểm tra validation
      final invalidQuestions = _questions.where((q) => !q.isValid).toList();
      if (invalidQuestions.isNotEmpty) {
        final errorMessage = invalidQuestions
            .map((q) => q.validationError)
            .where((e) => e != null)
            .join(', ');
        emit(SurveyFailure(errorMessage));
        return;
      }
      
      // Chuẩn bị dữ liệu submit
      final surveyResults = <String, dynamic>{};
      for (final question in _questions) {
        if (question.isAnswered) {
          surveyResults[question.maCauHoi] = {
            'selectedAnswers': question.selectedAnswers,
            'customAnswer': question.customAnswer,
          };
        }
      }
      
      // ✅ Gọi API submit với timeout 45 giây
      final data = await _networkFactory!.submitSurvey(
        _accessToken!,
        customerId: event.customerId,
        surveyResults: surveyResults,
      ).timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          throw TimeoutException('Yêu cầu gửi khảo sát bị timeout sau 45 giây. Vui lòng kiểm tra kết nối mạng.');
        },
      );
      
      if (data is String) {
        emit(SurveyFailure('Úi, $data', retryAction: 'Thử lại'));
        return;
      }
      
      try {
        final responseData = data as Map<String, dynamic>;
        if (responseData['success'] == true) {
          emit(SurveySubmitted(_questions));
        } else {
          emit(SurveyFailure('Không thể gửi khảo sát', retryAction: 'Thử lại'));
        }
      } catch (e) {
        emit(SurveyFailure('Lỗi parse dữ liệu: $e', retryAction: 'Thử lại'));
      }
    } on TimeoutException catch (e) {
      emit(SurveyFailure('${e.message}', retryAction: 'Thử lại'));
    } catch (e) {
      emit(SurveyFailure('Lỗi gửi khảo sát: $e', retryAction: 'Thử lại'));
    }
  }

  void _onResetSurvey(
    ResetSurveyEvent event,
    Emitter<SurveyState> emit,
  ) {
    _questions.clear();
    emit(SurveyInitial());
  }

  // ✅ Retry mechanism cho việc load câu hỏi
  Future<void> _onRetryLoadQuestions(
    RetryLoadQuestionsEvent event,
    Emitter<SurveyState> emit,
  ) async {
    try {
      emit(SurveyLoading());
      
      if (_accessToken == null) {
        emit(SurveyFailure('Token không tồn tại, vui lòng đăng nhập lại', canRetry: false));
        return;
      }

      // ✅ Thêm timeout 30 giây để tránh loading vô hạn
      final data = await _networkFactory!.getSurveyQuestions(
        _accessToken!,
        searchKey: event.searchKey,
        pageIndex: event.pageIndex,
        pageCount: event.pageCount,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Yêu cầu bị timeout sau 30 giây. Vui lòng kiểm tra kết nối mạng.');
        },
      );

      if (data is String) {
        emit(SurveyFailure('Úi, $data', retryAction: 'Thử lại'));
        return;
      }

      try {
        final response = SurveyQuestionsResponse.fromJson(data as Map<String, dynamic>);
        if (response.statusCode == 200 && response.data != null) {
          // Chỉ load câu hỏi, không load câu trả lời
          _questions = response.data!.map((q) => q.toSurveyQuestion()).toList();
          emit(SurveyQuestionsLoaded(_questions));
        } else {
          emit(SurveyFailure('Không thể tải danh sách câu hỏi', retryAction: 'Thử lại'));
        }
      } catch (e) {
        emit(SurveyFailure('Lỗi parse dữ liệu: $e', retryAction: 'Thử lại'));
      }
    } on TimeoutException catch (e) {
      emit(SurveyFailure('${e.message}', retryAction: 'Thử lại'));
    } catch (e) {
      emit(SurveyFailure('Lỗi: $e', retryAction: 'Thử lại'));
    }
  }

  // ✅ Retry mechanism cho việc load câu trả lời
  Future<void> _onRetryLoadAnswers(
    RetryLoadAnswersEvent event,
    Emitter<SurveyState> emit,
  ) async {
    try {
      // Kiểm tra xem câu hỏi đã có câu trả lời chưa
      final questionIndex = _questions.indexWhere(
        (q) => q.maCauHoi == event.maCauHoi,
      );
      
      if (questionIndex == -1) {
        emit(SurveyFailure('Không tìm thấy câu hỏi', canRetry: false));
        return;
      }
      
      final question = _questions[questionIndex];
      
      // Nếu đã load câu trả lời rồi, không cần call API nữa
      if (question.isAnswersLoaded) {
        emit(SurveyAnswersLoaded(_questions));
        return;
      }
      
      emit(SurveyLoading());
      
      if (_accessToken == null) {
        emit(SurveyFailure('Token không tồn tại, vui lòng đăng nhập lại', canRetry: false));
        return;
      }

      // ✅ Thêm timeout 20 giây cho việc load câu trả lời
      final data = await _networkFactory!.getSurveyAnswers(
        _accessToken!,
        sttRec: event.sttRec,
        maCauHoi: event.maCauHoi,
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw TimeoutException('Yêu cầu bị timeout sau 20 giây. Vui lòng kiểm tra kết nối mạng.');
        },
      );

      if (data is String) {
        emit(SurveyFailure('Úi, $data', retryAction: 'Thử lại'));
        return;
      }

      try {
        final response = SurveyAnswersResponse.fromJson(data as Map<String, dynamic>);
        if (response.statusCode == 200 && response.data != null) {
          // Tìm dữ liệu câu trả lời cho câu hỏi này
          SurveyAnswerData? questionData;
          try {
            questionData = response.data!.firstWhere(
              (d) => d.sttRec0 == event.maCauHoi,
            );
          } catch (e) {
            // Nếu không tìm thấy, sử dụng dữ liệu đầu tiên hoặc tạo mới
            questionData = response.data!.isNotEmpty ? response.data!.first : null;
          }
          
          // ✅ Process loaded answers với merge logic
          final answers = questionData?.answers?.map((a) => a.toSurveyAnswer()).toList();
          _processLoadedAnswers(questionIndex, event.maCauHoi, answers);
          
          emit(SurveyAnswersLoaded(_questions));
        } else {
          emit(SurveyFailure('Không thể tải danh sách câu trả lời', retryAction: 'Thử lại'));
        }
      } catch (e) {
        emit(SurveyFailure('Lỗi parse dữ liệu: $e', retryAction: 'Thử lại'));
      }
    } on TimeoutException catch (e) {
      emit(SurveyFailure('${e.message}', retryAction: 'Thử lại'));
    } catch (e) {
      emit(SurveyFailure('Lỗi: $e', retryAction: 'Thử lại'));
    }
  }

  /// Kiểm tra xem khảo sát có hợp lệ không
  bool get isSurveyValid {
    return _questions.every((q) => q.isValid);
  }

  /// Lấy danh sách câu hỏi đã trả lời (từ tất cả câu hỏi gốc)
  List<SurveyQuestion> get answeredQuestions {
    // ✅ Luôn tính từ danh sách gốc để đảm bảo chính xác
    final allQuestions = _originalQuestions.isNotEmpty ? _originalQuestions : _questions;
    return allQuestions.where((q) => q.isAnswered).toList();
  }

  /// Lấy tỷ lệ hoàn thành khảo sát (dựa trên tất cả câu hỏi gốc)
  double get completionRate {
    // ✅ Luôn tính từ danh sách gốc để đảm bảo chính xác
    final allQuestions = _originalQuestions.isNotEmpty ? _originalQuestions : _questions;
    if (allQuestions.isEmpty) return 0.0;
    
    // Đếm số câu hỏi đã trả lời từ tất cả câu hỏi gốc
    final answeredCount = allQuestions.where((q) => q.isAnswered).length;
    return answeredCount / allQuestions.length;
  }

  /// ✅ Restore danh sách câu hỏi gốc và preserve câu trả lời đã có
  Future<void> _onRestoreOriginalQuestions(
    RestoreOriginalQuestionsEvent event,
    Emitter<SurveyState> emit,
  ) async {
    try {
      if (_originalQuestions.isEmpty) {
        // Nếu chưa có danh sách gốc, load lại từ API
        add(LoadSurveyQuestionsEvent(
          pageIndex: 1,
          pageCount: 20,
        ));
        return;
      }

      // ✅ Merge với câu trả lời đã có
      final restoredQuestions = List<SurveyQuestion>.from(_originalQuestions);
      
      for (int i = 0; i < restoredQuestions.length; i++) {
        final originalQuestion = restoredQuestions[i];
        final existingQuestion = _questions.firstWhere(
          (q) => q.maCauHoi == originalQuestion.maCauHoi,
          orElse: () => originalQuestion,
        );
        
        if (existingQuestion.isAnswersLoaded || existingQuestion.isAnswered) {
          // Giữ lại câu trả lời đã load hoặc đã trả lời
          restoredQuestions[i] = existingQuestion;
        }
      }
      
      _questions = restoredQuestions;
      emit(SurveyQuestionsLoaded(_questions));
    } catch (e) {
      emit(SurveyFailure('Lỗi khi khôi phục danh sách câu hỏi: $e', retryAction: 'Thử lại'));
    }
  }

  // ✅ Current customer ID cho việc lưu dữ liệu
  String? _currentCustomerId;
  
  /// ✅ Set customer ID để auto-load data
  void setCustomerId(String customerId) {
    _currentCustomerId = customerId;
  }

  /// ✅ Merge answers từ API với data đã lưu
  void _mergeAnswersWithSavedData(int questionIndex, List<SurveyAnswer> answers) {
    final currentQuestion = _questions[questionIndex];
    if (currentQuestion.selectedAnswers != null && currentQuestion.selectedAnswers!.isNotEmpty) {
      // Cập nhật trạng thái isSelected cho answers dựa trên selectedAnswers đã lưu
      for (int i = 0; i < answers.length; i++) {
        if (currentQuestion.selectedAnswers!.contains(answers[i].maTraLoi)) {
          answers[i] = answers[i].copyWith(isSelected: true);
        }
      }
    }
  }

  /// ✅ Process loaded answers với merge logic
  void _processLoadedAnswers(int questionIndex, String maCauHoi, List<SurveyAnswer>? answers) {
    if (answers != null && answers.isNotEmpty) {
      // ✅ Merge với dữ liệu đã lưu
      _mergeAnswersWithSavedData(questionIndex, answers);
      
      _questions[questionIndex] = _questions[questionIndex].copyWith(
        answers: answers,
        isAnswersLoaded: true,
      );
    } else {
      // Nếu không có câu trả lời, tạo danh sách rỗng
      _questions[questionIndex] = _questions[questionIndex].copyWith(
        answers: <SurveyAnswer>[],
        isAnswersLoaded: true,
      );
    }
    
    // ✅ Cập nhật _originalQuestions nếu có
    if (_originalQuestions.isNotEmpty) {
      final originalIndex = _originalQuestions.indexWhere(
        (q) => q.maCauHoi == maCauHoi,
      );
      if (originalIndex != -1) {
        _originalQuestions[originalIndex] = _questions[questionIndex];
      }
    }
  }
  
  /// ✅ Lưu dữ liệu khảo sát vào GetStorage
  Future<void> _onSaveSurveyData(
    SaveSurveyDataEvent event,
    Emitter<SurveyState> emit,
  ) async {
    try {
      _currentCustomerId = event.customerId;
      final surveyDataList = _convertQuestionsToSurveyData();
      final jsonData = surveyDataList.toJson();
      
      // Lưu vào GetStorage với key unique cho từng customer
      final storageKey = '${Const.SURVEY_DATA}_${event.customerId}';
      await box.write(storageKey, jsonData);
      
      // Lưu progress
      final progressKey = '${Const.SURVEY_PROGRESS}_${event.customerId}';
      await box.write(progressKey, completionRate);
      
      print('✅ Đã lưu dữ liệu khảo sát cho customer: ${event.customerId}');
      print('📊 Progress: ${(completionRate * 100).toStringAsFixed(1)}%');
    } catch (e) {
      print('❌ Lỗi khi lưu dữ liệu khảo sát: $e');
    }
  }

  /// ✅ Load dữ liệu khảo sát từ GetStorage
  Future<void> _onLoadSurveyData(
    LoadSurveyDataEvent event,
    Emitter<SurveyState> emit,
  ) async {
    try {
      _currentCustomerId = event.customerId;
      final storageKey = '${Const.SURVEY_DATA}_${event.customerId}';
      final jsonData = box.read(storageKey);
      
      if (jsonData != null) {
        final surveyDataList = SurveyDataList.fromJson(jsonData);
        _applySurveyDataToQuestions(surveyDataList);
        
        print('✅ Đã load dữ liệu khảo sát cho customer: ${event.customerId}');
        print('📊 Progress: ${(completionRate * 100).toStringAsFixed(1)}%');
        
        emit(SurveyQuestionsLoaded(_questions));
      } else {
        print('ℹ️ Không có dữ liệu khảo sát đã lưu cho customer: ${event.customerId}');
      }
    } catch (e) {
      print('❌ Lỗi khi load dữ liệu khảo sát: $e');
    }
  }

  /// ✅ Tự động lưu dữ liệu (gọi từ _onSelectAnswer và _onUpdateCustomAnswer)
  void _autoSaveSurveyData() {
    if (_currentCustomerId != null && _currentCustomerId!.isNotEmpty) {
      add(SaveSurveyDataEvent(customerId: _currentCustomerId!));
    }
  }

  /// ✅ Convert danh sách câu hỏi thành SurveyDataList
  SurveyDataList _convertQuestionsToSurveyData() {
    final List<SurveyData> surveyDataList = [];
    
    // ✅ Lấy từ _originalQuestions để đảm bảo có đầy đủ dữ liệu
    final questionsToConvert = _originalQuestions.isNotEmpty ? _originalQuestions : _questions;
    
    for (final question in questionsToConvert) {
      if (question.isAnswered) {
        // ✅ Format ma_td2 theo yêu cầu: "001,002,003"
        String? maTd2;
        if (question.selectedAnswers != null && question.selectedAnswers!.isNotEmpty) {
          maTd2 = question.selectedAnswers!.join(',');
        }
        
        final surveyData = SurveyData(
          sttRec0: question.maCauHoi,
          dienGiai: question.customAnswer?.isNotEmpty == true ? question.customAnswer : null,
          maTd2: maTd2,
        );
        
        surveyDataList.add(surveyData);
      }
    }
    
    return SurveyDataList(data: surveyDataList);
  }

  /// ✅ Apply SurveyDataList vào danh sách câu hỏi
  void _applySurveyDataToQuestions(SurveyDataList surveyDataList) {
    for (final surveyData in surveyDataList.data) {
      // Tìm câu hỏi tương ứng trong _questions
      final questionIndex = _questions.indexWhere(
        (q) => q.maCauHoi == surveyData.sttRec0,
      );
      
      if (questionIndex != -1) {
        final question = _questions[questionIndex];
        
        // Parse ma_td2 thành selectedAnswers
        List<String>? selectedAnswers;
        if (surveyData.maTd2 != null && surveyData.maTd2!.isNotEmpty) {
          selectedAnswers = surveyData.maTd2!.split(',');
        }
        
        // Cập nhật câu hỏi với dữ liệu đã lưu
        _questions[questionIndex] = question.copyWith(
          selectedAnswers: selectedAnswers,
          customAnswer: surveyData.dienGiai,
          isAnswered: (selectedAnswers?.isNotEmpty ?? false) || 
                     (surveyData.dienGiai?.isNotEmpty ?? false),
        );
        
        // ✅ Cập nhật answers nếu có selectedAnswers
        if (selectedAnswers != null && question.answers != null) {
          final updatedAnswers = question.answers!.map((answer) {
            return answer.copyWith(
              isSelected: selectedAnswers!.contains(answer.maTraLoi),
            );
          }).toList();
          
          _questions[questionIndex] = _questions[questionIndex].copyWith(
            answers: updatedAnswers,
          );
        }
      }
      
      // ✅ Cập nhật _originalQuestions nếu có
      if (_originalQuestions.isNotEmpty) {
        final originalIndex = _originalQuestions.indexWhere(
          (q) => q.maCauHoi == surveyData.sttRec0,
        );
        
        if (originalIndex != -1) {
          _originalQuestions[originalIndex] = _questions[questionIndex];
        }
      }
    }
  }

  /// ✅ Lấy dữ liệu khảo sát theo format API
  SurveyDataList getSurveyDataForSubmit() {
    return _convertQuestionsToSurveyData();
  }
}
