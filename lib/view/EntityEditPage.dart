import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/model/Entity.dart';
import 'package:hasskit_2/helper/Logger.dart';

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
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(top: 0),
        color: Colors.grey,
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
              textScaleFactor: 1,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
