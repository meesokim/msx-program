; Ground.inc : 地面
;


; マクロの定義
;

; ジェネレータ
GROUND_GENERATOR_UPPER_STATE    =   0x00
GROUND_GENERATOR_UPPER_HEIGHT   =   0x01
GROUND_GENERATOR_UPPER_LENGTH   =   0x02
GROUND_GENERATOR_LOWER_STATE    =   0x03
GROUND_GENERATOR_LOWER_HEIGHT   =   0x04
GROUND_GENERATOR_LOWER_LENGTH   =   0x05
GROUND_GENERATOR_COUNT          =   0x06
GROUND_GENERATOR_SIZE           =   0x07

; ジェネレータの状態
GROUND_GENERATOR_STATE_NULL     =   0x00
GROUND_GENERATOR_STATE_FLAT     =   0x01
GROUND_GENERATOR_STATE_UP       =   0x02
GROUND_GENERATOR_STATE_DOWN     =   0x03

; 外部関数宣言
;

    .globl  _GroundInitialize
    .globl  _GroundUpdate
    .globl  _GroundRender

; 外部変数宣言
;

    .globl  _ground
    .globl  _groundGenerator
