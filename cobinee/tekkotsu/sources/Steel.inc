; Steel.inc : 鉄骨
;


; マクロの定義
;

; 鉄骨
STEEL_STATE         =   0x00
STEEL_SPEED         =   0x01
STEEL_X             =   0x02
STEEL_Y             =   0x03
STEEL_SIZE          =   0x04
STEEL_N             =   0x10

; 状態
STEEL_STATE_NULL    =   0x00
STEEL_STATE_FALL    =   0x01

; サイズ
STEEL_WIDTH         =   0x1f
STEEL_HEIGHT        =   0x08

; 外部関数宣言
;

    .globl  _SteelInitialize
    .globl  _SteelReset
    .globl  _SteelUpdate
    .globl  _SteelRender

; 外部変数宣言
;

    .globl  _steel
    .globl  _steelSpeed
    .globl  _steelFall
