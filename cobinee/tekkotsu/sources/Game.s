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
    .include    "Pilot.inc"
    .include    "Steel.inc"

; �O���ϐ��錾
;
    .globl  _backPatternNameTable
    .globl  _backPatternGeneratorTable
    .globl  _backColorTable
    .globl  _fontPatternGeneratorTable
    .globl  _fontColorTable

; �}�N���̒�`
;

; ���
GAME_STATE_NULL         =   0x00
GAME_STATE_START        =   0x10
GAME_STATE_PLAY         =   0x20
GAME_STATE_HIT          =   0x30
GAME_STATE_OVER         =   0x40

; ����
GAME_PROCESS_NULL           =   0b00000000
GAME_PROCESS_PILOT_UPDATE   =   0b00000001
GAME_PROCESS_PILOT_RENDER   =   0b00000010
GAME_PROCESS_STEEL_UPDATE   =   0b00000100
GAME_PROCESS_STEEL_RENDER   =   0b00001000


; CODE �̈�
;
    .area   _CODE

; �Q�[��������������
;
_GameInitialize::
    
    ; ���W�X�^�̕ۑ�
    
    ; �Q�[���̏�����
    ld      hl, #(gameScore + 0x00)
    ld      de, #(gameScore + 0x01)
    ld      bc, #(0x0004)
    xor     a
    ld      (hl), a
    ldir
    ld      hl, #(gameStringScore)
    ld      de, #(gameScoreText)
    ld      bc, #(0x000c)
    ldir
    ld      a, #0x03
    ld      (gameRest), a
    ld      hl, #(gameStringRest)
    ld      de, #(gameRestText)
    ld      bc, #(0x0006)
    ldir
    
    ; �p�C���b�g�̏�����
    call    _PilotInitialize
    
    ; �S���̏�����
    call    _SteelInitialize
    
;   ; �p�^�[���l�[���̓]��
;   ld      hl, #_backPatternNameTable
;   ld      de, #APP_PATTERN_NAME_TABLE_0
;   ld      bc, #0x0300
;   call    LDIRVM
    
    ; �p�^�[���W�F�l���[�^�̓]���^�w�i
    ld      hl, #_backPatternGeneratorTable
    ld      bc, (_backPatternGeneratorTable + 0x00)
    add     hl, bc
    ld      bc, (_backPatternGeneratorTable + 0x02)
    ld      de, #APP_PATTERN_GENERATOR_TABLE_0
    call    LDIRVM
    ld      hl, #_backPatternGeneratorTable
    ld      bc, (_backPatternGeneratorTable + 0x04)
    add     hl, bc
    ld      bc, (_backPatternGeneratorTable + 0x06)
    ld      de, #APP_PATTERN_GENERATOR_TABLE_1
    call    LDIRVM
    ld      hl, #_backPatternGeneratorTable
    ld      bc, (_backPatternGeneratorTable + 0x08)
    add     hl, bc
    ld      bc, (_backPatternGeneratorTable + 0x0a)
    ld      de, #APP_PATTERN_GENERATOR_TABLE_2
    call    LDIRVM
    
    ; �p�^�[���W�F�l���[�^�̓]���^�t�H���g
    ld      hl, #(_fontPatternGeneratorTable + 0x0c)
    ld      bc, (_fontPatternGeneratorTable + 0x02)
    ld      de, #(APP_PATTERN_GENERATOR_TABLE_0 + 0x0600)
    call    LDIRVM
    ld      hl, #(_fontPatternGeneratorTable + 0x0c)
    ld      bc, (_fontPatternGeneratorTable + 0x02)
    ld      de, #(APP_PATTERN_GENERATOR_TABLE_1 + 0x0600)
    call    LDIRVM
    ld      hl, #(_fontPatternGeneratorTable + 0x0c)
    ld      bc, (_fontPatternGeneratorTable + 0x02)
    ld      de, #(APP_PATTERN_GENERATOR_TABLE_2 + 0x0600)
    call    LDIRVM
    
    ; �J���[�e�[�u���̓]���^�w�i
    ld      hl, #_backColorTable
    ld      bc, (_backColorTable + 0x00)
    add     hl, bc
    ld      bc, (_backColorTable + 0x02)
    ld      de, #APP_COLOR_TABLE_0
    call    LDIRVM
    ld      hl, #_backColorTable
    ld      bc, (_backColorTable + 0x04)
    add     hl, bc
    ld      bc, (_backColorTable + 0x06)
    ld      de, #APP_COLOR_TABLE_1
    call    LDIRVM
    ld      hl, #_backColorTable
    ld      bc, (_backColorTable + 0x08)
    add     hl, bc
    ld      bc, (_backColorTable + 0x0a)
    ld      de, #APP_COLOR_TABLE_2
    call    LDIRVM
    
    ; �J���[�e�[�u���̓]���^�t�H���g
    ld      hl, #(_fontColorTable + 0x0c)
    ld      bc, (_fontColorTable + 0x02)
    ld      de, #(APP_COLOR_TABLE_0 + 0x0600)
    call    LDIRVM
    ld      hl, #(_fontColorTable + 0x0c)
    ld      bc, (_fontColorTable + 0x02)
    ld      de, #(APP_COLOR_TABLE_1 + 0x0600)
    call    LDIRVM
    ld      hl, #(_fontColorTable + 0x0c)
    ld      bc, (_fontColorTable + 0x02)
    ld      de, #(APP_COLOR_TABLE_2 + 0x0600)
    call    LDIRVM
    
;   ; �`��̊J�n
;   ld      hl, #(_videoRegister + VDP_R1)
;   set     #VDP_R1_BL, (hl)
    
;   ; �r�f�I���W�X�^�̓]��
;   ld      hl, #_request
;   set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; �����̏�����
    xor     a
    ld      (gameProcess), a
    
    ; ��Ԃ̐ݒ�
    ld      a, #GAME_STATE_START
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
    
    ; ��ԕʂ̏���
    ld      a, (gameState)
    and     #0xf0
    cp      #GAME_STATE_START
    jr      nz, 10$
    call    GameStart
    jr      19$
10$:
    cp      #GAME_STATE_PLAY
    jr      nz, 11$
    call    GamePlay
    jr      19$
11$:
    cp      #GAME_STATE_HIT
    jr      nz, 12$
    call    GameHit
    jr      19$
12$:
    cp      #GAME_STATE_OVER
    jr      nz, 19$
    call    GameOver
    jr      19$
19$:
    
    ; �p�C���b�g�̍X�V
    ld      a, (gameProcess)
    and     #GAME_PROCESS_PILOT_UPDATE
    call    nz, _PilotUpdate
    
    ; �S���̍X�V
    ld      a, (gameProcess)
    and     #GAME_PROCESS_STEEL_UPDATE
    call    nz, _SteelUpdate
    
    ; �p�C���b�g�̕`��
    ld      a, (gameProcess)
    and     #GAME_PROCESS_PILOT_RENDER
    call    nz, _PilotRender
    
    ; �S���̕`��
    ld      a, (gameProcess)
    and     #GAME_PROCESS_STEEL_RENDER
    call    nz, _SteelRender

    ; ���W�X�^�̕��A
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
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
    
    ; �c�@�̐ݒ�
    ld      a, (gameRest)
    add     a, #0xcf
    ld      (gameRestText + 0x05), a
    
    ; �p�^�[���l�[���̐ݒ�
    ld      hl, #(gamePatternName + 0x0000)
    ld      de, #(gamePatternName + 0x0001)
    ld      bc, #(0x02ff)
    ld      a, #0xc0
    ld      (hl), a
    ldir
    ld      hl, #(gameStringStart)
    ld      de, #(gamePatternName + 0x012b)
    ld      bc, #(0x000a)
    ldir
    ld      hl, #(gameRestText)
    ld      de, #(gamePatternName + 0x01ad)
    ld      bc, #(0x0006)
    ldir
    
    ; �p�^�[���l�[���̓]��
    call    GameTransferPatternName
    
    ; �`��̊J�n
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; �r�f�I���W�X�^�̓]��
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; �^�C�}�̐ݒ�
    ld      a, #0x60
    ld      (gameTimer), a
    
    ; �����̐ݒ�
    ld      a, #(GAME_PROCESS_NULL)
    ld      (gameProcess), a
    
    ; �������̊���
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; �^�C�}�̍X�V
    ld      hl, #gameTimer
    dec     (hl)
    jr      nz, 19$
    
    ; �Q�[���J�n
    ld      a, #GAME_STATE_PLAY
    ld      (gameState), a
    
    ; �^�C�}�X�V�̊���
19$:

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
    
    ; �p�C���b�g�̃��Z�b�g
    call    _PilotReset
    
    ; �S���̃��Z�b�g
    call    _SteelReset
    
    ; �p�^�[���l�[���̐ݒ�
    ld      hl, #_backPatternNameTable
    ld      de, #gamePatternName
    ld      bc, #0x0300
    ldir
    ld      hl, #(gameRestText)
    ld      de, #(gamePatternName + 0x0034)
    ld      bc, #(0x0006)
    ldir
    
    ; �p�^�[���l�[���̓]��
    call    GameTransferPatternName

    ; �����̐ݒ�
    ld      a, #(GAME_PROCESS_PILOT_UPDATE | GAME_PROCESS_PILOT_RENDER | GAME_PROCESS_STEEL_UPDATE | GAME_PROCESS_STEEL_RENDER)
    ld      (gameProcess), a
    
    ; �������̊���
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; �q�b�g�`�F�b�N�̊J�n
    ld      iy, #_pilotRange
    ld      ix, #_steel
    ld      b, #STEEL_N
10$:
    ld      a, STEEL_STATE(ix)
    or      a
    jr      z, 19$
    ld      a, STEEL_X(ix)
    cp      PILOT_RANGE_RIGHT(iy)
    jr      nc, 19$
    add     a, #STEEL_WIDTH
    cp      PILOT_RANGE_LEFT(iy)
    jr      c, 19$
    ld      a, STEEL_Y(ix)
    cp      PILOT_RANGE_TOP(iy)
    jr      c, 19$
    sub     #STEEL_HEIGHT
    cp      PILOT_RANGE_BOTTOM(iy)
    jr      nc, 19$
    
    ; �q�b�g
    ld      a, #GAME_STATE_HIT
    ld      (gameState), a
    
    ; �q�b�g�`�F�b�N�̊���
19$:
    ld      de, #STEEL_SIZE
    add     ix, de
    djnz    10$
    
    ; ���x�̎擾
    ld      d, #0x01
    ld      a, (_pilotTurn)
    and     #0x7f
    cp      #0x30
    jr      c, 20$
    inc     d
    cp      #0x60
    jr      c, 20$
    inc     d
    cp      #0x70
    jr      c, 20$
    inc     d
20$:
    ld      a, d
    ld      (_steelSpeed), a
    
    ; �X�R�A�̍X�V
    ld      ix, #_steelFall
    ld      a, 0(ix)
    or      a
    jr      z, 39$
30$:
    ld      hl, #(gameScore + 0x04)
    ld      b, #0x05
31$:
    inc     (hl)
    ld      a, (hl)
    cp      #0x0a
    jr      c, 33$
    xor     a
    ld      (hl), a
    dec     hl
    djnz    31$
    ld      a, #0x09
    ld      b, #0x05
32$:
    inc     hl
    ld      (hl), a
    djnz    32$
33$:
    dec     0(ix)
    jr      nz, 30$
    ld      de, #(gameScore)
    ld      hl, #(gameScoreText + 0x0006)
    ld      bc, #0x05c0
34$:
    ld      a, (de)
    or      a
    jr      nz, 35$
    ld      (hl), c
    inc     de
    inc     hl
    djnz    34$
    jr      39$
35$:
    ld      a, (de)
    add     a, #0xd0
    ld      (hl), a
    inc     de
    inc     hl
    djnz    35$
39$:
    
    ; �X�R�A�̓]��
    ld      hl, #(gameScoreText + 0x0006)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE_0 + 0x0026)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_DST), hl
    ld      a, #0x06
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �Q�[���Ńq�b�g����
;
GameHit:
    
    ; ���W�X�^�̕ۑ�
    
    ; �������̊J�n
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$
    
    ; �^�C�}�̐ݒ�
    ld      a, #0x40
    ld      (gameTimer), a
    
    ; �����̐ݒ�
    ld      a, #(GAME_PROCESS_NULL)
    ld      (gameProcess), a
    
    ; �������̊���
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; �^�C�}�̍X�V
    ld      hl, #gameTimer
    dec     (hl)
    jr      nz, 19$
    
    ; 
    ld      hl, #gameRest
    dec     (hl)
    jr      z, 10$
    
    ; ���g���C
    ld      a, #GAME_STATE_START
    ld      (gameState), a
    jr      19$
    
    ; �Q�[���I�[�o�[
10$:
    ld      a, #GAME_STATE_OVER
    ld      (gameState), a
    
    ; �^�C�}�X�V�̊���
19$:
    
    ; �����̐ݒ�
    ld      e, #0x00
    ld      a, (hl)
    and     #0x02
    jr      z, 20$
    ld      e, #GAME_PROCESS_PILOT_RENDER
20$:
    ld      a, #GAME_PROCESS_STEEL_RENDER
    or      e
    ld      (gameProcess), a
    
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
    
    ; �p�^�[���l�[���̐ݒ�
    ld      hl, #(gamePatternName + 0x0000)
    ld      de, #(gamePatternName + 0x0001)
    ld      bc, #(0x02ff)
    ld      a, #0xc0
    ld      (hl), a
    ldir
    ld      hl, #(gameStringOver)
    ld      de, #(gamePatternName + 0x012b)
    ld      bc, #(0x000a)
    ldir
    ld      hl, #(gameScoreText)
    ld      de, #(gamePatternName + 0x01aa)
    ld      bc, #(0x000c)
    ldir
    
    ; �p�^�[���l�[���̓]��
    call    GameTransferPatternName
    
    ; �^�C�}�̐ݒ�
    xor     a
    ld      (gameTimer), a
    
    ; �����̐ݒ�
    ld      a, #(GAME_PROCESS_NULL)
    ld      (gameProcess), a
    
    ; �������̊���
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; �^�C�}�̍X�V
    ld      hl, #gameTimer
    dec     (hl)
    jr      nz, 19$
    
    ; �`��̒�~
    ld      hl, #(_videoRegister + VDP_R1)
    res     #VDP_R1_BL, (hl)
    
    ; �r�f�I���W�X�^�̓]��
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; �^�C�g���֖߂�
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_appState), a
    
    ; �^�C�}�X�V�̊���
19$:

    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �p�^�[���l�[����]������
;
GameTransferPatternName:

    ; ���W�X�^�̕ۑ�
    
    ; �p�^�[���l�[���̓]��
    xor     a
    ld      hl, #(gamePatternName + 0x0000)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE_0)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES), a
    ld      hl, #(gamePatternName + 0x0100)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE_1)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_BYTES), a
    ld      hl, #(gamePatternName + 0x0200)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE_2)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �萔�̒�`
;

; ������
;
gameStringStart:

    .db     0xe7, 0xe1, 0xed, 0xe5, 0xc0, 0xf3, 0xf4, 0xe1, 0xf2, 0xf4

gameStringOver:

    .db     0xe7, 0xe1, 0xed, 0xe5, 0xc0, 0xc0, 0xef, 0xf6, 0xe5, 0xf2

gameStringScore:

    .db     0xf3, 0xe3, 0xef, 0xf2, 0xe5, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xd0

gameStringRest:

    .db     0xf2, 0xe5, 0xf3, 0xf4, 0xc0, 0xd0


; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

; ���
;
gameState:
    
    .ds     1
    
; ����
;
gameProcess:

    .ds     1

; �^�C�}
;
gameTimer:

    .ds     1

; �X�R�A
;
gameScore:

    .ds     5

gameScoreText:

    .ds     12

; �c�@
;
gameRest:

    .ds     1

gameRestText:

    .ds     6

; �p�^�[���l�[��
;
gamePatternName:

    .ds     0x300
