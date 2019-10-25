import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

class CameraThumbnail {
  String entityId;
  DateTime receivedDateTime;
  ImageProvider image;

  CameraThumbnail({
    this.entityId,
    this.receivedDateTime,
    this.image,
  });

  void thumbnailUpdate(Uint8List content) {
    receivedDateTime = DateTime.now();
    image = MemoryImage(content);
  }
}
