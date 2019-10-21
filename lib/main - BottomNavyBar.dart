import 'package:bottom_navy_bar/bottom_navy_bar.dart';
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
  PageController _pageController = PageController();

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
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: pageNumber,
        showElevation: true, // use this to remove appBar's elevation
        onItemSelected: (index) => setState(() {
          pageNumber = index;
          _getPage(pageNumber);
        }),
        items: [
          BottomNavyBarItem(
            icon: Icon(Icons.home),
            title: Text('Favorite'),
            activeColor: Theme.of(context).accentColor,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.view_carousel),
            title: Text('Room'),
            activeColor: Theme.of(context).accentColor,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.settings),
            title: Text('Setting'),
            activeColor: Theme.of(context).accentColor,
          ),
        ],
      ),
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
