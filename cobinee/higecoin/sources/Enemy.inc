; Enemy.inc : エネミー
;


; マクロの定義
;

; エネミー
ENEMY_TYPE                      =   0x00
ENEMY_STATE                     =   0x01
ENEMY_DIRECTION                 =   0x02
ENEMY_POSITION_X                =   0x03
ENEMY_POSITION_Y                =   0x04
ENEMY_PATTERN                   =   0x05
ENEMY_COLOR                     =   0x06
ENEMY_ANIMATION                 =   0x07
ENEMY_SIZE                      =   0x08
ENEMY_N                         =   0x04

; 種類
ENEMY_TYPE_NULL                 =   0x00
ENEMY_TYPE_CRAB                 =   0x01
ENEMY_TYPE_SPIN                 =   0x02

; 状態
ENEMY_STATE_NULL                =   0x00
ENEMY_STATE_OPEN                =   0x10
ENEMY_STATE_STAY                =   0x20
ENEMY_STATE_MOVE                =   0x30
ENEMY_STATE_KILL                =   0x40
ENEMY_STATE_CLOSE               =   0x50

; 向き
ENEMY_DIRECTION_LEFT            =   0x00
ENEMY_DIRECTION_RIGHT           =   0x01
ENEMY_DIRECTION_UP              =   0x00
ENEMY_DIRECTION_DOWN            =   0x01

; 色
ENEMY_COLOR_NULL                =   0x00
ENEMY_COLOR_SMOKE               =   0x0e
ENEMY_COLOR_KILL                =   0x0e
ENEMY_COLOR_CRAB                =   0x08
ENEMY_COLOR_SPIN                =   0x0d

; 外部関数宣言
;

    .globl  _EnemyInitialize
    .globl  _EnemyCreate
    .globl  _EnemyUpdate
    .globl  _EnemyRender
    .globl  _EnemyHit

; 外部変数宣言
;

    .globl  _enemy
    .globl  _enemyState
