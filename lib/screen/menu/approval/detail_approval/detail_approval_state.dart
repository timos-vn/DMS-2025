import 'package:equatable/equatable.dart';

import '../../../../model/network/response/get_html_approval_response.dart';

abstract class DetailApprovalState extends Equatable {
  @override
  List<Object> get props => [];
}

class DetailApprovalInitial extends DetailApprovalState {

  @override
  String toString() => 'DetailApprovalInitial';
}

class DetailApprovalFailure extends DetailApprovalState {
  final String error;

  DetailApprovalFailure(this.error);

  @override
  String toString() => 'DetailApprovalFailure { error: $error }';
}

class DetailApprovalLoading extends DetailApprovalState {
  @override
  String toString() => 'DetailApprovalLoading';
}

class GetListDetailApprovalSuccess extends DetailApprovalState {
  @override
  String toString() => 'GetListDetailApprovalSuccess }';
}

class GetHTMLApprovalSuccess extends DetailApprovalState {

  final String htmlDetailApproval;
  final List<ListValuesFilesView> listImage;

  GetHTMLApprovalSuccess({required this.htmlDetailApproval,required this.listImage});

  @override
  String toString() => 'GetHTMLApprovalSuccess }';
}

class GetHTMLApprovalFail extends DetailApprovalState {

  @override
  String toString() => 'GetHTMLApprovalFail }';
}

class AcceptDetailApprovalSuccess extends DetailApprovalState {
  final String notifi;

  AcceptDetailApprovalSuccess(this.notifi);
  @override
  String toString() => 'AcceptDetailApprovalSuccess {notifi:$notifi }';
}

class SelectedSuccess extends DetailApprovalState {
  @override
  String toString() => 'SelectedSuccess }';
}

class PickGenderStatusSuccess extends DetailApprovalState {
  @override
  String toString() => 'PickGenderStatusSuccess';
}

class GetPrefsSuccess extends DetailApprovalState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}
class GetDetailApprovalEmpty extends DetailApprovalState {

  @override
  String toString() {
    return 'GetDetailApprovalEmpty{}';
  }
}


class GetListStatusApprovalSuccess extends DetailApprovalState {

  @override
  String toString() => 'GetListStatusApprovalSuccess }';
}

class GetListDetailApprovalEmpty extends DetailApprovalState {

  @override
  String toString() {
    return 'GetListDetailApprovalEmpty{}';
  }
}