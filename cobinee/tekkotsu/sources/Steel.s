; Steel.s : 鉄骨
;


; モジュール宣言
;
    .module Steel

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include	"Game.inc"
    .include	"Steel.inc"

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 鉄骨を初期化する
;
_SteelInitialize::
    
    ; レジスタの保存
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 鉄骨をリセットする
;
_SteelReset::
    
    ; レジスタの保存
    
    ; 鉄骨の初期化
    ld      ix, #_steel
    ld      de, #STEEL_SIZE
    xor     a
    ld      b, #STEEL_N
0$:
    ld      STEEL_STATE(ix), a
    add     ix, de
    djnz    0$
    
    ; 速度の初期化
    ld      a, #0x01
    ld      (_steelSpeed), a
    
    ; 落下数の初期化
    xor     a
    ld      (_steelFall), a
    
    ; タイマの初期化
    ld      a, #0x01
    ld      (steelTimer), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 鉄骨を更新する
;
_SteelUpdate::
    
    ; レジスタの保存
    
    ; 鉄骨の生成
    ld      hl, #steelTimer
    dec     (hl)
    jr      nz, 19$
    ld      ix, #_steel
    ld      b, #STEEL_N
10$:
    ld      a, STEEL_STATE(ix)
    or      a
    jr      z, 11$
    ld      de, #STEEL_SIZE
    add     ix, de
    djnz    10$
    jr      19$
11$:
    ld      a, #STEEL_STATE_FALL
    ld      STEEL_STATE(ix), a
    ld      a, (_steelSpeed)
    ld      STEEL_SPEED(ix), a
    call    _SystemGetRandom
    cp      #0xe0
    jr      c, 12$
    sub     #0x70
12$:
    and     #0xf0
    ld      STEEL_X(ix), a
    ld      a, #0x20
    ld      STEEL_Y(ix), a
    ld      a, (_steelSpeed)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      c, a
    ld      a, #0x50
    sub     c
    ld      c, a
    call    _SystemGetRandom
    and     #0x1f
    add     a, c
    ld      (steelTimer), a
    ld      hl, #steelSe
    ld      (_soundRequest + 6), hl
19$:
    
    ; 鉄骨の更新
    ld      hl, #_steelFall
    ld      ix, #_steel
    ld      b, #STEEL_N
20$:
    ld      a, STEEL_STATE(ix)
    or      a
    jr      z, 29$
    ld      a, STEEL_SPEED(ix)
    add     a, STEEL_Y(ix)
    ld      STEEL_Y(ix), a
    cp      #0xc8
    jr      c, 29$
    xor     a
    ld      STEEL_STATE(ix), a
    inc     (hl)
29$:
    ld      de, #STEEL_SIZE
    add     ix, de
    djnz    20$
    
    ; レジスタの復帰
    
    ; 終了
    ret
    
; 鉄骨を描画する
;
_SteelRender::
    
    ; レジスタの保存
    
    ; スプライトの描画
    ld      hl, #(_sprite + GAME_SPRITE_STEEL)
    ld      ix, #_steel
    ld      b, #STEEL_N
0$:
    ld      a, STEEL_STATE(ix)
    or      a
    jr      z, 9$
    ld      de, #steelSprite
    ld      a, (de)
    add     a, STEEL_Y(ix)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    add     a, STEEL_X(ix)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    add     a, STEEL_Y(ix)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    add     a, STEEL_X(ix)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
9$:
    ld      de, #STEEL_SIZE
    add     ix, de
    djnz    0$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; スプライト
;
steelSprite:
    
    .db     0xf0, 0x00, 0x18, 0x0d, 0xf0, 0x10, 0x1c, 0x0d

; ＳＥ
;
steelSe:

    .ascii  "T1L5O4V15CV14CV13CV12CV11CV10CV9CV8CV7CV6CV5CV4CV3CV2CV1C"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 鉄骨
;
_steel::

    .ds     STEEL_SIZE * STEEL_N

; 速度
;
_steelSpeed:

    .ds     1

; 落下数
;
_steelFall:

    .ds     1

; タイマ
;
steelTimer:

    .ds     1

