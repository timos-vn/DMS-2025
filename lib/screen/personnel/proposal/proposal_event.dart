part of 'proposal_bloc.dart';

abstract class ProposalEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsProposal extends ProposalEvent {
  @override
  String toString() => 'GetPrefsProposal';
}
class UploadFileEvent extends ProposalEvent {
  final String keyUpload;
  final String controller;

  UploadFileEvent({required this.keyUpload,required this.controller});
  @override
  String toString() => 'UploadFileEvent';
}

class GetListProposalEvent extends ProposalEvent {
  final int pageIndex;
  final String controller;
  final List<dynamic> listRequestDetail;

  GetListProposalEvent({required this.pageIndex,required this.controller,required this.listRequestDetail});

  @override
  String toString() => 'GetListProposalEvent{pageIndex: $pageIndex}';
}
class GetFormDynamicEvent extends ProposalEvent {
  final String controller;

  GetFormDynamicEvent({required this.controller});

  @override
  String toString() => 'GetFormDynamicEvent{controller: $controller}';
}
class ViewDetailFormDynamicEvent extends ProposalEvent {
  final List<Map<String, dynamic>> listRequestDetail;
  final String controller;
  ViewDetailFormDynamicEvent({required this.controller,required this.listRequestDetail});

  @override
  String toString() => 'ViewDetailFormDynamicEvent{listRequestDetail: $listRequestDetail}';
}

class GetLookUpFormDynamicEvent extends ProposalEvent {
  final String controller;
  final int pageIndex;
  final List<Map<String, dynamic>> listRequestDetail;
  GetLookUpFormDynamicEvent({required this.controller, required this.pageIndex,required this.listRequestDetail});

  @override
  String toString() => 'GetLookUpFormDynamicEvent{controller: $controller}';
}
class GetLayoutSearchEvent extends ProposalEvent {
  final String controller;
  GetLayoutSearchEvent({required this.controller});

  @override
  String toString() => 'GetLayoutSearchEvent{controller: $controller}';
}

class ActionDynamicEvent extends ProposalEvent {
  final String controller;
  final String action;
  final List<Map<String, dynamic>> listRequestDetail;
  final Map<String, dynamic> request;

  ActionDynamicEvent({required this.controller,required this.action, required this.request, required this.listRequestDetail});

  @override
  String toString() => 'ActionDynamicEvent';
}
