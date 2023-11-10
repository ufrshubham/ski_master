import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';
import 'package:ski_master/game/actors/snowman.dart';
import 'package:ski_master/game/input.dart';
import 'package:ski_master/game/actors/player.dart';

class Gameplay extends Component with HasGameReference {
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
    final world = World(children: [map, input]);
    await add(world);

    final camera = CameraComponent.withFixedResolution(
      width: 320,
      height: 180,
      world: world,
    );
    await add(camera);

    final tiles = game.images.fromCache('../images/tilemap_packed.png');
    final spriteSheet = SpriteSheet(image: tiles, srcSize: Vector2.all(16));

    final spawnPointLayer = map.tileMap.getLayer<ObjectGroup>('SpawnPoint');
    final objects = spawnPointLayer?.objects;

    if (objects != null) {
      for (final object in objects) {
        switch (object.class_) {
          case 'Player':
            final player = Player(
              position: Vector2(object.x, object.y),
              sprite: spriteSheet.getSprite(5, 10),
            );
            await world.add(player);
            camera.follow(player);
            break;
          case 'Snowman':
            final snowman = Snowman(
              position: Vector2(object.x, object.y),
              sprite: spriteSheet.getSprite(5, 9),
            );
            await world.add(snowman);
            break;
        }
      }
    }
  }
}
