import 'dart:async';

import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';

class SkiMasterGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final map = await TiledComponent.load('sampleMap.tmx', Vector2.all(16));
    await add(map);
  }
}
