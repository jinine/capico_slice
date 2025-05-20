import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:color_splice/game/components/character.dart';
import 'package:color_splice/game/components/background.dart';

class CapicoSlice extends FlameGame with TapDetector, HasCollisionDetection {
  late final Background background;
  final List<Character> characters = [];
  int score = 0;
  bool isGameOver = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add background
    background = Background();
    add(background);

    // Start spawning characters
    spawnCharacters();
  }

  void spawnCharacters() {
    // TODO: Implement character spawning logic
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (isGameOver) return;

    final tapPosition = info.eventPosition.global;
    // TODO: Implement tap handling for character connections
  }

  void updateScore(int points) {
    score += points;
    // TODO: Update score display
  }

  void gameOver() {
    isGameOver = true;
    // TODO: Show game over screen
  }
} 