; App.s : �A�v���P�[�V����
;


; ���W���[���錾
;
    .module App

; �Q�ƃt�@�C��
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include    "Game.inc"

; �O���ϐ��錾
;
    .globl  _spriteGeneratorTable
    .globl  _patternGeneratorTable


; CODE �̈�
;
    .area   _CODE

; �A�v���P�[�V����������������
;
_AppInitialize::
    
    ; ���W�X�^�̕ۑ�
    
    ; �A�v���P�[�V�����̏�����
    
    ; �r�f�I�̐ݒ�
    ld      hl, #videoScreen1
    ld      de, #_videoRegister
    ld      bc, #0x08
    ldir
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; ���荞�݂̋֎~
    di
    
    ; �X�v���C�g�A�g���r���[�g�̃N���A
    ld      hl, #APP_SPRITE_ATTRIBUTE_TABLE
    ld      bc, #0x0080
    ld      a, #0xc0
    call    FILVRM
    
    ; �p�^�[���l�[���̃N���A
    ld      hl, #APP_PATTERN_NAME_TABLE
    ld      bc, #0x0300
    ld      a, #0x00
    call    FILVRM
    
    ; VDP �|�[�g�̎擾
    ld      a, (_videoPort + 1)
    ld      c, a
    
    ; �X�v���C�g�W�F�l���[�^�̓]��
    inc     c
    ld      a, #<APP_SPRITE_GENERATOR_TABLE_0
    out     (c), a
    ld      a, #(>APP_SPRITE_GENERATOR_TABLE_0 | 0b01000000)
    out     (c), a
    dec     c
    ld      hl, #(_spriteGeneratorTable + 0x0000)
    ld      d, #0x18
0$:
    ld      e, #0x10
1$:
    push    de
    ld      b, #0x08
    otir
    ld      de, #0x78
    add     hl, de
    ld      b, #0x08
    otir
    ld      de, #0x80
    or      a
    sbc     hl, de
    pop     de
    dec     e
    jr      nz, 1$
    ld      a, #0x80
    add     a, l
    ld      l, a
    ld      a, h
    adc     a, #0x00
    ld      h, a
    dec     d
    jr      nz, 0$
    
    ; �p�^�[���W�F�l���[�^�̓]��
    inc     c
    ld      a, #<APP_PATTERN_GENERATOR_TABLE
    out     (c), a
    ld      a, #(>APP_PATTERN_GENERATOR_TABLE | 0b01000000)
    out     (c), a
    dec     c
    ld      hl, #(_patternGeneratorTable + 0x0000)
    ld      b, #0x00
    otir
    otir
    otir
    otir
    otir
    otir
    otir
    otir
    
    ; �J���[�e�[�u���̓]��
    inc     c
    ld      a, #<APP_COLOR_TABLE
    out     (c), a
    ld      a, #(>APP_COLOR_TABLE | 0b01000000)
    out     (c), a
    dec     c
    ld      hl, #(colorTable + 0x0000)
    ld      b, #0x20
    otir
    
    ; ���荞�݋֎~�̉���
    ei
    
    ; ��Ԃ̏�����
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_appState), a
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �A�v���P�[�V�������X�V����
;
_AppUpdate::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; ��Ԃ̎擾
    ld      a, (_appState)
    
    ; �^�C�g���̏�����
1$:
    cp      #APP_STATE_TITLE_INITIALIZE
    jr      nz, 2$
    ;;
    jr      9$
    
    ; �^�C�g���̍X�V
2$:
    cp      #APP_STATE_TITLE_UPDATE
    jr      nz, 3$
    ;;
    jr      9$
    
    ; �Q�[���̏�����
3$:
    cp      #APP_STATE_GAME_INITIALIZE
    jr      nz, 4$
    call    _GameInitialize
    jr      9$
    
    ; �Q�[���̍X�V
4$:
    cp      #APP_STATE_GAME_UPDATE
    jr      nz, 3$
    call    _GameUpdate
;   jr      9$
    
    ; �X�V�̏I��
9$:

    ; ���W�X�^�̕��A
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; �I��
    ret

; �萔�̒�`
;

; VDP ���W�X�^�l�i�X�N���[���P�j
;
videoScreen1:

    .db     0b00000000
    .db     0b10100010
    .db     APP_PATTERN_NAME_TABLE >> 10
    .db     APP_COLOR_TABLE >> 6
    .db     APP_PATTERN_GENERATOR_TABLE >> 11
    .db     APP_SPRITE_ATTRIBUTE_TABLE >> 7
    .db     APP_SPRITE_GENERATOR_TABLE_0 >> 11
    .db     0b00000000
    
; �J���[�e�[�u��
;
colorTable:

    .db     0xf0, 0xf0
    .db     0xf0, 0xf0
    .db     0xf0, 0xf0
    .db     0xf0, 0xf0
    .db     0xb0, 0xb0
    .db     0xe0, 0xe0
    .db     0x40, 0x45
    .db     0x90, 0x90
    .db     0x60, 0x60
    .db     0xa0, 0xa0
    .db     0xa0, 0xa0
    .db     0xa0, 0xa0
    .db     0xa0, 0xa0
    .db     0xa0, 0xa0
    .db     0xa0, 0xa0
    .db     0xa0, 0xa0


; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

; ���
;
_appState::

    .ds     1

