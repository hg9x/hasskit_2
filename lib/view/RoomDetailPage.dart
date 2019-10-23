import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/helper/Logger.dart';
import 'package:hasskit_2/model/Room.dart';

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

  final _controller = TextEditingController();
  List<Widget> buttonWidgets;

  @override
  Widget build(BuildContext context) {
    _controller.text = gd.roomList[widget.roomIndex].name;
    var addButton = RaisedButton(
      onPressed: () {
        var newRoom = Room(
            name: _controller.text.trim(),
            imageIndex: gd.roomList.last.imageIndex);
        gd.addRoom(newRoom);
        Navigator.pop(context, "Add New Room");
//        gd.showSnackBar("Add New Room", context);
      },
      child: Text("Add"),
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(4)),
    );
    var saveButton = RaisedButton(
      onPressed: () {
        gd.setRoomName(gd.roomList[widget.roomIndex], _controller.text.trim());
        Navigator.pop(context, "Save Room");
//        gd.showSnackBar("Save Room", context);
      },
      child: Text("Save"),
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(4)),
    );
    var deleteButton = RaisedButton(
      onPressed: () {
        gd.deleteRoom(widget.roomIndex);
        Navigator.pop(context, "Delete Room");
//        gd.showSnackBar("Delete Room", context);
      },
      child: Text("Delete"),
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(4)),
    );
//    IconButton moveLeft = IconButton(
//      icon: Icon(
//        MdiIcons.chevronLeftBox,
//        size: 32,
//      ),
//      onPressed: () {},
//    );
//    IconButton moveRight = IconButton(
//      icon: Icon(
//        MdiIcons.chevronRightBox,
//        size: 32,
//      ),
//      onPressed: () {},
//    );
    Expanded expanded = Expanded(child: Container());
    if (widget.roomIndex > 0 && widget.roomIndex < gd.roomList.length - 2) {
      buttonWidgets = [
        expanded,
        saveButton,
        Container(width: 10),
        deleteButton,
        expanded,
      ];
    } else if (widget.roomIndex == gd.roomList.length - 1) {
      buttonWidgets = [expanded, addButton, expanded];
    } else {
      buttonWidgets = [expanded, saveButton, expanded];
    }
    return Padding(
      padding: EdgeInsets.only(top: 24),
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
                              _controller.text = val;
                            },
                            onEditingComplete: () {
                              log.d(
                                  "onEditingComplete ${_controller.text.trim()}");
                              gd.setRoomName(gd.roomList[widget.roomIndex],
                                  _controller.text.trim());
                            },
                            onFieldSubmitted: (val) {
                              log.d(
                                  "onFieldSubmitted ${_controller.text.trim()}");
                              gd.setRoomName(gd.roomList[widget.roomIndex],
                                  _controller.text.trim());
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            },
                          )
                        : Container(
                            child: Text(
                            gd.roomList[widget.roomIndex].name,
                            style: Theme.of(context).textTheme.title,
                          )),
                    SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: buttonWidgets),
                    Expanded(child: Container()),
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
//                    log.d(
//                        "InkWell 1 ${gd.roomList[widget.roomIndex].imageIndex}");
                    gd.setRoomBackgroundAndName(gd.roomList[widget.roomIndex],
                        index, _controller.text.trim());
                    log.d(
                        "InkWell 2 ${gd.roomList[widget.roomIndex].imageIndex}");
                    setState(() {});
                  },
                  child: Card(
                    elevation: 1,
                    margin: EdgeInsets.all(4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Container(
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
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
