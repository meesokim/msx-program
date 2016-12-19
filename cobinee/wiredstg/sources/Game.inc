; Game.inc : ゲーム
;


; マクロの定義
;

; スプライト
GAME_SPRITE_SHIP_0      =   0x00
GAME_SPRITE_BULLET      =   0x10
GAME_SPRITE_SHOT        =   0x50
GAME_SPRITE_SHIP_1      =   0x60

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate

; 外部変数宣言
;

    .globl  _gameScroll
