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
    .include    "Unit.inc"
    .include    "Enemy.inc"
    .include    "Player.inc"
    .include    "Eshot.inc"
    .include    "Pshot.inc"
    .include	"Cockpit.inc"
    .include	"Star.inc"
    .include	"Text.inc"
    .include    "Demo.inc"

; マクロの定義
;

; 状態
GAME_STATE_NULL     =   0x00
GAME_STATE_TITLE    =   0x10
GAME_STATE_START    =   0x20
GAME_STATE_PLAY     =   0x30
GAME_STATE_CLEAR    =   0x40
GAME_STATE_OVER     =   0x50

; プロセス
GAME_PROCESS_NULL       =   0b00000000
GAME_PROCESS_UNIT       =   0b00000001
GAME_PROCESS_ENEMY      =   0b00000010
GAME_PROCESS_ESHOT      =   0b00000100
GAME_PROCESS_PSHOT      =   0b00001000
GAME_PROCESS_PLAYER     =   0b00010000
GAME_PROCESS_DEMO       =   0b00100000
GAME_PROCESS_COCKPIT    =   0b00000000
GAME_PROCESS_STAR       =   0b00000000
GAME_PROCESS_TEXT       =   0b00000000


; CODE 領域
;
    .area   _CODE

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; ゲームの初期化
    xor     a
    ld      (gameProcess), a
    ld      (gameTimer + 0), a
    ld      (gameTimer + 1), a
    ld      (_gameFrame), a
    ld      (_gameRotateY), a
    ld      (_gameRotateX), a
    ld      (_gameSightX), a
    ld      (_gameSightY), a
    ld      (_gameMoveZ), a
    ld      (_gameAccel), a
    ld      (_gameFire), a
    
    ; ユニットの初期化
    call    _UnitInitialize
    
    ; エネミーショットの初期化
    call    _EshotInitialize
    
    ; プレイヤーショットの初期化
    call    _PshotInitialize
    
    ; エネミーの初期化
    call    _EnemyInitialize
    
    ; プレイヤーの初期化
    call    _PlayerInitialize
    
    ; コクピットの初期化
    call    _CockpitInitialize
    
    ; スターの初期化
    call    _StarInitialize
    
    ; テキストの初期化
    call    _TextInitialize
    
    ; デモの初期化
    call    _DemoInitialize
    
    ; スプライトジェネレータの設定
    ld      a, #(APP_SPRITE_GENERATOR_TABLE_0 >> 11)
    ld      (_videoRegister + VDP_R6), a
    
    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; ビデオレジスタの転送
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; 状態の設定
    ld      a, #GAME_STATE_TITLE
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
    ld      hl, #(_sprite + GAME_SPRITE_MASK)
    ld      de, #0x0080
    ld      bc, #0x040c
00$:
    ld      (hl), e
    inc     hl
    ld      (hl), d
    inc     hl
    ld      (hl), d
    inc     hl
    ld      (hl), d
    inc     hl
    djnz    00$
    
    ; 状態別の処理
    ld      a, (gameState)
    and     #0xf0
    cp      #GAME_STATE_TITLE
    jr      nz, 10$
    call    GameTitle
    jr      19$
10$:
    ld      a, (gameState)
    and     #0xf0
    cp      #GAME_STATE_START
    jr      nz, 11$
    call    GameStart
    jr      19$
11$:
    cp      #GAME_STATE_PLAY
    jr      nz, 12$
    call    GamePlay
    jr      19$
12$:
    cp      #GAME_STATE_CLEAR
    jr      nz, 13$
    call    GameClear
    jr      19$
13$:
    cp      #GAME_STATE_OVER
    jr      nz, 19$
    call    GameOver
19$:
    
    ; 操作
    call    GameControl
    
    ; ヒットチェック
    ld      a, (gameProcess)
    and     #GAME_PROCESS_PSHOT
    call    nz, _PshotHit
    
    ; プロセスの更新（先頭）
    ld      a, (gameProcess)
    and     #GAME_PROCESS_UNIT
    call    nz, _UnitUpdate
    ld      a, (gameProcess)
    and     #GAME_PROCESS_ESHOT
    call    nz, _EshotUpdate
    ld      a, (gameProcess)
    and     #GAME_PROCESS_PSHOT
    call    nz, _PshotUpdate
    ld      a, (gameProcess)
    and     #GAME_PROCESS_ENEMY
    call    nz, _EnemyUpdate
    ld      a, (gameProcess)
    and     #GAME_PROCESS_PLAYER
    call    nz, _PlayerUpdate
    
    ; プロセスの更新（共通）
    call    _CockpitUpdate
    call    _StarUpdate
    call    _TextUpdate
    
    ; プロセスの更新（末端）
    ld      a, (gameProcess)
    and     #GAME_PROCESS_DEMO
    call    nz, _DemoUpdate
    
    ; プロセスの描画（先頭）
    ld      a, (gameProcess)
    and     #GAME_PROCESS_UNIT
    call    nz, _UnitRender
    ld      a, (gameProcess)
    and     #GAME_PROCESS_ESHOT
    call    nz, _EshotRender
    ld      a, (gameProcess)
    and     #GAME_PROCESS_PSHOT
    call    nz, _PshotRender
    ld      a, (gameProcess)
    and     #GAME_PROCESS_ENEMY
    call    nz, _EnemyRender
    ld      a, (gameProcess)
    and     #GAME_PROCESS_PLAYER
    call    nz, _PlayerRender
    
    ; プロセスの描画（共通）
    call    _CockpitRender
    call    _StarRender
    call    _TextRender
    
    ; プロセスの描画（末端）
    ld      a, (gameProcess)
    and     #GAME_PROCESS_DEMO
    call    nz, _DemoRender
    
    ; パターンネームの転送
    xor     a
    ld      hl, #(_gamePatternName + 0x0000)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0000)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES), a
    ld      hl, #(_gamePatternName + 0x0100)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0100)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_BYTES), a
    ld      hl, #(_gamePatternName + 0x0200)
    ld      a, (_playerHitCount)
    and     #0x01
    jr      z, 30$
    inc     hl
30$:
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0200)
    ld      c, #0x00
    ld      a, (_playerHitCount)
    or      a
    jr      z, 31$
    dec     c
    and     #0x01
    jr      nz, 31$
    inc     hl
31$:
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_DST), hl
    ld      a, c
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)
    
    ; ヒットの描画
    ld      a, (_playerHitCount)
    or      a
    jr      z, 40$
    ld      a, #0x08
40$:
    ld      (_videoRegister + VDP_R7), a
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; フレームの更新
    ld      hl, #_gameFrame
    inc     (hl)
    
    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret
    
; タイトルを表示する
;
GameTitle:
    
    ; レジスタの保存
    
    ; 初期化の開始
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$
    
    ; プロセスの設定
    ld      a, #GAME_PROCESS_DEMO
    ld      (gameProcess), a
    
    ; プロセスのリセット
    call    _UnitReset
    call    _EshotReset
    call    _PshotReset
    call    _EnemyReset
    call    _PlayerReset
    call    _DemoReset
    
    ; テキストのクリア
    ld      hl, #0x0000
    ld      (_textString), hl
    
    ; ＢＧＭの設定
    ld      hl, #gameBgmTitle0
    ld      (_soundRequest + 0), hl
    ld      hl, #gameBgmTitle1
    ld      (_soundRequest + 2), hl
    ld      hl, #gameBgmTitle2
    ld      (_soundRequest + 4), hl
    
    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; デモの監視
    ld      a, (_demoState)
    or      a
    jr      nz, 19$
    ld      a, #GAME_STATE_TITLE
    ld      (gameState), a
19$:
    
    ; キー入力待ち
    ld      a, (_input + INPUT_BUTTON_SPACE)
    cp      #0x01
    jr      nz, 29$
    ld      a, #GAME_STATE_START
    ld      (gameState), a
29$:
    
    ; 乱数の操作
    call    _SystemGetRandom
    
    ; レジスタの復帰
    
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
    
    ; プロセスの設定
    ld      a, #GAME_PROCESS_NULL
    ld      (gameProcess), a
    
    ; ワープ演出の設定
    xor     a
    ld      (_gameMoveZ), a
    ld      a, #0x01
    ld      (_gameAccel), a
    
    ; テキストのクリア
    ld      hl, #0x0000
    ld      (_textString), hl
    
    ; ＢＧＭの設定
    ld      hl, #gameBgmStart0
    ld      (_soundRequest + 0), hl
    ld      hl, #gameBgmStart1
    ld      (_soundRequest + 2), hl
    ld      hl, #gameBgmStart2
    ld      (_soundRequest + 4), hl
    
    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; ワープの開始
    ld      a, (gameState)
    and     #0x0f
    cp      #0x01
    jr      nz, 19$
    
    ; 加速
    ld      hl, #_gameMoveZ
    ld      a, (hl)
    add     a, #0x02
    ld      (hl), a
    cp      #0x80
    jr      c, 19$
    
    ; テキストの設定
    ld      hl, #(_gamePatternName + (0x01 << 5) + 0x04)
    ld      (_textPosition), hl
    ld      hl, #gameStringStart
    ld      (_textString), hl
    xor     a
    ld      (_textLength), a
    
    ; ワープ開始の完了
    ld      hl, #gameState
    inc     (hl)
19$:
    
    ; テキストの表示
    ld      a, (gameState)
    and     #0x0f
    cp      #0x02
    jr      nz, 29$
    
    ; テキストの監視
    ld      a, (_textLength)
    cp      #0xc0
    jr      c, 29$
    
    ; テキスト表示の完了
    ld      hl, #0x0000
    ld      (_textString), hl
    ld      hl, #gameState
    inc     (hl)
29$:
    
    ; ワープの終了
    ld      a, (gameState)
    and     #0x0f
    cp      #0x03
    jr      nz, 39$
    
    ; 減速
    ld      hl, #_gameMoveZ
    ld      a, (hl)
    sub     #0x02
    ld      (hl), a
    jr      nz, 39$
    
    ; ワープ終了の完了
    ld      (_gameAccel), a
    ld      a, #GAME_STATE_PLAY
    ld      (gameState), a
39$:
    
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
    
    ; プロセスの設定
    ld      a, #(GAME_PROCESS_UNIT + GAME_PROCESS_ENEMY + GAME_PROCESS_ESHOT + GAME_PROCESS_PSHOT + GAME_PROCESS_PLAYER)
    ld      (gameProcess), a
    
    ; タイマの設定
    ld      a, #0x20
    ld      (gameTimer + 0), a
    
    ; テキストのクリア
    ld      hl, #0x0000
    ld      (_textString), hl
    
    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; ゲームの終了判定
    ld      a, (_enemyKilled + UNIT_TYPE_KABAKALI)
    or      a
    jr      z, 10$
    ld      a, (_enemyBorned + UNIT_TYPE_NULL)
    ld      e, a
    ld      a, (_enemyKilled + UNIT_TYPE_NULL)
    cp      e
    jr      nz, 10$
    ld      a, #GAME_STATE_CLEAR
    ld      (gameState), a
    jr      90$
10$:
    ld      a, (_playerOver)
    or      a
    jr      z, 19$
    ld      a, #GAME_STATE_OVER
    ld      (gameState), a
    jr      90$
19$:

    ; プレイの完了
90$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームをクリアする
;
GameClear:
    
    ; レジスタの保存
    
    ; 初期化の開始
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$
    
    ; プロセスの設定
    ld      a, #(GAME_PROCESS_UNIT + GAME_PROCESS_ENEMY + GAME_PROCESS_ESHOT + GAME_PROCESS_PSHOT)
    ld      (gameProcess), a
    
    ; ワープ演出の設定
    xor     a
    ld      (_gameMoveZ), a
    ld      a, #0x01
    ld      (_gameAccel), a
    
    ; テキストのクリア
    ld      hl, #0x0000
    ld      (_textString), hl
    
    ; ＢＧＭの設定
    ld      hl, #gameBgmClear0
    ld      (_soundRequest + 0), hl
    ld      hl, #gameBgmClear1
    ld      (_soundRequest + 2), hl
    ld      hl, #gameBgmClear2
    ld      (_soundRequest + 4), hl
    
    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; ワープの開始
    ld      a, (gameState)
    and     #0x0f
    cp      #0x01
    jr      nz, 19$
    
    ; 加速
    ld      hl, #_gameMoveZ
    ld      a, (hl)
    add     a, #0x02
    ld      (hl), a
    cp      #0x80
    jr      c, 19$
    
    ; テキストの設定
    ld      hl, #(_gamePatternName + (0x01 << 5) + 0x06)
    ld      (_textPosition), hl
    ld      hl, #gameStringClear
    ld      (_textString), hl
    xor     a
    ld      (_textLength), a
    
    ; プロセスの設定
    ld      a, #GAME_PROCESS_NULL
    ld      (gameProcess), a
    
    ; ワープ開始の完了
    ld      hl, #gameState
    inc     (hl)
19$:
    
    ; サウンドの再生
    ld      a, (gameState)
    and     #0x0f
    cp      #0x02
    jr      nz, 29$
    
    ; サウンドの監視
    ld      hl, (_soundHead + 0x00)
    ld      a, h
    or      l
    jr      nz, 29$
    
    ; サウンド再生の完了
    ld      hl, #0x0000
    ld      (_textString), hl
    ld      hl, #gameState
    inc     (hl)
29$:
    
    ; ワープの終了
    ld      a, (gameState)
    and     #0x0f
    cp      #0x03
    jr      nz, 39$
    
    ; 減速
    ld      hl, #_gameMoveZ
    ld      a, (hl)
    sub     #0x02
    ld      (hl), a
    jr      nz, 39$
    ld      (_gameAccel), a
    
    ; ワープ終了の完了
    ld      a, #GAME_STATE_TITLE
    ld      (gameState), a
39$:
    
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
    
    ; プロセスの設定
    ld      a, #GAME_PROCESS_PLAYER
    ld      (gameProcess), a
    
    ; ワープ演出の設定
    xor     a
    ld      (_gameMoveZ), a
    ld      a, #0x01
    ld      (_gameAccel), a
    
    ; タイマの設定
    ld      a, #0x80
    ld      (gameTimer + 0), a
    
    ; テキストのクリア
    ld      hl, #0x0000
    ld      (_textString), hl
    
    ; ＢＧＭの設定
    ld      hl, #gameBgmOver
    ld      (_soundRequest + 0), hl
    ld      (_soundRequest + 2), hl
    ld      (_soundRequest + 4), hl
    
    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; タイマ待ち
    ld      a, (gameState)
    and     #0x0f
    cp      #0x01
    jr      nz, 19$
    
    ; タイマの監視
    ld      hl, #(gameTimer + 0)
    dec     (hl)
    ld      a, (hl)
    jr      nz, 19$
    
    ; テキストの設定
    ld      a, (_playerOver)
    cp      #PLAYER_OVER_KILLED
    jr      nz, 10$
    ld      hl, #(_gamePatternName + (0x05 << 5) + 0x07)
    ld      (_textPosition), hl
    ld      hl, #gameStringOverKilled
    ld      (_textString), hl
    jr      11$
10$:
    ld      hl, #(_gamePatternName + (0x05 << 5) + 0x0a)
    ld      (_textPosition), hl
    ld      hl, #gameStringOverEmpty
    ld      (_textString), hl
11$:
    xor     a
    ld      (_textLength), a
    
    ; タイマ待ちの完了
    ld      hl, #gameState
    inc     (hl)
19$:
    
    ; テキストの表示
    ld      a, (gameState)
    and     #0x0f
    cp      #0x02
    jr      nz, 29$
    
    ; テキストの監視
    ld      a, (_textLength)
    cp      #0xc0
    jr      c, 29$
    
    ; テキスト表示の完了
    ld      hl, #0x0000
    ld      (_textString), hl
    ld      a, #GAME_STATE_TITLE
    ld      (gameState), a
29$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 操作する
;
GameControl:
    
    ; レジスタの保存
    
    ; 操作のマスク
    ld      a, (gameState)
    and     #0xf0
    sub     #GAME_STATE_PLAY
    jr      z, 00$
    ld      a, #0xff
00$:
    cpl
    ld      e, a
    
    ; 水平移動
    ld      hl, #_gameSightX
    ld      c, #0x00
    ld      a, (_input + INPUT_KEY_LEFT)
    and     e
    or      a
    jr      z, 10$
    dec     c
    ld      a, (hl)
    cp      #-0x10
    jr      z, 19$
    sub     #0x02
    jr      19$
10$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    and     e
    or      a
    jr      z, 11$
    inc     c
    ld      a, (hl)
    cp      #0x10
    jr      z, 19$
    add     a, #0x02
    jr      19$
11$:
    ld      a, (hl)
    or      a
    jr      z, 19$
    jp      p, 12$
    add     a, #0x02
    jr      19$
12$:
    sub     #0x02
19$:
    ld      (hl), a
    ld      a, c
    ld      (_gameRotateY), a
    
    ; 垂直移動
    ld      hl, #_gameSightY
    ld      c, #0x00
    ld      a, (_input + INPUT_KEY_UP)
    and     e
    or      a
    jr      z, 20$
    dec     c
    ld      a, (hl)
    cp      #-0x10
    jr      z, 29$
    sub     #0x02
    jr      29$
20$:
    ld      a, (_input + INPUT_KEY_DOWN)
    and     e
    or      a
    jr      z, 21$
    inc     c
    ld      a, (hl)
    cp      #0x10
    jr      z, 29$
    add     a, #0x02
    jr      29$
21$:
    ld      a, (hl)
    or      a
    jr      z, 29$
    jp      p, 22$
    add     a, #0x02
    jr      29$
22$:
    sub     #0x02
29$:
    ld      (hl), a
    ld      a, c
    ld      (_gameRotateX), a
    
    ; 前進
    ld      a, (_gameAccel)
    or      a
    jr      nz, 39$
    ld      hl, #_gameMoveZ
    ld      a, (_input + INPUT_BUTTON_SHIFT)
    and     e
    or      a
    ld      a, (hl)
    jr      z, 30$
    add     a, #0x02
    cp      #0x80
    jr      c, 31$
    ld      a, #0x80
    jr      31$
30$:
    sub     #0x02
    jr      nc, 31$
    xor     a
31$:
    ld      (hl), a
39$:
    
    ; 発射
    ld      a, (_input + INPUT_BUTTON_SPACE)
    and     e
    cp      #0x01
    jr      z, 40$
    xor     a
40$:
    ld      (_gameFire), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; 文字列
;
gameStringStart:

    .ascii  "        MISSION        \n"
    .ascii  "\n"
    .ascii  "\n"
    .ascii  "DESTROY ALL ENEMIES AND\n"
    .ascii  "\n"
    .ascii  "  DEFEND THE UNIVERSE"
    .db     0x00

gameStringClear:

    .ascii  "  CONGRATULATIONS  \n"
    .ascii  "\n"
    .ascii  "\n"
    .ascii  "YOU HAVE DEMOLISHED\n"
    .ascii  "\n"
    .ascii  "  ALL ENEMIES AND  \n"
    .ascii  "\n"
    .ascii  "PEACE IS MAINTAINED\n"
    .ascii  "\n"
    .ascii  "\n"
    .ascii  "\n"
    .ascii  "      THE END"
    .db     0x00

gameStringOverKilled:

    .ascii  "YOU ARE DESTROYED\n"
    .ascii  "\n"
    .ascii  "\n"
    .ascii  "    GAME OVER"
    .db     0x00
    
gameStringOverEmpty:

    .ascii  "ENERGY EMPTY\n"
    .ascii  "\n"
    .ascii  "\n"
    .ascii  " GAME OVER"
    .db     0x00
    
; ＢＧＭ
;
gameBgmTitle0:

    .ascii  "T1V15-L3"
    .ascii  "O4E-E-B-5A-5E-E-B-5A-5E-E-G-A-E-E-B-5A-5E-E-O5E-5O4B-5A-B-1A-1D-E-"
    .ascii  "O4E-E-B-5A-5E-E-B-5A-5E-E-G-A-O4C-5C-D-RC-D-7R5R5R5"
    .db     0x00
    
gameBgmTitle1:

    .ascii  "T1V16L3S0N2"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXM5XXX"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXM5XXX"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXM5XXX"
    .ascii  "M5XR5XR5XR"
    .ascii  "R6M3XXXR5"
    .db     0x00

gameBgmTitle2:

    .ascii  "T1V15-L5"
    .ascii  "O3B-RRB-RRB-RB-RRB-RRO4E-R"
    .ascii  "O3B-RRB-RRB-RG-R3G-R3A-R9"
    .db     0x00
    
gameBgmStart0:

    .ascii  "T1V15-L3"
    .ascii  "O4R5E-5E-D-RE-RG-RG-5E-D-5R5E-5E-D-RE-RB-RA-6R5"
    .ascii  "O4R5E-5E-D-RE-RG-RA-5G-E-D-E-6D-6E-6G-6A-5G-5"
    .ascii  "O4R5E-5E-D-RE-RG-RG-5E-D-5R5E-5E-D-RE-RB-RA-6R5"
    .ascii  "O4R5E-5E-D-RE-RG-RA-5G-E-D-E-6O5D-6O4A-8R7"
    .db     0xff

gameBgmStart1:

    .ascii  "T1V16L3S0N2"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXM5XXX"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M5XR5XR5XR5XR5XXXR"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXM5XXX"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M5XR5XR5XRR7XXXR"
    .db     0xff

gameBgmStart2:

    .ascii  "T1V15-L5"
    .ascii  "O3RB-R7R9RB-R7R9"
    .ascii  "O3RB-R7R9BRRBRRO4FR"
    .ascii  "O3RB-R7R9RB-R7R9"
    .ascii  "O3RB-R7R9B6O4A-6F8R7"
    .db     0xff

gameBgmClear0:

    .ascii  "T1V15-L3"
    .ascii  "O4R5A-5O5F5E-5G-6F6R5O4R5A-5O5F5E-5C6D-RD-CD-"
    .ascii  "O6C6O5B-6RD-A-5G-FRA-RF8RR5"
    .ascii  "O5F5E-D-RCRE-E-D-8RR9R9"
    .ascii  "O5F5E-D-RCRE-E-D-8RR9R9"
    .ascii  "R9R9"
    .db     0x00
    
gameBgmClear1:

    .ascii  "T1V16L3S0N2"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M5XRR5R5RM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M5XRR5R5RM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3X"
    .ascii  "M5XRRM5XRRM5XR"
    .ascii  "M3XXXRR7"
    .db     0x00

gameBgmClear2:

    .ascii  "T1V15-L5"
    .ascii  "O4RFRRO5C6R6RO4RFRRA-6R6R"
    .ascii  "O5G-6R6RFRRR3CR3RRR"
    .ascii  "O5CRRR3O4B-R3RRRR9R9"
    .ascii  "O5CRRR3O4B-R3RRRR9R9"
    .ascii  "R9R9"
    .db     0x00

gameBgmOver:

    .ascii  "T1"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
gameState:
    
    .ds     1

; プロセス
;
gameProcess:

    .ds     1

; タイマ
;
gameTimer:

    .ds     2

; フレーム
;
_gameFrame::

    .ds     1

; 操作
;
_gameRotateY::

    .ds     1

_gameRotateX::

    .ds     1

_gameSightX::

    .ds     1

_gameSightY::

    .ds     1

_gameMoveZ::

    .ds     1

_gameAccel::

    .ds     1

_gameFire::

    .ds     1

; パターンネーム
;
_gamePatternName::

    .ds     768
