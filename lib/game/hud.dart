import 'dart:async';
import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' hide Viewport;

class Hud extends Component with ParentIsA<Viewport> {
  Hud({required Sprite snowmanSprite})
      : _snowman = SpriteComponent(
          sprite: snowmanSprite,
          anchor: Anchor.center,
        );

  final _count = TextComponent(
    text: 'x0',
    anchor: Anchor.centerLeft,
    textRenderer: TextPaint(
      style: const TextStyle(color: Colors.black, fontSize: 10),
    ),
  );

  final SpriteComponent _snowman;

  @override
  Future<void> onLoad() async {
    _snowman.position.setValues(
      parent.virtualSize.x - 35,
      parent.virtualSize.y - 20,
    );

    _count.position.setValues(
      _snowman.position.x + 8,
      _snowman.position.y,
    );

    await addAll([_snowman, _count]);
  }

  void updateSnowmanCount(int count) {
    _count.text = 'x$count';

    _snowman.add(
      RotateEffect.by(
        pi / 8,
        EffectController(
          duration: 0.1,
          alternate: true,
          repeatCount: 2,
        ),
      ),
    );

    _count.add(
      ScaleEffect.by(
        Vector2.all(1.5),
        EffectController(
          duration: 0.1,
          alternate: true,
        ),
      ),
    );
  }
}
