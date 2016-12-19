; main.s : メインプログラム
;



; モジュール宣言
;
    .module main


; 参照ファイル
;
    .include    "bios.inc"
    .include    "System.inc"
    .include    "App.inc"


; マクロの定義
;



; CODE 領域
;
    .area   _CODE


; メインプログラム
;
_main::
    
    ; 初期化
    
    ; システムの初期化
    call    _SystemInitialize
    
    ; アプリケーションの初期化
    call    _AppInitialize
    
    ; 割り込みの禁止
    di
    
    ; タイマ割り込み処理の保存
    ld      hl, #H.TIMI
    ld      de, #h.timiRoutine
    ld      bc, #5
    ldir
    
    ; タイマ割り込み処理の書き換え
    ld      a, #0xc3
    ld      (H.TIMI + 0), a
    ld      hl, #H.timiEntry
    ld      (H.TIMI + 1), hl
    
    ; 割り込み禁止の解除
    ei
    
    ; キャンセル待ち
0$:
    ld      a, (_flag)
    bit     #FLAG_CANCEL, a
    jr      z, 0$
    
    ; 終了
    
    ; アプリケーションの終了
    
    ; システムの終了
    
    ; 割り込みの禁止
    di
    
    ; タイマ割り込み処理の復帰
    ld      hl, #h.timiRoutine
    ld      de, #H.TIMI
    ld      bc, #5
    ldir
    
    ; 割り込み禁止の解除
    ei
    
    ; 終了
    ret


; タイマ割り込みのエントリ
;
H.timiEntry:
    
    ; レジスタの保存
    push    af
    push    hl
    
    ; 割り込み禁止の解除
    ei
    
    ; すでに割り込み済みかどうか
    ld      hl, #_flag
    bit     #FLAG_H_TIMI, (hl)
    jp      nz, H.timiEntryEnd
    
    ; 処理の開始
    set     #FLAG_H_TIMI, (hl)
    
    ; リクエストの取得
    ld      a, (_request)
    ld      h, a
    
    ; ビデオレジスタの転送
    bit     #REQUEST_VIDEO_REGISTER, h
    jr      z, 00$
    call    _SystemTransferVideoRegister
00$:
    
    ; VRAM の転送
    bit     #REQUEST_VRAM, h
    jr      z, 01$
    call    _SystemTransferVram
01$:
    
    ; スプライトの転送
    call    _SystemTransferSprite
    
    ; キー入力の更新
    call    _SystemUpdateInput
    
    ; サウンドの更新
    call    _SystemUpdateSound
    
    ; STOP キーによるキャンセル
    ld      a, (_input + INPUT_BUTTON_STOP)
    dec     a
    jr      nz, 90$
    ld      hl, #_flag
    set     #FLAG_CANCEL, (hl)
90$:
    
    ; 処理の完了
H.timiEntryDone:
    
    ; アプリケーションの更新
    call    _AppUpdate
    
    ; 割り込みの完了
    ld      hl, #_flag
    res     #FLAG_H_TIMI, (hl)
    
    ; エントリの終了
H.timiEntryEnd:
    
    ; レジスタの復帰
    pop     hl
    pop     af
    
    ; 保存されたタイマ割り込みルーチンの実行
    jp      h.timiRoutine
    ret


; 定数定義
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



; DATA 領域
;
    .area   _DATA


; 変数定義
;

; タイマ割り込み
;
h.timiRoutine:
    
    .ds     5



