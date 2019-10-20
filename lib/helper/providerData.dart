import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hasskit_2/model/CameraThumbnail.dart';
import 'package:hasskit_2/model/Entity.dart';
import 'package:hasskit_2/model/LoginData.dart';
import "package:http/http.dart" as http;
import 'Logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

GeneralData gd;

class GeneralData with ChangeNotifier {
  int _lastSelectedRoom = 0;
  int get lastSelectedRoom => _lastSelectedRoom;
  set lastSelectedRoom(int val) {
    if (val == null) {
      throw new ArgumentError();
    }
    if (_lastSelectedRoom != val) {
      _lastSelectedRoom = val;
      notifyListeners();
    }
  }

  String _url = "";
  String get url => _url;
  set url(String val) {
    if (val == null) {
      throw new ArgumentError();
    }
    if (_url != val) {
      _url = val;
      notifyListeners();
    }
  }

  String _connectionStatus = "";
  String get connectionStatus => _connectionStatus;
  set connectionStatus(String val) {
    if (val == null) {
      throw new ArgumentError();
    }
    if (_connectionStatus != val) {
      _connectionStatus = val;
      notifyListeners();
    }
  }

  void saveBool(String key, bool content) async {
    var _preferences = await SharedPreferences.getInstance();
    _preferences.setBool(key, content);
    Logger.d("saveBool: key $key content $content");
  }

  Future<bool> getBool(String key) async {
    var _preferences = await SharedPreferences.getInstance();
    var value = _preferences.getBool(key) ?? false;
    return value;
  }

  void saveString(String key, String content) async {
    var _preferences = await SharedPreferences.getInstance();
    _preferences.setString(key, content);
    Logger.d("saveString: key $key content $content");
  }

  Future<String> getString(String key) async {
    var _preferences = await SharedPreferences.getInstance();
    var value = _preferences.getString(key) ?? "";
    return value;
  }

  get appBarThemeChanger {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.palette),
        onPressed: () {
          themeChange();
        },
      ),
    ];
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

  void sendHttpPost(String url, String authCode, BuildContext context) async {
    Logger.d("httpPost $url "
        "\nauthCode $authCode");
    Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded"
    };
    var body = "grant_type=authorization_code"
        "&code=$authCode&client_id=$url/hasskit";
    http
        .post(url + "/auth/token", headers: headers, body: body)
        .then((response) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        gd.connectionStatus =
            "Got response from server with code ${response.statusCode}";

        var bodyDecode = json.decode(response.body);
        var loginData = LoginData.fromJson(bodyDecode);
        loginData.url = url;
        loginDataListUpdateAccessTime(loginData);
        Navigator.pop(context);
      } else {
        gd.connectionStatus =
            "Error response from server with code ${response.statusCode}";
        Navigator.pop(context);
      }
    }).catchError((e) {
      gd.connectionStatus = "Error response from server with e $e";
      Navigator.pop(context);
    });
  }

  List<Entity> _entities = [];
  UnmodifiableListView<Entity> get entities {
    return UnmodifiableListView(_entities);
  }

  List<Entity> badges = [];

  Map<String, List<Entity>> cards = {};

  void getStates(List<dynamic> message) {
    _entities.clear();

    for (dynamic mess in message) {
      Entity entity = Entity.fromJson(mess);
      _entities.add(entity);
    }

    Logger.d('_entities.length ${entities.length}');
    notifyListeners();
  }

  void getLovelaceConfig(dynamic message) {
    badges.clear();
    cards.clear();

//    var title = message['result']['title'];
//    Logger.d('title $title');
    var viewNumber = 0;
    var cardNumber = 0;

    List<dynamic> viewsParse = message['result']['views'];
    Logger.d('viewsParse.length ${viewsParse.length}');

    for (var viewParse in viewsParse) {
      //iterate over the list
      var titleView = viewParse['title'];
//      if (titleView == null) {
//        titleView = 'Unnamed $cardNumber';
//      }
      List<dynamic> badgesParse = viewParse['badges'];
      List<Entity> tempListView = [];
//      Logger.d(
//          '\nviewNumber $viewNumber badgesParse.length ${badgesParse.length}');

      List<Entity> tempListEntities = [];
      for (var badgeParse in badgesParse) {
//        Logger.d('badgeParse $badgeParse');
        entityValidationAdd(badgeParse.toString(), tempListEntities);
      }

      for (var entity in tempListEntities) {
        if (!badges.contains(entity)) {
          badges.add(entity);
        }
      }
//      Logger.d('badges.length ${badges.length}');

      List<dynamic> cardsParse = viewParse['cards'];
//      Logger.d('viewNumber $viewNumber cardsParse.length ${cardsParse.length}');

      for (var cardParse in cardsParse) {
        var titleCard = cardParse['title'];
//        if (titleCard == null) {
//          titleCard = 'Unnamed $cardNumber';
//        }
        var type = cardParse['type'];
//        Logger.d('cardParse title $title type $type');

        //entities type = 1 page view
        if (type == 'entities' || type == 'glance') {
          List<dynamic> entitiesParse = cardParse['entities'];
          List<Entity> tempListEntities = [];

          for (var entityParse in entitiesParse) {
            entityValidationAdd(entityParse.toString(), tempListEntities);
          }
          if (tempListEntities.length > 0) {
            cards['[$viewNumber-$cardNumber].$titleView.$titleCard'] =
                tempListEntities;
          }
          //all none entities in 1 pageview
        } else {
          var entityParse = cardParse['entity'];
          entityValidationAdd(entityParse.toString(), tempListView);
        }

        //Don't add empty card

        cardNumber++;
      }
      if (tempListView.length > 0) {
        cards['[$viewNumber-$cardNumber].$titleView'] = tempListView;
      }
      viewNumber++;
      cardNumber = 0;
    }

//    Logger.d('\nbadges.length ${badges.length}');
//    for (int i = 0; i < badges.length; i++) {
//      Logger.d('  - ${i + 1}. ${badges[i].entityId}');
//    }

//    Logger.d('\ncards.length ${cards.length}');
//    var cardsKeys = cards.keys.toList();
//    for (var cardsKey in cardsKeys) {
////      Logger.d('\ncardskey $cardsKey length ${cards[cardsKey].length}');
//      int i = 0;
//      for (var entity in cards[cardsKey]) {
////        Logger.d('  - ${i + 1}. ${entity.entityId}');
//        i++;
//      }
//    }

    notifyListeners();
  }

  void entityValidationAdd(String entityId, List<Entity> list) {
    if (entityId == null) {
      Logger.d('entityValidationAdd $entityId null');
      return;
    }
    String entityIdOriginal = entityId;
    entityId = entityId.split(',').first;

    if (!entityId.contains('.')) {
      Logger.d('entityValidationAdd $entityIdOriginal not valid');
      return;
    }

    entityId = entityId.replaceAll('{entity: ', '');
    entityId = entityId.replaceAll('}', '');

    Entity entity;

    try {
      entity = entities.firstWhere((e) => e.entityId == entityId,
          orElse: () => null);
      if (entity != null) {
        list.add(entity);
      }
    } catch (e) {
      Logger.d('entityValidationAdd Error finding $entityId - $e');
    }
  }

  Map<int, String> cameraThumbnailsId = {};
  Map<String, DateTime> cameraRequestTime = {};
  Map<String, CameraThumbnail> cameraThumbnails = {};
  List<String> cameraActives = [];

  void camerasThumbnailUpdate(String entityId, String content) {
    CameraThumbnail cameraThumbnail = CameraThumbnail(
      entityId: entityId,
      receivedDateTime: DateTime.now(),
      content: base64Decode(content),
    );

    cameraThumbnails[entityId] = cameraThumbnail;
    notifyListeners();
  }

  int themeIndex = 3;
  List<ThemeData> themesData = [
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.grey,
    ),
    ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.grey,
    ),
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.red,
    ),
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.amber,
    ),
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.green,
    ),
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.teal,
    ),
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.cyan,
    ),
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
    ),
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.indigo,
    ),
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.purple,
    ),
  ];

  get currentTheme {
    return themesData[themeIndex];
  }

  themeChange() {
    themeIndex = themeIndex + 1;
    if (themeIndex >= themesData.length) {
      themeIndex = 0;
    }
    Logger.d("themeIndex $themeIndex");
    notifyListeners();
  }

  List<LoginData> loginDataList = [];

  LoginData loginDataCurrent;

  loadLoginData() async {
    Logger.d("LoginData.loadLoginData");
    loginDataCurrent = null;
    String loginDataLisString = await gd.getString('loginDataList');
    if (loginDataLisString.length > 0) {
      Logger.d("FOUND loginDataLisString $loginDataLisString");

      List<dynamic> loginDataList = jsonDecode(loginDataLisString);
      Logger.d("loginDataList.length ${loginDataList.length}");
      for (var loginData in loginDataList) {
        LoginData newLoginData = LoginData(
          url: loginData["url"],
          longToken: loginData["longToken"],
          accessToken: loginData["accessToken"],
          expiresIn: loginData["expiresIn"],
          refreshToken: loginData["refreshToken"],
          tokenType: loginData["tokenType"],
          lastAccess: loginData["lastAccess"],
        );
        Logger.d("loginDataListAdd url ${newLoginData.url}");
//            "accessToken  ${newLoginData.accessToken} \n"
//            "expiresIn  ${newLoginData.expiresIn} \n"
//            "refreshToken  ${newLoginData.refreshToken} \n"
//            "tokenType  ${newLoginData.tokenType} \n"
//            "lastAccess  ${newLoginData.lastAccess} \n");
        loginDataListAdd(newLoginData);
      }
      Logger.d("loginDataList.length ${loginDataList.length}");
    } else {
      Logger.d("CAN NOT FIND loginDataList");
    }
    loginDataListSortAndSave();
  }

  void loginDataListAdd(LoginData loginData) {
    Logger.d("LoginData.loginDataListAdd ${loginData.url}");
    var loginDataOld = loginDataList
        .firstWhere((rec) => rec.url == loginData.url, orElse: () => null);
    if (loginDataOld == null) {
      loginDataList.add(loginData);
      Logger.d("loginDataListAdd ${loginData.url}");
    } else {
      loginDataOld = loginData;
      Logger.e("loginDataListAdd ALREADY HAVE ${loginData.url}");
    }
  }

  void loginDataListSortAndSave() {
    Logger.d("LoginData.loginDataListSortAndSave");
    if (loginDataList.length < 1) {
      return;
    }
    loginDataList.sort((a, b) => b.lastAccess.compareTo(a.lastAccess));
//    for (var e in loginDataList) {
//      Logger.d("\nloginDataListSave: ${e.url} ${e.lastAccess}");
//    }
    gd.saveString('loginDataList', jsonEncode(loginDataList));
    loginDataCurrent = loginDataList[0];
    Logger.d("loginDataCurrent: ${loginDataCurrent.url} ");
    notifyListeners();
  }

  void loginDataListDelete(LoginData loginData) {
    Logger.d("LoginData.loginDataListDelete ${loginData.url}");
    if (loginData != null) {
      loginDataList.remove(loginData);
      Logger.d("loginDataList.remove ${loginData.url}");
    } else {
      Logger.e("loginDataList.remove Can not find ${loginData.url}");
    }
    loginDataListSortAndSave();
  }

  void loginDataListUpdateAccessTime(LoginData loginData) {
    loginData.lastAccess = DateTime.now().toUtc().millisecondsSinceEpoch;
    Logger.d("loginDataListUpdateAccessTime ${loginData.lastAccess}");
    loginDataListSortAndSave();
  }

  get socketUrl {
    String recVal = gd.url;
    recVal = recVal.replaceAll("http", "ws");
    recVal = recVal + "/api/websocket";
    return recVal;
  }

  int _socketId = 0;
  get socketId => _socketId;
  set socketId(int value) {
    if (value == null) {
      throw new ArgumentError();
    }
    if (_socketId != value) {
      _socketId = value;
      notifyListeners();
    }
  }

  void socketIdIncrement() {
    socketId = socketId + 1;
  }

  int _subscribeEventsId = 0;
  get subscribeEventsId => _subscribeEventsId;
  set subscribeEventsId(int value) {
    if (value == null) {
      throw new ArgumentError();
    }
    if (_subscribeEventsId != value) {
      _subscribeEventsId = value;
      notifyListeners();
    }
  }

  int _getStatesId = 0;
  get getStatesId => _getStatesId;
  set getStatesId(int value) {
    if (value == null) {
      throw new ArgumentError();
    }
    if (_getStatesId != value) {
      _getStatesId = value;
      notifyListeners();
    }
  }

  int _loveLaceConfigId = 0;
  get loveLaceConfigId => _loveLaceConfigId;
  set loveLaceConfigId(int value) {
    if (value == null) {
      throw new ArgumentError();
    }
    if (_loveLaceConfigId != value) {
      _loveLaceConfigId = value;
      notifyListeners();
    }
  }

  bool _autoConnect = true;
  get autoConnect => _autoConnect;
  set autoConnect(bool value) {
    if (value != true && value != false) {
      throw new ArgumentError();
    }
    if (_autoConnect != value) {
      _autoConnect = value;
      notifyListeners();
    }
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
}
