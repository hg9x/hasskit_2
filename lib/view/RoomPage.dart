import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';

class RoomsPage extends StatelessWidget {
  final PageController controller = PageController(
      initialPage: gd.roomList.length - 1, keepPage: true, viewportFraction: 1);
  @override
  Widget build(BuildContext context) {
    gd.pageController = controller;
    return PageView.builder(
        controller: controller,
        onPageChanged: (val) {
          gd.lastSelectedRoom = val;
//          log.d("onPageChanged ${gd.lastSelectedRoom}");
        },
        itemBuilder: (context, position) {
          return RoomPage(position: position + 1);
        },
        itemCount: gd.roomPageLength);
  }
}

class RoomPage extends StatelessWidget {
  final int position;
  const RoomPage({@required this.position});
  @override
  Widget build(BuildContext context) {
    return Container(
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
        color: Theme.of(context).primaryColorLight,
      ),
      child: CustomScrollView(
        slivers: gd.customScrollView(position, context),
      ),
    );
  }
}
