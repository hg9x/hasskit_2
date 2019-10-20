import 'dart:convert';
import 'package:hasskit_2/helper/WebSocket.dart';
import 'package:hasskit_2/helper/providerData.dart';

enum EntityType {
  lightSwitches,
  climateFans,
  cameras,
  mediaPlayers,
  accessories,
}

class Entity {
  final String entityId;
  String deviceClass;
  String friendlyName;
  String icon;
  String state;
  //climate
  List<String> hvacModes;
  double minTemp;
  double maxTemp;
  double targetTempStep;
  double temperature;
  String fanMode;
  List<String> fanModes;
  String lastOnOperation;
  int deviceCode;
  String manufacturer;
//Fan
  List<String> speedList;
  bool oscillating;
  String speedLevel;
  int angle;
  int directSpeed;

  Entity({
    this.entityId,
    this.deviceClass,
    this.friendlyName,
    this.icon,
    this.state,
    //climate
    this.hvacModes,
    this.minTemp,
    this.maxTemp,
    this.targetTempStep,
    this.temperature,
    this.fanMode,
    this.fanModes,
    this.deviceCode,
    this.manufacturer,
    //fan
    this.speedList,
    this.oscillating,
    this.speedLevel,
    this.angle,
    this.directSpeed,
  });

  factory Entity.fromJson(Map<String, dynamic> json) {
    List<String> hvacModes = [];
    if (json['attributes']['hvac_modes'] != null) {
      for (String hvac_mode in json['attributes']['hvac_modes']) {
        hvacModes.add(hvac_mode);
      }
    }

    List<String> fanModes = [];
    if (json['attributes']['fan_modes'] != null) {
      for (String fan_mode in json['attributes']['fan_modes']) {
        fanModes.add(fan_mode);
      }
    }

    List<String> speedList = [];
    if (json['attributes']['speed_list'] != null) {
      for (String speed in json['attributes']['speed_list']) {
        speedList.add(speed);
      }
    }
    return Entity(
      entityId: json['entity_id'],
      deviceClass: json['attributes']['device_class'],
      icon: json['attributes']['icon'],
      friendlyName: json['attributes']['friendly_name'],
      state: json['state'],
      //climate
      hvacModes: hvacModes,
      minTemp: double.tryParse(json['attributes']['min_temp'].toString()),
      maxTemp: double.tryParse(json['attributes']['max_temp'].toString()),
      targetTempStep:
          double.tryParse(json['attributes']['target_temp_step'].toString()),
      temperature:
          double.tryParse(json['attributes']['temperature'].toString()),
      fanMode: json['attributes']['fan_mode'],
      fanModes: fanModes,
      deviceCode: json['attributes']['device_code'],
      manufacturer: json['attributes']['manufacturer'],
      //fan
      speedList: speedList,
      oscillating: json['attributes']['oscillating'],
      speedLevel: json['attributes']['speed_level'],
      angle: json['attributes']['angle'],
      directSpeed: json['attributes']['direct_speed'],
    );
  }

  toggleState() {
    var domain = entityId.split('.').first;
    var service = '';
    if (state == 'on' ||
        state == 'turning on...' ||
        domain == 'climate' && state != 'off') {
      state = 'turning off...';
      service = 'turn_off';
    } else if (state == 'off' || state == 'turning off...') {
      state = 'turning on...';
      service = 'turn_on';
    }
    if (state == 'open' || state == 'opening...') {
      state = 'closing...';
      service = 'close_cover';
    } else if (state == 'closed' || state == 'closing...') {
      state = 'opening...';
      service = 'open_cover';
    }
    if (state == 'locked' || state == 'locking...') {
      state = 'unlocking...';
      service = 'unlock';
    } else if (state == 'unlocked' || state == 'unlocking...') {
      state = 'locking...';
      service = 'lock';
    }
    var outMsg = {
      "id": gd.socketId,
      "type": "call_service",
      "domain": domain,
      "service": service,
      "service_data": {"entity_id": entityId}
    };

    var outMsgEncoded = json.encode(outMsg);
    webSocket.send(outMsgEncoded);
  }

  EntityType get entityType {
    if (entityId.contains('fan.') || entityId.contains('climate.')) {
      return EntityType.climateFans;
    } else if (entityId.contains('camera.')) {
      return EntityType.cameras;
    } else if (entityId.contains('media_player.')) {
      return EntityType.mediaPlayers;
    } else if (entityId.contains('light.') ||
        entityId.contains('switch.') ||
        entityId.contains('cover.') ||
        entityId.contains('input_boolean.') ||
        entityId.contains('lock.') ||
        entityId.contains('vacuum.')) {
      return EntityType.lightSwitches;
    } else {
      return EntityType.accessories;
    }
  }

  int get fanModeIndex {
    return fanModes.indexOf(fanMode);
  }

  int get hvacModeIndex {
    return hvacModes.indexOf(state);
  }
}
