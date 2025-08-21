import 'dart:async';
import 'dart:ui';

class Debounce {
  Duration? delay;
  Timer? _timer;
  VoidCallback? _callback;

  Debounce({this.delay = const Duration(milliseconds: 500)});

  void debounce(VoidCallback callback) {
    _callback = callback;

    cancel();
    _timer =  Timer(delay!, flush);
  }

  void cancel() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  void flush() {
    _callback!();
    cancel();
  }
}