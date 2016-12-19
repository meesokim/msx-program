; Back.s : �w�i
;



; ���W���[���錾
;
    .module Back


; �Q�ƃt�@�C��
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include	"Back.inc"


; �O���ϐ��錾
;
    .globl  _bg



; CODE �̈�
;
    .area   _CODE


; �w�i�����[�h����
;
_BackLoad::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    push    de
    
    ; �p�^�[���l�[���e�[�u���̃��[�h
    call    BackLoadPatternNameTable
    
    ; �J���[�e�[�u���̃��[�h
    call    BackLoadColorTable
    
    ; �n�C�X�R�A�̍쐬
    call    BackMakeHiscorePatternNameTable
    
    ; �n�C�X�R�A�̓]��
    ld      a, (_videoPort + 1)
    inc     a
    ld      c, a
    ld      a, #<(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_HISCORE)
    out     (c), a
    ld      a, #(>(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_HISCORE) | 0b01000000)
    out     (c), a
    dec     c
    ld      hl, #hiscorePatternNameTable
    ld      b, #0x06
    otir
    
    ; ���݂̃X�R�A�̍쐬
    call    BackMakeScorePatternNameTable
    
    ; ���݂̃X�R�A�̓]��
    ld      a, (_videoPort + 1)
    inc     a
    ld      c, a
    ld      a, #<(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_SCORE)
    out     (c), a
    ld      a, #(>(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_SCORE) | 0b01000000)
    out     (c), a
    dec     c
    ld      hl, #scorePatternNameTable
    ld      b, #0x06
    otir
    
    ; �X�R�A�̔{���̍쐬
    call    BackMakeRatePatternNameTable
    
    ; �X�R�A�̔{���̓]��
    ld      a, (_videoPort + 1)
    inc     a
    ld      c, a
    ld      a, #<(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_RATE)
    out     (c), a
    ld      a, #(>(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_RATE) | 0b01000000)
    out     (c), a
    dec     c
    ld      hl, #ratePatternNameTable
    ld      b, #0x04
    otir
    
    ; �^�C�}�̍쐬
    call    BackMakeTimerPatternNameTable
    
    ; �^�C�}�̓]��
    ld      a, (_videoPort + 1)
    inc     a
    ld      c, a
    ld      a, #<(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_TIMER)
    out     (c), a
    ld      a, #(>(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_TIMER) | 0b01000000)
    out     (c), a
    dec     c
    ld      hl, #timerPatternNameTable
    ld      b, #0x04
    otir
    
    ; �J�E���g�̏�����
    ld      a, #0x01
    ld      (count), a
    
    ; ���W�X�^�̕��A
    pop     de
    pop     bc
    pop     hl
    
    ; �I��
    ret


; �w�i���X�V����
;
_BackUpdate::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    de
    
    ; �J���[�A�j���[�V����
    
    ; �J�E���^�̍X�V
    ld      a, (count)
    dec     a
    jr      nz, 9$
    
    ; �J���[�̐ݒ�
    call    _SystemGetRandom
    and     #0b01111000
    ld      e, a
    ld      d, #0x00
    ld      hl, #colorAnimationTable
    add     hl, de
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_SRC), hl
    ld      hl, #(VIDEO_GRAPHIC1_COLOR_TABLE + 0x10)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_DST), hl
    ld      a, #0x08
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_BYTES), a
    
    ; V-Blank ���̓]���̊J�n
    ld      hl, #_request
    set     #REQUEST_VRAM, (hl)
    
    ; �J�E���^�̍Đݒ�
    ld      a, #0x18
9$:
    ld      (count), a
    
    ; ���W�X�^�̕��A
    pop     de
    pop     hl
    
    ; �I��
    ret


; �n�C�X�R�A��]������
;
_BackTransferHiscore::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    
    ; �n�C�X�R�A�̍쐬
    call    BackMakeHiscorePatternNameTable
    
    ; �n�C�X�R�A�̓]���̐ݒ�
    ld      hl, #hiscorePatternNameTable
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC), hl
    ld      hl, #(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_HISCORE)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST), hl
    ld      a, #0x06
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES), a
    
    ; V-Blank ���̓]���̊J�n
    ld      hl, #_request
    set     #REQUEST_VRAM, (hl)
    
    ; ���W�X�^�̕��A
    pop     hl
    
    ; �I��
    ret


; �X�e�[�^�X��]������
;
_BackTransferStatus::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    push    de
    
    ; ���݂̃X�R�A�̍쐬
    call    BackMakeScorePatternNameTable
    
    ; ���݂̃X�R�A�̓]���̐ݒ�
    ld      hl, #scorePatternNameTable
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC), hl
    ld      hl, #(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_SCORE)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST), hl
    ld      a, #0x06
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES), a
    
    ; �X�R�A�̔{���̍쐬
    call    BackMakeRatePatternNameTable
    
    ; �X�R�A�̔{���̓]���̐ݒ�
    ld      hl, #ratePatternNameTable
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_SRC), hl
    ld      hl, #(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_RATE)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_DST), hl
    ld      a, #0x04
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_BYTES), a
    
    ; �^�C�}�̍쐬
    call    BackMakeTimerPatternNameTable
    
    ; �^�C�}�̓]���̐ݒ�
    ld      hl, #timerPatternNameTable
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_SRC), hl
    ld      hl, #(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_TIMER)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_DST), hl
    ld      a, #0x04
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_BYTES), a
    
    ; V-Blank ���̓]���̊J�n
    ld      hl, #_request
    set     #REQUEST_VRAM, (hl)
    
    ; ���W�X�^�̕��A
    pop     de
    pop     bc
    pop     hl
    
    ; �I��
    ret


; ���S��z�u����
;
_BackStoreLogo::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    
    ; �p�^�[���l�[���e�[�u���̓]���̐ݒ�
    ld      hl, #(logoPatternNameTable + 0x00)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC), hl
    ld      hl, #(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_LOGO + 0x00)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST), hl
    ld      a, #0x10
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES), a
    ld      hl, #(logoPatternNameTable + 0x10)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_SRC), hl
    ld      hl, #(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_LOGO + 0x20)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_DST), hl
    ld      a, #0x10
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_BYTES), a
    
    ; V-Blank ���̓]���̊J�n
    ld      hl, #_request
    set     #REQUEST_VRAM, (hl)
    
    ; ���W�X�^�̕��A
    pop     hl
    
    ; �I��
    ret


; ���S�̔w�i�𕜋�����
;
_BackRestoreLogo::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    
    ; �p�^�[���l�[���e�[�u���̓]���̐ݒ�
    ld      hl, #(_bg + 0x14 + BACK_PATTERN_NAME_TABLE_LOGO + 0x00)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC), hl
    ld      hl, #(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_LOGO + 0x00)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST), hl
    ld      a, #0x10
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES), a
    ld      hl, #(_bg + 0x14 + BACK_PATTERN_NAME_TABLE_LOGO + 0x20)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_SRC), hl
    ld      hl, #(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_LOGO + 0x20)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_DST), hl
    ld      a, #0x10
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_BYTES), a
    
    ; V-Blank ���̓]���̊J�n
    ld      hl, #_request
    set     #REQUEST_VRAM, (hl)
    
    ; ���W�X�^�̕��A
    pop     hl
    
    ; �I��
    ret


; ���b�Z�[�W��z�u����
;
_BackStoreMessage::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    de
    
    ; �p�^�[���l�[���e�[�u���̓]���̐ݒ�
    sla     a
    sla     a
    sla     a
    sla     a
    sla     a
    ld      e, a
    ld      d, #0x00
    ld      hl, #messagePatternNameTable
    add     hl, de
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC), hl
    ld      de, #0x0010
    add     hl, de
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_SRC), hl
    ld      hl, #(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_MESSAGE + 0x00)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST), hl
    ld      a, #0x10
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES), a
    ld      hl, #(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_MESSAGE + 0x20)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_DST), hl
    ld      a, #0x10
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_BYTES), a
    
    ; V-Blank ���̓]���̊J�n
    ld      hl, #_request
    set     #REQUEST_VRAM, (hl)
    
    ; ���W�X�^�̕��A
    pop     de
    pop     hl
    
    ; �I��
    ret


; ���b�Z�[�W�̔w�i�𕜋�����
;
_BackRestoreMessage::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    
    ; �p�^�[���l�[���e�[�u���̓]���̐ݒ�
    ld      hl, #(_bg + 0x14 + BACK_PATTERN_NAME_TABLE_MESSAGE + 0x00)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC), hl
    ld      hl, #(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_MESSAGE + 0x00)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST), hl
    ld      a, #0x10
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES), a
    ld      hl, #(_bg + 0x14 + BACK_PATTERN_NAME_TABLE_MESSAGE + 0x20)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_SRC), hl
    ld      hl, #(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_MESSAGE + 0x20)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_DST), hl
    ld      a, #0x10
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_BYTES), a
    
    ; V-Blank ���̓]���̊J�n
    ld      hl, #_request
    set     #REQUEST_VRAM, (hl)
    
    ; ���W�X�^�̕��A
    pop     hl
    
    ; �I��
    ret


; �p�^�[���l�[���e�[�u����ǂݍ���
;
BackLoadPatternNameTable:
    
    ; VRAM �A�h���X�̐ݒ�
    ld      a, (_videoPort + 1)
    inc     a
    ld      c, a
    ld      a, #<VIDEO_GRAPHIC1_PATTERN_NAME_TABLE
    out     (c), a
    ld      a, #(>VIDEO_GRAPHIC1_PATTERN_NAME_TABLE | 0b01000000)
    out     (c), a
    dec     c
    
    ; �p�^�[���l�[���e�[�u���̓]��
    ld      hl, #(_bg + 0x14)
    ld      b, #0x00
    otir
    otir
    otir
    
    ; �I��
    ret


; �n�C�X�R�A�̃p�^�[���l�[���e�[�u�����쐬����
;
BackMakeHiscorePatternNameTable:
    
    ld      hl, #_appHiscore
    ld      de, #hiscorePatternNameTable
    ld      bc, #0x0500
0$:
    ld      a, (hl)
    cp      #0x00
    jr      z, 1$
    ld      c, #0x10
1$:
    add     a, c
    ld      (de), a
    inc     hl
    inc     de
    djnz    0$
    ld      a, (hl)
    add     a, #0x10
    ld      (de), a
    ret


; ���݂̃X�R�A�̃p�^�[���l�[���e�[�u�����쐬����
;
BackMakeScorePatternNameTable:
    
    ld      hl, #_appScore
    ld      de, #scorePatternNameTable
    ld      bc, #0x0500
0$:
    ld      a, (hl)
    cp      #0x00
    jr      z, 1$
    ld      c, #0x10
1$:
    add     a, c
    ld      (de), a
    inc     hl
    inc     de
    djnz    0$
    ld      a, (hl)
    add     a, #0x10
    ld      (de), a
    ret


; �X�R�A�̔{���̃p�^�[���l�[���e�[�u�����쐬����
;
BackMakeRatePatternNameTable:
    
    ld      hl, #_appRate
    ld      de, #ratePatternNameTable
    ld      c, #0x10
    ld      a, (hl)
    or      a
    jr      z, 0$
    add     a, c
0$:
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    add     a, c
    ld      (de), a
    inc     hl
    inc     de
    ld      a, #0x0e
    ld      (de), a
    inc     de
    ld      a, (hl)
    add     a, c
    ld      (de), a
    ret


; �^�C�}�̃p�^�[���l�[���e�[�u�����쐬����
;
BackMakeTimerPatternNameTable:
    
    ld      hl, #_appTimer
    ld      de, #timerPatternNameTable
    ld      bc, #0x0300
0$:
    ld      a, (hl)
    cp      #0x00
    jr      z, 1$
    ld      c, #0x10
1$:
    add     a, c
    ld      (de), a
    inc     hl
    inc     de
    djnz    0$
    ld      a, (hl)
    add     a, #0x10
    ld      (de), a
    ret


; �J���[�e�[�u����ǂݍ���
;
BackLoadColorTable:
    
    ; VRAM �A�h���X�̐ݒ�
    ld      a, (_videoPort + 1)
    inc     a
    ld      c, a
    ld      a, #<VIDEO_GRAPHIC1_COLOR_TABLE
    out     (c), a
    ld      a, #(>VIDEO_GRAPHIC1_COLOR_TABLE | 0b01000000)
    out     (c), a
    dec     c
    
    ; �J���[�e�[�u���̓]��
    ld      hl, #colorTable
    ld      b, #0x20
    otir
    
    ; �I��
    ret


; �萔�̒�`
;

; �J���[�e�[�u��
;
colorTable:
    
    .db     0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1
    .db     0x01, 0x01, 0x51, 0x51, 0x91, 0x91, 0xb1, 0xb1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1

colorAnimationTable:
    
    .db     0x01, 0x01, 0xf1, 0xf1, 0x91, 0x91, 0xb1, 0xb1
    .db     0x01, 0x01, 0x51, 0x51, 0xf1, 0xf1, 0xb1, 0xb1
    .db     0x01, 0x01, 0x51, 0x51, 0x91, 0x91, 0xf1, 0xf1
    .db     0x01, 0x01, 0x51, 0x51, 0x91, 0x91, 0xb1, 0xb1
    .db     0x01, 0x01, 0xf1, 0xf1, 0xb1, 0xb1, 0x51, 0x51
    .db     0x01, 0x01, 0x91, 0x91, 0xf1, 0xf1, 0x51, 0x51
    .db     0x01, 0x01, 0x91, 0x91, 0xb1, 0xb1, 0xf1, 0xf1
    .db     0x01, 0x01, 0x91, 0x91, 0xb1, 0xb1, 0x51, 0x51
    .db     0x01, 0x01, 0xf1, 0xf1, 0x51, 0x51, 0x91, 0x91
    .db     0x01, 0x01, 0xb1, 0xb1, 0xf1, 0xf1, 0x91, 0x91
    .db     0x01, 0x01, 0xb1, 0xb1, 0x51, 0x51, 0xf1, 0xf1
    .db     0x01, 0x01, 0xb1, 0xb1, 0x51, 0x51, 0x91, 0x91
    .db     0x01, 0x01, 0xf1, 0xf1, 0x91, 0x91, 0xb1, 0xb1
    .db     0x01, 0x01, 0x51, 0x51, 0xf1, 0xf1, 0xb1, 0xb1
    .db     0x01, 0x01, 0x51, 0x51, 0x91, 0x91, 0xf1, 0xf1
    .db     0x01, 0x01, 0x51, 0x51, 0x91, 0x91, 0xb1, 0xb1

; ���S�f�[�^
;
logoPatternNameTable:
    
    .db     0x40, 0x41, 0x48, 0x49, 0x50, 0x51, 0x58, 0x59, 0x60, 0x61, 0x68, 0x69, 0x70, 0x71, 0x78, 0x79
    .db     0x42, 0x43, 0x4a, 0x4b, 0x52, 0x53, 0x5a, 0x5b, 0x62, 0x63, 0x6a, 0x6b, 0x72, 0x73, 0x7a, 0x7b

; ���b�Z�[�W�f�[�^
;
messagePatternNameTable:
    
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x33, 0x34, 0x21, 0x32, 0x34, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x34, 0x29, 0x2d, 0x25, 0x00, 0x35, 0x30, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x27, 0x21, 0x2d, 0x25, 0x00, 0x2f, 0x36, 0x25, 0x32, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x28, 0x29, 0x00, 0x33, 0x23, 0x2f, 0x32, 0x25, 0x01, 0x00, 0x00, 0x00



; DATA �̈�
;
    .area   _DATA


; �ϐ��̒�`
;

; �n�C�X�R�A
;
hiscorePatternNameTable:
    
    .ds     6

; ���݂̃X�R�A
;
scorePatternNameTable:
    
    .ds     6

; �X�R�A�̔{��
;
ratePatternNameTable:
    
    .ds     4

; �^�C�}
;
timerPatternNameTable:
    
    .ds     4

; �J�E���g
;
count:
    
    .ds     1



