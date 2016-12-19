; Back.s : 背景
;



; モジュール宣言
;
    .module Back


; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include	"Back.inc"


; 外部変数宣言
;
    .globl  _bg



; CODE 領域
;
    .area   _CODE


; 背景をロードする
;
_BackLoad::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    
    ; パターンネームテーブルのロード
    call    BackLoadPatternNameTable
    
    ; カラーテーブルのロード
    call    BackLoadColorTable
    
    ; ハイスコアの作成
    call    BackMakeHiscorePatternNameTable
    
    ; ハイスコアの転送
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
    
    ; 現在のスコアの作成
    call    BackMakeScorePatternNameTable
    
    ; 現在のスコアの転送
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
    
    ; スコアの倍率の作成
    call    BackMakeRatePatternNameTable
    
    ; スコアの倍率の転送
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
    
    ; タイマの作成
    call    BackMakeTimerPatternNameTable
    
    ; タイマの転送
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
    
    ; カウントの初期化
    ld      a, #0x01
    ld      (count), a
    
    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret


; 背景を更新する
;
_BackUpdate::
    
    ; レジスタの保存
    push    hl
    push    de
    
    ; カラーアニメーション
    
    ; カウンタの更新
    ld      a, (count)
    dec     a
    jr      nz, 9$
    
    ; カラーの設定
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
    
    ; V-Blank 中の転送の開始
    ld      hl, #_request
    set     #REQUEST_VRAM, (hl)
    
    ; カウンタの再設定
    ld      a, #0x18
9$:
    ld      (count), a
    
    ; レジスタの復帰
    pop     de
    pop     hl
    
    ; 終了
    ret


; ハイスコアを転送する
;
_BackTransferHiscore::
    
    ; レジスタの保存
    push    hl
    
    ; ハイスコアの作成
    call    BackMakeHiscorePatternNameTable
    
    ; ハイスコアの転送の設定
    ld      hl, #hiscorePatternNameTable
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC), hl
    ld      hl, #(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_HISCORE)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST), hl
    ld      a, #0x06
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES), a
    
    ; V-Blank 中の転送の開始
    ld      hl, #_request
    set     #REQUEST_VRAM, (hl)
    
    ; レジスタの復帰
    pop     hl
    
    ; 終了
    ret


; ステータスを転送する
;
_BackTransferStatus::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    
    ; 現在のスコアの作成
    call    BackMakeScorePatternNameTable
    
    ; 現在のスコアの転送の設定
    ld      hl, #scorePatternNameTable
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC), hl
    ld      hl, #(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_SCORE)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST), hl
    ld      a, #0x06
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES), a
    
    ; スコアの倍率の作成
    call    BackMakeRatePatternNameTable
    
    ; スコアの倍率の転送の設定
    ld      hl, #ratePatternNameTable
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_SRC), hl
    ld      hl, #(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_RATE)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_DST), hl
    ld      a, #0x04
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_BYTES), a
    
    ; タイマの作成
    call    BackMakeTimerPatternNameTable
    
    ; タイマの転送の設定
    ld      hl, #timerPatternNameTable
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_SRC), hl
    ld      hl, #(VIDEO_GRAPHIC1_PATTERN_NAME_TABLE + BACK_PATTERN_NAME_TABLE_TIMER)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_DST), hl
    ld      a, #0x04
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_BYTES), a
    
    ; V-Blank 中の転送の開始
    ld      hl, #_request
    set     #REQUEST_VRAM, (hl)
    
    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret


; ロゴを配置する
;
_BackStoreLogo::
    
    ; レジスタの保存
    push    hl
    
    ; パターンネームテーブルの転送の設定
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
    
    ; V-Blank 中の転送の開始
    ld      hl, #_request
    set     #REQUEST_VRAM, (hl)
    
    ; レジスタの復帰
    pop     hl
    
    ; 終了
    ret


; ロゴの背景を復旧する
;
_BackRestoreLogo::
    
    ; レジスタの保存
    push    hl
    
    ; パターンネームテーブルの転送の設定
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
    
    ; V-Blank 中の転送の開始
    ld      hl, #_request
    set     #REQUEST_VRAM, (hl)
    
    ; レジスタの復帰
    pop     hl
    
    ; 終了
    ret


; メッセージを配置する
;
_BackStoreMessage::
    
    ; レジスタの保存
    push    hl
    push    de
    
    ; パターンネームテーブルの転送の設定
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
    
    ; V-Blank 中の転送の開始
    ld      hl, #_request
    set     #REQUEST_VRAM, (hl)
    
    ; レジスタの復帰
    pop     de
    pop     hl
    
    ; 終了
    ret


; メッセージの背景を復旧する
;
_BackRestoreMessage::
    
    ; レジスタの保存
    push    hl
    
    ; パターンネームテーブルの転送の設定
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
    
    ; V-Blank 中の転送の開始
    ld      hl, #_request
    set     #REQUEST_VRAM, (hl)
    
    ; レジスタの復帰
    pop     hl
    
    ; 終了
    ret


; パターンネームテーブルを読み込む
;
BackLoadPatternNameTable:
    
    ; VRAM アドレスの設定
    ld      a, (_videoPort + 1)
    inc     a
    ld      c, a
    ld      a, #<VIDEO_GRAPHIC1_PATTERN_NAME_TABLE
    out     (c), a
    ld      a, #(>VIDEO_GRAPHIC1_PATTERN_NAME_TABLE | 0b01000000)
    out     (c), a
    dec     c
    
    ; パターンネームテーブルの転送
    ld      hl, #(_bg + 0x14)
    ld      b, #0x00
    otir
    otir
    otir
    
    ; 終了
    ret


; ハイスコアのパターンネームテーブルを作成する
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


; 現在のスコアのパターンネームテーブルを作成する
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


; スコアの倍率のパターンネームテーブルを作成する
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


; タイマのパターンネームテーブルを作成する
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


; カラーテーブルを読み込む
;
BackLoadColorTable:
    
    ; VRAM アドレスの設定
    ld      a, (_videoPort + 1)
    inc     a
    ld      c, a
    ld      a, #<VIDEO_GRAPHIC1_COLOR_TABLE
    out     (c), a
    ld      a, #(>VIDEO_GRAPHIC1_COLOR_TABLE | 0b01000000)
    out     (c), a
    dec     c
    
    ; カラーテーブルの転送
    ld      hl, #colorTable
    ld      b, #0x20
    otir
    
    ; 終了
    ret


; 定数の定義
;

; カラーテーブル
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

; ロゴデータ
;
logoPatternNameTable:
    
    .db     0x40, 0x41, 0x48, 0x49, 0x50, 0x51, 0x58, 0x59, 0x60, 0x61, 0x68, 0x69, 0x70, 0x71, 0x78, 0x79
    .db     0x42, 0x43, 0x4a, 0x4b, 0x52, 0x53, 0x5a, 0x5b, 0x62, 0x63, 0x6a, 0x6b, 0x72, 0x73, 0x7a, 0x7b

; メッセージデータ
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



; DATA 領域
;
    .area   _DATA


; 変数の定義
;

; ハイスコア
;
hiscorePatternNameTable:
    
    .ds     6

; 現在のスコア
;
scorePatternNameTable:
    
    .ds     6

; スコアの倍率
;
ratePatternNameTable:
    
    .ds     4

; タイマ
;
timerPatternNameTable:
    
    .ds     4

; カウント
;
count:
    
    .ds     1



