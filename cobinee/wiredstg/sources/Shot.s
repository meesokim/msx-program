; Shot.s : ショット
;


; モジュール宣言
;
    .module Shot

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include	"Game.inc"
    .include	"Ship.inc"
    .include	"Shot.inc"

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ショットを初期化する
;
_ShotInitialize::
    
    ; レジスタの保存
    
    ; ショットの初期化
    ld      hl, #(_shot + 0x0000)
    ld      de, #(_shot + 0x0001)
    ld      bc, #(SHOT_SIZE * SHOT_N - 1)
    xor     a
    ld      (hl), a
    ldir
    
    ; タイマの初期化
    xor     a
    ld      (shotTimer), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ショットを生成する
;
_ShotGenerate:
    
    ; レジスタの保存
    push    ix
    
    ; 空きを探す
    ld      ix, #_shot
    ld      de, #SHOT_SIZE
    ld      b, #SHOT_N
10$:
    ld      a, SHOT_STATE(ix)
    or      a
    jr      z, 11$
    ld      de, #SHOT_SIZE
    add     ix, de
    djnz    10$
    jr      19$
    
    ; ショットの生成
11$:
    ld      iy, #_ship
    ld      a, SHIP_POSITION_X(iy)
    sub     #0x0c
    ld      SHOT_POSITION_X(ix), a
    ld      SHOT_RANGE_LEFT(ix), a
    add     a, #0x07
    ld      SHOT_RANGE_RIGHT(ix), a
    ld      a, SHIP_POSITION_Y(iy)
    ld      SHOT_POSITION_Y(ix), a
    ld      SHOT_RANGE_TOP(ix), a
    ld      SHOT_RANGE_BOTTOM(ix), a
    inc     SHOT_STATE(ix)

    ; ＳＥの再生
    ld      hl, #shotSe
    ld      (_soundRequest + 0x0006), hl
    
    ; 生成の完了
19$:

    ; レジスタの復帰
    pop     ix
    
    ; 終了
    ret

; ショットを更新する
;
_ShotUpdate::
    
    ; レジスタの保存
    
    ; ショットの走査
    ld      ix, #_shot
    ld      de, #SHOT_SIZE
    ld      b, #SHOT_N
10$:
    ld      a, SHOT_STATE(ix)
    or      a
    jr      z, 19$
    
    ; 移動
    ld      a, SHOT_POSITION_X(ix)
    sub     #0x08
    jr      c, 18$
    ld      SHOT_POSITION_X(ix), a
    
    ; 範囲の取得
    ld      SHOT_RANGE_LEFT(ix), a
    add     a, #0x07
    ld      SHOT_RANGE_RIGHT(ix), a
    jr      19$
    
    ; 移動の完了
18$:
    xor     a
    ld      SHOT_STATE(ix), a
    
    ; 走査の完了
19$:
    add     ix, de
    djnz    10$
    
    ; タイマの更新
    ld      hl, #shotTimer
    inc     (hl)
    
    ; レジスタの復帰
    
    ; 終了
    ret
    
; ショットを描画する
;
_ShotRender::
    
    ; レジスタの保存
    
    ; ショットの走査
    ld      ix, #_shot
    ld      a, (shotTimer)
    and     #0x03
    add     a, a
    add     a, a
    ld      c, a
    ld      b, #SHOT_N
10$:
    ld      a, SHOT_STATE(ix)
    or      a
    jr      z, 19$

    ; スプライトの描画
    ld      hl, #(_sprite + GAME_SPRITE_SHOT)
    ld      e, c
    ld      d, #0x00
    add     hl, de
    ld      a, #0x04
    add     a, c
    and     #0x0f
    ld      c, a
    ld      a, SHOT_POSITION_Y(ix)
    dec     a
    ld      (hl), a
    inc     hl
    ld      a, SHOT_POSITION_X(ix)
    ld      (hl), a
    inc     hl
    ld      a, #0x38
    ld      (hl), a
    inc     hl
    ld      a, (_appColor)
    ld      (hl), a
;   inc     hl
    
    ; 走査の完了
19$:
    ld      de, #SHOT_SIZE
    add     ix, de
    djnz    10$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; ＳＥ
;
shotSe:
    
    .ascii  "T1V13L0O6CO5F+O6CO5F+CO4F+"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ショット
;
_shot::

    .ds     SHOT_SIZE * SHOT_N

; タイマ
;
shotTimer:

    .ds     1
