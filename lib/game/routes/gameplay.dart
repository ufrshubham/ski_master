import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ski_master/game/actors/snowman.dart';
import 'package:ski_master/game/hud.dart';
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
  static const _timeScaleRate = 1;

  final int currentLevel;
  final VoidCallback onPausePressed;
  final ValueChanged<int> onLevelCompleted;
  final VoidCallback onGameOver;

  late final input = Input(
    keyCallbacks: {
      LogicalKeyboardKey.keyP: onPausePressed,
      LogicalKeyboardKey.keyC: () => onLevelCompleted.call(3),
      LogicalKeyboardKey.keyO: onGameOver,
    },
  );

  late final _resetTimer = Timer(1, autoStart: false, onTick: _resetPlayer);

  late final World _world;
  late final CameraComponent _camera;
  late final Player _player;
  late final Vector2 _lastSafePosition;
  late final RectangleComponent _fader;
  late final Hud _hud;
  late final SpriteSheet _spriteSheet;

  int _nSnowmanCollected = 0;
  int _nLives = 3;

  late int _star1;
  late int _star2;
  late int _star3;

  int _nTrailTriggers = 0;
  bool get _isOffTrail => _nTrailTriggers == 0;

  bool _levelCompleted = false;
  bool _gameOver = false;

  @override
  Future<void> onLoad() async {
    final map = await TiledComponent.load(
      'Level$currentLevel.tmx',
      Vector2.all(16),
    );

    final tiles = game.images.fromCache('../images/tilemap_packed.png');
    _spriteSheet = SpriteSheet(image: tiles, srcSize: Vector2.all(16));

    _star1 = map.tileMap.map.properties.getValue<int>('Star1')!;
    _star2 = map.tileMap.map.properties.getValue<int>('Star2')!;
    _star3 = map.tileMap.map.properties.getValue<int>('Star3')!;

    await _setupWorldAndCamera(map);
    await _handleSpawnPoints(map);
    await _handleTriggers(map);

    _fader = RectangleComponent(
      size: _camera.viewport.virtualSize,
      paint: Paint()..color = game.backgroundColor(),
      children: [OpacityEffect.fadeOut(LinearEffectController(1.5))],
      priority: 1,
    );

    _hud = Hud(
      playerSprite: _spriteSheet.getSprite(5, 10),
      snowmanSprite: _spriteSheet.getSprite(5, 9),
    );

    await _camera.viewport.addAll([_fader, _hud]);
  }

  @override
  void update(double dt) {
    if (_levelCompleted || _gameOver) {
      _player.timeScale = lerpDouble(
        _player.timeScale,
        0,
        _timeScaleRate * dt,
      )!;
    } else {
      if (_isOffTrail && input.active) {
        _resetTimer.update(dt);

        if (!_resetTimer.isRunning()) {
          _resetTimer.start();
        }
      } else {
        if (_resetTimer.isRunning()) {
          _resetTimer.stop();
        }
      }
    }
  }

  Future<void> _setupWorldAndCamera(TiledComponent map) async {
    _world = World(children: [map, input]);
    await add(_world);

    _camera = CameraComponent.withFixedResolution(
      width: 320,
      height: 180,
      world: _world,
    );
    await add(_camera);
  }

  Future<void> _handleSpawnPoints(TiledComponent map) async {
    final spawnPointLayer = map.tileMap.getLayer<ObjectGroup>('SpawnPoint');
    final objects = spawnPointLayer?.objects;

    if (objects != null) {
      for (final object in objects) {
        switch (object.class_) {
          case 'Player':
            _player = Player(
              position: Vector2(object.x, object.y),
              sprite: _spriteSheet.getSprite(5, 10),
            );
            await _world.add(_player);
            _camera.follow(_player);
            _lastSafePosition = Vector2(object.x, object.y);
            break;
          case 'Snowman':
            final snowman = Snowman(
              position: Vector2(object.x, object.y),
              sprite: _spriteSheet.getSprite(5, 9),
              onCollected: _onSnowmanCollected,
            );
            await _world.add(snowman);
            break;
        }
      }
    }
  }

  Future<void> _handleTriggers(TiledComponent map) async {
    final triggerLayer = map.tileMap.getLayer<ObjectGroup>('Trigger');
    final objects = triggerLayer?.objects;

    if (objects != null) {
      for (final object in objects) {
        switch (object.class_) {
          case 'Trail':
            final vertices = <Vector2>[];
            for (final point in object.polygon) {
              vertices.add(Vector2(point.x + object.x, point.y + object.y));
            }

            final hitbox = PolygonHitbox(
              vertices,
              collisionType: CollisionType.passive,
              isSolid: true,
            );

            hitbox.onCollisionStartCallback = (_, __) => _onTrailEnter();
            hitbox.onCollisionEndCallback = (_) => _onTrailExit();

            await map.add(hitbox);
            break;

          case 'Checkpoint':
            final checkpoint = RectangleHitbox(
              position: Vector2(object.x, object.y),
              size: Vector2(object.width, object.height),
              collisionType: CollisionType.passive,
            );

            checkpoint.onCollisionStartCallback =
                (_, __) => _onCheckpoint(checkpoint);

            await map.add(checkpoint);
            break;

          case 'Ramp':
            final ramp = RectangleHitbox(
              position: Vector2(object.x, object.y),
              size: Vector2(object.width, object.height),
              collisionType: CollisionType.passive,
            );

            ramp.onCollisionStartCallback = (_, __) => _onRamp();

            await map.add(ramp);
            break;

          case 'Start':
            final trailStart = RectangleHitbox(
              position: Vector2(object.x, object.y),
              size: Vector2(object.width, object.height),
              collisionType: CollisionType.passive,
            );

            trailStart.onCollisionStartCallback = (_, __) => _onTrailStart();

            await map.add(trailStart);
            break;

          case 'End':
            final trailEnd = RectangleHitbox(
              position: Vector2(object.x, object.y),
              size: Vector2(object.width, object.height),
              collisionType: CollisionType.passive,
            );

            trailEnd.onCollisionStartCallback = (_, __) => _onTrailEnd();

            await map.add(trailEnd);
            break;
        }
      }
    }
  }

  void _onTrailEnter() {
    ++_nTrailTriggers;
  }

  void _onTrailExit() {
    --_nTrailTriggers;
  }

  void _onCheckpoint(RectangleHitbox checkpoint) {
    _lastSafePosition.setFrom(checkpoint.absoluteCenter);
    checkpoint.removeFromParent();
  }

  void _onRamp() {
    final jumpFactor = _player.jump();
    final jumpScale = lerpDouble(1, 1.08, jumpFactor)!;
    final jumpDuration = lerpDouble(0, 0.8, jumpFactor)!;

    _camera.viewfinder.add(
      ScaleEffect.by(
        Vector2.all(jumpScale),
        EffectController(
          duration: jumpDuration,
          alternate: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  void _onTrailStart() {
    input.active = true;
    _lastSafePosition.setFrom(_player.position);
  }

  void _onTrailEnd() {
    _fader.add(OpacityEffect.fadeIn(LinearEffectController(1.5)));
    input.active = false;
    _levelCompleted = true;

    if (_nSnowmanCollected >= _star3) {
      onLevelCompleted.call(3);
    } else if (_nSnowmanCollected >= _star2) {
      onLevelCompleted.call(2);
    } else if (_nSnowmanCollected >= _star1) {
      onLevelCompleted.call(1);
    } else {
      onLevelCompleted.call(0);
    }
  }

  void _onSnowmanCollected() {
    ++_nSnowmanCollected;
    _hud.updateSnowmanCount(_nSnowmanCollected);
  }

  void _resetPlayer() {
    --_nLives;
    _hud.updateLifeCount(_nLives);

    if (_nLives > 0) {
      _player.resetTo(_lastSafePosition);
    } else {
      _gameOver = true;
      _fader.add(OpacityEffect.fadeIn(LinearEffectController(1.5)));
      onGameOver.call();
    }
  }
}
