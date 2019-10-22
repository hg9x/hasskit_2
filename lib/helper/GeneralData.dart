import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/WebSocket.dart';
import 'package:hasskit_2/model/CameraThumbnail.dart';
import 'package:hasskit_2/model/Entity.dart';
import 'package:hasskit_2/model/LoginData.dart';
import 'package:hasskit_2/model/Room.dart';
import "package:http/http.dart" as http;
import 'Logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

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
    log.d("saveBool: key $key content $content");
  }

  Future<bool> getBool(String key) async {
    var _preferences = await SharedPreferences.getInstance();
    var value = _preferences.getBool(key) ?? false;
    return value;
  }

  void saveString(String key, String content) async {
    var _preferences = await SharedPreferences.getInstance();
    _preferences.setString(key, content);
    log.d("saveString: key $key content $content");
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
    log.d("httpPost $url "
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
//        log.d("bodyDecode $bodyDecode\n"
//            "url ${loginData.url}\n"
//            "longToken ${loginData.longToken}\n"
//            "accessToken ${loginData.accessToken}\n"
//            "expiresIn ${loginData.expiresIn}\n"
//            "refreshToken ${loginData.refreshToken}\n"
//            "tokenType ${loginData.tokenType}\n"
//            "lastAccess ${loginData.lastAccess}\n"
//            "");
        gd.loginDataCurrent = loginData;
        gd.loginDataListAdd(loginData);
        loginDataListSortAndSave();
        webSocket.initCommunication();
        log.w(
            "webSocket.initCommunication loginDataCurrent ${loginDataCurrent.url}");
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

    log.d('_entities.length ${entities.length}');
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
    log.d('viewsParse.length ${viewsParse.length}');

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
      log.d('entityValidationAdd $entityId null');
      return;
    }
    String entityIdOriginal = entityId;
    entityId = entityId.split(',').first;

    if (!entityId.contains('.')) {
      log.d('entityValidationAdd $entityIdOriginal not valid');
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
      log.d('entityValidationAdd Error finding $entityId - $e');
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

  int themeIndex = 7;
  themeChange() {
    themeIndex = themeIndex + 1;
    if (themeIndex >= themesData.length) {
      themeIndex = 0;
    }
    log.d("themeIndex $themeIndex");
    notifyListeners();
  }

  List<LoginData> loginDataList = [];

  int get loginDataListLength {
    return loginDataList.length;
  }

  LoginData loginDataCurrent = LoginData();

  loadLoginData() async {
    log.d("LoginData.loadLoginData");
    loginDataCurrent = null;
    String loginDataLisString = await gd.getString('loginDataList');
    if (loginDataLisString.length > 0) {
      log.d("FOUND loginDataLisString $loginDataLisString");
      List<dynamic> loginDataList = jsonDecode(loginDataLisString);
      log.d("loginDataList.length ${loginDataList.length}");
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
        log.d("loginDataListAdd url ${newLoginData.url}");
//            "accessToken  ${newLoginData.accessToken} \n"
//            "expiresIn  ${newLoginData.expiresIn} \n"
//            "refreshToken  ${newLoginData.refreshToken} \n"
//            "tokenType  ${newLoginData.tokenType} \n"
//            "lastAccess  ${newLoginData.lastAccess} \n");
        loginDataListAdd(newLoginData);
      }
      log.d("loginDataList.length ${loginDataList.length}");
    } else {
      log.d("CAN NOT FIND loginDataList");
    }
    loginDataListSortAndSave();
    if (gd.loginDataList.length > 0) {
      loginDataCurrent = gd.loginDataList[0];
    }

    if (loginDataLisString.length > 0 &&
        loginDataList[0].longToken != null &&
        loginDataList[0].longToken.length > 0) {
      loginDataCurrent = loginDataList[0];
      webSocket.initCommunication();
      log.w("Auto connect to ${loginDataCurrent.url}");
    }
  }

  void loginDataListAdd(LoginData loginData) {
    log.d("LoginData.loginDataListAdd ${loginData.url}");
    var loginDataOld = loginDataList
        .firstWhere((rec) => rec.url == loginData.url, orElse: () => null);
    if (loginDataOld == null) {
      loginDataList.add(loginData);
      log.d("loginDataListAdd ${loginData.url}");
    } else {
      loginDataOld.url = loginData.url;
      loginDataOld.accessToken = loginData.accessToken;
      loginDataOld.longToken = loginData.longToken;
      loginDataOld.expiresIn = loginData.expiresIn;
      loginDataOld.refreshToken = loginData.refreshToken;
      loginDataOld.tokenType = loginData.tokenType;
      loginDataOld.lastAccess = DateTime.now().toUtc().millisecondsSinceEpoch;
      log.e("loginDataListAdd ALREADY HAVE ${loginData.url}");
    }
    notifyListeners();
  }

  void loginDataListSortAndSave() {
    log.d("LoginData.loginDataListSortAndSave");
    if (loginDataList.length > 1) {
      loginDataList.sort((a, b) => b.lastAccess.compareTo(a.lastAccess));
    }
    gd.saveString('loginDataList', jsonEncode(loginDataList));
    log.d("loginDataList.length ${loginDataList.length}");
    notifyListeners();
  }

  void loginDataListDelete(LoginData loginData) {
    log.d("LoginData.loginDataListDelete ${loginData.url}");
    if (loginData != null) {
      loginDataList.remove(loginData);
      log.d("loginDataList.remove ${loginData.url}");
    } else {
      log.e("loginDataList.remove Can not find ${loginData.url}");
    }
    loginDataListSortAndSave();
  }

  get socketUrl {
    String recVal = loginDataCurrent.url;
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

  int _longTokenId = 0;
  get longTokenId => _longTokenId;
  set longTokenId(int value) {
    if (value == null) {
      throw new ArgumentError();
    }
    if (_longTokenId != value) {
      _longTokenId = value;
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

  bool _webViewLoading = false;
  bool get webViewLoading {
    return _webViewLoading;
  }

  set webViewLoading(bool value) {
    if (value != true && value != false) {
      throw new ArgumentError();
    }
    if (_webViewLoading != value) {
      _webViewLoading = value;
      notifyListeners();
    }
  }

//  bool _showLoading = false;
//  bool get showLoading {
//    return _showLoading;
//  }
//
//  set showLoading(bool value) {
//    if (value != true && value != false) {
//      throw new ArgumentError();
//    }
//    if (_showLoading != value) {
//      _showLoading = value;
//      notifyListeners();
//    }
//  }

  String trimUrl(String url) {
    url = url.trim();
    if (url.substring(url.length - 1, url.length) == '/') {
      url = url.substring(0, url.length - 1);
      log.w("$url contain last /");
    }
    return url;
  }

  List<Room> roomList = [
    Room(name: "Favorite", imageIndex: 4),
    Room(name: "Living Room", imageIndex: 0),
    Room(name: "Kitchen", imageIndex: 1),
    Room(name: "Bedroom", imageIndex: 2),
    Room(name: "Default Room", imageIndex: 3),
    Room(name: "Add New", imageIndex: 5),
  ];

  Room roomAddDefault = Room(name: "Add New", imageIndex: 5);
  List<String> backgroundImage = [
    "assets/background_images/DarkBlue-iOS-13-Home-app-wallpaper.jpg",
    "assets/background_images/DarkGreen-iOS-13-Home-app-wallpaper.jpg",
    "assets/background_images/LightBlue-iOS-13-Home-app-wallpaper.jpg",
    "assets/background_images/LightGreen-iOS-13-Home-app-wallpaper.jpg",
    "assets/background_images/Orange-iOS-13-Home-app-wallpaper.jpg",
    "assets/background_images/Red-iOS-13-Home-app-wallpaper.jpg",
  ];

  setRoomBackgroundImage(Room room, int backgroundImageIndex) {
    if (room.imageIndex != backgroundImageIndex) {
      room.imageIndex = backgroundImageIndex;
      notifyListeners();
    }
    roomListSave();
  }

  setRoomName(Room room, String name) {
    if (room.name != name) {
      room.name = name;
      notifyListeners();
    }
    roomListSave();
  }

  setRoomBackgroundAndName(Room room, int backgroundImageIndex, String name) {
    setRoomBackgroundImage(room, backgroundImageIndex);
    setRoomName(room, name);
  }

  deleteRoom(int roomIndex) {
    if (roomList.length >= roomIndex) {
      roomList.removeAt(roomIndex);
      notifyListeners();
    }
    roomListSave();
  }

  addRoom(Room newRoom) {
    roomList.insert(roomList.length - 2, newRoom);
    roomList.last.name = roomAddDefault.name;
    roomList.last.imageIndex = roomAddDefault.imageIndex;
    roomListSave();
    notifyListeners();
  }

  void roomListSave() {
    gd.saveString('roomList ${gd.loginDataCurrent.url}', jsonEncode(roomList));
    log.d("${gd.loginDataCurrent.url} roomList.length ${roomList.length}");
  }
}
