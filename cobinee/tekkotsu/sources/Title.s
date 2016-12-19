; Title.s : �^�C�g��
;


; ���W���[���錾
;
    .module Title

; �Q�ƃt�@�C��
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Title.inc"

; �O���ϐ��錾
;
    .globl  _logoPatternNameTable
    .globl  _logoPatternGeneratorTable
    .globl  _logoColorTable

; �}�N���̒�`
;


; CODE �̈�
;
    .area   _CODE

; �^�C�g��������������
;
_TitleInitialize::
    
    ; ���W�X�^�̕ۑ�
    
    ; �p�^�[���l�[���̓]��
    ld      hl, #_logoPatternNameTable
    ld      de, #APP_PATTERN_NAME_TABLE_0
    ld      bc, #0x0300
    call    LDIRVM
    
    ; �p�^�[���W�F�l���[�^�̓]��
    ld      hl, #_logoPatternGeneratorTable
    ld      bc, (_logoPatternGeneratorTable + 0x00)
    add     hl, bc
    ld      bc, (_logoPatternGeneratorTable + 0x02)
    ld      de, #APP_PATTERN_GENERATOR_TABLE_0
    call    LDIRVM
    ld      hl, #_logoPatternGeneratorTable
    ld      bc, (_logoPatternGeneratorTable + 0x04)
    add     hl, bc
    ld      bc, (_logoPatternGeneratorTable + 0x06)
    ld      de, #APP_PATTERN_GENERATOR_TABLE_1
    call    LDIRVM
    ld      hl, #_logoPatternGeneratorTable
    ld      bc, (_logoPatternGeneratorTable + 0x08)
    add     hl, bc
    ld      bc, (_logoPatternGeneratorTable + 0x0a)
    ld      de, #APP_PATTERN_GENERATOR_TABLE_2
    call    LDIRVM
    
    ; �J���[�e�[�u���̓]��
    ld      hl, #_logoColorTable
    ld      bc, (_logoColorTable + 0x00)
    add     hl, bc
    ld      bc, (_logoColorTable + 0x02)
    ld      de, #APP_COLOR_TABLE_0
    call    LDIRVM
    ld      hl, #_logoColorTable
    ld      bc, (_logoColorTable + 0x04)
    add     hl, bc
    ld      bc, (_logoColorTable + 0x06)
    ld      de, #APP_COLOR_TABLE_1
    call    LDIRVM
    ld      hl, #_logoColorTable
    ld      bc, (_logoColorTable + 0x08)
    add     hl, bc
    ld      bc, (_logoColorTable + 0x0a)
    ld      de, #APP_COLOR_TABLE_2
    call    LDIRVM
    
    ; �`��̊J�n
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; �r�f�I���W�X�^�̓]��
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; �a�f�l�̐ݒ�
    ld      hl, #titleBgm0
    ld      (_soundRequest + 0), hl
    ld      hl, #titleBgm1
    ld      (_soundRequest + 2), hl
    ld      hl, #titleBgm2
    ld      (_soundRequest + 4), hl
    
    ; ��Ԃ̐ݒ�
    ld      a, #APP_STATE_TITLE_UPDATE
    ld      (_appState), a
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �^�C�g�����X�V����
;
_TitleUpdate::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; �X�v���C�g�̃N���A
    call    _SystemClearSprite
    
    ; �����̍X�V
    call    _SystemGetRandom
    
    ; SPACE �̊Ď�
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 09$
    
    ; �`��̒�~
    ld      hl, #(_videoRegister + VDP_R1)
    res     #VDP_R1_BL, (hl)
    
    ; �r�f�I���W�X�^�̓]��
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; �Q�[���̊J�n
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_appState), a
    
    ; SPACE �Ď��̊���
09$:

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

; �a�f�l
;
titleBgm0:

    .ascii  "T3V15-L3"
    .ascii  "O4E5GE"
    .ascii  "G7RGGG"
    .ascii  "A4G4ERGGG"
    .ascii  "A4G4ERGGG"
    .ascii  "A4G4E"
    .db     0x00
    
titleBgm1:

    .ascii  "T3V16L3S0N2"
    .ascii  "M3XXM5XM3X"
    .ascii  "M5XM3XXXM3XXM5XM3X"
    .ascii  "M5XM3XXXM3XXM5XM3X"
    .ascii  "M5XM3XXXM3XXM5XM3X"
    .ascii  "M5XM3XXX"
    .db     0x00

titleBgm2:

    .ascii  "T3V15-L7"
    .ascii  "O4R"
    .ascii  "E7R"
    .ascii  "F+R"
    .ascii  "F+R"
    .ascii  "F+"
    .db     0x00


; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

