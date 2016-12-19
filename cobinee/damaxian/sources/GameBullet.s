; GameBullet.s : �Q�[����ʁ^�e
;



; ���W���[���錾
;
    .module Game


; �Q�ƃt�@�C��
;
    .include    "bios.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include    "Game.inc"
    .include    "GameBullet.inc"



; CODE �̈�
;
    .area   _CODE


; �e������������
;
_GameBulletInitialize::
    
    ; �e�̑���
    ld      ix, #_gameBullet
    ld      bc, #((GAME_BULLET_SIZE << 8) | 0x0000)
0$:
    
    ; �X�v���C�g�̐ݒ�
    ld      a, c
    sla     a
    sla     a
    ld      GAME_BULLET_PARAM_SPRITE_OFFSET(ix), a
    
    ; ��Ԃ̐ݒ�
    ld      a, #GAME_BULLET_STATE_NULL
    ld      GAME_BULLET_PARAM_STATE(ix), a
    xor     a
    ld      GAME_BULLET_PARAM_PHASE(ix), a
    
    ; ���̒e
    ld      de, #GAME_BULLET_PARAM_SIZE
    add     ix, de
    inc     c
    djnz    0$
    
    ; �X�v���C�g�I�t�Z�b�g�̏�����
    xor     a
    ld      (spriteOffset + 0), a
    ld      a, #GAME_SPRITE_BULLET
    ld      (spriteOffset + 1), a
    
    ; �I��
    ret


; �e���X�V����
;
_GameBulletUpdate::
    
    ; �e�̑���
    ld      ix, #_gameBullet
    ld      b, #GAME_BULLET_SIZE
GameBulletUpdateLoop:
    
    ; ���W�X�^�̕ۑ�
    push    bc
    
    ; ��Ԃ̎擾
    ld      a, GAME_BULLET_PARAM_STATE(ix)
    
    ; �Ȃ�
    cp      #GAME_BULLET_STATE_NULL
    jr      nz, 00$
    call    GameBulletNull
    jr      GameBulletUpdateNext
00$:
    
    ; �ړ�
    cp      #GAME_BULLET_STATE_MOVE
    jr      nz, 01$
    call    GameBulletMove
    jr      GameBulletUpdateNext
01$:
    
    ; ���̒e
GameBulletUpdateNext:
    pop     bc
    ld      de, #GAME_BULLET_PARAM_SIZE
    add     ix, de
    djnz    GameBulletUpdateLoop
    
    ; �X�V�̏I��
GameBulletUpdateEnd:
    
    ; �X�v���C�g�I�t�Z�b�g�̍X�V
    ld      hl, #spriteOffset
    ld      a, (hl)
    add     a, #0x04
    cp      #(GAME_BULLET_SIZE * 0x04)
    jr      c, 10$
    xor     a
10$:
    ld      (hl), a
    inc     hl
    ld      a, #GAME_SPRITE_BULLET_OFFSET
    sub     (hl)
    ld      (hl), a
    
    ; �I��
    ret


; �e�͂Ȃ�
;
GameBulletNull:
    
    ; ��Ԃ̎擾
    ld      a, GAME_BULLET_PARAM_PHASE(ix)
    or      a
    jr      nz, GameBulletNullMain
    
    ; ��Ԃ̍X�V
    inc     GAME_BULLET_PARAM_PHASE(ix)
    
    ; �ҋ@�̏���
GameBulletNullMain:
    
    ; �����̊���
GameBUlletNullDone:
    
    ; �`��̊J�n
    ld      hl, #spriteOffset
    ld      a, (hl)
    inc     hl
    add     a, GAME_BULLET_PARAM_SPRITE_OFFSET(ix)
    cp      #(GAME_BULLET_SIZE * 0x04)
    jr      c, 0$
    sub     #(GAME_BULLET_SIZE * 0x04)
0$:
    add     a, (hl)
    ld      c, a
    ld      b, #0x00
    ld      hl, #_sprite
    add     hl, bc
    ld      a, #0xc0
    ld      (hl), a
    inc     hl
    ld      (hl), a
    inc     hl
    ld      (hl), a
    inc     hl
    ld      (hl), a
    
    ; �����̏I��
GameBulletNullEnd:
    
    ; �I��
    ret


; �e���ړ�����
;
GameBulletMove:
    
    ; ��Ԃ̎擾
    ld      a, GAME_BULLET_PARAM_PHASE(ix)
    or      a
    jr      nz, GameBulletMoveMain
    
    ; ��Ԃ̍X�V
    inc     GAME_BULLET_PARAM_PHASE(ix)
    
    ; �ҋ@�̏���
GameBulletMoveMain:
    
    ; �ړ�
    ld      a, GAME_BULLET_PARAM_POINT_XD(ix)
    add     a, GAME_BULLET_PARAM_SPEED_XD(ix)
    ld      GAME_BULLET_PARAM_POINT_XD(ix), a
    ld      a, GAME_BULLET_PARAM_POINT_XI(ix)
    adc     a, GAME_BULLET_PARAM_SPEED_XI(ix)
    ld      GAME_BULLET_PARAM_POINT_XI(ix), a
    ld      a, GAME_BULLET_PARAM_POINT_YD(ix)
    add     a, GAME_BULLET_PARAM_SPEED_YD(ix)
    ld      GAME_BULLET_PARAM_POINT_YD(ix), a
    ld      a, GAME_BULLET_PARAM_POINT_YI(ix)
    adc     a, GAME_BULLET_PARAM_SPEED_YI(ix)
    ld      GAME_BULLET_PARAM_POINT_YI(ix), a
    
    ; �ړ��̊���
    ld      a, GAME_BULLET_PARAM_POINT_XI(ix)
    cp      #0xc4
    jr      nc, 00$
    ld      a, GAME_BULLET_PARAM_POINT_YI(ix)
    cp      #0xc4
    jr      c, GameBulletMoveDone
00$:
    
    ; ��Ԃ̍X�V
    ld      a, #GAME_BULLET_STATE_NULL
    ld      GAME_BULLET_PARAM_STATE(ix), a
    xor     a
    ld      GAME_BULLET_PARAM_PHASE(ix), a
    
    ; �����̊���
GameBulletMoveDone:
    
    ; �`��̊J�n
    ld      hl, #spriteOffset
    ld      a, (hl)
    inc     hl
    add     a, GAME_BULLET_PARAM_SPRITE_OFFSET(ix)
    cp      #(GAME_BULLET_SIZE * 0x04)
    jr      c, 10$
    sub     #(GAME_BULLET_SIZE * 0x04)
10$:
    add     a, (hl)
    ld      c, a
    ld      b, #0x00
    ld      hl, #_sprite
    add     hl, bc
    ld      d, h
    ld      e, l
    ld      l, GAME_BULLET_PARAM_SPRITE_SRC_L(ix)
    ld      h, GAME_BULLET_PARAM_SPRITE_SRC_H(ix)
    ld      b, GAME_BULLET_PARAM_POINT_XI(ix)
    ld      c, GAME_BULLET_PARAM_POINT_YI(ix)
    ld      a, b
    cp      #0xe0
    jr      c, 11$
    cp      #0xf8
    jr      nc, 11$
    ld      a, #0xc0
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    jr      12$
11$:
    call    _SystemSetSprite
12$:
    
    ; �����̏I��
GameBulletMoveEnd:
    
    ; �I��
    ret


; �e���G���g������
;
_GameBulletEntry::
    
    ; ���W�X�^�̕ۑ�
    push    bc
    push    de
    push    ix
    
    ; �e�̑���
    ld      ix, #_gameBullet
    ld      de, #GAME_BULLET_PARAM_SIZE
    ld      b, #GAME_BULLET_SIZE
0$:
    ld      a, GAME_BULLET_PARAM_STATE(ix)
    cp      #GAME_BULLET_STATE_NULL
    jr      z, 1$
    add     ix, de
    djnz    0$
    jr      GameBulletEntryEnd
1$:
    
    ; �ʒu�̐ݒ�
    ld      a, (_gameBulletEntry + GAME_BULLET_PARAM_POINT_XD)
    ld      GAME_BULLET_PARAM_POINT_XD(ix), a
    ld      a, (_gameBulletEntry + GAME_BULLET_PARAM_POINT_XI)
    ld      GAME_BULLET_PARAM_POINT_XI(ix), a
    ld      a, (_gameBulletEntry + GAME_BULLET_PARAM_POINT_YD)
    ld      GAME_BULLET_PARAM_POINT_YD(ix), a
    ld      a, (_gameBulletEntry + GAME_BULLET_PARAM_POINT_YI)
    ld      GAME_BULLET_PARAM_POINT_YI(ix), a
    
    ; ���x�̐ݒ�
    ld      a, (_gameBulletEntry + GAME_BULLET_PARAM_SPEED_XD)
    ld      GAME_BULLET_PARAM_SPEED_XD(ix), a
    ld      a, (_gameBulletEntry + GAME_BULLET_PARAM_SPEED_XI)
    ld      GAME_BULLET_PARAM_SPEED_XI(ix), a
    ld      a, (_gameBulletEntry + GAME_BULLET_PARAM_SPEED_YD)
    ld      GAME_BULLET_PARAM_SPEED_YD(ix), a
    ld      a, (_gameBulletEntry + GAME_BULLET_PARAM_SPEED_YI)
    ld      GAME_BULLET_PARAM_SPEED_YI(ix), a
    
    ; �X�v���C�g�̐ݒ�
    ld      a, (_gameBulletEntry + GAME_BULLET_PARAM_SPRITE_SRC_L)
    sla     a
    sla     a
    ld      e, a
    ld      d, #0x00
    ld      hl, #bulletSpriteTable
    add     hl, de
    ld      GAME_BULLET_PARAM_SPRITE_SRC_L(ix), l
    ld      GAME_BULLET_PARAM_SPRITE_SRC_H(ix), h
    
    ; ��Ԃ̍X�V
    ld      a, #GAME_BULLET_STATE_MOVE
    ld      GAME_BULLET_PARAM_STATE(ix), a
    xor     a
    ld      GAME_BULLET_PARAM_PHASE(ix), a
    
    ; �G���g���̏I��
GameBulletEntryEnd:
    
    ; ���W�X�^�̕��A
    pop     ix
    pop     de
    pop     bc
    
    ; �I��
    ret


; �萔�̒�`
;


; �e�f�[�^
;
bulletSpriteTable:
    
    .db     0xf8, 0xf8, 0x40, 0x06
    .db     0xf8, 0xf8, 0x40, 0x04



; DATA �̈�
;
    .area   _DATA


; �ϐ��̒�`
;

; �p�����[�^
;
_gameBullet::
    
    .ds     GAME_BULLET_PARAM_SIZE * GAME_BULLET_SIZE

; �G���g��
;
_gameBulletEntry::
    
    .ds     GAME_BULLET_PARAM_SIZE

; �X�v���C�g�I�t�Z�b�g
;
spriteOffset:
    
    .ds     2



