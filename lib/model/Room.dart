import 'package:flutter/cupertino.dart';

class Room {
  String name;
  int imageIndex;
  List<String> entities;

  Room({@required this.name, @required this.imageIndex, this.entities});

  Map<String, dynamic> toJson() => {
        'name': name,
        'imageIndex': imageIndex,
        'entities': entities,
      };

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
        name: json['name'],
        imageIndex: json['imageIndex'],
        entities: json['entities'] != null
            ? List<String>.from(json['entities'])
            : null);
  }
}
