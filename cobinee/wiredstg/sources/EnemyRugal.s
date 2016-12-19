; EnemyRugal.s : �G�^���O��
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
_EnemyRugalGenerate::
    
    ; ���W�X�^�̕ۑ�
    
    ; �W�F�l���[�^�̎擾
    ld      iy, #_enemyGenerator
    
    ; �������̊J�n
    ld      a, ENEMY_GENERATOR_STATE(iy)
    or      a
    jr      nz, 09$
    
    ; �������̐ݒ�
    ld      a, #0x03
    ld      ENEMY_GENERATOR_LENGTH(iy), a
    
    ; �^�C�}�̐ݒ�
    ld      a, #0x01
    ld      ENEMY_GENERATOR_TIMER(iy), a
    
    ; �p�����[�^�̐ݒ�
    ld      a, ENEMY_GENERATOR_TYPE(iy)
    cp      #ENEMY_TYPE_RUGAL_BACK
    ld      a, #0xff
    adc     a, #0x00
    ld      ENEMY_GENERATOR_PARAM_0(iy), a
    
    ; �������̊���
    inc     ENEMY_GENERATOR_STATE(iy)
09$:
    
    ; �^�C�}�̍X�V
    dec     ENEMY_GENERATOR_TIMER(iy)
    jr      nz, 19$
    ld      a, #0x10
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
    call    _SystemGetRandom
    and     #0x07
    add     a, a
    add     a, a
    add     a, a
    ld      c, a
    add     a, a
    add     a, c
    add     a, #0x20
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
_EnemyRugalUpdate::
    
    ; ���W�X�^�̕ۑ�
    
    ; �������̊J�n
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$
    
    ; �p�����[�^�̐ݒ�
    xor     a
    ld      ENEMY_PARAM_0(ix), a
    ld      a, ENEMY_TYPE(ix)
    sub     #ENEMY_TYPE_RUGAL_FRONT
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, #0x68
    ld      ENEMY_PARAM_1(ix), a
    
    ; �V���b�g�̐ݒ�
    call    _SystemGetRandom
    and     #0x3f
    add     #0x40
    ld      ENEMY_SHOT(ix), a
    
    ; �A�j���[�V�����̐ݒ�
    ld      a, ENEMY_PARAM_1(ix)
    ld      ENEMY_ANIMATION(ix), a
    
    ; �^�C�}�̐ݒ�
    ld      a, #0x40
    ld      ENEMY_TIMER(ix), a
    
    ; �������̊���
    inc     ENEMY_STATE(ix)
09$:
    
    ; �ړ�
    ld      a, ENEMY_TYPE(ix)
    cp      #ENEMY_TYPE_RUGAL_FRONT
    ld      a, ENEMY_POSITION_X(ix)
    jr      nz, 10$
    inc     a
    jr      z, 98$
    jr      11$
10$:
    or      a
    jr      z, 98$
    dec     a
11$:
    ld      ENEMY_POSITION_X(ix), a
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, ENEMY_PARAM_0(ix)
    cp      #0xc0
    jr      nc, 98$
    ld      ENEMY_POSITION_Y(ix), a
    
    ; �����]��
    dec     ENEMY_TIMER(ix)
    jr      nz, 29$
    ld      a, (_ship + SHIP_POSITION_Y)
    sub     ENEMY_POSITION_Y(ix)
    jr      nc, 20$
    cp      #0xf8
    ld      a, #0x00
    sbc     #0x00
    jr      21$
20$:
    cp      #0x08
    ld      a, #0x01
    sbc     #0x00
21$:
    ld      ENEMY_PARAM_0(ix), a
    add     a, a
    add     a, ENEMY_PARAM_1(ix)
    ld      ENEMY_ANIMATION(ix), a
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x10
    ld      ENEMY_TIMER(ix), a
29$:

    ; �V���b�g�̍X�V
90$:
    dec     ENEMY_SHOT(ix)
    jr      nz, 99$
    ld      h, ENEMY_POSITION_X(ix)
    ld      l, ENEMY_POSITION_Y(ix)
    call    _BulletGenerate
    call    _SystemGetRandom
    and     #0x3f
    add     #0x40
    ld      ENEMY_SHOT(ix), a
    jr      99$
    
    ; �G�̍폜
98$:
    xor     a
    ld      ENEMY_TYPE(ix), a
    
    ; �X�V�̊���
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

