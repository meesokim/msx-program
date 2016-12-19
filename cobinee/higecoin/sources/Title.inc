; Title.inc : タイトル
;


; マクロの定義
;

; 状態
TITLE_STATE_NULL                =   0x00
TITLE_STATE_LOOP                =   0x10

; スプライト
TITLE_SPRITE_CURSOR             =   0x00

; 外部関数宣言
;

    .globl  _TitleInitialize
    .globl  _TitleUpdate

; 外部変数宣言
;
