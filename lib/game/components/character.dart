import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CharacterType {
  bear,
  capico,
  frog,
  snake,
}

class Character extends SpriteComponent with HasGameRef {
  final CharacterType type;
  bool isConnected = false;
  Vector2 velocity = Vector2(0, 200); // Initial downward velocity

  Character({
    required this.type,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    // Retrieve the already loaded sprite from the game's image cache
    String spritePath = '';
    switch (type) {
      case CharacterType.bear:
        spritePath = 'assets/bear.png';
        break;
      case CharacterType.capico:
        spritePath = 'assets/capico.png';
        break;
      case CharacterType.frog:
        spritePath = 'assets/frog.png';
        break;
      case CharacterType.snake:
        spritePath = 'assets/snake.png';
        break;
    }
    final ByteData data = await rootBundle.load(spritePath);
    final image = await decodeImageFromList(data.buffer.asUint8List());
    await gameRef.images.load(spritePath);
    sprite = Sprite(gameRef.images.fromCache(spritePath));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    // Check if character is out of bounds
    if (position.y > gameRef.size.y) {
      removeFromParent();
    }
  }

  void connect() {
    isConnected = true;
    // TODO: Add connection visual effects
  }

  void disconnect() {
    isConnected = false;
    // TODO: Remove connection visual effects
  }
} 