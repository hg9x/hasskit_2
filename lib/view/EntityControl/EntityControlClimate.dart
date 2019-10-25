import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/helper/MaterialDesignIcons.dart';
import 'package:hasskit_2/helper/ThemeInfo.dart';
import 'package:hasskit_2/helper/WebSocket.dart';
import 'package:hasskit_2/model/Entity.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class EntityControlClimate extends StatelessWidget {
  final Entity entity;

  const EntityControlClimate({@required this.entity});

  @override
  Widget build(BuildContext context) {
    int hvacModeIndex = entity.hvacModeIndex;
    int fanModeIndex = entity.fanModeIndex;
    var info04 = InfoProperties(
        bottomLabelStyle: Theme.of(context).textTheme.title,
//        bottomLabelStyle: TextStyle(
//            color: HexColor('#54826D'),
//            fontSize: 14,
//            fontWeight: FontWeight.w600),
        bottomLabelText: entity.friendlyName,
        mainLabelStyle: Theme.of(context).textTheme.display3,
//        mainLabelStyle: TextStyle(
//            color: HexColor('#54826D'),
//            fontSize: 30.0,
//            fontWeight: FontWeight.w600),
        modifier: (double value) {
          var temp = value.toInt();
          return '$temp˚';
        });

    var customColors05 = CustomSliderColors(
      trackColor: Colors.amber,
      progressBarColors: [Colors.amber, Colors.green],
      gradientStartAngle: 0,
      gradientEndAngle: 180,
      dotColor: Colors.white,
      hideShadow: true,
      shadowColor: Colors.black12,
      shadowMaxOpacity: 0.25,
      shadowStep: 1,
    );
    var customWidths = CustomSliderWidths(
      handlerSize: 8,
      progressBarWidth: 20,
//      shadowWidth: 10,
//      trackWidth: 10,
    );

    var slider = SleekCircularSlider(
      appearance: CircularSliderAppearance(
        customColors: customColors05,
        infoProperties: info04,
        customWidths: customWidths,
      ),
      min: entity.minTemp,
      max: entity.maxTemp,
      initialValue: entity.temperature,
//        innerWidget: (double value) {
//          print('innerWidget $value');
//          return Center(child: Text('$value'));
//        },
//      onChange: (double value) {
//        print('onChange $value');
//      },

      onChangeEnd: (double value) {
        print('onChangeEnd $value');

        var outMsg = {
          "id": gd.socketId,
          "type": "call_service",
          "domain": "climate",
          "service": "set_temperature",
          "service_data": {
            "entity_id": entity.entityId,
            "temperature": value.toInt(),
          }
        };
        var outMsgEncoded = json.encode(outMsg);
//        print('outMsgEncoded $outMsgEncoded');
        webSocket.send(outMsgEncoded);
      },
    );

    List<Widget> hvacModes = [];

    for (String hvacMode in entity.hvacModes) {
      var widget = Container(
        width: 120,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                gd.textToDisplay(hvacMode),
                style: Theme.of(context).textTheme.title,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              gd.climateModeToIcon(hvacMode),
              color: gd.climateModeToColor(hvacMode),
            ),
            SizedBox(width: 6),
          ],
        ),
      );
      hvacModes.add(widget);
    }
    List<Widget> fanModes = [];

    var hvacModesScrollController =
        FixedExtentScrollController(initialItem: hvacModeIndex);

    for (String fanMode in entity.fanModes) {
      var widget = Container(
        width: 120,
        child: Row(
          children: <Widget>[
            SizedBox(width: 6),
            Icon(
              MaterialDesignIcons.getIconDataFromIconName('mdi:fan'),
              color: ThemeInfo.colorBottomSheetReverse,
            ),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                gd.textToDisplay(fanMode),
                style: Theme.of(context).textTheme.title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
      fanModes.add(widget);
    }

    var fanModesScrollController =
        FixedExtentScrollController(initialItem: fanModeIndex);

    return Column(
      children: <Widget>[
        SizedBox(
          width: 240,
          height: 240,
          child: slider,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 120,
              height: 60,
              child: CupertinoPicker(
                scrollController: hvacModesScrollController,
                magnification: 1.2,
                backgroundColor: Colors.transparent,
                children: hvacModes,
                itemExtent: 40, //height of each item
                looping: true,
                onSelectedItemChanged: (int index) {
                  hvacModeIndex = index;
//                  print(
//                      'hvacModeIndex $hvacModeIndex ${entity.climate.hvacModes}');
                  var outMsg = {
                    "id": gd.socketId,
                    "type": "call_service",
                    "domain": "climate",
                    "service": "set_hvac_mode",
                    "service_data": {
                      "entity_id": entity.entityId,
                      "hvac_mode": "${entity.hvacModes[hvacModeIndex]}"
                    }
                  };
                  var outMsgEncoded = json.encode(outMsg);
//                  print('outMsgEncoded $outMsgEncoded');
                  webSocket.send(outMsgEncoded);
                },
              ),
            ),
            SizedBox(
              width: 1,
              height: 60,
              child: Container(
                color: Colors.black26,
              ),
            ),
            Container(
              width: 120,
              height: 80,
              child: CupertinoPicker(
                scrollController: fanModesScrollController,
                magnification: 1.2,
                backgroundColor: Colors.transparent,
                children: fanModes,
                itemExtent: 40, //height of each item
                looping: true,
                onSelectedItemChanged: (int index) {
                  fanModeIndex = index;
                  print('fanModeIndex $fanModeIndex ${entity.fanModes}');
                  var outMsg = {
                    "id": gd.socketId,
                    "type": "call_service",
                    "domain": "climate",
                    "service": "set_fan_mode",
                    "service_data": {
                      "entity_id": entity.entityId,
                      "fan_mode": "${entity.fanModes[fanModeIndex]}"
                    }
                  };
                  var outMsgEncoded = json.encode(outMsg);
//                  print('outMsgEncoded $outMsgEncoded');
                  webSocket.send(outMsgEncoded);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
