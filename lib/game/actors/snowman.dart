import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class Snowman extends PositionComponent {
  Snowman({super.position, required Sprite sprite})
      : _body = SpriteComponent(sprite: sprite, anchor: Anchor.center);

  final SpriteComponent _body;

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

  void collect() {
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
  }
}
