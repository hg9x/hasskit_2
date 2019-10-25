import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';

class EntityControlCamera extends StatelessWidget {
  final String entityId;

  const EntityControlCamera({@required this.entityId});

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 1,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image(
            image: gd.getCameraThumbnail(entityId),
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: Icon(
                Icons.cancel,
                color: Colors.white70,
                size: 32,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
