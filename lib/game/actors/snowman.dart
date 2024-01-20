import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:ski_master/game/actors/player.dart';

class Snowman extends PositionComponent
    with CollisionCallbacks, HasGameReference {
  Snowman({super.position, required Sprite sprite, this.onCollected})
      : _body = SpriteComponent(sprite: sprite, anchor: Anchor.center);

  final SpriteComponent _body;
  final VoidCallback? onCollected;

  late final _particlePaint = Paint()..color = game.backgroundColor();

  static final _random = Random();
  static Vector2 _randomVector(double scale) {
    return Vector2(2 * _random.nextDouble() - 1, 2 * _random.nextDouble() - 1)
      ..normalize()
      ..scale(scale);
  }

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

    parent?.add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 30,
          lifespan: 1,
          generator: (index) {
            return MovingParticle(
              to: _randomVector(16),
              child: ScalingParticle(
                to: 0,
                child: CircleParticle(
                  radius: 2 + _random.nextDouble() * 3,
                  paint: _particlePaint,
                ),
              ),
            );
          },
        ),
      ),
    );

    onCollected?.call();
  }
}
