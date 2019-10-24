import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/model/Entity.dart';

class EntityRectangle extends StatelessWidget {
  final String entityId;
  final Function onTapCallback;
  final Function onLongPressCallback;

  const EntityRectangle(
      {@required this.entityId,
      @required this.onTapCallback,
      @required this.onLongPressCallback});

  @override
  Widget build(BuildContext context) {
    Entity entity = gd.entities
        .firstWhere((e) => e.entityId == entityId, orElse: () => null);
    return entity == null
        ? Container(
            child: Text("$entityId ???"),
          )
        : Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: entity.isStateOn
                  ? Theme.of(context).cardColor.withOpacity(0.8)
                  : Theme.of(context).cardColor.withOpacity(0.2),
            ),
            child: Row(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      entity.mdiIcon,
                      size: 30,
                      color: entity.isStateOn
                          ? Theme.of(context).accentColor.withOpacity(0.8)
                          : Theme.of(context).accentColor.withOpacity(0.2),
                    ),
                    Text(gd.textToDisplay(entity.state)),
                  ],
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${entity.friendlyName}",
                    maxLines: 2,
                    textScaleFactor: gd.textScaleFactor(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
  }
}
