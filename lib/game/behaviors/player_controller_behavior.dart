import 'dart:async';

import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/widgets.dart';
import 'package:leap/leap.dart';
import 'package:super_dash/game/game.dart';

class PlayerControllerBehavior extends PhysicalBehavior<Player> {
  @visibleForTesting
  bool doubleJumpUsed = false;

  double _jumpTimer = 0;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    parent.gameRef.addInputListener(_handleInput);
  }

  @override
  void onRemove() {
    super.onRemove();

    parent.gameRef.removeInputListener(_handleInput);
  }

  void _handleInput() {
    parent.isWalking = true;
    if (parent.isDead ||
        parent.isPlayerTeleporting ||
        parent.isPlayerRespawning ||
        parent.isGoingToGameOver) {
      return;
    }

    // Do nothing when there is a jump cool down
    if (_jumpTimer >= 0) {
      return;
    }

    // If is no isWalking, start isWalking
    if (!parent.isWalking) {
      parent.isWalking = true;
      return;
    }

    // If is isWalking, jump
    if (parent.isWalking) {
      parent
        ..jumpEffects()
        ..jumping = true;
      _jumpTimer = 0.01;
      return;
    }

    // If is isWalking and double jump is enabled, double jump
    if (parent.isWalking &&
        !parent.isOnGround &&
        parent.hasGoldenFeather &&
        !doubleJumpUsed) {
      parent
        ..doubleJumpEffects()
        ..jumping = true;
      _jumpTimer = 0.06;
      doubleJumpUsed = true;
      return;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (parent.isDead && parent.jumping) {
      parent.jumping = false;
    }

    if (parent.isDead ||
        parent.isPlayerTeleporting ||
        parent.isGoingToGameOver) {
      return;
    }

    if (_jumpTimer >= 0) {
      _jumpTimer -= dt;

      if (_jumpTimer <= 0) {
        parent.jumping = false;
      }
    }

    if (_jumpTimer <= 0 && parent.isOnGround && parent.isWalking) {
      parent.setRunningState();
    }

    if (doubleJumpUsed && parent.isOnGround) {
      doubleJumpUsed = false;
    }
  }
}
