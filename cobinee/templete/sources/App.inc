; App.inc : �A�v���P�[�V����
;


; �}�N���̒�`
;

; �r�f�I
APP_PATTERN_NAME_TABLE          =   0x1800
APP_PATTERN_GENERATOR_TABLE     =   0x0000
APP_COLOR_TABLE                 =   0x2000
APP_SPRITE_ATTRIBUTE_TABLE      =   0x1b00
APP_SPRITE_GENERATOR_TABLE      =   0x3800

; ���
APP_STATE_NULL                  =   0x00
APP_STATE_GAME_INITIALIZE       =   0x01
APP_STATE_GAME_UPDATE           =   0x02


; �O���֐��錾
;

    .globl  _AppInitialize
    .globl  _AppUpdate
    .globl  _AppNull
    .globl  _AppTransferPatternName

; �O���ϐ��錾
;

; ���
    .globl  _appState
    .globl  _appPatternName
    