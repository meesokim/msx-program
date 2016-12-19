; GameEnemy.s : �Q�[����ʁ^�G
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
    .include    "GameShip.inc"
    .include    "GameEnemy.inc"



; CODE �̈�
;
    .area   _CODE


; �G������������
;
_GameEnemyInitialize::
    
    ; �G�̑���
    ld      ix, #_gameEnemy
    ld      bc, #((GAME_ENEMY_SIZE << 8) | 0x0000)
0$:
    
    ; �ʒu�̐ݒ�
    ld      a, c
    sla     a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyPointTable
    add     hl, de
    ld      a, (hl)
    ld      GAME_ENEMY_PARAM_POINT_XS(ix), a
    inc     hl
    ld      a, (hl)
    ld      GAME_ENEMY_PARAM_POINT_YS(ix), a
    
    ; �X�v���C�g�̐ݒ�
    ld      a, c
    sla     a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemySpritePatternTable
    add     hl, de
    ld      a, (hl)
    ld      GAME_ENEMY_PARAM_SPRITE_SRC_L(ix), a
    inc     hl
    ld      a, (hl)
    ld      GAME_ENEMY_PARAM_SPRITE_SRC_H(ix), a
    ld      a, c
    sla     a
    sla     a
    ld      GAME_ENEMY_PARAM_SPRITE_OFFSET(ix), a
    
    ; ��Ԃ̐ݒ�
    ld      a, #GAME_ENEMY_STATE_IN
    ld      GAME_ENEMY_PARAM_STATE(ix), a
    xor     a
    ld      GAME_ENEMY_PARAM_PHASE(ix), a
    
    ; ���̓G
    ld      de, #GAME_ENEMY_PARAM_SIZE
    add     ix, de
    inc     c
    djnz    0$
    
    ; �X�v���C�g�I�t�Z�b�g�̏�����
    xor     a
    ld      (spriteOffset + 0), a
    ld      a, #GAME_SPRITE_ENEMY
    ld      (spriteOffset + 1), a
    
    ; �I��
    ret


; �G���X�V����
;
_GameEnemyUpdate::
    
    ; �G�̑���
    ld      ix, #_gameEnemy
    ld      b, #GAME_ENEMY_SIZE
GameEnemyUpdateLoop:
    
    ; ���W�X�^�̕ۑ�
    push    bc
    
    ; ��Ԃ̎擾
    ld      a, GAME_ENEMY_PARAM_STATE(ix)
    
    ; �Ȃ�
    cp      #GAME_ENEMY_STATE_NULL
    jr      nz, 00$
    call    GameEnemyNull
    jr      GameEnemyUpdateNext
00$:
    
    ; �C��
    cp      #GAME_ENEMY_STATE_IN
    jr      nz, 01$
    call    GameEnemyIn
    jr      GameEnemyUpdateNext
01$:
    
    ; �ҋ@
    cp      #GAME_ENEMY_STATE_STAY
    jr      nz, 02$
    call    GameEnemyStay
    jr      GameEnemyUpdateNext
02$:
    
    ; �^�[��
    cp      #GAME_ENEMY_STATE_TURN
    jr      nz, 03$
    call    GameEnemyTurn
    jr      GameEnemyUpdateNext
03$:
    
    ; �A�v���[�`
    cp      #GAME_ENEMY_STATE_APPROACH
    jr      nz, 04$
    call    GameEnemyApproach
    jr      GameEnemyUpdateNext
04$:
    
    ; ����
    cp      #GAME_ENEMY_STATE_BOMB
    jr      nz, 05$
    call    GameEnemyBomb
    jr      GameEnemyUpdateNext
05$:
    
    ; ���̓G
GameEnemyUpdateNext:
    pop     bc
    ld      de, #GAME_ENEMY_PARAM_SIZE
    add     ix, de
    djnz    GameEnemyUpdateLoop
    
    ; �X�V�̏I��
GameEnemyUpdateEnd:
    
    ; �X�v���C�g�I�t�Z�b�g�̍X�V
    ld      hl, #spriteOffset
    ld      a, (hl)
    add     a, #0x04
    cp      #(GAME_ENEMY_SIZE * 0x04)
    jr      c, 10$
    xor     a
10$:
    ld      (hl), a
    inc     hl
    ld      a, #GAME_SPRITE_ENEMY_OFFSET
    sub     (hl)
    ld      (hl), a
    
    ; �I��
    ret


; �G�͂Ȃ�
;
GameEnemyNull:
    
    ; ��Ԃ̎擾
    ld      a, GAME_ENEMY_PARAM_PHASE(ix)
    or      a
    jr      nz, GameEnemyNullMain
    
    ; �m�[�_���[�W�̐ݒ�
    ld      a, #0x80
    ld      GAME_ENEMY_PARAM_NODAMAGE(ix), a
    
    ; ��Ԃ̍X�V
    inc     GAME_ENEMY_PARAM_PHASE(ix)
    
    ; �ҋ@�̏���
GameEnemyNullMain:
    
    ; �����̊���
GameEnemyNullDone:
    
    ; �`��̊J�n
    ld      hl, #spriteOffset
    ld      a, (hl)
    inc     hl
    add     a, GAME_ENEMY_PARAM_SPRITE_OFFSET(ix)
    cp      #(GAME_ENEMY_SIZE * 0x04)
    jr      c, 0$
    sub     #(GAME_ENEMY_SIZE * 0x04)
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
GameEnemyNullEnd:
    
    ; �I��
    ret


; �G���C������
;
GameEnemyIn:
    
    ; ��Ԃ̎擾
    ld      a, GAME_ENEMY_PARAM_PHASE(ix)
    or      a
    jr      nz, GameEnemyInMain
    
    ; �ʒu�̐ݒ�
    ld      a, GAME_ENEMY_PARAM_POINT_XS(ix)
    ld      GAME_ENEMY_PARAM_POINT_XI(ix), a
    ld      a, #0xf4
    ld      GAME_ENEMY_PARAM_POINT_YI(ix), a
    xor     a
    ld      GAME_ENEMY_PARAM_POINT_XD(ix), a
    ld      GAME_ENEMY_PARAM_POINT_YD(ix), a
    
    ; �����̐ݒ�
    ld      a, #0x40
    ld      GAME_ENEMY_PARAM_ANGLE(ix), a
    
    ; �m�[�_���[�W�̐ݒ�
    xor     a
    ld      GAME_ENEMY_PARAM_NODAMAGE(ix), a
    
    ; �J�E���g�̐ݒ�
    ld      a, #0x40
    sub     GAME_ENEMY_PARAM_POINT_YS(ix)
    ld      GAME_ENEMY_PARAM_COUNT0(ix), a
    
    ; �A�j���[�V�����̐ݒ�
    xor     a
    ld      GAME_ENEMY_PARAM_ANIMATION(ix), a
    
    ; ��Ԃ̍X�V
    inc     GAME_ENEMY_PARAM_PHASE(ix)
    
    ; �C���̏���
GameEnemyInMain:
    
    ; �J�E���g�̍X�V
    ld      a, GAME_ENEMY_PARAM_COUNT0(ix)
    or      a
    jr      z, 00$
    sub     #0x02
    ld      GAME_ENEMY_PARAM_COUNT0(ix), a
    jr      GameEnemyInDone
00$:
    
    ; �ʒu�̍X�V
    ld      a, GAME_ENEMY_PARAM_POINT_YI(ix)
    cp      GAME_ENEMY_PARAM_POINT_YS(ix)
    jr      z, 10$
    add     #0x02
    ld      GAME_ENEMY_PARAM_POINT_YI(ix), a
    jr      GameEnemyInDone
10$:
    
    ; �����̍X�V
    ld      a, GAME_ENEMY_PARAM_ANGLE(ix)
    cp      #0xc0
    jr      z, 20$
    sub     #0x08
    ld      GAME_ENEMY_PARAM_ANGLE(ix), a
    jr      GameEnemyInDone
20$:
    
    ; ��Ԃ̐ݒ�
    ld      a, #GAME_ENEMY_STATE_STAY
    ld      GAME_ENEMY_PARAM_STATE(ix), a
    xor     a
    ld      GAME_ENEMY_PARAM_PHASE(ix), a
    
    ; �����̊���
GameEnemyInDone:
    
    ; �G�̕`��
    call    GameEnemyDraw
    
    ; �����̏I��
GameEnemyInEnd:
    
    ; �I��
    ret


; �G���ҋ@����
;
GameEnemyStay:
    
    ; ��Ԃ̎擾
    ld      a, GAME_ENEMY_PARAM_PHASE(ix)
    or      a
    jr      nz, GameEnemyStayMain
    
    ; �J�E���g�̐ݒ�
    ld      a, (_appTimer + 0)
    sla     a
    ld      c, a
    ld      b, #0x00
    ld      hl, #enemyStayTable
    add     hl, bc
    call    _SystemGetRandom
    and     (hl)
    inc     hl
    add     a, (hl)
    ld      GAME_ENEMY_PARAM_COUNT0(ix), a
    ld      a, #0x40
    ld      GAME_ENEMY_PARAM_COUNT1(ix), a
    
    ; ��Ԃ̍X�V
    inc     GAME_ENEMY_PARAM_PHASE(ix)
    
    ; �ҋ@�̏���
GameEnemyStayMain:
    
    ; ����\���ǂ���
    ld      hl, #_gameFlag
    bit     #GAME_FLAG_PLAYABLE, (hl)
    jr      z, GameEnemyStayDone
    
    ; �J�E���g�̍X�V
    ld      a, GAME_ENEMY_PARAM_COUNT0(ix)
    or      a
    jr      z, 0$
    dec     GAME_ENEMY_PARAM_COUNT0(ix)
    jr      GameEnemyStayDone
0$:
    ld      a, GAME_ENEMY_PARAM_COUNT1(ix)
    or      a
    jr      z, 1$
    dec     GAME_ENEMY_PARAM_COUNT1(ix)
    jr      GameEnemyStayDone
1$:
    
    ; ��Ԃ̐ݒ�
    ld      a, #GAME_ENEMY_STATE_TURN
    ld      GAME_ENEMY_PARAM_STATE(ix), a
    xor     a
    ld      GAME_ENEMY_PARAM_PHASE(ix), a
    
    ; �����̊���
GameEnemyStayDone:
    
    ; �G�̕`��
    call    GameEnemyDraw
    
    ; �����̏I��
GameEnemyStayEnd:
    
    ; �I��
    ret


; �G���^�[������
;
GameEnemyTurn:
    
    ; ��Ԃ̎擾
    ld      a, GAME_ENEMY_PARAM_PHASE(ix)
    or      a
    jr      nz, GameEnemyTurnMain
    
    ; ��]�̐ݒ�
    ld      a, #0x02
    ld      GAME_ENEMY_PARAM_TURN(ix), a
    call    _SystemGetRandom
    and     #0b00010000
    jr      nz, 00$
    ld      a, #0xfe
    ld      GAME_ENEMY_PARAM_TURN(ix), a
00$:
    
    ; ���t�̊J�n
    ld      hl, #mmlTurnChannel1
    ld      (_soundRequest + 2), hl
    
    ; ��Ԃ̍X�V
    inc     GAME_ENEMY_PARAM_PHASE(ix)
    
    ; �^�[���̏���
GameEnemyTurnMain:
    
    ; �����̍X�V
    ld      a, GAME_ENEMY_PARAM_TURN(ix)
    add     a, GAME_ENEMY_PARAM_ANGLE(ix)
    ld      GAME_ENEMY_PARAM_ANGLE(ix), a
    cp      #0x40
    jr      nz, 10$
    
    ; ��Ԃ̍X�V
    ld      a, #GAME_ENEMY_STATE_APPROACH
    ld      GAME_ENEMY_PARAM_STATE(ix), a
    xor     a
    ld      GAME_ENEMY_PARAM_PHASE(ix), a
10$:
    
    ; �ʒu�̍X�V
    
    ; X ������ x1.5 �̈ړ�
    ld      a, GAME_ENEMY_PARAM_ANGLE(ix)
    call    _SystemGetCos
    ld      a, GAME_ENEMY_PARAM_POINT_XD(ix)
    add     a, l
    ld      c, a
    ld      a, GAME_ENEMY_PARAM_POINT_XI(ix)
    adc     a, h
    ld      b, a
    sra     h
    rr      l
    ld      a, c
    add     a, l
    ld      GAME_ENEMY_PARAM_POINT_XD(ix), a
    ld      a, b
    adc     a, h
    ld      GAME_ENEMY_PARAM_POINT_XI(ix), a
    
    ; Y ������ x2.0 �̈ړ�
    ld      a, GAME_ENEMY_PARAM_ANGLE(ix)
    call    _SystemGetSin
    sla     l
    rl      h
    ld      a, GAME_ENEMY_PARAM_POINT_YD(ix)
    add     a, l
    ld      GAME_ENEMY_PARAM_POINT_YD(ix), a
    ld      a, GAME_ENEMY_PARAM_POINT_YI(ix)
    adc     a, h
    ld      GAME_ENEMY_PARAM_POINT_YI(ix), a
    
    ; ��ʒ[�̐���
    jr      21$
    ld      a, GAME_ENEMY_PARAM_POINT_XI(ix)
    cp      #0x08
    jr      nc, 20$
    ld      a, #0x08
    ld      GAME_ENEMY_PARAM_POINT_XI(ix), a
    xor     a
    ld      GAME_ENEMY_PARAM_POINT_XD(ix), a
    ld      a, #0x80
    sub     GAME_ENEMY_PARAM_ANGLE(ix)
    ld      GAME_ENEMY_PARAM_ANGLE(ix), a
    ld      a, GAME_ENEMY_PARAM_TURN(ix)
    xor     #0xff
    inc     a
    ld      GAME_ENEMY_PARAM_TURN(ix), a
20$:
    ld      a, GAME_ENEMY_PARAM_POINT_XI(ix)
    cp      #0xb8
    jr      c, 21$
    ld      a, #0xb8
    ld      GAME_ENEMY_PARAM_POINT_XI(ix), a
    xor     a
    ld      GAME_ENEMY_PARAM_POINT_XD(ix), a
    ld      a, #0x80
    sub     GAME_ENEMY_PARAM_ANGLE(ix)
    ld      GAME_ENEMY_PARAM_ANGLE(ix), a
    ld      a, GAME_ENEMY_PARAM_TURN(ix)
    xor     #0xff
    inc     a
    ld      GAME_ENEMY_PARAM_TURN(ix), a
21$:
    
    ; �����̊���
GameEnemyTurnDone:
    
    ; �G�̕`��
    call    GameEnemyDraw
    
    ; �����̏I��
GameEnemyTurnEnd:
    
    ; �I��
    ret


; �G���A�v���[�`����
;
GameEnemyApproach:
    
    ; ��Ԃ̎擾
    ld      a, GAME_ENEMY_PARAM_PHASE(ix)
    or      a
    jr      nz, GameEnemyApproachMain
    
    ; ��Ԃ̍X�V
    inc     GAME_ENEMY_PARAM_PHASE(ix)
    
    ; �A�v���[�`�̏���
GameEnemyApproachMain:
    
    ; �����̍X�V
    ld      a, GAME_ENEMY_PARAM_POINT_XI(ix)
    cp      #0xe0
    jr      c, 00$
    ld      a, #0xfe
    jr      02$
00$:
    ld      hl, #(_gameShip + GAME_SHIP_PARAM_POINT_X)
    cp      (hl)
    jr      nz, 01$
    xor     a
    jr      02$
01$:
    ld      a, #0x02
    jr      nc, 02$
    ld      a, #0xfe
02$:
    add     a, GAME_ENEMY_PARAM_ANGLE(ix)
    cp      #0x22
    jr      nc, 03$
    ld      a, #0x22
03$:
    cp      #0x5e
    jr      c, 04$
    ld      a, #0x5e
04$:
    ld      GAME_ENEMY_PARAM_ANGLE(ix), a
    
    ; �ʒu�̍X�V
    call    _SystemGetCos
    sla     l
    rl      h
    ld      a, GAME_ENEMY_PARAM_POINT_XD(ix)
    add     a, l
    ld      GAME_ENEMY_PARAM_POINT_XD(ix), a
    ld      a, GAME_ENEMY_PARAM_POINT_XI(ix)
    adc     a, h
    ld      GAME_ENEMY_PARAM_POINT_XI(ix), a
    
    ; �ʒu�̍X�V
    ld      a, GAME_ENEMY_PARAM_ANGLE(ix)
    call    _SystemGetSin
    sla     l
    rl      h
    ld      a, GAME_ENEMY_PARAM_POINT_YD(ix)
    add     a, l
    ld      GAME_ENEMY_PARAM_POINT_YD(ix), a
    ld      a, GAME_ENEMY_PARAM_POINT_YI(ix)
    adc     a, h
    ld      GAME_ENEMY_PARAM_POINT_YI(ix), a
    
    ; �ړ��̊���
    ld      a, GAME_ENEMY_PARAM_POINT_YI(ix)
    cp      #0xc8
    jr      c, GameEnemyApproachDone
    
    ; ��Ԃ̍X�V
    ld      a, #GAME_ENEMY_STATE_IN
    ld      GAME_ENEMY_PARAM_STATE(ix), a
    xor     a
    ld      GAME_ENEMY_PARAM_PHASE(ix), a
    
    ; �����̊���
GameEnemyApproachDone:
    
    ; �G�̕`��
    call    GameEnemyDraw
    
    ; �����̏I��
GameEnemyApproachEnd:
    
    ; �I��
    ret


; �G����������
;
GameEnemyBomb:
    
    ; ��Ԃ̎擾
    ld      a, GAME_ENEMY_PARAM_PHASE(ix)
    or      a
    jr      nz, GameEnemyBombMain
    
    ; �m�[�_���[�W�̐ݒ�
    ld      a, #0x80
    ld      GAME_ENEMY_PARAM_NODAMAGE(ix), a
    
    ; �A�j���[�V�����̐ݒ�
    xor     a
    ld      GAME_ENEMY_PARAM_ANIMATION(ix), a
    
    ; ���t�̊J�n
    ld      hl, #mmlBombChannel2
    ld      (_soundRequest + 4), hl
    
    ; ��Ԃ̍X�V
    inc     GAME_ENEMY_PARAM_PHASE(ix)
    
    ; �����̏���
GameEnemyBombMain:
    
    ; �A�j���[�V�����̍X�V
    inc     GAME_ENEMY_PARAM_ANIMATION(ix)
    ld      a, GAME_ENEMY_PARAM_ANIMATION(ix)
    cp      #0x1f
    jr      nz, GameEnemyBombDone
    
    ; ��Ԃ̍X�V
    ld      a, #GAME_ENEMY_STATE_IN
    ld      GAME_ENEMY_PARAM_STATE(ix), a
    xor     a
    ld      GAME_ENEMY_PARAM_PHASE(ix), a
    
    ; �����̊���
GameEnemyBombDone:
    
    ; �`��̊J�n
    ld      hl, #spriteOffset
    ld      a, (hl)
    inc     hl
    add     a, GAME_ENEMY_PARAM_SPRITE_OFFSET(ix)
    cp      #(GAME_ENEMY_SIZE * 0x04)
    jr      c, 0$
    sub     #(GAME_ENEMY_SIZE * 0x04)
0$:
    add     a, (hl)
    ld      c, a
    ld      b, #0x00
    ld      hl, #_sprite
    add     hl, bc
    ld      d, h
    ld      e, l
    ld      a, GAME_ENEMY_PARAM_ANIMATION(ix)
    and     #0b00011000
    srl     a
    ld      c, a
    ld      b, #0x00
    ld      hl, #bombSpriteTable
    add     hl, bc
    ld      b, GAME_ENEMY_PARAM_POINT_XI(ix)
    ld      c, GAME_ENEMY_PARAM_POINT_YI(ix)
    call    _SystemSetSprite
    
    ; �����̏I��
GameEnemyBombEnd:
    
    ; �I��
    ret


; �G��`�悷��
;
GameEnemyDraw::
    
    ; �A�j���[�V�����̍X�V
    inc     GAME_ENEMY_PARAM_ANIMATION(ix)
    
    ; �`��̊J�n
    ld      hl, #spriteOffset
    ld      a, (hl)
    inc     hl
    add     a, GAME_ENEMY_PARAM_SPRITE_OFFSET(ix)
    cp      #(GAME_ENEMY_SIZE * 0x04)
    jr      c, 0$
    sub     #(GAME_ENEMY_SIZE * 0x04)
0$:
    add     a, (hl)
    ld      c, a
    ld      b, #0x00
    ld      hl, #_sprite
    add     hl, bc
    ld      d, h
    ld      e, l
    ld      a, GAME_ENEMY_PARAM_ANGLE(ix)
    add     a, #0x20
    and     #0b11000000
    srl     a
    srl     a
    srl     a
    ld      c, a
    ld      b, #0x00
    ld      l, GAME_ENEMY_PARAM_SPRITE_SRC_L(ix)
    ld      h, GAME_ENEMY_PARAM_SPRITE_SRC_H(ix)
    add     hl, bc
    ld      a, GAME_ENEMY_PARAM_ANIMATION(ix)
    and     #0b00001000
    srl     a
    ld      c, a
    ld      b, #0x00
    add     hl, bc
    ld      b, GAME_ENEMY_PARAM_POINT_XI(ix)
    ld      c, GAME_ENEMY_PARAM_POINT_YI(ix)
    ld      a, b
    cp      #0xe0
    jr      c, 1$
    cp      #0xf8
    jr      nc, 1$
    ld      a, #0xc0
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    jr      2$
1$:
    call    _SystemSetSprite
2$:
    
    ; �I��
    ret


; �萔�̒�`
;

; �G�f�[�^
;
enemyPointTable:
    
    .db     0x40, 0x10
    .db     0x80, 0x10
    .db     0x30, 0x28
    .db     0x50, 0x28
    .db     0x70, 0x28
    .db     0x90, 0x28
    .db     0x40, 0x40
    .db     0x60, 0x40
    .db     0x80, 0x40

enemyStayTable:
    
    .db     0x7f, 0x00
    .db     0x7f, 0x40
    .db     0xff, 0x00
    .db     0xff, 0x00

enemySpriteTable:
    
    .db     0xf8, 0xf8, 0x80, 0x0a      ; 0:��
    .db     0xf8, 0xf8, 0x84, 0x0a
    .db     0xf8, 0xf8, 0x88, 0x0a      ; 0:��
    .db     0xf8, 0xf8, 0x8c, 0x0a
    .db     0xf8, 0xf8, 0x90, 0x0a      ; 0:��
    .db     0xf8, 0xf8, 0x94, 0x0a
    .db     0xf8, 0xf8, 0x98, 0x0a      ; 0:��
    .db     0xf8, 0xf8, 0x9c, 0x0a
    .db     0xf8, 0xf8, 0xa0, 0x06      ; 1:��
    .db     0xf8, 0xf8, 0xa4, 0x06
    .db     0xf8, 0xf8, 0xa8, 0x06      ; 1:��
    .db     0xf8, 0xf8, 0xac, 0x06
    .db     0xf8, 0xf8, 0xb0, 0x06      ; 1:��
    .db     0xf8, 0xf8, 0xb4, 0x06
    .db     0xf8, 0xf8, 0xb8, 0x06      ; 1:��
    .db     0xf8, 0xf8, 0xbc, 0x06
    .db     0xf8, 0xf8, 0xc0, 0x0d      ; 2:��
    .db     0xf8, 0xf8, 0xc4, 0x0d
    .db     0xf8, 0xf8, 0xc8, 0x0d      ; 2:��
    .db     0xf8, 0xf8, 0xcc, 0x0d
    .db     0xf8, 0xf8, 0xd0, 0x0d      ; 2:��
    .db     0xf8, 0xf8, 0xd4, 0x0d
    .db     0xf8, 0xf8, 0xd8, 0x0d      ; 2:��
    .db     0xf8, 0xf8, 0xdc, 0x0d
    .db     0xf8, 0xf8, 0xe0, 0x04      ; 3:��
    .db     0xf8, 0xf8, 0xe4, 0x04
    .db     0xf8, 0xf8, 0xe8, 0x04      ; 3:��
    .db     0xf8, 0xf8, 0xec, 0x04
    .db     0xf8, 0xf8, 0xf0, 0x04      ; 3:��
    .db     0xf8, 0xf8, 0xf4, 0x04
    .db     0xf8, 0xf8, 0xf8, 0x04      ; 3:��
    .db     0xf8, 0xf8, 0xfc, 0x04

enemySpritePatternTable:
    
    .dw     enemySpriteTable + 0x0000
    .dw     enemySpriteTable + 0x0000
    .dw     enemySpriteTable + 0x0020
    .dw     enemySpriteTable + 0x0060
    .dw     enemySpriteTable + 0x0060
    .dw     enemySpriteTable + 0x0020
    .dw     enemySpriteTable + 0x0040
    .dw     enemySpriteTable + 0x0060
    .dw     enemySpriteTable + 0x0040

; �����f�[�^
;
bombSpriteTable:
    
    .db     0xf8, 0xf8, 0x10, 0x06
    .db     0xf8, 0xf8, 0x14, 0x0a
    .db     0xf8, 0xf8, 0x18, 0x06
    .db     0xf8, 0xf8, 0x1c, 0x0f

; MML �f�[�^
;
mmlTurnChannel1:
    
    .ascii  "T1V15L1"
    .ascii  "O6CO5BA#AG#GF#FED#DDC#CO4BA#AAGF#FED#DC#CO3BA#AG#GF#FED#DC#CO2BA#A"
    .db     0x00

mmlBombChannel2:
    
    .ascii  "T1V15L0"
    .ascii  "O4AGFEDCAGFEDCCDEFGABO5CDEFGABO6CO5AFEDEF"
    .db     0x00



; DATA �̈�
;
    .area   _DATA


; �ϐ��̒�`
;

; �p�����[�^
;
_gameEnemy::
    
    .ds     GAME_ENEMY_PARAM_SIZE * GAME_ENEMY_SIZE

; �X�v���C�g�I�t�Z�b�g
;
spriteOffset:
    
    .ds     2



