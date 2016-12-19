; GameShot.s : �Q�[����ʁ^�V���b�g
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
    .include    "GameShot.inc"



; CODE �̈�
;
    .area   _CODE


; �V���b�g������������
;
_GameShotInitialize::
    
    ; �V���b�g�̑���
    ld      ix, #_gameShot
    ld      de, #GAME_SHOT_PARAM_SIZE
    ld      bc, #((GAME_SHOT_SIZE << 8) | 0x0000)
0$:
    
    ; �C���f�b�N�X�̐ݒ�
    ld      GAME_SHOT_PARAM_INDEX(ix), c
    
    ; ��Ԃ̐ݒ�
    ld      a, #GAME_SHOT_STATE_NULL
    ld      GAME_SHOT_PARAM_STATE(ix), a
    xor     a
    ld      GAME_SHOT_PARAM_PHASE(ix), a
    
    ; ���̃V���b�g
    add     ix, de
    inc     c
    djnz    0$
    
    ; �I��
    ret


; �V���b�g���X�V����
;
_GameShotUpdate::
    
    ; �V���b�g�̑���
    ld      ix, #_gameShot
    ld      b, #GAME_SHOT_SIZE
GameShotUpdateLoop:
    
    ; ���W�X�^�̕ۑ�
    push    bc
    
    ; ��Ԃ̎擾
    ld      a, GAME_SHOT_PARAM_STATE(ix)
    
    ; �Ȃ�
    cp      #GAME_SHOT_STATE_NULL
    jr      nz, 0$
    call    GameShotNull
    jr      GameShotUpdateNext
0$:
    
    ; �ړ�
    cp      #GAME_SHOT_STATE_MOVE
    jr      nz, 1$
    call    GameShotMove
    jr      GameShotUpdateNext
1$:
    
    ; ���̃V���b�g
GameShotUpdateNext:
    pop     bc
    ld      de, #GAME_SHOT_PARAM_SIZE
    add     ix, de
    djnz    GameShotUpdateLoop
    
    ; �X�V�̏I��
GameShotUpdateEnd:
    
    ; �I��
    ret


; �V���b�g�͂Ȃ�
;
GameShotNull:
    
    ; ��Ԃ̎擾
    ld      a, GAME_SHOT_PARAM_PHASE(ix)
    or      a
    jr      nz, GameShotNullMain
    
    ; ��Ԃ̍X�V
    inc     GAME_SHOT_PARAM_PHASE(ix)
    
    ; �ҋ@�̏���
GameShotNullMain:
    
    ; �����̊���
GameShotNullDone:
    
    ; �`��̊J�n
    ld      c, GAME_SHOT_PARAM_INDEX(ix)
    sla     c
    sla     c
    ld      b, #0x00
    ld      hl, #(_sprite + GAME_SPRITE_SHOT)
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
GameShotNullEnd:
    
    ; �I��
    ret


; �V���b�g���ړ�����
;
GameShotMove:
    
    ; ��Ԃ̎擾
    ld      a, GAME_SHOT_PARAM_PHASE(ix)
    or      a
    jr      nz, GameShotMoveMain
    
    ; �ʒu�̏�����
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_X)
    ld      GAME_SHOT_PARAM_POINT_X(ix), a
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_Y)
    ld      GAME_SHOT_PARAM_POINT_Y(ix), a
    
    ; ���t�̊J�n
    ld      hl, #mmlChannel0
    ld      (_soundRequest + 0), hl
    
    ; ��Ԃ̍X�V
    inc     GAME_SHOT_PARAM_PHASE(ix)
    
    ; �ړ��̏���
GameShotMoveMain:
    
    ; �ړ�
    ld      a, GAME_SHOT_PARAM_POINT_Y(ix)
    sub     #0x04
    ld      GAME_SHOT_PARAM_POINT_Y(ix), a
    
    ; �ړ��̊���
    cp      #0xf0
    jr      c, GameShotMoveDone
    cp      #0xf9
    jr      nc, GameShotMoveDone
    
    ; ��Ԃ̍X�V
    ld      a, #GAME_SHOT_STATE_NULL
    ld      GAME_SHOT_PARAM_STATE(ix), a
    xor     a
    ld      GAME_SHOT_PARAM_PHASE(ix), a
    
    ; �����̊���
GameShotMoveDone:
    
    ; �`��̊J�n
    ld      c, GAME_SHOT_PARAM_INDEX(ix)
    sla     c
    sla     c
    ld      b, #0x00
    ld      hl, #(_sprite + GAME_SPRITE_SHOT)
    add     hl, bc
    ld      d, h
    ld      e, l
    ld      hl, #shotSpriteTable
    ld      b, GAME_SHOT_PARAM_POINT_X(ix)
    ld      c, GAME_SHOT_PARAM_POINT_Y(ix)
    call    _SystemSetSprite
    
    ; �����̏I��
GameShotMoveEnd:
    
    ; �I��
    ret


; �V���b�g���G���g������
;
_GameShotEntry::
    
    ; ���W�X�^�̕ۑ�
    push    bc
    push    de
    push    ix
    
    ; �V���b�g�̑���
    ld      ix, #_gameShot
    ld      de, #GAME_SHOT_PARAM_SIZE
    ld      b, #GAME_SHOT_SIZE
0$:
    ld      a, GAME_SHOT_PARAM_STATE(ix)
    cp      #GAME_SHOT_STATE_NULL
    jr      z, 1$
    add     ix, de
    djnz    0$
    jr      GameShotEntryEnd
1$:
    
    ; ��Ԃ̍X�V
    ld      a, #GAME_SHOT_STATE_MOVE
    ld      GAME_SHOT_PARAM_STATE(ix), a
    xor     a
    ld      GAME_SHOT_PARAM_PHASE(ix), a
    
    ; �G���g���̏I��
GameShotEntryEnd:
    
    ; ���W�X�^�̕��A
    pop     ix
    pop     de
    pop     bc
    
    ; �I��
    ret


; �萔�̒�`
;


; �V���b�g�f�[�^
;
shotSpriteTable:
    
    .db     0xfc, 0xf8, 0x08, 0x0f

; MML �f�[�^
;
mmlChannel0:
    
    .ascii  "T1V15L0"
    .ascii  "O5C#CC#RCO4BA#AG#GFD#C#O3BG#"
    .db     0x00



; DATA �̈�
;
    .area   _DATA


; �ϐ��̒�`
;

; �p�����[�^
;
_gameShot::
    
    .ds     GAME_SHOT_PARAM_SIZE * GAME_SHOT_SIZE



