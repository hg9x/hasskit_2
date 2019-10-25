import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/helper/ThemeInfo.dart';
import 'package:hasskit_2/model/Entity.dart';
import 'package:hasskit_2/helper/Logger.dart';
import 'package:hasskit_2/view/EntityControl/EntityControlCamera.dart';
import 'package:hasskit_2/view/EntityEditPage.dart';
import 'package:hasskit_2/view/EntityRectangle.dart';
import 'EntitySquare.dart';

class EntitiesSliverGrid extends StatelessWidget {
  final List<Entity> entities;
  final int crossAxisCount;
  final double childAspectRatio;
  final EntityType entityType;
  final int roomIndex;
  const EntitiesSliverGrid(
      {@required this.entities,
      @required this.childAspectRatio,
      @required this.crossAxisCount,
      @required this.entityType,
      @required this.roomIndex});

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
            return entityType == EntityType.cameras
                ? EntityRectangle(
                    entityId: entities[index].entityId,
                    onTapCallback: () {
                      log.d(
                          "${entities[index].entityId} EntityRectangle onTapCallback");
                      if (roomIndex == gd.roomList.length - 1) {
                        showModalBottomSheet(
                          context: context,
                          elevation: 1,
                          backgroundColor: ThemeInfo.colorBottomSheet,
                          isScrollControlled: true,
                          useRootNavigator: true,
                          builder: (BuildContext context) {
                            return EntityEditPage(
                                entityId: entities[index].entityId);
                          },
                        );
                      } else {
                        showModalBottomSheet(
                          context: context,
                          elevation: 1,
                          backgroundColor: ThemeInfo.colorBottomSheet,
                          isScrollControlled: true,
                          useRootNavigator: true,
                          builder: (BuildContext context) {
                            return EntityControlCamera(
                                entityId: entities[index].entityId);
                          },
                        );
                      }
                    },
                    onLongPressCallback: () {
                      log.d(
                          "${entities[index].entityId} EntityRectangle onLongPressCallback");

                      showModalBottomSheet(
                        context: context,
                        elevation: 1,
                        backgroundColor: ThemeInfo.colorBottomSheet,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        builder: (BuildContext context) {
                          return EntityEditPage(
                              entityId: entities[index].entityId);
                        },
                      );
                    },
                  )
                : EntitySquare(
                    entityId: entities[index].entityId,
                    onTapCallback: () {
                      log.d(
                          "${entities[index].entityId} EntitySquare onTapCallback");
                      if (roomIndex == gd.roomList.length - 1 ||
                          entities[index].entityType ==
                              EntityType.accessories ||
                          entities[index].entityType == EntityType.cameras ||
                          entities[index].deviceClass == 'garage' ||
                          entities[index].deviceClass == 'door' ||
                          entities[index].deviceClass == 'window' ||
                          entities[index].entityId.contains('lock.')) {
                        showModalBottomSheet(
                          context: context,
                          elevation: 1,
                          backgroundColor: ThemeInfo.colorBottomSheet,
                          isScrollControlled: true,
                          useRootNavigator: true,
                          builder: (BuildContext context) {
                            return EntityEditPage(
                                entityId: entities[index].entityId);
                          },
                        );
                      } else {
                        gd.toggleStatus(entities[index]);
                      }
                    },
                    onLongPressCallback: () {
                      log.d(
                          "${entities[index].entityId} EntitySquare onLongPressCallback");
                      showModalBottomSheet(
                        context: context,
                        elevation: 1,
                        backgroundColor: ThemeInfo.colorBottomSheet,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        builder: (BuildContext context) {
                          return EntityEditPage(
                              entityId: entities[index].entityId);
                        },
                      );
                    },
                  );
          },
          childCount: entities.length,
        ),
      ),
    );
  }
}
