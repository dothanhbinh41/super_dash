import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:leap/leap.dart';
import 'package:super_dash/game/game.dart';

enum DashState {
  idle,
  running,

  phoenixIdle,
  phoenixRunning,

  deathPit,
  deathFaint,

  jump,
  phoenixJump,

  phoenixDoubleJump,
}

class PlayerStateBehavior extends PhysicalBehavior<Player> {
  DashState? _state;

  DashState get state => _state ?? DashState.idle;

  static const _needResetStates = {
    DashState.deathPit,
    DashState.deathFaint,
    DashState.jump,
    DashState.phoenixJump,
    DashState.phoenixDoubleJump,
  };

  void updateSpritePaintColor(Color color) {
    // for (final component in _stateMap.values) {
    //   if (component is HasPaint) {
    //     (component as HasPaint).paint.color = color;
    //   }
    // }
  }

  void fadeOut({VoidCallback? onComplete}) {
    // final component = _stateMap[state];
    // if (component != null && component is HasPaint) {
    //   component.add(
    //     OpacityEffect.fadeOut(
    //       EffectController(duration: .5),
    //       onComplete: onComplete,
    //     ),
    //   );
    // }
  }

  void fadeIn({VoidCallback? onComplete}) {
    // final component = _stateMap[state];
    // if (component != null && component is HasPaint) {
    //   component.add(
    //     OpacityEffect.fadeIn(
    //       EffectController(duration: .5, startDelay: .8),
    //       onComplete: onComplete,
    //     ),
    //   );
    // }
  }

  set state(DashState state) {
    _state = state;
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    state = DashState.idle;
  }
}
