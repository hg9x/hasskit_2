import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/helper/ThemeInfo.dart';
import 'package:hasskit_2/helper/WebSocket.dart';
import 'package:hasskit_2/model/Entity.dart';

class EntityControlFan extends StatelessWidget {
  final Entity entity;

  const EntityControlFan({@required this.entity});

  @override
  Widget build(BuildContext context) {
    List<Widget> buttonsWidget = [];

    var buttonsText = [];
    for (int i = entity.speedList.length - 1; i >= 0; i--) {
      buttonsText.add(entity.speedList[i]);
    }

    if (entity.oscillating != null) {
      buttonsText.add('Oscilating');
    }

    for (String buttonText in buttonsText) {
      var buttonColor = ThemeInfo.colorIconActive.withOpacity(0.25);
      if (entity.state != 'off') {
        if (buttonText == 'Oscilating' && entity.oscillating ||
            buttonText == entity.speedLevel) {
          buttonColor = Colors.amber;
        }
      } else if (buttonText == 'off') {
        buttonColor = Colors.amber;
      }

      var button = SizedBox(
        height: 60,
        width: 240,
        child: MaterialButton(
          height: 0,
          color: buttonColor,
          padding: EdgeInsets.zero,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          child: Text(
            gd.textToDisplay(buttonText).toUpperCase(),
            style: ThemeInfo.textNameButtonActive,
            textScaleFactor: gd.textScaleFactor,
          ),
          onPressed: () {
            print('button $buttonText pressed');

            var outMsg;
            if (buttonText == 'Oscilating') {
              outMsg = {
                "id": gd.socketId,
                "type": "call_service",
                "domain": "fan",
                "service": "oscillate",
                "service_data": {
                  "entity_id": entity.entityId,
                  "oscillating": !entity.oscillating,
                }
              };
            } else {
              outMsg = {
                "id": gd.socketId,
                "type": "call_service",
                "domain": "fan",
                "service": "set_speed",
                "service_data": {
                  "entity_id": entity.entityId,
                  "speed": buttonText,
                }
              };
            }

            var outMsgEncoded = json.encode(outMsg);
            print('EntityDetailFan $outMsgEncoded');
            webSocket.send(outMsgEncoded);
          },
        ),
      );
      buttonsWidget.add(button);
      buttonsWidget.add(SizedBox(height: 5));
    }

    return Column(
      children: buttonsWidget,
    );
  }
}
