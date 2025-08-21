import 'package:dms/screen/menu/menu_bloc.dart';
import 'package:dms/screen/menu/menu_event.dart';
import 'package:dms/screen/menu/menu_state.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late MenuBloc _bloc;

  final _oldPasswordFocusNode = FocusNode();
  final _newPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? _oldPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _bloc = MenuBloc(context);
    _bloc.add(GetPrefsMenuEvent());
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _oldPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleOldPasswordVisibility() {
    setState(() {
      _isOldPasswordVisible = !_isOldPasswordVisible;
    });
  }

  void _toggleNewPasswordVisibility() {
    setState(() {
      _isNewPasswordVisible = !_isNewPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  void _validateOldPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _oldPasswordError = 'Bạn chưa nhập mật khẩu cũ';
      } else if (value.length < 6) {
        _oldPasswordError = 'Nhập tối thiểu 6 kí tự';
      } else {
        _oldPasswordError = null;
      }
    });
  }

  void _validateNewPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _newPasswordError = 'Bạn chưa nhập mật khẩu mới';
      } else if (value.length < 6) {
        _newPasswordError = 'Nhập tối thiểu 6 kí tự';
      } else {
        _newPasswordError = null;
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = 'Bạn chưa nhập lại mật khẩu mới';
      } else if (value != _newPasswordController.text) {
        _confirmPasswordError = 'Mật khẩu không khớp, vui lòng nhập lại';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  void _onChangePasswordPressed() {
    _bloc.add(
      ChangePassWord(
        oldPass: _oldPasswordController.text,
        newPass: _newPasswordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      extendBody: true,
      body: BlocProvider(
        create: (context) => _bloc,
        child: BlocListener<MenuBloc, MenuState>(
          listener: (context, state) {
            if (state is MenuFailure) {
              Utils.showCustomToast(
                  context, Icons.warning_amber_outlined, state.error);
            } else if (state is ChangePassWordSuccess) {
              Utils.showCustomToast(context, Icons.check, state.message);
              Navigator.pop(context);
            }
          },
          child: BlocBuilder<MenuBloc, MenuState>(
            bloc: _bloc,
            builder: (context, MenuState state) {
              return Stack(
                children: [
                  buildBody(context),
                  Visibility(
                    visible: state is MenuLoading,
                    child: const PendingAction(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildAppBar() {
    return Container(
      height: 83,
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
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
          const Expanded(
            child: Center(
              child: Text(
                'Đổi mật khẩu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(
            height: 45,
            width: 40,
            child: Icon(
              Icons.how_to_reg,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        buildAppBar(),
        const SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      buildPasswordField(
                        label: 'Mật khẩu cũ',
                        controller: _oldPasswordController,
                        focusNode: _oldPasswordFocusNode,
                        isPasswordVisible: _isOldPasswordVisible,
                        toggleVisibility: _toggleOldPasswordVisibility,
                        errorText: _oldPasswordError,
                        validator: _validateOldPassword,
                        onSubmitted: (value) {
                          if (_oldPasswordController.text.isEmpty) {
                            setState(() {
                              _oldPasswordError = 'Bạn chưa nhập mật khẩu cũ';
                            });
                            FocusScope.of(context)
                                .requestFocus(_oldPasswordFocusNode);
                          } else {
                            FocusScope.of(context)
                                .requestFocus(_newPasswordFocusNode);
                          }
                        },
                        nextFocusNode: _newPasswordFocusNode,
                      ),
                      const SizedBox(height: 15),
                      buildPasswordField(
                        label: 'Mật khẩu mới',
                        controller: _newPasswordController,
                        focusNode: _newPasswordFocusNode,
                        isPasswordVisible: _isNewPasswordVisible,
                        toggleVisibility: _toggleNewPasswordVisibility,
                        errorText: _newPasswordError,
                        validator: _validateNewPassword,
                        onSubmitted: (value) {
                          if (_newPasswordController.text.isEmpty) {
                            setState(() {
                              _newPasswordError = 'Bạn chưa nhập mật khẩu mới';
                            });
                            FocusScope.of(context)
                                .requestFocus(_newPasswordFocusNode);
                          } else {
                            FocusScope.of(context)
                                .requestFocus(_confirmPasswordFocusNode);
                          }
                        },
                        nextFocusNode: _confirmPasswordFocusNode,
                      ),
                      const SizedBox(height: 15),
                      buildPasswordField(
                        label: 'Nhập lại mật khẩu mới',
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        isPasswordVisible: _isConfirmPasswordVisible,
                        toggleVisibility: _toggleConfirmPasswordVisibility,
                        errorText: _confirmPasswordError,
                        validator: _validateConfirmPassword,
                        onSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        nextFocusNode: null,
                      ),
                      const SizedBox(height: 30),
                      buildButtonChangePassword(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPasswordField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isPasswordVisible,
    required VoidCallback toggleVisibility,
    String? errorText,
    required Function(String) validator,
    required Function(String) onSubmitted,
    FocusNode? nextFocusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: text,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          obscureText: !isPasswordVisible,
          controller: controller,
          focusNode: focusNode,
          onTapOutside: (_) => label != 'Nhập lại mật khẩu mới'
              ? FocusScope.of(context).unfocus()
              : null,
          decoration: InputDecoration(
            hintText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorText != null ? kErrorColor : kSecondaryColor,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                  !isPasswordVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: toggleVisibility,
            ),
          ),
          onChanged: validator,
          onSubmitted: (value) {
            onSubmitted(value);
          },
          textInputAction: label == 'Nhập lại mật khẩu mới'
              ? TextInputAction.done
              : TextInputAction.next,
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              errorText,
              style: TextStyle(color: kErrorColor, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget buildButtonChangePassword() {
    final isDisabledButton = _oldPasswordError != null ||
        _oldPasswordController.text.isEmpty ||
        _newPasswordError != null ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordError != null ||
        _confirmPasswordController.text.isEmpty;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: InkWell(
        onTap: isDisabledButton ? null : _onChangePasswordPressed,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: isDisabledButton ? button_disabled : subColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              'Đổi mật khẩu',
              style: TextStyle(
                color: isDisabledButton ? text_disabled : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
