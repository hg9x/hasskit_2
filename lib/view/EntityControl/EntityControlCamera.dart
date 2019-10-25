import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';

class EntityControlCamera extends StatelessWidget {
  final String entityId;

  const EntityControlCamera({@required this.entityId});

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 1,
      child: Image(
        image: gd.getCameraThumbnail(entityId),
        fit: BoxFit.cover,
      ),
    );
  }
}
