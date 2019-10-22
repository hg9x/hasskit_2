import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/helper/Logger.dart';
import 'package:hasskit_2/model/Room.dart';
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

  List<Widget> buttonWidgets;

  @override
  Widget build(BuildContext context) {
    String roomName = gd.roomList[widget.roomIndex].name;
    if (widget.roomIndex == gd.roomList.length - 1) {
      var addButton = OutlineButton(
        onPressed: () {
          log.w("Add New Room");
          var newRoom =
              Room(name: roomName, imageIndex: gd.roomList.last.imageIndex);
          gd.addRoom(newRoom);
          Navigator.pop(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.add_circle),
            Text("Add"),
          ],
        ),
        borderSide: BorderSide(width: 1),
        shape:
            RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8)),
      );
      buttonWidgets = [addButton];
    } else if (widget.roomIndex != 0 &&
        widget.roomIndex != gd.roomList.length - 2) {
      var saveButton = OutlineButton(
        onPressed: () {
          log.w("Save");
          gd.setRoomName(gd.roomList[widget.roomIndex], roomName);
          Navigator.pop(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(MdiIcons.databaseEdit),
            Text("Save"),
          ],
        ),
        borderSide: BorderSide(width: 1),
        shape:
            RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8)),
      );
      var deleteButton = OutlineButton(
        onPressed: () {
          log.w("Delete");
          gd.deleteRoom(widget.roomIndex);
          Navigator.pop(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(MdiIcons.delete),
            Text("Delete"),
          ],
        ),
        borderSide: BorderSide(width: 1),
        shape:
            RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8)),
      );
      buttonWidgets = [saveButton, Container(width: 10), deleteButton];
    } else {
      buttonWidgets = [Container()];
    }
    return Padding(
      padding: EdgeInsets.only(top: 0),
      child: Column(
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
//                  image: AssetImage(gd.roomList[widget.roomIndex].image),
                    image: AssetImage(gd.backgroundImage[
                        gd.roomList[widget.roomIndex].imageIndex]),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10),
                    gd.roomList[widget.roomIndex].name != "Default Room"
                        ? TextFormField(
                            decoration: InputDecoration(
                              labelText: "Edit room name",
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white, width: 1),
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            initialValue:
                                "${gd.roomList[widget.roomIndex].name}",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.title,
                            maxLines: 1,
                            onChanged: (val) {
                              roomName = val;
                            },
                          )
                        : Container(
                            child: Text(
                            gd.roomList[widget.roomIndex].name,
                            style: Theme.of(context).textTheme.title,
                          )),
                    Expanded(child: Container()),
                    Row(
                      children: <Widget>[
                        Expanded(child: Container()),
                        Row(
                          children: buttonWidgets,
                        ),
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
                    log.d(
                        "InkWell 1 ${gd.roomList[widget.roomIndex].imageIndex}");
                    gd.setRoomBackgroundImage(
                        gd.roomList[widget.roomIndex], index);
                    log.d(
                        "InkWell 2 ${gd.roomList[widget.roomIndex].imageIndex}");
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
      ),
    );
  }
}
