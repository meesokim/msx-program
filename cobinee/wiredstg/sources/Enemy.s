; Enemy.s : �G
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
    .include    "Bullet.inc"

; �}�N���̒�`
;


; CODE �̈�
;
    .area   _CODE

; �G������������
;
_EnemyInitialize::
    
    ; ���W�X�^�̕ۑ�
    
    ; �G�̏�����
    ld      hl, #(_enemy + 0x0000)
    ld      de, #(_enemy + 0x0001)
    ld      bc, #(ENEMY_SIZE * ENEMY_N - 1)
    xor     a
    ld      (hl), a
    ldir
    ld      hl, #(_enemy + ENEMY_INDEX)
    ld      de, #ENEMY_SIZE
    ld      b, #ENEMY_N
    ld      a, #0x01
0$:
    ld      (hl), a
    add     hl, de
    inc     a
    djnz    0$
    ld      a, #0x07
    ld      (_enemyN), a
    
    ; �W�F�l���[�^�̏�����
    ld      hl, #(_enemyGenerator + 0x0000)
    ld      de, #(_enemyGenerator + 0x0001)
    ld      bc, #(ENEMY_GENERATOR_SIZE)
    xor     a
    ld      (hl), a
    ldir
    ld      a, #ENEMY_PHASE_NORMAL
    ld      (_enemyGenerator + ENEMY_GENERATOR_PHASE), a
    
    ; �R���W�����̏�����
    ld      hl, #(_enemyCollision + 0x0000)
    ld      de, #(_enemyCollision + 0x0001)
    ld      bc, #0x02ff
    xor     a
    ld      (hl), a
    ldir
    
    ; �p�^�[���W�F�l���[�^�̐ݒ�
    ld      a, #(APP_PATTERN_GENERATOR_TABLE_1 >> 11)
    ld      (_videoRegister + VDP_R4), a
    
    ; �r�f�I���W�X�^�̓]��
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �G���X�V����
;
_EnemyUpdate::
    
    ; ���W�X�^�̕ۑ�
    
    ; �R���W�����̏�����
    ld      hl, #(_enemyCollision + 0x0000)
    ld      de, #(_enemyCollision + 0x0001)
    ld      bc, #0x02ff
    xor     a
    ld      (hl), a
    ldir
    
    ; �G�̐���
    ld      hl, #19$
    push    hl
    ld      a, (_enemyGenerator + ENEMY_GENERATOR_TYPE)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyGenerateProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
19$:
    
    ; �G�̍X�V
    ld      ix, #_enemy
    ld      a, (_enemyN)
    ld      b, a
20$:
    ld      hl, #21$
    push    bc
    push    hl
    ld      a, ENEMY_TYPE(ix)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyUpdateProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
21$:
    pop     bc
    ld      de, #ENEMY_SIZE
    add     ix, de
    djnz    20$
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �G��`�悷��
;
_EnemyRender::
    
    ; ���W�X�^�̕ۑ�
    
    ; ��ޕʂ̕`��
    ld      ix, #_enemy
    ld      a, (_enemyN)
    ld      b, a
10$:
    ld      hl, #11$
    push    bc
    push    hl
    ld      a, ENEMY_TYPE(ix)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyRenderProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
11$:
    pop     bc
    ld      de, #ENEMY_SIZE
    add     ix, de
    djnz    10$
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; ENEMY_TYPE_NULL �𐶐�����
;
EnemyNullGenerate:
    
    ; ���W�X�^�̕ۑ�
    
    ; �W�F�l���[�^�̎擾
    ld      iy, #_enemyGenerator
    
    ; �ʏ��̊J�n
    ld      a, ENEMY_GENERATOR_PHASE(iy)
    dec     a
    jr      nz, 19$
    
    ; �ʏ��̏�����
    ld      a, ENEMY_GENERATOR_STATE(iy)
    or      a
    jr      nz, 10$
    ld      a, #0x08
    ld      ENEMY_GENERATOR_TIMER(iy), a
    inc     ENEMY_GENERATOR_STATE(iy)
10$:
    
    ; �{�X�o��̏���
    ld      hl, (_ship + SHIP_SHOT_L)
    ld      de, #0x0100
    or      a
    sbc     hl, de
    jr      nc, 18$

    ; �^�C�}�̍X�V
    dec     ENEMY_GENERATOR_TIMER(iy)
    jp      nz, 99$
    
    ; �G�̐���
    xor     a
    ld      ENEMY_GENERATOR_STATE(iy), a
    call    _SystemGetRandom
    rra
    rra
    and     #0x1f
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyGenerateType
    add     hl, de
    ld      a, (hl)
    ld      ENEMY_GENERATOR_TYPE(iy), a
    jp      99$
    
    ; �ʏ��̊���
18$:
    ld      a, #ENEMY_PHASE_WARNING
    ld      ENEMY_GENERATOR_PHASE(iy), a
    xor     a
    ld      ENEMY_GENERATOR_STATE(iy), a
    jp      99$
19$:
    
    ; �x���̊J�n
    dec     a
    jr      nz, 29$
    
    ; �x���̏�����
    ld      a, ENEMY_GENERATOR_STATE(iy)
    or      a
    jr      nz, 20$
    ld      a, #0x30
    ld      ENEMY_GENERATOR_TIMER(iy), a
    inc     ENEMY_GENERATOR_STATE(iy)
20$:
    
    ; �G�̊Ď�
    ld      hl, #(_enemy + ENEMY_TYPE)
    ld      de, #ENEMY_SIZE
    ld      a, (_enemyN)
    ld      b, a
    xor     a
21$:
    or      (hl)
    add     hl, de
    djnz    21$
    or      a
    jr      nz, 99$
    
    ; �^�C�}�̍X�V
    dec     ENEMY_GENERATOR_TIMER(iy)
    jr      nz, 99$
    
    ; �r�b�O�R�A�̐���
    ld      a, #ENEMY_TYPE_BIGCORE_CORE
    ld      ENEMY_GENERATOR_TYPE(iy), a
    xor     a
    ld      ENEMY_GENERATOR_STATE(iy), a
    
    ; �p�^�[���W�F�l���[�^�̐ݒ�
    ld      a, #(APP_PATTERN_GENERATOR_TABLE_2 >> 11)
    ld      (_videoRegister + VDP_R4), a
    
    ; �r�f�I���W�X�^�̓]��
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; �x���̊���
    ld      a, #ENEMY_PHASE_BOSS
    ld      ENEMY_GENERATOR_PHASE(iy), a
    xor     a
    ld      ENEMY_GENERATOR_STATE(iy), a
    jr      99$
29$:
    
    ; �{�X��̊J�n
    dec     a
    jr      nz, 39$
    
    ; �{�X��̏�����
    ld      a, ENEMY_GENERATOR_STATE(iy)
    or      a
    jr      nz, 30$
    ld      a, #0x60
    ld      ENEMY_GENERATOR_TIMER(iy), a
    inc     ENEMY_GENERATOR_STATE(iy)
30$:
    
    ; �{�X�̊Ď�
    ld      hl, #(_enemy + ENEMY_TYPE)
    ld      de, #ENEMY_SIZE
    ld      a, (_enemyN)
    ld      b, a
    ld      a, #ENEMY_TYPE_BIGCORE_BODY
31$:
    cp      (hl)
    jr      z, 99$
    add     hl, de
    djnz    31$
    
    ; �^�C�}�̍X�V
    dec     ENEMY_GENERATOR_TIMER(iy)
    jr      nz, 99$
    
    ; ���@�̃��Z�b�g
    ld      hl, #0x0000
    ld      (_ship + SHIP_SHOT_L), hl
    
    ; �G�̑���
    ld      hl, #_enemyN
    ld      a, (hl)
    add     a, #0x03
    cp      #ENEMY_N
    jr      c, 32$
    ld      a, #ENEMY_N
32$:
    ld      (hl), a
    
    ; �e�̑���
    ld      hl, #_bulletN
    ld      a, (hl)
    add     a, #0x03
    cp      #BULLET_N
    jr      c, 33$
    ld      a, #BULLET_N
33$:
    ld      (hl), a
    
    ; �p�^�[���W�F�l���[�^�̐ݒ�
    ld      a, #(APP_PATTERN_GENERATOR_TABLE_1 >> 11)
    ld      (_videoRegister + VDP_R4), a
    
    ; �r�f�I���W�X�^�̓]��
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; �{�X��̊���
    ld      a, #ENEMY_PHASE_NORMAL
    ld      ENEMY_GENERATOR_PHASE(iy), a
    xor     a
    ld      ENEMY_GENERATOR_STATE(iy), a
;   jr      99$
39$:

    ; �����̊���
99$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; ENEMY_TYPE_NULL ���X�V����
;
EnemyNullUpdate:
    
    ; ���W�X�^�̕ۑ�
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; ENEMY_TYPE_NULL ��`�悷��
;
EnemyNullRender:
    
    ; ���W�X�^�̕ۑ�
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; ��̓G���擾����
;
_EnemyGetEmpty::
    
    ; ���W�X�^�̕ۑ�
    
    ; ��̓G�̎擾
    ld      ix, #_enemy
    ld      de, #ENEMY_SIZE
    ld      a, (_enemyN)
    ld      b, a
0$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 9$
    add     ix, de
    djnz    0$
    ld      ix, #0x0000
    scf
9$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; 16x16 �T�C�Y�̃p�^�[����u��
;
EnemyPutPattern16x16:
    
    ; ���W�X�^�̕ۑ�
    
    ; �N���b�s���O�̎擾
    ld      c, #0b00001111
    ld      a, ENEMY_POSITION_Y(ix)
    cp      #0x08
    jr      nc, 00$
    res     #0, c
    res     #1, c
00$:
    cp      #0xc0
    jr      c, 01$
    res     #2, c
    res     #3, c
01$:
    ld      a, ENEMY_POSITION_X(ix)
    cp      #0x08
    jr      nc, 02$
    res     #0, c
    res     #2, c
02$:
    
    ; �p�^�[����u��
    ld      a, ENEMY_POSITION_Y(ix)
    and     #0xf8
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, ENEMY_POSITION_X(ix)
    srl     e
    srl     e
    srl     e
    add     a, e
    ld      e, a
    ld      hl, #(_appPatternName - 0x0021)
    add     hl, de
    ld      iy, #(_enemyCollision - 0x0021)
    add     iy, de
    ld      a, ENEMY_ANIMATION(ix)
    ld      b, ENEMY_INDEX(ix)
    rr      c
    jr      nc, 10$
    ld      (hl), a
    ld      0(iy), b
10$:
    inc     hl
    inc     iy
    inc     a
    rr      c
    jr      nc, 11$
    ld      (hl), a
    ld      0(iy), b
11$:
    ld      de, #0x001f
    add     hl, de
    add     iy, de
    add     a, #0x0f
    rr      c
    jr      nc, 12$
    ld      (hl), a
    ld      0(iy), b
12$:
    inc     hl
    inc     iy
    inc     a
    rr      c
    jr      nc, 13$
    ld      (hl), a
    ld      0(iy), b
13$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �萔�̒�`
;

; �W�F�l���[�^
;
enemyGenerateProc:

    .dw     EnemyNullGenerate
    .dw     EnemyNullGenerate
    .dw     _EnemyFansGenerate
    .dw     _EnemyFansGenerate
    .dw     _EnemyRugalGenerate
    .dw     _EnemyRugalGenerate
    .dw     _EnemyGarunGenerate
    .dw     _EnemyGarunGenerate
    .dw     _EnemyDee01Generate
    .dw     _EnemyDee01Generate
    .dw     _EnemyDuckerGenerate
    .dw     _EnemyDuckerGenerate
    .dw     _EnemyBigCoreGenerate
    .dw     0x0000
    .dw     _EnemyBeamGenerate

enemyGenerateType:

    .db     ENEMY_TYPE_FANS_FRONT
    .db     ENEMY_TYPE_FANS_FRONT
    .db     ENEMY_TYPE_FANS_FRONT
    .db     ENEMY_TYPE_FANS_FRONT
    .db     ENEMY_TYPE_FANS_FRONT
    .db     ENEMY_TYPE_FANS_BACK
    .db     ENEMY_TYPE_RUGAL_FRONT
    .db     ENEMY_TYPE_RUGAL_FRONT
    .db     ENEMY_TYPE_RUGAL_FRONT
    .db     ENEMY_TYPE_RUGAL_FRONT
    .db     ENEMY_TYPE_RUGAL_FRONT
    .db     ENEMY_TYPE_RUGAL_BACK
    .db     ENEMY_TYPE_GARUN_FRONT
    .db     ENEMY_TYPE_GARUN_FRONT
    .db     ENEMY_TYPE_GARUN_FRONT
    .db     ENEMY_TYPE_GARUN_FRONT
    .db     ENEMY_TYPE_GARUN_FRONT
    .db     ENEMY_TYPE_GARUN_FRONT
    .db     ENEMY_TYPE_GARUN_FRONT
    .db     ENEMY_TYPE_GARUN_BACK
    .db     ENEMY_TYPE_DEE01_UPPER
    .db     ENEMY_TYPE_DEE01_UPPER
    .db     ENEMY_TYPE_DEE01_UPPER
    .db     ENEMY_TYPE_DEE01_UPPER
    .db     ENEMY_TYPE_DEE01_LOWER
    .db     ENEMY_TYPE_DEE01_LOWER
    .db     ENEMY_TYPE_DEE01_LOWER
    .db     ENEMY_TYPE_DEE01_LOWER
    .db     ENEMY_TYPE_DUCKER_UPPER
    .db     ENEMY_TYPE_DUCKER_UPPER
    .db     ENEMY_TYPE_DUCKER_LOWER
    .db     ENEMY_TYPE_DUCKER_LOWER

; �X�V
;
enemyUpdateProc:

    .dw     EnemyNullUpdate
    .dw     _EnemyBombUpdate
    .dw     _EnemyFansUpdate
    .dw     _EnemyFansUpdate
    .dw     _EnemyRugalUpdate
    .dw     _EnemyRugalUpdate
    .dw     _EnemyGarunUpdate
    .dw     _EnemyGarunUpdate
    .dw     _EnemyDee01Update
    .dw     _EnemyDee01Update
    .dw     _EnemyDuckerUpdate
    .dw     _EnemyDuckerUpdate
    .dw     _EnemyBigCoreUpdateCore
    .dw     _EnemyBigCoreUpdateBody
    .dw     _EnemyBeamUpdate

; �`��
;
enemyRenderProc:

    .dw     EnemyNullRender
    .dw     _EnemyBombRender
    .dw     EnemyPutPattern16x16
    .dw     EnemyPutPattern16x16
    .dw     EnemyPutPattern16x16
    .dw     EnemyPutPattern16x16
    .dw     EnemyPutPattern16x16
    .dw     EnemyPutPattern16x16
    .dw     EnemyPutPattern16x16
    .dw     EnemyPutPattern16x16
    .dw     EnemyPutPattern16x16
    .dw     EnemyPutPattern16x16
    .dw     _EnemyBigCoreRenderCore
    .dw     _EnemyBigCoreRenderBody
    .dw     _EnemyBeamRender


; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

; �G
;
_enemy::

    .ds     ENEMY_SIZE * ENEMY_N

_enemyN::

    .ds     1

; �W�F�l���[�^
;
_enemyGenerator::

    .ds     ENEMY_GENERATOR_SIZE
    
; �R���W����
;
_enemyCollision::

    .ds     0x0300
