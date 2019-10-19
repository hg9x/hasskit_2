import "dart:async";
import "dart:convert";
import "package:flutter/material.dart";
import "package:hasskit_2/model/LoginData.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:http/http.dart" as http;
import 'ThemeProvider.dart';

SettingProvider pSetting;

class SettingProvider with ChangeNotifier {
  int lastSelectedRoom = 0;

  void saveBool(String key, bool content) async {
    var _preferences = await SharedPreferences.getInstance();
    _preferences.setBool(key, content);
    print("saveBool: key $key content $content");
  }

  Future<bool> getBool(String key) async {
    var _preferences = await SharedPreferences.getInstance();
    var value = _preferences.getBool(key) ?? false;
    return value;
  }

  void saveString(String key, String content) async {
    var _preferences = await SharedPreferences.getInstance();
    _preferences.setString(key, content);
    print("saveString: key $key content $content");
  }

  Future<String> getString(String key) async {
    var _preferences = await SharedPreferences.getInstance();
    var value = _preferences.getString(key) ?? "";
    return value;
  }

  String connectionStatus;

  httpPost(String url, String authCode, String clientId,
      BuildContext context) async {
    Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded"
    };
    var body = "grant_type=authorization_code"
        "&code=$authCode&client_id=$clientId";
    http
        .post(url + "/auth/token", headers: headers, body: body)
        .then((response) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        connectionStatus =
            "Got response from server with code ${response.statusCode}";

        var bodyDecode = json.decode(response.body);
        var loginData = LoginData.fromJson(bodyDecode);
        loginData.url = url;
        pLoginData.loginDataListUpdate(loginData);
        Navigator.pop(context);
      } else {
        connectionStatus =
            "Error response from server with code ${response.statusCode}";
        pSetting.showSnackBar('Token create success...', context);
        Navigator.pop(context);
      }
    }).catchError((e) {
      connectionStatus = "Error response from server with e $e";
      Navigator.pop(context);
    });
  }

  get appBarThemeChanger {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.palette),
        onPressed: () {
          pTheme.themeChange();
        },
      ),
    ];
  }

  bool _loading = false;
  bool get loading {
    return _loading;
  }

  set loading(bool value) {
    if (value != true && value != false) {
      throw new ArgumentError();
    }
    if (_loading != value) {
      _loading = value;
      notifyListeners();
    }
  }

  showSnackBar(String text, BuildContext context) {
    Scaffold.of(context)
        .removeCurrentSnackBar(reason: SnackBarClosedReason.remove);
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: Colors.black45,
    ));
  }

  removeSnackBar(BuildContext context) {
    Scaffold.of(context)
        .removeCurrentSnackBar(reason: SnackBarClosedReason.remove);
  }
}
