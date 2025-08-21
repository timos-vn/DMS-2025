import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class NewCustomerEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefs extends NewCustomerEvent {
  @override
  String toString() => 'GetPrefs';
}

class AddNewCustomerEvent extends NewCustomerEvent {
  final String? code;
  final String? phoneNumber;
  final String? name;
  final String? name2;
  final int?    gender;
  final String? address;
  final String? birthday;
  final String? email;

  AddNewCustomerEvent({this.code,this.phoneNumber, this.name,this.name2, this.address, this.gender,this.birthday, this.email});

  @override
  String toString() => 'AddNewCustomerEvent';
}

class UploadAvatarEvent extends NewCustomerEvent {
  final bool isUploadFromCamera;

  UploadAvatarEvent(this.isUploadFromCamera);

  @override
  String toString() {
    return 'UploadAvatarEvent{isUploadFromCamera: $isUploadFromCamera}';
  }
}

class PickDate extends NewCustomerEvent {

 final DateTime dateTime;

  PickDate(this.dateTime);

  @override
  String toString() {
    return 'PickDate{}';
  }
}

class PickGender extends NewCustomerEvent {

  final int sex;

  PickGender(this.sex);

  @override
  String toString() {
    return 'PickGender{}';
  }
}

class ValidatePhoneNumber extends NewCustomerEvent {
  final String phoneNumber;

  ValidatePhoneNumber(this.phoneNumber);

  @override
  String toString() =>
      'ValidatePhoneNumber { phoneNumber: $phoneNumber }';
}

class ValidateEmail extends NewCustomerEvent {
  final String email;

  ValidateEmail(this.email);

  @override
  String toString() =>
      'ValidateEmail { email: $email }';
}

// class PickContact extends NewCustomerEvent {
//
//   @override
//   String toString() {
//     return 'PickContact{}';
//   }
// }

class ValidateAddress extends NewCustomerEvent {
  final String address;

  ValidateAddress(this.address);

  @override
  String toString() =>
      'ValidateAddress { address: $address }';
}

class PickAddress extends NewCustomerEvent {

  final String? location;

  PickAddress({this.location});

  @override
  String toString() {
    return 'PickAddress{location: $location}';
  }
}