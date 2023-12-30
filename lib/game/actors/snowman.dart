import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/services.dart';
import 'package:ski_master/game/actors/player.dart';

class Snowman extends PositionComponent with CollisionCallbacks {
  Snowman({super.position, required Sprite sprite, this.onCollected})
      : _body = SpriteComponent(sprite: sprite, anchor: Anchor.center);

  final SpriteComponent _body;
  final VoidCallback? onCollected;

  @override
  Future<void> onLoad() async {
    await add(_body);

    await add(
      CircleHitbox.relative(
        1,
        parentSize: _body.size,
        anchor: Anchor.center,
        collisionType: CollisionType.passive,
      ),
    );
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Player) {
      _collect();
    }
  }

  void _collect() {
    addAll([
      OpacityEffect.fadeOut(
        LinearEffectController(0.4),
        target: _body,
        onComplete: removeFromParent,
      ),
      ScaleEffect.by(
        Vector2.all(1.2),
        LinearEffectController(0.4),
      ),
    ]);

    onCollected?.call();
  }
}
