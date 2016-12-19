; System.s : システムライブラリ
;


; モジュール宣言
;
    .module System

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"


; CODE 領域
;
    .area   _CODE

; システムを初期化する
;
_SystemInitialize::
    
    ; フラグの初期化
    xor     a
    ld      (_flag), a
    
    ; キー入力の初期化
    call    _SystemInitializeInput
    
    ; ビデオの初期化
    call    _SystemInitializeVideo
    
    ; サウンドの初期化
    call    _SystemInitializeSound
    
    ; 終了
    ret

; キー入力を初期化する  
;
_SystemInitializeInput::
    
    ; レジスタの保存
    push    hl
    push    bc
    
    ; キー入力の初期化
    ld      hl, #_input
    xor     a
    ld      b, #INPUT_SIZE
0$:
    ld      (hl), a
    inc     hl
    djnz    0$
    
    ; レジスタの復帰
    pop     bc
    pop     hl
    
    ; 終了
    ret

; キーの入力を更新する
;
_SystemUpdateInput::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; キーの取得
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
    
    ; ボタンの取得
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
    ld      a, #0x03
    call    GTTRIG
    ld      (inputBuffer + 0), a
    ld      a, #0x06
    call    SNSMAT
    cpl
    and     #0x01
    ld      hl, #(inputBuffer + 0)
    or      (hl)
    ld      hl, #(_input + INPUT_BUTTON_SHIFT)
    jr      z, 11$
    ld      a, (hl)
    inc     a
    jr      nz, 11$
    ld      a, #0xff
11$:
    ld      (hl), a
    ld      a, #0x07
    call    SNSMAT
    ld      b, a
    ld      hl, #(_input + INPUT_BUTTON_ESC)
    ld      a, (hl)
    inc     a
    jr      nz, 12$
    ld      a, #0xff
12$:
    bit     #0x02, b
    jr      z, 13$
    xor     a
13$:
    ld      (hl), a
    ld      hl, #(_input + INPUT_BUTTON_STOP)
    ld      a, (hl)
    inc     a
    jr      nz, 14$
    ld      a, #0xff
14$:
    bit     #0x04, b
    jr      z, 15$
    xor     a
15$:
    ld      (hl), a

    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; ビデオを初期化する
;
_SystemInitializeVideo::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    
    ; ポートの取得
    ld      a, (0x0006)
    ld      (_videoPort + 0), a
    ld      a, (0x0007)
    ld      (_videoPort + 1), a
    
    ; レジスタの取得
    ld      hl, #RG0SAV
    ld      de, #_videoRegister
    ld      bc, #0x08
    ldir
    
    ; VRAM の転送の初期化
    ld      hl, #_videoTransfer
    xor     a
    ld      b, #(VIDEO_TRANSFER_VRAM_SIZE * VIDEO_TRANSFER_SIZE)
0$:
    ld      (hl), a
    inc     hl
    djnz    0$
    
    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; スクリーンモードを設定する
;
_SystemSetScreenMode::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    
    ; レジスタの設定
    add     a, a
    add     a, a
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #videoScreenMode
    add     hl, bc
    ld      de, #_videoRegister
    ld      bc, #0x08
    ldir
    
    ; レジスタの転送
    call    _SystemTransferVideoRegister
    
    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; レジスタを転送する
;
_SystemTransferVideoRegister::
    
    ; レジスタの保存
    push    hl
    push    bc
    
    ; 割り込みの禁止
    di
    
    ; レジスタの設定
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
    
    ; 割り込み禁止の解除
    ei
    
    ; レジスタの復帰
    pop     bc
    pop     hl
    
    ; 終了
    ret

; VRAM にデータを転送する
;
_SystemTransferVram::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    
    ; 割り込みの禁止
    di
    
    ; ポートの取得
    ld      a, (_videoPort + 1)
    ld      d, a
    inc     a
    ld      e, a
    
    ; VRAM 0 の転送
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
    
    ; VRAM 1 の転送
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
    
    ; VRAM 2 の転送
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
    
    ; VRAM 3 の転送
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
    
    ; 割り込み禁止の解除
    ei
    
    ; 転送の完了
90$:
    ld      hl, #_videoTransfer
    xor     a
    ld      b, #(VIDEO_TRANSFER_VRAM_SIZE * VIDEO_TRANSFER_SIZE)
91$:
    ld      (hl), a
    inc     hl
    djnz    91$
    
    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; スプライトをクリアする
;
_SystemClearSprite::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    
    ; スプライトのクリア
    ld      hl, #(_sprite + 0)
    ld      de, #(_sprite + 1)
    ld      bc, #(0x80 - 1)
    ld      a, #0xc0
    ld      (hl), a
    ldir
    
    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; スプライトを転送する
;
_SystemTransferSprite::
    
    ; レジスタの保存
    push    hl
    push    bc
    
    ; スプライトアトリビュートテーブルの取得
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
    
    ; 割り込みの禁止
    di
    
    ; VRAM アドレスの設定
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
    
    ; スプライトアトリビュートテーブルの転送
    ld      hl, #_sprite
    ld      b, #0x80
    otir
    
    ; 割り込み禁止の解除
    ei
    
    ; レジスタの復帰
    pop     bc
    pop     hl
    
    ; 終了
    ret

; スプライトを設定する
;
_SystemSetSprite::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    
    ; スプライトの設定
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
    
    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; サウンドを初期化する
;
_SystemInitializeSound::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; PSG の初期化
    call    GICINI
    ld      e, #0b10111111
    ld      a, #0x07
    call    WRTPSG
    
;   ; サウンドレジスタの初期化
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
    
    ; サウンドデータの初期化
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
    
    ; サウンドパラメータの初期化
    xor     a
    ld      (soundS), a
    ld      (soundM + 0), a
    ld      (soundM + 1), a
    ld      (soundN), a
    ld      a, #0b10111111
    ld      (soundMixing), a
0$:
    call    SystemClearSoundChannel
    inc     a
    cp      #0x04
    jr      nz,  0$
    
    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; サウンドを更新する
;
_SystemUpdateSound::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; スリープの確認
    ld      hl, #_flag
    bit     #FLAG_SOUND_SLEEP, (hl)
    jr      z, 90$
    ld      e, #0b10111111
    ld      a, #0x07
    call    WRTPSG
    jp      SystemUpdateSoundEnd
90$:
    
    ; チャンネルの走査
    ld      bc, #0x0000
    
    ; １チャンネルの処理
SystemUpdateSoundLoop:
    
    ; リクエスト
    ld      ix, #_soundRequest
    add     ix, bc
    ld      a, 0(ix)
    or      1(ix)
    jr      z, 00$
    ld      l, 0(ix)
    ld      h, 1(ix)
    ld      0(ix), b
    ld      1(ix), b
    ld      ix, #_soundHead
    add     ix, bc
    ld      0(ix), l
    ld      1(ix), h
    ld      ix, #_soundPlay
    add     ix, bc
    ld      0(ix), l
    ld      1(ix), h
    ld      a, c
    srl     a
    call    SystemClearSoundChannel
00$:
    
    ; サウンドデータの存在
    ld      ix, #_soundPlay
    add     ix, bc
    ld      a, 0(ix)
    or      1(ix)
    jp      z, SystemUpdateSoundNext
    
    ; 待機
    ld      hl, #soundRest
    add     hl, bc
    dec     (hl)
    jr      z, 01$
    ld      hl, #soundVminus
    add     hl, bc
    ld      a, (hl)
    or      a
    jp      z, SystemUpdateSoundNext
    dec     (hl)
    jp      nz, SystemUpdateSoundNext
    ld      (hl), #0x04
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
    jp      SystemUpdateSoundNext
01$:
    
    ; 再生ポインタの取得
;   ld      ix, #_soundPlay
;   add     ix, bc
    ld      l, 0(ix)
    ld      h, 1(ix)
    
    ; MML の解析
SystemUpdateSoundMml:
    ld      a, (hl)
    inc     hl
    
    ; 0x00 : 終端コード
SystemUpdateSoundMml00:
    or      a
    jr      nz, SystemUpdateSoundMmlFf
    ld      ix, #_soundHead
    add     ix, bc
    ld      0(ix), a
    ld      1(ix), a
    ld      ix, #_soundPlay
    add     ix, bc
    ld      0(ix), a
    ld      1(ix), a
    ld      ix, #soundTone
    add     ix, bc
    ld      0(ix), a
    ld      1(ix), a
    ld      ix, #soundNoise
    add     ix, bc
    ld      0(ix), a
    ld      ix, #soundUpdate
    add     ix, bc
    inc     0(ix)
    jp      SystemUpdateSoundNext
    
    ; $ff : 繰り返し
SystemUpdateSoundMmlFf:
    cp      #0xff
    jr      nz, SystemUpdateSoundMmlS
    ld      ix, #_soundHead
    add     ix, bc
    ld      iy, #_soundPlay
    add     iy, bc
    ld      l, 0(ix)
    ld      0(iy), l
    ld      h, 1(ix)
    ld      1(iy), h
    jr      SystemUpdateSoundMml
    
    ; 'S' : エンベロープ波形（S0 ～ S15）
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
    jr      SystemUpdateSoundMml
    
    ; 'M' : エンベロープ周期（M0 ～ M9）
SystemUpdateSoundMmlM:
    cp      #'M
    jr      nz, SystemUpdateSoundMmlN
    ld      a, (hl)
    inc     hl
    sub     #'0
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      ix, #soundEnvelopeTable
    add     ix, de
    ld      a, 0(ix)
    ld      (soundM + 0), a
    ld      a, 1(ix)
    ld      (soundM + 1), a
    jp      SystemUpdateSoundMml
    
    ; 'N' : ノイズ周波数（N0 ～ N9）
SystemUpdateSoundMmlN:
    cp      #'N
    jr      nz, SystemUpdateSoundMmlT
    ld      a, (hl)
    inc     hl
    sub     #'0
    ld      e, a
    ld      d, b
    ld      ix, #soundNoiseTable
    add     ix, de
    ld      a, 0(ix)
    ld      (soundN), a
    jp      SystemUpdateSoundMml
    
    ; 'T' : テンポ（T1 ～ T8）
SystemUpdateSoundMmlT:
    cp      #'T
    jr      nz, SystemUpdateSoundMmlV
    ld      a, (hl)
    inc     hl
    sub     #'1
    ld      ix, #soundT
    add     ix, bc
    ld      0(ix), a
    jp      SystemUpdateSoundMml
    
    ; 'V' : 音量（V0 ～ V16）
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
    jp      c, SystemUpdateSoundMmlVminus
    cp      #('9 + 0x01)
    jp      nc, SystemUpdateSoundMmlVminus
    sub     #'0
    add     #0x0a
    ld      0(ix), a
    inc     hl
    
    ; 'V-' : 音量の減衰
SystemUpdateSoundMmlVminus:
    ld      a, (hl)
    cp      #'-
    ld      a, b
    jr      nz, 10$
    ld      a, #0x04
    inc     hl
10$:
    ld      ix, #soundVminus
    add     ix, bc
    ld      0(ix), a
    jp      SystemUpdateSoundMml
    
    ; 'O' : オクターブ（O1 ～ O8）
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
    
    ; 'L' : 音の長さ（L0 ～ L9）
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
    
    ; 'R' : 休符
SystemUpdateSoundMmlR:
    cp      #'R
    jr      nz, SystemUpdateSoundMmlX
    ld      ix, #soundTone
    add     ix, bc
    ld      0(ix), b
    ld      1(ix), b
    ld      ix, #soundNoise
    add     ix, bc
    ld      0(ix), b
    jr      SystemUpdateSoundRest
    
    ; 'X' : ノイズ
SystemUpdateSoundMmlX:
    cp      #'X
    jr      nz, SystemUpdateSoundMmlA
    ld      ix, #soundTone
    add     ix, bc
    ld      0(ix), b
    ld      1(ix), b
    ld      ix, #soundNoise
    add     ix, bc
    ld      0(ix), #0x01
    jr      SystemUpdateSoundRest
    
    ; 'A' : 音符
SystemUpdateSoundMmlA:
    sub     #'C
    jr      nc, 20$
    add     a, #0x07
20$:
    add     a, a
    add     a, a
    ld      e, a
    ld      d, b
    ld      ix, #(soundToneFrequencyTable + 0x04)
    add     ix, de
    ld      iy, #soundO
    add     iy, bc
    ld      a, 0(iy)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    add     ix, de
    ld      a, (hl)
    cp      #'+
    jr      nz, 21$
    inc     ix
    inc     ix
    inc     hl
    jr      22$
21$:
    cp      #'-
    jr      nz, 22$
    dec     ix
    dec     ix
    inc     hl
22$:
    ld      iy, #soundTone
    add     iy, bc
    ld      a, 0(ix)
    ld      0(iy), a
    ld      a, 1(ix)
    ld      1(iy), a
    ld      ix, #soundNoise
    add     ix, bc
    ld      0(ix), b
    ; jr      SystemUpdateSoundRest
    
    ; 音の長さの設定
SystemUpdateSoundRest:
    ld      a, (hl)
    cp      #('9 + 0x01)
    jr      nc, 30$
    sub     #'0
    jr      c, 30$
    inc     hl
    jr      31$
30$:
    ld      ix, #soundL
    add     ix, bc
    ld      a, 0(ix)
31$:
    ld      e, a
    ld      d, b
    ld      ix, #soundLengthTable
    add     ix, de
    ld      iy, #soundT
    add     iy, bc
    ld      a, 0(iy)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    add     ix, de
    ld      iy, #soundRest
    add     iy, bc
    ld      a, 0(ix)
    ld      0(iy), a
    ld      ix, #soundUpdate
    add     ix, bc
    inc     0(ix)
    
    ; 再生ポインタの保存
    ld      ix, #_soundPlay
    add     ix, bc
    ld      0(ix), l
    ld      1(ix), h
    ; jr      SystemUpdateSoundNext
    
    ; チャンネルの走査の完了
SystemUpdateSoundNext:
    
    ; 次のチャンネルへ
    inc     c
    inc     c
    ld      a, c
    cp      #0x08
    jp      nz, SystemUpdateSoundLoop
    
    ; 設定の確認
    ld      iy, #soundUpdate
    ld      a, 0(iy)
    or      2(iy)
    or      4(iy)
    or      6(iy)
    jp      z, SystemUpdateSoundEnd
    
    ; エンベロープ周波数の設定
    ld      hl, #soundM
    ld      e, (hl)
    ld      a, #0x0b
    call    WRTPSG
    inc     hl
    ld      e, (hl)
    ld      a, #0x0c
    call    WRTPSG
    
    ; ノイズ周波数の設定
    ld      a, (soundN)
    ld      e, a
    ld      a, #0x06
    call    WRTPSG
    
    ; チャンネルの設定
    ld      a, (soundMixing)
    ld      c, a
    ld      b, #0x00
    
    ; チャンネルＡの設定
    ld      a, 0(iy)
    or      a
    jr      z, 49$
    ld      a, #0b00001001
    or      c
    ld      c, a
    ld      hl, (soundTone + 0)
    ld      a, h
    or      l
    jr      z, 40$
    ld      a, #0b11111110
    and     c
    ld      c, a
    ld      e, l
    ld      a, #0x00
    call    WRTPSG
    ld      e, h
    ld      a, #0x01
    call    WRTPSG
    jr      41$
40$:
    ld      a, (soundNoise + 0)
    or      a
    jr      z, 42$
    ld      a, #0b11110111
    and     c
    ld      c, a
41$:
    ld      a, (soundV + 0)
42$:
    ld      (soundVolume + 0), a
    ld      e, a
    or      b
    ld      b, a
    ld      a, #0x08
    call    WRTPSG
49$:

    ; チャンネルＢの設定
    ld      a, 2(iy)
    or      a
    jr      z, 59$
    ld      a, #0b00010010
    or      c
    ld      c, a
    ld      hl, (soundTone + 2)
    ld      a, h
    or      l
    jr      z, 50$
    ld      a, #0b11111101
    and     c
    ld      c, a
    ld      e, l
    ld      a, #0x02
    call    WRTPSG
    ld      e, h
    ld      a, #0x03
    call    WRTPSG
    jr      51$
50$:
    ld      a, (soundNoise + 2)
    or      a
    jr      z, 52$
    ld      a, #0b11101111
    and     c
    ld      c, a
51$:
    ld      a, (soundV + 2)
52$:
    ld      (soundVolume + 2), a
    ld      e, a
    or      b
    ld      b, a
    ld      a, #0x09
    call    WRTPSG
59$:

    ; チャンネルＤの設定
    ld      a, 6(iy)
    or      a
    jr      z, 69$
    ld      a, #0b00100100
    or      c
    ld      c, a
    ld      hl, (soundTone + 6)
    ld      a, h
    or      l
    jr      z, 60$
    ld      a, #0b11111011
    and     c
    ld      c, a
    ld      e, l
    ld      a, #0x04
    call    WRTPSG
    ld      e, h
    ld      a, #0x05
    call    WRTPSG
    jr      61$
60$:
    ld      a, (soundNoise + 6)
    or      a
    jr      z, 62$
    ld      a, #0b11011111
    and     c
    ld      c, a
61$:
    ld      a, (soundV + 6)
62$:
    ld      (soundVolume + 6), a
    ld      e, a
    or      b
    ld      b, a
    ld      a, #0x0a
    call    WRTPSG
    jr      79$
69$:

    ; チャンネルＣの設定
    ld      a, 4(iy)
    or      a
    jr      z, 79$
    ld      a, #0b00100100
    or      c
    ld      c, a
    ld      hl, (soundTone + 4)
    ld      a, h
    or      l
    jr      z, 70$
    ld      a, #0b11111011
    and     c
    ld      c, a
    ld      e, l
    ld      a, #0x04
    call    WRTPSG
    ld      e, h
    ld      a, #0x05
    call    WRTPSG
    jr      71$
70$:
    ld      a, (soundNoise + 4)
    or      a
    jr      z, 72$
    ld      a, #0b11011111
    and     c
    ld      c, a
71$:
    ld      a, (soundV + 4)
72$:
    ld      (soundVolume + 4), a
    ld      e, a
    or      b
    ld      b, a
    ld      a, #0x0a
    call    WRTPSG
79$:

    ; エンベロープ形状の設定
    ld      a, #0x10
    and     b
    jr      z, 80$
    ld      a, (soundS)
    ld      e, a
    ld      a, #0x0d
    call    WRTPSG
80$:
    
    ; ミキシングの設定
    ld      a, c
    ld      (soundMixing), a
    ld      e, a
    ld      a, #0x07
    call    WRTPSG
    
    ; 設定の完了
    xor     a
    ld      0(iy), a
    ld      2(iy), a
    ld      4(iy), a
    ld      6(iy), a
    
    ; 更新の終了
SystemUpdateSoundEnd:
    
    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; サウンドを一時停止する
;
_SystemSuspendSound::
    
    ; レジスタの保存
    push    hl
    
    ; スリープの設定
    ld      hl, #_flag
    set     #FLAG_SOUND_SLEEP, (hl)
    
    ; サウンドの停止
    ld      e, #0b10111111
    ld      a, #0x07
    call    WRTPSG
    
    ; レジスタの復帰
    pop     hl
    
    ; 終了
    ret

; サウンドを再開する
;
_SystemResumeSound::
    
    ; レジスタの保存
    push        hl
    
    ; スリープの解除
    ld      hl, #_flag
    res     #FLAG_SOUND_SLEEP, (hl)
    
    ; サウンドの更新
    ld      ix, #soundUpdate
    ld      a, #0x01
    ld      0(ix), a
    ld      2(ix), a
    ld      4(ix), a
    ld      6(ix), a
    
    ; レジスタの復帰
    pop     hl
    
    ; 終了
    ret

; サウンドのチャンネルをクリアする
;
SystemClearSoundChannel:
    
    ; レジスタの保存
    push    af
    push    hl
    push    bc
    
    ; チャンネルのクリア
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
    
    ; レジスタの復帰
    pop     bc
    pop     hl
    pop     af
    
    ; 終了
    ret

; 乱数を取得する
;
_SystemGetRandom::
    
    ; レジスタの保存
    push    hl
    
    ; 乱数の生成
    ld      hl, #random
    ld      a, #0xaa
    xor     (hl)
    add     a, #73
    ld      (hl), a
    
    ; レジスタの復帰
    pop     hl
    
    ; 終了
    ret

; sin の値を取得する
;
_SystemGetSin::
    
    ; レジスタの保存
    push    bc
    push    ix
    
    ; 値の取得
    ld      c, a
    ld      b, #0x00
    ld      ix, #trigonometricDecimalTable
    add     ix, bc
    ld      l, 0(ix)
    ld      ix, #trigonometricIntegerTable
    add     ix, bc
    ld      h, 0(ix)
    
    ; レジスタの復帰
    pop     ix
    pop     bc
    
    ; 終了
    ret

; cos の値を取得する
;
_SystemGetCos::
    
    ; レジスタの保存
    push    af
    push    bc
    push    ix
    
    ; 値の取得
    add     a, #0x40
    ld      c, a
    ld      b, #0x00
    ld      ix, #trigonometricDecimalTable
    add     ix, bc
    ld      l, 0(ix)
    ld      ix, #trigonometricIntegerTable
    add     ix, bc
    ld      h, 0(ix)
    
    ; レジスタの復帰
    pop     ix
    pop     bc
    pop     af
    
    ; 終了
    ret

; atan2 の値を取得する
;
_SystemGetAtan2::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    
    ; 値の取得
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
    
    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; A レジスタの内容を出力する
;
_SystemPutRegisterA::
    
    ; レジスタの保存
    push    af
    push    hl
    push    bc
    
    ; 上位４ビットの出力
    push    af
    rra
    rra
    rra
    rra
    and     #0x0f
    ld      c, a
    ld      b, #0x00
    ld      hl, #hexString
    add     hl, bc
    ld      a, (hl)
    call    CHPUT
    pop     af
    
    ; 下位４ビットの出力
    and     #0b00001111
    ld      c, a
    ld      b, #0x00
    ld      hl, #hexString
    add     hl, bc
    ld      a, (hl)
    call    CHPUT
    
    ; レジスタの復帰
    pop     bc
    pop     hl
    pop     af
    
    ; 終了
    ret

; 定数の定義
;

; キー入力
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

; ビデオ
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

; サウンド
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

;  三角関数
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

; デバッグ出力
;
hexString:
    
    .ascii  "0123456789ABCDEF"


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; フラグ
;
_flag::
    
    .ds     1

; リクエスト
;
_request::
    
    .ds     1

; キー入力
;
_input::
    
    .ds     INPUT_SIZE

inputBuffer:
    
    .ds     1

; ビデオ
;
_videoPort::
    
    .ds     2

_videoRegister::
    
    .ds     8

_videoTransfer::
    
    .ds     VIDEO_TRANSFER_VRAM_SIZE * VIDEO_TRANSFER_SIZE

; スプライト
;
_sprite:
    
    .ds     128

; サウンド
;
_soundRequest::
    
    .ds     8

_soundHead::
    
    .ds     8

_soundPlay::
    
    .ds     8

soundS:
    
    .ds     1

soundM:
    
    .ds     2

soundN:
    
    .ds     1

soundMixing:

    .ds     1

soundT:
    
    .ds     8

soundV:
    
    .ds     8

soundVolume:
    
    .ds     8

soundVminus:
    
    .ds     8

soundO:
    
    .ds     8

soundL:
    
    .ds     8

soundTone:
    
    .ds     8

soundNoise:
    
    .ds     8

soundRest:
    
    .ds     8

soundUpdate:
    
    .ds     8

; 乱数
;
random:
    
    .ds     1
