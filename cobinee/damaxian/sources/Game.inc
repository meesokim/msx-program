; Game.inc : ゲーム画面
;



; マクロの定義
;

; 状態
;
GAME_STATE_INITIALIZE   =   0
GAME_STATE_LOAD         =   1
GAME_STATE_START        =   2
GAME_STATE_PLAY         =   3
GAME_STATE_TIMEUP       =   4
GAME_STATE_OVER         =   5
GAME_STATE_HISCORE      =   6
GAME_STATE_UNLOAD       =   7
GAME_STATE_END          =   8

; スプライト
;
GAME_SPRITE_BULLET          =   0x00
GAME_SPRITE_BULLET_OFFSET   =   0x24
GAME_SPRITE_ENEMY           =   0x48
GAME_SPRITE_ENEMY_OFFSET    =   0x48
GAME_SPRITE_SHIP            =   0x6c
GAME_SPRITE_SHOT            =   0x70

; フラグ
;
GAME_FLAG_PLAYABLE      =   0
GAME_FLAG_PAUSE         =   1
GAME_FLAG_STATUS        =   2



; 外部関数宣言
;

    .globl  _GameUpdate



; 外部変数宣言
;

    .globl  _gameFlag
    .globl  _gameShootDown



