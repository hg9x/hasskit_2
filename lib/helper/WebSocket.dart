import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hasskit_2/helper/providerData.dart';
import 'package:web_socket_channel/io.dart';
import 'Logger.dart';

///
/// Application-level global variable to access the WebSockets
///
WebSocket webSocket = new WebSocket();

///
/// Put your WebSockets server IP address and port number
///
//const String _SERVER_ADDRESS = "ws://192.168.1.45:34263";
///
///https://www.didierboelens.com/2018/06/web-sockets---build-a-real-time-game/
///

class WebSocket {
  static final WebSocket _sockets = new WebSocket._internal();

  factory WebSocket() {
    return _sockets;
  }

  WebSocket._internal();

  ///
  /// The WebSocket "open" channel
  ///
  IOWebSocketChannel _channel;

  ///
  /// Is the connection established?
  ///
  bool connected = false;

  ///
  /// Listeners
  /// List of methods to be called when a new message
  /// comes in.
  ///
  ObserverList<Function> _listeners = new ObserverList<Function>();

  /// ----------------------------------------------------------
  /// Initialization the WebSockets connection with the server
  /// ----------------------------------------------------------
  initCommunication() async {
    Logger.d(
        'initCommunication socketUrl ${gd.socketUrl} autoConnect ${gd.autoConnect} connectionStatus ${gd.connectionStatus}');

    ///
    /// Just in case, close any previous communication
    ///
    reset();

    ///
    /// Open a new WebSocket communication
    ///
    try {
      _channel = new IOWebSocketChannel.connect(gd.socketUrl,
          pingInterval: Duration(seconds: 15));

//      providerData.connectionError = '';
//      providerData.connectionStatus = 'Connecting...';
//      providerData.serverConnected = false;

      ///
      /// Start listening to new notifications / messages
      ///
      _channel.stream.listen(_onData,
          onDone: _onDone, onError: _onError, cancelOnError: false);
    } catch (e) {
      ///
      /// General error handling
      Logger.d('initCommunication catch $e');
      gd.connectionStatus = 'Error:\n' + e.toString();
      connected = false;

      ///
    }
  }

  /// ----------------------------------------------------------
  /// Closes the WebSocket communication
  /// ----------------------------------------------------------
  reset() {
    if (_channel != null) {
      if (_channel.sink != null) {
        _channel.sink.close();
        connected = false;
        gd.connectionStatus = "reset";
        gd.socketId = 0;
        gd.subscribeEventsId = 0;
//        providerData.cameraThumbnailsId.clear();
//        providerData.cameraRequestTime.clear();
//        providerData.cameraActives.clear();
      }
    }
  }

  /// ---------------------------------------------------------
  /// Sends a message to the server
  /// ---------------------------------------------------------
  send(String message) {
    Logger.d("send String message $message");
    if (_channel != null) {
      if (_channel.sink != null && connected) {
        var decode = json.decode(message);
        int id = decode['id'];
        String type = decode['type'];

        if (type == 'subscribe_events') {
          if (gd.subscribeEventsId != 0) {
            Logger.d('??? subscribe_events We do not sub twice');
            return;
          }
          gd.subscribeEventsId = id;
        }

        if (type == 'get_states') {
          gd.getStatesId = id;
        }
        if (type == 'lovelace/config') {
          gd.loveLaceConfigId = id;
        }
        if (type == 'camera_thumbnail' && decode['entity_id'] != null) {
          gd.cameraThumbnailsId[id] = decode['entity_id'];
        }

        _channel.sink.add(message);
        Logger.d('WebSocket send: id $id type $type $message');
        gd.socketIdIncrement();
      }
    }
  }

  /// ---------------------------------------------------------
  /// Adds a callback to be invoked in case of incoming
  /// notification
  /// ---------------------------------------------------------
  addListener(Function callback) {
    _listeners.add(callback);
  }

  removeListener(Function callback) {
    _listeners.remove(callback);
  }

  /// ----------------------------------------------------------
  /// Callback which is invoked each time that we are receiving
  /// a message from the server
  /// ----------------------------------------------------------
  _onData(message) {
    connected = true;
    gd.connectionStatus = "Connected";

    var decode = json.decode(message);
    Logger.d("_onData decode $decode");

    var type = decode['type'];

    var outMsg;
    switch (type) {
      case 'auth_required':
        {
          outMsg = {
            "type": "auth",
            "access_token": "${gd.loginDataCurrent.accessToken}"
          };
          send(json.encode(outMsg));
          gd.connectionStatus = "Sending access_token";
        }
        break;
      case 'auth_ok':
        {
          outMsg = {"id": gd.socketId, "type": "get_states"};
          send(json.encode(outMsg));
          gd.connectionStatus = "Sending get_states";
        }
        break;
      case 'result':
        {
          var success = decode['success'];
          if (!success) {
            Logger.d('result not success');
            break;
          }
          var id = decode['id'];

          if (id == gd.getStatesId) {
            Logger.d('Processing Get States');
            gd.getStates(decode['result']);
            outMsg = {"id": gd.socketId, "type": "lovelace/config"};
            send(json.encode(outMsg));
          } else if (id == gd.loveLaceConfigId) {
            Logger.d('Processing Lovelace Config');
            gd.getLovelaceConfig(decode);
            outMsg = {
              "id": gd.socketId,
              "type": "subscribe_events",
              "event_type": "state_changed"
            };
            send(json.encode(outMsg));
          } else if (gd.cameraThumbnailsId.containsKey(id)) {
            var content = decode['result']['content'];
//            Logger.d(
//                'cameraThumbnailsId $id ${providerData.cameraThumbnailsId[id]} content $content');
            gd.camerasThumbnailUpdate(gd.cameraThumbnailsId[id], content);
          } else {
//            Logger.d('providerData.socketIdServices $id == null $decode');
          }
        }
        break;
      case 'auth_invalid':
        {
          gd.connectionStatus = 'auth_invalid';
        }
        break;
      case 'event':
        {
          gd.connectionStatus = 'Connected';
        }
        break;
      default:
        {
          Logger.d('type default $decode');
        }
    }

//    _listeners.forEach((Function callback) {
//      callback(message);
//    });
  }

  void _onDone() {
//    providerData.connectionStatus = 'Disconnected';
    gd.connectionStatus = 'On Done';
    connected = false;
    Logger.d('_onDone');
  }

  _onError(error, StackTrace stackTrace) {
    gd.connectionStatus = 'On Error\n' + error.toString();
    connected = false;
    Logger.d('_onError error: $error stackTrace: $stackTrace');
  }
}
