; Title.s : タイトル
;



; モジュール宣言
;
    .module Title


; 参照ファイル
;
    .include    "bios.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include	"Back.inc"
    .include	"Title.inc"



; CODE 領域
;
    .area   _CODE


; タイトルを更新する
;
_TitleUpdate::
    
    ; 状態の取得
    ld      a, (_appState)
    
    ; 初期化
    cp      #TITLE_STATE_INIT
    jr      nz, 00$
    call    TitleInit
    jr      TitleUpdateEnd
00$:
    
    ; ロード
    cp      #TITLE_STATE_LOAD
    jr      nz, 01$
    call    TitleLoad
    jr      TitleUpdateEnd
01$:
    
    ; 待機
    cp      #TITLE_STATE_LOOP
    jr      nz, 02$
    call    TitleLoop
    jr      TitleUpdateEnd
02$:
    
    ; アンロード
    cp      #TITLE_STATE_UNLOAD
    jr      nz, 03$
    call    TitleUnload
    jr      TitleUpdateEnd
03$:
    
    ; 終了
    call    TitleEnd
    
    ; 更新の終了
TitleUpdateEnd:
    
    ; 背景の更新
    call    _BackUpdate
    
    ; 終了
    ret


; タイトルを初期化する
;
TitleInit:
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; 演奏の停止
    ld      hl, #mmlNull
    ld      (_soundRequest + 0), hl
    ld      (_soundRequest + 2), hl
    ld      (_soundRequest + 4), hl
    ld      (_soundRequest + 6), hl
    
    ; 状態の更新
    ld      a, #TITLE_STATE_LOAD
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; 終了
    ret


; タイトルをロードする
;
TitleLoad::
    
    ; ロゴのロード
    call    _BackStoreLogo
    
    ; 状態の更新
    ld      a, #TITLE_STATE_LOOP
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; 終了
    ret


; タイトルを待機する
;
TitleLoop:
    
    ; 状態の取得
    ld      a, (_appPhase)
    or      a
    jr      nz, TitleLoopMain
    
    ; ロゴの初期化
    ld      a, #0x01
    ld      (count), a
    
    ; 状態の更新
    ld      hl, #_appPhase
    inc     (hl)
    
    ; 待機の処理
TitleLoopMain:
    
    ; 状態の取得
    ld      a, (_appPhase)
    cp      #0x01
    jr      nz, TitleLoopWait
    
    ; SPACE キー
    ld      a, (_input + INPUT_BUTTON_SPACE)
    cp      #0x01
    jr      nz, TitleLoopDone
    
    ; 演奏の開始
    ld      hl, #mmlStartChannel0
    ld      (_soundRequest + 0), hl
    ld      hl, #mmlStartChannel1
    ld      (_soundRequest + 2), hl
    ld      hl, #mmlStartChannel2
    ld      (_soundRequest + 4), hl
    
    ; 状態の更新
    ld      hl, #_appPhase
    inc     (hl)
    
    ; 待機の完了待ち
TitleLoopWait:
    
    ; ゲームスタート
    ld      hl, (_soundRequest + 0)
    ld      a, h
    or      l
    ld      hl, (_soundPlay + 0)
    or      h
    or      l
    jr      nz, TitleLoopDone
    
    ; 状態の更新
    ld      a, #TITLE_STATE_UNLOAD
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; 待機の完了
TitleLoopDone:
    
    ; ロゴの更新
    ld      hl, #count
    dec     (hl)
    jr      nz, TitleLoopEnd
    ld      a, #0x04
    ld      (hl), a
    
    ; カラーの転送の設定
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
    
    ; V-Blank 中の転送の開始
    ld      hl, #_request
    set     #REQUEST_VRAM, (hl)
    
    ; 処理の終了
TitleLoopEnd:
    
    ; 終了
    ret


; タイトルをアンロードする
;
TitleUnload:
    
    ; ロゴのアンロード
    call    _BackRestoreLogo
    
    ; 状態の更新
    ld      a, #TITLE_STATE_END
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; 終了
    ret


; タイトルを終了する
;
TitleEnd:
    
    ; モードの更新
    ld      a, #APP_MODE_GAME
    ld      (_appMode), a
    
    ; 状態の更新
    ld      a, #APP_STATE_NULL
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; 終了
    ret


; 定数の定義
;

; カラーアニメーションテーブル
;
colorAnimationTable:
    
    .db     0xf1, 0x41, 0x61, 0xa1

; MML データ
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




; DATA 領域
;
    .area   _DATA


; 変数の定義
;

; カウント
;
count:
    
    .ds     1

colorTable:
    
    .ds     8



