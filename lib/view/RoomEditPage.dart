import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/helper/Logger.dart';
import 'package:hasskit_2/helper/MaterialDesignIcons.dart';

class RoomEditPage extends StatefulWidget {
  final int roomIndex;

  const RoomEditPage({@required this.roomIndex});

  @override
  _RoomEditPageState createState() => _RoomEditPageState();
}

class _RoomEditPageState extends State<RoomEditPage> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = gd.roomList[widget.roomIndex].name;
    //addButton
    var addButton = RaisedButton(
      onPressed: widget.roomIndex != 0
          ? () {
              gd.addRoom();
              Navigator.pop(context, "Added New Room");
//        gd.showSnackBar("Add New Room", context);
            }
          : null,
      child: Row(
        children: <Widget>[
          Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:plus-box")),
          Text("Add"),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(4)),
    );
    //saveButton
    var saveButton = RaisedButton(
      onPressed: () {
        gd.setRoomName(gd.roomList[widget.roomIndex], _controller.text.trim());
        Navigator.pop(context, "Save Room");
//        gd.showSnackBar("Save Room", context);
      },
      child: Row(
        children: <Widget>[
          Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:content-save")),
          Text(" Save"),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(4)),
    );
    //deleteButton
    var deleteButton = RaisedButton(
      onPressed:
          widget.roomIndex != 0 && widget.roomIndex != gd.roomList.length - 1
              ? () {
                  gd.deleteRoom(widget.roomIndex);
                  Navigator.pop(context, "Delete Room");
//        gd.showSnackBar("Delete Room", context);
                }
              : null,
      child: Row(
        children: <Widget>[
          Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:delete")),
          Text("Delete"),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(4)),
    );
    //moveLeft
    var moveLeft = IconButton(
      icon: Icon(
        MaterialDesignIcons.getIconDataFromIconName("mdi:chevron-left-circle"),
        size: 32,
        color: widget.roomIndex > 1 && widget.roomIndex < gd.roomList.length - 1
            ? null
            : Colors.transparent,
      ),
      onPressed:
          widget.roomIndex > 1 && widget.roomIndex < gd.roomList.length - 1
              ? () {
                  log.w("Move Left");
                  gd.moveRoom(widget.roomIndex, true);
                  Navigator.pop(context, "Move Room Left");
                }
              : () {},
    );
    //moveRight
    var moveRight = IconButton(
      icon: Icon(
        MaterialDesignIcons.getIconDataFromIconName("mdi:chevron-right-circle"),
        size: 32,
        color:
            widget.roomIndex < gd.roomList.length - 2 && widget.roomIndex != 0
                ? null
                : Colors.transparent,
      ),
      onPressed:
          widget.roomIndex < gd.roomList.length - 2 && widget.roomIndex != 0
              ? () {
                  log.w("Move Right");
                  gd.moveRoom(widget.roomIndex, false);
                  Navigator.pop(context, "Move Room Right");
                }
              : () {},
    );

    return Container(
      padding: EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Theme.of(context).brightness == gd.themesData[0].brightness
            ? Colors.grey
            : Colors.grey,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              labelText: "Edit Room",
            ),
            initialValue: "${gd.roomList[widget.roomIndex].name}",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.title,
            maxLines: 1,
            onChanged: (val) {
              _controller.text = val;
            },
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            onFieldSubmitted: (val) {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              moveLeft,
              deleteButton,
              saveButton,
              addButton,
              moveRight,
            ],
          ),
          Expanded(child: Container()),
          Text("Select Background Color"),
          Container(
            child: Container(
              height: 58,
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
                        height: 50,
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
          ),
          Container(height: 50),
        ],
      ),
    );
  }
}
