import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:dms/screen/login/component/login_card.dart';
import 'package:dms/widget/widget_helper.dart';
import 'package:flutter/material.dart';
import '../model/models/login_user_type.dart';
import 'custom_page_transformer.dart';


class AuthCardLogin extends StatefulWidget {
  const AuthCardLogin(
      {Key? key,
        required this.userType,
        required this.loadingController,
        this.onSubmit,
        this.onSubmitCompleted,
        this.disableCustomPageTransformer = false,
        required this.scrollable})
      : super(key: key);

  final AnimationController loadingController;
  final Function? onSubmit;
  final Function? onSubmitCompleted;
  final LoginUserType userType;
  final bool disableCustomPageTransformer;

  final bool scrollable;

  @override
  AuthCardLoginState createState() => AuthCardLoginState();
}

class AuthCardLoginState extends State<AuthCardLogin> with TickerProviderStateMixin {
  final GlobalKey _loginCardKey = GlobalKey();

  static const int _loginPageIndex = 0;
  static const int _recoveryIndex = 1;
  static const int _additionalSignUpIndex = 2;

  int _pageIndex = _loginPageIndex;

  static const cardSizeScaleEnd = .2;

  final TransformerPageController _pageController = TransformerPageController();
  late AnimationController _formLoadingController;
  late AnimationController _routeTransitionController;

  // Card specific animations
  late Animation<double> _cardSize2AnimationX;
  late Animation<double> _cardSize2AnimationY;

  @override
  void initState() {
    super.initState();

    widget.loadingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _formLoadingController.forward();
      }
    });

    _formLoadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _routeTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );

    _cardSize2AnimationX =
        Tween<double>(begin: 1, end: 1).animate(_routeTransitionController);

    _cardSize2AnimationY =
        Tween<double>(begin: 1, end: 1).animate(_routeTransitionController);
  }

  @override
  void dispose() {
    _formLoadingController.dispose();
    _pageController.dispose();
    _routeTransitionController.dispose();
    super.dispose();
  }

  void _changeCard(int newCardIndex) {
    // final auth = Provider.of<Auth>(context, listen: false);
    // auth.currentCardIndex = newCardIndex;
    setState(() {
      _pageController.animateToPage(
        newCardIndex,
        duration: const Duration(milliseconds: 100),
        curve: Curves.ease,
      );
      _pageIndex = newCardIndex;
    });
  }

  Future<void> _forwardChangeRouteAnimation(GlobalKey cardKey) {
    final deviceSize = MediaQuery.of(context).size;
    final cardSize = getWidgetSize(cardKey)!;
    final widthRatio = deviceSize.width / cardSize.height + 2;
    final heightRatio = deviceSize.height / cardSize.width + .25;
    _cardSize2AnimationX =
        Tween<double>(begin: 1.0, end: heightRatio / cardSizeScaleEnd)
            .animate(CurvedAnimation(
          parent: _routeTransitionController,
          curve: const Interval(.72727272, 1, curve: Curves.easeInOutCubic),
        ));
    _cardSize2AnimationY =
        Tween<double>(begin: 1.0, end: widthRatio / cardSizeScaleEnd)
            .animate(CurvedAnimation(
          parent: _routeTransitionController,
          curve: const Interval(.72727272, 1, curve: Curves.easeInOutCubic),
        ));

    widget.onSubmit?.call();

    return _formLoadingController
        .reverse()
        .then((_) => _routeTransitionController.forward());
  }

  Widget _changeToCard(BuildContext context, int index) {
    var formController = _formLoadingController;
    switch (index) {
      case _loginPageIndex:
        return LoginCard(
          key: _loginCardKey,
          userType: widget.userType,
          loadingController: formController,
          onSwitchRecoveryPassword: () => _changeCard(_recoveryIndex),
          // onSwitchSignUpAdditionalData: () =>
          //     _changeCard(_additionalSignUpIndex),
          onSubmitCompleted: () {
            _forwardChangeRouteAnimation(_loginCardKey).then((_) {
              widget.onSubmitCompleted!();
            });
          },
        );
    }
    throw IndexError(index, 5);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    Widget current = Container(
      height: deviceSize.height,
      width: deviceSize.width,
      color: Colors.white,
      // padding: widget.padding,
      child: TransformerPageView(
        physics: const NeverScrollableScrollPhysics(),
        pageController: _pageController,
        itemCount: 5,

        /// Need to keep track of page index because soft keyboard will
        /// make page view rebuilt
        index: _pageIndex,
        transformer: widget.disableCustomPageTransformer
            ? null
            : CustomPageTransformer(),
        itemBuilder: (BuildContext context, int index) {
          if (widget.scrollable) {
            return Align(
              alignment: Alignment.topCenter,
              child: Scrollbar(
                  child: SingleChildScrollView(
                      child: _changeToCard(context, index))),
            );
          } else {
            return Align(
              alignment: Alignment.topCenter,
              child: _changeToCard(context, index),
            );
          }
        },
      ),
    );

    return current;

    //   AnimatedBuilder(
    //   animation: _cardSize2AnimationX,
    //   builder: (context, snapshot) {
    //     return Transform(
    //       alignment: Alignment.center,
    //       transform: Matrix4.identity()
    //         ..rotateZ(_cardRotationAnimation.value)
    //         ..scale(_cardSizeAnimation.value, _cardSizeAnimation.value)
    //         ..scale(_cardSize2AnimationX.value, _cardSize2AnimationY.value),
    //       child: current,
    //     );
    //   },
    // );
  }
}
