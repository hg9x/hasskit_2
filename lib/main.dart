import 'dart:convert';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:hasskit_2/model/LoginData.dart';
import 'package:hasskit_2/view/HomePage.dart';
import 'package:hasskit_2/view/RoomPage.dart';
import 'package:hasskit_2/view/SettingPage.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'helper/Logger.dart';
import 'model/Setting.dart';
import 'model/ThemeProvider.dart';

//void main() => runApp(MyApp());
void main() {
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
  Logger.level = Level.debug;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (context) => ThemeProvider()),
        ChangeNotifierProvider(builder: (context) => SettingProvider()),
        ChangeNotifierProvider(builder: (context) => LoginDataProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    pTheme = Provider.of<ThemeProvider>(context);
    pSetting = Provider.of<SettingProvider>(context);
    pLoginData = Provider.of<LoginDataProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: pTheme.currentTheme,
      title: 'HassKit',
      home: HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int pageNumber = 2;
  @override
  void initState() {
    loadSavedData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _getPage(pageNumber),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      bottomNavigationBar: SafeArea(
        child: FancyBottomNavigation(
          initialSelection: pageNumber,
          barBackgroundColor: Theme.of(context).primaryColorLight,
          tabs: [
            TabData(
              title: "Home",
              iconData: Icons.home,
//            onclick: () {},
            ),
            TabData(
              title: "Room",
              iconData: Icons.view_carousel,
//            onclick: () {},
            ),
            TabData(
              title: "Setting",
              iconData: Icons.settings,
//            onclick: () {},
            ),
          ],
          onTabChangedListener: (position) {
            setState(() {
              pageNumber = position;
              log.d("onTabChangedListener position $position");
            });
          },
        ),
      ),

//      drawer: Drawer(
//        child: ListView(
//          children: <Widget>[Text("Hello"), Text("World")],
//        ),
//      ),
    );
  }

  _getPage(int pageNumber) {
    if (pageNumber == 1) {
//      log.d("pageNumber $pageNumber ");
      return RoomPage();
    } else if (pageNumber == 2) {
//      log.d("pageNumber $pageNumber ");
      return SettingPage();
    } else {
//      log.d("pageNumber $pageNumber ");
      return HomePage();
    }
  }

  void loadSavedData() async {
    String loginDataLisString = await pSetting.getString('loginDataList');
    if (loginDataLisString.length > 0) {
      log.d("loginDataLisString $loginDataLisString");

      List<dynamic> loginDataList = jsonDecode(loginDataLisString);
      log.d("loginDataList.length ${loginDataList.length}");
      for (var loginData in loginDataList) {
        LoginData newLoginData = LoginData(
          url: loginData["url"],
          accessToken: loginData["accessToken"],
          expiresIn: loginData["expiresIn"],
          refreshToken: loginData["refreshToken"],
          tokenType: loginData["tokenType"],
          lastAccess: loginData["lastAccess"],
        );
        log.d("pSetting.loginDataList.add url ${newLoginData.url} \n"
            "accessToken  ${newLoginData.accessToken} \n"
            "expiresIn  ${newLoginData.expiresIn} \n"
            "refreshToken  ${newLoginData.refreshToken} \n"
            "tokenType  ${newLoginData.tokenType} \n"
            "lastAccess  ${newLoginData.lastAccess} \n");
        pLoginData.loginDataListAdd(newLoginData);
      }

      pLoginData.loginDataListSortAndSave();
      log.d("pSetting.loginDataList.length ${pLoginData.loginDataList.length}");
    } else {
      log.d("CAN NOT FIND loginDataList");
    }
  }
}
