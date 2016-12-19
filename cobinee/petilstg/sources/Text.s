; Text.s : テキスト
;


; モジュール宣言
;
    .module Text

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include	"Text.inc"

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; テキストを初期化する
;
_TextInitialize::
    
    ; レジスタの保存
    
    ; テキストの初期化
    ld      hl, #0x0000
    xor     a
    ld      (_textPosition), hl
    ld      (_textString), hl
    ld      (_textLength), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; テキストを更新する
;
_TextUpdate::
    
    ; レジスタの保存
    
    ; レジスタの復帰
    
    ; 終了
    ret

; テキストを描画する
;
_TextRender::

    ; レジスタの保存
    
    ; 文字列の描画
    ld      hl, (_textString)
    ld      a, h
    or      l
    jr      z, 9$
    ld      ix, (_textPosition)
    ld      a, (_textLength)
    inc     a
    jr      z, 0$
    ld      (_textLength), a
0$:
    ld      b, a
1$:
    ld      c, #0x00
2$:
    ld      a, (hl)
    or      a
    jr      z, 9$
    cp      #'\n
    jr      z, 4$
    sub     #0x20
    jr      z, 3$
    ld      0(ix), a
3$:
    inc     ix
    inc     hl
    inc     c
    djnz    2$
    jr      9$
4$:
    ld      a, #0x20
    sub     c
    ld      e, a
    ld      d, #0x00
    add     ix, de
    inc     hl
    jr      1$
9$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 表示位置
;
_textPosition::

    .ds     2

; 文字列
;
_textString::

    .ds     2

; 文字列長
;
_textLength::

    .ds     1
