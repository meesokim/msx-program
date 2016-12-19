; GameBullet.inc : ゲーム画面／弾
;



; マクロの定義
;

; 弾
;
GAME_BULLET_SIZE            =   18

; パラメータ
;
GAME_BULLET_PARAM_STATE         =   0
GAME_BULLET_PARAM_PHASE         =   1
GAME_BULLET_PARAM_POINT_XD      =   2
GAME_BULLET_PARAM_POINT_XI      =   3
GAME_BULLET_PARAM_POINT_YD      =   4
GAME_BULLET_PARAM_POINT_YI      =   5
GAME_BULLET_PARAM_SPEED_XD      =   6
GAME_BULLET_PARAM_SPEED_XI      =   7
GAME_BULLET_PARAM_SPEED_YD      =   8
GAME_BULLET_PARAM_SPEED_YI      =   9
GAME_BULLET_PARAM_SPRITE_SRC_L  =   10
GAME_BULLET_PARAM_SPRITE_SRC_H  =   11
GAME_BULLET_PARAM_SPRITE_OFFSET =   12
GAME_BULLET_PARAM_SIZE          =   13

; 状態
;
GAME_BULLET_STATE_NULL      =   0
GAME_BULLET_STATE_MOVE      =   1



; 外部関数宣言
;

    .globl  _GameBulletInitialize
    .globl  _GameBulletUpdate
    .globl  _GameBulletEntry



; 外部変数宣言
;

    .globl  _gameBullet
    .globl  _gameBulletEntry



