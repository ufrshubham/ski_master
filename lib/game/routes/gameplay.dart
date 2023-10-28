import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';
import 'package:ski_master/game/input.dart';
import 'package:ski_master/game/player.dart';

class Gameplay extends Component {
  Gameplay(
    this.currentLevel, {
    super.key,
    required this.onPausePressed,
    required this.onLevelCompleted,
    required this.onGameOver,
  });

  static const id = 'Gameplay';

  final int currentLevel;
  final VoidCallback onPausePressed;
  final VoidCallback onLevelCompleted;
  final VoidCallback onGameOver;

  late final input = Input(
    keyCallbacks: {
      LogicalKeyboardKey.keyP: onPausePressed,
      LogicalKeyboardKey.keyC: onLevelCompleted,
      LogicalKeyboardKey.keyO: onGameOver,
    },
  );

  @override
  Future<void> onLoad() async {
    // ignore: avoid_print
    print('Current Level: $currentLevel');

    final map = await TiledComponent.load('Level1.tmx', Vector2.all(16));
    final player = Player(position: Vector2(map.size.x * 0.5, 8));

    final world = World(children: [map, input, player]);
    await add(world);

    final camera = CameraComponent.withFixedResolution(
      width: 320,
      height: 180,
      world: world,
    );
    await add(camera);

    camera.follow(player);
  }
}
