; Ground.s : �n��
;


; ���W���[���錾
;
    .module Ground

; �Q�ƃt�@�C��
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include	"Game.inc"
    .include	"Ground.inc"

; �}�N���̒�`
;


; CODE �̈�
;
    .area   _CODE

; �n�ʂ�����������
;
_GroundInitialize::
    
    ; ���W�X�^�̕ۑ�
    
    ; �n�ʂ̏�����
    ld      hl, #(_ground + 0x0000)
    ld      de, #(_ground + 0x0001)
    ld      bc, #0x2ff
    xor     a
    ld      (hl), a
    ldir

    ; �W�F�l���[�^�̏�����
    ld      ix, #_groundGenerator
    xor     a
    ld      GROUND_GENERATOR_UPPER_STATE(ix), a
    ld      GROUND_GENERATOR_LOWER_STATE(ix), a
    ld      GROUND_GENERATOR_UPPER_HEIGHT(ix), a
    ld      GROUND_GENERATOR_LOWER_HEIGHT(ix), a
    ld      a, #0x01
    ld      GROUND_GENERATOR_UPPER_LENGTH(ix), a
    ld      GROUND_GENERATOR_LOWER_LENGTH(ix), a
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �n�ʂ��X�V����
;
_GroundUpdate::
    
    ; ���W�X�^�̕ۑ�
    
    ; �X�N���[���̊J�n
    ld      a, (_gameScroll)
    or      a
    jp      nz, 99$
    
    ; �P�L�������̃X�N���[��
    ld      hl, #(_ground + 0x02fe)
    ld      de, #(_ground + 0x02ff)
    ld      bc, #0x02ff
    lddr
    
    ; ���������̏�����
    ld      hl, #(groundGeneratorRow + 0x0000)
    ld      de, #(groundGeneratorRow + 0x0001)
    ld      bc, #0x0017
    xor     a
    ld      (hl), a
    ldir
    
    ; �W�F�l���[�^�̎擾
    ld      ix, #_groundGenerator
    
    ; ���̐���
    ld      hl, #(groundGeneratorRow + 0x0001)
    ld      a, GROUND_GENERATOR_UPPER_STATE(ix)
    
    ; �n�ʂȂ��^��
    or      a
    jr      nz, 10$
    dec     GROUND_GENERATOR_UPPER_LENGTH(ix)
    jp      nz, 19$
    ld      a, #0x4a
    ld      (hl), a
    inc     GROUND_GENERATOR_UPPER_HEIGHT(ix)
    call    _SystemGetRandom
    and     #0x1f
    add     a, #0x11
    ld      GROUND_GENERATOR_UPPER_LENGTH(ix), a
    ld      a, #GROUND_GENERATOR_STATE_FLAT
    ld      GROUND_GENERATOR_UPPER_STATE(ix), a
    jr      19$
    
    ; ���n�^��
10$:
    cp      #GROUND_GENERATOR_STATE_FLAT
    jr      nz, 13$
    ld      b, GROUND_GENERATOR_UPPER_HEIGHT(ix)
    dec     b
    jr      z, 12$
    ld      a, #0x4f
11$:
    ld      (hl), a
    inc     hl
    djnz    11$
12$:
    ld      a, #0x48
    ld      (hl), a
    dec     GROUND_GENERATOR_UPPER_LENGTH(ix)
    jr      nz, 18$
    call    _SystemGetRandom
    and     #0x07
    inc     a
    ld      GROUND_GENERATOR_UPPER_LENGTH(ix), a
    ld      a, #GROUND_GENERATOR_STATE_UP
    ld      GROUND_GENERATOR_UPPER_STATE(ix), a
    jr      18$
    
    ; ���^��
13$:
    cp      #GROUND_GENERATOR_STATE_UP
    jr      nz, 15$
    ld      b, GROUND_GENERATOR_UPPER_HEIGHT(ix)
    ld      a, #0x4f
14$:
    ld      (hl), a
    inc     hl
    djnz    14$
    ld      a, #0x4a
    ld      (hl), a
    inc     GROUND_GENERATOR_UPPER_HEIGHT(ix)
    dec     GROUND_GENERATOR_UPPER_LENGTH(ix)
    jr      nz, 18$
    ld      a, GROUND_GENERATOR_UPPER_HEIGHT(ix)
    dec     a
    ld      GROUND_GENERATOR_UPPER_LENGTH(ix), a
    ld      a, #GROUND_GENERATOR_STATE_DOWN
    ld      GROUND_GENERATOR_UPPER_STATE(ix), a
    jr      18$
    
    ; ����^��
15$:
;   cp      #GROUND_GENERATOR_STATE_DOWN
;   jr      nz, 19$
    ld      b, GROUND_GENERATOR_UPPER_HEIGHT(ix)
    dec     b
    ld      a, #0x4f
16$:
    ld      (hl), a
    inc     hl
    djnz    16$
    ld      a, #0x4b
    ld      (hl), a
    dec     GROUND_GENERATOR_UPPER_HEIGHT(ix)
    dec     GROUND_GENERATOR_UPPER_LENGTH(ix)
    jr      nz, 18$
    call    _SystemGetRandom
    and     #0x1f
    add     a, #0x11
    ld      GROUND_GENERATOR_UPPER_LENGTH(ix), a
    ld      a, #GROUND_GENERATOR_STATE_FLAT
    ld      GROUND_GENERATOR_UPPER_STATE(ix), a
;   jr      18$

    ; ���̐����̊���
18$:
19$:
    
    ; ���̐���
    ld      hl, #(groundGeneratorRow + 0x0017)
    ld      a, GROUND_GENERATOR_LOWER_STATE(ix)
    
    ; �n�ʂȂ��^��
    or      a
    jr      nz, 20$
    dec     GROUND_GENERATOR_LOWER_LENGTH(ix)
    jp      nz, 29$
    ld      a, #0x4b
    ld      (hl), a
    inc     GROUND_GENERATOR_LOWER_HEIGHT(ix)
    call    _SystemGetRandom
    and     #0x1f
    add     a, #0x11
    ld      GROUND_GENERATOR_LOWER_LENGTH(ix), a
    ld      a, #GROUND_GENERATOR_STATE_FLAT
    ld      GROUND_GENERATOR_LOWER_STATE(ix), a
    jr      29$
    
    ; ���n�^��
20$:
    cp      #GROUND_GENERATOR_STATE_FLAT
    jr      nz, 23$
    ld      b, GROUND_GENERATOR_LOWER_HEIGHT(ix)
    dec     b
    jr      z, 22$
    ld      a, #0x4f
21$:
    ld      (hl), a
    dec     hl
    djnz    21$
22$:
    ld      a, #0x49
    ld      (hl), a
    dec     GROUND_GENERATOR_LOWER_LENGTH(ix)
    jr      nz, 28$
    call    _SystemGetRandom
    and     #0x07
    inc     a
    ld      GROUND_GENERATOR_LOWER_LENGTH(ix), a
    ld      a, #GROUND_GENERATOR_STATE_UP
    ld      GROUND_GENERATOR_LOWER_STATE(ix), a
    jr      28$
    
    ; ���^��
23$:
    cp      #GROUND_GENERATOR_STATE_UP
    jr      nz, 25$
    ld      b, GROUND_GENERATOR_LOWER_HEIGHT(ix)
    ld      a, #0x4f
24$:
    ld      (hl), a
    dec     hl
    djnz    24$
    ld      a, #0x4b
    ld      (hl), a
    inc     GROUND_GENERATOR_LOWER_HEIGHT(ix)
    dec     GROUND_GENERATOR_LOWER_LENGTH(ix)
    jr      nz, 28$
    ld      a, GROUND_GENERATOR_LOWER_HEIGHT(ix)
    dec     a
    ld      GROUND_GENERATOR_LOWER_LENGTH(ix), a
    ld      a, #GROUND_GENERATOR_STATE_DOWN
    ld      GROUND_GENERATOR_LOWER_STATE(ix), a
    jr      28$
    
    ; ����^��
25$:
;   cp      #GROUND_GENERATOR_STATE_DOWN
;   jr      nz, 29$
    ld      b, GROUND_GENERATOR_LOWER_HEIGHT(ix)
    dec     b
    ld      a, #0x4f
26$:
    ld      (hl), a
    dec     hl
    djnz    26$
    ld      a, #0x4a
    ld      (hl), a
    dec     GROUND_GENERATOR_LOWER_HEIGHT(ix)
    dec     GROUND_GENERATOR_LOWER_LENGTH(ix)
    jr      nz, 28$
    call    _SystemGetRandom
    and     #0x1f
    add     a, #0x08
    ld      GROUND_GENERATOR_LOWER_LENGTH(ix), a
    ld      a, #GROUND_GENERATOR_STATE_FLAT
    ld      GROUND_GENERATOR_LOWER_STATE(ix), a
;   jr      28$

    ; ���̐����̊���
28$:
29$:
    
    ; ��̓]��
    ld      hl, #(groundGeneratorRow + 0x0001)
    ld      ix, #(_ground + 0x0020)
    ld      de, #0x0020
    ld      b, #0x17
90$:
    ld      a, (hl)
    ld      0(ix), a
    inc     hl
    add     ix, de
    djnz    90$
    
    ; �X�N���[���̊���
99$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �n�ʂ�`�悷��
;
_GroundRender::
    
    ; ���W�X�^�̕ۑ�
    
    ; �p�^�[���l�[���̕`��
    ld      hl, #_ground
    ld      de, #_appPatternName
    ld      bc, #0x0300
    ldir
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �萔�̒�`
;


; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

; �n��
;
_ground::

    .ds     0x0300

; �W�F�l���[�^
;
_groundGenerator::

    .ds     GROUND_GENERATOR_SIZE

groundGeneratorRow:

    .ds     0x18
