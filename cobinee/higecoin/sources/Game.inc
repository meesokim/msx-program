; Game.inc : ゲーム
;


; マクロの定義
;

; 状態
GAME_STATE_NULL                 =   0x00
GAME_STATE_START                =   0x10
GAME_STATE_OPEN                 =   0x20
GAME_STATE_PLAY                 =   0x30
GAME_STATE_NEXT                 =   0x40
GAME_STATE_CLEAR                =   0x50
GAME_STATE_END                  =   0x60
GAME_STATE_MISS                 =   0x70
GAME_STATE_OVER                 =   0x80

; スプライト
GAME_SPRITE_PLAYER_0            =   0x00
GAME_SPRITE_ENEMY               =   0x10
GAME_SPRITE_PLAYER_1            =   0x38
GAME_SPRITE_PLAYER_2            =   0x3c
GAME_SPRITE_BLOCK               =   0x20
GAME_SPRITE_HINT                =   0x24
GAME_SPRITE_COIN                =   0x28

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate

; 外部変数宣言
;
    .globl  _gameCoin
    .globl  _gameTime
