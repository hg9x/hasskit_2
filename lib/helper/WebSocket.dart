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
        'initCommunication socketUrl ${pD.socketUrl} autoConnect ${pD.autoConnect} connectionStatus ${pD.connectionStatus}');

    ///
    /// Just in case, close any previous communication
    ///
    reset();

    ///
    /// Open a new WebSocket communication
    ///
    try {
      _channel = new IOWebSocketChannel.connect(pD.socketUrl,
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
      pD.connectionStatus = 'Error:\n' + e.toString();
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
        pD.connectionStatus = "reset";
        pD.socketId = 0;
        pD.subscribeEventsId = 0;
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
          if (pD.subscribeEventsId != 0) {
            Logger.d('??? subscribe_events We do not sub twice');
            return;
          }
          pD.subscribeEventsId = id;
        }

        if (type == 'get_states') {
          pD.getStatesId = id;
        }
        if (type == 'lovelace/config') {
          pD.loveLaceConfigId = id;
        }
        if (type == 'camera_thumbnail' && decode['entity_id'] != null) {
          pD.cameraThumbnailsId[id] = decode['entity_id'];
        }

        _channel.sink.add(message);
        Logger.d('WebSocket send: id $id type $type $message');
        pD.socketIdIncrement();
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
    pD.connectionStatus = "Connected";

    var decode = json.decode(message);
    Logger.d("_onData decode $decode");

    var type = decode['type'];

    var outMsg;
    switch (type) {
      case 'auth_required':
        {
          outMsg = {
            "type": "auth",
            "access_token": "${pD.loginDataCurrent.accessToken}"
          };
          send(json.encode(outMsg));
          pD.connectionStatus = "Sending access_token";
        }
        break;
      case 'auth_ok':
        {
          outMsg = {"id": pD.socketId, "type": "get_states"};
          send(json.encode(outMsg));
          pD.connectionStatus = "Sending get_states";
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

          if (id == pD.getStatesId) {
            Logger.d('Processing Get States');
            pD.getStates(decode['result']);
            outMsg = {"id": pD.socketId, "type": "lovelace/config"};
            send(json.encode(outMsg));
          } else if (id == pD.loveLaceConfigId) {
            Logger.d('Processing Lovelace Config');
            pD.getLovelaceConfig(decode);
            outMsg = {
              "id": pD.socketId,
              "type": "subscribe_events",
              "event_type": "state_changed"
            };
            send(json.encode(outMsg));
          } else if (pD.cameraThumbnailsId.containsKey(id)) {
            var content = decode['result']['content'];
//            Logger.d(
//                'cameraThumbnailsId $id ${providerData.cameraThumbnailsId[id]} content $content');
            pD.camerasThumbnailUpdate(pD.cameraThumbnailsId[id], content);
          } else {
//            Logger.d('providerData.socketIdServices $id == null $decode');
          }
        }
        break;
      case 'auth_invalid':
        {
          pD.connectionStatus = 'auth_invalid';
        }
        break;
      case 'event':
        {
          pD.connectionStatus = 'Connected';
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
    pD.connectionStatus = 'On Done';
    connected = false;
    Logger.d('_onDone');
  }

  _onError(error, StackTrace stackTrace) {
    pD.connectionStatus = 'On Error\n' + error.toString();
    connected = false;
    Logger.d('_onError error: $error stackTrace: $stackTrace');
  }
}
