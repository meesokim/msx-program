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

; タイマ割り込みカウンタ
H_TIMI_COUNT    =   0x02


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
    
    ; タイマ割り込みカウンタの初期化
    xor     a
    ld      (h.timiCount), a
    
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
    
    ; キーボードバッファのクリア
    call    KILBUF
    
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
H.timiEntry::
    
    ; レジスタの保存
    push    af
    push    hl
    
    ; 割り込み禁止の解除
    ei
    
    ; タイマ割り込みカウンタの更新
    ld      hl, #h.timiCount
    inc     (hl)
    
    ; すでに割り込み済みかどうか
    ld      hl, #_flag
    bit     #FLAG_H_TIMI, (hl)
    jr      nz, H.timiEntryEnd
    
    ; 指定されたタイマ割り込みカウンタに到達したか
    ld      a, (h.timiCount)
    cp      #H_TIMI_COUNT
    jr      c, H.timiEntryEnd
    
    ; 処理の開始
    set     #FLAG_H_TIMI, (hl)
    
    ; 割り込みカウンタのクリア
    xor     a
    ld      (h.timiCount), a
    
    ; リクエストの取得
    ld      a, (_request)
    ld      h, a
    
    ; ビデオレジスタの転送
    bit     #REQUEST_VIDEO_REGISTER, h
    call    nz, _SystemTransferVideoRegister
    
    ; VRAM の転送
    bit     #REQUEST_VRAM, h
    call    nz, _SystemTransferVram
    
    ; スプライトの転送
    call    _SystemTransferSprite
    
    ; キー入力の更新
    call    _SystemUpdateInput
    
    ; サウンドの更新
    call    _SystemUpdateSound
    
    ; STOP キーによるキャンセル
    ld      a, (_input + INPUT_BUTTON_STOP)
    dec     a
    jr      nz, H.timiEntryDone
    ld      hl, #_flag
    set     #FLAG_CANCEL, (hl)
    
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


; DATA 領域
;
    .area   _DATA

; 変数定義
;

; タイマ割り込みルーチン
;
h.timiRoutine:
    
    .ds     5

; タイマ割り込みカウンタ
;
h.timiCount:

    .ds     1
    
