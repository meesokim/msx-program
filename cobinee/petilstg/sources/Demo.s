; Demo.s : デモ
;


; モジュール宣言
;
    .module Demo

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include	"Text.inc"
    .include	"Demo.inc"

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; デモを初期化する
;
_DemoInitialize::
    
    ; レジスタの保存
    
    ; デモの初期化
    xor     a
    ld      (_demoState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; デモをリセットする
;
_DemoReset::
    
    ; レジスタの保存
    
    ; デモの初期化
    ld      a, #0x01
    ld      (_demoState), a
    ld      hl, #0x0000
    ld      (demoTimer), hl
    ld      a, #0xff
    ld      (demoLogo), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; デモを更新する
;
_DemoUpdate::
    
    ; レジスタの保存
    
    ; 状態の取得
    ld      a, (_demoState)
    
    ; １：ロゴの更新
    cp      #0x01
    jr      nz, 20$
    ld      hl, #demoLogo
    ld      a, (hl)
    cp      #0x40
    ccf
    sbc     #0x00
    ld      (hl), a
    cp      #0x41
    jp      nc, 90$
    ld      hl, (demoTimer)
    inc     hl
    ld      (demoTimer), hl
    ld      a, h
    cp      #0x02
    jp      c, 90$
    ld      hl, #0x0000
    ld      (demoTimer), hl
    ld      a, #0x02
    ld      (_demoState), a
    
    ; ２：メカニック０の更新
20$:
    cp      #0x02
    jr      nz, 30$
    ld      hl, (demoTimer)
    ld      a, h
    or      l
    jr      nz, 21$
    ld      hl, #(_gamePatternName + (0x00 << 5) + 0x0c)
    ld      (_textPosition), hl
    ld      hl, #demoStringMechanic0
    ld      (_textString), hl
    xor     a
    ld      (_textLength), a
21$:
    ld      hl, (demoTimer)
    inc     hl
    ld      (demoTimer), hl
    ld      a, h
    cp      #0x02
    jr      c, 90$
    ld      hl, #0x0000
    ld      (demoTimer), hl
    ld      a, #0x03
    ld      (_demoState), a

    ; ３：メカニック１の更新
30$:
    cp      #0x03
    jr      nz, 40$
    ld      hl, (demoTimer)
    ld      a, h
    or      l
    jr      nz, 31$
    ld      hl, #(_gamePatternName + (0x06 << 5) + 0x0c)
    ld      (_textPosition), hl
    ld      hl, #demoStringMechanic1
    ld      (_textString), hl
    xor     a
    ld      (_textLength), a
31$:
    ld      hl, (demoTimer)
    inc     hl
    ld      (demoTimer), hl
    ld      a, h
    cp      #0x02
    jr      c, 90$
    ld      hl, #0x0000
    ld      (demoTimer), hl
    ld      a, #0x04
    ld      (_demoState), a

    ; ４：メカニック２の更新
40$:
    cp      #0x04
    jr      nz, 90$
    ld      hl, (demoTimer)
    ld      a, h
    or      l
    jr      nz, 41$
    ld      hl, #(_gamePatternName + (0x02 << 5) + 0x0c)
    ld      (_textPosition), hl
    ld      hl, #demoStringMechanic2
    ld      (_textString), hl
    xor     a
    ld      (_textLength), a
41$:
    ld      hl, (demoTimer)
    inc     hl
    ld      (demoTimer), hl
    ld      a, h
    cp      #0x02
    jr      c, 90$
    ld      hl, #0x0000
    ld      (demoTimer), hl
    xor     a
    ld      (_demoState), a

    ; デモの完了
90$:

    ; レジスタの復帰
    
    ; 終了
    ret

; デモを描画する
;
_DemoRender::

    ; レジスタの保存
    
    ; 状態の取得
    ld      a, (_demoState)
    
    ; １：ロゴの表示
    cp      #0x01
    jr      nz, 20$
    ld      a, (demoLogo)
    and     #0xf0
    ld      e, a
    ld      d, #0x00
    sla     e
    rl      d
    ld      hl, #_gamePatternName
    add     hl, de
    ld      de, #demoLogoPatternName
    ex      de, hl
    ld      bc, #0x20
    ldir
    add     a, #0x10
    jr      c, 10$
    ld      bc, #0x20
    ldir
    add     a, #0x10
    jr      c, 10$
    ld      bc, #0x20
    ldir
10$:
    ld      a, (demoTimer + 0)
    and     #0x10
    jr      z, 11$
    ld      hl, #demoPressPatternName
    ld      de, #(_gamePatternName + 0x1a8)
    ld      bc, #0x0f
    ldir
11$:
    jr      90$
    
    ; ２：メカニック０の表示
20$:
    cp      #0x02
    jr      nz, 30$
    ld      hl, #demoSpriteMechanic0
    ld      de, #(_sprite + 0x0020)
    ld      bc, #0x0040
    ldir
    ld      a, #(APP_SPRITE_GENERATOR_TABLE_0 >> 11)
    ld      (_videoRegister + VDP_R6), a
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    jr      90$

    ; ３：メカニック１の表示
30$:
    cp      #0x03
    jr      nz, 40$
    ld      hl, #demoSpriteMechanic1
    ld      de, #(_sprite + 0x0020)
    ld      bc, #0x0040
    ldir
    ld      a, #(APP_SPRITE_GENERATOR_TABLE_1 >> 11)
    ld      (_videoRegister + VDP_R6), a
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    jr      90$

    ; ４：メカニック２の表示
40$:
    cp      #0x04
    jr      nz, 90$
    ld      hl, #demoSpriteMechanic2
    ld      de, #(_sprite + 0x0020)
    ld      bc, #0x0044
    ldir
    ld      a, #(APP_SPRITE_GENERATOR_TABLE_2 >> 11)
    ld      (_videoRegister + VDP_R6), a
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    jr      90$

    ; 描画の完了
90$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; パターンネーム
;
demoLogoPatternName:

    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9c, 0x9d, 0x9e, 0x9f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a
    .db     0x9b, 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xac, 0xad, 0xae, 0xaf, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa
    .db     0xab, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xbc, 0xbd, 0xbe, 0xbf, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

demoPressPatternName:

    .db     0x30, 0x32, 0x25, 0x33, 0x33, 0x00, 0x33, 0x30, 0x21, 0x23, 0x25, 0x00, 0x22, 0x21, 0x32

; スプライト
;
demoSpriteMechanic0:

    .db     0xfc, 0x20, 0x40, 0x07, 0xfc, 0x30, 0x44, 0x07, 0x0c, 0x20, 0x60, 0x07, 0x0c, 0x30, 0x64, 0x07
    .db     0x1c, 0x20, 0x94, 0x03, 0x1c, 0x30, 0x98, 0x03, 0x2c, 0x20, 0xb4, 0x03, 0x2c, 0x30, 0xb8, 0x03
    .db     0x3c, 0x20, 0x80, 0x0b, 0x3c, 0x30, 0x84, 0x0b, 0x4c, 0x20, 0xa0, 0x0b, 0x4c, 0x30, 0xa4, 0x0b
    .db     0x5c, 0x20, 0xc0, 0x09, 0x5c, 0x30, 0xc4, 0x09, 0x6c, 0x20, 0xe0, 0x09, 0x6c, 0x30, 0xe4, 0x09

demoSpriteMechanic1:

    .db     0x20, 0x10, 0x40, 0x06, 0x20, 0x20, 0x44, 0x06, 0x20, 0x30, 0x48, 0x06, 0x20, 0x40, 0x40, 0x06
    .db     0x30, 0x10, 0x60, 0x06, 0x30, 0x20, 0x64, 0x06, 0x30, 0x30, 0x68, 0x06, 0x30, 0x40, 0x40, 0x06
    .db     0x40, 0x10, 0x80, 0x06, 0x40, 0x20, 0x84, 0x06, 0x40, 0x30, 0x88, 0x06, 0x40, 0x40, 0x8c, 0x06
    .db     0x50, 0x10, 0xa0, 0x06, 0x50, 0x20, 0xa4, 0x06, 0x50, 0x30, 0xa8, 0x06, 0x50, 0x40, 0xac, 0x06

demoSpriteMechanic2:

    .db     0x0c, 0x20, 0xc0, 0x0e, 0x0c, 0x30, 0xc4, 0x0e, 0x1c, 0x20, 0xe0, 0x0e, 0x1c, 0x30, 0xe4, 0x0e
    .db     0x2c, 0x18, 0x94, 0x0d, 0x2c, 0x28, 0x98, 0x0d, 0x2c, 0x38, 0x9c, 0x0d
    .db     0x3c, 0x18, 0xb4, 0x0d, 0x3c, 0x28, 0xb8, 0x0d, 0x3c, 0x38, 0xbc, 0x0d
    .db     0x4c, 0x18, 0xd4, 0x0d, 0x4c, 0x28, 0xd8, 0x0d, 0x4c, 0x38, 0xdc, 0x0d
    .db     0x5c, 0x20, 0x40, 0x04, 0x5c, 0x30, 0x44, 0x04, 0x6c, 0x20, 0x60, 0x04, 0x6c, 0x30, 0x64, 0x04

; 文字列
;
demoStringMechanic0:

    .ascii  "RE G-IT\n"
    .ascii  "G-IT LABORATORY\n"
    .ascii  "\n"
    .ascii  "\n"
    .ascii  "Z'GOCKY\n"
    .ascii  "G-IT LABORATORY\n"
    .ascii  "PILOT:ROSENTHAL\n"
    .ascii  "      KOBASHI\n"
    .ascii  "GASTIMA\n"
    .ascii  "G-IT LABORATORY\n"
    .ascii  "PILOT:CHICKARA DUAL\n"
    .ascii  "\n"
    .ascii  "MAZRASTER\n"
    .ascii  "G-IT LABORATORY\n"
    .ascii  "PILOT:KUN SOON"
    .db     0x00

demoStringMechanic1:

    .ascii  "YGGDRASIL\n"
    .ascii  "G-IT LABORATORY\n"
    .ascii  "PILOT:BARARA PEOR"
    .db     0x00 

demoStringMechanic2:

    .ascii  "WUXIA\n"
    .ascii  "CAPITAL ARMY\n"
    .ascii  "\n"
    .ascii  "\n"
    .ascii  "G-RACH\n"
    .ascii  "G-IT LABORATORY\n"
    .ascii  "PILOT:MANNY\n"
    .ascii  "      AMBASSADA\n"
    .ascii  "\n"
    .ascii  "\n"
    .ascii  "KABAKALI\n"
    .ascii  "G-IT LABORATORY\n"
    .ascii  "PILOT:MASK"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
_demoState::

    .ds     1

; タイマ
;
demoTimer:

    .ds     2

; ロゴ
;
demoLogo:

    .ds     1

