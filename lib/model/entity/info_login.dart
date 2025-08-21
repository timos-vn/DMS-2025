import 'dart:convert';

import 'package:equatable/equatable.dart';

class InfoLogin extends Equatable {
  final String code;
  final String name;
  final String hotURL;
  final String id;
  final String pass;
  final String dateLogin;
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String userName;
  final String fullName;
  final int woPrice;
  final int autoAddDiscount;
  final int addProductFollowStore;
  final int allowViewPriceAndTotalPriceProductGift;

  const InfoLogin(
      this.code,
      this.name,
      this.hotURL,
      this.id,
      this.pass,
      this.dateLogin,
      this.accessToken,
      this.refreshToken,
      this.userId,
      this.userName,this.fullName, this.woPrice, this.autoAddDiscount,
      this.addProductFollowStore, this.allowViewPriceAndTotalPriceProductGift
     );

  InfoLogin.fromDb(Map<String, dynamic> map)
      :
        code = map['code'],
        name = map['name'],
        hotURL = map['hot'],
        id = map['id'],
        pass = map['pass'],
        dateLogin = map['dateLogin'],
        accessToken = map['accessToken'],
        refreshToken = map['refreshToken'],
        userId = map['userId'],
        userName = map['userName'],
        fullName = map['fullName'],
        woPrice = map['woPrice'],
        autoAddDiscount = map['autoAddDiscount'],
        allowViewPriceAndTotalPriceProductGift = map['viewTotalMoneyGift'],
        addProductFollowStore = map['addProductFollowStore'];


  Map<String, dynamic> toMapForDb() {
    var map = <String, dynamic>{};
    map['code'] = code;
    map['name'] = name;
    map['hot'] = hotURL;
    map['id'] = id;
    map['pass'] = pass;
    map['dateLogin'] = dateLogin;

    map['accessToken'] = accessToken;
    map['refreshToken'] = refreshToken;
    map['userId'] = userId;
    map['userName'] = userName;
    map['fullName'] = fullName;
    map['woPrice'] = woPrice;
    map['autoAddDiscount'] = autoAddDiscount;
    map['addProductFollowStore'] = addProductFollowStore;
    map['viewTotalMoneyGift'] = allowViewPriceAndTotalPriceProductGift;
    return map;
  }

  @override
  List<Object> get props => [
    code,
    name,
    hotURL,
    id,
    pass,
    dateLogin,
    accessToken,
    refreshToken,
    userId,
    userName,fullName,woPrice,autoAddDiscount,addProductFollowStore,allowViewPriceAndTotalPriceProductGift
  ];
}
