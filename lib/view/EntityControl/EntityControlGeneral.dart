import 'package:flutter/material.dart';
import 'package:hasskit_2/model/Entity.dart';

class EntityControlGeneral extends StatelessWidget {
  final Entity entity;

  const EntityControlGeneral({@required this.entity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          "The Detail Control Menu for ${entity.friendlyName} have not been updated, check back soon!",
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
        ),
      ),
    );
  }
}
