// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:async';
import 'dart:math';

import 'package:dms/model/database/data_local.dart';
import 'package:dms/widget/register_use.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_update_dialog/update_dialog.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:open_store/open_store.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../model/models/login_data.dart';
import '../../../model/models/login_user_type.dart';
import '../../../animation_widget/animation_text_form_field.dart';
import '../../../animation_widget/custom_animation_background.dart';
import '../../../animation_widget/animated_button.dart';
import '../../../animation_widget/fade_in.dart';
import '../../../utils/auth/auth.dart';
import '../../../utils/const.dart';
import '../../../utils/toast.dart';
import '../../../utils/utils.dart';
import '../login_bloc.dart';
import '../login_event.dart';
import '../login_state.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({
    Key? key,
    required this.loadingController,
    required this.onSwitchRecoveryPassword,
    this.onSwitchSignUpAdditionalData,
    required this.userType,
    this.onSubmitCompleted,
  }) : super(key: key);

  final AnimationController loadingController;
  final Function onSwitchRecoveryPassword;
  final Function? onSwitchSignUpAdditionalData;
  final Function? onSubmitCompleted;
  final LoginUserType userType;

  @override
  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final _passwordFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  late TextEditingController _hotIdController;
  late TextEditingController _nameController;
  late TextEditingController _passController;

  var _isLoading = false;
  var _isSubmitting = false;

  /// switch between login and signup
  late AnimationController _switchAuthController;
  late AnimationController _postSwitchAuthController;
  late AnimationController _submitController;

  ///Timer
  Timer? _timer;
  int start = 3;
  bool waitingLoad = false;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer =  Timer.periodic(
      oneSec,
          (Timer timer) {
        if (start == 0) {
          waitingLoad = false;
          _bloc.add(GetListNews());
          _bloc.add(GetVersionApp());
          setState(() {
            _hotIdController.text = !Utils.isEmpty(DataLocal.hotIdName) ? DataLocal.hotIdName.toString().trim().replaceAll('https://', '').replaceAll('-cloud.sse.net.vn', '') : '';
            _nameController.text = !Utils.isEmpty(DataLocal.accountName) ? DataLocal.accountName : '';
            _passController.text = !Utils.isEmpty(DataLocal.passwordAccount) ? DataLocal.passwordAccount : '';
          });
          _timer?.cancel();
        } else {
          start--;
        }
      },
    );
  }


  UpdateDialog? dialog;

  double progress = 0.0;

  void defaultStyle() {
    if (dialog != null && dialog!.isShowing()) {
      return;
    }
    dialog = UpdateDialog.showUpdate(context,
        title: 'Bạn đã nâng cấp lên phiên bản ${_bloc.versionGoLiveApp}?',
        updateButtonText: 'Nâng cấp',
        updateContent: Utils.getNewLineString(_bloc.contentUpdate.toString().split('*')),
        onUpdate: onUpdate);
  }

  void onUpdate() {
    ToastUtils.success('Đang kiểm tra phiên bản...');
    Timer.periodic(const Duration(milliseconds: 50), (Timer timer) {
      progress = progress + 0.02;
      if (progress > 1.0001) {
        timer.cancel();
        dialog!.dismiss();
        ToastUtils.success('Kiểm tra thành công.');
        progress = 0;
        OpenStore.instance.open(
            appStoreId: '6443526726', // AppStore id of your app for iOS
            appStoreIdMacOS: '6443526726', // AppStore id of your app for MacOS (appStoreId used as default)
            androidAppBundleId: 'sse.net.dms', // Android app bundle package name
            //windowsProductId: '9NZTWSQNTD0S' // Microsoft store id for Widnows apps
        );
      } else {
        dialog!.update(progress);
      }
    });
  }

  Future<void> _showValidationDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.orange,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                const Text(
                  'Thông tin chưa đầy đủ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Message
                const Text(
                  'Vui lòng nhập đầy đủ Host ID, Tên đăng nhập và Mật khẩu để tiếp tục.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // OK Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 51, 114),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Đã hiểu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  ///list of AnimationController each one responsible for a authentication provider icon
  final List<AnimationController> _providerControllerList = <AnimationController>[];

  Interval? _hotIdTextFieldLoadingAnimationInterval;
  Interval? _nameTextFieldLoadingAnimationInterval;
  Interval? _passTextFieldLoadingAnimationInterval;
  Interval? _textButtonLoadingAnimationInterval;
  late Animation<double> _buttonScaleAnimation;

  bool get buttonEnabled => !_isLoading && !_isSubmitting;

  bool showBackground = false;

  late LoginBloc _bloc;

  @override
  void initState() {
    super.initState();
    print('back login');

    startTimer();
    _bloc = LoginBloc(context);
    _bloc.add(GetPrefsLoginEvent());
    _hotIdController = TextEditingController();
    _nameController = TextEditingController();
    _passController = TextEditingController();

    widget.loadingController.addStatusListener(handleLoadingAnimationStatus);

    _switchAuthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _postSwitchAuthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _hotIdTextFieldLoadingAnimationInterval = const Interval(0, .39);
    _nameTextFieldLoadingAnimationInterval = const Interval(0, .85);
    _passTextFieldLoadingAnimationInterval = const Interval(.15, 1.0);
    _textButtonLoadingAnimationInterval = const Interval(.6, 1.0, curve: Curves.easeOut);
    _buttonScaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: widget.loadingController,
          curve: const Interval(.4, 1.0, curve: Curves.easeOutBack),
        ));
  }

  void handleLoadingAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      setState(() {
        _isLoading = true;
        showBackground = true;
      });
    }
    if (status == AnimationStatus.completed) {
      setState(()  {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    widget.loadingController.removeStatusListener(handleLoadingAnimationStatus);
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    _switchAuthController.dispose();
    _postSwitchAuthController.dispose();
    _submitController.dispose();

    for (var controller in _providerControllerList) {
      controller.dispose();
    }
    super.dispose();
  }


  Future<bool> _submit() async {
    FocusScope.of(context).requestFocus(FocusNode());

    // Validate all fields are filled before proceeding
    final hotIdValue = _hotIdController.text.trim();
    final usernameValue = _nameController.text.trim();
    final passwordValue = _passController.text.trim();

    if (hotIdValue.isEmpty || usernameValue.isEmpty || passwordValue.isEmpty) {
      _showValidationDialog();
      return false;
    }

    _formKey.currentState!.save();
    await _submitController.forward();
    setState(() {
      _isSubmitting = true;
    });
    final auth = Provider.of<Auth>(context, listen: false);
    bool? success;

    // auth.authType = AuthType.userPassword;

    success = await auth.onLogin?.call(LoginData(
        hotId: auth.hotId,
        username: auth.username,
        password: auth.password,
      ));

    await _submitController.reverse();

    if(success == false){
      // showErrorToast(context, messages.flushbarTitleError, error!);
      Utils.showCustomToast(context, Icons.warning_amber_outlined, DataLocal.messageLogin.isNotEmpty ? DataLocal.messageLogin : 'Sai thông tin tài khoản hoặc mật khẩu');
      setState(() {
        _isSubmitting = false;
        // showBackground = false;
      });
      return false;
    }else {
      setState(() {
        showBackground = false;
      });
    }

    widget.onSubmitCompleted?.call();

    return true;
  }

  Widget _buildHotIdField(double width, Auth auth,) {
    return AnimatedTextFormField(
      controller: _hotIdController,
      width: width,
      loadingController: widget.loadingController,
      interval: _hotIdTextFieldLoadingAnimationInterval,
      labelText: Utils.getLabelText(LoginUserType.hostId),
      autofillHints: _isSubmitting
          ? null
          : [Utils.getAutoFillHints(LoginUserType.hostId)],
      prefixIcon: Icon(MdiIcons.badgeAccountOutline,color: Color.fromARGB(255, 0, 51, 114),),
      // keyboardType: Utils.getKeyboardType(widget.userType),
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_nameFocusNode);
      },
      // validator: widget.userValidator,
      onSaved: (value) => auth.hotId = value.toString().trim().replaceAll('https://', '').replaceAll('-cloud.sse.net.vn', ''),
      enabled: !_isSubmitting,
    );
  }

  Widget _buildUserField(double width, Auth auth,) {
    return AnimatedTextFormField(
      controller: _nameController,
      width: width,
      loadingController: widget.loadingController,
      interval: _nameTextFieldLoadingAnimationInterval,
      labelText: Utils.getLabelText(LoginUserType.name),
      autofillHints: _isSubmitting
          ? null
          : [Utils.getAutoFillHints(LoginUserType.name)],
      prefixIcon: const Icon(Icons.account_circle_outlined,color: Color.fromARGB(255, 0, 51, 114),),
      keyboardType: Utils.getKeyboardType(widget.userType),
      textInputAction: TextInputAction.next,
      focusNode: _nameFocusNode,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
      // validator: widget.userValidator,
      onSaved: (value) => auth.username = value!,
      enabled: !_isSubmitting,
    );
  }

  Widget _buildPasswordField(double width, Auth auth,) {
    return AnimatedPasswordTextFormField(
      animatedWidth: width,
      loadingController: widget.loadingController,
      interval: _passTextFieldLoadingAnimationInterval,
      labelText: Utils.getLabelText(LoginUserType.pass),
      autofillHints: _isSubmitting
          ? null
          : [AutofillHints.password],
      controller: _passController,
      textInputAction:TextInputAction.done,
      // auth.isLogin ?  : TextInputAction.next,
      focusNode: _passwordFocusNode,
      onFieldSubmitted: (value) {
        _submit();
      },
      // validator: widget.passwordValidator,
      onSaved: (value) => auth.password = value!,
      enabled: !_isSubmitting,
    );
  }

  Widget _buildRegisterUse(ThemeData theme,) {
    return FadeIn(
      controller: widget.loadingController,
      fadeDirection: FadeDirection.bottomToTop,
      offset: .5,
      curve: _textButtonLoadingAnimationInterval!,
      child: TextButton(
        onPressed: buttonEnabled
            ? () {
          showDialog(
              context: context,
              builder: (context) {
                return WillPopScope(
                  onWillPop: () async => true,
                  child: const RegisterUseComponent(
                    title: 'Liên hệ với chúng tôi',
                    content: 'Bạn muốn gọi tới số 0243 568 22 22',
                  ),
                );
              }).then((value)async{
                if(value != null){
                  final Uri launchUri = Uri(
                    scheme: 'tel',
                    path: '02435682222',
                  );
                  await launchUrl(launchUri);
                }
          });
        }
            : null,
        child: const Text(
          'Liên hệ hỗ trợ ?',
          style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 13),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme, ) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: AnimatedButton(
        controller: _submitController,
        text: '      Đăng nhập      ',
        onPressed: () => _submit(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    //final messages = Provider.of<LoginMessages>(context, listen: false);
    final theme = Theme.of(context);
    final cardWidth = min(MediaQuery.of(context).size.width * 9.9, 360.0);
    const cardPadding = 4.0;
    final textFieldWidth = cardWidth - cardPadding * 1;
    final authForm = Form(
      key: _formKey,
      child: Column(
        children: [
          Container(

            padding: const EdgeInsets.only(
              left: cardPadding,
              right: cardPadding,
              top: cardPadding + 10,
            ),
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHotIdField(textFieldWidth, auth),
                const SizedBox(height: 20),
                _buildUserField(textFieldWidth, auth),
                const SizedBox(height: 20),
                _buildPasswordField(textFieldWidth, auth),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Container(
            padding:const EdgeInsets.only(right: cardPadding, bottom: cardPadding, left: cardPadding,),
            width: cardWidth,
            child: Column(
              children: <Widget>[
                Align(
                    alignment:Alignment.centerRight,
                    child: _buildRegisterUse(theme,)),
                const SizedBox(height: 10,),
                _buildSubmitButton(theme, ),
              ],
            ),
          ),
        ],
      ),
    );

    return BlocListener<LoginBloc, LoginState>(
      bloc: _bloc,
      listener: (context,state) async {
        if(state is GetPrefsLoginSuccess){
        }else if(state is LoginAgainSuccess){
        }
        else if(state is SaveDataUserSuccess){
        }
        else if (state is GetVersionGoLiveSuccess) {
          print('GoLive: ${_bloc.versionGoLiveApp}');
          print('Local: ${_bloc.versionLastUpdate}');

          List<String> localVersion = _bloc.versionLastUpdate!.split('.');
          List<String> storeVersion = _bloc.versionGoLiveApp!.split('.');
          if(int.parse(localVersion[0]) < int.parse(storeVersion[0])){
            defaultStyle();
          }
          else if((int.parse(localVersion[0]) == int.parse(storeVersion[0])) && (int.parse(localVersion[1]) < int.parse(storeVersion[1]))){
            defaultStyle();
          }
          else if((int.parse(localVersion[0]) == int.parse(storeVersion[0])) && (int.parse(localVersion[1]) == int.parse(storeVersion[1])) && (int.parse(localVersion[2]) < int.parse(storeVersion[2]))){
            defaultStyle();
          }
          // if(!Utils.isEmpty(DataLocal.dateLogin) && !Utils.isEmpty(DataLocal.accessToken)){
          //   print(DataLocal.dateLogin);
          //   print('Check Login: ${DateTime.now().isBeforeDay(Utils.parseStringToDate(DataLocal.dateLogin.toString().trim(), Const.DATE_SV_FORMAT_2))}');
          //   if(DateTime.now().isBeforeDay(Utils.parseStringToDate(DataLocal.dateLogin.toString().trim(), Const.DATE_SV_FORMAT_2)) == false){
          //     bool? success = await _bloc.login(DataLocal.hotIdName, DataLocal.accountName, DataLocal.passwordAccount,true);
          //     if(success == true){
          //       Navigator.of(context).pushReplacement(FadePageRoute(
          //         builder: (context) => InfoCPNScreen(username: DataLocal.userName.toString(),accessToken: _bloc.accessToken.toString(),),
          //       ));
          //     }
          //   }
          // }
        }
        if (state is LoginFailure) {
          Utils.showCustomToast(context, Icons.error, state.error);
          Const.HOST_URL = '';
          Const.PORT_URL = 0;
          //libGetX.Get.snackbar('Status'.tr,state.error.toString(),snackPosition: SnackPosition.BOTTOM, margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5));
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        bloc: _bloc,
        builder: (BuildContext context, LoginState state){
          return WillPopScope(
            onWillPop: () async => false,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                AnimatedBackground(width: 100, show: showBackground),
                FittedBox(
                  child: authForm,
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.1,
                  left: 0,right: 0,
                  child: _buildLoginDemo(),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginDemo() {
    return FadeIn(
      controller: widget.loadingController,
      fadeDirection: FadeDirection.bottomToTop,
      offset: .5,
      curve: _textButtonLoadingAnimationInterval!,
      child: TextButton(
          onPressed: (){
            setState(() {
              _hotIdController.text = 'sse';
              _nameController.text = 'tiennq';
              _passController.text = 'sse@123';
            });
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Bạn chưa có tài khoản ?',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                'Demo',
                style:TextStyle(
                    color: Color(0xfff79c4f),
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],
          )
      ),
    );
  }
}
