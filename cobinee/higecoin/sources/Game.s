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
    .include    "Stage.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; ステータスの初期化
    call    GameInitializeStatus
    
    ; ステージの初期化
    call    _StageInitialize

    ; プレイヤの初期化
    call    _PlayerInitialize

    ; エネミーの初期化　
    call    _EnemyInitialize

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; ビデオレジスタの転送
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
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
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; 乱数の更新
    call    _SystemGetRandom
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (gameState)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameProc
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
GameNull:

    ; レジスタの保存

    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを開始する
;
GameStart:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; 画面の作成
    xor     a
    call    _AppFillPatternName
    ld      hl, #gameStartString
    ld      de, #(_appPatternName + 0x0169)
    ld      bc, #0x000e
    ldir
    call    _AppTransferPatternName

    ; カウンタの設定
    ld      a, #0x60
    ld      (gameCount), a

    ; ＢＧＭの再生
    ld      hl, #gameSoundBgm0
    ld      (_soundRequest + 0x0000), hl
    ld      hl, #gameSoundBgm1
    ld      (_soundRequest + 0x0002), hl
    ld      hl, #gameSoundNull
    ld      (_soundRequest + 0x0004), hl
    
    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:
    
    ; カウンタの更新
    ld      hl, #gameCount
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
    ld      a, #GAME_STATE_OPEN
    ld      (gameState), a

    ; 監視の完了
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを開く
;
GameOpen:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$
    
    ; ステージの作成
    ld      a, #STAGE_TYPE_NORMAL
    ld      (_stageType), a
    call    _StageCreate
    
    ; プレイヤの作成
    call    _PlayerCreate

    ; エネミーの作成
    call    _EnemyCreate

    ; ステージを開く
    ld      a, #STAGE_STATE_OPEN
    ld      (_stageState), a

    ; エネミーを開く
    ld      a, #ENEMY_STATE_OPEN
    ld      (_enemyState), a

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; ステージの更新
    call    _StageUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

;   ; ステータスの更新
;   call    GameUpdateStatus

    ; ステージの描画
    call    _StageRender

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; ステータスの描画
    call    GamePrintStatus
    
    ; ステージの監視
    ld      a, (_stageState)
    or      a
    jr      nz, 19$

    ; 状態の更新
    ld      a, #GAME_STATE_PLAY
    ld      (gameState), a

    ; 監視の完了
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームをプレイする
;
GamePlay:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; ステージをプレイ
    ld      a, #STAGE_STATE_PLAY
    ld      (_stageState), a

    ; プレイヤをプレイ
    ld      a, #PLAYER_STATE_JUMP
    ld      (_player + PLAYER_STATE), a

    ; エネミーをプレイ
    ld      a, #ENEMY_STATE_MOVE
    ld      (_enemyState), a

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; ヒット判定
    call    _StageHit
    call    _PlayerHit
    call    _EnemyHit
    
    ; ステージの更新
    call    _StageUpdate
    
    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; ステータスの更新
    call    GameUpdateStatus

    ; ステージの描画
    call    _StageRender

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; ステータスの描画
    call    GamePrintStatus
    
    ; 獲得したコインの総数の監視
    ld      a, (_gameCoin + 0x0000)
    or      a
    jr      z, 10$

    ; 状態の更新
    ld      a, #GAME_STATE_CLEAR
    ld      (gameState), a
    jr      19$
10$:

    ; ヒットの監視
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_BIT_MISS, a
    jr      z, 11$

    ; 状態の更新
    ld      a, #GAME_STATE_MISS
    ld      (gameState), a
    jr      19$
11$:

    ; タイムの監視
    ld      hl, #_gameTime
    ld      a, (hl)
    inc     hl
    or      (hl)
    inc     hl
    or      (hl)
    inc     hl
    or      (hl)
;   inc     hl
    jr      nz, 12$

    ; 状態の更新
    ld      a, #GAME_STATE_MISS
    ld      (gameState), a
    jr      19$
12$:

    ; ステージのコインの残数の監視
    ld      a, (_stageCoinRest)
    or      a
    jr      nz, 13$

    ; 状態の更新
    ld      a, #GAME_STATE_NEXT
    ld      (gameState), a
    jr      19$
13$:

    ; 監視の完了
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 次のゲームに進む
;
GameNext:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; ステージを閉じる
    ld      a, #STAGE_STATE_CLOSE
    ld      (_stageState), a

    ; エネミーを閉じる
    ld      a, #ENEMY_STATE_CLOSE
    ld      (_enemyState), a

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; ステージの更新
    call    _StageUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

;   ; ステータスの更新
;   call    GameUpdateStatus

    ; ステージの描画
    call    _StageRender

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; ステータスの描画
    call    GamePrintStatus
    
    ; プレイヤの監視
    ld      hl, #(_player + PLAYER_POSITION_Y)
    ld      a, (hl)
    cp      #0xc0
    jr      c, 19$
    cp      #0xf0
    jr      nc, 19$
    ld      a, #0xd0
    ld      (hl), a

    ; ステージの監視
    ld      a, (_stageState)
    or      a
    jr      nz, 19$

    ; 状態の更新
    ld      a, #GAME_STATE_OPEN
    ld      (gameState), a

    ; 監視の完了
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームをクリアする
;
GameClear:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; プレイヤを停止
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_BIT_PAUSE, (hl)

    ; ステージを閉じる
    ld      a, #STAGE_STATE_CLOSE
    ld      (_stageState), a

    ; エネミーを閉じる
    ld      a, #ENEMY_STATE_CLOSE
    ld      (_enemyState), a

    ; ＢＧＭの停止
    ld      hl, #gameSoundNull
    ld      (_soundRequest + 0x0000), hl
    ld      (_soundRequest + 0x0002), hl
    ld      (_soundRequest + 0x0004), hl
    
    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; ステージの更新
    call    _StageUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

;   ; ステータスの更新
;   call    GameUpdateStatus

    ; ステージの描画
    call    _StageRender

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; ステータスの描画
    call    GamePrintStatus

    ; ステージの監視
    ld      a, (_stageState)
    or      a
    jr      nz, 19$

    ; 状態の更新
    ld      a, #GAME_STATE_END
    ld      (gameState), a

    ; 監視の完了
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを終了する
;
GameEnd:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; ベストタイムの更新
    ld      a, (_appGame)
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #_appTime
    add     hl, de
    ld      de, #_gameTime
    ld      b, #0x04
00$:
    ld      a, (de)
    cp      (hl)
    jr      c, 02$
    jr      nz, 01$
    inc     hl
    inc     de
    djnz    00$
    jr      02$
01$:
    ld      a, (de)
    ld      (hl), a
    inc     hl
    inc     de
    djnz    01$
02$:

    ; ステージの作成
    ld      a, #STAGE_TYPE_EXTRA
    ld      (_stageType), a
    call    _StageCreate
    
    ; ステージを開く
    ld      a, #STAGE_STATE_OPEN
    ld      (_stageState), a

    ; ジングルの再生
    ld      hl, #gameSoundEnd0
    ld      (_soundRequest + 0x0000), hl
    ld      hl, #gameSoundEnd1
    ld      (_soundRequest + 0x0002), hl
    ld      hl, #gameSoundNull
    ld      (_soundRequest + 0x0004), hl
    
    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; ステージの更新
    call    _StageUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

;   ; エネミーの更新
;   call    _EnemyUpdate

;   ; ステータスの更新
;   call    GameUpdateStatus

    ; ステージの描画
    call    _StageRender

    ; プレイヤの描画
    call    _PlayerRender

;   ; エネミーの描画
;   call    _EnemyRender

    ; ステータスの描画
    call    GamePrintStatus

    ; ステージの監視
    ld      a, (_stageState)
    or      a
    jr      nz, 19$

    ; プレイヤの監視
    ld      hl, #(_player + PLAYER_FLAG)
    ld      a, (hl)
    bit     #PLAYER_FLAG_BIT_PAUSE, a
    jr      z, 10$

    ; プレイヤ停止の解除
    res     #PLAYER_FLAG_BIT_PAUSE, a
    ld      (hl), a

    ; 画面の作成
    call    GamePrintEnd
10$:

    ; サウンドの監視
    ld      hl, (_soundRequest + 0x0000)
    ld      de, (_soundPlay + 0x0000)
    ld      a, h
    or      l
    or      d
    or      e
    jr      nz, 19$

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_appState), a

    ; 監視の完了
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームでミスをする
;
GameMiss:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; プレイヤがミス
    ld      a, #PLAYER_STATE_MISS
    ld      (_player + PLAYER_STATE), a

    ; エネミーを待機させる
    ld      a, #ENEMY_STATE_STAY
    ld      (_enemyState), a

    ; ジングルの再生
    ld      hl, #gameSoundMiss0
    ld      (_soundRequest + 0x0000), hl
    ld      hl, #gameSoundMiss1
    ld      (_soundRequest + 0x0002), hl
    ld      hl, #gameSoundMiss2
    ld      (_soundRequest + 0x0004), hl
    
    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; ステージの更新
    call    _StageUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

;   ; ステータスの更新
;   call    GameUpdateStatus

    ; ステージの描画
    call    _StageRender

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; ステータスの描画
    call    GamePrintStatus

    ; プレイヤの監視
    ld      a, (_player + PLAYER_STATE)
    or      a
    jr      nz, 19$

    ; サウンドの監視
    ld      hl, (_soundRequest + 0x0000)
    ld      de, (_soundPlay + 0x0000)
    ld      a, h
    or      l
    or      d
    or      e
    jr      nz, 19$

    ; 状態の更新
    ld      a, #GAME_STATE_OVER
    ld      (gameState), a

    ; 監視の完了
19$:

    ; レジスタの復帰
    
    ; 終了
    ret
    
; ゲームオーバーになる
;
GameOver:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; 画面の作成
    xor     a
    call    _AppFillPatternName
    ld      hl, #gameOverString
    ld      de, #(_appPatternName + 0x016b)
    ld      bc, #0x000a
    ldir
    call    _AppTransferPatternName

    ; ジングルの再生
    ld      hl, #gameSoundOver0
    ld      (_soundRequest + 0x0000), hl
    ld      hl, #gameSoundOver1
    ld      (_soundRequest + 0x0002), hl
    ld      hl, #gameSoundOver2
    ld      (_soundRequest + 0x0004), hl
    
    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; サウンドの監視
    ld      hl, (_soundRequest + 0x0000)
    ld      de, (_soundPlay + 0x0000)
    ld      a, h
    or      l
    or      d
    or      e
    jr      nz, 19$

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_appState), a
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; ステータスを初期化する
;
GameInitializeStatus:

    ; レジスタの保存

    ; パラメータの初期化
    ld      hl, #_gameCoin
    xor     a
    ld      b, #0x04
10$:
    ld      (hl), a
    inc     hl
    djnz    10$
    ld      hl, #_gameTime
    ld      a, #0x09
    ld      b, #0x04
11$:
    ld      (hl), a
    inc     hl
    djnz    11$

    ; レジスタの復帰
    
    ; 終了
    ret

; ステータスを更新する
;
GameUpdateStatus:

    ; レジスタの保存

    ; タイムの更新
    ld      hl, #_gameTime
    xor     a
    ld      b, #0x04
10$:
    or      (hl)
    inc     hl
    djnz    10$
    or      a
    jr      z, 19$
11$:
    dec     hl
    ld      a, (hl)
    or      a
    jr      z, 12$
    dec     (hl)
    jr      19$
12$:
    ld      a, #0x09
    ld      (hl), a
    jr      11$
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; ステータスを表示する
;
GamePrintStatus:

    ; レジスタの保存

    ; 表示の初期化
    ld      hl, #gameStatusString
    ld      de, #_appPatternName
    ld      bc, #0x0020
    ldir

    ; ゲームの表示
    ld      a, (_appGame)
    add     a, #0x21
    ld      hl, #(_appPatternName + 0x0005)
    ld      (hl), a

    ; コインの表示
    ld      hl, #_gameCoin
    ld      de, #(_appPatternName + 0x000f)
    ld      b, #0x04
10$:
    ld      a, (hl)
    add     a, #0x10
    ld      (de), a
    inc     hl
    inc     de
    djnz    10$

    ; タイムの表示
    ld      hl, #_gameTime
    ld      de, #(_appPatternName + 0x001c)
    ld      b, #0x04
20$:
    ld      a, (hl)
    add     a, #0x10
    ld      (de), a
    inc     hl
    inc     de
    djnz    20$

    ; パターンネームの転送
    ld      hl, #(_appPatternName + 0x0000)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0000)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_DST), hl
    ld      a, #0x40
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)

    ; レジスタの復帰

    ; 終了
    ret

; 終了画面を表示する
;
GamePrintEnd:

    ; レジスタの保存

    ; CONGRATULATIONS!
    ld      hl, #gameEndString0
    ld      de, #(_appPatternName + 0x0108)
    ld      bc, #0x0010
    ldir

    ; YOU GOT 1000 COINS
    ld      hl, #gameEndString1
    ld      de, #(_appPatternName + 0x0147)
    ld      bc, #0x0012
    ldir

    ; スコア
    ld      hl, #(_appPatternName + 0x001a)
    ld      de, #(_appPatternName + 0x01ad)
    ld      bc, #0x0006
    ldir

    ; BEST SCORE!
    ld      a, (_appGame)
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #_appTime
    add     hl, de
    ld      de, #_gameTime
    ld      b, #0x04
10$:
    ld      a, (de)
    cp      (hl)
    jr      nz, 11$
    inc     hl
    inc     de
    djnz    10$
    ld      hl, #gameEndString2
    ld      de, #(_appPatternName + 0x01eb)
    ld      bc, #0x000a
    ldir
11$:

    ; パターンネームの転送
    ld      hl, #(_appPatternName + 0x0100)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0100)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_DST), hl
    xor     a
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
gameProc:
    
    .dw     GameNull
    .dw     GameStart
    .dw     GameOpen
    .dw     GamePlay
    .dw     GameNext
    .dw     GameClear
    .dw     GameEnd
    .dw     GameMiss
    .dw     GameOver

; ゲームの開始
;
gameStartString:

    .db     0x27, 0x25, 0x34, 0x00, 0x11, 0x10, 0x10, 0x10, 0x00, 0x23, 0x2f, 0x29, 0x2e, 0x33

; ゲームの終了
;
gameEndString0:

    .db     0x23, 0x2f, 0x2e, 0x27, 0x32, 0x21, 0x34, 0x35, 0x2c, 0x21, 0x34, 0x29, 0x2f, 0x2e, 0x33, 0x01

gameEndString1:

    .db     0x39, 0x2f, 0x35, 0x00, 0x27, 0x2f, 0x34, 0x00, 0x11, 0x10, 0x10, 0x10, 0x00, 0x23, 0x2f, 0x29
    .db     0x2e, 0x33

gameEndString2:

    .db     0x22, 0x25, 0x33, 0x34, 0x00, 0x34, 0x29, 0x2d, 0x25, 0x01

; ゲームオーバー
;
gameOverString:

    .db     0x27, 0x21, 0x2d, 0x25, 0x00, 0x00, 0x2f, 0x36, 0x25, 0x32

; ステータス
;
gameStatusString:

    .db     0x28, 0x29, 0x27, 0x25, 0x0d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7c, 0x3e, 0x10
    .db     0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3f, 0x00, 0x10, 0x10, 0x10, 0x10

; サウンド
;
gameSoundNull:

    .ascii  "T1"
    .db     0x00

gameSoundBgm0:
    
    .ascii  "T1V15-4L5"
    .ascii  "O4CO5CO3AO4AO3B-O4B-R7R9"
    .ascii  "O4CO5CO3AO4AO3B-O4B-R7R9"
    .ascii  "O3FO4FO3DO4DO3E-O4E-R7R9"
    .ascii  "O3FO4FO3DO4DO3E-O4E-R7R9"
    .ascii  "R7T5L0O4E-DD-T1RL7CE-DO3A-GO4D-"
    .ascii  "L0T5O4CG-E-T1RT5EB-AT1R"
    .ascii  "L1T5O4A-E-O3BT1RT5B-AA-T1R"
    .ascii  "L9RRR"
    .db     0xff

gameSoundBgm1:

    .ascii  "T1V15-4L5"
    .ascii  "O3CO4CO2AO3AO2B-O3B-R7R9"
    .ascii  "O3CO4CO2AO3AO2B-O3B-R7R9"
    .ascii  "O2FO3FO2DO3DO2E-O3E-R7R9"
    .ascii  "O2FO3FO2DO3DO2E-O3E-R7R9"
    .ascii  "R7T5L0O3E-DD-T1RL7CE-DO2A-GO3D-"
    .ascii  "L0T5O3CG-E-T1RT5EB-AT1R"
    .ascii  "L1T5O3A-E-O2BT1RT5B-AA-T1R"
    .ascii  "L9RRR"
    .db     0xff
    
gameSoundEnd0:

    .ascii  "T3V15-4L5"
    .ascii  "T1O3AO4CEGO5CET3GE"
    .ascii  "T1O3A-O4CE-A-O5CE-T3A-E-"
    .ascii  "T1O3B-O4DFB-O5DFT3B-T1B-B-B-"
    .ascii  "L7T3O6CR"
    .ascii  "L9RR"
    .db     0x00
    
gameSoundEnd1:

    .ascii  "T3V15-4"
    .ascii  "T1O3GEGCEGT3O4EC"
    .ascii  "T1O3A-E-A-CE-A-T3O4E-C"
    .ascii  "T1O3B-FB-DFB-T3O4FT1DDD"
    .ascii  "L7T3O4ER"
    .ascii  "L9RR"
    .db     0x00
    
gameSoundMiss0:
    
    .ascii  "T2V15-4"
    .ascii  "L0O5CC+D1R3R5"
    .ascii  "L3O4BO5FRFT5F1E1D1T2R0CO4ERECRR5"
    .db     0x00

gameSoundMiss1:

    .ascii  "T2V15-4"
    .ascii  "R7"
    .ascii  "L3O4GO5DRDT5D1C1O4B1T2R0GERECRR5"
    .db     0x00

gameSoundMiss2:

    .ascii  "T2V15-4"
    .ascii  "R7"
    .ascii  "L3O3GRRGT5G1A1B1T2R0O4CRO3GRCRR5"
    .db     0x00

gameSoundOver0:

    .ascii  "T2V15-4"
    .ascii  "L3O5CRRO4GR5E5T5A1B1A1T2R0L5A-B-A-G8"
    .ascii  "R9"
    .db     0x00

gameSoundOver1:

    .ascii  "T2V15-4"
    .ascii  "L3O4ERRCR5O3G5O4F7F8EDE7"
    .ascii  "R9"
    .db     0x00

gameSoundOver2:

    .ascii  "T2V15-4"
    .ascii  "L3O3GRRDR5O2B5O3F7D-8C8"
    .ascii  "R9"
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

; カウンタ
;
gameCount:

    .ds     1

; コイン
;
_gameCoin::

    .ds     0x04

; タイム
;
_gameTime::

    .ds     0x04
