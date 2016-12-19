; Star.s : 星
;


; モジュール宣言
;
    .module Star

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include	"Game.inc"
    .include	"Star.inc"

; マクロの定義
;

; 星
STAR_POSITION_X     =   0x00
STAR_SPEED          =   0x01
STAR_SIZE           =   0x02
STAR_N              =   0x15


; CODE 領域
;
    .area   _CODE

; 星を初期化する
;
_StarInitialize::
    
    ; レジスタの保存
    
    ; 星の初期化
    ld      ix, #star
    ld      de, #STAR_SIZE
    ld      b, #STAR_N
10$:
    call    _SystemGetRandom
    ld      STAR_POSITION_X(ix), a
    call    _SystemGetRandom
    and     #0x03
    inc     a
    ld      STAR_SPEED(ix), a
    add     ix, de
    djnz    10$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 星を更新する
;
_StarUpdate::
    
    ; レジスタの保存
    
    ; 移動
    ld      ix, #star
    ld      de, #STAR_SIZE
    ld      b, #STAR_N
10$:
    ld      a, STAR_POSITION_X(ix)
    add     a, STAR_SPEED(ix)
    ld      STAR_POSITION_X(ix), a
    jr      nc, 11$
    call    _SystemGetRandom
    and     #0x03
    inc     a
    ld      STAR_SPEED(ix), a
11$:
    add     ix, de
    djnz    10$
    
    ; レジスタの復帰
    
    ; 終了
    ret
    
; 星を描画する
;
_StarRender::
    
    ; レジスタの保存
    
    ; パターンネームの描画
    ld      ix, #star
    ld      hl, #(_appPatternName + 0x0040)
    ld      d, #0x00
    ld      b, #STAR_N
10$:
    ld      a, STAR_POSITION_X(ix)
    ld      c, a
    rra
    rra
    rra
    and     #0x1f
    ld      e, a
    add     hl, de
    ld      a, (hl)
    or      a
    jr      nz, 11$
    ld      a, c
    and     #0x07
    add     #0x58
    ld      (hl), a
11$:
    or      a
    sbc     hl, de
    ld      e, #0x20
    add     hl, de
    ld      e, #STAR_SIZE
    add     ix, de
    djnz    10$
    
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

; 星
;
star::

    .ds     STAR_SIZE * STAR_N

