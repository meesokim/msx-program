; Shot.s : �V���b�g
;


; ���W���[���錾
;
    .module Shot

; �Q�ƃt�@�C��
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include	"Game.inc"
    .include	"Ship.inc"
    .include	"Shot.inc"

; �}�N���̒�`
;


; CODE �̈�
;
    .area   _CODE

; �V���b�g������������
;
_ShotInitialize::
    
    ; ���W�X�^�̕ۑ�
    
    ; �V���b�g�̏�����
    ld      hl, #(_shot + 0x0000)
    ld      de, #(_shot + 0x0001)
    ld      bc, #(SHOT_SIZE * SHOT_N - 1)
    xor     a
    ld      (hl), a
    ldir
    
    ; �^�C�}�̏�����
    xor     a
    ld      (shotTimer), a
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �V���b�g�𐶐�����
;
_ShotGenerate:
    
    ; ���W�X�^�̕ۑ�
    push    ix
    
    ; �󂫂�T��
    ld      ix, #_shot
    ld      de, #SHOT_SIZE
    ld      b, #SHOT_N
10$:
    ld      a, SHOT_STATE(ix)
    or      a
    jr      z, 11$
    ld      de, #SHOT_SIZE
    add     ix, de
    djnz    10$
    jr      19$
    
    ; �V���b�g�̐���
11$:
    ld      iy, #_ship
    ld      a, SHIP_POSITION_X(iy)
    sub     #0x0c
    ld      SHOT_POSITION_X(ix), a
    ld      SHOT_RANGE_LEFT(ix), a
    add     a, #0x07
    ld      SHOT_RANGE_RIGHT(ix), a
    ld      a, SHIP_POSITION_Y(iy)
    ld      SHOT_POSITION_Y(ix), a
    ld      SHOT_RANGE_TOP(ix), a
    ld      SHOT_RANGE_BOTTOM(ix), a
    inc     SHOT_STATE(ix)

    ; �r�d�̍Đ�
    ld      hl, #shotSe
    ld      (_soundRequest + 0x0006), hl
    
    ; �����̊���
19$:

    ; ���W�X�^�̕��A
    pop     ix
    
    ; �I��
    ret

; �V���b�g���X�V����
;
_ShotUpdate::
    
    ; ���W�X�^�̕ۑ�
    
    ; �V���b�g�̑���
    ld      ix, #_shot
    ld      de, #SHOT_SIZE
    ld      b, #SHOT_N
10$:
    ld      a, SHOT_STATE(ix)
    or      a
    jr      z, 19$
    
    ; �ړ�
    ld      a, SHOT_POSITION_X(ix)
    sub     #0x08
    jr      c, 18$
    ld      SHOT_POSITION_X(ix), a
    
    ; �͈͂̎擾
    ld      SHOT_RANGE_LEFT(ix), a
    add     a, #0x07
    ld      SHOT_RANGE_RIGHT(ix), a
    jr      19$
    
    ; �ړ��̊���
18$:
    xor     a
    ld      SHOT_STATE(ix), a
    
    ; �����̊���
19$:
    add     ix, de
    djnz    10$
    
    ; �^�C�}�̍X�V
    ld      hl, #shotTimer
    inc     (hl)
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret
    
; �V���b�g��`�悷��
;
_ShotRender::
    
    ; ���W�X�^�̕ۑ�
    
    ; �V���b�g�̑���
    ld      ix, #_shot
    ld      a, (shotTimer)
    and     #0x03
    add     a, a
    add     a, a
    ld      c, a
    ld      b, #SHOT_N
10$:
    ld      a, SHOT_STATE(ix)
    or      a
    jr      z, 19$

    ; �X�v���C�g�̕`��
    ld      hl, #(_sprite + GAME_SPRITE_SHOT)
    ld      e, c
    ld      d, #0x00
    add     hl, de
    ld      a, #0x04
    add     a, c
    and     #0x0f
    ld      c, a
    ld      a, SHOT_POSITION_Y(ix)
    dec     a
    ld      (hl), a
    inc     hl
    ld      a, SHOT_POSITION_X(ix)
    ld      (hl), a
    inc     hl
    ld      a, #0x38
    ld      (hl), a
    inc     hl
    ld      a, (_appColor)
    ld      (hl), a
;   inc     hl
    
    ; �����̊���
19$:
    ld      de, #SHOT_SIZE
    add     ix, de
    djnz    10$
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �萔�̒�`
;

; �r�d
;
shotSe:
    
    .ascii  "T1V13L0O6CO5F+O6CO5F+CO4F+"
    .db     0x00


; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

; �V���b�g
;
_shot::

    .ds     SHOT_SIZE * SHOT_N

; �^�C�}
;
shotTimer:

    .ds     1
