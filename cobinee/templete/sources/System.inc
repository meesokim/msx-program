; System.inc : �V�X�e�����C�u����
;


; �}�N���̒�`
;

; �t���O
;
FLAG_H_TIMI             =   0x00
FLAG_SOUND_SLEEP        =   0x01
FLAG_CANCEL             =   0x07

; ���N�G�X�g
;
REQUEST_NULL            =   0x00
REQUEST_VIDEO_REGISTER  =   0x01
REQUEST_VRAM            =   0x02

; �L�[����
;
INPUT_KEY_UP            =   0x00
INPUT_KEY_DOWN          =   0x01
INPUT_KEY_LEFT          =   0x02
INPUT_KEY_RIGHT         =   0x03
INPUT_BUTTON_SPACE      =   0x04
INPUT_BUTTON_SHIFT      =   0x05
INPUT_BUTTON_ESC        =   0x06
INPUT_BUTTON_STOP       =   0x07
INPUT_SIZE              =   0x08

; �r�f�I
;
VIDEO_TEXT1                                 =   0x00
VIDEO_TEXT1_PATTERN_NAME_TABLE              =   0x0000
VIDEO_TEXT1_PATTERN_GENERATOR_TABLE         =   0x0800
VIDEO_TEXT1_COLOR_TABLE                     =   0x0000
VIDEO_TEXT1_SPRITE_ATTRIBUTE_TABLE          =   0x1b00
VIDEO_TEXT1_SPRITE_GENERATOR_TABLE          =   0x3800
VIDEO_GRAPHIC1                              =   0x01
VIDEO_GRAPHIC1_PATTERN_NAME_TABLE           =   0x1800
VIDEO_GRAPHIC1_PATTERN_GENERATOR_TABLE      =   0x0000
VIDEO_GRAPHIC1_COLOR_TABLE                  =   0x2000
VIDEO_GRAPHIC1_SPRITE_ATTRIBUTE_TABLE       =   0x1b00
VIDEO_GRAPHIC1_SPRITE_GENERATOR_TABLE       =   0x3800
VIDEO_GRAPHIC2                              =   0x02
VIDEO_GRAPHIC2_PATTERN_NAME_TABLE           =   0x1800
VIDEO_GRAPHIC2_PATTERN_GENERATOR_TABLE      =   0x0000
VIDEO_GRAPHIC2_COLOR_TABLE                  =   0x2000
VIDEO_GRAPHIC2_SPRITE_ATTRIBUTE_TABLE       =   0x1b00
VIDEO_GRAPHIC2_SPRITE_GENERATOR_TABLE       =   0x3800
VIDEO_MULTICOLOR                            =   0x03
VIDEO_MULTICOLOR_PATTERN_NAME_TABLE         =   0x0800
VIDEO_MULTICOLOR_PATTERN_GENERATOR_TABLE    =   0x0000
VIDEO_MULTICOLOR_COLOR_TABLE                =   0x2000
VIDEO_MULTICOLOR_SPRITE_ATTRIBUTE_TABLE     =   0x1b00
VIDEO_MULTICOLOR_SPRITE_GENERATOR_TABLE     =   0x3800
VIDEO_TRANSFER_VRAM_0                       =   0x00
VIDEO_TRANSFER_VRAM_1                       =   0x01
VIDEO_TRANSFER_VRAM_2                       =   0x02
VIDEO_TRANSFER_VRAM_3                       =   0x03
VIDEO_TRANSFER_VRAM_SIZE                    =   0x04
VIDEO_TRANSFER_SRC                          =   0x00
VIDEO_TRANSFER_DST                          =   0x02
VIDEO_TRANSFER_BYTES                        =   0x04
VIDEO_TRANSFER_SIZE                         =   0x05
VIDEO_TRANSFER_VRAM_0                       =   0x00
VIDEO_TRANSFER_VRAM_0_SRC                   =   0x00
VIDEO_TRANSFER_VRAM_0_DST                   =   0x02
VIDEO_TRANSFER_VRAM_0_BYTES                 =   0x04
VIDEO_TRANSFER_VRAM_1                       =   0x05
VIDEO_TRANSFER_VRAM_1_SRC                   =   0x05
VIDEO_TRANSFER_VRAM_1_DST                   =   0x07
VIDEO_TRANSFER_VRAM_1_BYTES                 =   0x09
VIDEO_TRANSFER_VRAM_2                       =   0x0a
VIDEO_TRANSFER_VRAM_2_SRC                   =   0x0a
VIDEO_TRANSFER_VRAM_2_DST                   =   0x0c
VIDEO_TRANSFER_VRAM_2_BYTES                 =   0x0e
VIDEO_TRANSFER_VRAM_3                       =   0x0f
VIDEO_TRANSFER_VRAM_3_SRC                   =   0x0f
VIDEO_TRANSFER_VRAM_3_DST                   =   0x11
VIDEO_TRANSFER_VRAM_3_BYTES                 =   0x13

; �O���֐��錾
;

    ; �V�X�e��
    .globl  _SystemInitialize
    
    ; �L�[����
    .globl  _SystemUpdateInput
    
    ; �r�f�I
    .globl  _SystemTransferVideoRegister
    .globl  _SystemTransferVram
    
    ; �X�v���C�g
    .globl  _SystemClearSprite
    .globl  _SystemTransferSprite
    
    ; �T�E���h
    .globl  _SystemUpdateSound
    .globl  _SystemSuspendSound
    .globl  _SystemResumeSound
    
    ; ����
    .globl  _SystemGetRandom
    
; �O���ϐ��錾
;

    ; �t���O
    .globl  _flag
    
    ; ���N�G�X�g
    .globl  _request
    
    ; �L�[����
    .globl  _input
    
    ; �r�f�I
    .globl  _videoPort
    .globl  _videoRegister
    .globl  _videoTransfer
    
    ; �X�v���C�g
    .globl  _sprite
    
    ; �T�E���h
    .globl  _soundRequest
    .globl  _soundHead
    .globl  _soundPlay