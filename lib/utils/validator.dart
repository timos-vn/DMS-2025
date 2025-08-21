import 'package:dms/utils/utils.dart';
import 'package:flutter/cupertino.dart';

class Validators{
  static final RegExp _phoneRegex = RegExp(r'(\+84|0)\d{9}$');
  static final RegExp _emailRegex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  String? checkHotId(BuildContext context, String username) {
    if (Utils.isEmpty(username)) {
      return 'Hot ID không được để trống';
    }  else {
      return null;
    }
  }

  String? checkUsername(BuildContext context, String username) {
    if (Utils.isEmpty(username)) {
      return 'Vui lòng nhập tên đăng nhập';
    } else if (username.length < 4) {
      return 'Tên đăng nhập không hợp lệ';
    } else {
      return null;
    }
  }

  String? checkPass(BuildContext context, String password) {
    if (Utils.isEmpty(password)) {
      return 'Vui lòng nhập mật khẩu';
    } else if (password.length < 4) {
      return 'Mật khẩu phải có ít nhất 4 ký tự';
    } else {
      return null;
    }
  }

  String? checkPhoneNumber2(BuildContext context, String phoneNumber) {
    if (Utils.isEmpty(phoneNumber)) return null;
    if (!_phoneRegex.hasMatch(phoneNumber)) {
      return 'Số điện thoại không hợp lệ';
    } else {
      return null;
    }
  }

  String? checkEmail(BuildContext context, String email) {
    if (Utils.isEmpty(email)) {
      return 'Vui lòng nhập email';
    } else if (!_emailRegex.hasMatch(email)) {
      return 'Email không hợp lệ';
    } else {
      return null;
    }
  }
}