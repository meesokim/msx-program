; Game.inc : �Q�[��
;


; �}�N���̒�`
;

; �X�v���C�g
GAME_SPRITE_RADAR       =   0x00
GAME_SPRITE_MASK        =   0x0c
GAME_SPRITE_SIGHT_0     =   0x1c
GAME_SPRITE_SIGHT_1     =   0x7c
GAME_SPRITE_UNIT        =   0x20

; �O���֐��錾
;

    .globl  _GameInitialize
    .globl  _GameUpdate

; �O���ϐ��錾
;

    .globl  _gameFrame
    .globl  _gameRotateY
    .globl  _gameRotateX
    .globl  _gameSightX
    .globl  _gameSightY
    .globl  _gameMoveZ
    .globl  _gameAccel
    .globl  _gameFire
    .globl  _gamePatternName