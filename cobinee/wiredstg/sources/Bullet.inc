; Bullet.inc : 弾
;


; マクロの定義
;

; 弾
BULLET_TYPE             =   0x00
BULLET_STATE            =   0x01
BULLET_POSITION_XD      =   0x02
BULLET_POSITION_XI      =   0x03
BULLET_POSITION_YD      =   0x04
BULLET_POSITION_YI      =   0x05
BULLET_SPEED_XD         =   0x06
BULLET_SPEED_XI         =   0x07
BULLET_SPEED_YD         =   0x08
BULLET_SPEED_YI         =   0x09
BULLET_SIZE             =   0x10
BULLET_N                =   0x10

; 種類
BULLET_TYPE_NULL        =   0x00

; 状態
BULLET_STATE_NULL       =   0x00

; 外部関数宣言
;

    .globl  _BulletInitialize
    .globl  _BulletGenerate
    .globl  _BulletUpdate
    .globl  _BulletRender

; 外部変数宣言
;

    .globl  _bullet
    .globl  _bulletN
