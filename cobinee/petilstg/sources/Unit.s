; Unit.s : ユニット
;


; モジュール宣言
;
    .module Unit

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include	"Unit.inc"

; マクロの定義
;

; データ
UNIT_DATA_NORMAL_COLOR      =   0x00
UNIT_DATA_DAMAGE_COLOR      =   0x01
UNIT_DATA_R                 =   0x04
UNIT_DATA_SPRITE_NUMBER     =   0x08
UNIT_DATA_SPRITE_COMMAND    =   0x0c
UNIT_DATA_SIZE              =   0x10


; CODE 領域
;
    .area   _CODE

; ユニットを初期化する
;
_UnitInitialize::
    
    ; レジスタの保存
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ユニットをリセットする
;
_UnitReset::
    
    ; レジスタの保存
    
    ; ユニットの初期化
    ld      hl, #(_unit + 0)
    ld      de, #(_unit + 1)
    ld      bc, #(UNIT_N * UNIT_SIZE - 1)
    xor     a
    ld      (hl), a
    ldir
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ユニットを更新する
;
_UnitUpdate::
    
    ; レジスタの保存
    
    ; 移動
    call    UnitMove
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ユニットを描画する
;
_UnitRender::
    
    ; レジスタの保存
    
    ; 投影変換
    call    UnitProjection
    
    ; ソート
    call    UnitSort
    
    ; スプライトコマンドの発行
    call    UnitDraw
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ユニットを移動する
;
UnitMove:

    ; レジスタの保存
    
    ; 移動の開始
    ld      ix, #(_unit + UNIT_ENEMY)
    ld      b, #(UNIT_ENEMY_N + UNIT_ESHOT_N)
0$:
    push    bc
    ld      a, UNIT_TYPE(ix)
    or      a
    jp      z, 9$
    
    ; Ｙ軸回転（←→）
    ld      a, (_gameRotateY)
    or      a
    jp      z, 2$
    jp      m, 1$
    
    ; X = X + (Z >> 5)
    ; Z = Z - (X >> 5)
    ld      l, UNIT_X_POSITION_L(ix)
    ld      h, UNIT_X_POSITION_H(ix)
    ld      a, UNIT_Z_POSITION_L(ix)
    ld      d, UNIT_Z_POSITION_H(ix)
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    ld      e, a
    add     hl, de
    ld      b, h
    ld      c, l
    ld      l, UNIT_Z_POSITION_L(ix)
    ld      h, UNIT_Z_POSITION_H(ix)
    ld      a, UNIT_X_POSITION_L(ix)
    ld      d, UNIT_X_POSITION_H(ix)
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    ld      e, a
    or      a
    sbc     hl, de
    ld      UNIT_X_POSITION_L(ix), c
    ld      UNIT_X_POSITION_H(ix), b
    ld      UNIT_Z_POSITION_L(ix), l
    ld      UNIT_Z_POSITION_H(ix), h
    jp      4$
    
    ; X = X - (Z >> 5)
    ; Z = Z + (X >> 5)
1$:
    ld      l, UNIT_X_POSITION_L(ix)
    ld      h, UNIT_X_POSITION_H(ix)
    ld      a, UNIT_Z_POSITION_L(ix)
    ld      d, UNIT_Z_POSITION_H(ix)
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    ld      e, a
    or      a
    sbc     hl, de
    ld      b, h
    ld      c, l
    ld      l, UNIT_Z_POSITION_L(ix)
    ld      h, UNIT_Z_POSITION_H(ix)
    ld      a, UNIT_X_POSITION_L(ix)
    ld      d, UNIT_X_POSITION_H(ix)
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    ld      e, a
    add     hl, de
    ld      UNIT_X_POSITION_L(ix), c
    ld      UNIT_X_POSITION_H(ix), b
    ld      UNIT_Z_POSITION_L(ix), l
    ld      UNIT_Z_POSITION_H(ix), h
    jp      4$
    
    ; Ｘ軸回転（↑↓）
2$:
    ld      a, (_gameRotateX)
    or      a
    jp      z, 4$
    jp      m, 3$
    
    ; Y = Y + (Z >> 5)
    ; Z = Z - (Y >> 5)
    ld      l, UNIT_Y_POSITION_L(ix)
    ld      h, UNIT_Y_POSITION_H(ix)
    ld      a, UNIT_Z_POSITION_L(ix)
    ld      d, UNIT_Z_POSITION_H(ix)
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    ld      e, a
    add     hl, de
    ld      b, h
    ld      c, l
    ld      l, UNIT_Z_POSITION_L(ix)
    ld      h, UNIT_Z_POSITION_H(ix)
    ld      a, UNIT_Y_POSITION_L(ix)
    ld      d, UNIT_Y_POSITION_H(ix)
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    ld      e, a
    or      a
    sbc     hl, de
    ld      UNIT_Y_POSITION_L(ix), c
    ld      UNIT_Y_POSITION_H(ix), b
    ld      UNIT_Z_POSITION_L(ix), l
    ld      UNIT_Z_POSITION_H(ix), h
    jr      4$
    
    ; Y = Y - (Z >> 5)
    ; Z = Z + (Y >> 5)
3$:
    ld      l, UNIT_Y_POSITION_L(ix)
    ld      h, UNIT_Y_POSITION_H(ix)
    ld      a, UNIT_Z_POSITION_L(ix)
    ld      d, UNIT_Z_POSITION_H(ix)
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    ld      e, a
    or      a
    sbc     hl, de
    ld      b, h
    ld      c, l
    ld      l, UNIT_Z_POSITION_L(ix)
    ld      h, UNIT_Z_POSITION_H(ix)
    ld      a, UNIT_Y_POSITION_L(ix)
    ld      d, UNIT_Y_POSITION_H(ix)
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    sra     d
    rra
    ld      e, a
    add     hl, de
    ld      UNIT_Y_POSITION_L(ix), c
    ld      UNIT_Y_POSITION_H(ix), b
    ld      UNIT_Z_POSITION_L(ix), l
    ld      UNIT_Z_POSITION_H(ix), h
    
    ; 前進移動
4$:
    ld      a, (_gameMoveZ)
    srl     a
    ld      e, a
    ld      d, #0x00
    ld      l, UNIT_Z_POSITION_L(ix)
    ld      h, UNIT_Z_POSITION_H(ix)
    add     hl, de
    ld      UNIT_Z_POSITION_L(ix), l
    ld      UNIT_Z_POSITION_H(ix), h
9$:
    ld      de, #UNIT_SIZE
    add     ix, de
    pop     bc
    dec     b
    jp      nz, 0$
    
    ; レジスタの復帰
    
    ; 終了
    ret
    
; ユニットの投影変換を行う
;
UnitProjection:

    ; レジスタの保存
    
    ; 
    ld      ix, #_unit
    ld      b, #(UNIT_ENEMY_N + UNIT_ESHOT_N)
00$:
    push    bc
    xor     a
    ld      UNIT_DIV_Z(ix), a
    ld      a, UNIT_TYPE(ix)
    or      a
    jp      z, 90$
    
    ; hl = -Z
    ld      a, UNIT_Z_POSITION_L(ix)
    cpl
    ld      l, a
    ld      a, UNIT_Z_POSITION_H(ix)
    cpl
    ld      h, a
    inc     hl
    
    ; Ｚ座標でのクリッピング
    ld      a, h
    cp      #0x01
    jp      c, 90$
    cp      #0x10
    jp      nc, 90$
    
    ; hl = Z >> 1
    ld      c, l
    ld      b, h
    sra     h
    rr      l
    
    ; ＸＹ座標でのクリッピング
    ex      de, hl
    ld      l, UNIT_X_POSITION_L(ix)
    ld      h, UNIT_X_POSITION_H(ix)
    add     hl, de
    or      a
    sbc     hl, bc
    jp      nc, 90$
    ld      l, UNIT_Y_POSITION_L(ix)
    ld      h, UNIT_Y_POSITION_H(ix)
    add     hl, de
    or      a
    sbc     hl, bc
    jp      nc, 90$
    ex      de, hl
    
    ; bc = X
    ; de = Y
    ; hl = Z >> (3 + 1)
    ld      c, UNIT_X_POSITION_L(ix)
    ld      b, UNIT_X_POSITION_H(ix)
    ld      e, UNIT_Y_POSITION_L(ix)
    ld      d, UNIT_Y_POSITION_H(ix)
    sra     h
    rr      l
    sra     h
    rr      l
    sra     h
    rr      l
    
    ; Ｚ除数の取得
    ld      a, l
    cp      #0x20
    jr      c, 20$
    sra     b
    rr      c
    sra     d
    rr      e
    cp      #0x40
    jr      c, 20$
    sra     b
    rr      c
    sra     d
    rr      e
    cp      #0x80
    jr      c, 20$
    sra     b
    rr      c
    sra     d
    rr      e
20$:
    ex      de, hl
    ld      iy, #unitDivZ
    add     iy, de
    ex      de, hl
    
    ; 座標の投影
    push    hl
    ld      hl, #0x0000
    ld      a, 0(iy)
    jr      31$
30$:
    sla     c
    rl      b
31$:
    srl     a
    jr      nc, 30$
    add     hl, bc
    jr      nz, 30$
    ld      b, h
    ld      hl, #0x0000
    ld      a, 0(iy)
    jr      33$
32$:
    sla     e
    rl      d
33$:
    srl     a
    jr      nc, 32$
    add     hl, de
    jr      nz, 32$
    ld      a, h
    pop     hl
    
    ; Ｙ座標でのクリッピング
    cp      #-0x50
    jr      nc, 50$
    cp      #0x30
    jr      nc, 90$
50$:
    ld      UNIT_X_DRAW(ix), b
    ld      UNIT_Y_DRAW(ix), a
    ld      UNIT_DIV_Z(ix), l
    srl     l
    srl     l
    srl     l
    srl     l
    ld      de, #unitScale
    add     hl, de
    ld      a, (hl)
    ld      UNIT_SCALE(ix), a
    
90$:
    ld      de, #UNIT_SIZE
    add     ix, de
    pop     bc
    dec     b
    jp      nz, 00$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ユニットをソートする
;
UnitSort::
    
    ; レジスタの保存
    
    ; ソート順の初期化
    ld      ix, #unitOrder
    ld      hl, #_unit
    ld      de, #UNIT_SIZE
    ld      b, #UNIT_N
00$:
    ld      0x00(ix), l
    ld      0x01(ix), h
    add     hl, de
    inc     ix
    inc     ix
    djnz    00$
    
    ; ソートの開始
    ld      ix, #(unitOrder + 0x0002)
    ld      iy, #(unitOrder + 0x0000)
    ld      b, #0x01
10$:
    push    bc
    push    iy
    ld      l, 0x00(ix)
    ld      h, 0x01(ix)
    push    hl
    ld      de, #UNIT_DIV_Z
    add     hl, de
    ld      c, (hl)
    dec     b
11$:
    jp      m, 12$
    ld      l, 0x00(iy)
    ld      h, 0x01(iy)
    ld      de, #UNIT_DIV_Z
    add     hl, de
    ld      a, (hl)
    cp      c
    jr      z, 12$
    jr      c, 12$
    ld      l, 0x00(iy)
    ld      h, 0x01(iy)
    ld      0x02(iy), l
    ld      0x03(iy), h
    dec     iy
    dec     iy
    dec     b
    jr      11$
12$:
    pop     hl
    inc     iy
    inc     iy
    ld      0x00(iy), l
    ld      0x01(iy), h
    pop     iy
    inc     iy
    inc     iy
    inc     ix
    inc     ix
    pop     bc
    inc     b
    ld      a, b
    cp      #UNIT_N
    jr      nz, 10$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ユニットのスプライトコマンドを発行する
;
UnitDraw:
    
    ; レジスタの保存
    
    ; 描画の開始
    ld      hl, #unitOrder
    ld      iy, #(_sprite + 0x0020)
    ld      b, #UNIT_N
00$:
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    push    de
    pop     ix              ; ix = _unit[]
    ld      a, UNIT_DIV_Z(ix)
    or      a
    jr      z, 90$
    
    ; 描画するユニット
    push    hl
    push    bc
    ld      hl, #unitData
    ld      a, UNIT_TYPE(ix)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      c, a
    ld      b, #0x00
    add     hl, bc          ; hl = unitData[]
    ld      c, UNIT_COLOR(ix)
    add     hl, bc
    ld      d, (hl)         ; d = color
    or      a
    sbc     hl, bc
    ld      a, UNIT_SCALE(ix)
    add     a, #UNIT_DATA_R
    ld      c, a
    add     hl, bc
    ld      a, (hl)         ; a = r
    ld      UNIT_R(ix), a
    ld      c, #UNIT_SCALE_N
    add     hl, bc
    ld      e, (hl)         ; e = sprite number
    ld      c, #UNIT_SCALE_N
    add     hl, bc
    ld      c, (hl)
    ld      hl, #unitSpriteCommand
    add     hl, bc          ; hl = unitSpriteCommand[]
    ld      b, (hl)
    inc     hl
10$:
    push    bc
    ld      a, (hl)
    inc     hl
    add     a, #0x50
    add     a, 0x0b(ix)
    cp      #0x80
    jr      c, 11$
    cp      #0xe8
    jr      nc, 11$
    ld      a, #0xc0
11$:
    ld      c, a
    ld      a, 0x0a(ix)
    add     a, #0x80
    cp      #0x80
    jr      nc, 12$
    add     a, (hl)
    add     a, #0x20
    set     #7, d
    jr      13$
12$:
    add     a, (hl)
    cp      #0x20
    jr      nc, 13$
    ld      c, #0xc0
13$:
    inc     hl
    ld      b, a
    ld      a, (hl)
    inc     hl
    add     a, e
    inc     hl
    ld      VDP_SPRITE_Y(iy), c
    ld      VDP_SPRITE_X(iy), b
    ld      VDP_SPRITE_PATTERN(iy), a
    ld      VDP_SPRITE_COLOR(iy), d
    res     #7, d
    inc     iy
    inc     iy
    inc     iy
    inc     iy
    pop     bc
    djnz    10$
    pop     bc
    pop     hl
    
    ; 次のユニットへ
90$:
    dec     b
    jp      nz, 00$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; データ
;
unitData:
    
    .db       0,   0,   0,   0,   0,   0,   0,   0      ;  0 : ---
    .db       0,   0,   0,   0,   0,   0,   0,   0
    .db       7,   8,   0,   0,  16,  12,   8,   6      ;  1 : REGIT
    .db      64,  72,  80, 112,  15,  15,   0,   0
    .db       3,   8,   0,   0,  16,  12,   8,   6      ;  2 : Z'GOCKY
    .db     148, 212, 156, 188,  15,  15,   0,   0
    .db      11,   8,   0,   0,  16,  12,   8,   6      ;  3 : GASTIMA
    .db     128, 136, 144, 176,  15,  15,   0,   0
    .db       9,   8,   0,   0,  16,  12,   8,   6      ;  4 : MAZRASTER
    .db     192, 200, 208, 240,  15,  15,   0,   0
    .db       6,  11,   0,   0,  32,  24,  16,   8      ;  5 : YGGDRASILL
    .db      64, 148,  76, 144,  69,  32,  15,   0
    .db      14,   8,   0,   0,  16,  12,   8,   6      ;  6 : WUXIA
    .db     192, 200, 208, 240,  15,  15,   0,   0
    .db      13,   8,   0,   0,  24,  16,  12,   8      ;  7 : G-RACH
    .db     148, 128, 136, 144,  32,  15,  15,   0
    .db       4,   8,   0,   0,  16,  12,   8,   6      ;  8 : KABAKALI
    .db      64,  72,  80, 112,  15,  15,   0,   0
    .db       8,   8,   0,   0,  16,  16,   8,   8      ;  9 : bomb 0
    .db      24,  24,  40,  40,  15,  15,   0,   0
    .db       9,   9,   0,   0,  16,  16,   8,   8      ; 10 : bomb 1
    .db      88,  88,  44,  44,  15,  15,   0,   0
    .db      10,   8,   0,   0,   8,   6,   4,   2      ; 11 : enemy's shot
    .db      16,  20,  48,  52,   0,   0,   0,   0
    .db      11,  11,   0,   0,   0,   0,   0,   0      ; 12 : player's shot left
    .db      32,  32,  32,  32,   5,   5,   5,   5
    .db      11,  11,   0,   0,   0,   0,   0,   0      ; 13 : player's shot right
    .db      36,  36,  36,  36,  10,  10,  10,  10

; Ｚ除数
;
unitDivZ:

    .db     0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db     0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db     0xff, 0xef, 0xe2, 0xd6, 0xcb, 0xc2, 0xb9, 0xb1
    .db     0xa9, 0xa2, 0x9c, 0x96, 0x91, 0x8c, 0x87, 0x83
    .db     0xff, 0xf7, 0xef, 0xe9, 0xe2, 0xdc, 0xd6, 0xd1
    .db     0xcb, 0xc6, 0xc2, 0xbd, 0xb9, 0xb5, 0xb1, 0xad
    .db     0xa9, 0xa6, 0xa2, 0x9f, 0x9c, 0x99, 0x96, 0x93
    .db     0x91, 0x8e, 0x8c, 0x89, 0x87, 0x85, 0x83, 0x81
    .db     0xff, 0xfb, 0xf7, 0xf3, 0xef, 0xec, 0xe9, 0xe5
    .db     0xe2, 0xdf, 0xdc, 0xd9, 0xd6, 0xd3, 0xd1, 0xce
    .db     0xcb, 0xc9, 0xc6, 0xc4, 0xc2, 0xbf, 0xbd, 0xbb
    .db     0xb9, 0xb7, 0xb5, 0xb3, 0xb1, 0xaf, 0xad, 0xab
    .db     0xa9, 0xa7, 0xa6, 0xa4, 0xa2, 0xa1, 0x9f, 0x9e
    .db     0x9c, 0x9b, 0x99, 0x98, 0x96, 0x95, 0x93, 0x92
    .db     0x91, 0x8f, 0x8e, 0x8d, 0x8c, 0x8b, 0x89, 0x88
    .db     0x87, 0x86, 0x85, 0x84, 0x83, 0x82, 0x81, 0x80
    .db     0xff, 0xfd, 0xfb, 0xf9, 0xf7, 0xf5, 0xf3, 0xf1
    .db     0xef, 0xee, 0xec, 0xea, 0xe9, 0xe7, 0xe5, 0xe4
    .db     0xe2, 0xe0, 0xdf, 0xdd, 0xdc, 0xda, 0xd9, 0xd8
    .db     0xd6, 0xd5, 0xd3, 0xd2, 0xd1, 0xcf, 0xce, 0xcd
    .db     0xcb, 0xca, 0xc9, 0xc8, 0xc6, 0xc5, 0xc4, 0xc3
    .db     0xc2, 0xc0, 0xbf, 0xbe, 0xbd, 0xbc, 0xbb, 0xba
    .db     0xb9, 0xb8, 0xb7, 0xb6, 0xb5, 0xb4, 0xb3, 0xb2
    .db     0xb1, 0xb0, 0xaf, 0xae, 0xad, 0xac, 0xab, 0xaa
    .db     0xa9, 0xa8, 0xa7, 0xa7, 0xa6, 0xa5, 0xa4, 0xa3
    .db     0xa2, 0xa2, 0xa1, 0xa0, 0x9f, 0x9e, 0x9e, 0x9d
    .db     0x9c, 0x9b, 0x9b, 0x9a, 0x99, 0x98, 0x98, 0x97
    .db     0x96, 0x96, 0x95, 0x94, 0x93, 0x93, 0x92, 0x91
    .db     0x91, 0x90, 0x8f, 0x8f, 0x8e, 0x8e, 0x8d, 0x8c
    .db     0x8c, 0x8b, 0x8b, 0x8a, 0x89, 0x89, 0x88, 0x88
    .db     0x87, 0x86, 0x86, 0x85, 0x85, 0x84, 0x84, 0x83
    .db     0x83, 0x82, 0x82, 0x81, 0x81, 0x80, 0x80, 0x7f

; スケール
;
unitScale:

;   .db     0, 0, 0, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3
;   .db     0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3
    .db     0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3

; スプライトコマンド
;
unitSpriteCommand:

    .db     1                   ; [ 0] : 16x16
    .db      -8,  -8,  0,  0
    .db     1                   ; [ 5] : 16x16
    .db       0, -15,  0,  0
    .db     1                   ; [10] : 16x16
    .db       0,   0,  0,  0
    .db     4                   ; [15] : 32x32
    .db     -16, -16,  0,  0
    .db     -16,   0,  4,  0
    .db       0, -16, 32,  0
    .db       0,   0, 36,  0
    .db     9                   ; [32] : 48x48
    .db     -24, -24,  0,  0
    .db     -24,  -8,  4,  0
    .db     -24,   8,  8,  0
    .db      -8, -24, 32,  0
    .db      -8,  -8, 36,  0
    .db      -8,   8, 40,  0
    .db       8, -24, 64,  0
    .db       8,  -8, 68,  0
    .db       8,   8, 72,  0
    .db     12                  ; [69] : 64x64
;   .db     -32, -36,  0,  0
    .db     -32, -20,  4,  0
    .db     -32,  -4,  8,  0
;   .db     -32,  12, 12,  0
;   .db     -16, -36, 32,  0
    .db     -16, -20, 36,  0
    .db     -16,  -4, 40,  0
;   .db     -16,  12, 44,  0
    .db       0, -36, 64,  0
    .db       0, -20, 68,  0
    .db       0,  -4, 72,  0
    .db       0,  12, 76,  0
    .db      16, -36, 96,  0
    .db      16, -20,100,  0
    .db      16,  -4,104,  0
    .db      16,  12,108,  0


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ユニット
;
_unit::

    .ds     UNIT_N * UNIT_SIZE
    
; ソート順
;
unitOrder:

    .ds     UNIT_N * 2
    