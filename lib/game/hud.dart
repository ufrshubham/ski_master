import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Viewport;
import 'package:ski_master/game/game.dart';
import 'package:ski_master/game/input.dart';

class Hud extends PositionComponent with ParentIsA<Viewport>, HasGameReference {
  Hud({
    required Sprite playerSprite,
    required Sprite snowmanSprite,
    this.input,
    this.onPausePressed,
  }) : _player = SpriteComponent(
         sprite: playerSprite,
         anchor: Anchor.center,
         scale: Vector2.all(SkiMasterGame.isMobile ? 0.6 : 1.0),
       ),
       _snowman = SpriteComponent(
         sprite: snowmanSprite,
         anchor: Anchor.center,
         scale: Vector2.all(SkiMasterGame.isMobile ? 0.6 : 1.0),
       );

  final _life = TextComponent(
    text: 'x3',
    anchor: Anchor.centerLeft,
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.black,
        fontSize: SkiMasterGame.isMobile ? 8 : 10,
      ),
    ),
  );

  final _score = TextComponent(
    text: 'x0',
    anchor: Anchor.centerLeft,
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.black,
        fontSize: SkiMasterGame.isMobile ? 8 : 10,
      ),
    ),
  );

  final SpriteComponent _player;
  final SpriteComponent _snowman;

  late final JoystickComponent? _joystick;
  final Input? input;
  final VoidCallback? onPausePressed;

  @override
  Future<void> onLoad() async {
    _player.position.setValues(
      16,
      SkiMasterGame.isMobile ? 10 : parent.virtualSize.y - 20,
    );

    _life.position.setValues(_player.position.x + 8, _player.position.y);

    _snowman.position.setValues(parent.virtualSize.x - 35, _player.y);

    _score.position.setValues(_snowman.position.x + 8, _snowman.position.y);

    await addAll([_player, _life, _snowman, _score]);

    if (SkiMasterGame.isMobile) {
      _joystick = JoystickComponent(
        anchor: Anchor.center,
        position: parent.virtualSize * 0.5,
        knob: CircleComponent(
          radius: 10,
          paint: Paint()..color = Colors.green.withValues(alpha: 0.08),
        ),
        background: CircleComponent(
          radius: 20,
          paint:
              Paint()
                ..color = Colors.black.withValues(alpha: 0.05)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4,
        ),
      );

      _joystick?.position.y =
          parent.virtualSize.y - _joystick!.knobRadius * 1.5;
      await _joystick?.addToParent(this);

      final pauseButton = HudButtonComponent(
        button: SpriteComponent.fromImage(
          await game.images.load('pause.png'),
          size: Vector2.all(12),
        ),
        anchor: Anchor.bottomRight,
        position: parent.virtualSize,
        onPressed: onPausePressed,
      );
      await add(pauseButton);
    }
  }

  @override
  void update(double dt) {
    if (input?.active ?? false) {
      input?.hAxis =
          lerpDouble(
            input!.hAxis,
            _joystick!.isDragged
                ? _joystick!.relativeDelta.x * input!.maxHAxis
                : 0,
            input!.sensitivity * dt,
          )!;
    }
  }

  void updateSnowmanCount(int count) {
    _score.text = 'x$count';

    _snowman.add(
      RotateEffect.by(
        pi / 8,
        RepeatedEffectController(ZigzagEffectController(period: 0.2), 2),
      ),
    );

    _score.add(
      ScaleEffect.by(
        Vector2.all(1.5),
        EffectController(duration: 0.1, alternate: true),
      ),
    );
  }

  void updateLifeCount(int count) {
    _life.text = 'x$count';

    _player.add(
      RotateEffect.by(
        pi / 8,
        RepeatedEffectController(ZigzagEffectController(period: 0.2), 2),
      ),
    );

    _life.add(
      ScaleEffect.by(
        Vector2.all(1.5),
        EffectController(duration: 0.1, alternate: true),
      ),
    );
  }
}
