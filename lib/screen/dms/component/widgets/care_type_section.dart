import 'package:flutter/material.dart';
import '../../../../../themes/colors.dart';
import '../../../sell/component/input_address_popup.dart';

class CareTypeSection extends StatelessWidget {
  final bool isPhone;
  final bool isEmail;
  final bool isSMS;
  final bool isMXH;
  final bool isOther;
  final String? otherNote;
  final Function(int) onCareTypeChanged;
  final Function(String) onOtherNoteChanged;

  const CareTypeSection({
    Key? key,
    required this.isPhone,
    required this.isEmail,
    required this.isSMS,
    required this.isMXH,
    required this.isOther,
    this.otherNote,
    required this.onCareTypeChanged,
    required this.onOtherNoteChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(),
        _buildCareTypeOptions(context),
        _buildOtherOption(context),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return const Padding(
      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
      child: Text(
        'Loại CS',
        style: TextStyle(color: Colors.blueGrey, fontSize: 12),
      ),
    );
  }

  Widget _buildCareTypeOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCareTypeButton('Phone', isPhone, 1),
              _buildCareTypeButton('Email', isEmail, 2),
              _buildCareTypeButton('SMS', isSMS, 3),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCareTypeButton('Page', isMXH, 4),
              _buildCareTypeButton('Other', isOther, 5, context: context),
              const SizedBox(width: 100, height: 10),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCareTypeButton(String title, bool value, int index, {BuildContext? context}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      onPressed: () {
        onCareTypeChanged(index);
        if (index == 5 && context != null) {
          _handleOtherOption(context);
        }
      },
      child: _buildCheckboxItem(title, value, index),
    );
  }

  Widget _buildCheckboxItem(String title, bool value, int index) {
    return SizedBox(
      height: 25,
      child: Row(
        children: [
          SizedBox(
            height: 10,
            child: Transform.scale(
              scale: 1,
              alignment: Alignment.topLeft,
              child: Checkbox(
                value: value,
                onChanged: (b) => onCareTypeChanged(index),
                activeColor: mainColor,
                hoverColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: MaterialStateBorderSide.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return BorderSide(color: mainColor);
                  } else {
                    return BorderSide(color: mainColor);
                  }
                }),
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherOption(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: isOther,
          child: const Divider(height: 1),
        ),
        Visibility(
          visible: isOther,
          child: GestureDetector(
            onTap: () => _showOtherTypeDialog(context),
            child: SizedBox(
              height: 45,
              child: Padding(
                padding: const EdgeInsets.only(top: 5, left: 8, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Loại CS khác:',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          (otherNote != null && otherNote!.isNotEmpty)
                              ? otherNote!
                              : "Vui lòng nhập loại CS mà bạn sử dụng",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: isOther,
          child: const Divider(height: 1),
        ),
      ],
    );
  }

  void _handleOtherOption(BuildContext context) {
    if (isOther) {
      _showOtherTypeDialog(context);
    }
  }

  void _showOtherTypeDialog(BuildContext context) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return InputAddressPopup(
          note: otherNote ?? "",
          title: 'Vui lòng nhập loại CS bạn sử dụng',
          desc: 'Vui lòng nhập loại CS bạn sử dụng',
          convertMoney: false,
          inputNumber: false,
        );
      },
    ).then((note) {
      if (note != null) {
        onOtherNoteChanged(note);
      }
    });
  }
}

