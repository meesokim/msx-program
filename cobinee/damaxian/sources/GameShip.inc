; GameShip.inc : ゲーム画面／自機
;



; マクロの定義
;

; パラメータ
;
GAME_SHIP_PARAM_STATE       =   0
GAME_SHIP_PARAM_PHASE       =   1
GAME_SHIP_PARAM_POINT_X     =   2
GAME_SHIP_PARAM_POINT_Y     =   3
GAME_SHIP_PARAM_NODAMAGE    =   4
GAME_SHIP_PARAM_ANIMATION   =   5
GAME_SHIP_PARAM_SIZE        =   6

; 状態
;
GAME_SHIP_STATE_NULL    =   0
GAME_SHIP_STATE_PLAY    =   1
GAME_SHIP_STATE_BOMB    =   2



; 外部関数宣言
;

    .globl  _GameShipInitialize
    .globl  _GameShipUpdate



; 外部変数宣言
;

    .globl  _gameShip



