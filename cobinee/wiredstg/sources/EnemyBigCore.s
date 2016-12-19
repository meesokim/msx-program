; EnemyBigCore.s : �G�^�r�b�O�R�A
;


; ���W���[���錾
;
    .module Enemy

; �Q�ƃt�@�C��
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include	"Game.inc"
    .include    "Ship.inc"
    .include	"Enemy.inc"

; �}�N���̒�`
;


; CODE �̈�
;
    .area   _CODE

; �G�𐶐�����
;
_EnemyBigCoreGenerate::
    
    ; ���W�X�^�̕ۑ�
    
    ; �W�F�l���[�^�̎擾
    ld      iy, #_enemyGenerator
    
    ; �G�̐����^�R�A
    call    _EnemyGetEmpty
;   jr      c, 09$
    ld      a, #ENEMY_TYPE_BIGCORE_CORE
    ld      ENEMY_TYPE(ix), a
    xor     a
    ld      ENEMY_STATE(ix), a
    ld      a, #0xa0
    ld      ENEMY_POSITION_X(ix), a
    ld      a, #0xe0
    ld      ENEMY_POSITION_Y(ix), a
    ld      a, #0xe
    ld      ENEMY_HP(ix), a
    ld      ENEMY_PARAM_0(ix), a
    
    ; �R�A�̕ۑ�
    push    ix
    
    ; �G�̐����^�{�f�B
    call    _EnemyGetEmpty
;   jr      c, 09$
    ld      a, #ENEMY_TYPE_BIGCORE_BODY
    ld      ENEMY_TYPE(ix), a
    xor     a
    ld      ENEMY_STATE(ix), a
;   ld      a, #0xa0
;   ld      ENEMY_POSITION_X(ix), a
;   ld      a, #0xe0
;   ld      ENEMY_POSITION_Y(ix), a
    ld      a, #0xff
    ld      ENEMY_HP(ix), a
    
    ; �R�A�̎Q�Ƃ̎擾
    pop     hl
    ld      ENEMY_PARAM_0(ix), l
    ld      ENEMY_PARAM_1(ix), h
    
    ; �����̊���
    xor     a
    ld      ENEMY_GENERATOR_TYPE(iy), a
    ld      ENEMY_GENERATOR_STATE(iy), a
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �G���X�V����^�R�A
;
_EnemyBigCoreUpdateCore::
    
    ; ���W�X�^�̕ۑ�
    
    ; �������̊J�n
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$
    
    ; �������̊���
    inc     ENEMY_STATE(ix)
09$:
    
    ; �o��
    ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 19$
    ld      a, ENEMY_POSITION_Y(ix)
    cp      #0x61
    jr      c, 10$
    sub     #0x04
    ld      ENEMY_POSITION_Y(ix), a
    jp      nc, 90$
10$:
    ld      a, ENEMY_POSITION_X(ix)
    cp      #0x39
    jr      c, 11$
    sub     #0x04
    ld      ENEMY_POSITION_X(ix), a
    jp      nc, 90$
11$:
    ld      a, #0x02
    ld      ENEMY_STATE(ix), a
    jp      90$
19$:
    
    ; �r�[��������
    dec     a
    jr      nz, 29$
    ld      h, ENEMY_POSITION_X(ix)
    ld      l, ENEMY_POSITION_Y(ix)
    call    _EnemyBeamGenerate
    ld      a, #0x20
    ld      ENEMY_TIMER(ix), a
    ld      a, #0x03
    ld      ENEMY_STATE(ix), a
    jp      90$
29$:
    
    ; �ҋ@
    dec     a
    jr      nz, 39$
    dec     ENEMY_TIMER(ix)
    jr      nz, 90$
    call    _SystemGetRandom
    and     #0x18
    add     a, #0x18
    ld      c, a
    ld      a, (_ship + SHIP_POSITION_Y)
    ld      b, a
    ld      a, ENEMY_POSITION_Y(ix)
    cp      #0x88
    jr      nc, 30$
    cp      #0x38
    jr      c, 32$
    cp      b
    jr      c, 32$
    jr      nz, 30$
    cp      #0x64
    jr      c, 32$
;   jr      30$
30$:
    sub     c
    cp      #0x28
    jr      nc, 31$
    ld      a, #0x28
31$:
    ld      ENEMY_TIMER(ix), a
    ld      a, #0x04
    ld      ENEMY_STATE(ix), a
    jr      90$
32$:
    add     a, c
    cp      #0x98
    jr      c, 33$
    ld      a, #0x98
33$:
    ld      ENEMY_TIMER(ix), a
    ld      a, #0x05
    ld      ENEMY_STATE(ix), a
    jr      90$
39$:
    
    ; �ړ���
    dec     a
    jr      nz, 49$
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #0x04
    ld      ENEMY_POSITION_Y(ix), a
    cp      ENEMY_TIMER(ix)
    jr      nc, 90$
    ld      a, ENEMY_TIMER(ix)
    ld      ENEMY_POSITION_Y(ix), a
    ld      a, #0x02
    ld      ENEMY_STATE(ix), a
    jr      90$
49$:
    
    ; �ړ���
;   dec     a
;   jr      nz, 59$
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, #0x04
    ld      ENEMY_POSITION_Y(ix), a
    cp      ENEMY_TIMER(ix)
    jr      c, 90$
    ld      a, ENEMY_TIMER(ix)
    ld      ENEMY_POSITION_Y(ix), a
    ld      a, #0x02
    ld      ENEMY_STATE(ix), a
;   jr      90$
59$:
    
    ; �g�o�̊Ď�
90$:
    ld      a, ENEMY_HP(ix)
    cp      ENEMY_PARAM_0(ix)
    jr      z, 91$
    ld      ENEMY_PARAM_0(ix), a
    
    ; �r�d�̍Đ�
    ld      hl, #enemyBigCoreSeHit
    ld      (_soundRequest + 0x0006), hl
91$:
    
    ; �X�V�̊���
;99$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �G���X�V����^�{�f�B
;
_EnemyBigCoreUpdateBody::
    
    ; ���W�X�^�̕ۑ�
    
    ; �������̊J�n
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$
    
    ; �A�j���[�V�����̐ݒ�
    ld      a, #0x0c
    ld      ENEMY_ANIMATION(ix), a
    
    ; �������̊���
    inc     ENEMY_STATE(ix)
09$:
    
    ; �g�o�̍Đݒ�
    ld      a, #0xff
    ld      ENEMY_HP(ix), a
    
    ; �R�A�̎擾
    ld      l, ENEMY_PARAM_0(ix)
    ld      h, ENEMY_PARAM_1(ix)
    push    hl
    pop     iy
    
    ; �R�A�̊Ď�
    ld      a, ENEMY_TYPE(iy)
    cp      #ENEMY_TYPE_BIGCORE_CORE
    jr      nz, 19$
    ld      a, ENEMY_POSITION_X(iy)
    ld      ENEMY_POSITION_X(ix), a
    ld      a, ENEMY_POSITION_Y(iy)
    ld      ENEMY_POSITION_Y(ix), a
    jr      99$
19$:

    ; �A�j���[�V�����̊Ď�
    ld      a, ENEMY_ANIMATION(ix)
    cp      #0x0c
    jr      nz, 20$
    
    ; �r�d�̍Đ�
    ld      hl, #enemyBigCoreSeBomb
    ld      (_soundRequest + 0x0006), hl
20$:
    
    ; �A�j���[�V�����̍X�V
    dec     ENEMY_ANIMATION(ix)
    jr      nz, 99$
    
    ; �G�̍폜
    xor     a
    ld      ENEMY_TYPE(ix), a

    ; �X�V�̊���
99$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �G��`�悷��^�R�A
;
_EnemyBigCoreRenderCore::
    
    ; ���W�X�^�̕ۑ�
    
    ; �ʒu�̎擾
    ld      a, ENEMY_POSITION_Y(ix)
    and     #0xf8
    ld      b, #0x00
    add     a, a
    rl      b
    add     a, a
    rl      b
    ld      c, ENEMY_POSITION_X(ix)
    srl     c
    srl     c
    srl     c
    add     a, c
    sub     #0x06
    ld      c, a
    
    ; �p�^�[����u��
    ld      a, ENEMY_POSITION_Y(ix)
    cp      #0xc0
    jr      nc, 19$
    ld      hl, #_appPatternName
    add     hl, bc
    ex      de, hl
    ld      iy, #_enemyCollision
    add     iy, bc
    ld      a, ENEMY_HP(ix)
    add     a, #0x01
    rla
    rla
    rla
    and     #0xf0
    ld      c, a
    ld      b, #0x00
    ld      hl, #enemyBigCoreCorePatternName
    add     hl, bc
    ld      c, ENEMY_INDEX(ix)
    ld      b, #0x0c
10$:
    ld      a, (hl)
    or      a
    jr      z, 11$
    ld      (de), a
    ld      0(iy), c
11$:
    inc     hl
    inc     de
    inc     iy
    djnz    10$
19$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret
    
; �G��`�悷��^�{�f�B
;
_EnemyBigCoreRenderBody::
    
    ; ���W�X�^�̕ۑ�
    
    ; �ʒu�̎擾
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #0x20
    and     #0xf8
    ld      b, #0x00
    add     a, a
    rl      b
    add     a, a
    rl      b
    ld      c, ENEMY_POSITION_X(ix)
    srl     c
    srl     c
    srl     c
    add     a, c
    sub     #0x06
    ld      c, a
    
    ; �p�^�[����u��
    ld      hl, #_appPatternName
    add     hl, bc
    ex      de, hl
    ld      iy, #_enemyCollision
    add     iy, bc
    ld      hl, #enemyBigCoreBodyPatternName
    ld      c, ENEMY_INDEX(ix)
    ld      b, ENEMY_POSITION_Y(ix)
    srl     b
    srl     b
    srl     b
    ld      a, #0x1b
    sub     b
    jr      c, 19$
    inc     a
    cp      #0x09
    jr      c, 10$
    ld      a, #0x09
10$:
    ld      b, a
11$:
    push    bc
    ld      b, ENEMY_ANIMATION(ix)
12$:
    ld      a, (hl)
    or      a
    jr      z, 13$
    ld      (de), a
    ld      0(iy), c
13$:
    inc     hl
    inc     de
    inc     iy
    djnz    12$
    ld      a, #0x0c
    sub     ENEMY_ANIMATION(ix)
    ld      c, a
;   ld      b, #0x00
    add     hl, bc
    add     a, #0x14
    ld      c, a
    ex      de, hl
    add     hl, bc
    ex      de, hl
    add     iy, bc
    pop     bc
    djnz    11$
19$:

    ; ���W�X�^�̕��A
    
    ; �I��
    ret
    
; �萔�̒�`
;

; �p�^�[���l�[��
;
enemyBigCoreCorePatternName:

    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0xb1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0xb1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0xb1, 0x00, 0xb3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0xb1, 0x00, 0xb2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0xb1, 0x00, 0xb2, 0xb3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0xb1, 0x00, 0xb2, 0xb2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0xb1, 0x00, 0xb2, 0xb2, 0xb3, 0x00, 0x00, 0x00, 0x00, 0x00

enemyBigCoreBodyPatternName:

    .db     0x00, 0x00, 0x60, 0x00, 0x00, 0x61, 0x62, 0x63, 0x00, 0x00, 0x00, 0x00
    .db     0x64, 0x65, 0x66, 0x67, 0x68, 0xa0, 0x69, 0x6a, 0x6b, 0x00, 0x00, 0x00
    .db     0x6c, 0x6d, 0x6e, 0x6f, 0xa0, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x00
    .db     0x76, 0x77, 0x78, 0xa0, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7e, 0x7f
    .db     0xa1, 0xa2, 0xa3, 0xa0, 0xa4, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x86, 0x87, 0x88, 0xa0, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8e, 0x8f
    .db     0x9c, 0x9d, 0x9e, 0x9f, 0xa0, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x00
    .db     0x94, 0x95, 0x96, 0x97, 0x98, 0xa0, 0x99, 0x9a, 0x9b, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x90, 0x00, 0x00, 0x91, 0x92, 0x93, 0x00, 0x00, 0x00, 0x00

; �r�d
;
enemyBigCoreSeHit:

    .ascii  "T1V15-L0O7A"
    .db     0x00

enemyBigCoreSeBomb:

    .ascii  "T1V15L0"
    .ascii  "O3GO2D-O3EO2D-O3CO2D-O2GD-ED-"
    .ascii  "O2CO1D-O2D-O1CO2CO1D-O2D-O1CO2CO1D-O2D-O1CO2CO1D-O2D-O1C"
    .db     0x00


; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

