; Unit.inc : ユニット
;


; マクロの定義
;

; ユニット
UNIT_ENEMY              =   0x00
UNIT_ENEMY_N            =   0x03
UNIT_ESHOT              =   0x03
UNIT_ESHOT_N            =   0x03
UNIT_PSHOT              =   0x06
UNIT_PSHOT_N            =   0x02
UNIT_N                  =   0x08
UNIT_TYPE               =   0x00
UNIT_COLOR              =   0x01
UNIT_X_POSITION         =   0x02
UNIT_X_POSITION_L       =   0x02
UNIT_X_POSITION_H       =   0x03
UNIT_Y_POSITION         =   0x04
UNIT_Y_POSITION_L       =   0x04
UNIT_Y_POSITION_H       =   0x05
UNIT_Z_POSITION         =   0x06
UNIT_Z_POSITION_L       =   0x06
UNIT_Z_POSITION_H       =   0x07
UNIT_DIV_Z              =   0x08
UNIT_SCALE              =   0x09
UNIT_X_DRAW             =   0x0a
UNIT_Y_DRAW             =   0x0b
UNIT_R                  =   0x0c
UNIT_SIZE               =   0x20

; タイプ
UNIT_TYPE_NULL          =   0x00
UNIT_TYPE_REGIT         =   0x01
UNIT_TYPE_ZGOCKY        =   0x02
UNIT_TYPE_GASTIMA       =   0x03
UNIT_TYPE_MAZRASTER     =   0x04
UNIT_TYPE_YGGDRASILL    =   0x05
UNIT_TYPE_WUXIA         =   0x06
UNIT_TYPE_G_RACH        =   0x07
UNIT_TYPE_KABAKALI      =   0x08
UNIT_TYPE_BOMB_0        =   0x09
UNIT_TYPE_BOMB_1        =   0x0a
UNIT_TYPE_ESHOT         =   0x0b
UNIT_TYPE_PSHOT_LEFT    =   0x0c
UNIT_TYPE_PSHOT_RIGHT   =   0x0d
UNIT_TYPE_N             =   0x0e

; スケール
UNIT_SCALE_N            =   0x04

; 外部関数宣言
;

    .globl  _UnitInitialize
    .globl  _UnitReset
    .globl  _UnitUpdate
    .globl  _UnitRender

; 外部変数宣言
;

    .globl  _unit
