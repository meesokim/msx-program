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
H.timiEntry:
    
    ; ���W�X�^�̕ۑ�
    push    af
    push    hl
    
    ; ���荞�݋֎~�̉���
    ei
    
    ; ���łɊ��荞�ݍς݂��ǂ���
    ld      hl, #_flag
    bit     #FLAG_H_TIMI, (hl)
    jp      nz, H.timiEntryEnd
    
    ; �����̊J�n
    set     #FLAG_H_TIMI, (hl)
    
    ; ���N�G�X�g�̎擾
    ld      a, (_request)
    ld      h, a
    
    ; �r�f�I���W�X�^�̓]��
    bit     #REQUEST_VIDEO_REGISTER, h
    jr      z, 00$
    call    _SystemTransferVideoRegister
00$:
    
    ; VRAM �̓]��
    bit     #REQUEST_VRAM, h
    jr      z, 01$
    call    _SystemTransferVram
01$:
    
    ; �X�v���C�g�̓]��
    call    _SystemTransferSprite
    
    ; �L�[���͂̍X�V
    call    _SystemUpdateInput
    
    ; �T�E���h�̍X�V
    call    _SystemUpdateSound
    
    ; STOP �L�[�ɂ��L�����Z��
    ld      a, (_input + INPUT_BUTTON_STOP)
    dec     a
    jr      nz, 90$
    ld      hl, #_flag
    set     #FLAG_CANCEL, (hl)
90$:
    
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

mmlChannelC:
    
    .ascii  "T4S0M12V16L4"
    .ascii  "CDED"
    .db     0xff
    
mmlChannelD:
    
    .ascii  "T2S0M12V16L1"
    .ascii  "O5DEADEAB2"
    .ascii  "R4"
    .db     0x00



; DATA �̈�
;
    .area   _DATA


; �ϐ���`
;

; �^�C�}���荞��
;
h.timiRoutine:
    
    .ds     5



