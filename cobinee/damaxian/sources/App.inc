; App.inc : アプリケーション
;



; マクロの定義
;

; モード
;
APP_MODE_INIT       =   0
APP_MODE_LOAD       =   1
APP_MODE_TITLE      =   2
APP_MODE_GAME       =   3

; 状態
;
APP_STATE_NULL      =   0
APP_PHASE_NULL      =   0



; 外部関数宣言
;

    .globl  _AppInitialize
    .globl  _AppUpdate



; 外部変数宣言
;

    ; モード
    .globl  _appMode
    
    ; 状態
    .globl  _appState
    .globl  _appPhase
    
    ; ハイスコア
    .globl  _appHiscore
    
    ; 現在のスコア
    .globl  _appScore
    
    ; スコアの倍率
    .globl  _appRate
    
    ; タイマ
    .globl  _appTimer



