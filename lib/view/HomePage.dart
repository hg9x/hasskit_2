import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/providerData.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: pD.appBarThemeChanger,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColorLight,
                Theme.of(context).primaryColorDark
              ]),
        ),
        child: Center(
          child: Text(
            "Home Page",
            style: Theme.of(context).textTheme.title,
          ),
        ),
      ),
    );
  }
}
