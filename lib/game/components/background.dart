import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Background extends SpriteComponent with HasGameRef {
  Background() : super(priority: -1);

  @override
  Future<void> onLoad() async {
    final ByteData data = await rootBundle.load('assets/background.png');
    final image = await decodeImageFromList(data.buffer.asUint8List());
    await gameRef.images.load('assets/background.png');
    sprite = Sprite(gameRef.images.fromCache('assets/background.png'));
    size = gameRef.size;
  }
} 