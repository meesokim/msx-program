; App.inc : アプリケーション
;


; マクロの定義
;

; ビデオ
APP_PATTERN_NAME_TABLE          =   0x1800
APP_PATTERN_GENERATOR_TABLE_0   =   0x0000
APP_PATTERN_GENERATOR_TABLE_1   =   0x0800
APP_PATTERN_GENERATOR_TABLE_2   =   0x1000
APP_COLOR_TABLE                 =   0x2000
APP_SPRITE_ATTRIBUTE_TABLE      =   0x1b00
APP_SPRITE_GENERATOR_TABLE      =   0x3800

; 状態
APP_STATE_NULL                  =   0
APP_STATE_TITLE_INITIALIZE      =   1
APP_STATE_TITLE_UPDATE          =   2
APP_STATE_GAME_INITIALIZE       =   3
APP_STATE_GAME_UPDATE           =   4


; 外部関数宣言
;

    .globl  _AppInitialize
    .globl  _AppUpdate
    .globl  _AppTransferPatternName

; 外部変数宣言
;

; 状態
    .globl  _appState
    .globl  _appColor
    .globl  _appScore
    .globl  _appPatternName
    