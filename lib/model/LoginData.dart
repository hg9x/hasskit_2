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
  int lastAccess;
  LoginData({
    this.url,
    this.accessToken,
    this.expiresIn,
    this.refreshToken,
    this.tokenType,
    this.lastAccess,
  });

  lastAccessUpdate() {
    lastAccess = DateTime.now().toUtc().millisecondsSinceEpoch;
  }

  Duration get timeDurationSinceLastAccess {
    var totalDiff = DateTime.now().toUtc().millisecondsSinceEpoch - lastAccess;
    return Duration(milliseconds: totalDiff);
  }

  String get timeSinceLastAccess {
    var format =
        "${timeDurationSinceLastAccess.inDays}:${timeDurationSinceLastAccess.inHours.remainder(24)}:${timeDurationSinceLastAccess.inMinutes.remainder(60)}:${(timeDurationSinceLastAccess.inSeconds.remainder(60))}";
    var spit = format.split(":");
    var recVal = "";
    bool lessThanAMinute = true;

    var day = int.parse(spit[0]);
    var hour = int.parse(spit[1]);
    var minute = int.parse(spit[2]);
//    var second = int.parse(spit[3]);

    if (day > 0) {
      String s = " day";
      if (day > 1) {
        s = " days";
      }
      recVal = recVal + day.toString() + s;
      lessThanAMinute = false;
    }
    if (hour > 0) {
      String s = " hour";
      if (hour > 1) {
        s = " hours";
      }
      recVal = recVal + hour.toString() + s;
      lessThanAMinute = false;
    }
    if (minute > 0) {
      String s = " minute";
      if (minute > 1) {
        s = " minutes";
      }
      recVal = recVal + minute.toString() + s;
      lessThanAMinute = false;
    }

    if (lessThanAMinute) {
      recVal = "less than a minute";
    }

    return recVal;
  }
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
        'lastAccess': lastAccess,
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
    notifyListeners();
  }

  void loginDataListSortAndSave() {
    loginDataList.sort((a, b) => b.lastAccess.compareTo(a.lastAccess));
    log.d("loginDataListSave loginDataList.sort");
    for (var e in loginDataList) {
      log.d("\nloginDataListSave: ${e.url} ${e.lastAccess}");
    }
    pSetting.saveString('loginDataList', jsonEncode(loginDataList));
    notifyListeners();
  }

  void loginDataListUpdateAccessTime(LoginData loginData) {
    var loginDataOld = loginDataList
        .firstWhere((rec) => rec.url == loginData.url, orElse: () => null);
    if (loginDataOld != null) {
      loginDataOld.url = loginData.url;
      loginDataOld.accessToken = loginData.accessToken;
      loginDataOld.expiresIn = loginData.expiresIn;
      loginDataOld.refreshToken = loginData.refreshToken;
      loginDataOld.tokenType = loginData.tokenType;
      loginDataOld.lastAccessUpdate();
      log.d(
          "loginDataListUpdate loginDataOld = loginData data ${loginData.url}");
    } else {
      loginData.lastAccessUpdate();
      loginDataList.add(loginData);
      log.d("loginDataListUpdate.add ${loginData.url}");
    }
    loginDataListSortAndSave();
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
    loginDataListSortAndSave();
  }
}
