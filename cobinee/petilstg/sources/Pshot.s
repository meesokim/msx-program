; Pshot.s : �v���C���[�V���b�g
;


; ���W���[���錾
;
    .module Pshot

; �Q�ƃt�@�C��
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include	"Unit.inc"
    .include	"Enemy.inc"
    .include	"Pshot.inc"
    
; �}�N���̒�`
;

; ���j�b�g
PSHOT_UNIT_E            =   0x10
PSHOT_UNIT_COUNT        =   0x11
PSHOT_UNIT_X_DISTANCE   =   0x12
PSHOT_UNIT_X_START      =   0x13
PSHOT_UNIT_X_MOVE       =   0x14
PSHOT_UNIT_Y_DISTANCE   =   0x15
PSHOT_UNIT_Y_START      =   0x16
PSHOT_UNIT_Y_MOVE       =   0x17


; CODE �̈�
;
    .area   _CODE

; �v���C���[�V���b�g������������
;
_PshotInitialize::
    
    ; ���W�X�^�̕ۑ�
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �v���C���[�V���b�g�����Z�b�g����
;
_PshotReset::
    
    ; ���W�X�^�̕ۑ�
    
    ; ���j�b�g�̏�����
    ld      ix, #(_unit + (UNIT_PSHOT + 0) * UNIT_SIZE)
    ld      a, #-0x50
    ld      PSHOT_UNIT_X_START(ix), a
    ld      a, #0x01
    ld      PSHOT_UNIT_X_MOVE(ix), a
    ld      a, #0x30
    ld      PSHOT_UNIT_Y_START(ix), a
    ld      a, #-0x01
    ld      PSHOT_UNIT_Y_MOVE(ix), a
    ld      ix, #(_unit + (UNIT_PSHOT + 1) * UNIT_SIZE)
    ld      a, #0x50
    ld      PSHOT_UNIT_X_START(ix), a
    ld      a, #-0x01
    ld      PSHOT_UNIT_X_MOVE(ix), a
    ld      a, #0x30
    ld      PSHOT_UNIT_Y_START(ix), a
    ld      a, #-0x01
    ld      PSHOT_UNIT_Y_MOVE(ix), a
    
    ; ���Ɍ��ʒu�̏�����
    xor     a
    ld      (pshotFirePosition), a
    
    ; �Ə��̕\���v���C�I���e�B�̏�����
    ld      a, #GAME_SPRITE_SIGHT_0
    ld      (pshotSightPriority), a
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �v���C���[�V���b�g���X�V����
;
_PshotUpdate::
    
    ; ���W�X�^�̕ۑ�
    
    ; �V���b�g������
    call    PshotFire
    
    ; �V���b�g�̈ړ�
    call    PshotMove
    
    ; �Ə��̕\���v���C�I���e�B�̍X�V
    ld      hl, #pshotSightPriority
    ld      a, (hl)
    xor     #0b01100000
    ld      (hl), a
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret
    
; �v���C���[�V���b�g��`�悷��
;
_PshotRender::
    
    ; ���W�X�^�̕ۑ�
    
    ; �Ə��̕`��
    ld      a, (pshotSightPriority)
    ld      e, a
    ld      d, #0x00
    ld      hl, #_sprite
    add     hl, de
    ld      a, (_gameSightY)
    add     a, #0x48
    ld      (hl), a
    inc     hl
    ld      a, (_gameSightX)
    add     a, #0x78
    ld      (hl), a
    inc     hl
    ld      a, #0x0c
    ld      (hl), a
    inc     hl
    ld      a, #0x0f
    ld      (hl), a
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �v���C���[�V���b�g������
;
PshotFire:
    
    ; ���W�X�^�̕ۑ�
    
    ; �{�^���������ꂽ
    ld      a, (_gameFire)
    or      a
    jr      z, 9$
    
    ; �V���b�g�̍쐬
    ld      hl, #pshotFirePosition
    ld      a, (hl)
    or      a
    jr      z, 0$
    ld      a, #UNIT_SIZE
0$:
    add     a, #(UNIT_PSHOT * UNIT_SIZE)
    ld      e, a
    ld      d, #0x00
    ld      ix, #_unit
    add     ix, de
    ld      a, UNIT_TYPE(ix)
    or      a
    jr      nz, 9$
    ld      a, (hl)
    add     a, #UNIT_TYPE_PSHOT_LEFT
    ld      UNIT_TYPE(ix), a
    xor     a
    ld      UNIT_COLOR(ix), a
    ld      UNIT_Z_POSITION_L(ix), a
    ld      a, #-0x01
    ld      UNIT_Z_POSITION_H(ix), a
    ld      UNIT_DIV_Z(ix), a
    ld      a, (_gameSightX)
    ld      e, a
    ld      a, PSHOT_UNIT_X_START(ix)
    ld      UNIT_X_DRAW(ix), a
    sub     e
    jp      p, 1$
    neg
1$:
    ld      PSHOT_UNIT_X_DISTANCE(ix), a
    ld      PSHOT_UNIT_COUNT(ix), a
    ld      a, (_gameSightY)
    ld      e, a
    ld      a, PSHOT_UNIT_Y_START(ix)
    ld      UNIT_Y_DRAW(ix), a
    sub     e
    jp      p, 2$
    neg
2$:
    ld      PSHOT_UNIT_Y_DISTANCE(ix), a
    xor     a
    ld      PSHOT_UNIT_E(ix), a
    ld      a, #0x01
    sub     (hl)
    ld      (hl), a
    
    ; �r�d�̐ݒ�
    ld      hl, #pshotSeShot
    ld      (_soundRequest + 6), hl
    
    ; �쐬�̊���
9$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret
    

; �v���C���[�V���b�g���ړ�����
;
PshotMove:
    
    ; ���W�X�^�̕ۑ�
    
    ; �ړ��̊J�n
    ld      ix, #(_unit + UNIT_PSHOT * UNIT_SIZE)
    ld      b, #UNIT_PSHOT_N
0$:
    ld      a, UNIT_TYPE(ix)
    or      a
    jr      z, 9$
    push    bc
    
    ; �ړ��̊���
    ld      a, PSHOT_UNIT_COUNT(ix)
    or      a
    jr      nz, 1$
    ld      UNIT_TYPE(ix), a
    ld      UNIT_DIV_Z(ix), a
    
    ; �w�x�y�̈ړ�
1$:
    ld      c, a
    ld      b, #0x0c
    sub     b
    jr      nc, 2$
    ld      b, c
    xor     a
2$:
    ld      PSHOT_UNIT_COUNT(ix), a
    ld      l, UNIT_Z_POSITION_L(ix)
    ld      h, UNIT_Z_POSITION_H(ix)
3$:
    ld      a, PSHOT_UNIT_E(ix)
    add     a, PSHOT_UNIT_Y_DISTANCE(ix)
    ld      e, a
    sub     PSHOT_UNIT_X_DISTANCE(ix)
    jr      c, 4$
    ld      e, a
    ld      a, UNIT_Y_DRAW(ix)
    add     a, PSHOT_UNIT_Y_MOVE(ix)
    ld      UNIT_Y_DRAW(ix), a
4$:
    ld      PSHOT_UNIT_E(ix), e
    ld      a, UNIT_X_DRAW(ix)
    add     a, PSHOT_UNIT_X_MOVE(ix)
    ld      UNIT_X_DRAW(ix), a
    ld      de, #-(0x0f00 / (0x50 / 0x08))
    add     hl, de
    djnz    3$
    ld      UNIT_Z_POSITION_L(ix), l
    ld      UNIT_Z_POSITION_H(ix), h
    
    ; ���̃V���b�g��
8$:
    pop     bc
9$:
    ld      de, #UNIT_SIZE
    add     ix, de
    djnz    0$
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret
    
; �v���C���[�V���b�g�̃q�b�g�`�F�b�N���s��
;
_PshotHit::
    
    ; ���W�X�^�̕ۑ�
    
    ; �G�l�~�[�̑���
    ld      iy, #(_unit + UNIT_ENEMY * UNIT_SIZE)
    ld      b, #UNIT_ENEMY_N
00$:
    ld      a, UNIT_DIV_Z(iy)
    or      a
    jr      z, 90$
    ld      a, ENEMY_UNIT_DAMAGE(iy)
    or      a
    jr      nz, 90$
    push    bc
    
    ; �V���b�g�̑���
    ld      ix, #(_unit + UNIT_PSHOT * UNIT_SIZE)
    ld      b, #UNIT_PSHOT_N
10$:
    ld      a, UNIT_TYPE(ix)
    or      a
    jr      z, 19$
    
    ; �Փ˔���
    ld      e, UNIT_R(iy)
    ld      a, UNIT_X_DRAW(iy)
    sub     UNIT_X_DRAW(ix)
    jp      p, 11$
    neg
11$:
    cp      e
    jr      nc, 19$
    ld      a, UNIT_Y_DRAW(iy)
    sub     UNIT_Y_DRAW(ix)
    jp      p, 12$
    neg
12$:
    cp      e
    jr      nc, 19$
    ld      l, UNIT_Z_POSITION_L(iy)
    ld      h, UNIT_Z_POSITION_H(iy)
    ld      e, UNIT_Z_POSITION_L(ix)
    ld      d, UNIT_Z_POSITION_H(ix)
    or      a
    sbc     hl, de
    jr      c, 19$
    
    ; �q�b�g
    ld      a, ENEMY_UNIT_HP(iy)
    or      a
    ld      a, #0x10
    ld      hl, #pshotSeBomb
    jr      z, 13$
    dec     ENEMY_UNIT_HP(iy)
    jr      z, 13$
    ld      a, #0x08
    ld      hl, #pshotSeHit
13$:
    ld      ENEMY_UNIT_DAMAGE(iy), a
    ld      (_soundRequest + 6), hl
    xor     a
    ld      UNIT_TYPE(ix), a
    
    ; ���̃V���b�g��
19$:
    ld      de, #UNIT_SIZE
    add     ix, de
    djnz    10$
    
    ; ���̃G�l�~�[��
    pop     bc
90$:
    ld      de, #UNIT_SIZE
    add     iy, de
    djnz    00$
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �萔�̒�`
;

; �r�d
;
pshotSeShot:

;    .ascii  "T1V15L0O4CO3BAG-EDCO2BA"
    .ascii  "T1V15L0O4CF+O5CO4F+CO3C"
    .db     0x00

pshotSeHit:

    .ascii  "T1V15L0O3CD"
    .db     0x00
    
pshotSeBomb:

    .ascii  "T1V15L0"
    .ascii  "O3GO2D-O3EO2D-O3CO2D-O2GD-ED-"
    .ascii  "O2CO1D-O2D-O1CO2CO1D-O2D-O1CO2CO1D-O2D-O1CO2CO1D-O2D-O1C"
    .db     0x00


; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

; ���Ɍ��ʒu
;
pshotFirePosition:

    .ds     1

; �Ə��̕\���v���C�I���e�B
;
pshotSightPriority:

    .ds     1
    