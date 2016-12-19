; Game.s : �Q�[��
;


; ���W���[���錾
;
    .module Game

; �Q�ƃt�@�C��
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Ground.inc"
    .include    "Star.inc"
    .include    "Ship.inc"
    .include    "Shot.inc"
    .include    "Enemy.inc"
    .include    "Bullet.inc"

; �O���ϐ��錾
;

; �}�N���̒�`
;

; ���
GAME_STATE_NULL         =   0x00
GAME_STATE_PLAY         =   0x10
GAME_STATE_OVER         =   0x20


; CODE �̈�
;
    .area   _CODE

; �Q�[��������������
;
_GameInitialize::
    
    ; ���W�X�^�̕ۑ�
    
    ; �Q�[���̏�����
    
    ; �n�ʂ̏�����
    call    _GroundInitialize
    
    ; ���̏�����
    call    _StarInitialize
    
    ; ���@�̏�����
    call    _ShipInitialize
    
    ; �V���b�g�̏�����
    call    _ShotInitialize
    
    ; �G�̏�����
    call    _EnemyInitialize
    
    ; �e�̏�����
    call    _BulletInitialize
    
    ; �ꎞ��~�̏�����
    xor     a
    ld      (gamePause), a
    
    ; �X�R�A�̏�����
    ld      hl, #(gameScore + 0x0000)
    ld      de, #(gameScore + 0x0001)
    ld      bc, #0x0005
    xor     a
    ld      (hl), a
    ldir
    ld      (gameScorePlus), a
    
    ; �X�N���[���̏�����
    xor     a
    ld      (_gameScroll), a
    
    ; �p�^�[���̃N���A
    ld      hl, #(_appPatternName + 0x0000)
    ld      de, #(_appPatternName + 0x0001)
    ld      bc, #0x02ff
    xor     a
    ld      (hl), a
    ldir
    
    ; �p�^�[���l�[���̓]��
    call    _AppTransferPatternName
    
;   ; �`��̊J�n
;   ld      hl, #(_videoRegister + VDP_R1)
;   set     #VDP_R1_BL, (hl)
    
;   ; �r�f�I���W�X�^�̓]��
;   ld      hl, #_request
;   set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; ��Ԃ̐ݒ�
    ld      a, #GAME_STATE_PLAY
    ld      (gameState), a
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_appState), a
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �Q�[�����X�V����
;
_GameUpdate::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; ESC �L�[�ňꎞ��~
    ld      a, (_input + INPUT_BUTTON_ESC)
    cp      #0x01
    jr      nz, 09$
    ld      hl, #gamePause
    sub     (hl)
    ld      (hl), a
    or      a
    jr      z, 00$
    call    _SystemSuspendSound
    jr      09$
00$:
    call    _SystemResumeSound
;   jr      09$
09$:
    ld      a, (gamePause)
    or      a
    jr      nz, 99$
    
    ; �����̍X�V
    call    _SystemGetRandom
    
    ; ��ԕʂ̏���
    ld      a, (gameState)
    and     #0xf0
    cp      #GAME_STATE_PLAY
    jr      nz, 10$
    call    GamePlay
    jr      19$
10$:
;   cp      #GAME_STATE_OVER
;   jr      nz, 19$
    call    GameOver
;   jr      19$
19$:
    
    ; �X�V�̊���
99$:
    
    ; ���W�X�^�̕��A
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; �I��
    ret
    
; �Q�[�����v���C����
;
GamePlay:
    
    ; ���W�X�^�̕ۑ�
    
    ; �������̊J�n
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$
    
    ; �`��̊J�n
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; �r�f�I���W�X�^�̓]��
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; �a�f�l�̍Đ�
    ld      hl, #gamePlayBgm0
    ld      (_soundRequest + 0x0000), hl
    ld      hl, #gamePlayBgm1
    ld      (_soundRequest + 0x0002), hl
    ld      hl, #gamePlayBgm2
    ld      (_soundRequest + 0x0004), hl
    
    ; �������̊���
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; �X�v���C�g�̃N���A
    call    _SystemClearSprite
    
    ; ���Z�����X�R�A�̃N���A
    xor     a
    ld      (gameScorePlus), a
    
    ; �X�N���[���̍X�V
    ld      hl, #_gameScroll
    ld      a, (hl)
    inc     a
    and     #0x0f
    ld      (hl), a
    
    ; �q�b�g�`�F�b�N
    call    GameHitCheck
    
    ; �n�ʂ̍X�V
    call    _GroundUpdate
    
    ; ���̍X�V
    call    _StarUpdate
    
    ; ���@�̍X�V
    call    _ShipUpdate
    
    ; �V���b�g�̍X�V
    call    _ShotUpdate
    
    ; �G�̍X�V
    call    _EnemyUpdate
    
    ; �e�̍X�V
    call    _BulletUpdate
    
    ; �n�ʂ̕`��
    call    _GroundRender
    
    ; ���̕`��
    call    _StarRender
    
    ; ���@�̕`��
    call    _ShipRender
    
    ; �V���b�g�̕`��
    call    _ShotRender
    
    ; �G�̕`��
    call    _EnemyRender
    
    ; �e�̕`��
    call    _BulletRender
    
    ; �X�R�A�̍X�V
    call    GameUpdateScore
    
    ; �p�^�[���l�[���̓]��
    call    _AppTransferPatternName
    
    ; �Q�[���I�[�o�[�̏���
    ld      a, (_ship + SHIP_TYPE)
    or      a
    jr      nz, 19$
    
    ; �Q�[���I�[�o�[
    ld      a, #GAME_STATE_OVER
    ld      (gameState), a
19$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �Q�[���I�[�o�[�ɂȂ�
;
GameOver:
    
    ; ���W�X�^�̕ۑ�
    
    ; �������̊J�n
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$
    
    ; �Q�[���I�[�o�[�̕\��
    ld      hl, #gameOverString
    ld      de, #(_appPatternName + 0x016b)
    ld      bc, #0x000a
    ldir
    
    ; �p�^�[���l�[���̓]��
    call    _AppTransferPatternName

    ; �a�f�l�̍Đ�
    ld      hl, #gameOverBgm0
    ld      (_soundRequest + 0x0000), hl
    ld      hl, #gameOverBgm1
    ld      (_soundRequest + 0x0002), hl
    ld      hl, #gameOverBgm2
    ld      (_soundRequest + 0x0004), hl
    
    ; �������̊���
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; �a�f�l�̊Ď�
    ld      hl, (_soundRequest + 0x0000)
    ld      a, h
    or      l
    jr      nz, 19$
    ld      hl, (_soundPlay + 0x0000)
    ld      a, h
    or      l
    jr      nz, 19$
    
    ; �^�C�g���֖߂�
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_appState), a
19$:

    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �q�b�g�`�F�b�N���s��
;
GameHitCheck:
    
    ; ���W�X�^�̕ۑ�
    
    ; �V���b�g�̃`�F�b�N
    ld      ix, #_shot
    ld      bc, #(SHOT_N << 8)
10$:
    ld      a, SHOT_STATE(ix)
    or      a
    jr      z, 19$
    ld      a, SHOT_POSITION_Y(ix)
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
    ld      hl, #_enemyCollision
    add     hl, de
    ld      a, (hl)
    or      a
    jr      z, 11$
    dec     a
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      iy, #_enemy
    add     iy, de
    dec     ENEMY_HP(iy)
    jr      nz, 18$
    ld      a, #ENEMY_TYPE_BOMB
    ld      ENEMY_TYPE(iy), a
    xor     a
    ld      ENEMY_STATE(iy), a
    inc     c
    jr      18$
11$:
    ld      hl, #_ground
    add     hl, de
    ld      a, (hl)
    or      a
    jr      z, 19$
18$:
    xor     a
    ld      SHOT_STATE(ix), a
19$:
    ld      de, #SHOT_SIZE
    add     ix, de
    djnz    10$
    
    ; ���Z�����X�R�A�̐ݒ�
    ld      a, c
    ld      (gameScorePlus), a
    
    ; �e�̃`�F�b�N
    ld      ix, #_bullet
    ld      iy, #_ship
    ld      a, (_bulletN)
    ld      b, a
20$:
    ld      a, BULLET_STATE(ix)
    or      a
    jr      z, 29$
    ld      a, BULLET_POSITION_YI(ix)
    and     #0xf8
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, BULLET_POSITION_XI(ix)
    srl     e
    srl     e
    srl     e
    add     a, e
    ld      e, a
    ld      hl, #_ground
    add     hl, de
    ld      a, (hl)
    or      a
    jr      nz, 28$
    ld      a, SHIP_TYPE(iy)
    cp      #SHIP_TYPE_VICVIPER
    jr      nz, 29$
    ld      a, SHIP_POSITION_X(iy)
    sub     BULLET_POSITION_XI(ix)
    jr      c, 21$
    cp      #0x04
    jr      nc, 29$
    jr      22$
21$:
    cp      #0xfc
    jr      c, 29$
22$:
    ld      a, SHIP_POSITION_Y(iy)
    sub     BULLET_POSITION_YI(ix)
    jr      c, 23$
    cp      #0x04
    jr      nc, 29$
    jr      24$
23$:
    cp      #0xfc
    jr      c, 29$
24$:
;   dec     SHIP_HP(iy)
;   jr      nz, 28$
    ld      a, #SHIP_TYPE_BOMB
    ld      SHIP_TYPE(iy), a
    xor     a
    ld      SHIP_STATE(iy), a
28$:
    xor     a
    ld      BULLET_STATE(ix), a
29$:
    ld      de, #SHOT_SIZE
    add     ix, de
    djnz    20$
    
    ; ���@�̃`�F�b�N
    ld      ix, #_ship
    ld      a, SHIP_TYPE(ix)
    cp      #SHIP_TYPE_VICVIPER
    jr      nz, 39$
    ld      a, SHIP_POSITION_Y(ix)
    and     #0xf8
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, SHIP_POSITION_X(ix)
    srl     e
    srl     e
    srl     e
    add     a, e
    ld      e, a
    ld      hl, #_enemyCollision
    add     hl, de
    ld      a, (hl)
    or      a
    jr      nz, 38$
    ld      hl, #_ground
    add     hl, de
    ld      a, (hl)
    or      a
    jr      z, 39$
38$:
;   dec     SHIP_HP(iy)
;   jr      nz, 39$
    ld      a, #SHIP_TYPE_BOMB
    ld      SHIP_TYPE(iy), a
    xor     a
    ld      SHIP_STATE(iy), a
39$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �X�R�A���X�V����
;
GameUpdateScore:
    
    ; ���W�X�^�̕ۑ�
    
    ; �X�R�A�̍X�V
    ld      a, (gameScorePlus)
    or      a
    jr      z, 09$
    ld      hl, #(gameScore + 0x0005)
    ld      b, #0x06
00$:
    add     a, (hl)
    ld      (hl), a
    sub     #0x0a
    jr      c, 01$
    ld      (hl), a
    dec     hl
    ld      a, #0x01
    djnz    00$
    ld      hl, #(gameScore + 0x0000)
    ld      de, #(gameScore + 0x0001)
    ld      bc, #0x0005
    ld      a, #0x09
    ld      (hl), a
    ldir
01$:
    ld      hl, #gameScore
    ld      de, #_appScore
    ld      b, #0x06
02$:
    ld      a, (de)
    cp      (hl)
    jr      c, 03$
    jr      nz, 09$
    inc     hl
    inc     de
    djnz    02$
    jr      09$
03$:
    ld      hl, #gameScore
    ld      de, #_appScore
    ld      bc, #0x0006
    ldir
09$:
    
    ; ����������̓]��
    ld      hl, #gameScoreString
    ld      de, #(_appPatternName + 0x0000)
    ld      bc, #0x0020
    ldir
    
    ; �X�R�A�̕`��
    ld      hl, #gameScore
    ld      de, #(_appPatternName + 0x0003)
    ld      b, #0x06
10$:
    ld      a, (hl)
    or      a
    jr      nz, 11$
    inc     hl
    inc     de
    djnz    10$
    jr      19$
11$:
    ld      a, (hl)
    add     a, #0x10
    ld      (de), a
    inc     hl
    inc     de
    djnz    11$
    ld      a, #0x10
    ld      (de), a
19$:
    
    ; �n�C�X�R�A�̕`��
    ld      hl, #_appScore
    ld      de, #(_appPatternName + 0x000f)
    ld      b, #0x06
20$:
    ld      a, (hl)
    or      a
    jr      nz, 21$
    inc     hl
    inc     de
    djnz    20$
    jr      29$
21$:
    ld      a, (hl)
    add     a, #0x10
    ld      (de), a
    inc     hl
    inc     de
    djnz    21$
    ld      a, #0x10
    ld      (de), a
29$:
    
    ; ���x�̕`��
    ld      a, (_ship + SHIP_SPEED)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameSpeedString
    add     hl, de
    ld      de, #(_appPatternName + 0x1d)
    ld      bc, #0x0002
    ldir
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �萔�̒�`
;

; �X�R�A
;
gameScoreString:

    .db     0x11, 0x30, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00
    .db     0x28, 0x29, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

; ���x
;
gameSpeedString:

    .db     0x00, 0x00
    .db     0x00, 0x46
    .db     0x00, 0x47
    .db     0x46, 0x47
    .db     0x47, 0x47

; ����
;
gamePlayBgm0:

    .ascii  "T2V15-L1"
;   .ascii  "O3G5G4O4CF3E5C3"
;   .ascii  "O4G4O3B-B-6GA-B-O4E-FG"
;   .ascii  "O4C4O3A4O4C5F3O3ABO4CD"
;   .ascii  "O4E-3CO3ARO4E-3CF3DO3B-RO4DF3"
;   .ascii  "O3G5G4O4CF3E5C3"
;   .ascii  "O4G4O3B-B-6GA-B-O4E-FG"
;   .ascii  "O4A3CC4F3G3A5F3"
;   .ascii  "O4D4G8R"
;   .ascii  "O5E-4C4E-6CDE-3"
;   .ascii  "O5D4O4B-4G7R3"
;   .ascii  "O5C4O4A4O5CCD4O4B4O5DD"
;   .ascii  "O5E-4C4E-FF4D4G9R3"
    .ascii  "O4F3DRO3B-O4DF3CE-3RO3AO4CE-3"
    .ascii  "O4DCO3BAO4F3C5O3A4O4C4"
    .ascii  "O4GFE-O3B-A-GB-6B-O4G4"
    .ascii  "O4C3E5F3CO3G4G5"
    .ascii  "O4G8RD4"
    .ascii  "O4F3A5G3F3C4CA3"
    .ascii  "O4GFE-O3B-A-GB-6B-O4G4"
    .ascii  "O4C3E5F3CO3G4G5"
    .ascii  "O5G9R3D4F4FE-C4E-4"
    .ascii  "O5DDO4B4O5D4CCO4A4O5C4"
    .ascii  "O4G7R3B-4O5D4"
    .ascii  "O5E-3DCE-6C4E-4"
    .db     0xff

gamePlayBgm1:

    .ascii  "T2V14-L1"
;   .ascii  "O5CO4BAGFGABO5CO4BAGFGAB"
;   .ascii  "O5CO4B-A-GFGA-B-O5CO4B-A-GFGA-B-"
;   .ascii  "O5CO4BAGFGABO5CO4BAGFGAB"
;   .ascii  "O5CO4B-A-GFGA-B-O5CDE-DCO4B-A-B-"
;   .ascii  "O5CO4BAGFGABO5CO4BAGFGAB"
;   .ascii  "O5CO4B-A-GFGA-B-O5CO4B-A-GFGA-B-"
;   .ascii  "O5CO4BAGFGABO5CO4BAGFGAF"
;   .ascii  "O5DCO4BAGABO5CDCO4BAGBO5DG"
;   .ascii  "V15-"
;   .ascii  "O4C4E-4A-7R3"
;   .ascii  "O3B-4O4D4E-7R3"
;   .ascii  "O3AB-O4CF5RO3BO4CDG5R"
;   .ascii  "O4CDE-A-5RDE-FB-4O5C7R3O4B7"
    .ascii  "O4B-A-B-O5CDE-DCO4B-A-GFGA-B-O5C"
    .ascii  "O4BAGFGABO5CO4BAGFGABO5C"
    .ascii  "O4B-A-GFGA-B-O5CO4B-A-GFGA-B-O5C"
    .ascii  "O4BAGFGABO5CO4BAGFGABO5C"
    .ascii  "O5GDO4BGABO5CDCO4BAGABO5CD"
    .ascii  "O4FAGFGABO5CO4BAGFGABO5C"
    .ascii  "O4B-A-GFGA-B-O5CO4B-A-GFGA-B-O5C"
    .ascii  "O4BAGFGABO5CO4BAGFGABO5C"
    .ascii  "V15-"
    .ascii  "O4B7O5C7R3O4B-4FE-DA-5RE-DC"
    .ascii  "O4G5RDCO3BO4F5RCO3B-A"
    .ascii  "O4E-7R3D4O3B-4"
    .ascii  "O4A-7R3E-4C4"
    .db     0xff

    
gamePlayBgm2:

    .ascii  "T2V15-L1"
;   .ascii  "O2C3O3CCO2C3O3CCO2C3O3CCO2C3O3CC"
;   .ascii  "O2E-3O3E-E-O2E-3O3E-E-O2E-3O3E-E-O2E-3O3E-E-"
;   .ascii  "O2F3O3FFO2F3O3FFO2F3O3FFO2F3O3FF"
;   .ascii  "O2A-3O3A-A-O2A-3O3A-A-O2A-3O3A-A-O2A-3O3A-A-"
;   .ascii  "O2C3O3CCO2C3O3CCO2C3O3CCO2C3O3CC"
;   .ascii  "O2E-3O3E-E-O2E-3O3E-E-O2E-3O3E-E-O2E-3O3E-E-"
;   .ascii  "O2F3O3FFO2F3O3FFO2F3O3FFO2F3O3FF"
;   .ascii  "O2G3O3GGO2G3O3GGO2G3O3GGO2G3O3GG"
;   .ascii  "O2A-O3A-E-A-O2A-O3A-E-A-O2A-O3A-E-A-O2A-O3A-E-A-"
;   .ascii  "O2E-O3E-O2B-O3E-O2E-O3E-O2B-O3E-O2E-O3E-O2B-O3E-O2E-O3E-O2B-O3E-"
;   .ascii  "O2FO3FCFO2FO3FCFO2GO3GDGO2GO3GDG"
;   .ascii  "O2A-O3A-E-A-O2A-O3A-E-A-O2B-O3B-FB-O2B-O3B-FB-"
;   .ascii  "O2G3O3GGO2G3O3GGO2G3O3GGO2G3O3GG"
    .ascii  "O3A-A-O2A-3O3A-A-O2A-3O3A-A-O2A-3O3A-A-O2A-3"
    .ascii  "O3FFO2F3O3FFO2F3O3FFO2F3O3FFO2F3"
    .ascii  "O3E-E-O2E-3O3E-E-O2E-3O3E-E-O2E-3O3E-E-O2E-3"
    .ascii  "O3CCO2C3O3CCO2C3O3CCO2C3O3CCO2C3"
    .ascii  "O3GGO2G3O3GGO2G3O3GGO2G3O3GGO2G3"
    .ascii  "O3FFO2F3O3FFO2F3O3FFO2F3O3FFO2F3"
    .ascii  "O3E-E-O2E-3O3E-E-O2E-3O3E-E-O2E-3O3E-E-O2E-3"
    .ascii  "O3CCO2C3O3CCO2C3O3CCO2C3O3CCO2C3"
    .ascii  "O3GGO2G3O3GGO2G3O3GGO2G3O3GGO2G3"
    .ascii  "O3B-FB-O2B-O3B-FB-O2B-O3A-E-A-O2A-O3A-E-A-O2A-"
    .ascii  "O3GDGO2GO3GDGO2GO3FCFO2FO3FCFO2F"
    .ascii  "O3E-O2B-O3E-O2E-O3E-O2B-O3E-O2E-O3E-O2B-O3E-O2E-O3E-O2B-O3E-O2E-"
    .ascii  "O3A-E-A-O2A-O3A-E-A-O2A-O3A-E-A-O2A-O3A-E-A-O2A-"
    .db     0xff

; �Q�[���I�[�o�[
;
gameOverString:

    .db     0x27, 0x21, 0x2d, 0x25, 0x00, 0x00, 0x2f, 0x36, 0x25, 0x32

gameOverBgm0:

    .ascii  "T2V15-L1"
;   .ascii  "O4GECGECGECGEC"
;   .ascii  "O5CO4GEO5CO4GEO5CO4GEO5CO4GE"
;   .ascii  "O5ECO4GEGO5CGECO4GO5CE"
;   .ascii  "O6CO5GEGECE6"
    .ascii  "O5E6CEGEGO6C"
    .ascii  "O5ECO4GO5CEGCO4GEGO5CE"
    .ascii  "O4EGO5CO4EGO5CO4EGO5CO4EGO5C"
    .ascii  "O4CEGCEGCEGCEG"
    .db     0x00

gameOverBgm1:

    .ascii  "T2V15-L1"
;   .ascii  "O4CO3GEO4CO3GEO4CO3GEO4CO3GE"
;   .ascii  "O4ECO3GO4ECO3GO4ECO3GO4ECO3G"
;   .ascii  "O4GECO3GO4CEO5CO4GECEG"
;   .ascii  "O5ECO4GO5CO4GEG6"
    .ascii  "O4G6EGO5CO4GO5CE"
    .ascii  "O4GECEGO5CO4ECO3GO4CEG"
    .ascii  "O3GO4CEO3GO4CEO3GO4CEO3GO4CE"
    .ascii  "O3EGO4CO3EGO4CO3EGO4CO3EGO4C"
    .db     0x00

gameOverBgm2:

    .ascii  "T2V15-L1"
;   .ascii  "O2C5CCC4O1G3"
;   .ascii  "O2E5EEE4C3"
;   .ascii  "O2G5GGG4C3"
;   .ascii  "O3C5O2CCC4R3"
    .ascii  "O2C4R3CCO3C5"
    .ascii  "O2C3G4GGG5"
    .ascii  "O2C3E4EEE5"
    .ascii  "O1G3O2C4CCC5"
    .db     0x00


; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

; ���
;
gameState:
    
    .ds     1

; �ꎞ��~
;
gamePause:

    .ds     1
    
; �^�C�}
;
gameTimer:

    .ds     1
    
; �X�R�A
;
gameScore:

    .ds     6

gameScorePlus:

    .ds     1

; �X�N���[��
;
_gameScroll::

    .ds     1
