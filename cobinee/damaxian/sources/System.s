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
    
    ; �t���O�̏�����
    xor     a
    ld      (_flag), a
    
    ; �L�[���͂̏�����
    call    _SystemInitializeInput
    
    ; �r�f�I�̏�����
    call    _SystemInitializeVideo
    
    ; �T�E���h�̏�����
    call    _SystemInitializeSound
    
    ; �I��
    ret


; �L�[���͂�����������  
;
_SystemInitializeInput::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    
    ; �L�[���͂̏�����
    ld      hl, #_input
    xor     a
    ld      b, #INPUT_SIZE
0$:
    ld      (hl), a
    inc     hl
    djnz    0$
    
    ; ���W�X�^�̕��A
    pop     bc
    pop     hl
    
    ; �I��
    ret


; �L�[�̓��͂��X�V����
;
_SystemUpdateInput::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; �L�[�̎擾
    ld      a, #0x00
    call    GTSTCK
    ld      c, a
    ld      b, #0x00
    ld      hl, #inputStickTable
    add     hl, bc
    ld      a, (hl)
    ld      (inputBuffer + 0), a
    ld      a, #0x01
    call    GTSTCK
    ld      c, a
    ld      b, #0x00
    ld      hl, #inputStickTable
    add     hl, bc
    ld      a, (inputBuffer + 0)
    or      (hl)
    ld      b, a
    ld      hl, #(_input + INPUT_KEY_UP)
    ld      a, (hl)
    inc     a
    jr      nz, 00$
    ld      a, #0xff
00$:
    bit     #INPUT_KEY_UP, b
    jr      nz, 01$
    xor     a
01$:
    ld      (hl), a
    ld      hl, #(_input + INPUT_KEY_DOWN)
    ld      a, (hl)
    inc     a
    jr      nz, 02$
    ld      a, #0xff
02$:
    bit     #INPUT_KEY_DOWN, b
    jr      nz, 03$
    xor     a
03$:
    ld      (hl), a
    ld      hl, #(_input + INPUT_KEY_LEFT)
    ld      a, (hl)
    inc     a
    jr      nz, 04$
    ld      a, #0xff
04$:
    bit     #INPUT_KEY_LEFT, b
    jr      nz, 05$
    xor     a
05$:
    ld      (hl), a
    ld      hl, #(_input + INPUT_KEY_RIGHT)
    ld      a, (hl)
    inc     a
    jr      nz, 06$
    ld      a, #0xff
06$:
    bit     #INPUT_KEY_RIGHT, b
    jr      nz, 07$
    xor     a
07$:
    ld      (hl), a
    
    ; �{�^���̎擾
    ld      a, #0x00
    call    GTTRIG
    ld      (inputBuffer + 0), a
    ld      a, #0x01
    call    GTTRIG
    ld      hl, #(inputBuffer + 0)
    or      (hl)
    ld      hl, #(_input + INPUT_BUTTON_SPACE)
    jr      z, 10$
    ld      a, (hl)
    inc     a
    jr      nz, 10$
    ld      a, #0xff
10$:
    ld      (hl), a
    ld      a, #0x07
    call    SNSMAT
    ld      b, a
    ld      hl, #(_input + INPUT_BUTTON_RETURN)
    ld      a, (hl)
    inc     a
    jr      nz, 11$
    ld      a, #0xff
11$:
    bit     #0x07, b
    jr      z, 12$
    xor     a
12$:
    ld      (hl), a
    ld      hl, #(_input + INPUT_BUTTON_ESC)
    ld      a, (hl)
    inc     a
    jr      nz, 13$
    ld      a, #0xff
13$:
    bit     #0x02, b
    jr      z, 14$
    xor     a
14$:
    ld      (hl), a
    ld      hl, #(_input + INPUT_BUTTON_STOP)
    ld      a, (hl)
    inc     a
    jr      nz, 15$
    ld      a, #0xff
15$:
    bit     #0x04, b
    jr      z, 16$
    xor     a
16$:
    ld      (hl), a
    
    ; ���W�X�^�̕��A
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; �I��
    ret


; �r�f�I������������
;
_SystemInitializeVideo::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    push    de
    
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
0$:
    ld      (hl), a
    inc     hl
    djnz    0$
    
    ; ���W�X�^�̕��A
    pop     de
    pop     bc
    pop     hl
    
    ; �I��
    ret


; �X�N���[�����[�h��ݒ肷��
;
_SystemSetScreenMode::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    push    de
    
    ; ���W�X�^�̐ݒ�
    sla     a
    sla     a
    sla     a
    ld      c, a
    ld      b, #0x00
    ld      hl, #videoScreenMode
    add     hl, bc
    ld      de, #_videoRegister
    ld      bc, #0x08
    ldir
    
    ; ���W�X�^�̓]��
    call    _SystemTransferVideoRegister
    
    ; ���W�X�^�̕��A
    pop     de
    pop     bc
    pop     hl
    
    ; �I��
    ret


; ���W�X�^��]������
;
_SystemTransferVideoRegister::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    
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
    ld      a, #0x81
    out     (c), a
    outi
    ld      a, #0x82
    out     (c), a
    outi
    ld      a, #0x83
    out     (c), a
    outi
    ld      a, #0x84
    out     (c), a
    outi
    ld      a, #0x85
    out     (c), a
    outi
    ld      a, #0x86
    out     (c), a
    outi
    ld      a, #0x87
    out     (c), a
    
    ; ���荞�݋֎~�̉���
    ei
    
    ; ���W�X�^�̕��A
    pop     bc
    pop     hl
    
    ; �I��
    ret


; VRAM �Ƀf�[�^��]������
;
_SystemTransferVram::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    push    de
    
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
    jr      z, 01$
    ld      c, e
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST + 0)
    out     (c), a
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST + 1)
    or      #0b01000000
    out     (c), a
    ld      c, d
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES)
    ld      b, a
    otir
    
    ; VRAM 1 �̓]��
01$:
    ld      hl, (_videoTransfer + VIDEO_TRANSFER_VRAM_1_SRC)
    ld      a, l
    or      h
    jr      z, 02$
    ld      c, e
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_1_DST + 0)
    out     (c), a
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_1_DST + 1)
    or      #0b01000000
    out     (c), a
    ld      c, d
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_1_BYTES)
    ld      b, a
    otir
    
    ; VRAM 2 �̓]��
02$:
    ld      hl, (_videoTransfer + VIDEO_TRANSFER_VRAM_2_SRC)
    ld      a, l
    or      h
    jr      z, 03$
    ld      c, e
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_2_DST + 0)
    out     (c), a
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_2_DST + 1)
    or      #0b01000000
    out     (c), a
    ld      c, d
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_2_BYTES)
    ld      b, a
    otir
    
    ; VRAM 3 �̓]��
03$:
    ld      hl, (_videoTransfer + VIDEO_TRANSFER_VRAM_3_SRC)
    ld      a, l
    or      h
    jr      z, 90$
    ld      c, e
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_3_DST + 0)
    out     (c), a
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_3_DST + 1)
    or      #0b01000000
    out     (c), a
    ld      c, d
    ld      a, (_videoTransfer + VIDEO_TRANSFER_VRAM_3_BYTES)
    ld      b, a
    otir
    
    ; ���荞�݋֎~�̉���
    ei
    
    ; �]���̊���
90$:
    ld      hl, #_videoTransfer
    xor     a
    ld      b, #(VIDEO_TRANSFER_VRAM_SIZE * VIDEO_TRANSFER_SIZE)
91$:
    ld      (hl), a
    inc     hl
    djnz    91$
    
    ; ���W�X�^�̕��A
    pop     de
    pop     bc
    pop     hl
    
    ; �I��
    ret


; �X�v���C�g���N���A����
;
_SystemClearSprite::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    
    ; �X�v���C�g�̃N���A
    ld      hl, #_sprite
    ld      a, #0xc0
    ld      b, #0x80
0$:
    ld      (hl), a
    inc     hl
    djnz    0$
    
    ; ���W�X�^�̕��A
    pop     bc
    pop     hl
    
    ; �I��
    ret


; �X�v���C�g��]������
;
_SystemTransferSprite::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    
    ; �X�v���C�g�A�g���r���[�g�e�[�u���̎擾
    ld      a, (_videoRegister + VDP_R5)
    ld      l, a
    ld      h, #0x00
    sla     l
    rl      h
    sla     l
    rl      h
    sla     l
    rl      h
    sla     l
    rl      h
    sla     l
    rl      h
    sla     l
    rl      h
    sla     l
    rl      h
    
    ; ���荞�݂̋֎~
    di
    
    ; VRAM �A�h���X�̐ݒ�
    ld      a, (_videoPort + 1)
    inc     a
    ld      c, a
    ;ld      a, #<VIDEO_GRAPHIC1_SPRITE_ATTRIBUTE_TABLE
    ;out     (c), a
    ;ld      a, #(>VIDEO_GRAPHIC1_SPRITE_ATTRIBUTE_TABLE | 0b01000000)
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
    pop     bc
    pop     hl
    
    ; �I��
    ret


; �X�v���C�g��ݒ肷��
;
_SystemSetSprite::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    push    de
    
    ; �X�v���C�g�̐ݒ�
    ld      a, (hl)
    add     a, c
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    add     a, b
    ld      b, #0x00
    cp      #0xf0
    jr      c, 0$
    add     a, #0x20
    ld      b, #0x80
0$:
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    or      b
    ld      (de), a
    
    ; ���W�X�^�̕��A
    pop     de
    pop     bc
    pop     hl
    
    ; �I��
    ret


; �T�E���h������������
;
_SystemInitializeSound::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; PSG �̏�����
    call    GICINI
    ld      e, #0b10111111
    ld      a, #0x07
    call    WRTPSG
    
    ; �T�E���h���W�X�^�̏�����
    ld      ix, #soundRegister
    ld      0x00(ix), #0b01010101
    ld      0x01(ix), #0b00000000
    ld      0x02(ix), #0b00000000
    ld      0x03(ix), #0b00000000
    ld      0x04(ix), #0b00000000
    ld      0x05(ix), #0b00000000
    ld      0x06(ix), #0b00000000
    ld      0x07(ix), #0b10111111
    ld      0x08(ix), #0b00000000
    ld      0x09(ix), #0b00000000
    ld      0x0a(ix), #0b00000000
    ld      0x0b(ix), #0b00001011
    ld      0x0c(ix), #0b00000000
    ld      0x0d(ix), #0b00000000
    ld      0x0e(ix), #0b00000000
    ld      0x0f(ix), #0b00000000
    
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
    xor     a
0$:
    call    SystemClearSoundChannel
    inc     a
    cp      #0x04
    jr      nz,  0$
    xor     a
    ld      (soundS), a
    ld      a, #0x09
    ld      (soundM), a
    
    ; ���W�X�^�̕��A
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; �I��
    ret


; �T�E���h���X�V����
;
_SystemUpdateSound::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; �X���[�v�̊m�F
    ld      hl, #_flag
    bit     #FLAG_SOUND_SLEEP, (hl)
    jr      z, 90$
    ld      e, #0b10111111
    ld      a, #0x07
    call    WRTPSG
    jp      SystemUpdateSoundEnd
90$:
    
    ; �`�����l���̑���
    ld      bc, #0x0000
    ld      de, #0x0000
    
    ; �P�`�����l���̏���
SystemUpdateSoundChannel:
    
    ; ���N�G�X�g
    ld      ix, #_soundRequest
    add     ix, de
    ld      a, 0(ix)
    or      1(ix)
    jr      z, 00$
    ld      l, 0(ix)
    ld      h, 1(ix)
    xor     a
    ld      0(ix), a
    ld      1(ix), a
    ld      ix, #_soundHead
    add     ix, de
    ld      0(ix), l
    ld      1(ix), h
    ld      ix, #_soundPlay
    add     ix, de
    ld      0(ix), l
    ld      1(ix), h
    ld      a, c
    call    SystemClearSoundChannel
00$:
    
    ; �T�E���h�f�[�^�̑���
    ld      ix, #_soundPlay
    add     ix, de
    ld      a, 0(ix)
    or      1(ix)
    jp      z, SystemUpdateSoundNext
    
    ; �ҋ@
    ld      hl, #soundRest
    add     hl, bc
    dec     (hl)
    jp      nz, SystemUpdateSoundNext
    
    ; �Đ��|�C���^�̎擾
    ld      ix, #_soundPlay
    add     ix, de
    ld      l, 0(ix)
    ld      h, 1(ix)
    
    ; MML �̉��
SystemUpdateSoundMml:
    ld      a, (hl)
    inc     hl
    
    ; 0x00 : �I�[�R�[�h
SystemUpdateSoundMml00:
    or      a
    jr      nz, SystemUpdateSoundMmlFf
    ld      ix, #_soundHead
    add     ix, de
    ld      0(ix), a
    ld      1(ix), a
    ld      ix, #_soundPlay
    add     ix, de
    ld      0(ix), a
    ld      1(ix), a
    ld      ix, #soundFrequency
    add     ix, de
    ld      0(ix), a
    ld      1(ix), a
    ld      ix, #soundUpdate
    add     ix, bc
    ld      0(ix), #0x01
    jp      SystemUpdateSoundNext
    
    ; $ff : �J��Ԃ�
SystemUpdateSoundMmlFf:
    cp      #0xff
    jr      nz, SystemUpdateSoundMmlT
    ld      ix, #_soundHead
    add     ix, de
    ld      iy, #_soundPlay
    add     iy, de
    ld      a, 0(ix)
    ld      0(iy), a
    ld      l, a
    ld      a, 1(ix)
    ld      1(iy), a
    ld      h, a
    jr      SystemUpdateSoundMml
    
    ; 'T' : �e���|�iT1 �` T8�j
SystemUpdateSoundMmlT:
    cp      #'T
    jr      nz, SystemUpdateSoundMmlS
    ld      a, (hl)
    inc     hl
    sub     #'1
    ld      ix, #soundT
    add     ix, bc
    ld      0(ix), a
    jr      SystemUpdateSoundMml
    
    ; 'S' : �G���x���[�v�g�`�iS0 �` S15�j
SystemUpdateSoundMmlS:
    cp      #'S
    jr      nz, SystemUpdateSoundMmlM
    ld      a, (hl)
    inc     hl
    sub     #'0
    ld      (soundS), a
    ld      a, (hl)
    cp      #'0
    jr      c, SystemUpdateSoundMml
    cp      #('9 + 0x01)
    jr      nc, SystemUpdateSoundMml
    sub     #'0
    add     a, #0x0a
    ld      (soundS), a
    inc     hl
    jp      SystemUpdateSoundMml
    
    ; 'M' : �G���x���[�v�����iM0 �` M15�j
SystemUpdateSoundMmlM:
    cp      #'M
    jr      nz, SystemUpdateSoundMmlV
    ld      a, (hl)
    inc     hl
    sub     #'0
    ld      (soundM), a
    ld      a, (hl)
    cp      #'0
    jp      c, SystemUpdateSoundMml
    cp      #('9 + 0x01)
    jp      nc, SystemUpdateSoundMml
    sub     #'0
    add     a, #0x0a
    ld      (soundM), a
    inc     hl
    jp      SystemUpdateSoundMml
    
    ; 'V' : ���ʁiV0 �` V16�j
SystemUpdateSoundMmlV:
    cp      #'V
    jr      nz, SystemUpdateSoundMmlO
    ld      a, (hl)
    inc     hl
    ld      ix, #soundV
    add     ix, bc
    sub     #'0
    ld      0(ix), a
    ld      a, (hl)
    cp      #'0
    jp      c, SystemUpdateSoundMml
    cp      #('9 + 0x01)
    jp      nc, SystemUpdateSoundMml
    sub     #'0
    add     #0x0a
    ld      0(ix), a
    inc     hl
    jp      SystemUpdateSoundMml
    
    ; 'O' : �I�N�^�[�u�iO1 �` O8�j
SystemUpdateSoundMmlO:
    cp      #'O
    jr      nz, SystemUpdateSoundMmlL
    ld      a, (hl)
    inc     hl
    sub     #'1
    ld      ix, #soundO
    add     ix, bc
    ld      0(ix), a
    jp      SystemUpdateSoundMml
    
    ; 'L' : ���̒����iL0 �` L9�j
SystemUpdateSoundMmlL:
    cp      #'L
    jr      nz, SystemUpdateSoundMmlR
    ld      a, (hl)
    inc     hl
    sub     #'0
    ld      ix, #soundL
    add     ix, bc
    ld      0(ix), a
    jp      SystemUpdateSoundMml
    
    ; 'R' : �x��
SystemUpdateSoundMmlR:
    cp      #'R
    jr      nz, SystemUpdateSoundMmlA
    ld      ix, #soundFrequency
    add     ix, de
    xor     a
    ld      0(ix), a
    ld      1(ix), a
    jr      SystemUpdateSoundRest
    
    ; 'A' : ����
SystemUpdateSoundMmlA:
    push    de
    sub     #'A
    sla     a
    sla     a
    ld      ix, #soundToneFrequencyTable
    ld      e, a
    ld      d, #0x00
    add     ix, de
    ld      iy, #soundO
    add     iy, bc
    ld      e, 0(iy)
    sla     e
    sla     e
    sla     e
    sla     e
    sla     e
    add     ix, de
    ld      a, (hl)
    cp      #'#
    jr      nz, 10$
    ld      de, #0x0002
    add     ix, de
    inc     hl
10$:
    pop     de
    ld      iy, #soundFrequency
    add     iy, de
    ld      a, 0(ix)
    ld      0(iy), a
    ld      a, 1(ix)
    ld      1(iy), a
    ; jr      SystemUpdateSoundRest
    
    ; ���̒����̐ݒ�
SystemUpdateSoundRest:
    ld      a, (hl)
    cp      #'0
    jr      c, 20$
    cp      #('9 + 0x01)
    jr      nc, 20$
    inc     hl
    sub     #'0
    jr      21$
20$:
    ld      ix, #soundL
    add     ix, bc
    ld      a, 0(ix)
21$:
    push    de
    ld      ix, #soundLengthTable
    ld      e, a
    ld      d, #0x00
    add     ix, de
    ld      iy, #soundT
    add     iy, bc
    ld      e, 0(iy)
    sla     e
    sla     e
    sla     e
    sla     e
    add     ix, de
    pop     de
    ld      iy, #soundRest
    add     iy, bc
    ld      a, 0(ix)
    ld      0(iy), a
    ld      ix, #soundUpdate
    add     ix, bc
    ld      0(ix), #0x01
    
    ; �Đ��|�C���^�̕ۑ�
    ld      ix, #_soundPlay
    add     ix, de
    ld      0(ix), l
    ld      1(ix), h
    ; jr      SystemUpdateSoundNext
    
    ; �`�����l���̑����̊���
SystemUpdateSoundNext:
    
    ; ���̃`�����l����
    inc     bc
    inc     de
    inc     de
    ld      a, c
    cp      #0x04
    jp      nz, SystemUpdateSoundChannel
    
    ; �`�����l���`�̐ݒ�
SystemUpdateSoundChannelA:
    ld      a, (soundUpdate + 0)
    or      a
    jr      z, SystemUpdateSoundChannelB
    ld      hl, #(soundRegister + 0x07)
    ld      ix, #soundFrequency
    ld      a, 0(ix)
    or      1(ix)
    jr      z, 30$
    res     #0x00, (hl)
    jr      31$
30$:
    set     #0x00, (hl)
31$:
    ld      a, (soundV + 0)
    ld      e, a
    ld      a, #0x08
    call    WRTPSG
    ld      e, 0(ix)
    ld      a, #0x00
    call    WRTPSG
    ld      e, 1(ix)
    ld      a, #0x01
    call    WRTPSG
    
    ; �`�����l���a�̐ݒ�
SystemUpdateSoundChannelB:
    ld      a, (soundUpdate + 1)
    or      a
    jr      z, SystemUpdateSoundChannelD
    ld      hl, #(soundRegister + 0x07)
    ld      ix, #soundFrequency
    ld      a, 2(ix)
    or      3(ix)
    jr      z, 40$
    res     #0x01, (hl)
    jr      41$
40$:
    set     #0x01, (hl)
41$:
    ld      a, (soundV + 1)
    ld      e, a
    ld      a, #0x09
    call    WRTPSG
    ld      e, 2(ix)
    ld      a, #0x02
    call    WRTPSG
    ld      e, 3(ix)
    ld      a, #0x03
    call    WRTPSG
    
    ; �`�����l���c�̐ݒ�
SystemUpdateSoundChannelD:
    ld      a, (soundUpdate + 3)
    or      a
    jr      z, SystemUpdateSoundChannelC
    ld      hl, #(soundRegister + 0x07)
    ld      ix, #soundFrequency
    ld      a, 6(ix)
    or      7(ix)
    jr      z, 50$
    res     #0x02, (hl)
    jr      51$
50$:
    set     #0x02, (hl)
51$:
    ld      a, (soundV + 3)
    ld      e, a
    ld      a, #0x0a
    call    WRTPSG
    ld      e, 6(ix)
    ld      a, #0x04
    call    WRTPSG
    ld      e, 7(ix)
    ld      a, #0x05
    call    WRTPSG
    jr      SystemUpdateSoundChannelCommon
    
    ; �`�����l���b�̐ݒ�
SystemUpdateSoundChannelC:
    ld      a, (soundUpdate + 2)
    or      a
    jr      z, SystemUpdateSoundChannelCommon
    ld      ix, #_soundPlay
    ld      a, 6(ix)
    or      7(ix)
    jr      nz, SystemUpdateSoundChannelCommon
    ld      hl, #(soundRegister + 0x07)
    ld      ix, #soundFrequency
    ld      a, 4(ix)
    or      5(ix)
    jr      z, 60$
    res     #0x02, (hl)
    jr      61$
60$:
    set     #0x02, (hl)
61$:
    ld      a, (soundV + 2)
    ld      e, a
    ld      a, #0x0a
    call    WRTPSG
    ld      e, 4(ix)
    ld      a, #0x04
    call    WRTPSG
    ld      e, 5(ix)
    ld      a, #0x05
    call    WRTPSG
    
    ; �`�����l�����ʂ̍X�V
SystemUpdateSoundChannelCommon:
    ld      ix, #soundUpdate
    ld      a, 0(ix)
    or      1(ix)
    or      2(ix)
    or      3(ix)
    jr      z, SystemUpdateSoundEnd
    xor     a
    ld      0(ix), a
    ld      1(ix), a
    ld      2(ix), a
    ld      3(ix), a
    ld      a, (soundS)
    ld      e, a
    ld      a, #0x0d
    call    WRTPSG
    ld      a, (soundM)
    sla     a
    ld      c, a
    ld      b, #0x00
    ld      ix, #soundEnvelopeTable
    add     ix, bc
    push    ix
    ld      e, 0(ix)
    ld      a, #0x0b
    call    WRTPSG
    pop     ix
    ld      e, 1(ix)
    ld      a, #0x0c
    call    WRTPSG
    ld      a, (soundRegister + 0x07)
    ld      e, a
    ld      a, #0x07
    call    WRTPSG
    
    ; �X�V�̏I��
SystemUpdateSoundEnd:
    
    ; ���W�X�^�̕��A
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; �I��
    ret


; �T�E���h���ꎞ��~����
;
_SystemSuspendSound::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    
    ; �X���[�v�̐ݒ�
    ld      hl, #_flag
    set     #FLAG_SOUND_SLEEP, (hl)
    
    ; �T�E���h�̒�~
    ld      e, #0b10111111
    ld      a, #0x07
    call    WRTPSG
    
    ; ���W�X�^�̕��A
    pop     hl
    
    ; �I��
    ret


; �T�E���h���ĊJ����
;
_SystemResumeSound::
    
    ; ���W�X�^�̕ۑ�
    push        hl
    
    ; �X���[�v�̉���
    ld      hl, #_flag
    res     #FLAG_SOUND_SLEEP, (hl)
    
    ; �T�E���h�̍X�V
    ld      a, #0x01
    ld      (soundUpdate + 0), a
    ld      (soundUpdate + 1), a
    ld      (soundUpdate + 2), a
    ld      (soundUpdate + 3), a
    
    ; ���W�X�^�̕��A
    pop     hl
    
    ; �I��
    ret


; �T�E���h�̃`�����l�����N���A����
;
SystemClearSoundChannel:
    
    ; ���W�X�^�̕ۑ�
    push    af
    push    hl
    push    bc
    
    ; �`�����l���̃N���A
    ld      c, a
    ld      b, #0x00
    ld      hl, #soundT
    add     hl, bc
    ld      (hl), #0x00
    ld      hl, #soundV
    add     hl, bc
    ld      (hl), #0x0f
    ld      hl, #soundO
    add     hl, bc
    ld      (hl), #0x03
    ld      hl, #soundL
    add     hl, bc
    ld      (hl), #0x05
    ld      hl, #soundFrequency
    add     hl, bc
    add     hl, bc
    ld      (hl), #0x00
    inc     hl
    ld      (hl), #0x00
    ld      hl, #soundRest
    add     hl, bc
    ld      (hl), #0x01
    ld      hl, #soundUpdate
    add     hl, bc
    ld      (hl), #0x00
    
    ; ���W�X�^�̕��A
    pop     bc
    pop     hl
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


; sin �̒l���擾����
;
_SystemGetSin::
    
    ; ���W�X�^�̕ۑ�
    push    bc
    push    ix
    
    ; �l�̎擾
    ld      c, a
    ld      b, #0x00
    ld      ix, #trigonometricDecimalTable
    add     ix, bc
    ld      l, 0(ix)
    ld      ix, #trigonometricIntegerTable
    add     ix, bc
    ld      h, 0(ix)
    
    ; ���W�X�^�̕��A
    pop     ix
    pop     bc
    
    ; �I��
    ret


; cos �̒l���擾����
;
_SystemGetCos::
    
    ; ���W�X�^�̕ۑ�
    push    bc
    push    ix
    
    ; �l�̎擾
    add     a, #0x40
    ld      c, a
    ld      b, #0x00
    ld      ix, #trigonometricDecimalTable
    add     ix, bc
    ld      l, 0(ix)
    ld      ix, #trigonometricIntegerTable
    add     ix, bc
    ld      h, 0(ix)
    
    ; ���W�X�^�̕��A
    pop     ix
    pop     bc
    
    ; �I��
    ret


; atan2 �̒l���擾����
;
_SystemGetAtan2::
    
    ; ���W�X�^�̕ۑ�
    push    hl
    push    bc
    push    de
    
    ; �l�̎擾
    ld      c, #0x00
    ld      a, l
    sla     l
    rl      c
    bit     #0x00, c
    jr      z, 0$
    neg
    jp      po, 0$
    ld      a, #0x7f
0$:
    ld      l, a
    ld      a, h
    sla     h
    rl      c
    bit     #0x00, c
    jr      z, 1$
    neg
    jp      po, 1$
    ld      a, #0x7f
1$:
    ld      h, a
    cp      l
    jr      nc, 2$
    ld      a, l
2$:
    cp      #0x08
    jr      c, 3$
    sra     a
    sra     h
    sra     l
    jr      2$
3$:
    ld      a, l
    sla     a
    sla     a
    sla     a
    add     a, h
    ld      e, a
    ld      d, #0x00
    ld      hl, #trigonometricAtanAngleTable
    add     hl, de
    ld      a, (hl)
    ld      b, c
    inc     b
    bit     #0x01, b
    jr      z, 4$
    neg
4$:
    ld      b, #0x00
    ld      hl, #trigonometricAtanOffsetTable
    add     hl, bc
    add     a, (hl)
    
    ; ���W�X�^�̕��A
    pop     de
    pop     bc
    pop     hl
    
    ; �I��
    ret


; A ���W�X�^�̓��e���o�͂���
;
_SystemPutRegisterA::
    
    ; ���W�X�^�̕ۑ�
    push    af
    push    hl
    push    bc
    
    ; ��ʂS�r�b�g�̏o��
    push    af
    srl     a
    srl     a
    srl     a
    srl     a
    ld      c, a
    ld      b, #0x00
    ld      hl, #hexString
    add     hl, bc
    ld      a, (hl)
    call    CHPUT
    pop     af
    
    ; ���ʂS�r�b�g�̏o��
    and     #0b00001111
    ld      c, a
    ld      b, #0x00
    ld      hl, #hexString
    add     hl, bc
    ld      a, (hl)
    call    CHPUT
    
    ; ���W�X�^�̕��A
    pop     bc
    pop     hl
    pop     af
    
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

; �r�f�I
;
videoScreenMode:
    
    .db     0b00000000          ; text 1
    .db     0b10110000
    .db     (0x0000 >> 10)
    .db     (0x0000 >> 6)
    .db     (0x0800 >> 11)
    .db     (0x1b00 >> 7)
    .db     (0x3800 >> 11)
    .db     0b11110100
    .db     0b00000000          ; graphic 1
    .db     0b10100000
    .db     (0x1800 >> 10)
    .db     (0x2000 >> 6)
    .db     (0x0000 >> 11)
    .db     (0x1b00 >> 7)
    .db     (0x3800 >> 11)
    .db     0b00000111
    .db     0b00000010          ; graphic 2
    .db     0b10100000
    .db     (0x1800 >> 10)
    .db     (0x2000 >> 6)
    .db     (0x0000 >> 11)
    .db     (0x1b00 >> 7)
    .db     (0x3800 >> 11)
    .db     0b00000111
    .db     0b00000000          ; multi color
    .db     0b10101000
    .db     (0x0800 >> 10)
    .db     (0x2000 >> 6)
    .db     (0x0000 >> 11)
    .db     (0x1b00 >> 7)
    .db     (0x3800 >> 11)
    .db     0b00000111

; �T�E���h
;
soundToneFrequencyTable:
    
    .dw     0x07f2, 0x0780, 0x0714, 0x06af, 0x0d5d, 0x0c9c, 0x0be7, 0x0b3c, 0x0a9b, 0x0a02, 0x0a02, 0x0973, 0x08eb, 0x086b, 0x0000, 0x0000  ; O1
    .dw     0x03f9, 0x03c0, 0x038a, 0x0357, 0x06af, 0x064e, 0x05f4, 0x059e, 0x054e, 0x0501, 0x0501, 0x04ba, 0x0476, 0x0436, 0x0000, 0x0000  ; O2
    .dw     0x01fd, 0x01e0, 0x01c5, 0x01ac, 0x0357, 0x0327, 0x02fa, 0x02cf, 0x02a7, 0x0281, 0x0281, 0x025d, 0x023b, 0x021b, 0x0000, 0x0000  ; O3
    .dw     0x00fe, 0x00f0, 0x00e3, 0x00d6, 0x01ac, 0x0194, 0x017d, 0x0168, 0x0153, 0x0140, 0x0140, 0x012e, 0x011d, 0x010d, 0x0000, 0x0000  ; O4
    .dw     0x007f, 0x0078, 0x0071, 0x006b, 0x00d6, 0x00ca, 0x00be, 0x00b4, 0x00aa, 0x00a0, 0x00a0, 0x0097, 0x008f, 0x0087, 0x0000, 0x0000  ; O5
    .dw     0x0040, 0x003c, 0x0039, 0x0035, 0x006b, 0x0065, 0x005f, 0x005a, 0x0055, 0x0050, 0x0050, 0x004c, 0x0047, 0x0043, 0x0000, 0x0000  ; O6
    .dw     0x0020, 0x001e, 0x001c, 0x001b, 0x0035, 0x0032, 0x0030, 0x002d, 0x002a, 0x0028, 0x0028, 0x0026, 0x0024, 0x0022, 0x0000, 0x0000  ; O7
    .dw     0x0010, 0x000d, 0x000e, 0x000d, 0x001b, 0x0019, 0x0018, 0x0016, 0x0015, 0x0014, 0x0014, 0x0013, 0x0012, 0x0011, 0x0000, 0x0000  ; O8

soundLengthTable:
    
    .db     1       ; T1 L0 32
    .db     2       ; T1 L1 16
    .db     3       ; T1 L2 16.
    .db     4       ; T1 L3  8
    .db     6       ; T1 L4  8.
    .db     8       ; T1 L5  4
    .db     12      ; T1 L6  4.
    .db     16      ; T1 L7  2
    .db     20      ; T1 L8  2.
    .db     24      ; T1 L9  1
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
    
    .dw         0,  1000,  2000,  3000,  4000,  5000,  6000,  7000,  8000,  9000, 10000, 11000, 12000, 13000, 14000, 15000

;  �O�p�֐�
;
trigonometricDecimalTable:
    
    .db     0x00, 0x06, 0x0c, 0x12, 0x19, 0x1f, 0x25, 0x2b, 0x31, 0x38, 0x3e, 0x44, 0x4a, 0x50, 0x56, 0x5c
    .db     0x61, 0x67, 0x6d, 0x73, 0x78, 0x7e, 0x83, 0x88, 0x8e, 0x93, 0x98, 0x9d, 0xa2, 0xa7, 0xab, 0xb0
    .db     0xb5, 0xb9, 0xbd, 0xc1, 0xc5, 0xc9, 0xcd, 0xd1, 0xd4, 0xd8, 0xdb, 0xde, 0xe1, 0xe4, 0xe7, 0xea
    .db     0xec, 0xee, 0xf1, 0xf3, 0xf4, 0xf6, 0xf8, 0xf9, 0xfb, 0xfc, 0xfd, 0xfe, 0xfe, 0xff, 0xff, 0xff
    .db     0x00, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfd, 0xfc, 0xfb, 0xf9, 0xf8, 0xf6, 0xf4, 0xf3, 0xf1, 0xee
    .db     0xec, 0xea, 0xe7, 0xe4, 0xe1, 0xde, 0xdb, 0xd8, 0xd4, 0xd1, 0xcd, 0xc9, 0xc5, 0xc1, 0xbd, 0xb9
    .db     0xb5, 0xb0, 0xab, 0xa7, 0xa2, 0x9d, 0x98, 0x93, 0x8e, 0x88, 0x83, 0x7e, 0x78, 0x73, 0x6d, 0x67
    .db     0x61, 0x5c, 0x56, 0x50, 0x4a, 0x44, 0x3e, 0x38, 0x31, 0x2b, 0x25, 0x1f, 0x19, 0x12, 0x0c, 0x06
    .db     0x00, 0xfa, 0xf4, 0xee, 0xe7, 0xe1, 0xdb, 0xd5, 0xcf, 0xc8, 0xc2, 0xbc, 0xb6, 0xb0, 0xaa, 0xa4
    .db     0x9f, 0x99, 0x93, 0x8d, 0x88, 0x82, 0x7d, 0x78, 0x72, 0x6d, 0x68, 0x63, 0x5e, 0x59, 0x55, 0x50
    .db     0x4b, 0x47, 0x43, 0x3f, 0x3b, 0x37, 0x33, 0x2f, 0x2c, 0x28, 0x25, 0x22, 0x1f, 0x1c, 0x19, 0x16
    .db     0x14, 0x12, 0x0f, 0x0d, 0x0c, 0x0a, 0x08, 0x07, 0x05, 0x04, 0x03, 0x02, 0x02, 0x01, 0x01, 0x01
    .db     0x00, 0x01, 0x01, 0x01, 0x02, 0x02, 0x03, 0x04, 0x05, 0x07, 0x08, 0x0a, 0x0c, 0x0d, 0x0f, 0x12
    .db     0x14, 0x16, 0x19, 0x1c, 0x1f, 0x22, 0x25, 0x28, 0x2c, 0x2f, 0x33, 0x37, 0x3b, 0x3f, 0x43, 0x47
    .db     0x4b, 0x50, 0x55, 0x59, 0x5e, 0x63, 0x68, 0x6d, 0x72, 0x78, 0x7d, 0x82, 0x88, 0x8d, 0x93, 0x99
    .db     0x9f, 0xa4, 0xaa, 0xb0, 0xb6, 0xbc, 0xc2, 0xc8, 0xcf, 0xd5, 0xdb, 0xe1, 0xe7, 0xee, 0xf4, 0xfa

trigonometricIntegerTable:
    
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db     0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db     0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db     0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db     0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db     0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db     0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db     0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff

trigonometricAtanAngleTable:
    
    .db     0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x40, 0x20, 0x12, 0x0d, 0x09, 0x08, 0x06, 0x05
    .db     0x40, 0x2d, 0x20, 0x17, 0x12, 0x0f, 0x0d, 0x0b
    .db     0x40, 0x32, 0x28, 0x20, 0x1a, 0x16, 0x12, 0x10
    .db     0x40, 0x36, 0x2d, 0x25, 0x20, 0x1b, 0x17, 0x15
    .db     0x40, 0x37, 0x30, 0x29, 0x24, 0x20, 0x1c, 0x19
    .db     0x40, 0x39, 0x32, 0x2d, 0x28, 0x23, 0x20, 0x1c
    .db     0x40, 0x3a, 0x34, 0x2f, 0x2a, 0x26, 0x23, 0x20

trigonometricAtanOffsetTable:
    
    .db     0x00, 0x80, 0x00, 0x80

; �f�o�b�O�o��
;
hexString:
    
    .ascii  "0123456789ABCDEF"



; DATA �̈�
;
    .area   _DATA


; �ϐ��̒�`
;

; �t���O
;
_flag::
    
    .ds     1

; ���N�G�X�g
;
_request::
    
    .ds     1

; �L�[����
;
_input::
    
    .ds     INPUT_SIZE

inputBuffer:
    
    .ds     1

; �r�f�I
;
_videoPort::
    
    .ds     2

_videoRegister::
    
    .ds     8

_videoTransfer::
    
    .ds     VIDEO_TRANSFER_VRAM_SIZE * VIDEO_TRANSFER_SIZE

; �X�v���C�g
;
_sprite:
    
    .ds     128

; �T�E���h
;
_soundRequest::
    
    .ds     8

_soundHead::
    
    .ds     8

_soundPlay::
    
    .ds     8

soundT:
    
    .ds     4

soundS:
    
    .ds     1

soundM:
    
    .ds     1

soundV:
    
    .ds     4

soundO:
    
    .ds     4

soundL:
    
    .ds     4

soundFrequency:
    
    .ds     8

soundRest:
    
    .ds     4

soundUpdate:
    
    .ds     4

soundRegister:
    
    .ds     16

soundBuffer:
    
    .ds     2

; ����
;
random:
    
    .ds     1




