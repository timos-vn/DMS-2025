import 'package:equatable/equatable.dart';

abstract class MainState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialMainState extends MainState {

  @override
  String toString() {
    return 'InitialMainState{}';
  }
}

class GetPrefsSuccess extends MainState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class MainLoading extends MainState {

  @override
  String toString() => 'MainLoading';
}
