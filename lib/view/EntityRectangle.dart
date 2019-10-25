import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/helper/ThemeInfo.dart';
import 'package:hasskit_2/model/Entity.dart';

class EntityRectangle extends StatefulWidget {
  final String entityId;
  final Function onTapCallback;
  final Function onLongPressCallback;

  const EntityRectangle(
      {@required this.entityId,
      @required this.onTapCallback,
      @required this.onLongPressCallback});

  @override
  _EntityRectangleState createState() => _EntityRectangleState();
}

class _EntityRectangleState extends State<EntityRectangle> {
  @override
  void dispose() {
    if (gd.activeCameraxs.containsKey(widget.entityId)) {
      gd.activeCameraxs.remove(widget.entityId);
//      log.d("gd.activeCameras.remove ${widget.entityId}");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Entity entity = gd.entities
        .firstWhere((e) => e.entityId == widget.entityId, orElse: () => null);
    if (!gd.activeCameraxs.containsKey(widget.entityId)) {
      gd.activeCameraxs[widget.entityId] = DateTime.now();
    }

    return InkResponse(
      onTap: widget.onTapCallback,
      onLongPress: widget.onLongPressCallback,
      child: entity == null
          ? Container(
              child: Text("${widget.entityId} ???"),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image(
                    image: gd.getCameraThumbnail(widget.entityId),
                    fit: BoxFit.cover,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.white30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            entity.friendlyName,
                            style: ThemeInfo.textNameButtonActive,
                            textScaleFactor: gd.textScaleFactor,
                          ),
                          Text(
                            "${(DateTime.now().difference(gd.cameraThumbnails[widget.entityId].receivedDateTime)).inSeconds}",
                            style: ThemeInfo.textNameButtonActive,
                            textScaleFactor: gd.textScaleFactor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
