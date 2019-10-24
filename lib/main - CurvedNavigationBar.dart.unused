import 'package:curved_navigation_bar/curved_navigation_bar.dart';
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
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        items: <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.view_carousel, size: 30),
          Icon(Icons.settings, size: 30),
        ],
        onTap: (index) {
          //Handle button tap
          setState(() {
            pageNumber = index;
          });
        },
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
