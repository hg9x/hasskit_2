import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/ThemeInfo.dart';
import 'package:hasskit_2/helper/WebSocket.dart';
import 'package:hasskit_2/model/CameraThumbnail.dart';
import 'package:hasskit_2/model/Entity.dart';
import 'package:hasskit_2/model/LoginData.dart';
import 'package:hasskit_2/model/Room.dart';
import 'package:hasskit_2/view/EntitiesSliverGrid.dart';
import 'package:hasskit_2/view/RoomEditPage.dart';
import 'package:hasskit_2/view/SliverAppBarDelegate.dart';
import "package:http/http.dart" as http;
import 'Logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'MaterialDesignIcons.dart';

GeneralData gd;

class GeneralData with ChangeNotifier {
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

  double _mediaQueryWidth = 411.42857142857144;
  double get mediaQueryWidth => _mediaQueryWidth;
  set mediaQueryWidth(double val) {
//    log.d("mediaQueryWidth $val");
    if (val == null) {
      throw new ArgumentError();
    }
    if (_mediaQueryWidth != val) {
      _mediaQueryWidth = val;
      notifyListeners();
    }
  }

  double _mediaQueryHeight = 0;
  double get mediaQueryHeight => _mediaQueryHeight;
  set mediaQueryHeight(double val) {
//    log.d("mediaQueryHeight $val");
    if (val == null) {
      throw new ArgumentError();
    }
    if (_mediaQueryHeight != val) {
      _mediaQueryHeight = val;
      notifyListeners();
    }
  }

  double get textScaleFactor {
//    I/flutter ( 2137): DEBUG mediaQueryWidth 411.42857142857144
//    I/flutter ( 2137): DEBUG mediaQueryHeight 683.4285714285714
//    gd.mediaQueryWidth = MediaQuery.of(context).size.width;
//    gd.mediaQueryHeight = MediaQuery.of(context).size.height;
    double retVal = mediaQueryWidth / 411.42857142857144;
//    log.d("textScaleFactor $retVal");
    return retVal;
  }

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

  String _urlTextField = "";
  String get urlTextField => _urlTextField;
  set urlTextField(String val) {
    if (val == null) {
      throw new ArgumentError();
    }
    if (_urlTextField != val) {
      _urlTextField = val;
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
        gd.connectionStatus =
            "Init Websocket Communication to ${loginDataCurrent.url}";
        log.w(gd.connectionStatus);
        Navigator.pop(context, gd.connectionStatus);
//        gd.showSnackBar(gd.connectionStatus, context);
      } else {
        gd.connectionStatus =
            "Error response from server with code ${response.statusCode}";
        Navigator.pop(context, gd.connectionStatus);
//        gd.showSnackBar(gd.connectionStatus, context);
      }
    }).catchError((e) {
      gd.connectionStatus = "Error response from server with code $e";
      Navigator.pop(context, gd.connectionStatus);
//      gd.showSnackBar(gd.connectionStatus, context);
    });
  }

  List<Entity> _entities = [];
  UnmodifiableListView<Entity> get entities {
    return UnmodifiableListView(_entities);
  }

  void getStates(List<dynamic> message) {
    log.d('getStates');
    _entities.clear();

    for (dynamic mess in message) {
      Entity entity = Entity.fromJson(mess);
      _entities.add(entity);
    }

//    log.d('_entities.length ${entities.length}');
    log.d("_entities.length ${_entities.length}");
    notifyListeners();
  }

  List<String> lovelaceEntities = [];

  void getLovelaceConfig(dynamic message) {
    log.d('getLovelaceConfig');

    List<dynamic> viewsParse = message['result']['views'];
//    log.d('viewsParse.length ${viewsParse.length}');

    for (var viewParse in viewsParse) {
      List<dynamic> badgesParse = viewParse['badges'];
      for (var badgeParse in badgesParse) {
        badgeParse = processEntityId(badgeParse.toString());
//        log.d("badgeParse $badgeParse");
        if (isEntityNameValid(badgeParse) &&
            !lovelaceEntities.contains(badgeParse)) {
          lovelaceEntities.add(badgeParse);
        }
      }

      List<dynamic> cardsParse = viewParse['cards'];

      for (var cardParse in cardsParse) {
        var type = cardParse['type'];
        if (type == 'entities' || type == 'glance') {
          List<dynamic> entitiesParse = cardParse['entities'];
          for (var entityParse in entitiesParse) {
            entityParse = processEntityId(entityParse.toString());
//            log.d("entityParse 1 $entityParse");
            if (isEntityNameValid(entityParse) &&
                !lovelaceEntities.contains(entityParse)) {
              lovelaceEntities.add(entityParse);
            }
          }
        } else {
          var entityParse = cardParse['entity'];
          entityParse = processEntityId(entityParse.toString());
//          log.d("entityParse 2 $entityParse");
          if (isEntityNameValid(entityParse) &&
              !lovelaceEntities.contains(entityParse)) {
            lovelaceEntities.add(entityParse);
          }
        }
      }
    }

    log.d("lovelaceEntities.length ${lovelaceEntities.length} ");

    int i = 1;
    for (var entity in lovelaceEntities) {
      log.d("$i. lovelaceEntities $entity");
      i++;
    }
    notifyListeners();
  }

  void socketSubscribeEvents(dynamic message) {
//    print('socketSubscribeEvents $message');
    Entity newEntity = Entity.fromJson(message['event']['data']['new_state']);

    Entity oldEntity = entities.firstWhere(
        (e) => e != null && e.entityId == newEntity.entityId,
        orElse: () => null);

    if (oldEntity != null) {
      oldEntity.state = newEntity.state;
      oldEntity.icon = newEntity.icon;
      oldEntity.friendlyName = newEntity.friendlyName;

      if (newEntity.entityId.contains("climate.")) {
        oldEntity.hvacModes = newEntity.hvacModes;
        oldEntity.minTemp = newEntity.minTemp;
        oldEntity.maxTemp = newEntity.maxTemp;
        oldEntity.targetTempStep = newEntity.targetTempStep;
        oldEntity.temperature = newEntity.temperature;
        oldEntity.fanMode = newEntity.fanMode;
        oldEntity.fanModes = newEntity.fanModes;
        oldEntity.deviceCode = newEntity.deviceCode;
        oldEntity.manufacturer = newEntity.manufacturer;
      }

      if (newEntity.entityId.contains("fan.")) {
        oldEntity.speedList = newEntity.speedList;
        oldEntity.oscillating = newEntity.oscillating;
        oldEntity.speedLevel = newEntity.speedLevel;
        oldEntity.angle = newEntity.angle;
        oldEntity.directSpeed = newEntity.directSpeed;
        oldEntity.angle = newEntity.angle;
      }
      notifyListeners();
    } else {
      _entities.add(newEntity);
      log.e('WTF newEntity ${newEntity.entityId}');
      notifyListeners();
    }
  }

  bool isEntityNameValid(String entityId) {
    if (entityId == null) {
      log.d('isEntityNameValid entityName null');
      return false;
    }

    if (!entityId.contains('.')) {
      log.d('isEntityNameValid $entityId not valid');
      return false;
    }
    return true;
  }

  String processEntityId(String entityId) {
    if (entityId == null) {
      log.e('processEntityId String entityId null');
      return null;
    }

    String entityIdOriginal = entityId;
    entityId = entityId.split(',').first;

    if (!entityId.contains('.')) {
      log.e('processEntityId $entityIdOriginal not valid');
      return null;
    }

    entityId = entityId.replaceAll('{entity: ', '');
    entityId = entityId.replaceAll('}', '');

    return entityId;
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

  ThemeData get currentTheme {
    return ThemeInfo.themesData[themeIndex];
  }

  int _themeIndex = 0;
  int get themeIndex => _themeIndex;

  set themeIndex(int value) {
    {
      if (_themeIndex != value) {
        _themeIndex = value;
        notifyListeners();
      }
    }
  }

  themeChange() {
    themeIndex = themeIndex + 1;
    if (themeIndex >= ThemeInfo.themesData.length) {
      themeIndex = 0;
    }
    log.d("themeIndex $themeIndex");
    notifyListeners();
  }

  get cupertinoActionSheet {
    return CupertinoActionSheet(
      title: Text("title"),
      message: Text("Message"),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("CupertinoActionSheetAction"),
          onPressed: () {
            log.d("CupertinoActionSheet");
          },
        )
      ],
    );
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
      log.w("CAN NOT FIND loginDataList");
    }
    loginDataListSortAndSave();
    if (gd.loginDataList.length > 0) {
      loginDataCurrent = gd.loginDataList[0];
    }

    if (loginDataLisString.length > 0 &&
        loginDataList != null &&
        loginDataList.length > 0 &&
        loginDataList[0] != null &&
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
    if (loginDataList != null && loginDataList.length > 0) {
      loginDataList.sort((a, b) => b.lastAccess.compareTo(a.lastAccess));
      gd.saveString('loginDataList', jsonEncode(loginDataList));
      log.d("loginDataList.length ${loginDataList.length}");
      notifyListeners();
    } else {
      log.d("LoginData.loginDataListSortAndSave NO DATA");
    }
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

  bool _useSSL = true;
  get useSSL => _useSSL;
  set useSSL(bool value) {
    if (value != true && value != false) {
      throw new ArgumentError();
    }
    if (_useSSL != value) {
      _useSSL = value;
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

  List<Room> roomList = [];
  List<Room> roomListDefault = [
    Room(name: "Home", imageIndex: 4, entities: []),
    Room(name: "Living Room", imageIndex: 5, entities: []),
    Room(name: "Kitchen", imageIndex: 1, entities: []),
    Room(name: "Bedroom", imageIndex: 2, entities: []),
    Room(name: "Bathroom", imageIndex: 3, entities: []),
    Room(name: "Default Room", imageIndex: 0, entities: []),
  ];

  int get roomListLength {
    if (roomList.length - 1 < 0) {
      return 0;
    }
    return roomList.length - 1;
  }

  String getRoomName(int roomIndex) {
    if (roomList.length > roomIndex && roomList[roomIndex].name != null) {
      return roomList[roomIndex].name;
    }
    return "Home";
  }

  AssetImage getRoomImage(int roomIndex) {
    if (roomList.length > roomIndex &&
        roomList[roomIndex] != null &&
        roomList[roomIndex].imageIndex != null) {
      return AssetImage(backgroundImage[roomList[roomIndex].imageIndex]);
    }
    return AssetImage(backgroundImage[4]);
  }

  List<String> backgroundImage = [
    "assets/background_images/DarkBlue-iOS-13-Home-app-wallpaper.jpg",
    "assets/background_images/DarkGreen-iOS-13-Home-app-wallpaper.jpg",
    "assets/background_images/LightBlue-iOS-13-Home-app-wallpaper.jpg",
    "assets/background_images/LightGreen-iOS-13-Home-app-wallpaper.jpg",
    "assets/background_images/Orange-iOS-13-Home-app-wallpaper.jpg",
    "assets/background_images/Red-iOS-13-Home-app-wallpaper.jpg",
    "assets/background_images/Blue-Gradient.jpg",
    "assets/background_images/Green-Gradient.jpg",
    "assets/background_images/Yellow-Gradient.jpg",
    "assets/background_images/White-Gradient.jpg",
    "assets/background_images/Black-Gradient.jpg",
  ];

  setRoomBackgroundImage(Room room, int backgroundImageIndex) {
    if (room.imageIndex != backgroundImageIndex) {
      room.imageIndex = backgroundImageIndex;
      notifyListeners();
    }
    roomListSave();
  }

  setRoomName(Room room, String name) {
    log.w("setRoomName room.name ${room.name} name $name");
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
    log.w("deleteRoom roomIndex $roomIndex");
    if (roomList.length > roomIndex) {
      roomList.removeAt(roomIndex);
      notifyListeners();
    }
    roomListSave();
  }

  PageController pageController;
  addRoom() {
    log.w("addRoom ");
    var newRoom = Room(
      name: "New Room",
      imageIndex: 5,
      entities: [],
    );
    roomList.insert(roomList.length - 1, newRoom);
    pageController.jumpToPage(roomList.length - 3);

    roomListSave();
    notifyListeners();
  }

  moveRoom(int roomIndex, bool toLeft) {
    var room = roomList[roomIndex];

    if (toLeft) {
      roomList.removeAt(roomIndex);
      roomList.insert(roomIndex - 1, room);
      pageController.jumpToPage(roomIndex - 2);
//      lastSelectedRoom = roomIndex - 1;
    } else {
      roomList.removeAt(roomIndex);
      roomList.insert(roomIndex + 1, room);
      pageController.jumpToPage(roomIndex);
//      lastSelectedRoom = roomIndex + 1;
    }

    log.w(
        "moveRoom $roomIndex toLeft $toLeft lastSelectedRoom $lastSelectedRoom");
    roomListSave();
    notifyListeners();
  }

  void roomListSave() {
    gd.saveString('roomList ${gd.loginDataCurrent.url}', jsonEncode(roomList));
    log.d("${gd.loginDataCurrent.url} roomList.length ${roomList.length}");
  }

  roomListLoad(String url) async {
    log.w("roomListLoad $url ");
    String roomListLoadString = await gd.getString('roomList $url');
    if (roomListLoadString.length > 0) {
      log.w("FOUND roomListLoadString $roomListLoadString");
      List<dynamic> roomListJson = jsonDecode(roomListLoadString);

      roomList.clear();

      for (var roomJson in roomListJson) {
        Room room = Room.fromJson(roomJson);
        log.d("addRoom ${room.name}");
        roomList.add(room);
      }
      log.d("loginDataList.length ${roomList.length}");
    } else {
      log.w("CAN NOT FIND roomList $url adding default data");
      roomList.clear();
      for (var room in roomListDefault) {
        roomList.add(room);
      }
    }
  }

  SliverPersistentHeader makeHeader(
    Color color,
    Image image,
    String headerText,
    String subText,
    BuildContext context,
  ) {
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: SliverAppBarDelegate(
        minHeight: 30,
        maxHeight: 60,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: color,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 24),
                        ClipRRect(
                          borderRadius: new BorderRadius.circular(4.0),
                          child: SizedBox(
                            width: 28,
                            child: image,
                          ),
                        ),
                        SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(headerText),
                            subText.length > 0 ? Text(subText) : Container(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverPersistentHeader makeHeaderIcon(
    Color color,
    Icon icon,
    String headerText,
    String subText,
    BuildContext context,
  ) {
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: SliverAppBarDelegate(
        minHeight: 24,
        maxHeight: 60,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: color,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 24),
                        ClipRRect(
                          borderRadius: new BorderRadius.circular(4.0),
                          child: SizedBox(
                            width: 28,
                            child: icon,
                          ),
                        ),
                        SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              headerText,
                              textScaleFactor: gd.textScaleFactor,
                            ),
                            subText.length > 0
                                ? Text(
                                    subText,
                                    textScaleFactor: gd.textScaleFactor,
                                  )
                                : Container(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> customScrollView(int roomIndex, BuildContext context) {
    var emptySliver = SliverFixedExtentList(
      itemExtent: 0,
      delegate: SliverChildListDelegate(
        [Container()],
      ),
    );

    //entitiesInRoomsExceptDefault
//    List<Entity> entitiesFiltered = [];
//    if (roomIndex != roomList.length - 1) {
//      entitiesFiltered = gd.entities
//          //&& lovelaceEntities.contains(e.entityId)
//          .where((e) =>
////              e.friendlyName != null &&
////              e.friendlyName.length > 0 &&
//              gd.roomList[roomIndex].entities.contains(e.entityId))
//          .toList();
//    } else {
//      entitiesFiltered = gd.entities
////          && lovelaceEntities.contains(e.entityId)
//          .where((e) =>
////              e.friendlyName != null &&
////              e.friendlyName.length > 0 &&
//              entitiesInRoomsExceptDefault.contains(e.entityId))
//          .toList();
//    }
//
////    entitiesFiltered.sort((a, b) => a.friendlyName.compareTo(b.friendlyName));
    List<Entity> entitiesFiltered = [];
    if (roomIndex != roomList.length - 1) {
      entitiesFiltered = gd.entities
          .where((e) =>
              e.friendlyName != null &&
              e.friendlyName.length > 0 &&
              gd.roomList[roomIndex].entities.contains(e.entityId))
          .toList();
    } else {
      entitiesFiltered = gd.entities
          .where((e) =>
              e.friendlyName != null &&
              e.friendlyName.length > 0 &&
              !entitiesInRoomsExceptDefault.contains(e.entityId))
          .toList();
    }

    entitiesFiltered.sort((a, b) => a.friendlyName.compareTo(b.friendlyName));

    var lightSwitches = entitiesFiltered
        .where((e) => e.entityType == EntityType.lightSwitches)
        .toList();
    var climateFans = entitiesFiltered
        .where((e) => e.entityType == EntityType.climateFans)
        .toList();
    var cameras = entitiesFiltered
        .where((e) => e.entityType == EntityType.cameras)
        .toList();
    var mediaPlayers = entitiesFiltered
        .where((e) => e.entityType == EntityType.mediaPlayers)
        .toList();
    var accessories = entitiesFiltered
        .where((e) => e.entityType == EntityType.accessories)
        .toList();
    var scriptAutomation = entitiesFiltered
        .where((e) => e.entityType == EntityType.scriptAutomation)
        .toList();

    return [
      CupertinoSliverNavigationBar(
        leading: Image(
          image: AssetImage(
              'assets/images/icon_transparent_border_transparent.png'),
        ),
        largeTitle: Text(gd.getRoomName(roomIndex)),
        trailing: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              elevation: 1,
              backgroundColor: ThemeInfo.colorBottomSheet,
              isScrollControlled: false,
              useRootNavigator: true,
              builder: (BuildContext context) {
                return RoomEditPage(roomIndex: roomIndex);
              },
            );
          },
        ),
      ),
      roomIndex == gd.roomList.length - 1
          ? SliverFixedExtentList(
              itemExtent: 60,
              delegate: SliverChildListDelegate(
                [
                  Container(
                    padding: EdgeInsets.all(8),
                    color: ThemeInfo.colorBottomSheetReverse.withOpacity(0.5),
                    child: Center(
                      child: Text(
                        "Click Entities To Setup Room Position",
                        style: Theme.of(context).textTheme.title,
                        textScaleFactor: gd.textScaleFactor,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
            )
          : SliverFixedExtentList(
              itemExtent: 0,
              delegate: SliverChildListDelegate(
                [Container()],
              ),
            ),
      lightSwitches.length > 0
          ? gd.makeHeaderIcon(
              Theme.of(context).cardColor.withOpacity(0.2),
              Icon(MaterialDesignIcons.getIconDataFromIconName(
                  "mdi:toggle-switch")),
              'Light, Switchs...',
              "",
              context)
          : emptySliver,
      lightSwitches.length > 0
          ? EntitiesSliverGrid(
              entities: entitiesFiltered
                  .where((e) => e.entityType == EntityType.lightSwitches)
                  .toList(),
              crossAxisCount: 3,
              childAspectRatio: 1,
              entityType: EntityType.lightSwitches,
              roomIndex: roomIndex,
            )
          : emptySliver,
      climateFans.length > 0
          ? gd.makeHeaderIcon(
              Theme.of(context).cardColor.withOpacity(0.2),
              Icon(MaterialDesignIcons.getIconDataFromIconName(
                  "mdi:thermometer")),
              'Climates, Fans...',
              "",
              context)
          : emptySliver,
      climateFans.length > 0
          ? EntitiesSliverGrid(
              entities: entitiesFiltered
                  .where((e) => e.entityType == EntityType.climateFans)
                  .toList(),
              crossAxisCount: 3,
              childAspectRatio: 1,
              entityType: EntityType.climateFans,
              roomIndex: roomIndex,
            )
          : emptySliver,
      cameras.length > 0
          ? gd.makeHeaderIcon(
              Theme.of(context).cardColor.withOpacity(0.2),
              Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:cctv")),
              'Camera...',
              "",
              context)
          : emptySliver,
      cameras.length > 0
          ? EntitiesSliverGrid(
              entities: entitiesFiltered
                  .where((e) => e.entityType == EntityType.cameras)
                  .toList(),
              crossAxisCount: 1,
              childAspectRatio: 8 / 5,
              entityType: EntityType.cameras,
              roomIndex: roomIndex,
            )
          : emptySliver,
      mediaPlayers.length > 0
          ? gd.makeHeaderIcon(
              Theme.of(context).cardColor.withOpacity(0.2),
              Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:theater")),
              'Media Players...',
              "",
              context)
          : emptySliver,
      mediaPlayers.length > 0
          ? EntitiesSliverGrid(
              entities: entitiesFiltered
                  .where((e) => e.entityType == EntityType.mediaPlayers)
                  .toList(),
              crossAxisCount: 1,
              childAspectRatio: 8 / 5,
              entityType: EntityType.mediaPlayers,
              roomIndex: roomIndex,
            )
          : emptySliver,
      accessories.length > 0
          ? gd.makeHeaderIcon(
              Theme.of(context).cardColor.withOpacity(0.2),
              Icon(MaterialDesignIcons.getIconDataFromIconName(
                  "mdi:home-automation")),
              'Accessories...',
              "",
              context)
          : emptySliver,
      accessories.length > 0
          ? EntitiesSliverGrid(
              entities: entitiesFiltered
                  .where((e) => e.entityType == EntityType.accessories)
                  .toList(),
              crossAxisCount: 3,
              childAspectRatio: 8 / 8,
              entityType: EntityType.accessories,
              roomIndex: roomIndex,
            )
          : emptySliver,
      scriptAutomation.length > 0
          ? gd.makeHeaderIcon(
              Theme.of(context).cardColor.withOpacity(0.2),
              Icon(MaterialDesignIcons.getIconDataFromIconName(
                  "mdi:playlist-check")),
              'Automation, Script...',
              "",
              context)
          : emptySliver,
      scriptAutomation.length > 0
          ? EntitiesSliverGrid(
              entities: entitiesFiltered
                  .where((e) => e.entityType == EntityType.scriptAutomation)
                  .toList(),
              crossAxisCount: 3,
              childAspectRatio: 8 / 8,
              entityType: EntityType.accessories,
              roomIndex: roomIndex,
            )
          : emptySliver,
      SliverFixedExtentList(
        itemExtent: 60,
        delegate: SliverChildListDelegate(
          [Container()],
        ),
      ),
    ];
  }

  String textToDisplay(String text) {
    text = text.replaceAll('_', ' ');
    if (text.length > 1) {
      return text[0].toUpperCase() + text.substring(1);
    } else if (text.length > 0) {
      return text[0].toUpperCase();
    } else {
      return '???';
    }
  }

  void toggleStatus(Entity entity) {
    if (entity.entityType != EntityType.lightSwitches &&
        entity.entityType != EntityType.scriptAutomation &&
        entity.entityType != EntityType.climateFans &&
        entity.entityType != EntityType.mediaPlayers) {
      return;
    }
    runMultipleTimes();
    entity.toggleState();
    notifyListeners();
  }

  //https://stackoverflow.com/questions/17552757/is-there-any-way-to-cancel-a-dart-future
  Timer _runJustOnceAtTheEnd;

  void runMultipleTimes() {
    _runJustOnceAtTheEnd?.cancel();
    _runJustOnceAtTheEnd = null;

    // do your processing
//    print("runMultipleTimes!");

    _runJustOnceAtTheEnd = Timer(Duration(seconds: 5), onceAtTheEndOfTheBatch);
  }

  void onceAtTheEndOfTheBatch() {
    var outMsg = {"id": gd.socketId, "type": "get_states"};
    webSocket.send(json.encode(outMsg));
    gd.connectionStatus = "Sending get_states";
    log.w("Sending get_states 5 seconds after the last send spam!");
  }

  List<String> get entitiesInRoomsExceptDefault {
    List<String> recVal = [];
    for (int i = 0; i < roomList.length - 2; i++) {
      recVal = recVal + roomList[i].entities;
    }
    return recVal;
  }

  void removeRoomEntity(String entityId) {
    for (int i = 1; i < roomList.length; i++) {
      var roomEntities = roomList[i].entities;
      if (roomEntities.contains(entityId)) {
        roomEntities.remove(entityId);
      }
    }
  }

  void showInRoom(String entityId, int roomIndex, String friendlyName,
      BuildContext context) {
    log.w("Show In Room entityId $entityId roomIndex $roomIndex");
    if (roomIndex == 0) {
      if (roomList[roomIndex].entities.contains(entityId)) {
        roomList[roomIndex].entities.remove(entityId);
        showSnackBar(
            "Remove $friendlyName from ${roomList[roomIndex].name}", context);
      } else {
        roomList[roomIndex].entities.add(entityId);
        showSnackBar(
            "Show $friendlyName  in ${roomList[roomIndex].name}", context);
      }
      notifyListeners();
    } else {
      if (roomList[roomIndex].entities.contains(entityId)) {
        roomList[roomIndex].entities.remove(entityId);
        showSnackBar(
            "Remove $friendlyName  from ${roomList[roomIndex].name}", context);
      } else {
        removeRoomEntity(entityId);
        roomList[roomIndex].entities.add(entityId);
        showSnackBar(
            "Show $friendlyName  in ${roomList[roomIndex].name}", context);
      }
    }
    roomListSave();
    notifyListeners();
  }

  IconData climateModeToIcon(String text) {
    text = text.toLowerCase();
    if (text.contains('off')) {
      return MaterialDesignIcons.getIconDataFromIconName('mdi:power');
    }
    if (text.contains('cool')) {
      return MaterialDesignIcons.getIconDataFromIconName('mdi:snowflake');
    }
    if (text.contains('heat')) {
      return MaterialDesignIcons.getIconDataFromIconName('mdi:weather-sunny');
    }
    if (text.contains('fan')) {
      return MaterialDesignIcons.getIconDataFromIconName('mdi:fan');
    }
    return MaterialDesignIcons.getIconDataFromIconName('mdi:thermometer');
  }

  Color climateModeToColor(String text) {
    text = text.toLowerCase();
    if (text.contains('off')) {
      return Colors.black.withOpacity(0.5);
    }
    if (text.contains('heat')) {
      return Colors.red;
    }
    if (text.contains('cool')) {
      return Colors.green;
    }
    return Colors.amber;
  }
}
