import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: gd.getRoomImage(0),
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
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            leading: Image(
              image: AssetImage(
                  'assets/images/icon_transparent_border_transparent.png'),
            ),
            largeTitle: Text(gd.roomTitle(0)),
            trailing: IconButton(
              icon: Icon(Icons.palette),
              onPressed: () {
                gd.themeChange();
              },
            ),
          ),
          gd.makeHeaderIcon(Theme.of(context).primaryColorDark.withOpacity(0.2),
              Icon(MdiIcons.toggleSwitch), 'Light, Switchs...', "", context),
          SliverFixedExtentList(
            itemExtent: 200.0,
            delegate: SliverChildListDelegate(
              [
                Container(child: Center(child: Text(gd.roomTitle(0)))),
              ],
            ),
          ),
          gd.makeHeaderIcon(Theme.of(context).primaryColorDark.withOpacity(0.2),
              Icon(MdiIcons.homeThermometer), 'Climates, Fans...', "", context),
          SliverFixedExtentList(
            itemExtent: 200.0,
            delegate: SliverChildListDelegate(
              [
                Container(child: Center(child: Text(gd.roomTitle(0)))),
              ],
            ),
          ),
          gd.makeHeaderIcon(Theme.of(context).primaryColorDark.withOpacity(0.2),
              Icon(MdiIcons.cctv), 'Camera...', "", context),
          SliverFixedExtentList(
            itemExtent: 200.0,
            delegate: SliverChildListDelegate(
              [
                Container(child: Center(child: Text(gd.roomTitle(0)))),
              ],
            ),
          ),
          gd.makeHeaderIcon(Theme.of(context).primaryColorDark.withOpacity(0.2),
              Icon(MdiIcons.homeAutomation), 'Accessories...', "", context),
          SliverFixedExtentList(
            itemExtent: 1000.0,
            delegate: SliverChildListDelegate(
              [
                Container(child: Center(child: Text(gd.roomTitle(0)))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
