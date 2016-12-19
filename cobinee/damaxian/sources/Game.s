; Game.s : �Q�[�����
;



; ���W���[���錾
;
    .module Game


; �Q�ƃt�@�C��
;
    .include    "bios.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include    "Back.inc"
    .include    "Game.inc"
    .include    "GameShip.inc"
    .include    "GameShot.inc"
    .include    "GameEnemy.inc"
    .include    "GameBullet.inc"



; CODE �̈�
;
    .area   _CODE


; �Q�[�����X�V����
;
_GameUpdate::
    
    ; ��Ԃ̎擾
    ld      a, (_appState)
    
    ; ������
    cp      #GAME_STATE_INITIALIZE
    jr      nz, 00$
    call    GameInitialize
    jr      GameUpdateDone
00$:
    
    ; ���[�h
    cp      #GAME_STATE_LOAD
    jr      nz, 01$
    call    GameLoad
    jr      GameUpdateDone
01$:
    
    ; �J�n
    cp      #GAME_STATE_START
    jr      nz, 02$
    call    GameStart
    jr      GameUpdateDone
02$:
    
    ; �v���C
    cp      #GAME_STATE_PLAY
    jr      nz, 03$
    call    GamePlay
    jr      GameUpdateDone
03$:
    
    ; �^�C���A�b�v
    cp      #GAME_STATE_TIMEUP
    jr      nz, 04$
    call    GameTimeUp
    jr      GameUpdateDone
04$:
    
    ; �I�[�o�[
    cp      #GAME_STATE_OVER
    jr      nz, 05$
    call    GameOver
    jr      GameUpdateDone
05$:
    
    ; �n�C�X�R�A
    cp      #GAME_STATE_HISCORE
    jr      nz, 06$
    call    GameHiscore
    jr      GameUpdateDone
06$:
    
    ; �A�����[�h
    cp      #GAME_STATE_UNLOAD
    jr      nz, 07$
    call    GameUnload
    jr      GameUpdateDone
07$:
    
    ; �I��
    call    GameEnd
    
    ; �X�V�̊���
GameUpdateDone:
    
    ; �ꎞ��~
    ld      a, (_gameFlag)
    bit     #GAME_FLAG_PAUSE, a
    jr      nz, GameUpdateEnd
    
    ; �w�i�̍X�V
    call    _BackUpdate
    
    ; ���@�̍X�V
    call    _GameShipUpdate
    
    ; �V���b�g�̍X�V
    call    _GameShotUpdate
    
    ; �G�̍X�V
    call    _GameEnemyUpdate
    
    ; �e�̍X�V
    call    _GameBulletUpdate
    
    ; �X�e�[�^�X�̍X�V
    ld      a, (_gameFlag)
    bit     #GAME_FLAG_STATUS, a
    jr      z, 10$
    call    _BackTransferStatus
10$:
    
    ; �X�V�̏I��
GameUpdateEnd:
    
    ; �I��
    ret


; �Q�[��������������
;
GameInitialize:
    
    ; �X�v���C�g�̃N���A
    call    _SystemClearSprite
    
    ; ���t�̒�~
    ld      hl, #mmlNull
    ld      (_soundRequest + 0), hl
    ld      (_soundRequest + 2), hl
    ld      (_soundRequest + 4), hl
    ld      (_soundRequest + 6), hl
    
    ; ���݂̃X�R�A�̏�����
    ld      ix, #_appScore
    xor     a
    ld      0(ix), a
    ld      1(ix), a
    ld      2(ix), a
    ld      3(ix), a
    ld      4(ix), a
    ld      5(ix), a
    
    ; �X�R�A�̔{���̏�����
    ld      ix, #_appRate
    xor     a
    ld      0(ix), a
    ld      2(ix), a
    ld      3(ix), a
    inc     a
    ld      1(ix), a
    
    ; �^�C�}�̏�����
    ld      ix, #_appTimer
    ld      a, #0x03
    ld      0(ix), a
    xor     a
    ld      1(ix), a
    ld      2(ix), a
    ld      3(ix), a
    
    ; ���@�̏�����
    call    _GameShipInitialize
    
    ; �V���b�g�̏�����
    call    _GameShotInitialize
    
    ; �G�̏�����
    call    _GameEnemyInitialize
    
    ; �e�̏�����
    call    _GameBulletInitialize
    
    ; �t���O�̏�����
    xor     a
    ld      (_gameFlag), a
    
    ; �|�������̏�����
    xor     a
    ld      (_gameShootDown), a
    
    ; ��Ԃ̍X�V
    ld      a, #GAME_STATE_LOAD
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; �I��
    ret


; �Q�[�������[�h����
;
GameLoad:
    
    ; ��Ԃ̎擾
    ld      a, (_appPhase)
    or      a
    jr      nz, GameLoadMain
    
    ; �t���O�̐ݒ�
    ld      hl, #_gameFlag
    set     #GAME_FLAG_STATUS, (hl)
    
    ; ��Ԃ̍X�V
    ld      hl, #_appPhase
    inc     (hl)
    jr      GameLoadEnd
    
    ; ���[�h�̏���
GameLoadMain:
    
    ; ��Ԃ̍X�V
    ld      a, #GAME_STATE_START
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; �ǂݍ��݂̏I��
GameLoadEnd:
    
    ; �I��
    ret


; �Q�[�����J�n����
;
GameStart:
    
    ; ��Ԃ̎擾
    ld      a, (_appPhase)
    or      a
    jr      nz, GameStartMain
    
    ; ���b�Z�[�W�̃��[�h
    ld      a, #BACK_MESSAGE_START
    call    _BackStoreMessage
    
    ; ���t�̊J�n
    ld      hl, #mmlStartChannel0
    ld      (_soundRequest + 0), hl
    ld      hl, #mmlStartChannel1
    ld      (_soundRequest + 2), hl
    ld      hl, #mmlStartChannel2
    ld      (_soundRequest + 4), hl
    
    ; �t���O�̐ݒ�
    ld      hl, #_gameFlag
    res     #GAME_FLAG_PLAYABLE, (hl)
    res     #GAME_FLAG_PAUSE, (hl)
    res     #GAME_FLAG_STATUS, (hl)
    
    ; ��Ԃ̍X�V
    ld      hl, #_appPhase
    inc     (hl)
    
    ; �J�n�̏���
GameStartMain:
    
    ; ���t�̏I��
    ld      hl, (_soundRequest + 0)
    ld      a, h
    or      l
    ld      hl, (_soundPlay + 0)
    or      h
    or      l
    jr      nz, GameStartEnd
    
    ; ���b�Z�[�W�̃A�����[�h
    call    _BackRestoreMessage
    
    ; ��Ԃ̍X�V
    ld      a, #GAME_STATE_PLAY
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; �J�n�̏I��
GameStartEnd:
    
    ; �I��
    ret


; �Q�[�����v���C����
;
GamePlay:
    
    ; ��Ԃ̎擾
    ld      a, (_appPhase)
    or      a
    jr      nz, GamePlayMain
    
    ; �t���O�̐ݒ�
    ld      hl, #_gameFlag
    res     #GAME_FLAG_PAUSE, (hl)
    set     #GAME_FLAG_PLAYABLE, (hl)
    set     #GAME_FLAG_STATUS, (hl)
    
    ; ��Ԃ̍X�V
    ld      hl, #_appPhase
    inc     (hl)
    
    ; �v���C�̏���
GamePlayMain:
    
    ; START �{�^���������ꂽ
    ld      a, (_input + INPUT_BUTTON_ESC)
    cp      #0x01
    jr      nz, 00$
    ld      hl, #_flag
    ld      a, #(1 << FLAG_SOUND_SLEEP)
    xor     (hl)
    ld      (hl), a
    ld      hl, #_gameFlag
    ld      a, #(1 << GAME_FLAG_PAUSE)
    xor     (hl)
    ld      (hl), a
00$:
    
    ; �ꎞ��~
    ld      hl, #_gameFlag
    bit     #GAME_FLAG_PAUSE, (hl)
    jp      nz, GamePlayEnd
    
    ; �^�C�}�̍X�V
    ld      ix, #_appTimer
    ld      a, 0(ix)
    or      1(ix)
    or      2(ix)
    or      3(ix)
    jr      z, 10$
    dec     3(ix)
    jp      p, 10$
    ld      a, #0x09
    ld      3(ix), a
    dec     2(ix)
    jp      p, 10$
    ld      a, #0x09
    ld      2(ix), a
    dec     1(ix)
    jp      p, 10$
    ld      a, #0x09
    ld      1(ix), a
    dec     0(ix)
    jp      p, 10$
    xor     a
    ld      0(ix), a
10$:
    
    ; �|�������̐ݒ�
    xor     a
    ld      (_gameShootDown), a
    
    ; �V���b�g�ƓG�̃q�b�g�`�F�b�N
    call    GameCheckShotEnemy
    
    ; ���@�ƒe�̃q�b�g�`�F�b�N
    call    GameCheckShipBullet
    
    ; ���@�ƓG�̃q�b�g�`�F�b�N
    call    GameCheckShipEnemy
    
    ; �X�R�A�̔{���̍X�V
    ld      ix, #_appRate
    ld      a, (_gameShootDown)
    or      a
    jr      z, 20$
    add     a, 1(ix)
    ld      1(ix), a
    sub     #0x0a
    jr      c, 22$
    ld      1(ix), a
    inc     0(ix)
    ld      a, 0(ix)
    cp      #0x0a
    jr      c, 22$
    ld      a, #0x09
    ld      0(ix), a
    ld      1(ix), a
    ld      2(ix), a
    jr      22$
20$:
    ld      a, 0(ix)
    or      2(ix)
    or      3(ix)
    jr      nz, 21$
    ld      a, 1(ix)
    cp      #0x01
    jr      z, 22$
21$:
    dec     3(ix)
    jp      p, 22$
    ld      a, #0x01
    ld      3(ix), a
    dec     2(ix)
    jp      p, 22$
    ld      a, #0x09
    ld      2(ix), a
    dec     1(ix)
    jp      p, 22$
    ld      a, #0x09
    ld      1(ix), a
    dec     0(ix)
22$:
    
    ; �X�R�A�̍X�V
    ld      a, (_gameShootDown)
    or      a
    jr      z, 34$
    ld      ix, #_appScore
    ld      iy, #_appRate
    ld      b, a
30$:
    ld      a, 2(iy)
    add     a, 5(ix)
    ld      5(ix), a
    sub     #0x0a
    jr      c, 31$
    ld      5(ix), a
31$:
    ld      a, 1(iy)
    ccf
    adc     a, 4(ix)
    ld      4(ix), a
    sub     #0x0a
    jr      c, 32$
    ld      4(ix), a
32$:
    ld      a, 0(iy)
    ccf
    adc     a, 3(ix)
    ld      3(ix), a
    sub     #0x0a
    jr      c, 33$
    ld      3(ix), a
    inc     2(ix)
    ld      a, 2(ix)
    sub     #0x0a
    jr      c, 33$
    ld      2(ix), a
    inc     1(ix)
    ld      a, 1(ix)
    sub     #0x0a
    jr      c, 33$
    ld      1(ix), a
    inc     0(ix)
    ld      a, 0(ix)
    sub     #0x0a
    jr      c, 33$
    ld      a, #0x09
    ld      0(ix), a
    ld      1(ix), a
    ld      2(ix), a
    ld      3(ix), a
    ld      4(ix), a
    ld      5(ix), a
33$:
    djnz    30$
34$:
    
    ; �^�C���A�b�v
    ld      ix, #_appTimer
    ld      a, 0(ix)
    or      1(ix)
    or      2(ix)
    or      3(ix)
    jr      nz, GamePlayEnd
    
    ; ��Ԃ̍X�V
    ld      a, #GAME_STATE_TIMEUP
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; �v���C�̏I��
GamePlayEnd:
    
    ; �I��
    ret


; �Q�[�����^�C���A�b�v����
;
GameTimeUp:
    
    ; ��Ԃ̎擾
    ld      a, (_appPhase)
    or      a
    jr      nz, GameTimeUpMain
    
    ; ���b�Z�[�W�̃��[�h
    ld      a, #BACK_MESSAGE_TIMEUP
    call    _BackStoreMessage
    
    ; �J�E���g�̐ݒ�
    ld      a, #180
    ld      (gameCount), a
    
    ; �t���O�̐ݒ�
    ld      hl, #_gameFlag
    res     #GAME_FLAG_PLAYABLE, (hl)
    res     #GAME_FLAG_PAUSE, (hl)
    res     #GAME_FLAG_STATUS, (hl)
    
    ; ��Ԃ̍X�V
    ld      hl, #_appPhase
    inc     (hl)
    
    ; �^�C���A�b�v�̏���
GameTimeUpMain:
    
    ; �J�E���g�̍X�V
    ld      hl, #gameCount
    dec     (hl)
    jp      nz, GameTimeUpEnd
    
    ; �n�C�X�R�A���X�V�������ǂ���
    ld      ix, #_appHiscore
    ld      iy, #_appScore
    ld      a, 0(iy)
    cp      0(ix)
    jr      c, GameTimeUpOver
    jr      nz, GameTimeUpHiscore
    ld      a, 1(iy)
    cp      1(ix)
    jr      c, GameTimeUpOver
    jr      nz, GameTimeUpHiscore
    ld      a, 2(iy)
    cp      2(ix)
    jr      c, GameTimeUpOver
    jr      nz, GameTimeUpHiscore
    ld      a, 3(iy)
    cp      3(ix)
    jr      c, GameTimeUpOver
    jr      nz, GameTimeUpHiscore
    ld      a, 4(iy)
    cp      4(ix)
    jr      c, GameTimeUpOver
    jr      nz, GameTimeUpHiscore
    ld      a, 5(iy)
    cp      5(ix)
    jr      c, GameTimeUpOver
    jr      nz, GameTimeUpHiscore
    
    ; �Q�[���I�[�o�[
GameTimeUpOver:
    
    ; ��Ԃ̍X�V
    ld      a, #GAME_STATE_OVER
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    jr      GameTimeUpEnd
    
    ; �n�C�X�R�A
GameTimeUpHiscore:
    
    ; �n�C�X�R�A�̍X�V
    ld      a, 0(iy)
    ld      0(ix), a
    ld      a, 1(iy)
    ld      1(ix), a
    ld      a, 2(iy)
    ld      2(ix), a
    ld      a, 3(iy)
    ld      3(ix), a
    ld      a, 4(iy)
    ld      4(ix), a
    ld      a, 5(iy)
    ld      5(ix), a
    call    _BackTransferHiscore
    
    ; ��Ԃ̍X�V
    ld      a, #GAME_STATE_HISCORE
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; �^�C���A�b�v�̏I��
GameTimeUpEnd:
    
    ; �I��
    ret


; �Q�[���I�[�o�[�ɂȂ�
;
GameOver:
    
    ; ��Ԃ̎擾
    ld      a, (_appPhase)
    or      a
    jr      nz, GameOverMain
    
    ; ���b�Z�[�W�̃��[�h
    ld      a, #BACK_MESSAGE_GAMEOVER
    call    _BackStoreMessage
    
    ; �J�E���g�̐ݒ�
    ld      a, #180
    ld      (gameCount), a
    
    ; �t���O�̐ݒ�
    ld      hl, #_gameFlag
    res     #GAME_FLAG_PLAYABLE, (hl)
    res     #GAME_FLAG_PAUSE, (hl)
    res     #GAME_FLAG_STATUS, (hl)
    
    ; ��Ԃ̍X�V
    ld      hl, #_appPhase
    inc     (hl)
    
    ; �I�[�o�[�̏���
GameOverMain:
    
    ; �J�E���g�̍X�V
    ld      hl, #gameCount
    dec     (hl)
    jr      nz, GameOverEnd
    
    ; ���b�Z�[�W�̃A�����[�h
    call    _BackRestoreMessage
    
    ; ��Ԃ̍X�V
    ld      a, #GAME_STATE_UNLOAD
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; �I�[�o�[�̏I��
GameOverEnd:
    
    ; �I��
    ret


; �n�C�X�R�A���X�V����
;
GameHiscore:
    
    ; ��Ԃ̎擾
    ld      a, (_appPhase)
    or      a
    jr      nz, GameHiscoreMain
    
    ; ���b�Z�[�W�̃��[�h
    ld      a, #BACK_MESSAGE_HISCORE
    call    _BackStoreMessage
    
    ; ���t�̊J�n
    ld      hl, #mmlHiScoreChannel0
    ld      (_soundRequest + 0), hl
    ld      hl, #mmlHiScoreChannel1
    ld      (_soundRequest + 2), hl
    ld      hl, #mmlHiScoreChannel2
    ld      (_soundRequest + 4), hl
    
    ; �t���O�̐ݒ�
    ld      hl, #_gameFlag
    res     #GAME_FLAG_PLAYABLE, (hl)
    res     #GAME_FLAG_PAUSE, (hl)
    res     #GAME_FLAG_STATUS, (hl)
    
    ; ��Ԃ̍X�V
    ld      hl, #_appPhase
    inc     (hl)
    
    ; �n�C�X�R�A�̏���
GameHiscoreMain:
    
    ; ���t�̏I��
    ld      hl, (_soundRequest + 0)
    ld      a, h
    or      l
    ld      hl, (_soundPlay + 0)
    or      h
    or      l
    jr      nz, GameHiscoreEnd
    
    ; ���b�Z�[�W�̃A�����[�h
    call    _BackRestoreMessage
    
    ; ��Ԃ̍X�V
    ld      a, #GAME_STATE_UNLOAD
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; �n�C�X�R�A�̏I��
GameHiscoreEnd:
    
    ; �I��
    ret


; �Q�[�����A�����[�h����
;
GameUnload:
    
    ; ��Ԃ̎擾
    ld      a, (_appPhase)
    or      a
    jr      nz, GameUnloadMain
    
    ; �t���O�̐ݒ�
    xor     a
    ld      (_gameFlag), a
    
    ; ��Ԃ̍X�V
    ld      hl, #_appPhase
    inc     (hl)
    
    ; �A�����[�h�̏���
GameUnloadMain:
    
    ; ��Ԃ̍X�V
    ld      a, #GAME_STATE_END
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; �A�����[�h�̏I��
GameUnloadEnd:
    
    ; �I��
    ret


; �Q�[�����I������
;
GameEnd:
    
    ; ���[�h�̍X�V
    ld      a, #APP_MODE_TITLE
    ld      (_appMode), a
    
    ; ��Ԃ̍X�V
    ld      a, #APP_STATE_NULL
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; �I��
    ret


; �V���b�g�ƓG�̃q�b�g�`�F�b�N���s��
;
GameCheckShotEnemy:
    
    ; �V���b�g�̑���
    ld      iy, #_gameShot
    ld      c, #GAME_SHOT_SIZE
0$:
    
    ; �V���b�g�̑���
    ld      a, GAME_SHOT_PARAM_STATE(iy)
    cp      #GAME_SHOT_STATE_NULL
    jr      z, 9$
    
    ; �G�̑���
    ld      ix, #_gameEnemy
    ld      b, #GAME_ENEMY_SIZE
1$:
    
    ; �G�̑���
    ld      a, GAME_ENEMY_PARAM_NODAMAGE(ix)
    or      a
    jr      nz, 8$
    
    ; �q�b�g�`�F�b�N
    ld      a, GAME_ENEMY_PARAM_POINT_XI(ix)
    sub     GAME_SHOT_PARAM_POINT_X(iy)
    cp      #0x08
    jr      c, 2$
    cp      #0xf9
    jr      c, 8$
2$:
    ld      a, GAME_ENEMY_PARAM_POINT_YI(ix)
    sub     GAME_SHOT_PARAM_POINT_Y(iy)
    cp      #0x0b
    jr      c, 3$
    cp      #0xf6
    jr      c, 8$
3$:
    
    ; �|�������̍X�V
    ld      hl, #_gameShootDown
    inc     (hl)
    
    ; �G�̃m�[�_���[�W�̍X�V
    ld      a, #0x80
    ld      GAME_ENEMY_PARAM_NODAMAGE(ix), a
    
    ; �G�̏�Ԃ̍X�V
    ld      a, #GAME_ENEMY_STATE_BOMB
    ld      GAME_ENEMY_PARAM_STATE(ix), a
    ld      a, #APP_PHASE_NULL
    ld      GAME_ENEMY_PARAM_PHASE(ix), a
    
    ; �G�̌����Ԃ�
    call    GameShootBack
    
    ; �V���b�g�̏�Ԃ̍X�V
    ld      a, #GAME_SHOT_STATE_NULL
    ld      GAME_SHOT_PARAM_STATE(iy), a
    ld      a, #APP_PHASE_NULL
    ld      GAME_SHOT_PARAM_PHASE(iy), a
    
    ; �G�̑����̊���
8$:
    ld      de, #GAME_ENEMY_PARAM_SIZE
    add     ix, de
    djnz    1$
    
    ; �V���b�g�̑����̊���
9$:
    ld      de, #GAME_SHOT_PARAM_SIZE
    add     iy, de
    dec     c
    jr      nz, 0$
    
    ; �����̏I��
GameCheckShotEnemyEnd:
    
    ; �I��
    ret


; ���@�ƒe�̃q�b�g�`�F�b�N���s��
;
GameCheckShipBullet:
    
    ; ���@�̑���
    ld      iy, #_gameShip
    ld      a, GAME_SHIP_PARAM_NODAMAGE(iy)
    or      a
    jr      nz, GameCheckShipBulletEnd
    
    ; �e�̑���
    ld      ix, #_gameBullet
    ld      de, #GAME_BULLET_PARAM_SIZE
    ld      b, #GAME_BULLET_SIZE
0$:
    
    ; �e�̑���
    ld      a, GAME_BULLET_PARAM_STATE(ix)
    cp      #GAME_BULLET_STATE_NULL
    jr      z, 9$
    
    ; �q�b�g�`�F�b�N
    ld      a, GAME_BULLET_PARAM_POINT_XI(ix)
    sub     GAME_SHIP_PARAM_POINT_X(iy)
    jr      nc, 1$
    neg
1$:
    cp      #0x06
    jr      nc, 9$
    ; ld      c, a
    ld      a, GAME_BULLET_PARAM_POINT_YI(ix)
    sub     GAME_SHIP_PARAM_POINT_Y(iy)
    jr      nc, 2$
    neg
2$:
    cp      #0x06
    jr      nc, 9$
    ; add     a, c
    ; cp      #0x06
    ; jr      nc, 9$
    
    ; �e�̏�Ԃ̍X�V
    ld      a, #GAME_BULLET_STATE_NULL
    ld      GAME_BULLET_PARAM_STATE(ix), a
    ld      a, #APP_PHASE_NULL
    ld      GAME_BULLET_PARAM_PHASE(ix), a
    
    ; ���@�̏�Ԃ̍X�V
    ld      a, #GAME_SHIP_STATE_BOMB
    ld      GAME_SHIP_PARAM_STATE(iy), a
    ld      a, #APP_PHASE_NULL
    ld      GAME_SHIP_PARAM_PHASE(iy), a
    
    ; �e�̑����̊���
9$:
    add     ix, de
    djnz    0$
    
    ; �����̏I��
GameCheckShipBulletEnd:
    
    ; �I��
    ret


; ���@�ƓG�̃q�b�g�`�F�b�N���s��
;
GameCheckShipEnemy:
    
    ; ���@�̑���
    ld      iy, #_gameShip
    ld      a, GAME_SHIP_PARAM_NODAMAGE(iy)
    or      a
    jr      nz, GameCheckShipEnemyEnd
    
    ; �G�̑���
    ld      ix, #_gameEnemy
    ld      de, #GAME_ENEMY_PARAM_SIZE
    ld      b, #GAME_ENEMY_SIZE
0$:
    
    ; �G�̑���
    ld      a, GAME_ENEMY_PARAM_NODAMAGE(ix)
    or      a
    jr      nz, 9$
    
    ; �q�b�g�`�F�b�N
    ld      a, GAME_ENEMY_PARAM_POINT_XI(ix)
    sub     GAME_SHIP_PARAM_POINT_X(iy)
    jr      nc, 1$
    neg
1$:
    cp      #0x08
    jr      nc, 9$
    ; ld      c, a
    ld      a, GAME_ENEMY_PARAM_POINT_YI(ix)
    sub     GAME_SHIP_PARAM_POINT_Y(iy)
    jr      nc, 2$
    neg
2$:
    cp      #0x08
    jr      nc, 9$
    ; add     a, c
    ; cp      #0x08
    ; jr      nc, 9$
    
    ; �|�������̍X�V
    ld      hl, #_gameShootDown
    inc     (hl)
    
    ; �G�̃m�[�_���[�W�̍X�V
    ld      a, #0x80
    ld      GAME_ENEMY_PARAM_NODAMAGE(ix), a
    
    ; �G�̏�Ԃ̍X�V
    ld      a, #GAME_ENEMY_STATE_BOMB
    ld      GAME_ENEMY_PARAM_STATE(ix), a
    ld      a, #APP_PHASE_NULL
    ld      GAME_ENEMY_PARAM_PHASE(ix), a
    
    ; ���@�̏�Ԃ̍X�V
    ld      a, #GAME_SHIP_STATE_BOMB
    ld      GAME_SHIP_PARAM_STATE(iy), a
    ld      a, #APP_PHASE_NULL
    ld      GAME_SHIP_PARAM_PHASE(iy), a
    
    ; �G�̑����̊���
9$:
    add     ix, de
    djnz    0$
    
    ; �����̏I��
GameCheckShipEnemyEnd:
    
    ; �I��
    ret


; �G���e��ł��Ԃ�
;
GameShootBack:
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    push    de
    push    iy
    
    ; �G�����@�ɋ߂��ꍇ�͌����Ԃ��Ȃ�
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_Y)
    sub     #0x20
    cp      GAME_ENEMY_PARAM_POINT_YI(ix)
    jr      nc, 00$
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_X)
    sub     #0x18
    cp      GAME_ENEMY_PARAM_POINT_XI(ix)
    jr      nc, 00$
    add     #0x30
    cp      GAME_ENEMY_PARAM_POINT_XI(ix)
    jp      nc, GameShootBackEnd
00$:
    
    ; �x�N�g���̎擾
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_X)
    sub     GAME_ENEMY_PARAM_POINT_XI(ix)
    ld      h, a
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_Y)
    sub     GAME_ENEMY_PARAM_POINT_YI(ix)
    ld      l, a
    
    ; �K���������Ɍ����Ԃ�
    bit     #0x07, a
    jr      z, 10$
    sra     h
    srl     l
10$:
    
    ; �����̎擾
    call    _SystemGetAtan2
    ld      (gameBackAngle), a
    
    ; �e�̃G���g���̎擾
    ld      iy, #_gameBulletEntry
    
    ; �e�̈ʒu�̐ݒ�
    ld      a, GAME_ENEMY_PARAM_POINT_XD(ix)
    ld      GAME_BULLET_PARAM_POINT_XD(iy), a
    ld      a, GAME_ENEMY_PARAM_POINT_XI(ix)
    ld      GAME_BULLET_PARAM_POINT_XI(iy), a
    ld      a, GAME_ENEMY_PARAM_POINT_YD(ix)
    ld      GAME_BULLET_PARAM_POINT_YD(iy), a
    ld      a, GAME_ENEMY_PARAM_POINT_YI(ix)
    ld      GAME_BULLET_PARAM_POINT_YI(iy), a
    
    ; �e�̃G���g��
    ld      bc, #0x0500
20$:
    ld      hl, #backTypeTable
    ld      e, c
    ld      d, #0x00
    add     hl, de
    ld      a, (hl)
    ld      GAME_BULLET_PARAM_SPRITE_SRC_L(iy), a
    ld      hl, #backAngleTable
    add     hl, de
    ld      a, (gameBackAngle)
    add     a, (hl)
    push    af
    call    _SystemGetCos
    ld      (gameBackCos), hl
    pop     af
    call    _SystemGetSin
    ld      (gameBackSin), hl
    xor     a
    ld      GAME_BULLET_PARAM_SPEED_XD(iy), a
    ld      GAME_BULLET_PARAM_SPEED_XI(iy), a
    ld      GAME_BULLET_PARAM_SPEED_YD(iy), a
    ld      GAME_BULLET_PARAM_SPEED_YI(iy), a
    ld      hl, #backSpeedTable
    add     hl, de
    add     hl, de
    ld      a, (_appTimer + 0)
    sla     a
    sla     a
    sla     a
    sla     a
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      d, (hl)
    inc     hl
    ld      e, (hl)
    ld      a, d
    or      a
    jr      z, 22$
21$:
    ld      a, (gameBackCos + 0)
    add     a, GAME_BULLET_PARAM_SPEED_XD(iy)
    ld      GAME_BULLET_PARAM_SPEED_XD(iy), a
    ld      a, (gameBackCos + 1)
    adc     a, GAME_BULLET_PARAM_SPEED_XI(iy)
    ld      GAME_BULLET_PARAM_SPEED_XI(iy), a
    ld      a, (gameBackSin + 0)
    add     a, GAME_BULLET_PARAM_SPEED_YD(iy)
    ld      GAME_BULLET_PARAM_SPEED_YD(iy), a
    ld      a, (gameBackSin + 1)
    adc     a, GAME_BULLET_PARAM_SPEED_YI(iy)
    ld      GAME_BULLET_PARAM_SPEED_YI(iy), a
    dec     d
    jr      nz, 21$
22$:
    ld      a, e
    or      a
    jr      z, 24$
    ld      hl, (gameBackCos)
    sra     h
    rr      l
    ld      (gameBackCos), hl
    ld      hl, (gameBackSin)
    sra     h
    rr      l
    ld      (gameBackSin), hl
23$:
    ld      a, (gameBackCos + 0)
    add     a, GAME_BULLET_PARAM_SPEED_XD(iy)
    ld      GAME_BULLET_PARAM_SPEED_XD(iy), a
    ld      a, (gameBackCos + 1)
    adc     a, GAME_BULLET_PARAM_SPEED_XI(iy)
    ld      GAME_BULLET_PARAM_SPEED_XI(iy), a
    ld      a, (gameBackSin + 0)
    add     a, GAME_BULLET_PARAM_SPEED_YD(iy)
    ld      GAME_BULLET_PARAM_SPEED_YD(iy), a
    ld      a, (gameBackSin + 1)
    adc     a, GAME_BULLET_PARAM_SPEED_YI(iy)
    ld      GAME_BULLET_PARAM_SPEED_YI(iy), a
    dec     e
    jr      nz, 23$
24$:
    call    _GameBulletEntry
    inc     c
    dec     b
    jp      nz, 20$
    
    ; �����̏I��
GameShootBackEnd:
    
    ; ���W�X�^�̕��A
    pop     iy
    pop     de
    pop     bc
    pop     hl
    
    ; �I��
    ret


; �萔�̒�`
;

; �����Ԃ��f�[�^
;
backTypeTable:
    
    .db     0x00, 0x01, 0x01, 0x00, 0x00

backAngleTable:
    
    .db     0x00, 0x0c, 0xf4, 0x18, 0xe8

backSpeedTable:
    
;    .db     0x03, 0x00, 0x02, 0x01, 0x02, 0x01, 0x03, 0x00, 0x03, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db     0x02, 0x01, 0x02, 0x00, 0x02, 0x00, 0x02, 0x01, 0x02, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db     0x02, 0x00, 0x01, 0x01, 0x01, 0x01, 0x02, 0x00, 0x02, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db     0x01, 0x01, 0x01, 0x00, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db     0x01, 0x01, 0x01, 0x00, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff


; MML �f�[�^
;
mmlNull:
    
    .db     0x00

mmlStartChannel0:
    
    .ascii  "T1S0M12V16"
    .ascii  "L0O6CO5BAGFEDCO4BAG"
    .ascii  "L3O3GO4CO3GO4CECEGEGO5C5R5"
    .ascii  "L3O3GO4CO3GO4CECEGEGO5C5R5"
    .ascii  "L1O4E3DD#DD#DD#DD#DD#DD#DD#DD#"
    .ascii  "L0O4CDEFGABO5C"
    .ascii  "L0O4CDEFGABO5C"
    .ascii  "L0O4CDEFGABO5C"
    .ascii  "R5"
    .db     0x00

mmlStartChannel1:
    
    .ascii  "T1V16"
    .ascii  "L0RRRRRRRRRRR"
    .ascii  "L5RRRRRRR"
    .ascii  "L5RRRRRRR"
    .ascii  "L3RRRRRRRRR"
    .ascii  "L0RRRRRRRR"
    .ascii  "L0RRRRRRRR"
    .ascii  "L0RRRRRRRR"
    .ascii  "R5"
    .db     0x00

mmlStartChannel2:
    
    .ascii  "T1V16"
    .ascii  "L0RRRRRRRRRRR"
    .ascii  "L5RRRRRRR"
    .ascii  "L5RRRRRRR"
    .ascii  "L3RRRRRRRRR"
    .ascii  "L0RRRRRRRR"
    .ascii  "L0RRRRRRRR"
    .ascii  "L0RRRRRRRR"
    .ascii  "R5"
    .db     0x00

mmlHiScoreChannel0:
    
    .ascii  "T2S0M12V16L3"
    .ascii  "O5D5RDD#FG6"
    .ascii  "R9"
    .db     0x00

mmlHiScoreChannel1:
    
    .ascii  "T2V16L3"
    .ascii  "O4A5RAA#O5CD6"
    .ascii  "R9"
    .db     0x00

mmlHiScoreChannel2:
    
    .ascii  "T2V16L3"
    .ascii  "O4F#5RF#GAB6"
    .ascii  "R9"
    .db     0x00



; DATA �̈�
;
    .area   _DATA


; �ϐ��̒�`
;

; �t���O
;
_gameFlag::
    
    .ds     1

; �|������
;
_gameShootDown::
    
    .ds     1

; �J�E���g
;
gameCount:
    
    .ds     1

; �����Ԃ�
;
gameBackAngle:
    
    .ds     1

gameBackCos:
    
    .ds     2

gameBackSin:
    
    .ds     2


