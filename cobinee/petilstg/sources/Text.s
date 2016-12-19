; Text.s : �e�L�X�g
;


; ���W���[���錾
;
    .module Text

; �Q�ƃt�@�C��
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include	"Text.inc"

; �}�N���̒�`
;


; CODE �̈�
;
    .area   _CODE

; �e�L�X�g������������
;
_TextInitialize::
    
    ; ���W�X�^�̕ۑ�
    
    ; �e�L�X�g�̏�����
    ld      hl, #0x0000
    xor     a
    ld      (_textPosition), hl
    ld      (_textString), hl
    ld      (_textLength), a
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �e�L�X�g���X�V����
;
_TextUpdate::
    
    ; ���W�X�^�̕ۑ�
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �e�L�X�g��`�悷��
;
_TextRender::

    ; ���W�X�^�̕ۑ�
    
    ; ������̕`��
    ld      hl, (_textString)
    ld      a, h
    or      l
    jr      z, 9$
    ld      ix, (_textPosition)
    ld      a, (_textLength)
    inc     a
    jr      z, 0$
    ld      (_textLength), a
0$:
    ld      b, a
1$:
    ld      c, #0x00
2$:
    ld      a, (hl)
    or      a
    jr      z, 9$
    cp      #'\n
    jr      z, 4$
    sub     #0x20
    jr      z, 3$
    ld      0(ix), a
3$:
    inc     ix
    inc     hl
    inc     c
    djnz    2$
    jr      9$
4$:
    ld      a, #0x20
    sub     c
    ld      e, a
    ld      d, #0x00
    add     ix, de
    inc     hl
    jr      1$
9$:
    
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

; �\���ʒu
;
_textPosition::

    .ds     2

; ������
;
_textString::

    .ds     2

; ������
;
_textLength::

    .ds     1
