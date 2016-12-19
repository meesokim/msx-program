; App.inc : アプリケーション
;


; マクロの定義
;

; ビデオ
APP_PATTERN_NAME_TABLE          =   0x1800
APP_PATTERN_GENERATOR_TABLE     =   0x0000
APP_COLOR_TABLE                 =   0x2000
APP_SPRITE_ATTRIBUTE_TABLE      =   0x1b00
APP_SPRITE_GENERATOR_TABLE      =   0x3800

; 状態
APP_STATE_NULL                  =   0x00
APP_STATE_TITLE_INITIALIZE      =   0x01
APP_STATE_TITLE_UPDATE          =   0x02
APP_STATE_GAME_INITIALIZE       =   0x03
APP_STATE_GAME_UPDATE           =   0x04

; ゲーム
APP_GAME_A                      =   0x00
APP_GAME_B                      =   0x01
APP_GAME_SIZE                   =   0x02


; 外部関数宣言
;

    .globl  _AppInitialize
    .globl  _AppUpdate
    .globl  _AppNull
    .globl  _AppFillPatternName
    .globl  _AppTransferPatternName

; 外部変数宣言
;

; 状態
    .globl  _appState
    .globl  _appPatternName
    .globl  _appGame
    .globl  _appTime
    