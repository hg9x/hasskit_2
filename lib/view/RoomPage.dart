import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';

class RoomsPage extends StatelessWidget {
  final PageController controller = PageController(
      initialPage: gd.lastSelectedRoom, keepPage: true, viewportFraction: 1);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        controller: controller,
        onPageChanged: (val) {
          gd.lastSelectedRoom = val;
//          log.d("onPageChanged ${gd.lastSelectedRoom}");
        },
        itemBuilder: (context, position) {
          return RoomPage(position: position + 1);
        },
        itemCount: gd.roomList.length - 2);
  }
}

class RoomPage extends StatelessWidget {
  final int position;
  const RoomPage({@required this.position});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gd.roomTitle(position)),
        actions: gd.appBarThemeChanger,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: gd.getRoomImage(position),
            fit: BoxFit.cover,
          ),
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
            "${gd.roomTitle(position)}",
            style: Theme.of(context).textTheme.title,
          ),
        ),
      ),
    );
  }
}
