import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:ski_master/game/game.dart';

class Input extends Component with KeyboardHandler, HasGameReference {
  Input({Map<LogicalKeyboardKey, VoidCallback>? keyCallbacks})
    : _keyCallbacks = keyCallbacks ?? <LogicalKeyboardKey, VoidCallback>{};

  bool _leftPressed = false;
  bool _rightPressed = false;

  var _leftInput = 0.0;
  var _rightInput = 0.0;

  final maxHAxis = 1.5;
  final sensitivity = 2.0;

  var hAxis = 0.0;
  bool active = false;

  final Map<LogicalKeyboardKey, VoidCallback> _keyCallbacks;

  @override
  void update(double dt) {
    if (!SkiMasterGame.isMobile) {
      _leftInput =
          lerpDouble(
            _leftInput,
            (_leftPressed && active) ? maxHAxis : 0,
            sensitivity * dt,
          )!;

      _rightInput =
          lerpDouble(
            _rightInput,
            (_rightPressed && active) ? maxHAxis : 0,
            sensitivity * dt,
          )!;

      hAxis = _rightInput - _leftInput;
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!SkiMasterGame.isMobile && game.paused == false) {
      _leftPressed =
          keysPressed.contains(LogicalKeyboardKey.keyA) ||
          keysPressed.contains(LogicalKeyboardKey.arrowLeft);
      _rightPressed =
          keysPressed.contains(LogicalKeyboardKey.keyD) ||
          keysPressed.contains(LogicalKeyboardKey.arrowRight);

      if (active && event is KeyDownEvent) {
        for (final entry in _keyCallbacks.entries) {
          if (entry.key == event.logicalKey) {
            entry.value.call();
          }
        }
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
