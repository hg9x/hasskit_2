import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/model/Entity.dart';
import 'package:hasskit_2/helper/Logger.dart';
import 'EntitySquare.dart';

class EntitiesSliverGrid extends StatelessWidget {
  final List<Entity> entities;
  final int crossAxisCount;
  final double childAspectRatio;
  final EntityType entityType;

  const EntitiesSliverGrid(
      {@required this.entities,
      @required this.childAspectRatio,
      @required this.crossAxisCount,
      @required this.entityType});

  @override
  Widget build(BuildContext context) {
    if (entities.length < 1) {
      return SliverList(
        delegate: SliverChildListDelegate(
          [Container()],
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: childAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (entityType == EntityType.accessories) {
              return EntitySquare(
                entityId: entities[index].entityId,
                onTapCallback: () {
                  log.d("${entities[index].entityId} onTapCallback");
                  gd.toggleStatus(entities[index]);
                },
                onLongPressCallback: () {
                  log.d("${entities[index].entityId} onLongPressCallback");
                },
              );
            } else {
              return EntitySquare(
                entityId: entities[index].entityId,
                onTapCallback: () {
                  log.d("${entities[index].entityId} onTapCallback");
                  gd.toggleStatus(entities[index]);
                },
                onLongPressCallback: () {
                  log.d("${entities[index].entityId} onLongPressCallback");
                },
              );
            }
          },
          childCount: entities.length,
        ),
      ),
    );
  }
}
