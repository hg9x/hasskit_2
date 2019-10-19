import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:hasskit_2/helper/Logger.dart';
import 'package:hasskit_2/model/Setting.dart';

class LoginData {
  String url;
  String accessToken;
  int expiresIn;
  String refreshToken;
  String tokenType;
  LoginData({
    this.url,
    this.accessToken,
    this.expiresIn,
    this.refreshToken,
    this.tokenType,
  });

//  factory LoginData.fromJson(Map<String, dynamic> json)
//      : accessToken = json['access_token'],
//        expiresIn = json['expires_in'],
//        refreshToken = json['refresh_token'],
//        tokenType = json['token_type'];

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      url: json['url'],
      accessToken: json['access_token'],
      expiresIn: json['expires_in'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
    );
  }
  Map<String, dynamic> toJson() => {
        'url': url,
        'accessToken': accessToken,
        'expiresIn': expiresIn,
        'refreshToken': refreshToken,
        'tokenType': tokenType,
      };
}

LoginDataProvider pLoginData;

class LoginDataProvider with ChangeNotifier {
  List<LoginData> loginDataList = [];
  void loginDataListAdd(LoginData loginData) {
    var loginDataOld = loginDataList
        .firstWhere((rec) => rec.url == loginData.url, orElse: () => null);
    if (loginDataOld == null) {
      loginDataList.add(loginData);
      log.d("loginDataListAdd ${loginData.url}");
    } else {
      log.e("loginDataListAdd ALREADY HAVE ${loginData.url}");
    }
    pSetting.saveString('loginDataList', jsonEncode(loginDataList));
    notifyListeners();
  }

  void loginDataListUpdate(LoginData loginData) {
    var loginDataOld = loginDataList
        .firstWhere((rec) => rec.url == loginData.url, orElse: () => null);
    if (loginDataOld != null) {
      loginDataOld.url = loginData.url;
      loginDataOld.accessToken = loginData.accessToken;
      loginDataOld.expiresIn = loginData.expiresIn;
      loginDataOld.refreshToken = loginData.refreshToken;
      loginDataOld.tokenType = loginData.tokenType;
      log.d(
          "loginDataListUpdate loginDataOld = loginData data ${loginData.url}");
    } else {
      loginDataList.add(loginData);
      log.d("loginDataListUpdate.add ${loginData.url}");
    }
    pSetting.saveString('loginDataList', jsonEncode(loginDataList));
    notifyListeners();
  }

  void loginDataListDelete(String url) {
    var loginData =
        loginDataList.firstWhere((rec) => rec.url == url, orElse: () => null);
    if (loginData != null) {
      loginDataList.remove(loginData);
      log.d("loginDataListDelete $url");
    } else {
      log.e("loginDataListDelete Can not find $url");
    }
    pSetting.saveString('loginDataList', jsonEncode(loginDataList));
    notifyListeners();
  }
}
