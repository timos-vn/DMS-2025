import 'package:equatable/equatable.dart';

abstract class MenuState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialMenuState extends MenuState {
  @override
  String toString() {
    return 'InitialMenuState{}';
  }
}

class GetPrefsSuccess extends MenuState {
  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class LogOutAppSuccess extends MenuState {
  @override
  String toString() {
    return 'LogOutAppSuccess{}';
  }
}

class DeleteAccountSuccess extends MenuState {
  @override
  String toString() {
    return 'DeleteAccountSuccess{}';
  }
}

class MenuLoading extends MenuState {
  @override
  String toString() => 'MenuLoading';
}

class MenuFailure extends MenuState {
  final String error;

  MenuFailure(this.error);

  @override
  String toString() => 'MenuFailure';
}

class GetListHistoryEmployeeEmpty extends MenuState {
  @override
  String toString() {
    return 'GetListHistoryEmployeeEmpty{}';
  }
}

class GetListTypeVoucherEmpty extends MenuState {
  @override
  String toString() {
    return 'GetListTypeVoucherEmpty{}';
  }
}

class GetListTypeVoucherSuccess extends MenuState {
  @override
  String toString() {
    return 'GetListTypeVoucherSuccess{}';
  }
}

class GetInformationCardSuccess extends MenuState {
  final bool updateLocation;

  GetInformationCardSuccess({required this.updateLocation});

  @override
  String toString() {
    return 'GetInformationCardSuccess{}';
  }
}

class GetListHistoryEmployeeSuccess extends MenuState {
  @override
  String toString() {
    return 'GetListHistoryEmployeeSuccess{}';
  }
}

class ChangePageViewSuccess extends MenuState {
  final int valueChange;

  ChangePageViewSuccess(this.valueChange);

  @override
  String toString() {
    return 'ChangePageViewSuccess{valueChange:$valueChange}';
  }
}

class GetTotalUnreadNotificationSuccess extends MenuState {
  @override
  String toString() {
    return 'GetTotalUnreadNotificationSuccess';
  }
}

class ChangePassWordSuccess extends MenuState {
  final String message;
  ChangePassWordSuccess({required this.message});
  @override
  String toString() {
    return 'ChangePassWordSuccess';
  }
}
