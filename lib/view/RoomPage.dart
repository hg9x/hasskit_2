import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/providerData.dart';
import 'package:hasskit_2/model/SwitchlikeCheckbox.dart';

class RoomPage extends StatelessWidget {
  final PageController controller =
      PageController(initialPage: pD.lastSelectedRoom, keepPage: true);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room'),
        actions: pD.appBarThemeChanger,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: PageView(
        onPageChanged: (pageNumber) {
          pD.lastSelectedRoom = pageNumber;
        },
        controller: controller,
        children: <Widget>[
          RoomPage1(),
          RoomPage2(),
          RoomPage3(),
        ],
      ),
    );
  }
}

class RoomPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          "RoomPage1",
          style: Theme.of(context).textTheme.title,
        ),
      ),
    );
  }
}

class RoomPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          "RoomPage2",
          style: Theme.of(context).textTheme.title,
        ),
      ),
    );
  }
}

class RoomPage3 extends StatefulWidget {
  @override
  _RoomPage3State createState() => _RoomPage3State();
}

class _RoomPage3State extends State<RoomPage3> {
  bool enableCoolStuff = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColorLight,
              Theme.of(context).primaryColorDark
            ]),
      ),
      child: GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.translucent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SwitchlikeCheckbox(checked: enableCoolStuff),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                "Enable cool stuff",
                textScaleFactor: 1.3,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _toggle() {
    setState(() {
      enableCoolStuff = !enableCoolStuff;
    });
  }
}
