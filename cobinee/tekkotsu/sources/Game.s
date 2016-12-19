; Game.s : ゲーム
;


; モジュール宣言
;
    .module Game

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Pilot.inc"
    .include    "Steel.inc"

; 外部変数宣言
;
    .globl  _backPatternNameTable
    .globl  _backPatternGeneratorTable
    .globl  _backColorTable
    .globl  _fontPatternGeneratorTable
    .globl  _fontColorTable

; マクロの定義
;

; 状態
GAME_STATE_NULL         =   0x00
GAME_STATE_START        =   0x10
GAME_STATE_PLAY         =   0x20
GAME_STATE_HIT          =   0x30
GAME_STATE_OVER         =   0x40

; 処理
GAME_PROCESS_NULL           =   0b00000000
GAME_PROCESS_PILOT_UPDATE   =   0b00000001
GAME_PROCESS_PILOT_RENDER   =   0b00000010
GAME_PROCESS_STEEL_UPDATE   =   0b00000100
GAME_PROCESS_STEEL_RENDER   =   0b00001000


; CODE 領域
;
    .area   _CODE

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; ゲームの初期化
    ld      hl, #(gameScore + 0x00)
    ld      de, #(gameScore + 0x01)
    ld      bc, #(0x0004)
    xor     a
    ld      (hl), a
    ldir
    ld      hl, #(gameStringScore)
    ld      de, #(gameScoreText)
    ld      bc, #(0x000c)
    ldir
    ld      a, #0x03
    ld      (gameRest), a
    ld      hl, #(gameStringRest)
    ld      de, #(gameRestText)
    ld      bc, #(0x0006)
    ldir
    
    ; パイロットの初期化
    call    _PilotInitialize
    
    ; 鉄骨の初期化
    call    _SteelInitialize
    
;   ; パターンネームの転送
;   ld      hl, #_backPatternNameTable
;   ld      de, #APP_PATTERN_NAME_TABLE_0
;   ld      bc, #0x0300
;   call    LDIRVM
    
    ; パターンジェネレータの転送／背景
    ld      hl, #_backPatternGeneratorTable
    ld      bc, (_backPatternGeneratorTable + 0x00)
    add     hl, bc
    ld      bc, (_backPatternGeneratorTable + 0x02)
    ld      de, #APP_PATTERN_GENERATOR_TABLE_0
    call    LDIRVM
    ld      hl, #_backPatternGeneratorTable
    ld      bc, (_backPatternGeneratorTable + 0x04)
    add     hl, bc
    ld      bc, (_backPatternGeneratorTable + 0x06)
    ld      de, #APP_PATTERN_GENERATOR_TABLE_1
    call    LDIRVM
    ld      hl, #_backPatternGeneratorTable
    ld      bc, (_backPatternGeneratorTable + 0x08)
    add     hl, bc
    ld      bc, (_backPatternGeneratorTable + 0x0a)
    ld      de, #APP_PATTERN_GENERATOR_TABLE_2
    call    LDIRVM
    
    ; パターンジェネレータの転送／フォント
    ld      hl, #(_fontPatternGeneratorTable + 0x0c)
    ld      bc, (_fontPatternGeneratorTable + 0x02)
    ld      de, #(APP_PATTERN_GENERATOR_TABLE_0 + 0x0600)
    call    LDIRVM
    ld      hl, #(_fontPatternGeneratorTable + 0x0c)
    ld      bc, (_fontPatternGeneratorTable + 0x02)
    ld      de, #(APP_PATTERN_GENERATOR_TABLE_1 + 0x0600)
    call    LDIRVM
    ld      hl, #(_fontPatternGeneratorTable + 0x0c)
    ld      bc, (_fontPatternGeneratorTable + 0x02)
    ld      de, #(APP_PATTERN_GENERATOR_TABLE_2 + 0x0600)
    call    LDIRVM
    
    ; カラーテーブルの転送／背景
    ld      hl, #_backColorTable
    ld      bc, (_backColorTable + 0x00)
    add     hl, bc
    ld      bc, (_backColorTable + 0x02)
    ld      de, #APP_COLOR_TABLE_0
    call    LDIRVM
    ld      hl, #_backColorTable
    ld      bc, (_backColorTable + 0x04)
    add     hl, bc
    ld      bc, (_backColorTable + 0x06)
    ld      de, #APP_COLOR_TABLE_1
    call    LDIRVM
    ld      hl, #_backColorTable
    ld      bc, (_backColorTable + 0x08)
    add     hl, bc
    ld      bc, (_backColorTable + 0x0a)
    ld      de, #APP_COLOR_TABLE_2
    call    LDIRVM
    
    ; カラーテーブルの転送／フォント
    ld      hl, #(_fontColorTable + 0x0c)
    ld      bc, (_fontColorTable + 0x02)
    ld      de, #(APP_COLOR_TABLE_0 + 0x0600)
    call    LDIRVM
    ld      hl, #(_fontColorTable + 0x0c)
    ld      bc, (_fontColorTable + 0x02)
    ld      de, #(APP_COLOR_TABLE_1 + 0x0600)
    call    LDIRVM
    ld      hl, #(_fontColorTable + 0x0c)
    ld      bc, (_fontColorTable + 0x02)
    ld      de, #(APP_COLOR_TABLE_2 + 0x0600)
    call    LDIRVM
    
;   ; 描画の開始
;   ld      hl, #(_videoRegister + VDP_R1)
;   set     #VDP_R1_BL, (hl)
    
;   ; ビデオレジスタの転送
;   ld      hl, #_request
;   set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; 処理の初期化
    xor     a
    ld      (gameProcess), a
    
    ; 状態の設定
    ld      a, #GAME_STATE_START
    ld      (gameState), a
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_appState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを更新する
;
_GameUpdate::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; 状態別の処理
    ld      a, (gameState)
    and     #0xf0
    cp      #GAME_STATE_START
    jr      nz, 10$
    call    GameStart
    jr      19$
10$:
    cp      #GAME_STATE_PLAY
    jr      nz, 11$
    call    GamePlay
    jr      19$
11$:
    cp      #GAME_STATE_HIT
    jr      nz, 12$
    call    GameHit
    jr      19$
12$:
    cp      #GAME_STATE_OVER
    jr      nz, 19$
    call    GameOver
    jr      19$
19$:
    
    ; パイロットの更新
    ld      a, (gameProcess)
    and     #GAME_PROCESS_PILOT_UPDATE
    call    nz, _PilotUpdate
    
    ; 鉄骨の更新
    ld      a, (gameProcess)
    and     #GAME_PROCESS_STEEL_UPDATE
    call    nz, _SteelUpdate
    
    ; パイロットの描画
    ld      a, (gameProcess)
    and     #GAME_PROCESS_PILOT_RENDER
    call    nz, _PilotRender
    
    ; 鉄骨の描画
    ld      a, (gameProcess)
    and     #GAME_PROCESS_STEEL_RENDER
    call    nz, _SteelRender

    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret
    
; ゲームを開始する
;
GameStart:
    
    ; レジスタの保存
    
    ; 初期化の開始
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$
    
    ; 残機の設定
    ld      a, (gameRest)
    add     a, #0xcf
    ld      (gameRestText + 0x05), a
    
    ; パターンネームの設定
    ld      hl, #(gamePatternName + 0x0000)
    ld      de, #(gamePatternName + 0x0001)
    ld      bc, #(0x02ff)
    ld      a, #0xc0
    ld      (hl), a
    ldir
    ld      hl, #(gameStringStart)
    ld      de, #(gamePatternName + 0x012b)
    ld      bc, #(0x000a)
    ldir
    ld      hl, #(gameRestText)
    ld      de, #(gamePatternName + 0x01ad)
    ld      bc, #(0x0006)
    ldir
    
    ; パターンネームの転送
    call    GameTransferPatternName
    
    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; ビデオレジスタの転送
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; タイマの設定
    ld      a, #0x60
    ld      (gameTimer), a
    
    ; 処理の設定
    ld      a, #(GAME_PROCESS_NULL)
    ld      (gameProcess), a
    
    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; タイマの更新
    ld      hl, #gameTimer
    dec     (hl)
    jr      nz, 19$
    
    ; ゲーム開始
    ld      a, #GAME_STATE_PLAY
    ld      (gameState), a
    
    ; タイマ更新の完了
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームをプレイする
;
GamePlay::
    
    ; レジスタの保存
    
    ; 初期化の開始
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$
    
    ; パイロットのリセット
    call    _PilotReset
    
    ; 鉄骨のリセット
    call    _SteelReset
    
    ; パターンネームの設定
    ld      hl, #_backPatternNameTable
    ld      de, #gamePatternName
    ld      bc, #0x0300
    ldir
    ld      hl, #(gameRestText)
    ld      de, #(gamePatternName + 0x0034)
    ld      bc, #(0x0006)
    ldir
    
    ; パターンネームの転送
    call    GameTransferPatternName

    ; 処理の設定
    ld      a, #(GAME_PROCESS_PILOT_UPDATE | GAME_PROCESS_PILOT_RENDER | GAME_PROCESS_STEEL_UPDATE | GAME_PROCESS_STEEL_RENDER)
    ld      (gameProcess), a
    
    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; ヒットチェックの開始
    ld      iy, #_pilotRange
    ld      ix, #_steel
    ld      b, #STEEL_N
10$:
    ld      a, STEEL_STATE(ix)
    or      a
    jr      z, 19$
    ld      a, STEEL_X(ix)
    cp      PILOT_RANGE_RIGHT(iy)
    jr      nc, 19$
    add     a, #STEEL_WIDTH
    cp      PILOT_RANGE_LEFT(iy)
    jr      c, 19$
    ld      a, STEEL_Y(ix)
    cp      PILOT_RANGE_TOP(iy)
    jr      c, 19$
    sub     #STEEL_HEIGHT
    cp      PILOT_RANGE_BOTTOM(iy)
    jr      nc, 19$
    
    ; ヒット
    ld      a, #GAME_STATE_HIT
    ld      (gameState), a
    
    ; ヒットチェックの完了
19$:
    ld      de, #STEEL_SIZE
    add     ix, de
    djnz    10$
    
    ; 速度の取得
    ld      d, #0x01
    ld      a, (_pilotTurn)
    and     #0x7f
    cp      #0x30
    jr      c, 20$
    inc     d
    cp      #0x60
    jr      c, 20$
    inc     d
    cp      #0x70
    jr      c, 20$
    inc     d
20$:
    ld      a, d
    ld      (_steelSpeed), a
    
    ; スコアの更新
    ld      ix, #_steelFall
    ld      a, 0(ix)
    or      a
    jr      z, 39$
30$:
    ld      hl, #(gameScore + 0x04)
    ld      b, #0x05
31$:
    inc     (hl)
    ld      a, (hl)
    cp      #0x0a
    jr      c, 33$
    xor     a
    ld      (hl), a
    dec     hl
    djnz    31$
    ld      a, #0x09
    ld      b, #0x05
32$:
    inc     hl
    ld      (hl), a
    djnz    32$
33$:
    dec     0(ix)
    jr      nz, 30$
    ld      de, #(gameScore)
    ld      hl, #(gameScoreText + 0x0006)
    ld      bc, #0x05c0
34$:
    ld      a, (de)
    or      a
    jr      nz, 35$
    ld      (hl), c
    inc     de
    inc     hl
    djnz    34$
    jr      39$
35$:
    ld      a, (de)
    add     a, #0xd0
    ld      (hl), a
    inc     de
    inc     hl
    djnz    35$
39$:
    
    ; スコアの転送
    ld      hl, #(gameScoreText + 0x0006)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE_0 + 0x0026)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_DST), hl
    ld      a, #0x06
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームでヒットする
;
GameHit:
    
    ; レジスタの保存
    
    ; 初期化の開始
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$
    
    ; タイマの設定
    ld      a, #0x40
    ld      (gameTimer), a
    
    ; 処理の設定
    ld      a, #(GAME_PROCESS_NULL)
    ld      (gameProcess), a
    
    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; タイマの更新
    ld      hl, #gameTimer
    dec     (hl)
    jr      nz, 19$
    
    ; 
    ld      hl, #gameRest
    dec     (hl)
    jr      z, 10$
    
    ; リトライ
    ld      a, #GAME_STATE_START
    ld      (gameState), a
    jr      19$
    
    ; ゲームオーバー
10$:
    ld      a, #GAME_STATE_OVER
    ld      (gameState), a
    
    ; タイマ更新の完了
19$:
    
    ; 処理の設定
    ld      e, #0x00
    ld      a, (hl)
    and     #0x02
    jr      z, 20$
    ld      e, #GAME_PROCESS_PILOT_RENDER
20$:
    ld      a, #GAME_PROCESS_STEEL_RENDER
    or      e
    ld      (gameProcess), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームオーバーになる
;
GameOver:
    
    ; レジスタの保存
    
    ; 初期化の開始
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$
    
    ; パターンネームの設定
    ld      hl, #(gamePatternName + 0x0000)
    ld      de, #(gamePatternName + 0x0001)
    ld      bc, #(0x02ff)
    ld      a, #0xc0
    ld      (hl), a
    ldir
    ld      hl, #(gameStringOver)
    ld      de, #(gamePatternName + 0x012b)
    ld      bc, #(0x000a)
    ldir
    ld      hl, #(gameScoreText)
    ld      de, #(gamePatternName + 0x01aa)
    ld      bc, #(0x000c)
    ldir
    
    ; パターンネームの転送
    call    GameTransferPatternName
    
    ; タイマの設定
    xor     a
    ld      (gameTimer), a
    
    ; 処理の設定
    ld      a, #(GAME_PROCESS_NULL)
    ld      (gameProcess), a
    
    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; タイマの更新
    ld      hl, #gameTimer
    dec     (hl)
    jr      nz, 19$
    
    ; 描画の停止
    ld      hl, #(_videoRegister + VDP_R1)
    res     #VDP_R1_BL, (hl)
    
    ; ビデオレジスタの転送
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; タイトルへ戻る
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_appState), a
    
    ; タイマ更新の完了
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; パターンネームを転送する
;
GameTransferPatternName:

    ; レジスタの保存
    
    ; パターンネームの転送
    xor     a
    ld      hl, #(gamePatternName + 0x0000)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE_0)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES), a
    ld      hl, #(gamePatternName + 0x0100)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE_1)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_BYTES), a
    ld      hl, #(gamePatternName + 0x0200)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE_2)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; 文字列
;
gameStringStart:

    .db     0xe7, 0xe1, 0xed, 0xe5, 0xc0, 0xf3, 0xf4, 0xe1, 0xf2, 0xf4

gameStringOver:

    .db     0xe7, 0xe1, 0xed, 0xe5, 0xc0, 0xc0, 0xef, 0xf6, 0xe5, 0xf2

gameStringScore:

    .db     0xf3, 0xe3, 0xef, 0xf2, 0xe5, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xd0

gameStringRest:

    .db     0xf2, 0xe5, 0xf3, 0xf4, 0xc0, 0xd0


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
gameState:
    
    .ds     1
    
; 処理
;
gameProcess:

    .ds     1

; タイマ
;
gameTimer:

    .ds     1

; スコア
;
gameScore:

    .ds     5

gameScoreText:

    .ds     12

; 残機
;
gameRest:

    .ds     1

gameRestText:

    .ds     6

; パターンネーム
;
gamePatternName:

    .ds     0x300
