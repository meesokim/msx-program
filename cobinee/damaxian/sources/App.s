; App.s : アプリケーション
;



; モジュール宣言
;
    .module App


; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include    "Back.inc"
    .include    "Title.inc"
    .include    "Game.inc"


; 外部変数宣言
;
    .globl  _pattern



; CODE 領域
;
    .area   _CODE


; アプリケーションを初期化する
;
_AppInitialize::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    ix
    
    ; スクリーンモードの設定
    ld      a, #VIDEO_GRAPHIC1
    call    _SystemSetScreenMode
    
    ; 割り込みの禁止
    di
    
    ; パターンジェネレータの転送
    ld      a, (_videoPort + 1)
    inc     a
    ld      c, a
    ld      a, #<VIDEO_GRAPHIC1_PATTERN_GENERATOR_TABLE
    out     (c), a
    ld      a, #(>VIDEO_GRAPHIC1_PATTERN_GENERATOR_TABLE | 0b01000000)
    out     (c), a
    dec     c
    ld      hl, #(_pattern + 0x0000)
    ld      b, #0x00
    otir
    otir
    otir
    otir
    otir
    otir
    otir
    otir
    
    ; スプライトジェネレータの転送
    inc     c
    ld      a, #<VIDEO_GRAPHIC1_SPRITE_GENERATOR_TABLE
    out     (c), a
    ld      a, #(>VIDEO_GRAPHIC1_SPRITE_GENERATOR_TABLE | 0b01000000)
    out     (c), a
    dec     c
    otir
    otir
    otir
    otir
    otir
    otir
    otir
    otir
    
    ; 割り込み禁止の解除
    ei
    
    ; アプリケーションの初期化
    
    ; ハイスコアの初期化
    ld      ix, #_appHiscore
    xor     a
    ld      0(ix), a
    ld      1(ix), a
    ld      3(ix), a
    ld      4(ix), a
    ld      5(ix), a
    ld      a, #0x05
    ld      2(ix), a
    
    ; 現在のスコアの初期化
    ld      ix, #_appScore
    xor     a
    ld      0(ix), a
    ld      1(ix), a
    ld      2(ix), a
    ld      3(ix), a
    ld      4(ix), a
    ld      5(ix), a
    
    ; スコアの倍率の初期化
    ld      ix, #_appRate
    xor     a
    ld      0(ix), a
    ld      2(ix), a
    ld      3(ix), a
    inc     a
    ld      1(ix), a
    
    ; タイマの初期化
    ld      ix, #_appTimer
    xor     a
    ld      0(ix), a
    ld      1(ix), a
    ld      2(ix), a
    ld      3(ix), a
    
    ; モードの初期化
    ld      a, #APP_MODE_LOAD
    ld      (_appMode), a
    
    ; 状態の更新
    ld      a, #APP_STATE_NULL
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; レジスタの復帰
    pop     ix
    pop     bc
    pop     hl
    
    ; 終了
    ret


; アプリケーションを更新する
;
_AppUpdate::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; モードの取得
    ld      a, (_appMode)
    
    ; 読み込み
    cp      #APP_MODE_LOAD
    jr      nz, 00$
    call    AppLoad
    jr      AppUpdateEnd
00$:
    
    ; タイトル画面
    cp      #APP_MODE_TITLE
    jr      nz, 01$
    call    AppTitle
    jr      AppUpdateEnd
01$:
    
    ; ゲーム画面
    cp      #APP_MODE_GAME
    jr      nz, 02$
    call    AppGame
    jr      AppUpdateEnd
02$:
    
    ; 更新の終了
AppUpdateEnd:
    
    ; 乱数をまわす
    call    _SystemGetRandom
    
    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret


; アプリケーションを読み込む
;
AppLoad:
    
    ; 背景のロード
    call    _BackLoad
    
    ; 背景色の設定
    ld      a, #0x07
    ld      (_videoRegister + VDP_R7), a
    
    ; スプライトの設定と表示の開始
    ; ld      hl, #(_videoRegister + VDP_R1)
    ; ld      a, (hl)
    ; or      #((1 << VDP_R1_BL) | (1 << VDP_R1_SI))
    ; ld      (hl), a
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    set     #VDP_R1_SI, (hl)
    
    ; V-Blank 中の転送の開始
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; モードの更新
    ld      a, #APP_MODE_TITLE
    ld      (_appMode), a
    
    ; 状態の更新
    ld      a, #APP_STATE_NULL
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; 終了
    ret


; タイトル画面を処理する
;
AppTitle:
    
    ; タイトル画面の更新
    call    _TitleUpdate
    
    ; 終了
    ret


; ゲーム画面を処理する
;
AppGame:
    
    ; ゲーム画面の更新
    call    _GameUpdate
    
    ; 終了
    ret



; 定数の定義
;



; DATA 領域
;
    .area   _DATA


; 変数の定義
;

; モード
;
_appMode::
    
    .ds     1

; 状態
;
_appState::
    
    .ds     1

_appPhase::
    
    .ds     1

; ハイスコア
;
_appHiscore::
    
    .ds     6

; 現在のスコア
;
_appScore::
    
    .ds     6

; スコアの倍率
;
_appRate::
    
    .ds     4

; タイマ
;
_appTimer::
    
    .ds     4



