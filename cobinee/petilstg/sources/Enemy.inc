; Enemy.inc : エネミー
;


; マクロの定義
;

; ユニット
ENEMY_UNIT_HP       =   0x0e
ENEMY_UNIT_DAMAGE   =   0x0f
ENEMY_UNIT_ATTACK   =   0x10
ENEMY_UNIT_FIRE     =   0x11
ENEMY_UNIT_INTERVAL =   0x12
ENEMY_UNIT_X_SPEED  =   0x14
ENEMY_UNIT_X_LIMIT  =   0x15
ENEMY_UNIT_X_ACCEL  =   0x16
ENEMY_UNIT_X_SGN    =   0x17
ENEMY_UNIT_Y_SPEED  =   0x18
ENEMY_UNIT_Y_LIMIT  =   0x19
ENEMY_UNIT_Y_ACCEL  =   0x1a
ENEMY_UNIT_Y_SGN    =   0x1b
ENEMY_UNIT_Z_SPEED  =   0x1c
ENEMY_UNIT_Z_LIMIT  =   0x1d
ENEMY_UNIT_Z_ACCEL  =   0x1e
ENEMY_UNIT_Z_SGN    =   0x1f


; 外部関数宣言
;

    .globl  _EnemyInitialize
    .globl  _EnemyReset
    .globl  _EnemyUpdate
    .globl  _EnemyRender

; 外部変数宣言
;

    .globl  _enemyBorned
    .globl  _enemyKilled
