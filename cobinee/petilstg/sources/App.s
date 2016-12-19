; App.s : アプリケーション
;


; モジュール宣言
;
    .module App

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include    "Game.inc"

; 外部変数宣言
;
    .globl  _spriteGeneratorTable
    .globl  _patternGeneratorTable


; CODE 領域
;
    .area   _CODE

; アプリケーションを初期化する
;
_AppInitialize::
    
    ; レジスタの保存
    
    ; アプリケーションの初期化
    
    ; ビデオの設定
    ld      hl, #videoScreen1
    ld      de, #_videoRegister
    ld      bc, #0x08
    ldir
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; 割り込みの禁止
    di
    
    ; スプライトアトリビュートのクリア
    ld      hl, #APP_SPRITE_ATTRIBUTE_TABLE
    ld      bc, #0x0080
    ld      a, #0xc0
    call    FILVRM
    
    ; パターンネームのクリア
    ld      hl, #APP_PATTERN_NAME_TABLE
    ld      bc, #0x0300
    ld      a, #0x00
    call    FILVRM
    
    ; VDP ポートの取得
    ld      a, (_videoPort + 1)
    ld      c, a
    
    ; スプライトジェネレータの転送
    inc     c
    ld      a, #<APP_SPRITE_GENERATOR_TABLE_0
    out     (c), a
    ld      a, #(>APP_SPRITE_GENERATOR_TABLE_0 | 0b01000000)
    out     (c), a
    dec     c
    ld      hl, #(_spriteGeneratorTable + 0x0000)
    ld      d, #0x18
0$:
    ld      e, #0x10
1$:
    push    de
    ld      b, #0x08
    otir
    ld      de, #0x78
    add     hl, de
    ld      b, #0x08
    otir
    ld      de, #0x80
    or      a
    sbc     hl, de
    pop     de
    dec     e
    jr      nz, 1$
    ld      a, #0x80
    add     a, l
    ld      l, a
    ld      a, h
    adc     a, #0x00
    ld      h, a
    dec     d
    jr      nz, 0$
    
    ; パターンジェネレータの転送
    inc     c
    ld      a, #<APP_PATTERN_GENERATOR_TABLE
    out     (c), a
    ld      a, #(>APP_PATTERN_GENERATOR_TABLE | 0b01000000)
    out     (c), a
    dec     c
    ld      hl, #(_patternGeneratorTable + 0x0000)
    ld      b, #0x00
    otir
    otir
    otir
    otir
    otir
    otir
    otir
    otir
    
    ; カラーテーブルの転送
    inc     c
    ld      a, #<APP_COLOR_TABLE
    out     (c), a
    ld      a, #(>APP_COLOR_TABLE | 0b01000000)
    out     (c), a
    dec     c
    ld      hl, #(colorTable + 0x0000)
    ld      b, #0x20
    otir
    
    ; 割り込み禁止の解除
    ei
    
    ; 状態の初期化
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_appState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; アプリケーションを更新する
;
_AppUpdate::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; 状態の取得
    ld      a, (_appState)
    
    ; タイトルの初期化
1$:
    cp      #APP_STATE_TITLE_INITIALIZE
    jr      nz, 2$
    ;;
    jr      9$
    
    ; タイトルの更新
2$:
    cp      #APP_STATE_TITLE_UPDATE
    jr      nz, 3$
    ;;
    jr      9$
    
    ; ゲームの初期化
3$:
    cp      #APP_STATE_GAME_INITIALIZE
    jr      nz, 4$
    call    _GameInitialize
    jr      9$
    
    ; ゲームの更新
4$:
    cp      #APP_STATE_GAME_UPDATE
    jr      nz, 3$
    call    _GameUpdate
;   jr      9$
    
    ; 更新の終了
9$:

    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; 定数の定義
;

; VDP レジスタ値（スクリーン１）
;
videoScreen1:

    .db     0b00000000
    .db     0b10100010
    .db     APP_PATTERN_NAME_TABLE >> 10
    .db     APP_COLOR_TABLE >> 6
    .db     APP_PATTERN_GENERATOR_TABLE >> 11
    .db     APP_SPRITE_ATTRIBUTE_TABLE >> 7
    .db     APP_SPRITE_GENERATOR_TABLE_0 >> 11
    .db     0b00000000
    
; カラーテーブル
;
colorTable:

    .db     0xf0, 0xf0
    .db     0xf0, 0xf0
    .db     0xf0, 0xf0
    .db     0xf0, 0xf0
    .db     0xb0, 0xb0
    .db     0xe0, 0xe0
    .db     0x40, 0x45
    .db     0x90, 0x90
    .db     0x60, 0x60
    .db     0xa0, 0xa0
    .db     0xa0, 0xa0
    .db     0xa0, 0xa0
    .db     0xa0, 0xa0
    .db     0xa0, 0xa0
    .db     0xa0, 0xa0
    .db     0xa0, 0xa0


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
_appState::

    .ds     1

