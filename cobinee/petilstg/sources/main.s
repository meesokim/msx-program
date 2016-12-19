; main.s : ���C���v���O����
;


; ���W���[���錾
;
    .module main

; �Q�ƃt�@�C��
;
    .include    "bios.inc"
    .include    "System.inc"
    .include    "App.inc"

; �}�N���̒�`
;

; �^�C�}���荞�݃J�E���^
H_TIMI_COUNT    =   0x02


; CODE �̈�
;
    .area   _CODE

; ���C���v���O����
;
_main::
    
    ; ������
    
    ; �V�X�e���̏�����
    call    _SystemInitialize
    
    ; �A�v���P�[�V�����̏�����
    call    _AppInitialize
    
    ; ���荞�݂̋֎~
    di
    
    ; �^�C�}���荞�ݏ����̕ۑ�
    ld      hl, #H.TIMI
    ld      de, #h.timiRoutine
    ld      bc, #5
    ldir
    
    ; �^�C�}���荞�ݏ����̏�������
    ld      a, #0xc3
    ld      (H.TIMI + 0), a
    ld      hl, #H.timiEntry
    ld      (H.TIMI + 1), hl
    
    ; �^�C�}���荞�݃J�E���^�̏�����
    xor     a
    ld      (h.timiCount), a
    
    ; ���荞�݋֎~�̉���
    ei
    
    ; �L�����Z���҂�
0$:
    ld      a, (_flag)
    bit     #FLAG_CANCEL, a
    jr      z, 0$
    
    ; �I��
    
    ; �A�v���P�[�V�����̏I��
    
    ; �V�X�e���̏I��
    
    ; �L�[�{�[�h�o�b�t�@�̃N���A
    call    KILBUF
    
    ; ���荞�݂̋֎~
    di
    
    ; �^�C�}���荞�ݏ����̕��A
    ld      hl, #h.timiRoutine
    ld      de, #H.TIMI
    ld      bc, #5
    ldir
    
    ; ���荞�݋֎~�̉���
    ei
    
    ; �I��
    ret

; �^�C�}���荞�݂̃G���g��
;
H.timiEntry::
    
    ; ���W�X�^�̕ۑ�
    push    af
    push    hl
    
    ; ���荞�݋֎~�̉���
    ei
    
    ; �^�C�}���荞�݃J�E���^�̍X�V
    ld      hl, #h.timiCount
    inc     (hl)
    
    ; ���łɊ��荞�ݍς݂��ǂ���
    ld      hl, #_flag
    bit     #FLAG_H_TIMI, (hl)
    jr      nz, H.timiEntryEnd
    
    ; �w�肳�ꂽ�^�C�}���荞�݃J�E���^�ɓ��B������
    ld      a, (h.timiCount)
    cp      #H_TIMI_COUNT
    jr      c, H.timiEntryEnd
    
    ; �����̊J�n
    set     #FLAG_H_TIMI, (hl)
    
    ; ���荞�݃J�E���^�̃N���A
    xor     a
    ld      (h.timiCount), a
    
    ; ���N�G�X�g�̎擾
    ld      a, (_request)
    ld      h, a
    
    ; �r�f�I���W�X�^�̓]��
    bit     #REQUEST_VIDEO_REGISTER, h
    call    nz, _SystemTransferVideoRegister
    
    ; VRAM �̓]��
    bit     #REQUEST_VRAM, h
    call    nz, _SystemTransferVram
    
    ; �X�v���C�g�̓]��
    call    _SystemTransferSprite
    
    ; �L�[���͂̍X�V
    call    _SystemUpdateInput
    
    ; �T�E���h�̍X�V
    call    _SystemUpdateSound
    
    ; STOP �L�[�ɂ��L�����Z��
    ld      a, (_input + INPUT_BUTTON_STOP)
    dec     a
    jr      nz, H.timiEntryDone
    ld      hl, #_flag
    set     #FLAG_CANCEL, (hl)
    
    ; �����̊���
H.timiEntryDone:
    
    ; �A�v���P�[�V�����̍X�V
    call    _AppUpdate
    
    ; ���荞�݂̊���
    ld      hl, #_flag
    res     #FLAG_H_TIMI, (hl)
    
    ; �G���g���̏I��
H.timiEntryEnd:
    
    ; ���W�X�^�̕��A
    pop     hl
    pop     af
    
    ; �ۑ����ꂽ�^�C�}���荞�݃��[�`���̎��s
    jp      h.timiRoutine
    ret

; �萔��`
;


; DATA �̈�
;
    .area   _DATA

; �ϐ���`
;

; �^�C�}���荞�݃��[�`��
;
h.timiRoutine:
    
    .ds     5

; �^�C�}���荞�݃J�E���^
;
h.timiCount:

    .ds     1
    
