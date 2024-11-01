import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_behaviors/src/entity.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/widgets.dart';
import 'package:leap/leap.dart';
import 'package:super_dash/audio/audio.dart';
import 'package:super_dash/game/game.dart';

class Player extends JumperCharacter<SuperDashGame>
    with HasGameRef<SuperDashGame>, HasAnimationGroup, HasHealth {
  Player({
    required this.levelSize,
    required this.cameraViewport,
  }) {
    health = initialHealth;
    cameraAnchor = PlayerCameraAnchor(
      cameraViewport: cameraViewport,
      levelSize: levelSize,
      showCameraBounds: true,
    );

    add(JumperAccelerationBehavior());
    add(GravityAccelerationBehavior());
    // Global collision detection
    add(CollisionDetectionBehavior());
    // Other state based behaviors
    add(OnLadderMovementBehavior());
    // Apply velocity to position (respecting collisions)
    add(ApplyVelocityBehavior());
    // Cosemetic behaviors
    // add(AnimationVelocityFlipBehavior());

    // Children
    add(animationGroup);

    health = 1;
    solidTags.add(CommonTags.ground);
  }

  bool get isOnGround => collisionInfo.down;

  static const initialHealth = 1;
  static const speed = 5.0;
  static const jumpImpulse = .6;

  final Vector2 levelSize;
  final Vector2 cameraViewport;
  late Vector2 spawn;
  late List<Vector2> respawnPoints;
  late final PlayerCameraAnchor cameraAnchor;
  late final PlayerStateBehavior stateBehavior =
      findBehavior<PlayerStateBehavior>();

  bool hasGoldenFeather = false;
  bool isPlayerInvincible = false;
  bool isPlayerTeleporting = false;
  bool isPlayerRespawning = false;

  double? _gameOverTimer;

  double? _stuckTimer;
  double _dashPosition = 0;

  bool get isGoingToGameOver => _gameOverTimer != null;

  @override
  int get priority => 1;

  void jumpEffects() {
    jumping = true;
    final jumpSound = hasGoldenFeather ? Sfx.phoenixJump : Sfx.jump;
    gameRef.audioController.playSfx(jumpSound);

    final newJumpState =
        hasGoldenFeather ? DashState.phoenixJump : DashState.jump;
    stateBehavior.state = newJumpState;
  }

  void doubleJumpEffects() {
    jumping = true;
    gameRef.audioController.playSfx(Sfx.phoenixJump);
    stateBehavior.state = DashState.phoenixDoubleJump;
  }

  @override
  set isWalking(bool value) {
    if (!super.isWalking && value) {
      setRunningState();
    } else if (super.isWalking && !value) {
      setIdleState();
    }

    super.isWalking = value;
  }

  void setRunningState() {
    final behavior = stateBehavior;
    if (behavior.state != DashState.running &&
        behavior.state != DashState.phoenixRunning) {
      final newRunState =
          hasGoldenFeather ? DashState.phoenixRunning : DashState.running;
      if (behavior.state != newRunState) {
        behavior.state = newRunState;
      }
    }
  }

  void setIdleState() {
    stateBehavior.state =
        hasGoldenFeather ? DashState.phoenixIdle : DashState.idle;
  }

  @override
  void onLoad() {
    super.onLoad();
    add(PlayerControllerBehavior());
    add(PlayerStateBehavior());
    add(cameraAnchor);
    gameRef.camera.follow(cameraAnchor);
    size = Vector2.all(gameRef.tileSize * .5);
    walkSpeed = gameRef.tileSize * speed;
    minJumpImpulse = gameRef.world.gravity * jumpImpulse;
    loadSpawnPoint();
    loadRespawnPoints();
  }

  void loadRespawnPoints() {
    final respawnGroup = gameRef.leapMap.getTileLayer<ObjectGroup>('respawn');
    respawnPoints = [
      ...respawnGroup.objects.map(
        (object) => Vector2(object.x, object.y),
      ),
    ];
  }

  void loadSpawnPoint() {
    final spawnGroup = gameRef.leapMap.getTileLayer<ObjectGroup>('spawn');
    for (final object in spawnGroup.objects) {
      position = Vector2(object.x, object.y);
      spawn = position.clone();
    }
  }

  void addPowerUp() {
    hasGoldenFeather = true;

    if (stateBehavior.state == DashState.idle) {
      stateBehavior.state = DashState.phoenixIdle;
    } else if (stateBehavior.state == DashState.running) {
      stateBehavior.state = DashState.phoenixRunning;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_gameOverTimer != null) {
      _gameOverTimer = _gameOverTimer! - dt;
      if (_gameOverTimer! <= 0) {
        _gameOverTimer = null;
        gameRef.gameOver();
      }
      return;
    }

    _checkPlayerStuck(dt);

    if (isPlayerTeleporting) return;

    if ((gameRef.isLastSection && x >= gameRef.leapMap.width - tileSize) ||
        (!gameRef.isLastSection &&
            x >= gameRef.leapMap.width - gameRef.tileSize * 15)) {
      sectionCleared();
      return;
    }

    if (isDead) {
      return _animateToGameOver();
    }

    // Player falls in a hazard zone.
    if ((collisionInfo.downCollision?.tags.contains('hazard') ?? false) &&
        !isPlayerInvincible) {
      // If player has no golden feathers, game over.
      if (!hasGoldenFeather) {
        _animateToGameOver(DashState.deathPit);
        return;
      }

      // If player has a golden feather, use it to avoid death.
      hasGoldenFeather = false;
      return respawn();
    }

    final collisions = collisionInfo.allCollisions;

    if (collisions.isEmpty) return;

    for (final collision in collisions) {
      if (collision is Item) {
        switch (collision.type) {
          case ItemType.acorn || ItemType.egg:
            gameRef.audioController.playSfx(
              collision.type == ItemType.acorn
                  ? Sfx.acornPickup
                  : Sfx.eggPickup,
            );
            gameRef.gameBloc.add(
              GameScoreIncreased(by: collision.type.points),
            );
          case ItemType.goldenFeather:
            addPowerUp();
            gameRef.audioController.playSfx(Sfx.featherPowerup);
        }
        gameRef.world.add(
          ItemEffect(
            type: collision.type,
            position: collision.position.clone(),
          ),
        );
        collision.removeFromParent();
      }

      if (collision is Enemy && !isPlayerInvincible) {
        // If player has no golden feathers, game over.
        if (!hasGoldenFeather) {
          health -= collision.enemyDamage;
          return;
        }

        // If player has a golden feather, use it to avoid death.
        hasGoldenFeather = false;
        return respawn();
      }
    }
  }

  void _checkPlayerStuck(double dt) {
    final currentDashPosition = position.x;
    final isPlayerStopped = currentDashPosition == _dashPosition;
    // Player is set as walking but is not moving.
    if (isWalking && isPlayerStopped) {
      _stuckTimer ??= 1;
      _stuckTimer = _stuckTimer! - dt;
      if (_stuckTimer! <= 0) {
        _stuckTimer = null;
        health = 0;
      }
    } else {
      _stuckTimer = null;
    }
    _dashPosition = currentDashPosition;
  }

  void _animateToGameOver([DashState deathState = DashState.deathFaint]) {
    stateBehavior.state = deathState;
    super.isWalking = false;
    _gameOverTimer = 1.4;
  }

  void respawn() {
    // Get closest value to gridX and gridY in respawnPoints.
    final respawnPointsBehind = respawnPoints.where((point) {
      return point.x < position.x;
    });

    Vector2 closestRespawn;
    if (respawnPointsBehind.isEmpty) {
      closestRespawn = spawn;
    } else {
      closestRespawn = respawnPointsBehind.reduce((a, b) {
        return (a - position).length2 < (b - position).length2 ? a : b;
      });
    }

    isPlayerRespawning = true;
    isPlayerInvincible = true;
    isWalking = false;
    stateBehavior.fadeOut();
    add(
      MoveToEffect(
        closestRespawn.clone(),
        EffectController(
          curve: Curves.easeInOut,
          startDelay: .2,
          duration: .8,
        ),
      ),
    );
    stateBehavior.fadeIn(
      onComplete: () {
        isPlayerRespawning = false;
        isPlayerInvincible = false;
        isWalking = true;
      },
    );
  }

  void spritePaintColor(Color color) {
    stateBehavior.updateSpritePaintColor(color);
  }

  Future<void> sectionCleared() async {
    isPlayerTeleporting = true;
    await gameRef.sectionCleared();
  }

  @override
  AnchoredAnimationGroup animationGroup = PlayerSpriteAnimation();
}

// class PlayerCollisionBehavior extends PhysicalBehavior<Player> {
//   @override
//   void update(double dt) {
//     if (parent.isDead) {
//       return;
//     }

//     if (parent.didEnemyBop) {
//       parent.didEnemyBop = false;
//       velocity.y = -parent.minJumpImpulse;
//     }

//     for (final other in collisionInfo.allCollisions) {
//       if (other is Coin) {
//         other.collect();
//         parent.coins++;
//         parent._checkForLevelCompletion();
//       }

//       if (other is InfoText) {
//         other.activateText();
//       }

//       if (other is Door &&
//           parent._input.justPressed &&
//           parent._input.isPressedCenter) {
//         other.enter(parent);
//       }
//     }
//   }
// }

// class PlayerDeathBehavior extends PhysicalBehavior<Player> {
//   @override
//   void update(double dt) {
//     if (parent.isDead) {
//       parent.deadTime += dt;
//       // Set zero on velocity again in case player died this tick
//       parent.velocity.setZero();
//     }

//     if (leapWorld.isOutside(parent) || (parent.isDead && parent.deadTime > 3)) {
//       parent.health = parent.initialHealth;
//       parent.deadTime = 0;
//       parent.resetPosition();
//     }

//     if (parent.wasAlive && !parent.isAlive) {
//       FlameAudio.play('die.wav');
//     }
//   }
// }

class PlayerSpriteAnimation extends AnchoredAnimationGroup<DashState, Player>
    with HasGameRef<SuperDashGame> {
  PlayerSpriteAnimation() : super(scale: Vector2.all(1));

  @override
  Future<void>? onLoad() async {
    final [
      idleAnimation,
      runningAnimation,
      phoenixIdleAnimation,
      phoenixRunningAnimation,
      deathPitAnimation,
      deathFaintAnimation,
      jumpAnimation,
      phoenixJumpAnimation,
      phoenixDoubleJumpAnimation,
    ] = await Future.wait(
      [
        parent.gameRef.loadSpriteAnimation(
          'anim/spritesheet_dash_idle.png',
          SpriteAnimationData.sequenced(
            amount: 18,
            stepTime: 0.042,
            textureSize: Vector2.all(parent.gameRef.tileSize),
          ),
        ),
        parent.gameRef.loadSpriteAnimation(
          'anim/spritesheet_dash_run.png',
          SpriteAnimationData.sequenced(
            amount: 16,
            stepTime: 0.042,
            textureSize: Vector2.all(parent.gameRef.tileSize),
          ),
        ),
        parent.gameRef.loadSpriteAnimation(
          'anim/spritesheet_phoenixDash_idle.png',
          SpriteAnimationData.sequenced(
            amount: 18,
            stepTime: 0.042,
            textureSize: Vector2.all(parent.gameRef.tileSize),
          ),
        ),
        parent.gameRef.loadSpriteAnimation(
          'anim/spritesheet_phoenixDash_run.png',
          SpriteAnimationData.sequenced(
            amount: 16,
            stepTime: 0.042,
            textureSize: Vector2.all(parent.gameRef.tileSize),
          ),
        ),
        parent.gameRef.loadSpriteAnimation(
          'anim/spritesheet_dash_deathPit.png',
          SpriteAnimationData.sequenced(
            amount: 24,
            stepTime: 0.042,
            textureSize: Vector2.all(parent.gameRef.tileSize),
            amountPerRow: 8,
            loop: false,
          ),
        ),
        parent.gameRef.loadSpriteAnimation(
          'anim/spritesheet_dash_deathFaint.png',
          SpriteAnimationData.sequenced(
            amount: 24,
            stepTime: 0.042,
            textureSize: Vector2.all(parent.gameRef.tileSize),
            amountPerRow: 8,
            loop: false,
          ),
        ),
        parent.gameRef.loadSpriteAnimation(
          'anim/spritesheet_dash_jump.png',
          SpriteAnimationData.sequenced(
            amount: 16,
            stepTime: 0.042,
            textureSize: Vector2.all(parent.gameRef.tileSize),
            loop: false,
          ),
        ),
        parent.gameRef.loadSpriteAnimation(
          'anim/spritesheet_phoenixDash_jump.png',
          SpriteAnimationData.sequenced(
            amount: 16,
            stepTime: 0.042,
            textureSize: Vector2(
              parent.gameRef.tileSize,
              parent.gameRef.tileSize * 2,
            ),
            amountPerRow: 8,
            loop: false,
          ),
        ),
        parent.gameRef.loadSpriteAnimation(
          'anim/spritesheet_phoenixDash_doublejump.png',
          SpriteAnimationData.sequenced(
            amount: 16,
            stepTime: 0.042,
            textureSize: Vector2.all(parent.gameRef.tileSize),
            loop: false,
          ),
        ),
      ],
    );

    animations = {
      DashState.idle: idleAnimation,
      DashState.running: runningAnimation,
      DashState.phoenixIdle: phoenixIdleAnimation,
      DashState.phoenixRunning: phoenixRunningAnimation,
      DashState.deathPit: deathPitAnimation,
      DashState.deathFaint: deathFaintAnimation,
      DashState.jump: jumpAnimation,
      DashState.phoenixJump: phoenixJumpAnimation,
      DashState.phoenixDoubleJump: phoenixDoubleJumpAnimation,
    };

    current = DashState.idle;

    return super.onLoad();
  }

  @override
  @mustCallSuper
  void update(double dt) {
    playing = true;

    if (parent.isDead) {
      current = DashState.deathPit;
    } else if (parent.hasStatus<OnLadderStatus>()) {
      if (parent.getStatus<OnLadderStatus>()!.movement ==
          LadderMovement.stopped) {
        playing = false;
      } else {
        playing = true;
      }
      current = DashState.running;
    } else {
      if (parent.collisionInfo.down) {
        // On the ground.
        if (parent.velocity.x.abs() > 0) {
          current = DashState.running;
        } else {
          current = DashState.idle;
        }
      } else {
        // In the air.
        if (parent.velocity.y > (parent.leapWorld.maxGravityVelocity)) {
          current = DashState.phoenixRunning;
        } else if (parent.velocity.y >
            (parent.leapWorld.maxGravityVelocity / 4)) {
          current = DashState.running;
        } else if (parent.velocity.y < 0) {
          current = DashState.jump;
        }
      }
    }
    super.update(dt);
  }
}
