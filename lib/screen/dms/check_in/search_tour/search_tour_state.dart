import 'package:equatable/equatable.dart';

abstract class SearchTourState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialSearchState extends SearchTourState {

  @override
  String toString() {
    return 'InitialSearchTourState{}';
  }
}

class GetPrefsSuccess extends SearchTourState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class GetListSuccess extends SearchTourState{

  @override
  String toString() {
    return 'GetListTourSuccess{}';
  }
}


class SearchLoading extends SearchTourState {

  @override
  String toString() => 'SearchTourLoading';
}

class SearchFailure extends SearchTourState {
  final String error;

  SearchFailure(this.error);

  @override
  String toString() => 'SearchFailure { error: $error }';
}

class GetListEmpty extends SearchTourState {

  @override
  String toString() {
    return 'GetListTourEmpty{}';
  }
}