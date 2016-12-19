; GameEnemy.inc : ゲーム画面／敵
;



; マクロの定義
;

; 敵
;
GAME_ENEMY_SIZE             =   9

; パラメータ
;
GAME_ENEMY_PARAM_STATE          =   0
GAME_ENEMY_PARAM_PHASE          =   1
GAME_ENEMY_PARAM_POINT_XD       =   2
GAME_ENEMY_PARAM_POINT_XI       =   3
GAME_ENEMY_PARAM_POINT_YD       =   4
GAME_ENEMY_PARAM_POINT_YI       =   5
GAME_ENEMY_PARAM_POINT_XS       =   6
GAME_ENEMY_PARAM_POINT_YS       =   7
GAME_ENEMY_PARAM_ANGLE          =   8
GAME_ENEMY_PARAM_TURN           =   9
GAME_ENEMY_PARAM_NODAMAGE       =   10
GAME_ENEMY_PARAM_COUNT0         =   11
GAME_ENEMY_PARAM_COUNT1         =   12
GAME_ENEMY_PARAM_ANIMATION      =   13
GAME_ENEMY_PARAM_SPRITE_SRC_L   =   14
GAME_ENEMY_PARAM_SPRITE_SRC_H   =   15
GAME_ENEMY_PARAM_SPRITE_OFFSET  =   16
GAME_ENEMY_PARAM_SIZE           =   17

; 状態
;
GAME_ENEMY_STATE_NULL       =   0
GAME_ENEMY_STATE_IN         =   1
GAME_ENEMY_STATE_STAY       =   2
GAME_ENEMY_STATE_TURN       =   3
GAME_ENEMY_STATE_APPROACH   =   4
GAME_ENEMY_STATE_BOMB       =   5



; 外部関数宣言
;

    .globl  _GameEnemyInitialize
    .globl  _GameEnemyUpdate



; 外部変数宣言
;

    .globl  _gameEnemy



