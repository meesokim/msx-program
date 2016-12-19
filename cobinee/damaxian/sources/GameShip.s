; GameShip.s : �Q�[����ʁ^���@
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


; ���@������������
;
_GameShipInitialize::
    
    ; ��Ԃ̐ݒ�
    ld      a, #GAME_SHIP_STATE_PLAY
    ld      (_gameShip + GAME_SHIP_PARAM_STATE), a
    xor     a
    ld      (_gameShip + GAME_SHIP_PARAM_PHASE), a
    
    ; �I��
    ret


; ���@���X�V����
;
_GameShipUpdate::
    
    ; ��Ԃ̎擾
    ld      a, (_gameShip + GAME_SHIP_PARAM_STATE)
    
    ; �Ȃ�
    cp      #GAME_SHIP_STATE_NULL
    jr      nz, 0$
    call    GameShipNull
    jr      GameUpdateEnd
0$:
    
    ; ����
    cp      #GAME_SHIP_STATE_PLAY
    jr      nz, 1$
    call    GameShipPlay
    jr      GameUpdateEnd
1$:
    
    ; ����
    cp      #GAME_SHIP_STATE_BOMB
    jr      nz, 2$
    call    GameShipBomb
    jr      GameUpdateEnd
2$:
    
    ; �X�V�̏I��
GameUpdateEnd:
    
    ; �I��
    ret


; ���@�͂Ȃ�
;
GameShipNull:
    
    ; ��Ԃ̎擾
    ld      a, (_gameShip + GAME_SHIP_PARAM_PHASE)
    or      a
    jr      nz, GameShipNullMain
    
    ; �m�[�_���[�W�̐ݒ�
    ld      a, #0x80
    ld      (_gameShip + GAME_SHIP_PARAM_NODAMAGE), a
    
    ; ��Ԃ̍X�V
    ld      hl, (_gameShip + GAME_SHIP_PARAM_PHASE)
    inc     (hl)
    
    ; �ҋ@�̏���
GameShipNullMain:
    
    ; �����̊���
GameShipNullDone:
    
    ; �`��̊J�n
    ld      a, #0xc0
    ld      (_sprite + GAME_SPRITE_SHIP + 0x00), a
    ld      (_sprite + GAME_SPRITE_SHIP + 0x01), a
    ld      (_sprite + GAME_SPRITE_SHIP + 0x02), a
    ld      (_sprite + GAME_SPRITE_SHIP + 0x03), a
    
    ; �����̏I��
GameShipNullEnd:
    
    ; �I��
    ret


; ���@�𑀍삷��
;
GameShipPlay:
    
    ; ��Ԃ̎擾
    ld      a, (_gameShip + GAME_SHIP_PARAM_PHASE)
    or      a
    jr      nz, GameShipPlayMain
    
    ; �ʒu�̐ݒ�
    ld      a, #0x60
    ld      (_gameShip + GAME_SHIP_PARAM_POINT_X), a
    ld      a, #0xc8
    ld      (_gameShip + GAME_SHIP_PARAM_POINT_Y), a
    
    ; �m�[�_���[�W�̐ݒ�
    ld      a, #0x80
    ld      (_gameShip + GAME_SHIP_PARAM_NODAMAGE), a
    
    ; ��Ԃ̍X�V
    ld      hl, #(_gameShip + GAME_SHIP_PARAM_PHASE)
    inc     (hl)
    
    ; �ҋ@����
GameShipPlayMain:
    
    ; �m�[�_���[�W�̍X�V
    ld      hl, #(_gameShip + GAME_SHIP_PARAM_NODAMAGE)
    ld      a, (hl)
    or      a
    jr      z, 00$
    dec     (hl)
00$:
    
    ; ���@���ʒu�Ɉړ�
    ld      hl, #(_gameShip + GAME_SHIP_PARAM_POINT_Y)
    ld      a, (hl)
    cp      #0xb1
    jr      c, GameShipPlayMove
    dec     (hl)
    jr      GameShipPlayDone
    
    ; �ړ�����
GameShipPlayMove:
    
    ; ����\���ǂ���
    ld      hl, #_gameFlag
    bit     #GAME_FLAG_PLAYABLE, (hl)
    jr      z, GameShipPlayDone
    
    ; �w�����̈ړ�
    ld      hl, #(_gameShip + GAME_SHIP_PARAM_POINT_X)
    
    ; ���������ꂽ
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 10$
    ld      a, (hl)
    cp      #(0x08 + 2)
    jr      c, 10$
    dec     (hl)
    dec     (hl)
    jr      GameShipPlayShot
10$:
    
    ; ���������ꂽ
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 11$
    ld      a, (hl)
    cp      #(0xb8 - 0)
    jr      nc, 11$
    inc     (hl)
    inc     (hl)
11$:
    
    ; ���ˏ���
GameShipPlayShot:
    
    ; A �{�^���������ꂽ
    ld      a, (_input + INPUT_BUTTON_SPACE)
    cp      #0x01
    jr      nz, GameShipPlayDone
    
    ; �V���b�g�̃G���g��
    call    _GameShotEntry
    
    ; �����̊���
GameShipPlayDone:
    
    ; �`��̊J�n
    ld      a, (_gameShip + GAME_SHIP_PARAM_NODAMAGE)
    and     #0b00000010
    sla     a
    ld      c, a
    ld      b, #0x00
    ld      hl, #shipSpriteTable
    add     hl, bc
    ld      de, #(_sprite + GAME_SPRITE_SHIP)
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_X)
    ld      b, a
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_Y)
    ld      c, a
    call    _SystemSetSprite
    
    ; �����̏I��
GameShipPlayEnd:
    
    ; �I��
    ret


; ���@����������
;
GameShipBomb::
    
    ; ��Ԃ̎擾
    ld      a, (_gameShip + GAME_SHIP_PARAM_PHASE)
    or      a
    jr      nz, GameShipBombMain
    
    ; �m�[�_���[�W�̐ݒ�
    ld      a, #0x80
    ld      (_gameShip + GAME_SHIP_PARAM_NODAMAGE), a
    
    ; �A�j���[�V�����̐ݒ�
    xor     a
    ld      (_gameShip + GAME_SHIP_PARAM_ANIMATION), a
    
    ; ���t�̊J�n
    ld      hl, #mmlBombChannel0
    ld      (_soundRequest + 0), hl
    
    ; ��Ԃ̍X�V
    ld      hl, #(_gameShip + GAME_SHIP_PARAM_PHASE)
    inc     (hl)
    
    ; �����̏���
GameShipBombMain:
    
    ; �A�j���[�V�����̍X�V
    ld      hl, #(_gameShip + GAME_SHIP_PARAM_ANIMATION)
    inc     (hl)
    ld      a, (hl)
    cp      #0x1f
    jr      nz, GameShipBombDone
    
    ; ��Ԃ̍X�V
    ld      a, #GAME_SHIP_STATE_PLAY
    ld      (_gameShip + GAME_SHIP_PARAM_STATE), a
    xor     a
    ld      (_gameShip + GAME_SHIP_PARAM_PHASE), a
    
    ; �����̊���
GameShipBombDone:
    
    ; �`��̊J�n
    ld      a, (_gameShip + GAME_SHIP_PARAM_ANIMATION)
    and     #0b00011000
    srl     a
    ld      c, a
    ld      b, #0x00
    ld      hl, #bombSpriteTable
    add     hl, bc
    ld      de, #(_sprite + GAME_SPRITE_SHIP)
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_X)
    ld      b, a
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_Y)
    ld      c, a
    call    _SystemSetSprite
    
    ; �����̏I��
GameShipBombEnd:
    
    ; �I��
    ret


; �萔�̒�`
;

; ���@�f�[�^
;
shipSpriteTable:
    
    .db     0xf8, 0xf8, 0x00, 0x0f
    .db     0xf8, 0xf8, 0x04, 0x0f

; �����f�[�^
;
bombSpriteTable:
    
    .db     0xf8, 0xf8, 0x10, 0x06
    .db     0xf8, 0xf8, 0x14, 0x0a
    .db     0xf8, 0xf8, 0x18, 0x06
    .db     0xf8, 0xf8, 0x1c, 0x0f

; MML �f�[�^
;
mmlBombChannel0:
    
    .ascii  "T1V15L0"
    .ascii  "O4CO3BAGABO4CDEFGG#R1GFEDCDFGABO5CC#R1CO4BAGAO5CDEGG#R1GFEDCDFGABO6CDO5A#"
    .db     0x00



; DATA �̈�
;
    .area   _DATA


; �ϐ��̒�`
;

; �p�����[�^
;
_gameShip::
    
    .ds     GAME_SHIP_PARAM_SIZE



