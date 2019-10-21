import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:hasskit_2/view/HomePage.dart';
import 'package:hasskit_2/view/RoomPage.dart';
import 'package:hasskit_2/view/SettingPage.dart';
import 'package:provider/provider.dart';
import 'helper/Logger.dart';
import 'helper/GeneralData.dart';

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
  @override
  void initState() {
    mainInitState();
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
//              Logger.d("onTabChangedListener position $position");
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
//      Logger.d("pageNumber $pageNumber ");
      return RoomPage();
    } else if (pageNumber == 2) {
//      Logger.d("pageNumber $pageNumber ");
      return SettingPage();
    } else {
//      Logger.d("pageNumber $pageNumber ");
      return HomePage();
    }
  }

  mainInitState() async {
    log.w("mainInitState START await loginDataInstance.loadLoginData");
    await gd.loadLoginData();
    log.w("mainInitState END await loginDataInstance.loadLoginData");
  }
}
