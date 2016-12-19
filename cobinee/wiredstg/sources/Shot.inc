; Shot.inc : ショット
;


; マクロの定義
;

; ショット
SHOT_TYPE               =   0x00
SHOT_STATE              =   0x01
SHOT_POSITION_X         =   0x02
SHOT_POSITION_Y         =   0x03
SHOT_RANGE_LEFT         =   0x04
SHOT_RANGE_TOP          =   0x05
SHOT_RANGE_RIGHT        =   0x06
SHOT_RANGE_BOTTOM       =   0x07
SHOT_SIZE               =   0x08
SHOT_N                  =   0x04

; 種類
SHOT_TYPE_NULL          =   0x00

; 状態
SHOT_STATE_NULL         =   0x00

; 外部関数宣言
;

    .globl  _ShotInitialize
    .globl  _ShotGenerate
    .globl  _ShotUpdate
    .globl  _ShotRender

; 外部変数宣言
;

    .globl  _shot
