import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/helper/ThemeInfo.dart';
import 'package:hasskit_2/model/Entity.dart';

class EntityControlLightSwitch extends StatelessWidget {
  final Entity entity;

  const EntityControlLightSwitch({@required this.entity});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Icon(
            entity.mdiIcon,
            size: 200,
            color: ThemeInfo.colorIconActive,
          ),
          SizedBox(
            height: 30,
          ),
          Transform.scale(
            scale: 3,
            child: SizedBox(
              width: 72,
              height: 24,
              child: Switch(
                activeColor: ThemeInfo.colorIconActive,
                value: entity.isStateOn,
                onChanged: (bool isOn) {
//                        print(
//                            'onChanged $isOn | entity.isIconOn ${entity.isIconOn}');
                  if (isOn != entity.isStateOn) {
//                          print('providerData.toggleStatus ${entity.entityId}');
                    gd.toggleStatus(entity);
                  }
                },
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Text(
            gd.textToDisplay(entity.state),
            style: Theme.of(context).textTheme.title,
          ),
        ],
      ),
    );
  }
}
