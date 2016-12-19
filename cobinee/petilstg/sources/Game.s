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
    .include    "Unit.inc"
    .include    "Enemy.inc"
    .include    "Player.inc"
    .include    "Eshot.inc"
    .include    "Pshot.inc"
    .include	"Cockpit.inc"
    .include	"Star.inc"
    .include	"Text.inc"
    .include    "Demo.inc"

; �}�N���̒�`
;

; ���
GAME_STATE_NULL     =   0x00
GAME_STATE_TITLE    =   0x10
GAME_STATE_START    =   0x20
GAME_STATE_PLAY     =   0x30
GAME_STATE_CLEAR    =   0x40
GAME_STATE_OVER     =   0x50

; �v���Z�X
GAME_PROCESS_NULL       =   0b00000000
GAME_PROCESS_UNIT       =   0b00000001
GAME_PROCESS_ENEMY      =   0b00000010
GAME_PROCESS_ESHOT      =   0b00000100
GAME_PROCESS_PSHOT      =   0b00001000
GAME_PROCESS_PLAYER     =   0b00010000
GAME_PROCESS_DEMO       =   0b00100000
GAME_PROCESS_COCKPIT    =   0b00000000
GAME_PROCESS_STAR       =   0b00000000
GAME_PROCESS_TEXT       =   0b00000000


; CODE �̈�
;
    .area   _CODE

; �Q�[��������������
;
_GameInitialize::
    
    ; ���W�X�^�̕ۑ�
    
    ; �Q�[���̏�����
    xor     a
    ld      (gameProcess), a
    ld      (gameTimer + 0), a
    ld      (gameTimer + 1), a
    ld      (_gameFrame), a
    ld      (_gameRotateY), a
    ld      (_gameRotateX), a
    ld      (_gameSightX), a
    ld      (_gameSightY), a
    ld      (_gameMoveZ), a
    ld      (_gameAccel), a
    ld      (_gameFire), a
    
    ; ���j�b�g�̏�����
    call    _UnitInitialize
    
    ; �G�l�~�[�V���b�g�̏�����
    call    _EshotInitialize
    
    ; �v���C���[�V���b�g�̏�����
    call    _PshotInitialize
    
    ; �G�l�~�[�̏�����
    call    _EnemyInitialize
    
    ; �v���C���[�̏�����
    call    _PlayerInitialize
    
    ; �R�N�s�b�g�̏�����
    call    _CockpitInitialize
    
    ; �X�^�[�̏�����
    call    _StarInitialize
    
    ; �e�L�X�g�̏�����
    call    _TextInitialize
    
    ; �f���̏�����
    call    _DemoInitialize
    
    ; �X�v���C�g�W�F�l���[�^�̐ݒ�
    ld      a, #(APP_SPRITE_GENERATOR_TABLE_0 >> 11)
    ld      (_videoRegister + VDP_R6), a
    
    ; �`��̊J�n
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; �r�f�I���W�X�^�̓]��
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; ��Ԃ̐ݒ�
    ld      a, #GAME_STATE_TITLE
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
    
    ; �X�v���C�g�̃N���A
    call    _SystemClearSprite
    ld      hl, #(_sprite + GAME_SPRITE_MASK)
    ld      de, #0x0080
    ld      bc, #0x040c
00$:
    ld      (hl), e
    inc     hl
    ld      (hl), d
    inc     hl
    ld      (hl), d
    inc     hl
    ld      (hl), d
    inc     hl
    djnz    00$
    
    ; ��ԕʂ̏���
    ld      a, (gameState)
    and     #0xf0
    cp      #GAME_STATE_TITLE
    jr      nz, 10$
    call    GameTitle
    jr      19$
10$:
    ld      a, (gameState)
    and     #0xf0
    cp      #GAME_STATE_START
    jr      nz, 11$
    call    GameStart
    jr      19$
11$:
    cp      #GAME_STATE_PLAY
    jr      nz, 12$
    call    GamePlay
    jr      19$
12$:
    cp      #GAME_STATE_CLEAR
    jr      nz, 13$
    call    GameClear
    jr      19$
13$:
    cp      #GAME_STATE_OVER
    jr      nz, 19$
    call    GameOver
19$:
    
    ; ����
    call    GameControl
    
    ; �q�b�g�`�F�b�N
    ld      a, (gameProcess)
    and     #GAME_PROCESS_PSHOT
    call    nz, _PshotHit
    
    ; �v���Z�X�̍X�V�i�擪�j
    ld      a, (gameProcess)
    and     #GAME_PROCESS_UNIT
    call    nz, _UnitUpdate
    ld      a, (gameProcess)
    and     #GAME_PROCESS_ESHOT
    call    nz, _EshotUpdate
    ld      a, (gameProcess)
    and     #GAME_PROCESS_PSHOT
    call    nz, _PshotUpdate
    ld      a, (gameProcess)
    and     #GAME_PROCESS_ENEMY
    call    nz, _EnemyUpdate
    ld      a, (gameProcess)
    and     #GAME_PROCESS_PLAYER
    call    nz, _PlayerUpdate
    
    ; �v���Z�X�̍X�V�i���ʁj
    call    _CockpitUpdate
    call    _StarUpdate
    call    _TextUpdate
    
    ; �v���Z�X�̍X�V�i���[�j
    ld      a, (gameProcess)
    and     #GAME_PROCESS_DEMO
    call    nz, _DemoUpdate
    
    ; �v���Z�X�̕`��i�擪�j
    ld      a, (gameProcess)
    and     #GAME_PROCESS_UNIT
    call    nz, _UnitRender
    ld      a, (gameProcess)
    and     #GAME_PROCESS_ESHOT
    call    nz, _EshotRender
    ld      a, (gameProcess)
    and     #GAME_PROCESS_PSHOT
    call    nz, _PshotRender
    ld      a, (gameProcess)
    and     #GAME_PROCESS_ENEMY
    call    nz, _EnemyRender
    ld      a, (gameProcess)
    and     #GAME_PROCESS_PLAYER
    call    nz, _PlayerRender
    
    ; �v���Z�X�̕`��i���ʁj
    call    _CockpitRender
    call    _StarRender
    call    _TextRender
    
    ; �v���Z�X�̕`��i���[�j
    ld      a, (gameProcess)
    and     #GAME_PROCESS_DEMO
    call    nz, _DemoRender
    
    ; �p�^�[���l�[���̓]��
    xor     a
    ld      hl, #(_gamePatternName + 0x0000)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0000)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES), a
    ld      hl, #(_gamePatternName + 0x0100)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0100)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_BYTES), a
    ld      hl, #(_gamePatternName + 0x0200)
    ld      a, (_playerHitCount)
    and     #0x01
    jr      z, 30$
    inc     hl
30$:
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0200)
    ld      c, #0x00
    ld      a, (_playerHitCount)
    or      a
    jr      z, 31$
    dec     c
    and     #0x01
    jr      nz, 31$
    inc     hl
31$:
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_DST), hl
    ld      a, c
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)
    
    ; �q�b�g�̕`��
    ld      a, (_playerHitCount)
    or      a
    jr      z, 40$
    ld      a, #0x08
40$:
    ld      (_videoRegister + VDP_R7), a
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; �t���[���̍X�V
    ld      hl, #_gameFrame
    inc     (hl)
    
    ; ���W�X�^�̕��A
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; �I��
    ret
    
; �^�C�g����\������
;
GameTitle:
    
    ; ���W�X�^�̕ۑ�
    
    ; �������̊J�n
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$
    
    ; �v���Z�X�̐ݒ�
    ld      a, #GAME_PROCESS_DEMO
    ld      (gameProcess), a
    
    ; �v���Z�X�̃��Z�b�g
    call    _UnitReset
    call    _EshotReset
    call    _PshotReset
    call    _EnemyReset
    call    _PlayerReset
    call    _DemoReset
    
    ; �e�L�X�g�̃N���A
    ld      hl, #0x0000
    ld      (_textString), hl
    
    ; �a�f�l�̐ݒ�
    ld      hl, #gameBgmTitle0
    ld      (_soundRequest + 0), hl
    ld      hl, #gameBgmTitle1
    ld      (_soundRequest + 2), hl
    ld      hl, #gameBgmTitle2
    ld      (_soundRequest + 4), hl
    
    ; �������̊���
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; �f���̊Ď�
    ld      a, (_demoState)
    or      a
    jr      nz, 19$
    ld      a, #GAME_STATE_TITLE
    ld      (gameState), a
19$:
    
    ; �L�[���͑҂�
    ld      a, (_input + INPUT_BUTTON_SPACE)
    cp      #0x01
    jr      nz, 29$
    ld      a, #GAME_STATE_START
    ld      (gameState), a
29$:
    
    ; �����̑���
    call    _SystemGetRandom
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �Q�[�����J�n����
;
GameStart:
    
    ; ���W�X�^�̕ۑ�
    
    ; �������̊J�n
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$
    
    ; �v���Z�X�̐ݒ�
    ld      a, #GAME_PROCESS_NULL
    ld      (gameProcess), a
    
    ; ���[�v���o�̐ݒ�
    xor     a
    ld      (_gameMoveZ), a
    ld      a, #0x01
    ld      (_gameAccel), a
    
    ; �e�L�X�g�̃N���A
    ld      hl, #0x0000
    ld      (_textString), hl
    
    ; �a�f�l�̐ݒ�
    ld      hl, #gameBgmStart0
    ld      (_soundRequest + 0), hl
    ld      hl, #gameBgmStart1
    ld      (_soundRequest + 2), hl
    ld      hl, #gameBgmStart2
    ld      (_soundRequest + 4), hl
    
    ; �������̊���
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; ���[�v�̊J�n
    ld      a, (gameState)
    and     #0x0f
    cp      #0x01
    jr      nz, 19$
    
    ; ����
    ld      hl, #_gameMoveZ
    ld      a, (hl)
    add     a, #0x02
    ld      (hl), a
    cp      #0x80
    jr      c, 19$
    
    ; �e�L�X�g�̐ݒ�
    ld      hl, #(_gamePatternName + (0x01 << 5) + 0x04)
    ld      (_textPosition), hl
    ld      hl, #gameStringStart
    ld      (_textString), hl
    xor     a
    ld      (_textLength), a
    
    ; ���[�v�J�n�̊���
    ld      hl, #gameState
    inc     (hl)
19$:
    
    ; �e�L�X�g�̕\��
    ld      a, (gameState)
    and     #0x0f
    cp      #0x02
    jr      nz, 29$
    
    ; �e�L�X�g�̊Ď�
    ld      a, (_textLength)
    cp      #0xc0
    jr      c, 29$
    
    ; �e�L�X�g�\���̊���
    ld      hl, #0x0000
    ld      (_textString), hl
    ld      hl, #gameState
    inc     (hl)
29$:
    
    ; ���[�v�̏I��
    ld      a, (gameState)
    and     #0x0f
    cp      #0x03
    jr      nz, 39$
    
    ; ����
    ld      hl, #_gameMoveZ
    ld      a, (hl)
    sub     #0x02
    ld      (hl), a
    jr      nz, 39$
    
    ; ���[�v�I���̊���
    ld      (_gameAccel), a
    ld      a, #GAME_STATE_PLAY
    ld      (gameState), a
39$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �Q�[�����v���C����
;
GamePlay::
    
    ; ���W�X�^�̕ۑ�
    
    ; �������̊J�n
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$
    
    ; �v���Z�X�̐ݒ�
    ld      a, #(GAME_PROCESS_UNIT + GAME_PROCESS_ENEMY + GAME_PROCESS_ESHOT + GAME_PROCESS_PSHOT + GAME_PROCESS_PLAYER)
    ld      (gameProcess), a
    
    ; �^�C�}�̐ݒ�
    ld      a, #0x20
    ld      (gameTimer + 0), a
    
    ; �e�L�X�g�̃N���A
    ld      hl, #0x0000
    ld      (_textString), hl
    
    ; �������̊���
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; �Q�[���̏I������
    ld      a, (_enemyKilled + UNIT_TYPE_KABAKALI)
    or      a
    jr      z, 10$
    ld      a, (_enemyBorned + UNIT_TYPE_NULL)
    ld      e, a
    ld      a, (_enemyKilled + UNIT_TYPE_NULL)
    cp      e
    jr      nz, 10$
    ld      a, #GAME_STATE_CLEAR
    ld      (gameState), a
    jr      90$
10$:
    ld      a, (_playerOver)
    or      a
    jr      z, 19$
    ld      a, #GAME_STATE_OVER
    ld      (gameState), a
    jr      90$
19$:

    ; �v���C�̊���
90$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �Q�[�����N���A����
;
GameClear:
    
    ; ���W�X�^�̕ۑ�
    
    ; �������̊J�n
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$
    
    ; �v���Z�X�̐ݒ�
    ld      a, #(GAME_PROCESS_UNIT + GAME_PROCESS_ENEMY + GAME_PROCESS_ESHOT + GAME_PROCESS_PSHOT)
    ld      (gameProcess), a
    
    ; ���[�v���o�̐ݒ�
    xor     a
    ld      (_gameMoveZ), a
    ld      a, #0x01
    ld      (_gameAccel), a
    
    ; �e�L�X�g�̃N���A
    ld      hl, #0x0000
    ld      (_textString), hl
    
    ; �a�f�l�̐ݒ�
    ld      hl, #gameBgmClear0
    ld      (_soundRequest + 0), hl
    ld      hl, #gameBgmClear1
    ld      (_soundRequest + 2), hl
    ld      hl, #gameBgmClear2
    ld      (_soundRequest + 4), hl
    
    ; �������̊���
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; ���[�v�̊J�n
    ld      a, (gameState)
    and     #0x0f
    cp      #0x01
    jr      nz, 19$
    
    ; ����
    ld      hl, #_gameMoveZ
    ld      a, (hl)
    add     a, #0x02
    ld      (hl), a
    cp      #0x80
    jr      c, 19$
    
    ; �e�L�X�g�̐ݒ�
    ld      hl, #(_gamePatternName + (0x01 << 5) + 0x06)
    ld      (_textPosition), hl
    ld      hl, #gameStringClear
    ld      (_textString), hl
    xor     a
    ld      (_textLength), a
    
    ; �v���Z�X�̐ݒ�
    ld      a, #GAME_PROCESS_NULL
    ld      (gameProcess), a
    
    ; ���[�v�J�n�̊���
    ld      hl, #gameState
    inc     (hl)
19$:
    
    ; �T�E���h�̍Đ�
    ld      a, (gameState)
    and     #0x0f
    cp      #0x02
    jr      nz, 29$
    
    ; �T�E���h�̊Ď�
    ld      hl, (_soundHead + 0x00)
    ld      a, h
    or      l
    jr      nz, 29$
    
    ; �T�E���h�Đ��̊���
    ld      hl, #0x0000
    ld      (_textString), hl
    ld      hl, #gameState
    inc     (hl)
29$:
    
    ; ���[�v�̏I��
    ld      a, (gameState)
    and     #0x0f
    cp      #0x03
    jr      nz, 39$
    
    ; ����
    ld      hl, #_gameMoveZ
    ld      a, (hl)
    sub     #0x02
    ld      (hl), a
    jr      nz, 39$
    ld      (_gameAccel), a
    
    ; ���[�v�I���̊���
    ld      a, #GAME_STATE_TITLE
    ld      (gameState), a
39$:
    
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
    
    ; �v���Z�X�̐ݒ�
    ld      a, #GAME_PROCESS_PLAYER
    ld      (gameProcess), a
    
    ; ���[�v���o�̐ݒ�
    xor     a
    ld      (_gameMoveZ), a
    ld      a, #0x01
    ld      (_gameAccel), a
    
    ; �^�C�}�̐ݒ�
    ld      a, #0x80
    ld      (gameTimer + 0), a
    
    ; �e�L�X�g�̃N���A
    ld      hl, #0x0000
    ld      (_textString), hl
    
    ; �a�f�l�̐ݒ�
    ld      hl, #gameBgmOver
    ld      (_soundRequest + 0), hl
    ld      (_soundRequest + 2), hl
    ld      (_soundRequest + 4), hl
    
    ; �������̊���
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; �^�C�}�҂�
    ld      a, (gameState)
    and     #0x0f
    cp      #0x01
    jr      nz, 19$
    
    ; �^�C�}�̊Ď�
    ld      hl, #(gameTimer + 0)
    dec     (hl)
    ld      a, (hl)
    jr      nz, 19$
    
    ; �e�L�X�g�̐ݒ�
    ld      a, (_playerOver)
    cp      #PLAYER_OVER_KILLED
    jr      nz, 10$
    ld      hl, #(_gamePatternName + (0x05 << 5) + 0x07)
    ld      (_textPosition), hl
    ld      hl, #gameStringOverKilled
    ld      (_textString), hl
    jr      11$
10$:
    ld      hl, #(_gamePatternName + (0x05 << 5) + 0x0a)
    ld      (_textPosition), hl
    ld      hl, #gameStringOverEmpty
    ld      (_textString), hl
11$:
    xor     a
    ld      (_textLength), a
    
    ; �^�C�}�҂��̊���
    ld      hl, #gameState
    inc     (hl)
19$:
    
    ; �e�L�X�g�̕\��
    ld      a, (gameState)
    and     #0x0f
    cp      #0x02
    jr      nz, 29$
    
    ; �e�L�X�g�̊Ď�
    ld      a, (_textLength)
    cp      #0xc0
    jr      c, 29$
    
    ; �e�L�X�g�\���̊���
    ld      hl, #0x0000
    ld      (_textString), hl
    ld      a, #GAME_STATE_TITLE
    ld      (gameState), a
29$:

    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; ���삷��
;
GameControl:
    
    ; ���W�X�^�̕ۑ�
    
    ; ����̃}�X�N
    ld      a, (gameState)
    and     #0xf0
    sub     #GAME_STATE_PLAY
    jr      z, 00$
    ld      a, #0xff
00$:
    cpl
    ld      e, a
    
    ; �����ړ�
    ld      hl, #_gameSightX
    ld      c, #0x00
    ld      a, (_input + INPUT_KEY_LEFT)
    and     e
    or      a
    jr      z, 10$
    dec     c
    ld      a, (hl)
    cp      #-0x10
    jr      z, 19$
    sub     #0x02
    jr      19$
10$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    and     e
    or      a
    jr      z, 11$
    inc     c
    ld      a, (hl)
    cp      #0x10
    jr      z, 19$
    add     a, #0x02
    jr      19$
11$:
    ld      a, (hl)
    or      a
    jr      z, 19$
    jp      p, 12$
    add     a, #0x02
    jr      19$
12$:
    sub     #0x02
19$:
    ld      (hl), a
    ld      a, c
    ld      (_gameRotateY), a
    
    ; �����ړ�
    ld      hl, #_gameSightY
    ld      c, #0x00
    ld      a, (_input + INPUT_KEY_UP)
    and     e
    or      a
    jr      z, 20$
    dec     c
    ld      a, (hl)
    cp      #-0x10
    jr      z, 29$
    sub     #0x02
    jr      29$
20$:
    ld      a, (_input + INPUT_KEY_DOWN)
    and     e
    or      a
    jr      z, 21$
    inc     c
    ld      a, (hl)
    cp      #0x10
    jr      z, 29$
    add     a, #0x02
    jr      29$
21$:
    ld      a, (hl)
    or      a
    jr      z, 29$
    jp      p, 22$
    add     a, #0x02
    jr      29$
22$:
    sub     #0x02
29$:
    ld      (hl), a
    ld      a, c
    ld      (_gameRotateX), a
    
    ; �O�i
    ld      a, (_gameAccel)
    or      a
    jr      nz, 39$
    ld      hl, #_gameMoveZ
    ld      a, (_input + INPUT_BUTTON_SHIFT)
    and     e
    or      a
    ld      a, (hl)
    jr      z, 30$
    add     a, #0x02
    cp      #0x80
    jr      c, 31$
    ld      a, #0x80
    jr      31$
30$:
    sub     #0x02
    jr      nc, 31$
    xor     a
31$:
    ld      (hl), a
39$:
    
    ; ����
    ld      a, (_input + INPUT_BUTTON_SPACE)
    and     e
    cp      #0x01
    jr      z, 40$
    xor     a
40$:
    ld      (_gameFire), a
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �萔�̒�`
;

; ������
;
gameStringStart:

    .ascii  "        MISSION        \n"
    .ascii  "\n"
    .ascii  "\n"
    .ascii  "DESTROY ALL ENEMIES AND\n"
    .ascii  "\n"
    .ascii  "  DEFEND THE UNIVERSE"
    .db     0x00

gameStringClear:

    .ascii  "  CONGRATULATIONS  \n"
    .ascii  "\n"
    .ascii  "\n"
    .ascii  "YOU HAVE DEMOLISHED\n"
    .ascii  "\n"
    .ascii  "  ALL ENEMIES AND  \n"
    .ascii  "\n"
    .ascii  "PEACE IS MAINTAINED\n"
    .ascii  "\n"
    .ascii  "\n"
    .ascii  "\n"
    .ascii  "      THE END"
    .db     0x00

gameStringOverKilled:

    .ascii  "YOU ARE DESTROYED\n"
    .ascii  "\n"
    .ascii  "\n"
    .ascii  "    GAME OVER"
    .db     0x00
    
gameStringOverEmpty:

    .ascii  "ENERGY EMPTY\n"
    .ascii  "\n"
    .ascii  "\n"
    .ascii  " GAME OVER"
    .db     0x00
    
; �a�f�l
;
gameBgmTitle0:

    .ascii  "T1V15-L3"
    .ascii  "O4E-E-B-5A-5E-E-B-5A-5E-E-G-A-E-E-B-5A-5E-E-O5E-5O4B-5A-B-1A-1D-E-"
    .ascii  "O4E-E-B-5A-5E-E-B-5A-5E-E-G-A-O4C-5C-D-RC-D-7R5R5R5"
    .db     0x00
    
gameBgmTitle1:

    .ascii  "T1V16L3S0N2"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXM5XXX"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXM5XXX"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXM5XXX"
    .ascii  "M5XR5XR5XR"
    .ascii  "R6M3XXXR5"
    .db     0x00

gameBgmTitle2:

    .ascii  "T1V15-L5"
    .ascii  "O3B-RRB-RRB-RB-RRB-RRO4E-R"
    .ascii  "O3B-RRB-RRB-RG-R3G-R3A-R9"
    .db     0x00
    
gameBgmStart0:

    .ascii  "T1V15-L3"
    .ascii  "O4R5E-5E-D-RE-RG-RG-5E-D-5R5E-5E-D-RE-RB-RA-6R5"
    .ascii  "O4R5E-5E-D-RE-RG-RA-5G-E-D-E-6D-6E-6G-6A-5G-5"
    .ascii  "O4R5E-5E-D-RE-RG-RG-5E-D-5R5E-5E-D-RE-RB-RA-6R5"
    .ascii  "O4R5E-5E-D-RE-RG-RA-5G-E-D-E-6O5D-6O4A-8R7"
    .db     0xff

gameBgmStart1:

    .ascii  "T1V16L3S0N2"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXM5XXX"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M5XR5XR5XR5XR5XXXR"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXM5XXX"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M5XR5XR5XRR7XXXR"
    .db     0xff

gameBgmStart2:

    .ascii  "T1V15-L5"
    .ascii  "O3RB-R7R9RB-R7R9"
    .ascii  "O3RB-R7R9BRRBRRO4FR"
    .ascii  "O3RB-R7R9RB-R7R9"
    .ascii  "O3RB-R7R9B6O4A-6F8R7"
    .db     0xff

gameBgmClear0:

    .ascii  "T1V15-L3"
    .ascii  "O4R5A-5O5F5E-5G-6F6R5O4R5A-5O5F5E-5C6D-RD-CD-"
    .ascii  "O6C6O5B-6RD-A-5G-FRA-RF8RR5"
    .ascii  "O5F5E-D-RCRE-E-D-8RR9R9"
    .ascii  "O5F5E-D-RCRE-E-D-8RR9R9"
    .ascii  "R9R9"
    .db     0x00
    
gameBgmClear1:

    .ascii  "T1V16L3S0N2"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M5XRR5R5RM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M5XRR5R5RM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M5XRRM5XRRM5XR"
    .ascii  "M3XXXRR7"
    .db     0x00

gameBgmClear2:

    .ascii  "T1V15-L5"
    .ascii  "O4RFRRO5C6R6RO4RFRRA-6R6R"
    .ascii  "O5G-6R6RFRRR3CR3RRR"
    .ascii  "O5CRRR3O4B-R3RRRR9R9"
    .ascii  "O5CRRR3O4B-R3RRRR9R9"
    .ascii  "R9R9"
    .db     0x00

gameBgmOver:

    .ascii  "T1"
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

; �v���Z�X
;
gameProcess:

    .ds     1

; �^�C�}
;
gameTimer:

    .ds     2

; �t���[��
;
_gameFrame::

    .ds     1

; ����
;
_gameRotateY::

    .ds     1

_gameRotateX::

    .ds     1

_gameSightX::

    .ds     1

_gameSightY::

    .ds     1

_gameMoveZ::

    .ds     1

_gameAccel::

    .ds     1

_gameFire::

    .ds     1

; �p�^�[���l�[��
;
_gamePatternName::

    .ds     768
