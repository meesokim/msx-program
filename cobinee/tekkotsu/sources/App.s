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
    .include    "Title.inc"
    .include    "Game.inc"

; �O���ϐ��錾
;
    .globl  _spriteGeneratorTable


; CODE �̈�
;
    .area   _CODE

; �A�v���P�[�V����������������
;
_AppInitialize::
    
    ; ���W�X�^�̕ۑ�
    
    ; �A�v���P�[�V�����̏�����
    
    ; �r�f�I�̐ݒ�
    ld      hl, #videoScreen2
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
    ld      hl, #(_spriteGeneratorTable + 0x0000)
    ld      d, #0x08
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
    
    ; ���荞�݋֎~�̉���
    ei
    
    ; ��ʕ\���̒�~
    call    DISSCR
    
    ; ��Ԃ̏�����
    ld      a, #APP_STATE_TITLE_INITIALIZE
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
    call    _TitleInitialize
    jr      9$
    
    ; �^�C�g���̍X�V
2$:
    cp      #APP_STATE_TITLE_UPDATE
    jr      nz, 3$
    call    _TitleUpdate
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

; VDP ���W�X�^�l�i�X�N���[���Q�j
;
videoScreen2:

    .db     0b00000010
    .db     0b10100010
    .db     APP_PATTERN_NAME_TABLE_0 >> 10
    .db     (APP_COLOR_TABLE_0 >> 6) | 0b01111111
    .db     (APP_PATTERN_GENERATOR_TABLE_0 >> 11) | 0b00000011
    .db     APP_SPRITE_ATTRIBUTE_TABLE >> 7
    .db     APP_SPRITE_GENERATOR_TABLE >> 11
    .db     0b00000000
    

; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

; ���
;
_appState::

    .ds     1

