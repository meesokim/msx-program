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

; �}�N���̒�`
;


; CODE �̈�
;
    .area   _CODE

; �^�C�g��������������
;
_TitleInitialize::
    
    ; ���W�X�^�̕ۑ�
    
    ; �X�v���C�g�̃N���A
    call    _SystemClearSprite
    
    ; �p�^�[���̃N���A
    ld      hl, #(_appPatternName + 0x0000)
    ld      de, #(_appPatternName + 0x0001)
    ld      bc, #0x02ff
    xor     a
    ld      (hl), a
    ldir
    
    ; �p�^�[���l�[���̓]��
    call    _AppTransferPatternName
    
    ; �p�^�[���W�F�l���[�^�̐ݒ�
    ld      a, #(APP_PATTERN_GENERATOR_TABLE_0 >> 11)
    ld      (_videoRegister + VDP_R4), a
    
    ; �`��̊J�n
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; �r�f�I���W�X�^�̓]��
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; ��Ԃ̐ݒ�
    xor     a
    ld      (titleState), a
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
    
    ; �������̊J�n
    ld      a, (titleState)
    or      a
    jr      nz, 09$
    
    ; �A�j���[�V�����̏�����
    xor     a
    ld      (titleAnimation), a
    
    ; �^�C�}�̏�����
;   xor     a
    ld      (titleTimer), a
    
    ; �������̊���
    ld      hl, #titleState
    inc     (hl)
09$:
    
    ; �����̍X�V
    call    _SystemGetRandom
    
    ; SPACE �L�[�̊Ď�
    ld      hl, #titleState
    ld      a, (hl)
    dec     a
    jr      nz, 19$
    
    ; �^�C�}�̍X�V
    ld      hl, #titleTimer
    inc     (hl)
    
    ; SPACE �L�[�̉���
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 90$
    ld      hl, #titleState
    inc     (hl)
    
    ; �A�j���[�V�����̐ݒ�
    ld      a, #0x60
    ld      (titleAnimation), a
    
    ; �W���O���̍Đ�
    ld      hl, #titleJingle0
    ld      (_soundRequest + 0x0000), hl
    ld      hl, #titleJingle1
    ld      (_soundRequest + 0x0002), hl
    ld      hl, #titleJingle2
    ld      (_soundRequest + 0x0004), hl
    jr      90$
    
    ; SPACE �L�[�Ď��̊���
19$:
    
    ; �^�C�}�̍X�V
    ld      hl, #titleTimer
    ld      a, (hl)
    add     a, #0x08
    ld      (hl), a
    
    ; �W���O���̊Ď�
    ld      hl, (_soundPlay + 0x0000)
    ld      a, h
    or      l
    jr      nz, 29$
    
;   ; �`��̒�~
;   ld      hl, #(_videoRegister + VDP_R1)
;   res     #VDP_R1_BL, (hl)
    
;   ; �r�f�I���W�X�^�̓]��
;   ld      hl, #_request
;   set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; �Q�[���̊J�n
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_appState), a
;   jr      90$
    
    ; �W���O���Ď��̊���
29$:
    
    ; �A�j���[�V�����̍X�V
90$:
    ld      hl, #titleAnimation
    ld      a, (hl)
    cp      #0x60
    adc     a, #0x00
    ld      (hl), a
    ld      hl, #titleLogoString
    ld      de, #(_appPatternName + 0x00c0)
    ld      c, a
    ld      b, #0x00
    ldir
    
    ; �n�C�X�R�A�̕`��
    ld      a, (titleAnimation)
    cp      #0x60
    jr      c, 98$
    ld      hl, #titleScoreString
    ld      de, #(_appPatternName + 0x0187)
    ld      bc, #0x0011
    ldir
    ld      hl, #_appScore
    ld      de, #(_appPatternName + 0x0190)
    ld      bc, #0x0650
91$:
    ld      a, (hl)
    or      a
    jr      nz, 92$
    inc     hl
    inc     de
    djnz    91$
    jr      93$
92$:
    ld      a, (hl)
    add     a, c
    ld      (de), a
    inc     hl
    inc     de
    djnz    92$
    ld      a, c
    ld      (de), a
93$:
    
    ; SPACE �L�[�̕`��
    ld      a, (titleTimer)
    and     #0x10
    ld      c, a
    ld      b, #0x00
    ld      hl, #titleSpaceString
    add     hl, bc
    ld      de, #(_appPatternName + 0x0228)
    ld      bc, #0x0f
    ldir
    
    ; �A�j���[�V�����̊���
98$:
    call    _AppTransferPatternName
    
    ; �X�V�̊���
99$:

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

; ���S
;
titleLogoString:

    .db     0x00, 0x00, 0x00, 0x00, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0xa0, 0xa1
    .db     0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0xb0, 0xb1
    .db     0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x8a, 0x8b, 0x8c, 0x8d, 0x9a
    .db     0x9b, 0x9c, 0x9d, 0x9e, 0x9f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

; �X�R�A
;
titleScoreString:

    .db     0x68, 0x69, 0x4d, 0x73, 0x63, 0x6f, 0x72, 0x65, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x50

; SPACE �L�[
;
titleSpaceString:

    .db     0x70, 0x72, 0x65, 0x73, 0x73, 0x00, 0x73, 0x70, 0x61, 0x63, 0x65, 0x00, 0x62, 0x61, 0x72, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

; �W���O��
;
titleJingle0:

    .ascii  "T2V15-L1"
;   .ascii  "O4BO5DGBG5R7"
    .ascii  "O5G5BGDO4BR7"
    .db     0x00

titleJingle1:

    .ascii  "T2V15-L1"
;   .ascii  "O4DGBO5DO4B5R7"
    .ascii  "O4B5O5DO4BGDR7"
    .db     0x00
    
titleJingle2:

    .ascii  "T2V15-L1"
;   .ascii  "O3G4O4DO3G5R7"
    .ascii  "O3G5O4DO3G4R7"
    .db     0x00


; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

; ���
;
titleState:

    .ds     1

; �A�j���[�V����
;
titleAnimation:

    .ds     1

; �^�C�}
;
titleTimer:

    .ds     1
