; Title.s : タイトル
;


; モジュール宣言
;
    .module Title

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Title.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; タイトルを初期化する
;
_TitleInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; ビデオレジスタの転送
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; 状態の設定
    ld      a, #TITLE_STATE_LOOP
    ld      (titleState), a
    ld      a, #APP_STATE_TITLE_UPDATE
    ld      (_appState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; タイトルを更新する
;
_TitleUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; 乱数の更新
    call    _SystemGetRandom
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (titleState)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #titleProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; なにもしない
;
TitleNull:

    ; レジスタの保存

    ; レジスタの復帰
    
    ; 終了
    ret

; タイトルを待機する
;
TitleLoop:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (titleState)
    and     #0x0f
    jr      nz, 09$

    ; 画面の作成
    call    TitlePrintLogo

    ; アニメーションの設定    
    xor     a
    ld      (titleAnimation), a

    ; 初期化の完了
    ld      hl, #titleState
    inc     (hl)
09$:
    
    ; タイムの更新
    ld      a, (titleState)
    and     #0x0f
    cp      #0x01
    jr      nz, 19$

    ; タイムの表示
    call    TitlePrintTime

    ; 状態の更新
    ld      hl, #titleState
    inc     (hl)
19$:

    ; SPACE キーの監視
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 20$

    ; 状態の更新
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_appState), a
    jr      29$

    ; ↑↓キーの監視
20$:
    ld      a, (_input + INPUT_KEY_UP)
    dec     a
    jr      z, 21$
    ld      a, (_input + INPUT_KEY_DOWN)
    dec     a
    jr      nz, 29$
21$:

    ; ゲームの更新
    ld      hl, #_appGame
    ld      a, (hl)
    xor     #0x01
    ld      (hl), a

    ; 状態の更新
    ld      hl, #titleState
    dec     (hl)
    jr      29$

    ; キーの監視の完了
29$:

    ; カーソルの描画
    call    TitlePrintCursor

    ; アニメーションの更新    
    ld      hl, #titleAnimation
    inc     (hl)

    ; レジスタの復帰
    
    ; 終了
    ret

; ロゴを表示する
;
TitlePrintLogo:

    ; レジスタの保存

    ; クリア
    ld      a, #0x80
    call    _AppFillPatternName

    ; 背景の表示
    ld      hl, #titlePattern
    ld      de, #_appPatternName
10$:
    ld      a, (hl)
    or      a
    jr      z, 11$
    ex      de, hl
    ld      c, a
    ld      b, #0x00
    add     hl, bc
    ex      de, hl
    inc     hl
    ld      c, (hl)
;   ld      b, #0x00
    inc     hl
    ldir
    jr      10$
11$:

    ; パターンネームの転送
    call    _AppTransferPatternName

    ; レジスタの復帰

    ; 終了
    ret

; タイムを表示する
;
TitlePrintTime:

    ; レジスタの保存

    ; タイムの表示
    ld      a, (_appGame)
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #_appTime
    add     hl, de
    ld      de, #(_appPatternName + 0x02a7)
    ld      b, #0x04
10$:
    ld      a, (hl)
    add     a, #0xc8
    ld      (de), a
    inc     hl
    inc     de
    djnz    10$

    ; パターンネームの転送
    ld      hl, #(_appPatternName + 0x02a7)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x02a7)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_DST), hl
    ld      a, #0x04
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)

    ; レジスタの復帰

    ; 終了
    ret

; カーソルを表示する
;
TitlePrintCursor:

    ; レジスタの保存

    ; スプライトの表示
    ld      hl, #(_sprite + TITLE_SPRITE_CURSOR)
    ld      a, (_appGame)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, #0x7f
    ld      (hl), a
    inc     hl
    ld      a, #0x20
    ld      (hl), a
    inc     hl
    ld      a, (titleAnimation)
    and     #0x18
    rrca
    add     a, #0x10
    ld      (hl), a
    inc     hl
    ld      a, #0x0b
    ld      (hl), a
;   inc     hl

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
titleProc:
    
    .dw     TitleNull
    .dw     TitleLoop

; パターン
;
titlePattern:

    .db     0x58, 0x04, 0x81, 0x80, 0x82, 0x83
    .db     0x1c, 0x03, 0x84, 0x85, 0x86
    .db     0x1d, 0x02, 0x87, 0x88
    .db     0x1e, 0x04, 0x89, 0x8a, 0x8b, 0x8c
    .db     0x17, 0x07, 0xa7, 0xa8, 0xa9, 0x80, 0x80, 0x8d, 0x8e
    .db     0x19, 0x0a, 0xaa, 0x80, 0xab, 0x80, 0x80, 0x8f, 0x80, 0x90, 0x91, 0x92
    .db     0x16, 0x0a, 0xac, 0xad, 0xae, 0x80, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98
    .db     0x16, 0x08, 0xaf, 0xb0, 0x80, 0x80, 0x99, 0x9a, 0x9b, 0x9c
    .db     0x18, 0x07, 0xb1, 0xb2, 0x80, 0x80, 0x80, 0x80, 0x9d
    .db     0x19, 0x07, 0xb3, 0xb4, 0x80, 0xa0, 0x80, 0x80, 0x9e
    .db     0x18, 0x06, 0xb5, 0xb6, 0xb7, 0x80, 0xa1, 0xa2
    .db     0x1a, 0x06, 0xb8, 0xb9, 0xba, 0x80, 0xa3, 0xa4
    .db     0x1e, 0x02, 0xa5, 0xa6
    .db     0x1a, 0x02, 0xbb, 0xbc
    .db     0x12, 0x06, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7
    .db     0x08, 0x03, 0xbd, 0xbe, 0xbf
    .db     0x1b, 0x03, 0xc0, 0xc1, 0xc2
    .db     0x11, 0x06, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd8
    .db     0x59, 0x06, 0xdc, 0x80, 0xc8, 0xc8, 0xc8, 0xc8
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
titleState:
    
    .ds     0x01

; アニメーション
;
titleAnimation:

    .ds     0x01
