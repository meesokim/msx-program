; Bullet.s : �e
;


; ���W���[���錾
;
    .module Bullet

; �Q�ƃt�@�C��
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include	"Game.inc"
    .include	"Ship.inc"
    .include	"Bullet.inc"

; �}�N���̒�`
;


; CODE �̈�
;
    .area   _CODE

; �e������������
;
_BulletInitialize::
    
    ; ���W�X�^�̕ۑ�
    
    ; �e�̏�����
    ld      hl, #(_bullet + 0x0000)
    ld      de, #(_bullet + 0x0001)
    ld      bc, #(BULLET_SIZE * BULLET_N - 1)
    xor     a
    ld      (hl), a
    ldir
    ld      a, #0x07
    ld      (_bulletN), a
    
    ; �^�C�}�̏�����
    xor     a
    ld      (bulletTimer), a
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �e�𐶐�����
;
_BulletGenerate::
    
    ; ���W�X�^�̕ۑ�
    push    ix
    
    ; ���@�̑���
    ld      iy, #_ship
    ld      a, SHIP_TYPE(iy)
    cp      #SHIP_TYPE_VICVIPER
    jp      nz, 99$
    
    ; �����̎擾
    ld      a, SHIP_POSITION_X(iy)
    sub     h
    cp      #0x10
    jp      c, 99$
    cp      #0xf0
    jp      nc, 99$
    ld      a, SHIP_POSITION_Y(iy)
    sub     l
    cp      #0x10
    jp      c, 99$
    cp      #0xf0
    jp      nc, 99$
    
    ; ��̎擾
    ld      ix, #_bullet
    ld      de, #BULLET_SIZE
    ld      a, (_bulletN)
    ld      b, a
10$:
    ld      a, BULLET_STATE(ix)
    or      a
    jr      z, 11$
    add     ix, de
    djnz    10$
    jp      99$
    
    ; �����̊J�n
11$:
    xor     a
    ld      BULLET_POSITION_XD(ix), a
    ld      BULLET_POSITION_XI(ix), h
    ld      BULLET_POSITION_YD(ix), a
    ld      BULLET_POSITION_YI(ix), l
    ld      a, SHIP_POSITION_X(iy)
    srl     a
    srl     h
    sub     h
    ld      h, a
    ld      a, SHIP_POSITION_Y(iy)
    srl     a
    srl     l
    sub     l
    ld      l, a
    call    _SystemGetAtan2
    cp      #0x40
    jr      nc, 12$
    call    _SystemGetCos
    ld      BULLET_SPEED_XD(ix), l
    ld      BULLET_SPEED_XI(ix), h
    call    _SystemGetSin
    ld      BULLET_SPEED_YD(ix), l
    ld      BULLET_SPEED_YI(ix), h
    ld      a, #0x01
    ld      BULLET_STATE(ix), a
    jr      18$
12$:
    cp      #0x80
    jr      nc, 13$
    call    _SystemGetSin
    ld      BULLET_SPEED_YD(ix), l
    ld      BULLET_SPEED_YI(ix), h
    ld      b, a
    ld      a, #0x80
    sub     b
    call    _SystemGetCos
    ld      BULLET_SPEED_XD(ix), l
    ld      BULLET_SPEED_XI(ix), h
    ld      a, #0x02
    ld      BULLET_STATE(ix), a
    jr      18$
13$:
    cp      #0xc0
    jr      nc, 14$
    sub     #0x80
    call    _SystemGetCos
    ld      BULLET_SPEED_XD(ix), l
    ld      BULLET_SPEED_XI(ix), h
    call    _SystemGetSin
    ld      BULLET_SPEED_YD(ix), l
    ld      BULLET_SPEED_YI(ix), h
    ld      a, #0x03
    ld      BULLET_STATE(ix), a
    jr      18$
14$:
    ld      b, a
    xor     a
    sub     b
    call    _SystemGetCos
    ld      BULLET_SPEED_XD(ix), l
    ld      BULLET_SPEED_XI(ix), h
    call    _SystemGetSin
    ld      BULLET_SPEED_YD(ix), l
    ld      BULLET_SPEED_YI(ix), h
    ld      a, #0x04
    ld      BULLET_STATE(ix), a
;   jr      18$

    ; ���x�̐ݒ�
18$:
    ld      l, BULLET_SPEED_XD(ix)
    ld      h, BULLET_SPEED_XI(ix)
    add     hl, hl
    ld      BULLET_SPEED_XD(ix), l
    ld      BULLET_SPEED_XI(ix), h
    ld      l, BULLET_SPEED_YD(ix)
    ld      h, BULLET_SPEED_YI(ix)
    add     hl, hl
    ld      BULLET_SPEED_YD(ix), l
    ld      BULLET_SPEED_YI(ix), h
    
    ; �����̊���
99$:
    
    ; ���W�X�^�̕��A
    pop     ix
    
    ; �I��
    ret

; �e���X�V����
;
_BulletUpdate::
    
    ; ���W�X�^�̕ۑ�
    
    ; �e�̑���
    ld      ix, #_bullet
    ld      a, (_bulletN)
    ld      b, a
10$:
    ld      a, BULLET_STATE(ix)
    or      a
    jp      z, 19$
    
    ; �e�̈ړ�
    dec     a
    jr      nz, 11$
    ld      l, BULLET_POSITION_XD(ix)
    ld      h, BULLET_POSITION_XI(ix)
    ld      e, BULLET_SPEED_XD(ix)
    ld      d, BULLET_SPEED_XI(ix)
    add     hl, de
    jp      c, 18$
    ld      BULLET_POSITION_XD(ix), l
    ld      BULLET_POSITION_XI(ix), h
    ld      l, BULLET_POSITION_YD(ix)
    ld      h, BULLET_POSITION_YI(ix)
    ld      e, BULLET_SPEED_YD(ix)
    ld      d, BULLET_SPEED_YI(ix)
    add     hl, de
    jp      c, 18$
    ld      BULLET_POSITION_YD(ix), l
    ld      BULLET_POSITION_YI(ix), h
    jp      19$
11$:
    dec     a
    jr      nz, 12$
    ld      l, BULLET_POSITION_XD(ix)
    ld      h, BULLET_POSITION_XI(ix)
    ld      e, BULLET_SPEED_XD(ix)
    ld      d, BULLET_SPEED_XI(ix)
    or      a
    sbc     hl, de
    jr      c, 18$
    ld      BULLET_POSITION_XD(ix), l
    ld      BULLET_POSITION_XI(ix), h
    ld      l, BULLET_POSITION_YD(ix)
    ld      h, BULLET_POSITION_YI(ix)
    ld      e, BULLET_SPEED_YD(ix)
    ld      d, BULLET_SPEED_YI(ix)
    add     hl, de
    jr      c, 18$
    ld      BULLET_POSITION_YD(ix), l
    ld      BULLET_POSITION_YI(ix), h
    jr      19$
12$:
    dec     a
    jr      nz, 13$
    ld      l, BULLET_POSITION_XD(ix)
    ld      h, BULLET_POSITION_XI(ix)
    ld      e, BULLET_SPEED_XD(ix)
    ld      d, BULLET_SPEED_XI(ix)
    or      a
    sbc     hl, de
    jr      c, 18$
    ld      BULLET_POSITION_XD(ix), l
    ld      BULLET_POSITION_XI(ix), h
    ld      l, BULLET_POSITION_YD(ix)
    ld      h, BULLET_POSITION_YI(ix)
    ld      e, BULLET_SPEED_YD(ix)
    ld      d, BULLET_SPEED_YI(ix)
    or      a
    sbc     hl, de
    jr      c, 18$
    ld      BULLET_POSITION_YD(ix), l
    ld      BULLET_POSITION_YI(ix), h
    jr      19$
13$:
    ld      l, BULLET_POSITION_XD(ix)
    ld      h, BULLET_POSITION_XI(ix)
    ld      e, BULLET_SPEED_XD(ix)
    ld      d, BULLET_SPEED_XI(ix)
    add     hl, de
    jr      c, 18$
    ld      BULLET_POSITION_XD(ix), l
    ld      BULLET_POSITION_XI(ix), h
    ld      l, BULLET_POSITION_YD(ix)
    ld      h, BULLET_POSITION_YI(ix)
    ld      e, BULLET_SPEED_YD(ix)
    ld      d, BULLET_SPEED_YI(ix)
    or      a
    sbc     hl, de
    jr      c, 18$
    ld      BULLET_POSITION_YD(ix), l
    ld      BULLET_POSITION_YI(ix), h
    jr      19$
    
    ; �e�̍폜
18$:
    xor     a
    ld      BULLET_STATE(ix), a
    
    ; ���̒e��
19$:
    ld      de, #BULLET_SIZE
    add     ix, de
    dec     b
    jp      nz, 10$
    
    ; �^�C�}�̍X�V
    ld      hl, #bulletTimer
    inc     (hl)
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �e��`�悷��
;
_BulletRender::
    
    ; ���W�X�^�̕ۑ�
    
    ; �X�v���C�g�̕`��
    ld      ix, #_bullet
    ld      hl, #_sprite + GAME_SPRITE_BULLET
    ld      a, (bulletTimer)
    and     #0x0f
    add     a, a
    add     a, a
    ld      c, a
    ld      a, (_bulletN)
    ld      b, a
10$:
    ld      a, BULLET_STATE(ix)
    or      a
    jr      z, 19$
    ld      hl, #(_sprite + GAME_SPRITE_BULLET)
    ld      e, c
    ld      d, #0x00
    add     hl, de
    ld      a, #0x04
    add     a, c
    and     #0x3f
    ld      c, a
    ld      a, BULLET_POSITION_YI(ix)
    sub     #0x09
    ld      (hl), a
    inc     hl
    ld      a, BULLET_POSITION_XI(ix)
    sub     #0x08
    ld      (hl), a
    inc     hl
    ld      a, #0x3c
    ld      (hl), a
    inc     hl
    ld      a, (_appColor)
    ld      (hl), a
    inc     hl
19$:
    ld      de, #BULLET_SIZE
    add     ix, de
    djnz    10$
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �萔�̒�`
;


; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

; �e
;
_bullet::

    .ds     BULLET_SIZE * BULLET_N

_bulletN::

    .ds     1

; �^�C�}
;
bulletTimer:

    .ds     1
