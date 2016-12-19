; crt0.s : ブートコード
;


; モジュール宣言
;
    .module crt0

; 外部関数宣言
;
    .globl  _main


; HEADER 領域（プログラムのエントリポイント）
;
    .area   _HEADER (ABS)
    .org    0x8400

; ブート
;
boot:

    ld      hl, #stackfinal
    ld      sp, hl
    call    gsinit              ; 変数の初期化
    call    _main               ; main() 関数の呼び出し

; 終了
;
terminated:

    ld      hl, #terminatedCode ; NEWSTT
    jp      0x4601

; 終了コード
;
terminatedCode:
    
    .db     0x3a, 0x94, 0x00


; CODE 領域
;
    .area   _CODE


; GSINIT 領域
;
    .area   _GSINIT

; 変数の初期化
;
gsinit:


; GSFINAL 領域
;
    .area   _GSFINAL

; 変数の初期化の完了
;
gsfinal:

    ret


; DATA 領域
;
    .area   _DATA

; DATA 領域の開始
;
data:

; スタック領域
;
stack:

    .ds     0x100

stackfinal:


; DATA 領域の末端
;
    .area   _DATAFINAL

; DATA 領域の終了
;
datafinal:
