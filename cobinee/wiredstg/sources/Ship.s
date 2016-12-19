; Ship.s : ���@
;


; ���W���[���錾
;
    .module Ship

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

; ���@������������
;
_ShipInitialize::
    
    ; ���W�X�^�̕ۑ�
    
    ; ���@�̏�����
    ld      hl, #shipDefault
    ld      de, #_ship
    ld      bc, #SHIP_SIZE
    ldir
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; ���@���X�V����
;
_ShipUpdate::
    
    ; ���W�X�^�̕ۑ�
    
    ; ���@�̎擾
    ld      ix, #_ship
    
    ; ��ޕʂ̏���
    ld      a, SHIP_TYPE(ix)
    cp      #SHIP_TYPE_VICVIPER
    jr      nz, 10$
    call    ShipPlay
    jr      19$
10$:
    cp      #SHIP_TYPE_BOMB
    jr      nz, 19$
    call    ShipBomb
    jr      19$
19$:    
    
    ; �X�v���C�g�̍X�V
    ld      hl, (_ship + SHIP_SPRITE_0)
    ld      de, (_ship + SHIP_SPRITE_1)
    ld      (_ship + SHIP_SPRITE_0), de
    ld      (_ship + SHIP_SPRITE_1), hl
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret
    
; ���@�𑀍삷��
;
ShipPlay:
    
    ; ���W�X�^�̕ۑ�
    
    ; �X�s�[�h�A�b�v
    ld      a, (_input + INPUT_BUTTON_SHIFT)
    dec     a
    jr      nz, 19$
    ld      a, SHIP_SPEED(ix)
    inc     a
    cp      #0x05
    jr      c, 10$
    ld      a, #0x01
10$:
    ld      SHIP_SPEED(ix), a
19$:
    
    ; �����̈ړ�
    ld      a, (_input + INPUT_KEY_UP)
    or      a
    jr      z, 21$
    ld      a, SHIP_POSITION_Y(ix)
    sub     SHIP_SPEED(ix)
    cp      #0x10
    jr      nc, 20$
    ld      a, #0x10
20$:
    ld      SHIP_POSITION_Y(ix), a
    ld      a, #0x02
    jr      23$
21$:
    ld      a, (_input + INPUT_KEY_DOWN)
    or      a
    jr      z, 23$
    ld      a, SHIP_POSITION_Y(ix)
    add     SHIP_SPEED(ix)
    cp      #0xb7
    jr      c, 22$
    ld      a, #0xb7
22$:
    ld      SHIP_POSITION_Y(ix), a
    ld      a, #0x01
23$:
    ld      SHIP_ANIMATION(ix), a
    
    ; �����̈ړ�
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 25$
    ld      a, SHIP_POSITION_X(ix)
    sub     SHIP_SPEED(ix)
    cp      #0x0c
    jr      nc, 24$
    ld      a, #0x0c
24$:
    ld      SHIP_POSITION_X(ix), a
    jr      27$
25$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 27$
    ld      a, SHIP_POSITION_X(ix)
    add     SHIP_SPEED(ix)
    cp      #0xf6
    jr      c, 26$
    ld      a, #0xf6
26$:
    ld      SHIP_POSITION_X(ix), a
27$:
    
    ; �V���b�g
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 39$
    call    _ShotGenerate
    ld      l, SHIP_SHOT_L(ix)
    ld      h, SHIP_SHOT_H(ix)
    inc     hl
    ld      SHIP_SHOT_L(ix), l
    ld      SHIP_SHOT_H(ix), h
39$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; ���@����������
;
ShipBomb:
    
    ; ���W�X�^�̕ۑ�
    
    ; �������̊J�n
    ld      a, SHIP_STATE(ix)
    or      a
    jr      nz, 09$
    
    ; �A�j���[�V�����̐ݒ�
    ld      a, #0x03
    ld      SHIP_ANIMATION(ix), a
    
    ; �^�C�}�̐ݒ�
    ld      a, #0x04
    ld      SHIP_TIMER(ix), a

    ; �r�d�̍Đ�
    ld      hl, #shipSe
    ld      (_soundRequest + 0x0006), hl
    
    ; �������̊���
    inc     SHIP_STATE(ix)
09$:
    
    ; �A�j���[�V�����̍X�V
    dec     SHIP_TIMER(ix)
    jr      nz, 19$
    ld      a, #0x04
    ld      SHIP_TIMER(ix), a
    inc     SHIP_ANIMATION(ix)
    ld      a, SHIP_ANIMATION(ix)
    cp      #0x0b
    jr      nz, 19$
    
    ; ���@�̍폜
    xor     a
    ld      SHIP_TYPE(ix), a
    ld      SHIP_STATE(ix), a
19$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; ���@��`�悷��
;
_ShipRender::
    
    ; ���W�X�^�̕ۑ�
    
    ; �X�v���C�g�̕`��
    ld      ix, #_ship
    ld      a, SHIP_TYPE(ix)
    or      a
    jr      z, 9$
    ld      a, SHIP_ANIMATION(ix)
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #shipSprite
    add     hl, de
    ex      de, hl
    ld      hl, (_ship + SHIP_SPRITE_0)
    ld      a, (_appColor)
    ld      c, a
    ld      a, (de)
    add     a, SHIP_POSITION_Y(ix)
    ld      (hl), a
    inc     hl
    inc     de
    ld      a, (de)
    add     a, SHIP_POSITION_X(ix)
    ld      (hl), a
    inc     hl
    inc     de
    ld      a, (de)
    ld      (hl), a
    inc     hl
    inc     de
    ld      (hl), c
    inc     hl
    inc     de
;   ld      hl, (_ship + SHIP_SPRITE_1)
    ld      a, (de)
    add     a, SHIP_POSITION_Y(ix)
    ld      (hl), a
    inc     hl
    inc     de
    ld      a, (de)
    add     a, SHIP_POSITION_X(ix)
    ld      (hl), a
    inc     hl
    inc     de
    ld      a, (de)
    ld      (hl), a
    inc     hl
    inc     de
    ld      (hl), c
;   inc     hl
;   inc     de
9$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �萔�̒�`
;

; ���@�̏����l
;
shipDefault:

    .db     SHIP_TYPE_VICVIPER
    .db     SHIP_STATE_NULL
    .db     0xc0, 0x60
    .db     0x01
    .db     0x02
    .db     0x00
    .db     0x00
    .db     0x00, 0x00
    .db     0x00, 0x00
    .dw     _sprite + GAME_SPRITE_SHIP_0
    .dw     _sprite + GAME_SPRITE_SHIP_1

; �X�v���C�g
;
shipSprite:

    .db     0xf7, 0xf4, 0x20, 0x00, 0xf7, 0x04, 0x24, 0x00
    .db     0xf7, 0xf4, 0x28, 0x00, 0xf7, 0x04, 0x2c, 0x00
    .db     0xf7, 0xf4, 0x30, 0x00, 0xf7, 0x04, 0x34, 0x00
    .db     0xf7, 0xf8, 0x10, 0x00, 0xf7, 0x08, 0x00, 0x00
    .db     0xf7, 0xf8, 0x14, 0x00, 0xf7, 0x08, 0x00, 0x00
    .db     0xf7, 0xf8, 0x18, 0x00, 0xf7, 0x08, 0x00, 0x00
    .db     0xf7, 0xf8, 0x1c, 0x00, 0xf7, 0x08, 0x00, 0x00
    .db     0xf7, 0xf8, 0x00, 0x00, 0xf7, 0x08, 0x00, 0x00
    .db     0xf7, 0xf8, 0x00, 0x00, 0xf7, 0x08, 0x00, 0x00
    .db     0xf7, 0xf8, 0x00, 0x00, 0xf7, 0x08, 0x00, 0x00
    .db     0xf7, 0xf8, 0x00, 0x00, 0xf7, 0x08, 0x00, 0x00

; �r�d
;
shipSe:

;   .ascii  "T1V15L0O4GO2D-O4EO2D-O4CO2D-O3GO2D-O3EO2D-O3CO2D-O2GD-ED-"
    .ascii  "T1V15L0O3GO1D-O3EO1D-O3CO1D-O2GO1D-O2EO1D-O2CO1D-O1GD-ED-"
    .db     0x00

; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

; ���@
;
_ship::

    .ds     SHIP_SIZE

