; crt0.s : �u�[�g�R�[�h
;


; ���W���[���錾
;
    .module crt0

; �O���֐��錾
;
    .globl  _main


; HEADER �̈�i�v���O�����̃G���g���|�C���g�j
;
    .area   _HEADER (ABS)
    .org    0x4000
	.DW	#0x4241,boot,0,0,0,0,0,0 

; �u�[�g
;
boot:

    ld      hl, #stackfinal
    ld      sp, hl
    call    gsinit              ; �ϐ��̏�����
    call    _main               ; main() �֐��̌Ăяo��

; �I��
;
terminated:

    ld      hl, #terminatedCode ; NEWSTT
    jp      0x4601

; �I���R�[�h
;
terminatedCode:
    
    .db     0x3a, 0x94, 0x00


; CODE �̈�
;
    .area   _CODE


; GSINIT �̈�
;
    .area   _GSINIT

; �ϐ��̏�����
;
gsinit:


; GSFINAL �̈�
;
    .area   _GSFINAL

; �ϐ��̏������̊���
;
gsfinal:

    ret


; DATA �̈�
;
    .area   _DATA

; DATA �̈�̊J�n
;
data:

; �X�^�b�N�̈�
;
stack:

    .ds     256

stackfinal:


; DATA �̈�̖��[
;
    .area   _DATAFINAL

; DATA �̈�̏I��
;
datafinal:
