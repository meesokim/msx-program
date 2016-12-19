; Steel.s : �S��
;


; ���W���[���錾
;
    .module Steel

; �Q�ƃt�@�C��
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include	"Game.inc"
    .include	"Steel.inc"

; �}�N���̒�`
;


; CODE �̈�
;
    .area   _CODE

; �S��������������
;
_SteelInitialize::
    
    ; ���W�X�^�̕ۑ�
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �S�������Z�b�g����
;
_SteelReset::
    
    ; ���W�X�^�̕ۑ�
    
    ; �S���̏�����
    ld      ix, #_steel
    ld      de, #STEEL_SIZE
    xor     a
    ld      b, #STEEL_N
0$:
    ld      STEEL_STATE(ix), a
    add     ix, de
    djnz    0$
    
    ; ���x�̏�����
    ld      a, #0x01
    ld      (_steelSpeed), a
    
    ; �������̏�����
    xor     a
    ld      (_steelFall), a
    
    ; �^�C�}�̏�����
    ld      a, #0x01
    ld      (steelTimer), a
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �S�����X�V����
;
_SteelUpdate::
    
    ; ���W�X�^�̕ۑ�
    
    ; �S���̐���
    ld      hl, #steelTimer
    dec     (hl)
    jr      nz, 19$
    ld      ix, #_steel
    ld      b, #STEEL_N
10$:
    ld      a, STEEL_STATE(ix)
    or      a
    jr      z, 11$
    ld      de, #STEEL_SIZE
    add     ix, de
    djnz    10$
    jr      19$
11$:
    ld      a, #STEEL_STATE_FALL
    ld      STEEL_STATE(ix), a
    ld      a, (_steelSpeed)
    ld      STEEL_SPEED(ix), a
    call    _SystemGetRandom
    cp      #0xe0
    jr      c, 12$
    sub     #0x70
12$:
    and     #0xf0
    ld      STEEL_X(ix), a
    ld      a, #0x20
    ld      STEEL_Y(ix), a
    ld      a, (_steelSpeed)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      c, a
    ld      a, #0x50
    sub     c
    ld      c, a
    call    _SystemGetRandom
    and     #0x1f
    add     a, c
    ld      (steelTimer), a
    ld      hl, #steelSe
    ld      (_soundRequest + 6), hl
19$:
    
    ; �S���̍X�V
    ld      hl, #_steelFall
    ld      ix, #_steel
    ld      b, #STEEL_N
20$:
    ld      a, STEEL_STATE(ix)
    or      a
    jr      z, 29$
    ld      a, STEEL_SPEED(ix)
    add     a, STEEL_Y(ix)
    ld      STEEL_Y(ix), a
    cp      #0xc8
    jr      c, 29$
    xor     a
    ld      STEEL_STATE(ix), a
    inc     (hl)
29$:
    ld      de, #STEEL_SIZE
    add     ix, de
    djnz    20$
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret
    
; �S����`�悷��
;
_SteelRender::
    
    ; ���W�X�^�̕ۑ�
    
    ; �X�v���C�g�̕`��
    ld      hl, #(_sprite + GAME_SPRITE_STEEL)
    ld      ix, #_steel
    ld      b, #STEEL_N
0$:
    ld      a, STEEL_STATE(ix)
    or      a
    jr      z, 9$
    ld      de, #steelSprite
    ld      a, (de)
    add     a, STEEL_Y(ix)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    add     a, STEEL_X(ix)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    add     a, STEEL_Y(ix)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    add     a, STEEL_X(ix)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
9$:
    ld      de, #STEEL_SIZE
    add     ix, de
    djnz    0$
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �萔�̒�`
;

; �X�v���C�g
;
steelSprite:
    
    .db     0xf0, 0x00, 0x18, 0x0d, 0xf0, 0x10, 0x1c, 0x0d

; �r�d
;
steelSe:

    .ascii  "T1L5O4V15CV14CV13CV12CV11CV10CV9CV8CV7CV6CV5CV4CV3CV2CV1C"
    .db     0x00


; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

; �S��
;
_steel::

    .ds     STEEL_SIZE * STEEL_N

; ���x
;
_steelSpeed:

    .ds     1

; ������
;
_steelFall:

    .ds     1

; �^�C�}
;
steelTimer:

    .ds     1

