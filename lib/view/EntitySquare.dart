import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/helper/ThemeInfo.dart';
import 'package:hasskit_2/model/Entity.dart';

class EntitySquare extends StatelessWidget {
  final String entityId;
  final Function onTapCallback;
  final Function onLongPressCallback;

  const EntitySquare(
      {@required this.entityId,
      @required this.onTapCallback,
      @required this.onLongPressCallback});

  @override
  Widget build(BuildContext context) {
    Entity entity = gd.entities
        .firstWhere((e) => e.entityId == entityId, orElse: () => null);

    Widget iconWidget;

    if (entity.entityType == EntityType.climateFans &&
        entity.hvacModes != null) {
      iconWidget = iconWidget = AspectRatio(
        aspectRatio: 1,
        child: FittedBox(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(
                entity.mdiIcon,
                size: 100,
                color: gd.climateModeToColor(entity.state),
              ),
              Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  Text(
                    "${entity.temperature}",
                    style: ThemeInfo.textNameButtonActive
                        .copyWith(color: Colors.white),
                    textScaleFactor: 2,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      iconWidget = AspectRatio(
        aspectRatio: 1,
        child: FittedBox(
          child: Icon(
            entity.mdiIcon,
            size: 100,
            color: entity.isStateOn
                ? ThemeInfo.colorIconActive
                : ThemeInfo.colorIconInActive,
          ),
        ),
      );
    }
    return InkResponse(
      onTap: onTapCallback,
      onLongPress: onLongPressCallback,
      child: entity == null
          ? Container(
              child: Text("$entityId ???"),
            )
          : Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: entity.isStateOn
                    ? ThemeInfo.colorBackgroundActive
                    : ThemeInfo.colorEntityBackground,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: <Widget>[
                        iconWidget,
                        Expanded(
                          child: FittedBox(
                            alignment: Alignment.centerRight,
                            child: (gd.connectionStatus != "Connected" ||
                                    entity.state.contains("..."))
                                ? SpinKitThreeBounce(
                                    size: 100,
                                    color: Theme.of(context).cardColor,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "${entity.friendlyName}",
                        style: entity.isStateOn
                            ? ThemeInfo.textNameButtonActive
                            : ThemeInfo.textNameButtonInActive,
                        maxLines: 2,
                        textScaleFactor: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "${gd.textToDisplay(entity.state)}",
                      style: entity.isStateOn
                          ? ThemeInfo.textStatusButtonActive
                          : ThemeInfo.textStatusButtonInActive,
                      maxLines: 1,
                      textScaleFactor: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
