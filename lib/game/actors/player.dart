import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:ski_master/game/actors/snowman.dart';
import 'package:ski_master/game/routes/gameplay.dart';

class Player extends PositionComponent
    with HasGameReference, HasAncestor<Gameplay>, CollisionCallbacks {
  Player({super.position, required Sprite sprite})
      : _body = SpriteComponent(sprite: sprite, anchor: Anchor.center);

  final SpriteComponent _body;
  final _moveDirection = Vector2(0, 1);

  static const _maxSpeed = 80;
  static const _acceleration = 0.5;
  var _speed = 0.0;

  @override
  Future<void> onLoad() async {
    await add(_body);
    await add(
      CircleHitbox.relative(1, parentSize: _body.size, anchor: Anchor.center),
    );
  }

  @override
  void update(double dt) {
    _moveDirection.x = ancestor.input.hAxis;
    _moveDirection.y = 1;

    _moveDirection.normalize();
    _speed = lerpDouble(_speed, _maxSpeed, _acceleration * dt)!;

    angle = _moveDirection.screenAngle() + pi;
    position.addScaled(_moveDirection, _speed * dt);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Snowman) {
      other.collect();
    }
  }

  void resetTo(Vector2 resetPosition) {
    position.setFrom(resetPosition);
    _speed *= 0.5;
  }
}
