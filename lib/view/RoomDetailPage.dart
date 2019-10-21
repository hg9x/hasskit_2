import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/helper/Logger.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RoomDetailPage extends StatefulWidget {
  final int roomIndex;
  const RoomDetailPage({@required this.roomIndex});

  @override
  _RoomDetailPageState createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  @override
  void dispose() {
    super.dispose();
  }

  Widget buttonWidget;

  @override
  Widget build(BuildContext context) {
    if (widget.roomIndex == gd.roomList.length - 1) {
      buttonWidget = OutlineButton(
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.add_circle),
            Text("Add New Room"),
          ],
        ),
        borderSide: BorderSide(width: 1),
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)),
      );
    } else if (widget.roomIndex != 0) {
      buttonWidget = OutlineButton(
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(MdiIcons.delete),
            Text("Delete This Room"),
          ],
        ),
        borderSide: BorderSide(width: 1),
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)),
      );
    } else {
      buttonWidget = Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Card(
            margin: EdgeInsets.all(4),
            elevation: 1,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(gd.roomList[widget.roomIndex].image),
                ),
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Edit room name",
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(0)),
                    ),
                    initialValue: "${gd.roomList[widget.roomIndex].name}",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.title,
                    maxLines: 1,
                    onChanged: (val) {
                      gd.setRoomName(gd.roomList[widget.roomIndex], val);
                    },
                  ),
                  Expanded(child: Container()),
                  Row(
                    children: <Widget>[
                      Expanded(child: Container()),
                      buttonWidget,
                      Expanded(child: Container()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: gd.backgroundImage.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  log.d("InkWell 1 ${gd.roomList[widget.roomIndex].image}");
                  gd.setRoomBackgroundImage(
                      gd.roomList[widget.roomIndex], gd.backgroundImage[index]);
                  log.d("InkWell 2 ${gd.roomList[widget.roomIndex].image}");
                  setState(() {});
                },
                child: Card(
                  elevation: 1,
                  margin: EdgeInsets.all(4),
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(gd.backgroundImage[index]),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
