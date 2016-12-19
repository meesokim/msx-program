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
    .globl  _patternTable


; CODE �̈�
;
    .area   _CODE

; �A�v���P�[�V����������������
;
_AppInitialize::
    
    ; ���W�X�^�̕ۑ�
    
    ; �A�v���P�[�V�����̏�����
    
    ; ��ʕ\���̒�~
    call    DISSCR
    
    ; �r�f�I�̐ݒ�
    ld      hl, #videoScreen1
    ld      de, #_videoRegister
    ld      bc, #0x08
    ldir
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; ���荞�݂̋֎~
    di
    
    ; VDP �|�[�g�̎擾
    ld      a, (_videoPort + 1)
    ld      c, a
    
    ; �X�v���C�g�W�F�l���[�^�̓]��
    inc     c
    ld      a, #<APP_SPRITE_GENERATOR_TABLE
    out     (c), a
    ld      a, #(>APP_SPRITE_GENERATOR_TABLE | 0b01000000)
    out     (c), a
    dec     c
    ld      hl, #(_patternTable + 0x0000)
    ld      d, #0x08
10$:
    ld      e, #0x10
11$:
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
    jr      nz, 11$
    ld      a, #0x80
    add     a, l
    ld      l, a
    ld      a, h
    adc     a, #0x00
    ld      h, a
    dec     d
    jr      nz, 10$
    
    ; �p�^�[���W�F�l���[�^�̓]��
    ld      hl, #(_patternTable + 0x0800)
    ld      de, #APP_PATTERN_GENERATOR_TABLE
    ld      bc, #0x0800
    call    LDIRVM
    
    ; �J���[�e�[�u���̏�����
    ld      hl, #APP_COLOR_TABLE
    ld      a, #0x51
    ld      bc, #0x0020
    call    FILVRM
    
    ; �p�^�[���l�[���̏�����
    ld      hl, #APP_PATTERN_NAME_TABLE
    xor     a
    ld      bc, #0x0600
    call    FILVRM
    
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
    
    ; ��ԕʂ̏���
    ld      hl, #10$
    push    hl
    ld      a, (_appState)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #appProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:
    
    ; �X�V�̏I��
99$:

    ; ���W�X�^�̕��A
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; �I��
    ret

; �����Ȃ�
;
_AppNull::

    ; ���W�X�^�̕ۑ�
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �p�^�[���l�[����]������
;
_AppTransferPatternName:

    ; ���W�X�^�̕ۑ�
    
    ; �p�^�[���l�[���̓]��
    xor     a
    ld      hl, #(_appPatternName + 0x0000)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0000)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES), a
    ld      hl, #(_appPatternName + 0x0100)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0100)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_BYTES), a
    ld      hl, #(_appPatternName + 0x0200)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0200)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)
    
    ; ���W�X�^�̕��A
    
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
    .db     APP_SPRITE_GENERATOR_TABLE >> 11
    .db     0b00000111

; ��ԕʂ̏���
;
appProc:
    
    .dw     _AppNull
    .dw     _GameInitialize
    .dw     _GameUpdate


; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

; ���
;
_appState::

    .ds     1

; �p�^�[���l�[��
;
_appPatternName::

    .ds     0x0300
