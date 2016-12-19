; Player.inc : プレイヤ
;


; マクロの定義
;

; プレイヤ
PLAYER_STATE                    =   0x00
PLAYER_DIRECTION                =   0x01
PLAYER_POSITION_X               =   0x02
PLAYER_POSITION_Y               =   0x03
PLAYER_SPEED_X                  =   0x04
PLAYER_SPEED_Y                  =   0x05
PLAYER_PATTERN                  =   0x06
PLAYER_ANIMATION                =   0x07
PLAYER_SPRITE_0                 =   0x08
PLAYER_SPRITE_1                 =   0x09
PLAYER_SPRITE_2                 =   0x0a
PLAYER_FLAG                     =   0x0b
PLAYER_SIZE                     =   0x0c

; 状態
PLAYER_STATE_NULL               =   0x00
PLAYER_STATE_WALK               =   0x10
PLAYER_STATE_JUMP               =   0x20
PLAYER_STATE_FALL               =   0x30
PLAYER_STATE_MISS               =   0x40

; 向き
PLAYER_DIRECTION_LEFT           =   0x00
PLAYER_DIRECTION_RIGHT          =   0x01

; フラグ
PLAYER_FLAG_BIT_PAUSE           =   0x00
PLAYER_FLAG_BIT_PUNCH           =   0x01
PLAYER_FLAG_BIT_MISS            =   0x02
PLAYER_FLAG_NULL                =   0x00
PLAYER_FLAG_PAUSE               =   (1 << PLAYER_FLAG_BIT_PAUSE)
PLAYER_FLAG_PUNCH               =   (1 << PLAYER_FLAG_BIT_PUNCH)
PLAYER_FLAG_MISS                =   (1 << PLAYER_FLAG_BIT_MISS)

; 外部関数宣言
;

    .globl  _PlayerInitialize
    .globl  _PlayerCreate
    .globl  _PlayerUpdate
    .globl  _PlayerRender
    .globl  _PlayerHit

; 外部変数宣言
;

    .globl  _player
