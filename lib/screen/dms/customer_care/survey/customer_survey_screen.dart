import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/utils.dart';
import '../../../../widget/pending_action.dart';
import 'survey_bloc.dart';
import 'survey_event.dart';
import 'survey_state.dart';
import 'widgets/survey_question_card.dart';
import 'widgets/survey_progress_bar.dart';

class CustomerSurveyScreen extends StatefulWidget {
  final String? sttRec;
  final String customerName;
  final String customerId;

  const CustomerSurveyScreen({
    Key? key,
    required this.sttRec,
    required this.customerName,
    required this.customerId,
  }) : super(key: key);

  @override
  State<CustomerSurveyScreen> createState() => _CustomerSurveyScreenState();
}

class _CustomerSurveyScreenState extends State<CustomerSurveyScreen> {
  late SurveyBloc _surveyBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _surveyBloc = SurveyBloc(context);
    _loadSurveyQuestions();
  }

  void _loadSurveyQuestions() {
    // ✅ Set customer ID trước khi load questions
    _surveyBloc.setCustomerId(widget.customerId);
    
    _surveyBloc.add(GetPrefsSurveyEvent());
    _surveyBloc.add(LoadSurveyQuestionsEvent(
      pageIndex: 1,
      pageCount: 20, // Tải nhiều câu hỏi hơn
    ));
  }

  // ✅ Retry action thông minh dựa trên loại lỗi
  void _retryAction(String? retryAction) {
    if (retryAction == null || retryAction.isEmpty) {
      // Retry mặc định - load lại câu hỏi
      _loadSurveyQuestions();
      return;
    }

    // Retry dựa trên action cụ thể
    if (retryAction.contains('câu hỏi')) {
      _surveyBloc.add(RetryLoadQuestionsEvent(
        pageIndex: 1,
        pageCount: 20,
      ));
    } else if (retryAction.contains('câu trả lời')) {
      // Retry cho câu trả lời cụ thể (cần context)
      _loadSurveyQuestions();
    } else {
      // Fallback
      _loadSurveyQuestions();
    }
  }

  @override
  void dispose() {
    _surveyBloc.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: BlocListener<SurveyBloc, SurveyState>(
              bloc: _surveyBloc,
              listener: (context, state) {
                if (state is SurveyFailure) {
                  Utils.showCustomToast(
                    context,
                    Icons.warning_amber_outlined,
                    state.error,
                  );
                }
              },
              child: BlocBuilder<SurveyBloc, SurveyState>(
                bloc: _surveyBloc,
                builder: (context, state) {
                  // ✅ Chỉ hiển thị loading toàn màn hình khi load questions lần đầu
                  if (state is SurveyLoading && _surveyBloc.questions.isEmpty) {
                    return const Center(child: PendingAction());
                  } else if (state is SurveyQuestionsLoaded ||
                      state is SurveyAnswersLoaded ||
                      state is SurveyLoading) { // ✅ Cho phép SurveyLoading khi đã có questions
                    return _buildSurveyContent(state);
                  } else if (state is SurveyFailure) {
                    return _buildErrorState(state);
                  } else {
                    return const Center(
                      child: Text('Không có dữ liệu khảo sát'),
                    );
                  }
                },
              ),
            ),
          ),
          _buildBottomSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 83,
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(2, 4),
            blurRadius: 5,
            spreadRadius: 2,
          )
        ],
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [subColor, Color.fromARGB(255, 150, 185, 229)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(5, 35, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Khảo sát khách hàng',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                  Text(
                    widget.customerName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          const SizedBox(
            width: 40,
            height: 50,
            child: Icon(
              Icons.quiz,
              size: 25,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSurveyContent(SurveyState state) {
    final questions = _surveyBloc.questions;
    
    return Column(
      children: [
        // Search bar
        _buildSearchBar(),
        
        // Progress bar
        SurveyProgressBar(
          currentProgress: _surveyBloc.completionRate,
          totalQuestions: questions.length,
          answeredQuestions: _surveyBloc.answeredQuestions.length,
        ),
        
        // Questions list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SurveyQuestionCard(
                  question: question,
                  onAnswerSelected: (answerId, isSelected) {
                    _surveyBloc.add(SelectSurveyAnswerEvent(
                      questionId: question.maCauHoi,
                      answerId: answerId,
                      isSelected: isSelected,
                    ));
                  },
                  onCustomAnswerChanged: (customAnswer) {
                    _surveyBloc.add(UpdateCustomAnswerEvent(
                      questionId: question.maCauHoi,
                      customAnswer: customAnswer,
                    ));
                  },
                  onLoadAnswers: () {
                    _surveyBloc.add(LoadSurveyAnswersEvent(
                      sttRec: widget.sttRec.toString(),
                      maCauHoi: question.maCauHoi,
                    ));
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm câu hỏi...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _surveyBloc.add(RestoreOriginalQuestionsEvent());
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            _surveyBloc.add(LoadSurveyQuestionsEvent(
              searchKey: value,
              pageIndex: 1,
              pageCount: 20,
            ));
          }
        },
      ),
    );
  }

  Widget _buildErrorState(SurveyFailure state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Đã xảy ra lỗi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          // ✅ Hiển thị retry button thông minh
          if (state.canRetry) ...[
            ElevatedButton.icon(
              onPressed: () => _retryAction(state.retryAction),
              icon: const Icon(Icons.refresh),
              label: Text(state.retryAction ?? 'Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: subColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadSurveyQuestions,
              child: const Text('Quay lại danh sách câu hỏi'),
            ),
          ] else ...[
            ElevatedButton(
              onPressed: _loadSurveyQuestions,
              child: const Text('Quay lại danh sách câu hỏi'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<SurveyBloc, SurveyState>(
              bloc: _surveyBloc,
              builder: (context, state) {
                final isValid = _surveyBloc.isSurveyValid;
                final completionRate = _surveyBloc.completionRate;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tiến độ: ${(completionRate * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: completionRate,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isValid ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          BlocBuilder<SurveyBloc, SurveyState>(
            bloc: _surveyBloc,
            builder: (context, state) {
              final hasQuestions = _surveyBloc.questions.isNotEmpty;
              
              return ElevatedButton(
                onPressed: hasQuestions ? _completeSurvey : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: subColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Hoàn thành',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _completeSurvey() {
    // ✅ Tự động lưu dữ liệu trước khi hoàn thành
    _surveyBloc.add(SaveSurveyDataEvent(customerId: widget.customerId));
    
    // ✅ Hiển thị thông báo và back về màn trước
    Utils.showCustomToast(
      context,
      Icons.check_circle,
      'Khảo sát đã được lưu thành công!',
    );
    
    // ✅ Back về màn trước để tiếp tục khai báo customer care
    Navigator.pop(context, 'SURVEY_COMPLETED');
  }
}
