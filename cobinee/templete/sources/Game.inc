; Game.inc : ゲーム
;


; マクロの定義
;

; 状態
GAME_STATE_NULL                 =   0x00
GAME_STATE_WALK                 =   0x01
GAME_STATE_JUMP                 =   0x02

; スプライト
GAME_SPRITE_NULL                =   0x00

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate

; 外部変数宣言
;
