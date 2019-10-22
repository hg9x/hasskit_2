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
}
