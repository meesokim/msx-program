; EnemyBomb.s : �G�^����
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
    .include	"Enemy.inc"
    .include    "Bullet.inc"

; �}�N���̒�`
;


; CODE �̈�
;
    .area   _CODE

; �G�𐶐�����
;
_EnemyBombGenerate::
    
    ; ���W�X�^�̕ۑ�
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �G���X�V����
;
_EnemyBombUpdate::
    
    ; ���W�X�^�̕ۑ�
    
    ; �������̊J�n
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$
    
    ; �A�j���[�V�����̐ݒ�
    ld      a, #0x40
    ld      ENEMY_ANIMATION(ix), a
    
    ; �^�C�}�̐ݒ�
    ld      a, #0x02
    ld      ENEMY_TIMER(ix), a
    
    ; �����Ԃ�
    ld      h, ENEMY_POSITION_X(ix)
    ld      l, ENEMY_POSITION_Y(ix)
    call    _BulletGenerate

    ; �r�d�̍Đ�
    ld      hl, #enemyBombSe
    ld      (_soundRequest + 0x0006), hl
    
    ; �������̊���
    inc     ENEMY_STATE(ix)
09$:
    
    ; �A�j���[�V�����̍X�V
90$:
    dec     ENEMY_TIMER(ix)
    jr      nz, 99$
    ld      a, ENEMY_ANIMATION(ix)
    add     a, #0x02
    cp      #0x46
    jr      nc, 98$
    ld      ENEMY_ANIMATION(ix), a
    ld      a, #0x02
    ld      ENEMY_TIMER(ix), a
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

; �G��`�悷��
;
_EnemyBombRender::
    
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
    ld      a, ENEMY_ANIMATION(ix)
    ld      b, ENEMY_INDEX(ix)
    rr      c
    jr      nc, 10$
    ld      (hl), a
10$:
    inc     hl
    inc     a
    rr      c
    jr      nc, 11$
    ld      (hl), a
11$:
    ld      de, #0x001f
    add     hl, de
    add     a, #0x0f
    rr      c
    jr      nc, 12$
    ld      (hl), a
12$:
    inc     hl
    inc     a
    rr      c
    jr      nc, 13$
    ld      (hl), a
13$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �萔�̒�`
;

; �r�d
;
enemyBombSe:

    .ascii  "T1V15L0O4GFEDCO3BAG"
    .db     0x00

; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

