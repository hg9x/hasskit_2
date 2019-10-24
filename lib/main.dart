import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/WebSocket.dart';
import 'package:hasskit_2/view/HomePage.dart';
import 'package:hasskit_2/view/RoomPage.dart';
import 'package:hasskit_2/view/SettingPage.dart';
import 'package:provider/provider.dart';
import 'helper/Logger.dart';
import 'helper/GeneralData.dart';
import 'helper/MaterialDesignIcons.dart';

//void main() => runApp(MyApp());
void main() {
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (context) => GeneralData()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    gd = Provider.of<GeneralData>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: gd.currentTheme,
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
  bool showLoading = true;

  Timer timer1;
  Timer timer5;
  Timer timer10;
  Timer timer30;

  @override
  void initState() {
    timer1 =
        Timer.periodic(Duration(seconds: 1), (Timer t) => timer1Callback());
    timer5 =
        Timer.periodic(Duration(seconds: 5), (Timer t) => timer5Callback());
    timer10 =
        Timer.periodic(Duration(seconds: 10), (Timer t) => timer10Callback());
    timer30 =
        Timer.periodic(Duration(seconds: 30), (Timer t) => timer30Callback());
    mainInitState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (showLoading) {
      return Container(
          color: Theme.of(context).backgroundColor,
          child: Center(child: CircularProgressIndicator()));
    } else {
      return Scaffold(
        body: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            currentIndex: 0,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                    MaterialDesignIcons.getIconDataFromIconName("mdi:star")),
                title: Text(gd.getRoomName(0)),
              ),
              BottomNavigationBarItem(
                icon: Icon(MaterialDesignIcons.getIconDataFromIconName(
                    "mdi:view-carousel")),
                title: Text("Room"),
              ),
              BottomNavigationBarItem(
                icon: Icon(MaterialDesignIcons.getIconDataFromIconName(
                    "mdi:settings")),
                title: Text('Setting'),
              ),
            ],
          ),
          tabBuilder: (context, index) {
            switch (index) {
              case 0:
                return CupertinoTabView(
                  builder: (context) {
                    return CupertinoPageScaffold(
                      child: HomePage(),
//                    child: HomePage(),
                    );
                  },
                );
              case 1:
                return CupertinoTabView(
                  builder: (context) {
                    return CupertinoPageScaffold(
                      child: RoomsPage(),
//                    child: RoomTab(),
                    );
                  },
                );
              case 2:
                return CupertinoTabView(
                  builder: (context) {
                    return CupertinoPageScaffold(
                      child: SettingPage(),
                    );
                  },
                );
              default:
                return CupertinoTabView(
                  builder: (context) {
                    return CupertinoPageScaffold(
                      child: HomePage(),
                    );
                  },
                );
            }
          },
        ),
      );
    }
  }

//  _getPage(int pageNumber) {
//    if (pageNumber == 1) {
////      Logger.d("pageNumber $pageNumber ");
//      return RoomsPage();
//    } else if (pageNumber == 2) {
////      Logger.d("pageNumber $pageNumber ");
//      return SettingPage();
//    } else {
////      Logger.d("pageNumber $pageNumber ");
//      return HomePage();
//    }
//  }

  mainInitState() async {
    log.w("showLoading $showLoading");
    log.w("mainInitState START await loginDataInstance.loadLoginData");
    await gd.loadLoginData();
    log.w("mainInitState END await loginDataInstance.loadLoginData");
//    await Future.delayed(const Duration(milliseconds: 1000));
    showLoading = false;
    log.w("showLoading $showLoading");
    setState(() {});
  }

  timer1Callback() {
//    updateCameraThumbnails();
  }

  timer5Callback() {}

  timer10Callback() {
    if (gd.connectionStatus != "Connected" && gd.autoConnect) {
      webSocket.initCommunication();
    }
  }

  timer30Callback() {
    if (gd.connectionStatus == "Connected") {
      var outMsg = {"id": gd.socketId, "type": "get_states"};
      var outMsgEncoded = json.encode(outMsg);
      webSocket.send(outMsgEncoded);
    }
  }
}
