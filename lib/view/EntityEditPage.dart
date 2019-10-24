import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/helper/ThemeInfo.dart';
import 'package:hasskit_2/model/Entity.dart';
import 'package:hasskit_2/helper/Logger.dart';
import 'package:hasskit_2/view/EntityControl/EntityControlClimate.dart';
import 'package:hasskit_2/view/EntityControl/EntityControlFan.dart';
import 'package:hasskit_2/view/EntityControl/EntityControlGeneral.dart';

import 'EntityControl/EntityControlLightSwitch.dart';

class EntityEditPage extends StatelessWidget {
  final String entityId;
  const EntityEditPage({@required this.entityId});

  @override
  Widget build(BuildContext context) {
    final Entity entity = gd.entities
        .firstWhere((e) => e.entityId == entityId, orElse: () => null);
    if (entity == null) {
      log.e("Cant find entity name $entityId");
      return Container();
    }

    Widget entityControl;

    if (entity.entityType == EntityType.climateFans &&
        entity.hvacModes != null &&
        entity.hvacModes.length > 0) {
      entityControl = EntityControlClimate(entity: entity);
    } else if (entity.entityType == EntityType.climateFans &&
        entity.speedList != null &&
        entity.speedList.length > 0) {
      entityControl = EntityControlFan(entity: entity);
    } else if (entity.entityType == EntityType.lightSwitches) {
      entityControl = EntityControlLightSwitch(entity: entity);
    } else {
      entityControl = EntityControlGeneral(entity: entity);
    }
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(top: 0),
          color: ThemeInfo.colorBottomSheet,
          child: Column(
            children: <Widget>[
              Container(
                height: 25,
                color: Colors.black,
              ),
              Container(
                height: 8,
              ),
              Text(
                entity.friendlyName,
                style: Theme.of(context).textTheme.display1,
                textScaleFactor: gd.textScaleFactor(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Expanded(
                child: Container(
//                  color: Colors.red,
                    ),
              ),
              Container(
                child: entityControl,
              ),
              Expanded(
                child: Container(
//                  color: Colors.red,
                    ),
              ),
              Text(
                "Show In Room",
                style: Theme.of(context).textTheme.title,
                textScaleFactor: gd.textScaleFactor(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
//              Text(
//                "One Entity Can Show in ${gd.roomList[0].name} and ONE Another Room",
//                style: Theme.of(context).textTheme.body2,
//                textScaleFactor: gd.textScaleFactor(context),
//                maxLines: 1,
//                overflow: TextOverflow.ellipsis,
//              ),
              Container(
                height: 67,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: gd.roomList.length - 1,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        gd.showInRoom(
                            entityId, index, entity.friendlyName, context);
                      },
                      child: Card(
                        elevation: 1,
                        margin: EdgeInsets.all(4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Container(
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage(gd.backgroundImage[
                                  gd.roomList[index].imageIndex]),
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(
                                gd.roomList[index].name,
                                style: Theme.of(context).textTheme.body2,
                                textScaleFactor: gd.textScaleFactor(context),
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Icon(
                                index == 0 ? Icons.star : Icons.check_circle,
                                size: 32,
                                color: gd.roomList[index].entities
                                        .contains(entityId)
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.white.withOpacity(0.2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
