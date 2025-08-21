import 'package:equatable/equatable.dart';

abstract class DeliveryPlanState extends Equatable {
  @override
  List<Object> get props => [];
}
class GetPrefsSuccess extends DeliveryPlanState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class DeliveryPlanInitial extends DeliveryPlanState {
  @override
  String toString() => 'DeliveryPlanInitial';
}
class DeliveryPlanLoading extends DeliveryPlanState {
  @override
  String toString() => 'DeliveryPlanLoading';
}

class DeliveryPlanFailure extends DeliveryPlanState {
  final String error;

  DeliveryPlanFailure(this.error);

  @override
  String toString() => 'DeliveryPlanFailure { error: $error }';
}

class GetListDeliveryPlanSuccess extends DeliveryPlanState{

  @override
  String toString() {
    return 'GetListDeliveryPlanSuccess';
  }
}


class UpdateDeliveryPlanSuccess extends DeliveryPlanState{

  @override
  String toString() {
    return 'UpdateDeliveryPlanSuccess';
  }
}

class CreateDeliveryPlanSuccess extends DeliveryPlanState{

  @override
  String toString() {
    return 'CreateDeliveryPlanSuccess';
  }
}

class GetListDeliveryPlanEmpty extends DeliveryPlanState {

  @override
  String toString() {
    return 'GetListDeliveryPlanEmpty{}';
  }
}