; Title.s : �^�C�g��
;



; ���W���[���錾
;
    .module Title


; �Q�ƃt�@�C��
;
    .include    "bios.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include	"Back.inc"
    .include	"Title.inc"



; CODE �̈�
;
    .area   _CODE


; �^�C�g�����X�V����
;
_TitleUpdate::
    
    ; ��Ԃ̎擾
    ld      a, (_appState)
    
    ; ������
    cp      #TITLE_STATE_INIT
    jr      nz, 00$
    call    TitleInit
    jr      TitleUpdateEnd
00$:
    
    ; ���[�h
    cp      #TITLE_STATE_LOAD
    jr      nz, 01$
    call    TitleLoad
    jr      TitleUpdateEnd
01$:
    
    ; �ҋ@
    cp      #TITLE_STATE_LOOP
    jr      nz, 02$
    call    TitleLoop
    jr      TitleUpdateEnd
02$:
    
    ; �A�����[�h
    cp      #TITLE_STATE_UNLOAD
    jr      nz, 03$
    call    TitleUnload
    jr      TitleUpdateEnd
03$:
    
    ; �I��
    call    TitleEnd
    
    ; �X�V�̏I��
TitleUpdateEnd:
    
    ; �w�i�̍X�V
    call    _BackUpdate
    
    ; �I��
    ret


; �^�C�g��������������
;
TitleInit:
    
    ; �X�v���C�g�̃N���A
    call    _SystemClearSprite
    
    ; ���t�̒�~
    ld      hl, #mmlNull
    ld      (_soundRequest + 0), hl
    ld      (_soundRequest + 2), hl
    ld      (_soundRequest + 4), hl
    ld      (_soundRequest + 6), hl
    
    ; ��Ԃ̍X�V
    ld      a, #TITLE_STATE_LOAD
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; �I��
    ret


; �^�C�g�������[�h����
;
TitleLoad::
    
    ; ���S�̃��[�h
    call    _BackStoreLogo
    
    ; ��Ԃ̍X�V
    ld      a, #TITLE_STATE_LOOP
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; �I��
    ret


; �^�C�g����ҋ@����
;
TitleLoop:
    
    ; ��Ԃ̎擾
    ld      a, (_appPhase)
    or      a
    jr      nz, TitleLoopMain
    
    ; ���S�̏�����
    ld      a, #0x01
    ld      (count), a
    
    ; ��Ԃ̍X�V
    ld      hl, #_appPhase
    inc     (hl)
    
    ; �ҋ@�̏���
TitleLoopMain:
    
    ; ��Ԃ̎擾
    ld      a, (_appPhase)
    cp      #0x01
    jr      nz, TitleLoopWait
    
    ; SPACE �L�[
    ld      a, (_input + INPUT_BUTTON_SPACE)
    cp      #0x01
    jr      nz, TitleLoopDone
    
    ; ���t�̊J�n
    ld      hl, #mmlStartChannel0
    ld      (_soundRequest + 0), hl
    ld      hl, #mmlStartChannel1
    ld      (_soundRequest + 2), hl
    ld      hl, #mmlStartChannel2
    ld      (_soundRequest + 4), hl
    
    ; ��Ԃ̍X�V
    ld      hl, #_appPhase
    inc     (hl)
    
    ; �ҋ@�̊����҂�
TitleLoopWait:
    
    ; �Q�[���X�^�[�g
    ld      hl, (_soundRequest + 0)
    ld      a, h
    or      l
    ld      hl, (_soundPlay + 0)
    or      h
    or      l
    jr      nz, TitleLoopDone
    
    ; ��Ԃ̍X�V
    ld      a, #TITLE_STATE_UNLOAD
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; �ҋ@�̊���
TitleLoopDone:
    
    ; ���S�̍X�V
    ld      hl, #count
    dec     (hl)
    jr      nz, TitleLoopEnd
    ld      a, #0x04
    ld      (hl), a
    
    ; �J���[�̓]���̐ݒ�
    ld      hl, #colorTable
    ld      a, #0xf1
    ld      b, #0x08
0$:
    ld      (hl), a
    inc     hl
    djnz    0$
    call    _SystemGetRandom
    rra
    rra
    rra
    and     #0b00000011
    ld      e, a
    ld      d, #0x00
    ld      hl, #colorAnimationTable
    add     hl, de
    ld      c, (hl)
    call    _SystemGetRandom
    rra
    rra
    rra
    and     #0b00000111
    ld      e, a
    ld      d, #0x00
    ld      hl, #colorTable
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC), hl
    add     hl, de
    ld      (hl), c
    ld      hl, #(VIDEO_GRAPHIC1_COLOR_TABLE + 0x08)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST), hl
    ld      a, #0x08
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES), a
    
    ; V-Blank ���̓]���̊J�n
    ld      hl, #_request
    set     #REQUEST_VRAM, (hl)
    
    ; �����̏I��
TitleLoopEnd:
    
    ; �I��
    ret


; �^�C�g�����A�����[�h����
;
TitleUnload:
    
    ; ���S�̃A�����[�h
    call    _BackRestoreLogo
    
    ; ��Ԃ̍X�V
    ld      a, #TITLE_STATE_END
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; �I��
    ret


; �^�C�g�����I������
;
TitleEnd:
    
    ; ���[�h�̍X�V
    ld      a, #APP_MODE_GAME
    ld      (_appMode), a
    
    ; ��Ԃ̍X�V
    ld      a, #APP_STATE_NULL
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; �I��
    ret


; �萔�̒�`
;

; �J���[�A�j���[�V�����e�[�u��
;
colorAnimationTable:
    
    .db     0xf1, 0x41, 0x61, 0xa1

; MML �f�[�^
;
mmlNull:
    
    .db     0x00

mmlStartChannel0:
    
    .ascii  "T2S0M12V16L1"
    .ascii  "O5DEADEAB2"
    .ascii  "R4"
    .db     0x00

mmlStartChannel1:
    
    .ascii  "T2V16L1"
    .ascii  "O4AO5DEO4AO5DEF#2"
    .ascii  "R4"
    .db     0x00

mmlStartChannel2:
    
    .ascii  "T2V16L1"
    .ascii  "O4EAO5DO4EAO5DE2"
    .ascii  "R4"
    .db     0x00




; DATA �̈�
;
    .area   _DATA


; �ϐ��̒�`
;

; �J�E���g
;
count:
    
    .ds     1

colorTable:
    
    .ds     8



