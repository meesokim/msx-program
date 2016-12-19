; Eshot.s : エネミーショット
;


; モジュール宣言
;
    .module Eshot

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include	"Unit.inc"
    .include    "Enemy.inc"
    .include    "Player.inc"
    .include	"Eshot.inc"
    
; マクロの定義
;

; ユニット
ESHOT_UNIT_PARENT_L     =   0x10
ESHOT_UNIT_PARENT_H     =   0x11
ESHOT_UNIT_X_SPEED      =   0x14
ESHOT_UNIT_X_LIMIT      =   0x15
ESHOT_UNIT_Y_SPEED      =   0x18
ESHOT_UNIT_Y_LIMIT      =   0x19
ESHOT_UNIT_Z_SPEED      =   0x1c
ESHOT_UNIT_Z_LIMIT      =   0x1d


; CODE 領域
;
    .area   _CODE

; エネミーショットを初期化する
;
_EshotInitialize::
    
    ; レジスタの保存
    
    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーショットをリセットする
;
_EshotReset::
    
    ; レジスタの保存
    
    ; ユニットの初期化
    ld      de, #UNIT_SIZE
    ld      hl, #(_unit + UNIT_ENEMY * UNIT_SIZE)
    ld      ix, #(_unit + UNIT_ESHOT * UNIT_SIZE)
    ld      b, #UNIT_ESHOT_N
0$:
    ld      ESHOT_UNIT_PARENT_L(ix), l
    ld      ESHOT_UNIT_PARENT_H(ix), h
    add     hl, de
    add     ix, de
    djnz    0$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーショットを更新する
;
_EshotUpdate::
    
    ; レジスタの保存
    
    ; ショットの更新
    ld      ix, #(_unit + UNIT_ESHOT * UNIT_SIZE)
    ld      iy, #(_unit + UNIT_ENEMY * UNIT_SIZE)
    ld      b, #UNIT_ESHOT_N
0$:
    push    bc
    ld      a, UNIT_TYPE(ix)
    or      a
    jr      nz, 1$
    call    EshotFire
    jr      3$
1$:
    ld      a, UNIT_DIV_Z(ix)
    or      a
    jr      z, 2$
    call    EshotMove
    jr      3$
2$:
    call    EshotHit
3$:
    ld      de, #UNIT_SIZE
    add     ix, de
    add     iy, de
    pop     bc
    djnz    0$
    
    ; レジスタの復帰
    
    ; 終了
    ret
    
; エネミーショットを描画する
;
_EshotRender::
    
    ; レジスタの保存
    
    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーショットを撃つ
;
EshotFire:
    
    ; レジスタの保存
    
    ; ショットを撃つ
    ld      a, UNIT_TYPE(iy)
    or      a
    jp      z, 9$
    ld      a, ENEMY_UNIT_HP(iy)
    or      a
    jp      z, 9$
    ld      a, ENEMY_UNIT_DAMAGE(iy)
    or      a
    jr      nz, 9$
    ld      a, ENEMY_UNIT_ATTACK(iy)
    or      a
    jr      z, 9$
    
    ; ショットの作成
    ld      a, #UNIT_TYPE_ESHOT
    ld      UNIT_TYPE(ix), a
    xor     a
    ld      UNIT_COLOR(ix), a
    ld      c, UNIT_X_POSITION_L(iy)
    ld      b, UNIT_X_POSITION_H(iy)
    ld      UNIT_X_POSITION_L(ix), c
    ld      UNIT_X_POSITION_H(ix), b
    ld      l, UNIT_Y_POSITION_L(iy)
    ld      h, UNIT_Y_POSITION_H(iy)
    ld      UNIT_Y_POSITION_L(ix), l
    ld      UNIT_Y_POSITION_H(ix), h
    ld      l, UNIT_Z_POSITION_L(iy)
    ld      h, UNIT_Z_POSITION_H(iy)
    ld      de, #0x0080
    add     hl, de
    ld      UNIT_Z_POSITION_L(ix), l
    ld      UNIT_Z_POSITION_H(ix), h
    ld      a, #0x10                    ; default x speed
    ld      ESHOT_UNIT_X_LIMIT(ix), a
    ld      a, #0x0c                    ; default y speed
    ld      ESHOT_UNIT_Y_LIMIT(ix), a
    xor     a
    ld      ESHOT_UNIT_X_SPEED(ix), a
    ld      ESHOT_UNIT_Y_SPEED(ix), a
    ld      a, #0x40                    ; default z speed
    ld      ESHOT_UNIT_Z_SPEED(ix), a
    ld      ESHOT_UNIT_Z_LIMIT(ix), a
9$:
    
    ; レジスタの復帰
    
    ; 終了
    ret
    

; エネミーショットを移動する
;
EshotMove:
    
    ; レジスタの保存
    
    ; Ｘの移動
    ld      e, UNIT_X_POSITION_H(ix)
    ld      a, UNIT_X_POSITION_L(ix)
    or      e
    jr      z, 01$
    ld      a, e
    or      a
    jp      p, 00$
    ld      a, ESHOT_UNIT_X_SPEED(ix)
    cp      ESHOT_UNIT_X_LIMIT(ix)
    jr      z, 01$
    add     a, #0x02
    ld      ESHOT_UNIT_X_SPEED(ix), a
    jr      01$
00$:
    ld      a, ESHOT_UNIT_X_LIMIT(ix)
    neg
    ld      e, a
    ld      a, ESHOT_UNIT_X_SPEED(ix)
    cp      e
    jr      z, 01$
    sub     #0x02
    ld      ESHOT_UNIT_X_SPEED(ix), a
01$:
    ld      e, ESHOT_UNIT_X_SPEED(ix)
    ld      d, e
    xor     a
    rl      d
    sbc     #0x00
    ld      d, a
    ld      l, UNIT_X_POSITION_L(ix)
    ld      h, UNIT_X_POSITION_H(ix)
    add     hl, de
    ld      UNIT_X_POSITION_L(ix), l
    ld      UNIT_X_POSITION_H(ix), h
    
    ; Ｙの移動
    ld      e, UNIT_Y_POSITION_H(ix)
    ld      a, UNIT_Y_POSITION_L(ix)
    or      e
    jr      z, 11$
    ld      a, e
    or      a
    jp      p, 10$
    ld      a, ESHOT_UNIT_Y_SPEED(ix)
    cp      ESHOT_UNIT_Y_LIMIT(ix)
    jr      z, 11$
    add     a, #0x02
    ld      ESHOT_UNIT_Y_SPEED(ix), a
    jr      11$
10$:
    ld      a, ESHOT_UNIT_Y_LIMIT(ix)
    neg
    ld      e, a
    ld      a, ESHOT_UNIT_Y_SPEED(ix)
    cp      e
    jr      z, 11$
    sub     #0x02
    ld      ESHOT_UNIT_Y_SPEED(ix), a
11$:
    ld      e, ESHOT_UNIT_Y_SPEED(ix)
    ld      d, e
    xor     a
    rl      d
    sbc     #0x00
    ld      d, a
    ld      l, UNIT_Y_POSITION_L(ix)
    ld      h, UNIT_Y_POSITION_H(ix)
    add     hl, de
    ld      UNIT_Y_POSITION_L(ix), l
    ld      UNIT_Y_POSITION_H(ix), h
    
    ; Ｚの移動
    ld      e, UNIT_Z_POSITION_H(ix)
    ld      a, UNIT_Z_POSITION_L(ix)
    or      e
    jr      z, 21$
    ld      a, e
    or      a
    jp      p, 20$
    ld      a, ESHOT_UNIT_Z_SPEED(ix)
    cp      ESHOT_UNIT_Z_LIMIT(ix)
    jr      z, 21$
    add     a, #0x02
    ld      ESHOT_UNIT_Z_SPEED(ix), a
    jr      21$
20$:
    ld      a, ESHOT_UNIT_Z_LIMIT(ix)
    neg
    ld      e, a
    ld      a, ESHOT_UNIT_Z_SPEED(ix)
    cp      e
    jr      z, 21$
    sub     #0x02
    ld      ESHOT_UNIT_Z_SPEED(ix), a
21$:
    ld      e, ESHOT_UNIT_Z_SPEED(ix)
    ld      d, e
    xor     a
    rl      d
    sbc     #0x00
    ld      d, a
    ld      l, UNIT_Z_POSITION_L(ix)
    ld      h, UNIT_Z_POSITION_H(ix)
    add     hl, de
    ld      UNIT_Z_POSITION_L(ix), l
    ld      UNIT_Z_POSITION_H(ix), h
    
    ; レジスタの復帰
    
    ; 終了
    ret
    
; エネミーショットのヒットチェックを行う
;
EshotHit:
    
    ; レジスタの保存
    
    ; ヒットチェック
    ld      a, UNIT_Z_POSITION_H(ix)
    or      a
    jp      p, 0$
    cp      #0xff
    jr      c, 9$
0$:
    ld      l, UNIT_X_POSITION_L(ix)
    ld      h, UNIT_X_POSITION_H(ix)
    ld      a, h
    or      a
    jp      p, 1$
    cpl
    ld      h, a
    ld      a, l
    cpl
    ld      l, a
    inc     hl
1$:
    ld      de, #0x0060
    or      a
    sbc     hl, de
    jr      nc, 9$
    ld      l, UNIT_Y_POSITION_L(ix)
    ld      h, UNIT_Y_POSITION_H(ix)
    ld      a, h
    or      a
    jp      p, 2$
    cpl
    ld      h, a
    ld      a, l
    cpl
    ld      l, a
    inc     hl
2$:
    ld      de, #0x0040
    or      a
    sbc     hl, de
    jr      nc, 9$
    
    ; プレイヤーへのダメージ
    ld      hl, #_playerDamage
    ld      a, (hl)
    add     a, ENEMY_UNIT_ATTACK(iy)
    ld      (hl), a
9$:
    xor     a
    ld      ENEMY_UNIT_ATTACK(iy), a
    ld      UNIT_TYPE(ix), a
    
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

