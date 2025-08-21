import 'package:equatable/equatable.dart';

abstract class MainEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefs extends MainEvent {
  @override
  String toString() => 'GetPrefs';
}

