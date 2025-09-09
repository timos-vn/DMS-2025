import 'package:flutter/material.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import '../../../../../themes/colors.dart';
import '../../../../../model/entity/survey_question.dart';
import '../../../../../model/entity/survey_answer.dart';

class SurveyQuestionCard extends StatefulWidget {
  final SurveyQuestion question;
  final Function(String, bool) onAnswerSelected;
  final Function(String) onCustomAnswerChanged;
  final VoidCallback onLoadAnswers;

  const SurveyQuestionCard({
    Key? key,
    required this.question,
    required this.onAnswerSelected,
    required this.onCustomAnswerChanged,
    required this.onLoadAnswers,
  }) : super(key: key);

  @override
  State<SurveyQuestionCard> createState() => _SurveyQuestionCardState();
}

class _SurveyQuestionCardState extends State<SurveyQuestionCard> {
  bool _isExpanded = false;
  bool _isLoading = false;
  final GlobalKey<ExpansionTileCardState> _cardKey = GlobalKey();
  final TextEditingController _customAnswerController = TextEditingController();
  final FocusNode _customAnswerFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _customAnswerController.text = widget.question.customAnswer ?? '';
  }

  @override
  void didUpdateWidget(SurveyQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // ✅ Reset loading state khi dữ liệu được load xong
    if (_isLoading && widget.question.isAnswersLoaded) {
      setState(() {
        _isLoading = false;
        _isExpanded = true; // Expand khi load xong
      });
    }
  }

  /// ✅ Xử lý expand/collapse thống nhất cho cả title và mũi tên
  void _handleExpansionChange(bool expanded) {
    print('_handleExpansionChange called with expanded: $expanded'); // Debug log
    if (expanded && !widget.question.isAnswersLoaded && !_isLoading) {
      // Bắt đầu loading
      setState(() {
        _isLoading = true;
        _isExpanded = true; // ✅ Set expanded ngay lập tức
      });
      
      // Load dữ liệu
      widget.onLoadAnswers();
    } else if (expanded && widget.question.isAnswersLoaded) {
      // Đã load xong, có thể expand
      setState(() {
        _isExpanded = true;
      });
    } else if (!expanded) {
      // Collapse
      setState(() {
        _isExpanded = false;
      });
    }
  }

  @override
  void dispose() {
    _customAnswerController.dispose();
    _customAnswerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTileCard(
      key: _cardKey,
      initiallyExpanded: _isExpanded,
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),initialElevation: 2,
      onExpansionChanged: (expanded) {
        // ✅ Xử lý expand/collapse giống như click vào title
        print('ExpansionTileCard onExpansionChanged: $expanded'); // Debug log
        _handleExpansionChange(expanded);
      }, 
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: widget.question.isAnswered ? Colors.green : Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            widget.question.maCauHoi.trim(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: widget.question.isAnswered ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
      title: InkWell(
        onTap: () {
          // ✅ Click vào title để expand/collapse - giống như mũi tên
          print('Title clicked! Current expanded: $_isExpanded'); // Debug log
          if (_isExpanded) {
            _cardKey.currentState?.collapse();
          } else {
            _cardKey.currentState?.expand();
          }
        },
        borderRadius: BorderRadius.circular(8),
        splashColor: subColor.withOpacity(0.3), // ✅ Thêm splash effect
        highlightColor: subColor.withOpacity(0.1), // ✅ Thêm highlight effect
        child: Container(
          width: double.infinity, // ✅ Đảm bảo toàn bộ width có thể click
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.question.tenCauHoi,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              if (widget.question.isRequired)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Bắt buộc',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      subtitle: widget.question.isAnswered
          ? Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Đã trả lời',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : null,
                           children: [
          _buildAnswersSection(),
        ],
      );
  }

  Widget _buildAnswersSection() {
    final answers = widget.question.answers ?? [];
    
    // ✅ Hiển thị CircularProgressIndicator khi đang loading
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // ✅ Hiển thị thông báo nếu không có câu trả lời
    if (answers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey[500],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Không có câu trả lời cho câu hỏi này',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Hiển thị UI khác nhau dựa trên số lượng câu trả lời
        if (answers.length <= 5)
          ...answers.map((answer) => _buildAnswerOption(answer as SurveyAnswer))
        else
          _buildScrollableAnswers(answers),
        
        // ✅ Custom answer field với preview
        _buildCustomAnswerField(),
      ],
    );
  }

  Widget _buildAnswerOption(SurveyAnswer answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // ✅ Click vào cả dòng để tích chọn
          final newValue = !answer.isSelected;
          widget.onAnswerSelected(answer.maTraLoi, newValue);
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: answer.isSelected 
                ? subColor.withOpacity(0.1) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: answer.isSelected 
                  ? subColor.withOpacity(0.3) 
                  : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                value: answer.isSelected,
                onChanged: (value) {
                  if (value != null) {
                    widget.onAnswerSelected(answer.maTraLoi, value);
                  }
                },
                activeColor: subColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: Text(
                  answer.tenCauTraLoi,
                  style: TextStyle(
                    fontSize: 14,
                    color: answer.isSelected ? Colors.grey[800] : Colors.grey[600],
                    fontWeight: answer.isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
              // ✅ Nút (x) để bỏ chọn nhanh
              if (answer.isSelected)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.grey[500],
                  ),
                  onPressed: () {
                    widget.onAnswerSelected(answer.maTraLoi, false);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAnswerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Checkbox "Khác" với visual feedback
        InkWell(
          onTap: () {
            print('InkWell "Khác" clicked!'); // Debug log
            final currentValue = widget.question.customAnswer != null &&
                widget.question.customAnswer!.isNotEmpty;
            if (currentValue) {
              // Nếu đã có nội dung, bỏ chọn và xóa
              print('InkWell - clearing content'); // Debug log
              widget.onCustomAnswerChanged('');
              _customAnswerController.clear();
            } else {
              // Nếu chưa có nội dung, tích chọn và focus
              print('InkWell - checking and focusing'); // Debug log
              widget.onCustomAnswerChanged(' '); // Tạo giá trị tạm để trigger UI
              Future.delayed(const Duration(milliseconds: 100), () {
                _customAnswerController.clear();
                _customAnswerFocusNode.requestFocus();
              });
            }
          },
          borderRadius: BorderRadius.circular(8),
          splashColor: subColor.withOpacity(0.3), // ✅ Thêm splash effect
          highlightColor: subColor.withOpacity(0.1), // ✅ Thêm highlight effect
          child: Container(
            width: double.infinity, // ✅ Đảm bảo toàn bộ width có thể click
            padding: const EdgeInsets.only(left: 4,right: 4),
            child: Row(
              children: [
                Checkbox(
                  value: widget.question.customAnswer != null &&
                      widget.question.customAnswer!.isNotEmpty,
                  onChanged: (value) {
                    print('Checkbox "Khác" clicked! Value: $value'); // Debug log
                    if (value == true) {
                      // ✅ Khi tích chọn, focus vào text field
                      print('Checkbox checked - focusing text field'); // Debug log
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _customAnswerFocusNode.requestFocus();
                      });
                    } else {
                      // ✅ Khi bỏ chọn, xóa nội dung
                      print('Checkbox unchecked - clearing content'); // Debug log
                      widget.onCustomAnswerChanged('');
                      _customAnswerController.clear();
                    }
                  },
                  activeColor: subColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded( // ✅ Wrap text trong Expanded để click được
                  child: Text(
                    'Khác:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ✅ TextField với preview và nút xóa
        if (widget.question.customAnswer != null &&
            widget.question.customAnswer!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 40, top: 0,bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _customAnswerController,
                  focusNode: _customAnswerFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Nhập câu trả lời của bạn...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: subColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ Nút ẩn bàn phím
                        IconButton(
                          icon: Icon(
                            Icons.keyboard_hide,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            _customAnswerFocusNode.unfocus();
                          },
                          tooltip: 'Ẩn bàn phím',
                        ),
                        // ✅ Nút xóa nội dung
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: 18,
                            color: Colors.grey[500],
                          ),
                          onPressed: () {
                            widget.onCustomAnswerChanged('');
                            _customAnswerController.clear();
                          },
                          tooltip: 'Xóa nội dung',
                        ),
                      ],
                    ),
                  ),
                  onChanged: (value) {
                    widget.onCustomAnswerChanged(value);
                  },
                  onSubmitted: (value) {
                    // ✅ Ẩn bàn phím khi nhấn Enter
                    _customAnswerFocusNode.unfocus();
                  },
                  textInputAction: TextInputAction.done, // ✅ Hiển thị nút "Xong" trên bàn phím
                  maxLines: 2,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildScrollableAnswers(List<dynamic> answers) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn câu trả lời:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200, // ✅ Height cố định để tránh infinite scrolling
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: answers.length,
              itemBuilder: (context, index) {
                final answer = answers[index] as SurveyAnswer;
                return InkWell(
                  onTap: () {
                    // ✅ Click vào cả dòng để tích chọn
                    final newValue = !answer.isSelected;
                    widget.onAnswerSelected(answer.maTraLoi, newValue);
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: answer.isSelected 
                          ? subColor.withOpacity(0.1) 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: answer.isSelected 
                            ? subColor.withOpacity(0.3) 
                            : Colors.grey[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: answer.isSelected,
                          onChanged: (value) {
                            if (value != null) {
                              widget.onAnswerSelected(answer.maTraLoi, value);
                            }
                          },
                          activeColor: subColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            answer.tenCauTraLoi,
                            style: TextStyle(
                              fontSize: 14,
                              color: answer.isSelected ? Colors.grey[800] : Colors.grey[600],
                              fontWeight: answer.isSelected ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ),
                        // ✅ Nút (x) để bỏ chọn nhanh
                        if (answer.isSelected)
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.grey[500],
                            ),
                            onPressed: () {
                              widget.onAnswerSelected(answer.maTraLoi, false);
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownAnswers(List<dynamic> answers) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn câu trả lời:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: null,
                hint: Text(
                  'Chọn câu trả lời...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                isExpanded: true,
                items: answers.map<DropdownMenuItem<String>>((answer) {
                  final surveyAnswer = answer as SurveyAnswer;
                  return DropdownMenuItem<String>(
                    value: surveyAnswer.maTraLoi,
                    child: Row(
                      children: [
                        Checkbox(
                          value: surveyAnswer.isSelected,
                          onChanged: (value) {
                            if (value != null) {
                              widget.onAnswerSelected(surveyAnswer.maTraLoi, value);
                            }
                          },
                          activeColor: subColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            surveyAnswer.tenCauTraLoi,
                            style: TextStyle(
                              fontSize: 14,
                              color: surveyAnswer.isSelected ? Colors.grey[800] : Colors.grey[600],
                              fontWeight: surveyAnswer.isSelected ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  // Không cần xử lý gì ở đây vì đã xử lý trong checkbox
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
