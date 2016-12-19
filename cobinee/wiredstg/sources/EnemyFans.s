; EnemyFans.s : �G�^�t�@��
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

; �G�𐶐�����
;
_EnemyFansGenerate::
    
    ; ���W�X�^�̕ۑ�
    
    ; �W�F�l���[�^�̎擾
    ld      iy, #_enemyGenerator
    
    ; �������̊J�n
    ld      a, ENEMY_GENERATOR_STATE(iy)
    or      a
    jr      nz, 09$
    
    ; �������̐ݒ�
    call    _SystemGetRandom
    and     #0x01
    add     a, a
    add     a, #0x04
    ld      ENEMY_GENERATOR_LENGTH(iy), a
    
    ; �^�C�}�̐ݒ�
    ld      a, #0x01
    ld      ENEMY_GENERATOR_TIMER(iy), a
    
    ; �p�����[�^�̐ݒ�
    ld      a, ENEMY_GENERATOR_TYPE(iy)
    cp      #ENEMY_TYPE_FANS_BACK
    ld      a, #0xff
    adc     a, #0x00
    ld      ENEMY_GENERATOR_PARAM_0(iy), a
    call    _SystemGetRandom
    and     #0x80
    add     a, #0x20
    ld      ENEMY_GENERATOR_PARAM_1(iy), a
    
    ; �������̊���
    inc     ENEMY_GENERATOR_STATE(iy)
09$:
    
    ; �^�C�}�̍X�V
    dec     ENEMY_GENERATOR_TIMER(iy)
    jr      nz, 19$
    ld      a, #0x04
    ld      ENEMY_GENERATOR_TIMER(iy), a
    
    ; �����̊J�n
    call    _EnemyGetEmpty
    jr      c, 19$
    
    ; �G�̐���
    ld      a, ENEMY_GENERATOR_TYPE(iy)
    ld      ENEMY_TYPE(ix), a
    xor     a
    ld      ENEMY_STATE(ix), a
    ld      a, ENEMY_GENERATOR_PARAM_0(iy)
    ld      ENEMY_POSITION_X(ix), a
    ld      a, ENEMY_GENERATOR_PARAM_1(iy)
    ld      ENEMY_POSITION_Y(ix), a
    ld      a, #0x01
    ld      ENEMY_HP(ix), a
    
    ; �������̍X�V
    dec     ENEMY_GENERATOR_LENGTH(iy)
    jr      nz, 19$
    
    ; �����̊���
    xor     a
    ld      ENEMY_GENERATOR_TYPE(iy), a
    ld      ENEMY_GENERATOR_STATE(iy), a
19$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �G���X�V����
;
_EnemyFansUpdate::
    
    ; ���W�X�^�̕ۑ�
    
    ; �������̊J�n
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$
    
    ; �V���b�g�̐ݒ�
    call    _SystemGetRandom
    and     #0x1f
    add     #0x08
    ld      ENEMY_SHOT(ix), a
    
    ; �A�j���[�V�����̐ݒ�
    ld      a, #0x60
    ld      ENEMY_ANIMATION(ix), a
    
    ; �^�C�}�̐ݒ�
    ld      a, #0x04
    ld      ENEMY_TIMER(ix), a
    
    ; �������̊���
    inc     ENEMY_STATE(ix)
09$:
    
    ; �ړ�
    ld      a, ENEMY_TYPE(ix)
    cp      #ENEMY_TYPE_FANS_FRONT
    jr      nz, 10$
    call    EnemyFansFrontMove
    jr      19$
10$:
    call    EnemyFansBackMove
19$:

    ; �V���b�g�̍X�V
90$:
    dec     ENEMY_SHOT(ix)
    jr      nz, 91$
    ld      h, ENEMY_POSITION_X(ix)
    ld      l, ENEMY_POSITION_Y(ix)
    call    _BulletGenerate
    call    _SystemGetRandom
    and     #0x1f
    add     #0x30
    ld      ENEMY_SHOT(ix), a

    ; �A�j���[�V�����̍X�V
91$:
    dec     ENEMY_TIMER(ix)
    jr      nz, 99$
    ld      a, ENEMY_ANIMATION(ix)
    add     a, #0x02
    cp      #0x66
    jr      c, 92$
    ld      a, #0x60
92$:
    ld      ENEMY_ANIMATION(ix), a
    ld      a, #0x04
    ld      ENEMY_TIMER(ix), a
    jr      99$
    
    ; �X�V�̊���
99$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �G���ړ�����^��
;
EnemyFansFrontMove:
    
    ; ���W�X�^�̕ۑ�
    
    ; �ړ��i���j
    ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 19$
    ld      a, ENEMY_POSITION_X(ix)
    add     a, #0x04
    jp      c, 98$
    ld      ENEMY_POSITION_X(ix), a
    cp      #0xd0
    jr      c, 99$
    ld      a, (_ship + SHIP_POSITION_Y)
    cp      ENEMY_POSITION_Y(ix)
    ld      a, #0x02
    adc     a, #0x00
    ld      ENEMY_STATE(ix), a
    jr      99$
19$:
    
    ; �ړ��i���j
;   ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 29$
    ld      a, ENEMY_POSITION_X(ix)
    sub     #0x04
    jr      c, 98$
    ld      ENEMY_POSITION_X(ix), a
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, #0x04
    cp      #0xc0
    jr      nc, 98$
    ld      ENEMY_POSITION_Y(ix), a
    ld      b, a
    ld      a, (_ship + SHIP_POSITION_Y)
    cp      b
    jr      nc, 99$
    ld      a, #0x04
    ld      ENEMY_STATE(ix), a
    jr      99$
29$:

    ; �ړ��i���j
;   ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 39$
    ld      a, ENEMY_POSITION_X(ix)
    sub     #0x04
    jr      c, 98$
    ld      ENEMY_POSITION_X(ix), a
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #0x04
    jr      c, 98$
    ld      ENEMY_POSITION_Y(ix), a
    ld      b, a
    ld      a, (_ship + SHIP_POSITION_Y)
    cp      b
    jr      c, 99$
    ld      a, #0x04
    ld      ENEMY_STATE(ix), a
    jr      99$
39$:

    ; �ړ��i���j
;   ld      a, ENEMY_STATE(ix)
;   dec     a
;   jr      nz, 49$
    ld      a, ENEMY_POSITION_X(ix)
    sub     #0x04
    jr      c, 98$
    ld      ENEMY_POSITION_X(ix), a
    jr      99$
49$:
    
    ; �G�̍폜
98$:
    xor     a
    ld      ENEMY_TYPE(ix), a
    
    ; �ړ��̊���
99$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �G���ړ�����^��
;
EnemyFansBackMove:
    
    ; ���W�X�^�̕ۑ�
    
    ; �ړ��i���j
    ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 19$
    ld      a, ENEMY_POSITION_X(ix)
    sub     #0x04
    ld      ENEMY_POSITION_X(ix), a
    cp      #0x30
    jp      nc, 99$
    ld      a, (_ship + SHIP_POSITION_Y)
    cp      ENEMY_POSITION_Y(ix)
    ld      a, #0x02
    adc     a, #0x00
    ld      ENEMY_STATE(ix), a
    jr      99$
19$:
    
    ; �ړ��i���j
;   ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 29$
    ld      a, ENEMY_POSITION_X(ix)
    add     a, #0x04
    jr      c, 98$
    ld      ENEMY_POSITION_X(ix), a
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, #0x04
    cp      #0xc0
    jr      nc, 98$
    ld      ENEMY_POSITION_Y(ix), a
    ld      b, a
    ld      a, (_ship + SHIP_POSITION_Y)
    cp      b
    jr      nc, 99$
    ld      a, #0x04
    ld      ENEMY_STATE(ix), a
    jr      99$
29$:

    ; �ړ��i���j
;   ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 39$
    ld      a, ENEMY_POSITION_X(ix)
    add     a, #0x04
    jr      c, 98$
    ld      ENEMY_POSITION_X(ix), a
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #0x04
    jr      c, 98$
    ld      ENEMY_POSITION_Y(ix), a
    ld      b, a
    ld      a, (_ship + SHIP_POSITION_Y)
    cp      b
    jr      c, 99$
    ld      a, #0x04
    ld      ENEMY_STATE(ix), a
    jr      99$
39$:

    ; �ړ��i���j
;   ld      a, ENEMY_STATE(ix)
;   dec     a
;   jr      nz, 49$
    ld      a, ENEMY_POSITION_X(ix)
    add     a, #0x04
    jr      c, 98$
    ld      ENEMY_POSITION_X(ix), a
    jr      99$
49$:
    
    ; �G�̍폜
98$:
    xor     a
    ld      ENEMY_TYPE(ix), a
    
    ; �ړ��̊���
99$:
    
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

