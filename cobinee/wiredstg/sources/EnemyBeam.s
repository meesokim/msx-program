; EnemyBeam.s : �G�^�r�[��
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

; �}�N���̒�`
;


; CODE �̈�
;
    .area   _CODE

; �G�𐶐�����
;
_EnemyBeamGenerate::
    
    ; ���W�X�^�̕ۑ�
    push    ix
    
    ; �G�̐���
    call    _EnemyGetEmpty
    jr      c, 09$
    ld      a, #ENEMY_TYPE_BEAM
    ld      ENEMY_TYPE(ix), a
    xor     a
    ld      ENEMY_STATE(ix), a
    ld      a, #0x18
    add     a, h
    ld      ENEMY_POSITION_X(ix), a
    ld      a, #0xe8
    add     a, l
    ld      ENEMY_POSITION_Y(ix), a
    ld      a, #0xff
    ld      ENEMY_HP(ix), a
    
    ; �����̊���
09$:
    
    ; ���W�X�^�̕��A
    pop     ix
    
    ; �I��
    ret

; �G���X�V����
;
_EnemyBeamUpdate::
    
    ; ���W�X�^�̕ۑ�
    
    ; �������̊J�n
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$
    
    ; �V���b�g�̐ݒ�
    xor     a
    ld      ENEMY_SHOT(ix), a
    
    ; �������̊���
    inc     ENEMY_STATE(ix)
09$:
    
    ; �g�o�̍Đݒ�
    ld      a, #0xff
    ld      ENEMY_HP(ix), a
    
    ; �V���b�g�̍X�V
    ld      a, ENEMY_SHOT(ix)
    cp      #0x04
    jr      nc, 19$
    inc     ENEMY_SHOT(ix)
    jr      99$
19$:
    
    ; �ړ�
    ld      a, ENEMY_POSITION_X(ix)
    add     a, #0x08
    ld      ENEMY_POSITION_X(ix), a
    jr      nc, 99$
    
    ; �G�̍폜
    xor     a
    ld      ENEMY_TYPE(ix), a
    
    ; �X�V�̊���
99$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �G��`�悷��
;
_EnemyBeamRender::
    
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
    ld      e, c
    add     a, c
    ld      c, a
    ld      ENEMY_PARAM_0(ix), c
    ld      ENEMY_PARAM_1(ix), b
    
    ; �����̎擾
    ld      a, #0x20
    sub     e
    cp      #0x04
    jr      c, 00$
    ld      a, ENEMY_SHOT(ix)
00$:
    ld      ENEMY_PARAM_2(ix), a
    ld      a, #0x1d
    sub     e
    jr      nc, 01$
    xor     a
    jr      02$
01$:
    cp      #0x04
    jr      c, 02$
    ld      a, ENEMY_SHOT(ix)
02$:
    ld      ENEMY_PARAM_3(ix), a
    
    ; �p�^�[����u���^�O��
    ld      hl, #_appPatternName
    add     hl, bc
    ex      de, hl
    ld      hl, #_enemyCollision
    add     hl, bc
    ld      c, ENEMY_INDEX(ix)
    ld      a, #0xb4
    ld      b, ENEMY_PARAM_2(ix)
10$:
    ld      (de), a
    ld      (hl), c
    inc     de
    inc     hl
    djnz    10$
    ld      a, #0xc0
    sub     ENEMY_PARAM_2(ix)
    ld      c, a
;   ld      b, #0x00
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    ld      c, ENEMY_INDEX(ix)
    ld      a, #0xb4
    ld      b, ENEMY_PARAM_2(ix)
11$:
    ld      (de), a
    ld      (hl), c
    inc     de
    inc     hl
    djnz    11$
    
    ; �p�^�[����u���^����
    ld      a, ENEMY_PARAM_3(ix)
    or      a
    jr      z, 29$
    ld      c, ENEMY_PARAM_0(ix)
    ld      b, ENEMY_PARAM_1(ix)
    ld      hl, #(_appPatternName + 0x0043)
    add     hl, bc
    ex      de, hl
    ld      hl, #(_enemyCollision + 0x0043)
    add     hl, bc
    ld      c, ENEMY_INDEX(ix)
    ld      a, #0xb4
    ld      b, ENEMY_PARAM_3(ix)
20$:
    ld      (de), a
    ld      (hl), c
    inc     de
    inc     hl
    djnz    20$
    ld      a, #0x40
    sub     ENEMY_PARAM_3(ix)
    ld      c, a
;   ld      b, #0x00
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    ld      c, ENEMY_INDEX(ix)
    ld      a, #0xb4
    ld      b, ENEMY_PARAM_3(ix)
21$:
    ld      (de), a
    ld      (hl), c
    inc     de
    inc     hl
    djnz    21$
29$:
    
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

