; Ship.inc : 自機
;


; マクロの定義
;

; 自機
SHIP_TYPE               =   0x00
SHIP_STATE              =   0x01
SHIP_POSITION_X         =   0x02
SHIP_POSITION_Y         =   0x03
SHIP_HP                 =   0x04
SHIP_SPEED              =   0x05
SHIP_ANIMATION          =   0x06
SHIP_TIMER              =   0x07
SHIP_SHOT_L             =   0x08
SHIP_SHOT_H             =   0x09
SHIP_SPRITE_0           =   0x0c
SHIP_SPRITE_1           =   0x0e
SHIP_SIZE               =   0x10

; 種類
SHIP_TYPE_NULL          =   0x00
SHIP_TYPE_VICVIPER      =   0x01
SHIP_TYPE_BOMB          =   0x02

; 状態
SHIP_STATE_NULL         =   0x00

; 外部関数宣言
;

    .globl  _ShipInitialize
    .globl  _ShipUpdate
    .globl  _ShipRender

; 外部変数宣言
;

    .globl  _ship
