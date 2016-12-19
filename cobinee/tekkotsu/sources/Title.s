; Title.s : タイトル
;


; モジュール宣言
;
    .module Title

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Title.inc"

; 外部変数宣言
;
    .globl  _logoPatternNameTable
    .globl  _logoPatternGeneratorTable
    .globl  _logoColorTable

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; タイトルを初期化する
;
_TitleInitialize::
    
    ; レジスタの保存
    
    ; パターンネームの転送
    ld      hl, #_logoPatternNameTable
    ld      de, #APP_PATTERN_NAME_TABLE_0
    ld      bc, #0x0300
    call    LDIRVM
    
    ; パターンジェネレータの転送
    ld      hl, #_logoPatternGeneratorTable
    ld      bc, (_logoPatternGeneratorTable + 0x00)
    add     hl, bc
    ld      bc, (_logoPatternGeneratorTable + 0x02)
    ld      de, #APP_PATTERN_GENERATOR_TABLE_0
    call    LDIRVM
    ld      hl, #_logoPatternGeneratorTable
    ld      bc, (_logoPatternGeneratorTable + 0x04)
    add     hl, bc
    ld      bc, (_logoPatternGeneratorTable + 0x06)
    ld      de, #APP_PATTERN_GENERATOR_TABLE_1
    call    LDIRVM
    ld      hl, #_logoPatternGeneratorTable
    ld      bc, (_logoPatternGeneratorTable + 0x08)
    add     hl, bc
    ld      bc, (_logoPatternGeneratorTable + 0x0a)
    ld      de, #APP_PATTERN_GENERATOR_TABLE_2
    call    LDIRVM
    
    ; カラーテーブルの転送
    ld      hl, #_logoColorTable
    ld      bc, (_logoColorTable + 0x00)
    add     hl, bc
    ld      bc, (_logoColorTable + 0x02)
    ld      de, #APP_COLOR_TABLE_0
    call    LDIRVM
    ld      hl, #_logoColorTable
    ld      bc, (_logoColorTable + 0x04)
    add     hl, bc
    ld      bc, (_logoColorTable + 0x06)
    ld      de, #APP_COLOR_TABLE_1
    call    LDIRVM
    ld      hl, #_logoColorTable
    ld      bc, (_logoColorTable + 0x08)
    add     hl, bc
    ld      bc, (_logoColorTable + 0x0a)
    ld      de, #APP_COLOR_TABLE_2
    call    LDIRVM
    
    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; ビデオレジスタの転送
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; ＢＧＭの設定
    ld      hl, #titleBgm0
    ld      (_soundRequest + 0), hl
    ld      hl, #titleBgm1
    ld      (_soundRequest + 2), hl
    ld      hl, #titleBgm2
    ld      (_soundRequest + 4), hl
    
    ; 状態の設定
    ld      a, #APP_STATE_TITLE_UPDATE
    ld      (_appState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; タイトルを更新する
;
_TitleUpdate::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; 乱数の更新
    call    _SystemGetRandom
    
    ; SPACE の監視
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 09$
    
    ; 描画の停止
    ld      hl, #(_videoRegister + VDP_R1)
    res     #VDP_R1_BL, (hl)
    
    ; ビデオレジスタの転送
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; ゲームの開始
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_appState), a
    
    ; SPACE 監視の完了
09$:

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

; ＢＧＭ
;
titleBgm0:

    .ascii  "T3V15-L3"
    .ascii  "O4E5GE"
    .ascii  "G7RGGG"
    .ascii  "A4G4ERGGG"
    .ascii  "A4G4ERGGG"
    .ascii  "A4G4E"
    .db     0x00
    
titleBgm1:

    .ascii  "T3V16L3S0N2"
    .ascii  "M3XXM5XM3X"
    .ascii  "M5XM3XXXM3XXM5XM3X"
    .ascii  "M5XM3XXXM3XXM5XM3X"
    .ascii  "M5XM3XXXM3XXM5XM3X"
    .ascii  "M5XM3XXX"
    .db     0x00

titleBgm2:

    .ascii  "T3V15-L7"
    .ascii  "O4R"
    .ascii  "E7R"
    .ascii  "F+R"
    .ascii  "F+R"
    .ascii  "F+"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

