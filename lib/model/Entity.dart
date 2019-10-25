import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:hasskit_2/helper/MaterialDesignIcons.dart';
import 'package:hasskit_2/helper/WebSocket.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/helper/Logger.dart';

enum EntityType {
  lightSwitches,
  climateFans,
  cameras,
  mediaPlayers,
  accessories,
  scriptAutomation,
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
    if (json['entity_id'] == null) {
      return null;
    }
    return Entity(
      entityId: json['entity_id'],
      deviceClass: json['attributes']['device_class'],
      icon: json['attributes']['icon'],
      friendlyName: json['attributes']['friendly_name'],
      state: json['state'],
      //climate
      hvacModes: json['attributes']['hvac_modes'] != null
          ? List<String>.from(json['attributes']['hvac_modes'])
          : null,
      minTemp: double.tryParse(json['attributes']['min_temp'].toString()),
      maxTemp: double.tryParse(json['attributes']['max_temp'].toString()),
      targetTempStep:
          double.tryParse(json['attributes']['target_temp_step'].toString()),
      temperature:
          double.tryParse(json['attributes']['temperature'].toString()),
      fanMode: json['attributes']['fan_mode'],
      fanModes: json['attributes']['fan_modes'] != null
          ? List<String>.from(json['attributes']['fan_modes'])
          : null,
      deviceCode: json['attributes']['device_code'],
      manufacturer: json['attributes']['manufacturer'],
      //fan
      speedList: json['attributes']['speed_list'] != null
          ? List<String>.from(json['attributes']['speed_list'])
          : null,
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
    } else if (entityId.contains('script.') ||
        entityId.contains('automation.')) {
      return EntityType.scriptAutomation;
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

  IconData get mdiIcon {
    try {
      return MaterialDesignIcons.getIconDataFromIconName(getDefaultIconString);
    } catch (e) {
      log.e("mdiIcon $e");
      return MaterialDesignIcons.getIconDataFromIconName("help-box");
    }
  }

  String get getDefaultIconString {
    if (!["", null].contains(icon)) {
      return icon;
    }

    var deviceClass = entityId.split('.')[0];
    var deviceName = entityId.split('.')[1];

    if (deviceClass == 'lock' && isStateOn) {
      return 'mdi:lock-open';
    }
    if (deviceClass == 'climate') {
      return 'mdi:checkbox-blank-circle';
    }

    if ([null, ''].contains(deviceClass) || [null, ''].contains(deviceName)) {
      return 'mdi:help-circle';
    }

    if (iconOverrider.containsKey(deviceClass)) {
      return '${iconOverrider[deviceClass]}';
    }

    if (deviceName.contains('automation')) {
      return 'mdi:home-automation';
    }
    if (deviceName.contains('cover')) {
      return isStateOn ? 'mdi:garage-open' : 'mdi:garage';
    }
    if (deviceName.contains('door_window')) {
      return isStateOn ? 'mdi:window-open' : 'mdi:window-closed';
    }
    if (deviceName.contains('illumination')) {
      return 'mdi:brightness-4';
    }
    if (deviceName.contains('humidity')) {
      return 'mdi:water-percent';
    }
    if (deviceName.contains('light')) {
      return 'mdi:brightness-4';
    }
    if (deviceName.contains('motion')) {
      return isStateOn ? 'mdi:run' : 'mdi:walk';
    }
    if (deviceName.contains('pressure')) {
      return 'mdi:gauge';
    }
    if (deviceName.contains('smoke')) {
      return 'mdi:fire';
    }
    if (deviceName.contains('temperature')) {
      return 'mdi:thermometer';
    }
    if (deviceName.contains('time')) {
      return 'mdi:clock';
    }
    if (deviceName.contains('switch')) {
      return 'mdi:toggle-switch';
    }
    if (deviceName.contains('water_leak')) {
      return 'mdi:water-off';
    }
    if (deviceName.contains('water')) {
      return 'mdi:water';
    }
    if (deviceName.contains('yr_symbol')) {
      return 'mdi:weather-partlycloudy';
    }

    return 'mdi:help-circle';
  }

  Map<String, String> iconOverrider = {
    'automation': 'mdi:home-automation',
    'camera': 'mdi:camera',
    'climate': 'mdi:thermostat',
    'cover': 'mdi:garage',
    'fan': 'mdi:fan',
    'group': 'mdi:group',
    'light': 'mdi:lightbulb',
    'lock': 'mdi:lock',
    'media_player': 'mdi:cast',
    'person': 'mdi:account',
    'sun': 'mdi:white-balance-sunny',
    'script': 'mdi:script-text',
    'switch': 'mdi:power',
    'timer': 'mdi:timer',
    'vacuum': 'mdi:robot-vacuum',
    'weather': 'mdi:weather-partlycloudy',
  };

  bool get isStateOn {
    var stateLower = state.toLowerCase();
    if ([
      'on',
      'turning on...',
      'open',
      'opening...',
      'unlocked',
      'unlocking...'
    ].contains(stateLower)) {
      return true;
    }

    if (entityId.split('.')[0] == 'climate' && state.toLowerCase() != 'off') {
      return true;
    }
    return false;
  }
}
