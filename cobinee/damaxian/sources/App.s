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
    .include    "Back.inc"
    .include    "Title.inc"
    .include    "Game.inc"


; �O���ϐ��錾
;
    .globl  _pattern



; CODE �̈�
;
    .area   _CODE


; �A�v���P�[�V����������������
;
_AppInitialize::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    push    ix
    
    ; �X�N���[�����[�h�̐ݒ�
    ld      a, #VIDEO_GRAPHIC1
    call    _SystemSetScreenMode
    
    ; ���荞�݂̋֎~
    di
    
    ; �p�^�[���W�F�l���[�^�̓]��
    ld      a, (_videoPort + 1)
    inc     a
    ld      c, a
    ld      a, #<VIDEO_GRAPHIC1_PATTERN_GENERATOR_TABLE
    out     (c), a
    ld      a, #(>VIDEO_GRAPHIC1_PATTERN_GENERATOR_TABLE | 0b01000000)
    out     (c), a
    dec     c
    ld      hl, #(_pattern + 0x0000)
    ld      b, #0x00
    otir
    otir
    otir
    otir
    otir
    otir
    otir
    otir
    
    ; �X�v���C�g�W�F�l���[�^�̓]��
    inc     c
    ld      a, #<VIDEO_GRAPHIC1_SPRITE_GENERATOR_TABLE
    out     (c), a
    ld      a, #(>VIDEO_GRAPHIC1_SPRITE_GENERATOR_TABLE | 0b01000000)
    out     (c), a
    dec     c
    otir
    otir
    otir
    otir
    otir
    otir
    otir
    otir
    
    ; ���荞�݋֎~�̉���
    ei
    
    ; �A�v���P�[�V�����̏�����
    
    ; �n�C�X�R�A�̏�����
    ld      ix, #_appHiscore
    xor     a
    ld      0(ix), a
    ld      1(ix), a
    ld      3(ix), a
    ld      4(ix), a
    ld      5(ix), a
    ld      a, #0x05
    ld      2(ix), a
    
    ; ���݂̃X�R�A�̏�����
    ld      ix, #_appScore
    xor     a
    ld      0(ix), a
    ld      1(ix), a
    ld      2(ix), a
    ld      3(ix), a
    ld      4(ix), a
    ld      5(ix), a
    
    ; �X�R�A�̔{���̏�����
    ld      ix, #_appRate
    xor     a
    ld      0(ix), a
    ld      2(ix), a
    ld      3(ix), a
    inc     a
    ld      1(ix), a
    
    ; �^�C�}�̏�����
    ld      ix, #_appTimer
    xor     a
    ld      0(ix), a
    ld      1(ix), a
    ld      2(ix), a
    ld      3(ix), a
    
    ; ���[�h�̏�����
    ld      a, #APP_MODE_LOAD
    ld      (_appMode), a
    
    ; ��Ԃ̍X�V
    ld      a, #APP_STATE_NULL
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; ���W�X�^�̕��A
    pop     ix
    pop     bc
    pop     hl
    
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
    
    ; ���[�h�̎擾
    ld      a, (_appMode)
    
    ; �ǂݍ���
    cp      #APP_MODE_LOAD
    jr      nz, 00$
    call    AppLoad
    jr      AppUpdateEnd
00$:
    
    ; �^�C�g�����
    cp      #APP_MODE_TITLE
    jr      nz, 01$
    call    AppTitle
    jr      AppUpdateEnd
01$:
    
    ; �Q�[�����
    cp      #APP_MODE_GAME
    jr      nz, 02$
    call    AppGame
    jr      AppUpdateEnd
02$:
    
    ; �X�V�̏I��
AppUpdateEnd:
    
    ; �������܂킷
    call    _SystemGetRandom
    
    ; ���W�X�^�̕��A
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; �I��
    ret


; �A�v���P�[�V������ǂݍ���
;
AppLoad:
    
    ; �w�i�̃��[�h
    call    _BackLoad
    
    ; �w�i�F�̐ݒ�
    ld      a, #0x07
    ld      (_videoRegister + VDP_R7), a
    
    ; �X�v���C�g�̐ݒ�ƕ\���̊J�n
    ; ld      hl, #(_videoRegister + VDP_R1)
    ; ld      a, (hl)
    ; or      #((1 << VDP_R1_BL) | (1 << VDP_R1_SI))
    ; ld      (hl), a
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    set     #VDP_R1_SI, (hl)
    
    ; V-Blank ���̓]���̊J�n
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; ���[�h�̍X�V
    ld      a, #APP_MODE_TITLE
    ld      (_appMode), a
    
    ; ��Ԃ̍X�V
    ld      a, #APP_STATE_NULL
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; �I��
    ret


; �^�C�g����ʂ���������
;
AppTitle:
    
    ; �^�C�g����ʂ̍X�V
    call    _TitleUpdate
    
    ; �I��
    ret


; �Q�[����ʂ���������
;
AppGame:
    
    ; �Q�[����ʂ̍X�V
    call    _GameUpdate
    
    ; �I��
    ret



; �萔�̒�`
;



; DATA �̈�
;
    .area   _DATA


; �ϐ��̒�`
;

; ���[�h
;
_appMode::
    
    .ds     1

; ���
;
_appState::
    
    .ds     1

_appPhase::
    
    .ds     1

; �n�C�X�R�A
;
_appHiscore::
    
    .ds     6

; ���݂̃X�R�A
;
_appScore::
    
    .ds     6

; �X�R�A�̔{��
;
_appRate::
    
    .ds     4

; �^�C�}
;
_appTimer::
    
    .ds     4



