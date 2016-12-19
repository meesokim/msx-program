; GameShot.inc : ゲーム画面／ショット
;



; マクロの定義
;

; ショット
;
GAME_SHOT_SIZE          =   4

; パラメータ
;
GAME_SHOT_PARAM_INDEX   =   0
GAME_SHOT_PARAM_STATE   =   1
GAME_SHOT_PARAM_PHASE   =   2
GAME_SHOT_PARAM_POINT_X =   3
GAME_SHOT_PARAM_POINT_Y =   4
GAME_SHOT_PARAM_SIZE    =   5

; 状態
;
GAME_SHOT_STATE_NULL    =   0
GAME_SHOT_STATE_MOVE    =   1



; 外部関数宣言
;

    .globl  _GameShotInitialize
    .globl  _GameShotUpdate
    .globl  _GameShotEntry



; 外部変数宣言
;

    .globl  _gameShot



