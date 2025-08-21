import 'dart:collection';
import 'dart:math';
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:dms/screen/info_cpn/component/info_cpn_card.dart';
import 'package:dms/utils/auth/auth.dart';
import 'package:dms/utils/maths/matrix.dart';
import 'package:dms/widget/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'custom_page_transformer.dart';

class AuthCardInfoCPN extends StatefulWidget {
  const AuthCardInfoCPN(
      {super.key,
        this.padding = const EdgeInsets.all(0),
        required this.loadingController,
        this.onSubmit,
        this.onSubmitCompleted,
        this.disableCustomPageTransformer = false,
        required this.scrollable});

  final EdgeInsets padding;
  final AnimationController loadingController;
  final Function? onSubmit;
  final Function? onSubmitCompleted;
  final bool disableCustomPageTransformer;
  final bool scrollable;

  @override
  AuthCardInfoCPNState createState() => AuthCardInfoCPNState();
}

class AuthCardInfoCPNState extends State<AuthCardInfoCPN> with TickerProviderStateMixin {
  final GlobalKey _infoCPNCardKey = GlobalKey();


  static const int _infoCPNScreenIndex = 0;
  static const int _recoveryIndex = 1;
  static const int _additionalSignUpIndex = 2;


  int _pageIndex = _infoCPNScreenIndex;

  var _isLoadingFirstTime = true;
  static const cardSizeScaleEnd = .2;

  final TransformerPageController _pageController = TransformerPageController();
  late AnimationController _formLoadingController;
  late AnimationController _routeTransitionController;

  // Card specific animations
  late Animation<double> _flipAnimation;
  late Animation<double> _cardSizeAnimation;
  late Animation<double> _cardSize2AnimationX;
  late Animation<double> _cardSize2AnimationY;
  late Animation<double> _cardRotationAnimation;
  late Animation<double> _cardOverlayHeightFactorAnimation;
  late Animation<double> _cardOverlaySizeAndOpacityAnimation;

  @override
  void initState() {
    super.initState();

    widget.loadingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isLoadingFirstTime = false;
        _formLoadingController.forward();
      }
    });

    // Set all animations
    _flipAnimation = Tween<double>(begin: pi / 2, end: 0).animate(
      CurvedAnimation(
        parent: widget.loadingController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );

    _formLoadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _routeTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _cardSizeAnimation = Tween<double>(begin: 1.0, end: cardSizeScaleEnd)
        .animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: const Interval(0, .27272727 /* ~300ms */,
          curve: Curves.easeInOutCirc),
    ));

    // replace 0 with minPositive to pass the test
    // https://github.com/flutter/flutter/issues/42527#issuecomment-575131275
    _cardOverlayHeightFactorAnimation =
        Tween<double>(begin: double.minPositive, end: 1.0)
            .animate(CurvedAnimation(
          parent: _routeTransitionController,
          curve: const Interval(.27272727, .5 /* ~250ms */, curve: Curves.linear),
        ));

    _cardOverlaySizeAndOpacityAnimation =
        Tween<double>(begin: 1.0, end: 0).animate(CurvedAnimation(
          parent: _routeTransitionController,
          curve: const Interval(.5, .72727272 /* ~250ms */, curve: Curves.linear),
        ));

    _cardSize2AnimationX =
        Tween<double>(begin: 1, end: 1).animate(_routeTransitionController);

    _cardSize2AnimationY =
        Tween<double>(begin: 1, end: 1).animate(_routeTransitionController);

    _cardRotationAnimation =
        Tween<double>(begin: 0, end: pi / 2).animate(CurvedAnimation(
          parent: _routeTransitionController,
          curve: const Interval(.72727272, 1 /* ~300ms */,
              curve: Curves.easeInOutCubic),
        ));
  }

  @override
  void dispose() {
    _formLoadingController.dispose();
    _pageController.dispose();
    _routeTransitionController.dispose();
    super.dispose();
  }

  void _changeCard(int newCardIndex) {
    setState(() {
      _pageController.animateToPage(
        newCardIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      _pageIndex = newCardIndex;
    });
  }

  Future<void>? runLoadingAnimation() {
    if (widget.loadingController.isDismissed) {
      return widget.loadingController.forward().then((_) {
        if (!_isLoadingFirstTime) {
          _formLoadingController.forward();
        }
      });
    } else if (widget.loadingController.isCompleted) {
      return _formLoadingController
          .reverse()
          .then((_) => widget.loadingController.reverse());
    }
    return null;
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

  Widget _buildLoadingAnimator({Widget? child, required ThemeData theme}) {
    Widget card;
    Widget overlay;
    // loading at startup
    card = AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) => Transform(
        transform: Matrix.perspective()..rotateX(_flipAnimation.value),
        alignment: Alignment.center,
        child: child,
      ),
      child: child,
    );

    // change-route transition
    overlay = Padding(
      padding: theme.cardTheme.margin!,
      child: AnimatedBuilder(
        animation: _cardOverlayHeightFactorAnimation,
        builder: (context, child) => ClipPath.shape(
          shape: theme.cardTheme.shape!,
          child: FractionallySizedBox(
            heightFactor: _cardOverlayHeightFactorAnimation.value,
            alignment: Alignment.topCenter,
            child: child,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.colorScheme.secondary),
        ),
      ),
    );

    overlay = ScaleTransition(
      scale: _cardOverlaySizeAndOpacityAnimation,
      child: FadeTransition(
        opacity: _cardOverlaySizeAndOpacityAnimation,
        child: overlay,
      ),
    );

    return Stack(
      children: <Widget>[
        card,
        Positioned.fill(child: overlay),
      ],
    );
  }

  Widget _changeToCard(BuildContext context, int index) {
    final auth = Provider.of<Auth>(context, listen: false);
    var formController = _formLoadingController;
    // if (!_isLoadingFirstTime) formController = _formLoadingController..value = 1.0;
    switch (index) {
      case _infoCPNScreenIndex:
        return _buildLoadingAnimator(
          theme: Theme.of(context),
          child: InfoCPNCard(
            key: _infoCPNCardKey,
            loadingController: formController,
            onSubmitCompleted: () {
              _forwardChangeRouteAnimation(_infoCPNCardKey).then((_) {
                widget.onSubmitCompleted!();
              });
            },
          ),
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
      padding: widget.padding,
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

    return AnimatedBuilder(
      animation: _cardSize2AnimationX,
      builder: (context, snapshot) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(_cardRotationAnimation.value)
            ..scale(_cardSizeAnimation.value, _cardSizeAnimation.value)
            ..scale(_cardSize2AnimationX.value, _cardSize2AnimationY.value),
          child: current,
        );
      },
    );
  }
}
