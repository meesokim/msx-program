; System.s : �V�X�e�����C�u����
;


; ���W���[���錾
;
    .module System

; �Q�ƃt�@�C��
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"


; CODE �̈�
;
    .area   _CODE

; �V�X�e��������������
;
_SystemInitialize::
    
    ; ���W�X�^�̕ۑ�
    push    af
    push    bc
    push    de
    push    hl
    push    ix
    push    iy
    
    ; �t���O�̏�����
    xor     a
    ld      (_flag), a
    
    ; �L�[���͂̏�����
    call    SystemInitializeInput
    
    ; �r�f�I�̏�����
    call    SystemInitializeVideo
    
    ; �T�E���h�̏�����
    call    SystemInitializeSound
    
    ; ���W�X�^�̕��A
    pop     iy
    pop     ix
    pop     hl
    pop     de
    pop     bc
    pop     af
    
    ; �I��
    ret

; �L�[���͂�����������  
;
SystemInitializeInput:
    
    ; ���W�X�^�̕ۑ�
    
    ; �L�[���͂̏�����
    ld      hl, #(_input + 0x0000)
    xor     a
    ld      b, #INPUT_SIZE
0$:
    ld      (hl), a
    inc     hl
    djnz    0$
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �L�[�̓��͂��X�V����
;
_SystemUpdateInput::
    
    ; ���W�X�^�̕ۑ�
    
    ; �L�[�̎擾
    xor     a
    call    GTSTCK
    ld      c, a
    ld      b, #0x00
    ld      hl, #inputStickTable
    add     hl, bc
    ld      a, (hl)
    push    af
    ld      a, #0x01
    call    GTSTCK
    ld      c, a
    ld      b, #0x00
    ld      hl, #inputStickTable
    add     hl, bc
    pop     af
    or      (hl)
    ld      c, a
    ld      hl, #(_input + INPUT_KEY_UP)
    ld      b, #0x04
10$:
    srl     c
    jr      c, 11$
    xor     a
    ld      (hl), a
    jr      12$
11$:
    inc     (hl)
    jr      nz, 12$
    dec     (hl)
12$:
    inc     hl
    djnz    10$
    
    ; �{�^���̎擾
    ld      a, #0x00
    call    GTTRIG
    push    af
    ld      a, #0x01
    call    GTTRIG
    ld      c, a
    pop     af
    or      c
    ld      hl, #(_input + INPUT_BUTTON_SPACE)
    jr      z, 20$
    ld      a, (hl)
    inc     a
    jr      nz, 20$
    dec     a
20$:
    ld      (hl), a
    ld      a, #0x03
    call    GTTRIG
    push    af
    ld      a, #0x06
    call    SNSMAT
    cpl
    and     #0x01
    ld      c, a
    pop     af
    or      c
    ld      hl, #(_input + INPUT_BUTTON_SHIFT)
    jr      z, 21$
    ld      a, (hl)
    inc     a
    jr      nz, 21$
    dec     a
21$:
    ld      (hl), a
    ld      a, #0x07
    call    SNSMAT
    ld      c, a
    ld      hl, #(_input + INPUT_BUTTON_ESC)
    bit     #0x02, c
    jr      z, 22$
    xor     a
    ld      (hl), a
    jr      23$
22$:
    inc     (hl)
    jr      nz, 23$
    dec     (hl)
23$:
    inc     hl
    bit     #0x04, c
    jr      z, 24$
    xor     a
    ld      (hl), a
    jr      25$
24$:
    inc     (hl)
    jr      nz, 25$
    dec     (hl)
25$:

    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �r�f�I������������
;
SystemInitializeVideo:
    
    ; ���W�X�^�̕ۑ�
    
    ; �|�[�g�̎擾
    ld      a, (0x0006)
    ld      (_videoPort + 0), a
    ld      a, (0x0007)
    ld      (_videoPort + 1), a
    
    ; ���W�X�^�̎擾
    ld      hl, #RG0SAV
    ld      de, #_videoRegister
    ld      bc, #0x08
    ldir
    
    ; VRAM �̓]���̏�����
    ld      hl, #_videoTransfer
    xor     a
    ld      b, #(VIDEO_TRANSFER_VRAM_SIZE * VIDEO_TRANSFER_SIZE)
10$:
    ld      (hl), a
    inc     hl
    djnz    10$
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; ���W�X�^��]������
;
_SystemTransferVideoRegister::
    
    ; ���W�X�^�̕ۑ�
    
    ; ���荞�݂̋֎~
    di
    
    ; ���W�X�^�̐ݒ�
    ld      hl, #_videoRegister
    ld      a, (_videoPort + 1)
    inc     a
    ld      c, a
    outi
    ld      a, #0x80
    out     (c), a
    outi
    inc     a
    out     (c), a
    outi
    inc     a
    out     (c), a
    outi
    inc     a
    out     (c), a
    outi
    inc     a
    out     (c), a
    outi
    inc     a
    out     (c), a
    outi
    inc     a
    out     (c), a
    outi
    inc     a
    out     (c), a
    
    ; ���荞�݋֎~�̉���
    ei
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; VRAM �Ƀf�[�^��]������
;
_SystemTransferVram::
    
    ; ���W�X�^�̕ۑ�
    push    bc
    push    de
    push    hl
    
    ; ���荞�݂̋֎~
    di
    
    ; �|�[�g�̎擾
    ld      a, (_videoPort + 1)
    ld      d, a
    inc     a
    ld      e, a
    
    ; VRAM 0 �̓]��
    ld      hl, (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC)
    ld      a, l
    or      h
    jr      z, 10$
    ld      c, e
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST + 0x0000)
    out     (c), a
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST + 0x0001)
    or      #0b01000000
    out     (c), a
    ld      c, d
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES)
    ld      b, a
    otir
10$:
    
    ; VRAM 1 �̓]��
    ld      hl, (_videoTransfer + VIDEO_TRANSFER_VRAM_1_SRC)
    ld      a, l
    or      h
    jr      z, 11$
    ld      c, e
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_1_DST + 0x0000)
    out     (c), a
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_1_DST + 0x0001)
    or      #0b01000000
    out     (c), a
    ld      c, d
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_1_BYTES)
    ld      b, a
    otir
11$:
    
    ; VRAM 2 �̓]��
    ld      hl, (_videoTransfer + VIDEO_TRANSFER_VRAM_2_SRC)
    ld      a, l
    or      h
    jr      z, 12$
    ld      c, e
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_2_DST + 0x0000)
    out     (c), a
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_2_DST + 0x0001)
    or      #0b01000000
    out     (c), a
    ld      c, d
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_2_BYTES)
    ld      b, a
    otir
12$:
    
    ; VRAM 3 �̓]��
    ld      hl, (_videoTransfer + VIDEO_TRANSFER_VRAM_3_SRC)
    ld      a, l
    or      h
    jr      z, 13$
    ld      c, e
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_3_DST + 0x0000)
    out     (c), a
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_3_DST + 0x0001)
    or      #0b01000000
    out     (c), a
    ld      c, d
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_3_BYTES)
    ld      b, a
    otir
13$:
    
    ; ���荞�݋֎~�̉���
    ei
    
    ; �]���̊���
    ld      hl, #_videoTransfer
    xor     a
    ld      b, #(VIDEO_TRANSFER_VRAM_SIZE * VIDEO_TRANSFER_SIZE)
91$:
    ld      (hl), a
    inc     hl
    djnz    91$
    
    ; ���W�X�^�̕��A
    pop     hl
    pop     de
    pop     bc
    
    ; �I��
    ret

; �X�v���C�g���N���A����
;
_SystemClearSprite::
    
    ; ���W�X�^�̕ۑ�
    push    bc
    push    hl
    
    ; �X�v���C�g�̃N���A
    ld      hl, #_sprite
    ld      bc, #0x80c0
10$:
    ld      (hl), c
    inc     hl
    djnz    10$
    
    ; ���W�X�^�̕��A
    pop     hl
    pop     bc
    
    ; �I��
    ret

; �X�v���C�g��]������
;
_SystemTransferSprite::
    
    ; ���W�X�^�̕ۑ�
    
    ; �X�v���C�g�A�g���r���[�g�e�[�u���̎擾
    ld      a, (_videoRegister + VDP_R5)
    ld      h, a
    ld      l, #0x00
    srl     h
    rr      l
    
    ; ���荞�݂̋֎~
    di
    
    ; VRAM �A�h���X�̐ݒ�
    ld      a, (_videoPort + 1)
    inc     a
    ld      c, a
    out     (c), l
    ld      a, h
    or      #0b01000000
    out     (c), a
    dec     c
    
    ; �X�v���C�g�A�g���r���[�g�e�[�u���̓]��
    ld      hl, #_sprite
    ld      b, #0x80
    otir
    
    ; ���荞�݋֎~�̉���
    ei
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �T�E���h������������
;
SystemInitializeSound:
    
    ; ���W�X�^�̕ۑ�
    
    ; PSG �̏�����
    call    GICINI
    ld      e, #0b10111111
    ld      a, #0x07
    call    WRTPSG
    
;   ; �T�E���h���W�X�^�̏�����
;   ld      0x00(ix), #0b01010101
;   ld      0x01(ix), #0b00000000
;   ld      0x02(ix), #0b00000000
;   ld      0x03(ix), #0b00000000
;   ld      0x04(ix), #0b00000000
;   ld      0x05(ix), #0b00000000
;   ld      0x06(ix), #0b00000000
;   ld      0x07(ix), #0b10111111
;   ld      0x08(ix), #0b00000000
;   ld      0x09(ix), #0b00000000
;   ld      0x0a(ix), #0b00000000
;   ld      0x0b(ix), #0b00001011
;   ld      0x0c(ix), #0b00000000
;   ld      0x0d(ix), #0b00000000
;   ld      0x0e(ix), #0b00000000
;   ld      0x0f(ix), #0b00000000
    
    ; �T�E���h�f�[�^�̏�����
    ld      hl, #0x0000
    ld      (_soundRequest + 0), hl
    ld      (_soundRequest + 2), hl
    ld      (_soundRequest + 4), hl
    ld      (_soundRequest + 6), hl
    ld      (_soundHead + 0), hl
    ld      (_soundHead + 2), hl
    ld      (_soundHead + 4), hl
    ld      (_soundHead + 6), hl
    ld      (_soundPlay + 0), hl
    ld      (_soundPlay + 2), hl
    ld      (_soundPlay + 4), hl
    ld      (_soundPlay + 6), hl
    
    ; �T�E���h�p�����[�^�̏�����
    ld      a, #0b10111111
    ld      (soundMixing), a
    xor     a
    ld      (soundS), a
    ld      (soundM + 0x0000), a
    ld      (soundM + 0x0001), a
    ld      (soundN), a
10$:
    call    SystemClearSoundChannel
    inc     a
    cp      #0x04
    jr      nz,  10$
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �T�E���h���X�V����
;
_SystemUpdateSound::
    
    ; ���W�X�^�̕ۑ�
    
    ; �X���[�v�̊m�F
    ld      hl, #_flag
    bit     #FLAG_SOUND_SLEEP, (hl)
    jr      z, 09$
    
    ; �X���[�v
    ld      e, #0b10111111
    ld      a, #0x07
    call    WRTPSG
    jp      99$
09$:
    
    ; �`�����l���̑���
    ld      bc, #0x0000
10$:
    
    ; ���N�G�X�g
    ld      ix, #_soundRequest
    add     ix, bc
    ld      a, 0x00(ix)
    or      0x01(ix)
    jr      z, 11$
    ld      l, 0x00(ix)
    ld      h, 0x01(ix)
    ld      0x00(ix), b
    ld      0x01(ix), b
    ld      ix, #_soundHead
    add     ix, bc
    ld      0x00(ix), l
    ld      0x01(ix), h
    ld      ix, #_soundPlay
    add     ix, bc
    ld      0x00(ix), l
    ld      0x01(ix), h
    ld      a, c
    srl     a
    call    SystemClearSoundChannel
11$:
    
    ; �T�E���h�f�[�^�̑���
    ld      ix, #_soundPlay
    add     ix, bc
    ld      a, 0x00(ix)
    or      0x01(ix)
    jp      z, 19$
    
    ; �ҋ@
    ld      hl, #soundRest
    add     hl, bc
    dec     (hl)
    jr      z, 12$
    
    ; ���ʂ̌���
    ld      hl, #soundVminus
    add     hl, bc
    ld      a, (hl)
    or      a
    jp      z, 19$
    dec     (hl)
    jp      nz, 19$
    inc     hl
    ld      a, (hl)
    dec     hl
    ld      (hl), a
    ld      hl, #soundVolume
    add     hl, bc
    ld      a, (hl)
    cp      #0x01
    ccf
    sbc     b
    ld      (hl), a
    ld      e, a
    ld      a, c
    srl     a
    add     a, #0x08
    cp      #0x0b
    ccf
    sbc     b
    call    WRTPSG
    jp      19$
12$:
    
    ; �Đ��|�C���^�̎擾
;   ld      ix, #_soundPlay
;   add     ix, bc
    ld      l, 0x00(ix)
    ld      h, 0x01(ix)
    
    ; MML �̉��
13$:
    ld      a, (hl)
    inc     hl
    
    ; 0x00 : �I�[�R�[�h
    or      a
    jr      nz, 14$
    ld      ix, #_soundHead
    add     ix, bc
    ld      0x00(ix), a
    ld      0x01(ix), a
    ld      ix, #_soundPlay
    add     ix, bc
    ld      0x00(ix), a
    ld      0x01(ix), a
    ld      ix, #soundTone
    add     ix, bc
    ld      0x00(ix), a
    ld      0x01(ix), a
    ld      ix, #soundNoise
    add     ix, bc
    ld      0x00(ix), a
    ld      ix, #soundUpdate
    add     ix, bc
    inc     0x00(ix)
    jp      19$
14$:
    
    ; 0xff : �J��Ԃ�
    cp      #0xff
    jr      nz, 15$
    ld      ix, #_soundHead
    add     ix, bc
    ld      iy, #_soundPlay
    add     iy, bc
    ld      l, 0x00(ix)
    ld      0x00(iy), l
    ld      h, 0x01(ix)
    ld      0x01(iy), h
    jr      13$
15$:
    
    ; 'A'�`'Z' �̏���
    ld      de, #16$
    push    de
    sub     #'A
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      ix, #soundMmlProc
    add     ix, de
    ld      e, 0x00(ix)
    ld      d, 0x01(ix)
    push    de
    pop     ix
    jp      (ix)
;   pop     de
16$:
    jr      c, 13$
    
    ; ���̒����̐ݒ�
    ld      a, (hl)
    cp      #('9 + 0x01)
    jr      nc, 17$
    sub     #'0
    jr      c, 17$
    inc     hl
    jr      18$
17$:
    ld      ix, #soundL
    add     ix, bc
    ld      a, 0x00(ix)
18$:
    ld      e, a
    ld      d, b
    ld      ix, #soundLengthTable
    add     ix, de
    ld      iy, #soundT
    add     iy, bc
    ld      a, 0x00(iy)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    add     ix, de
    ld      iy, #soundRest
    add     iy, bc
    ld      a, 0x00(ix)
    ld      0x00(iy), a
    ld      ix, #soundUpdate
    add     ix, bc
    inc     0x00(ix)
    
    ; �Đ��|�C���^�̕ۑ�
    ld      ix, #_soundPlay
    add     ix, bc
    ld      0x00(ix), l
    ld      0x01(ix), h
    
    ; ���̃`�����l����
19$:
    inc     c
    inc     c
    ld      a, c
    cp      #0x08
    jp      nz, 10$
    
    ; �ݒ�̊m�F
    ld      iy, #soundUpdate
    ld      a, 0x00(iy)
    or      0x02(iy)
    or      0x04(iy)
    or      0x06(iy)
    jp      z, 99$
    
    ; �G���x���[�v���g���̐ݒ�
    ld      hl, #soundM
    ld      e, (hl)
    ld      a, #0x0b
    call    WRTPSG
    inc     hl
    ld      e, (hl)
    ld      a, #0x0c
    call    WRTPSG
    
    ; �m�C�Y���g���̐ݒ�
    ld      a, (soundN)
    ld      e, a
    ld      a, #0x06
    call    WRTPSG
    
    ; �`�����l���̐ݒ�
    ld      a, (soundMixing)
    ld      c, a
    ld      b, #0x00
    
    ; �`�����l���`�̐ݒ�
    ld      a, 0x00(iy)
    or      a
    jr      z, 29$
    ld      a, #0b00001001
    or      c
    ld      c, a
    ld      hl, (soundTone + 0x0000)
    ld      a, h
    or      l
    jr      z, 20$
    ld      a, #0b11111110
    and     c
    ld      c, a
    ld      e, l
    ld      a, #0x00
    call    WRTPSG
    ld      e, h
    ld      a, #0x01
    call    WRTPSG
    jr      21$
20$:
    ld      a, (soundNoise + 0x0000)
    or      a
    jr      z, 22$
    ld      a, #0b11110111
    and     c
    ld      c, a
21$:
    ld      a, (soundV + 0x0000)
22$:
    ld      (soundVolume + 0x0000), a
    ld      e, a
    or      b
    ld      b, a
    ld      a, #0x08
    call    WRTPSG
29$:

    ; �`�����l���a�̐ݒ�
    ld      a, 0x02(iy)
    or      a
    jr      z, 39$
    ld      a, #0b00010010
    or      c
    ld      c, a
    ld      hl, (soundTone + 0x0002)
    ld      a, h
    or      l
    jr      z, 30$
    ld      a, #0b11111101
    and     c
    ld      c, a
    ld      e, l
    ld      a, #0x02
    call    WRTPSG
    ld      e, h
    ld      a, #0x03
    call    WRTPSG
    jr      31$
30$:
    ld      a, (soundNoise + 0x0002)
    or      a
    jr      z, 52$
    ld      a, #0b11101111
    and     c
    ld      c, a
31$:
    ld      a, (soundV + 0x0002)
32$:
    ld      (soundVolume + 0x0002), a
    ld      e, a
    or      b
    ld      b, a
    ld      a, #0x09
    call    WRTPSG
39$:

    ; �`�����l���c�̐ݒ�
    ld      a, 0x06(iy)
    or      a
    jr      z, 49$
    ld      a, #0b00100100
    or      c
    ld      c, a
    ld      hl, (soundTone + 0x0006)
    ld      a, h
    or      l
    jr      z, 40$
    ld      a, #0b11111011
    and     c
    ld      c, a
    ld      e, l
    ld      a, #0x04
    call    WRTPSG
    ld      e, h
    ld      a, #0x05
    call    WRTPSG
    jr      41$
40$:
    ld      a, (soundNoise + 0x0006)
    or      a
    jr      z, 42$
    ld      a, #0b11011111
    and     c
    ld      c, a
41$:
    ld      a, (soundV + 0x0006)
42$:
    ld      (soundVolume + 0x0006), a
    ld      e, a
    or      b
    ld      b, a
    ld      a, #0x0a
    call    WRTPSG
    jr      59$
49$:

    ; �`�����l���b�̐ݒ�
    ld      a, 0x04(iy)
    or      a
    jr      z, 59$
    ld      a, #0b00100100
    or      c
    ld      c, a
    ld      hl, (soundTone + 0x0004)
    ld      a, h
    or      l
    jr      z, 50$
    ld      a, #0b11111011
    and     c
    ld      c, a
    ld      e, l
    ld      a, #0x04
    call    WRTPSG
    ld      e, h
    ld      a, #0x05
    call    WRTPSG
    jr      51$
50$:
    ld      a, (soundNoise + 0x0004)
    or      a
    jr      z, 52$
    ld      a, #0b11011111
    and     c
    ld      c, a
51$:
    ld      a, (soundV + 0x0004)
52$:
    ld      (soundVolume + 0x0004), a
    ld      e, a
    or      b
    ld      b, a
    ld      a, #0x0a
    call    WRTPSG
59$:

    ; �G���x���[�v�`��̐ݒ�
    ld      a, #0x10
    and     b
    jr      z, 60$
    ld      a, (soundS)
    ld      e, a
    ld      a, #0x0d
    call    WRTPSG
60$:
    
    ; �~�L�V���O�̐ݒ�
    ld      a, c
    ld      (soundMixing), a
    ld      e, a
    ld      a, #0x07
    call    WRTPSG
    
    ; �ݒ�̊���
    xor     a
    ld      0x00(iy), a
    ld      0x02(iy), a
    ld      0x04(iy), a
    ld      0x06(iy), a
    
    ; �X�V�̏I��
99$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; MML : ��Ή�����
;
SystemUpdateSoundMmlNull:
    
    scf
    ret

; 'S' : �G���x���[�v�g�`�iS0 �` S15�j
;
SystemUpdateSoundMmlS:

    ld      a, (hl)
    inc     hl
    sub     #'0
    ld      (soundS), a
    ld      a, (hl)
    cp      #'0
    jr      c, 09$
    cp      #('9 + 0x01)
    jr      nc, 09$
    sub     #'0
    add     a, #0x0a
    ld      (soundS), a
    inc     hl
09$:
    scf
    ret
    
; 'M' : �G���x���[�v�����iM0 �` M9�j
;
SystemUpdateSoundMmlM:

    ld      a, (hl)
    inc     hl
    sub     #'0
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      ix, #soundEnvelopeTable
    add     ix, de
    ld      a, 0x00(ix)
    ld      (soundM + 0), a
    ld      a, 0x01(ix)
    ld      (soundM + 1), a
    scf
    ret
    
; 'N' : �m�C�Y���g���iN0 �` N9�j
;
SystemUpdateSoundMmlN:

    ld      a, (hl)
    inc     hl
    sub     #'0
    ld      e, a
    ld      d, b
    ld      ix, #soundNoiseTable
    add     ix, de
    ld      a, 0x00(ix)
    ld      (soundN), a
    scf
    ret
    
; 'T' : �e���|�iT1 �` T8�j
;
SystemUpdateSoundMmlT:

    ld      a, (hl)
    inc     hl
    sub     #'1
    ld      ix, #soundT
    add     ix, bc
    ld      0x00(ix), a
    scf
    ret
    
; 'V' : ���ʁiV0 �` V16�j
;
SystemUpdateSoundMmlV:

    ld      a, (hl)
    inc     hl
    ld      ix, #soundV
    add     ix, bc
    sub     #'0
    ld      0x00(ix), a
    ld      a, (hl)
    cp      #'0
    jp      c, 00$
    cp      #('9 + 0x01)
    jp      nc, 00$
    sub     #'0
    add     a, #0x0a
    ld      0x00(ix), a
    inc     hl
00$:
    ld      a, (hl)
    cp      #'-
    ld      a, b
    jr      nz, 01$
    inc     hl
    ld      a, (hl)
    sub     #'0
    inc     hl
01$:
    ld      ix, #soundVminus
    add     ix, bc
    ld      0x00(ix), a
    ld      0x01(ix), a
    scf
    ret
    
; 'O' : �I�N�^�[�u�iO1 �` O8�j
;
SystemUpdateSoundMmlO:

    ld      a, (hl)
    inc     hl
    sub     #'1
    ld      ix, #soundO
    add     ix, bc
    ld      0x00(ix), a
    scf
    ret
    
; 'L' : ���̒����iL0 �` L9�j
;
SystemUpdateSoundMmlL:

    ld      a, (hl)
    inc     hl
    sub     #'0
    ld      ix, #soundL
    add     ix, bc
    ld      0x00(ix), a
    scf
    ret
    
; 'R' : �x��
;
SystemUpdateSoundMmlR:

    ld      ix, #soundTone
    add     ix, bc
    ld      0x00(ix), b
    ld      0x01(ix), b
    ld      ix, #soundNoise
    add     ix, bc
    ld      0x00(ix), b
    or      a
    ret
    
; 'X' : �m�C�Y
;
SystemUpdateSoundMmlX:

    ld      ix, #soundTone
    add     ix, bc
    ld      0x00(ix), b
    ld      0x01(ix), b
    ld      ix, #soundNoise
    add     ix, bc
    ld      0x00(ix), #0x01
    or      a
    ret
    
; 'A' : ����
;
SystemUpdateSoundMmlA::

    sub     #(('C - 'A) * 2)
    jr      nc, 00$
    add     a, #(0x07 * 2)
00$:
;   add     a, a
    add     a, a
    ld      e, a
    ld      d, b
    ld      ix, #(soundToneFrequencyTable + 0x04)
    add     ix, de
    ld      iy, #soundO
    add     iy, bc
    ld      a, 0x00(iy)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    add     ix, de
    ld      a, (hl)
    cp      #'+
    jr      nz, 01$
    inc     ix
    inc     ix
    inc     hl
    jr      02$
01$:
    cp      #'-
    jr      nz, 02$
    dec     ix
    dec     ix
    inc     hl
02$:
    ld      iy, #soundTone
    add     iy, bc
    ld      a, 0x00(ix)
    ld      0x00(iy), a
    ld      a, 0x01(ix)
    ld      0x01(iy), a
    ld      ix, #soundNoise
    add     ix, bc
    ld      0x00(ix), b
    or      a
    ret

; �T�E���h���ꎞ��~����
;
_SystemSuspendSound::
    
    ; ���W�X�^�̕ۑ�
    
    ; �X���[�v�̐ݒ�
    ld      hl, #_flag
    set     #FLAG_SOUND_SLEEP, (hl)
    
    ; �T�E���h�̒�~
    ld      e, #0b10111111
    ld      a, #0x07
    call    WRTPSG
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �T�E���h���ĊJ����
;
_SystemResumeSound::
    
    ; ���W�X�^�̕ۑ�
    
    ; �X���[�v�̉���
    ld      hl, #_flag
    res     #FLAG_SOUND_SLEEP, (hl)
    
    ; �T�E���h�̍X�V
    ld      hl, #soundUpdate
    ld      bc, #0x0401
10$:
    ld      (hl), c
    inc     hl
    inc     hl
    djnz    10$
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �T�E���h�̃`�����l�����N���A����
;
SystemClearSoundChannel:
    
    ; ���W�X�^�̕ۑ�
    push    af
    push    bc
    push    hl
    
    ; �`�����l���̃N���A
    add     a, a
    ld      c, a
    ld      b, #0x00
    xor     a
    ld      hl, #soundT
    add     hl, bc
    ld      (hl), a
    ld      hl, #soundV
    add     hl, bc
    ld      (hl), #0x0f
    ld      hl, #soundVolume
    add     hl, bc
    ld      (hl), #0x0f
    ld      hl, #soundVminus
    add     hl, bc
    ld      (hl), a
    inc     hl
    ld      (hl), a
    ld      hl, #soundO
    add     hl, bc
    ld      (hl), #0x03
    ld      hl, #soundL
    add     hl, bc
    ld      (hl), #0x05
    ld      hl, #soundTone
    add     hl, bc
    ld      (hl), a
    inc     hl
    ld      (hl), a
    ld      hl, #soundNoise
    add     hl, bc
    ld      (hl), a
    ld      hl, #soundRest
    add     hl, bc
    ld      (hl), #0x01
    ld      hl, #soundUpdate
    add     hl, bc
    ld      (hl), a
    
    ; ���W�X�^�̕��A
    pop     hl
    pop     bc
    pop     af
    
    ; �I��
    ret

; �������擾����
;
_SystemGetRandom::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    
    ; �����̐���
    ld      hl, #random
    ld      a, #0xaa
    xor     (hl)
    add     a, #73
    ld      (hl), a
    
    ; ���W�X�^�̕��A
    pop     hl
    
    ; �I��
    ret

; �萔�̒�`
;

; �L�[����
;
inputStickTable:
    
    .db     0x00
    .db     (1 << INPUT_KEY_UP)
    .db     (1 << INPUT_KEY_UP)    | (1 << INPUT_KEY_RIGHT)
    .db     (1 << INPUT_KEY_RIGHT)
    .db     (1 << INPUT_KEY_DOWN)  | (1 << INPUT_KEY_RIGHT)
    .db     (1 << INPUT_KEY_DOWN)
    .db     (1 << INPUT_KEY_DOWN)  | (1 << INPUT_KEY_LEFT)
    .db     (1 << INPUT_KEY_LEFT)
    .db     (1 << INPUT_KEY_UP)    | (1 << INPUT_KEY_LEFT)

; �T�E���h
;
soundToneFrequencyTable:
    .dw     0x0000, 0x0000, 0x0d5d, 0x0c9c, 0x0be7, 0x0b3c, 0x0a9b, 0x0a02, 0x0a02, 0x0973, 0x08eb, 0x086b, 0x07f2, 0x0780, 0x0714, 0x06af  ; O1
    .dw     0x0000, 0x0714, 0x06af, 0x064e, 0x05f4, 0x059e, 0x054e, 0x0501, 0x0501, 0x04ba, 0x0476, 0x0436, 0x03f9, 0x03c0, 0x038a, 0x0357  ; O2
    .dw     0x0000, 0x038a, 0x0357, 0x0327, 0x02fa, 0x02cf, 0x02a7, 0x0281, 0x0281, 0x025d, 0x023b, 0x021b, 0x01fd, 0x01e0, 0x01c5, 0x01ac  ; O3
    .dw     0x0000, 0x01c5, 0x01ac, 0x0194, 0x017d, 0x0168, 0x0153, 0x0140, 0x0140, 0x012e, 0x011d, 0x010d, 0x00fe, 0x00f0, 0x00e3, 0x00d6  ; O4
    .dw     0x0000, 0x00e3, 0x00d6, 0x00ca, 0x00be, 0x00b4, 0x00aa, 0x00a0, 0x00a0, 0x0097, 0x008f, 0x0087, 0x007f, 0x0078, 0x0071, 0x006b  ; O5
    .dw     0x0000, 0x0071, 0x006b, 0x0065, 0x005f, 0x005a, 0x0055, 0x0050, 0x0050, 0x004c, 0x0047, 0x0043, 0x0040, 0x003c, 0x0039, 0x0035  ; O6
    .dw     0x0000, 0x0039, 0x0035, 0x0032, 0x0030, 0x002d, 0x002a, 0x0028, 0x0028, 0x0026, 0x0024, 0x0022, 0x0020, 0x001e, 0x001c, 0x001b  ; O7
    .dw     0x0000, 0x001c, 0x001b, 0x0019, 0x0018, 0x0016, 0x0015, 0x0014, 0x0014, 0x0013, 0x0012, 0x0011, 0x0010, 0x000d, 0x000e, 0x000d  ; O8

soundLengthTable:
    
    .db     1       ; T1 L0 32
    .db     2       ; T1 L1 16
    .db     3       ; T1 L2 16.
    .db     4       ; T1 L3  8
    .db     6       ; T1 L4  8.
    .db     8       ; T1 L5  4
    .db     12      ; T1 L6  4.
    .db     16      ; T1 L7  2
    .db     24      ; T1 L8  2.
    .db     32      ; T1 L9  1
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     2       ; T2 L0 32
    .db     4       ; T2 L1 16
    .db     6       ; T2 L2 16.
    .db     8       ; T2 L3  8
    .db     12      ; T2 L4  8.
    .db     16      ; T2 L5  4
    .db     24      ; T2 L6  4.
    .db     32      ; T2 L7  2
    .db     48      ; T2 L8  2.
    .db     64      ; T2 L9  1
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     3       ; T3 L0 32
    .db     6       ; T3 L1 16
    .db     9       ; T3 L2 16.
    .db     12      ; T3 L3  8
    .db     18      ; T3 L4  8.
    .db     24      ; T3 L5  4
    .db     36      ; T3 L6  4.
    .db     48      ; T3 L7  2
    .db     72      ; T3 L8  2.
    .db     96      ; T3 L9  1
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     4       ; T4 L0 32
    .db     8       ; T4 L1 16
    .db     12      ; T4 L2 16.
    .db     16      ; T4 L3  8
    .db     24      ; T4 L4  8.
    .db     32      ; T4 L5  4
    .db     48      ; T4 L6  4.
    .db     64      ; T4 L7  2
    .db     96      ; T4 L8  2.
    .db     128     ; T4 L9  1
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     5       ; T5 L0 32
    .db     10      ; T5 L1 16
    .db     15      ; T5 L2 16.
    .db     20      ; T5 L3  8
    .db     30      ; T5 L4  8.
    .db     40      ; T5 L5  4
    .db     60      ; T5 L6  4.
    .db     80      ; T5 L7  2
    .db     120     ; T5 L8  2.
    .db     160     ; T5 L9  1
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     6       ; T6 L0 32
    .db     12      ; T6 L1 16
    .db     18      ; T6 L2 16.
    .db     24      ; T6 L3  8
    .db     32      ; T6 L4  8.
    .db     48      ; T6 L5  4
    .db     72      ; T6 L6  4.
    .db     96      ; T6 L7  2
    .db     144     ; T6 L8  2.
    .db     192     ; T6 L9  1
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     7       ; T7 L0 32
    .db     14      ; T7 L1 16
    .db     21      ; T7 L2 16.
    .db     28      ; T7 L3  8
    .db     42      ; T7 L4  8.
    .db     56      ; T7 L5  4
    .db     84      ; T7 L6  4.
    .db     112     ; T7 L7  2
    .db     168     ; T7 L8  2.
    .db     224     ; T7 L9  1
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     8       ; T8 L0 32
    .db     16      ; T8 L1 16
    .db     24      ; T8 L2 16.
    .db     32      ; T8 L3  8
    .db     48      ; T8 L4  8.
    .db     64      ; T8 L5  4
    .db     96      ; T8 L6  4.
    .db     128     ; T8 L7  2
    .db     192     ; T8 L8  2.
    .db     0       ; T8 L9  1
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;
    .db     1       ;

soundEnvelopeTable:
    
    .dw        0,    128,   256,   512,  1024,  2048,  4096,  8192, 16384, 32768

soundNoiseTable:
    
    .db      0,  1,  2,  4,  8, 12, 16, 20, 24, 31

soundMmlProc:

    .dw     SystemUpdateSoundMmlA
    .dw     SystemUpdateSoundMmlA
    .dw     SystemUpdateSoundMmlA
    .dw     SystemUpdateSoundMmlA
    .dw     SystemUpdateSoundMmlA
    .dw     SystemUpdateSoundMmlA
    .dw     SystemUpdateSoundMmlA
    .dw     SystemUpdateSoundMmlNull
    .dw     SystemUpdateSoundMmlNull
    .dw     SystemUpdateSoundMmlNull
    .dw     SystemUpdateSoundMmlNull
    .dw     SystemUpdateSoundMmlL
    .dw     SystemUpdateSoundMmlM
    .dw     SystemUpdateSoundMmlN
    .dw     SystemUpdateSoundMmlO
    .dw     SystemUpdateSoundMmlNull
    .dw     SystemUpdateSoundMmlNull
    .dw     SystemUpdateSoundMmlR
    .dw     SystemUpdateSoundMmlS
    .dw     SystemUpdateSoundMmlT
    .dw     SystemUpdateSoundMmlNull
    .dw     SystemUpdateSoundMmlV
    .dw     SystemUpdateSoundMmlNull
    .dw     SystemUpdateSoundMmlX
    .dw     SystemUpdateSoundMmlNull
    .dw     SystemUpdateSoundMmlNull


; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

; �t���O
;
_flag::
    
    .ds     0x01

; ���N�G�X�g
;
_request::
    
    .ds     0x01

; �L�[����
;
_input::
    
    .ds     INPUT_SIZE

; �r�f�I
;
_videoPort::
    
    .ds     0x02

_videoRegister::
    
    .ds     0x08

_videoTransfer::
    
    .ds     VIDEO_TRANSFER_VRAM_SIZE * VIDEO_TRANSFER_SIZE

; �X�v���C�g
;
_sprite:
    
    .ds     0x80

; �T�E���h
;
_soundRequest::
    
    .ds     0x08

_soundHead::
    
    .ds     0x08

_soundPlay::
    
    .ds     0x08

soundS:
    
    .ds     0x01

soundM:
    
    .ds     0x02

soundN:
    
    .ds     0x01

soundMixing:

    .ds     0x01

soundT:
    
    .ds     0x08

soundV:
    
    .ds     0x08

soundVolume:
    
    .ds     0x08

soundVminus:
    
    .ds     0x08

soundO:
    
    .ds     0x08

soundL:
    
    .ds     0x08

soundTone:
    
    .ds     0x08

soundNoise:
    
    .ds     0x08

soundRest:
    
    .ds     0x08

soundUpdate:
    
    .ds     0x08

; ����
;
random:
    
    .ds     0x01
