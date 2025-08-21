import 'package:dms/utils/const.dart';
import 'package:flutter/material.dart';

class AppLifecycleService with WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();

  AppLifecycleState? _currentState;

  factory AppLifecycleService() {
    return _instance;
  }

  AppLifecycleService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _currentState = state;
    Const.appLifecycleStateChanged = _currentState!;
    print("AppLifecycleState changed: ${Const.appLifecycleStateChanged}");
  }

  AppLifecycleState? get currentState => _currentState;

  bool isAppInForeground() {
    return _currentState == AppLifecycleState.resumed;
  }

  bool isAppInBackground() {
    return _currentState == AppLifecycleState.paused;
  }

  bool isAppInactive() {
    return _currentState == AppLifecycleState.inactive;
  }

  bool isAppDetached() {
    return _currentState == AppLifecycleState.detached;
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}