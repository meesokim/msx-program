; Game.s : ゲーム画面
;



; モジュール宣言
;
    .module Game


; 参照ファイル
;
    .include    "bios.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include    "Back.inc"
    .include    "Game.inc"
    .include    "GameShip.inc"
    .include    "GameShot.inc"
    .include    "GameEnemy.inc"
    .include    "GameBullet.inc"



; CODE 領域
;
    .area   _CODE


; ゲームを更新する
;
_GameUpdate::
    
    ; 状態の取得
    ld      a, (_appState)
    
    ; 初期化
    cp      #GAME_STATE_INITIALIZE
    jr      nz, 00$
    call    GameInitialize
    jr      GameUpdateDone
00$:
    
    ; ロード
    cp      #GAME_STATE_LOAD
    jr      nz, 01$
    call    GameLoad
    jr      GameUpdateDone
01$:
    
    ; 開始
    cp      #GAME_STATE_START
    jr      nz, 02$
    call    GameStart
    jr      GameUpdateDone
02$:
    
    ; プレイ
    cp      #GAME_STATE_PLAY
    jr      nz, 03$
    call    GamePlay
    jr      GameUpdateDone
03$:
    
    ; タイムアップ
    cp      #GAME_STATE_TIMEUP
    jr      nz, 04$
    call    GameTimeUp
    jr      GameUpdateDone
04$:
    
    ; オーバー
    cp      #GAME_STATE_OVER
    jr      nz, 05$
    call    GameOver
    jr      GameUpdateDone
05$:
    
    ; ハイスコア
    cp      #GAME_STATE_HISCORE
    jr      nz, 06$
    call    GameHiscore
    jr      GameUpdateDone
06$:
    
    ; アンロード
    cp      #GAME_STATE_UNLOAD
    jr      nz, 07$
    call    GameUnload
    jr      GameUpdateDone
07$:
    
    ; 終了
    call    GameEnd
    
    ; 更新の完了
GameUpdateDone:
    
    ; 一時停止
    ld      a, (_gameFlag)
    bit     #GAME_FLAG_PAUSE, a
    jr      nz, GameUpdateEnd
    
    ; 背景の更新
    call    _BackUpdate
    
    ; 自機の更新
    call    _GameShipUpdate
    
    ; ショットの更新
    call    _GameShotUpdate
    
    ; 敵の更新
    call    _GameEnemyUpdate
    
    ; 弾の更新
    call    _GameBulletUpdate
    
    ; ステータスの更新
    ld      a, (_gameFlag)
    bit     #GAME_FLAG_STATUS, a
    jr      z, 10$
    call    _BackTransferStatus
10$:
    
    ; 更新の終了
GameUpdateEnd:
    
    ; 終了
    ret


; ゲームを初期化する
;
GameInitialize:
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; 演奏の停止
    ld      hl, #mmlNull
    ld      (_soundRequest + 0), hl
    ld      (_soundRequest + 2), hl
    ld      (_soundRequest + 4), hl
    ld      (_soundRequest + 6), hl
    
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
    ld      a, #0x03
    ld      0(ix), a
    xor     a
    ld      1(ix), a
    ld      2(ix), a
    ld      3(ix), a
    
    ; 自機の初期化
    call    _GameShipInitialize
    
    ; ショットの初期化
    call    _GameShotInitialize
    
    ; 敵の初期化
    call    _GameEnemyInitialize
    
    ; 弾の初期化
    call    _GameBulletInitialize
    
    ; フラグの初期化
    xor     a
    ld      (_gameFlag), a
    
    ; 倒した数の初期化
    xor     a
    ld      (_gameShootDown), a
    
    ; 状態の更新
    ld      a, #GAME_STATE_LOAD
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; 終了
    ret


; ゲームをロードする
;
GameLoad:
    
    ; 状態の取得
    ld      a, (_appPhase)
    or      a
    jr      nz, GameLoadMain
    
    ; フラグの設定
    ld      hl, #_gameFlag
    set     #GAME_FLAG_STATUS, (hl)
    
    ; 状態の更新
    ld      hl, #_appPhase
    inc     (hl)
    jr      GameLoadEnd
    
    ; ロードの処理
GameLoadMain:
    
    ; 状態の更新
    ld      a, #GAME_STATE_START
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; 読み込みの終了
GameLoadEnd:
    
    ; 終了
    ret


; ゲームを開始する
;
GameStart:
    
    ; 状態の取得
    ld      a, (_appPhase)
    or      a
    jr      nz, GameStartMain
    
    ; メッセージのロード
    ld      a, #BACK_MESSAGE_START
    call    _BackStoreMessage
    
    ; 演奏の開始
    ld      hl, #mmlStartChannel0
    ld      (_soundRequest + 0), hl
    ld      hl, #mmlStartChannel1
    ld      (_soundRequest + 2), hl
    ld      hl, #mmlStartChannel2
    ld      (_soundRequest + 4), hl
    
    ; フラグの設定
    ld      hl, #_gameFlag
    res     #GAME_FLAG_PLAYABLE, (hl)
    res     #GAME_FLAG_PAUSE, (hl)
    res     #GAME_FLAG_STATUS, (hl)
    
    ; 状態の更新
    ld      hl, #_appPhase
    inc     (hl)
    
    ; 開始の処理
GameStartMain:
    
    ; 演奏の終了
    ld      hl, (_soundRequest + 0)
    ld      a, h
    or      l
    ld      hl, (_soundPlay + 0)
    or      h
    or      l
    jr      nz, GameStartEnd
    
    ; メッセージのアンロード
    call    _BackRestoreMessage
    
    ; 状態の更新
    ld      a, #GAME_STATE_PLAY
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; 開始の終了
GameStartEnd:
    
    ; 終了
    ret


; ゲームをプレイする
;
GamePlay:
    
    ; 状態の取得
    ld      a, (_appPhase)
    or      a
    jr      nz, GamePlayMain
    
    ; フラグの設定
    ld      hl, #_gameFlag
    res     #GAME_FLAG_PAUSE, (hl)
    set     #GAME_FLAG_PLAYABLE, (hl)
    set     #GAME_FLAG_STATUS, (hl)
    
    ; 状態の更新
    ld      hl, #_appPhase
    inc     (hl)
    
    ; プレイの処理
GamePlayMain:
    
    ; START ボタンが押された
    ld      a, (_input + INPUT_BUTTON_ESC)
    cp      #0x01
    jr      nz, 00$
    ld      hl, #_flag
    ld      a, #(1 << FLAG_SOUND_SLEEP)
    xor     (hl)
    ld      (hl), a
    ld      hl, #_gameFlag
    ld      a, #(1 << GAME_FLAG_PAUSE)
    xor     (hl)
    ld      (hl), a
00$:
    
    ; 一時停止
    ld      hl, #_gameFlag
    bit     #GAME_FLAG_PAUSE, (hl)
    jp      nz, GamePlayEnd
    
    ; タイマの更新
    ld      ix, #_appTimer
    ld      a, 0(ix)
    or      1(ix)
    or      2(ix)
    or      3(ix)
    jr      z, 10$
    dec     3(ix)
    jp      p, 10$
    ld      a, #0x09
    ld      3(ix), a
    dec     2(ix)
    jp      p, 10$
    ld      a, #0x09
    ld      2(ix), a
    dec     1(ix)
    jp      p, 10$
    ld      a, #0x09
    ld      1(ix), a
    dec     0(ix)
    jp      p, 10$
    xor     a
    ld      0(ix), a
10$:
    
    ; 倒した数の設定
    xor     a
    ld      (_gameShootDown), a
    
    ; ショットと敵のヒットチェック
    call    GameCheckShotEnemy
    
    ; 自機と弾のヒットチェック
    call    GameCheckShipBullet
    
    ; 自機と敵のヒットチェック
    call    GameCheckShipEnemy
    
    ; スコアの倍率の更新
    ld      ix, #_appRate
    ld      a, (_gameShootDown)
    or      a
    jr      z, 20$
    add     a, 1(ix)
    ld      1(ix), a
    sub     #0x0a
    jr      c, 22$
    ld      1(ix), a
    inc     0(ix)
    ld      a, 0(ix)
    cp      #0x0a
    jr      c, 22$
    ld      a, #0x09
    ld      0(ix), a
    ld      1(ix), a
    ld      2(ix), a
    jr      22$
20$:
    ld      a, 0(ix)
    or      2(ix)
    or      3(ix)
    jr      nz, 21$
    ld      a, 1(ix)
    cp      #0x01
    jr      z, 22$
21$:
    dec     3(ix)
    jp      p, 22$
    ld      a, #0x01
    ld      3(ix), a
    dec     2(ix)
    jp      p, 22$
    ld      a, #0x09
    ld      2(ix), a
    dec     1(ix)
    jp      p, 22$
    ld      a, #0x09
    ld      1(ix), a
    dec     0(ix)
22$:
    
    ; スコアの更新
    ld      a, (_gameShootDown)
    or      a
    jr      z, 34$
    ld      ix, #_appScore
    ld      iy, #_appRate
    ld      b, a
30$:
    ld      a, 2(iy)
    add     a, 5(ix)
    ld      5(ix), a
    sub     #0x0a
    jr      c, 31$
    ld      5(ix), a
31$:
    ld      a, 1(iy)
    ccf
    adc     a, 4(ix)
    ld      4(ix), a
    sub     #0x0a
    jr      c, 32$
    ld      4(ix), a
32$:
    ld      a, 0(iy)
    ccf
    adc     a, 3(ix)
    ld      3(ix), a
    sub     #0x0a
    jr      c, 33$
    ld      3(ix), a
    inc     2(ix)
    ld      a, 2(ix)
    sub     #0x0a
    jr      c, 33$
    ld      2(ix), a
    inc     1(ix)
    ld      a, 1(ix)
    sub     #0x0a
    jr      c, 33$
    ld      1(ix), a
    inc     0(ix)
    ld      a, 0(ix)
    sub     #0x0a
    jr      c, 33$
    ld      a, #0x09
    ld      0(ix), a
    ld      1(ix), a
    ld      2(ix), a
    ld      3(ix), a
    ld      4(ix), a
    ld      5(ix), a
33$:
    djnz    30$
34$:
    
    ; タイムアップ
    ld      ix, #_appTimer
    ld      a, 0(ix)
    or      1(ix)
    or      2(ix)
    or      3(ix)
    jr      nz, GamePlayEnd
    
    ; 状態の更新
    ld      a, #GAME_STATE_TIMEUP
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; プレイの終了
GamePlayEnd:
    
    ; 終了
    ret


; ゲームがタイムアップする
;
GameTimeUp:
    
    ; 状態の取得
    ld      a, (_appPhase)
    or      a
    jr      nz, GameTimeUpMain
    
    ; メッセージのロード
    ld      a, #BACK_MESSAGE_TIMEUP
    call    _BackStoreMessage
    
    ; カウントの設定
    ld      a, #180
    ld      (gameCount), a
    
    ; フラグの設定
    ld      hl, #_gameFlag
    res     #GAME_FLAG_PLAYABLE, (hl)
    res     #GAME_FLAG_PAUSE, (hl)
    res     #GAME_FLAG_STATUS, (hl)
    
    ; 状態の更新
    ld      hl, #_appPhase
    inc     (hl)
    
    ; タイムアップの処理
GameTimeUpMain:
    
    ; カウントの更新
    ld      hl, #gameCount
    dec     (hl)
    jp      nz, GameTimeUpEnd
    
    ; ハイスコアを更新したかどうか
    ld      ix, #_appHiscore
    ld      iy, #_appScore
    ld      a, 0(iy)
    cp      0(ix)
    jr      c, GameTimeUpOver
    jr      nz, GameTimeUpHiscore
    ld      a, 1(iy)
    cp      1(ix)
    jr      c, GameTimeUpOver
    jr      nz, GameTimeUpHiscore
    ld      a, 2(iy)
    cp      2(ix)
    jr      c, GameTimeUpOver
    jr      nz, GameTimeUpHiscore
    ld      a, 3(iy)
    cp      3(ix)
    jr      c, GameTimeUpOver
    jr      nz, GameTimeUpHiscore
    ld      a, 4(iy)
    cp      4(ix)
    jr      c, GameTimeUpOver
    jr      nz, GameTimeUpHiscore
    ld      a, 5(iy)
    cp      5(ix)
    jr      c, GameTimeUpOver
    jr      nz, GameTimeUpHiscore
    
    ; ゲームオーバー
GameTimeUpOver:
    
    ; 状態の更新
    ld      a, #GAME_STATE_OVER
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    jr      GameTimeUpEnd
    
    ; ハイスコア
GameTimeUpHiscore:
    
    ; ハイスコアの更新
    ld      a, 0(iy)
    ld      0(ix), a
    ld      a, 1(iy)
    ld      1(ix), a
    ld      a, 2(iy)
    ld      2(ix), a
    ld      a, 3(iy)
    ld      3(ix), a
    ld      a, 4(iy)
    ld      4(ix), a
    ld      a, 5(iy)
    ld      5(ix), a
    call    _BackTransferHiscore
    
    ; 状態の更新
    ld      a, #GAME_STATE_HISCORE
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; タイムアップの終了
GameTimeUpEnd:
    
    ; 終了
    ret


; ゲームオーバーになる
;
GameOver:
    
    ; 状態の取得
    ld      a, (_appPhase)
    or      a
    jr      nz, GameOverMain
    
    ; メッセージのロード
    ld      a, #BACK_MESSAGE_GAMEOVER
    call    _BackStoreMessage
    
    ; カウントの設定
    ld      a, #180
    ld      (gameCount), a
    
    ; フラグの設定
    ld      hl, #_gameFlag
    res     #GAME_FLAG_PLAYABLE, (hl)
    res     #GAME_FLAG_PAUSE, (hl)
    res     #GAME_FLAG_STATUS, (hl)
    
    ; 状態の更新
    ld      hl, #_appPhase
    inc     (hl)
    
    ; オーバーの処理
GameOverMain:
    
    ; カウントの更新
    ld      hl, #gameCount
    dec     (hl)
    jr      nz, GameOverEnd
    
    ; メッセージのアンロード
    call    _BackRestoreMessage
    
    ; 状態の更新
    ld      a, #GAME_STATE_UNLOAD
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; オーバーの終了
GameOverEnd:
    
    ; 終了
    ret


; ハイスコアを更新する
;
GameHiscore:
    
    ; 状態の取得
    ld      a, (_appPhase)
    or      a
    jr      nz, GameHiscoreMain
    
    ; メッセージのロード
    ld      a, #BACK_MESSAGE_HISCORE
    call    _BackStoreMessage
    
    ; 演奏の開始
    ld      hl, #mmlHiScoreChannel0
    ld      (_soundRequest + 0), hl
    ld      hl, #mmlHiScoreChannel1
    ld      (_soundRequest + 2), hl
    ld      hl, #mmlHiScoreChannel2
    ld      (_soundRequest + 4), hl
    
    ; フラグの設定
    ld      hl, #_gameFlag
    res     #GAME_FLAG_PLAYABLE, (hl)
    res     #GAME_FLAG_PAUSE, (hl)
    res     #GAME_FLAG_STATUS, (hl)
    
    ; 状態の更新
    ld      hl, #_appPhase
    inc     (hl)
    
    ; ハイスコアの処理
GameHiscoreMain:
    
    ; 演奏の終了
    ld      hl, (_soundRequest + 0)
    ld      a, h
    or      l
    ld      hl, (_soundPlay + 0)
    or      h
    or      l
    jr      nz, GameHiscoreEnd
    
    ; メッセージのアンロード
    call    _BackRestoreMessage
    
    ; 状態の更新
    ld      a, #GAME_STATE_UNLOAD
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; ハイスコアの終了
GameHiscoreEnd:
    
    ; 終了
    ret


; ゲームをアンロードする
;
GameUnload:
    
    ; 状態の取得
    ld      a, (_appPhase)
    or      a
    jr      nz, GameUnloadMain
    
    ; フラグの設定
    xor     a
    ld      (_gameFlag), a
    
    ; 状態の更新
    ld      hl, #_appPhase
    inc     (hl)
    
    ; アンロードの処理
GameUnloadMain:
    
    ; 状態の更新
    ld      a, #GAME_STATE_END
    ld      (_appState), a
    ld      a, #APP_PHASE_NULL
    ld      (_appPhase), a
    
    ; アンロードの終了
GameUnloadEnd:
    
    ; 終了
    ret


; ゲームを終了する
;
GameEnd:
    
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


; ショットと敵のヒットチェックを行う
;
GameCheckShotEnemy:
    
    ; ショットの走査
    ld      iy, #_gameShot
    ld      c, #GAME_SHOT_SIZE
0$:
    
    ; ショットの存在
    ld      a, GAME_SHOT_PARAM_STATE(iy)
    cp      #GAME_SHOT_STATE_NULL
    jr      z, 9$
    
    ; 敵の走査
    ld      ix, #_gameEnemy
    ld      b, #GAME_ENEMY_SIZE
1$:
    
    ; 敵の存在
    ld      a, GAME_ENEMY_PARAM_NODAMAGE(ix)
    or      a
    jr      nz, 8$
    
    ; ヒットチェック
    ld      a, GAME_ENEMY_PARAM_POINT_XI(ix)
    sub     GAME_SHOT_PARAM_POINT_X(iy)
    cp      #0x08
    jr      c, 2$
    cp      #0xf9
    jr      c, 8$
2$:
    ld      a, GAME_ENEMY_PARAM_POINT_YI(ix)
    sub     GAME_SHOT_PARAM_POINT_Y(iy)
    cp      #0x0b
    jr      c, 3$
    cp      #0xf6
    jr      c, 8$
3$:
    
    ; 倒した数の更新
    ld      hl, #_gameShootDown
    inc     (hl)
    
    ; 敵のノーダメージの更新
    ld      a, #0x80
    ld      GAME_ENEMY_PARAM_NODAMAGE(ix), a
    
    ; 敵の状態の更新
    ld      a, #GAME_ENEMY_STATE_BOMB
    ld      GAME_ENEMY_PARAM_STATE(ix), a
    ld      a, #APP_PHASE_NULL
    ld      GAME_ENEMY_PARAM_PHASE(ix), a
    
    ; 敵の撃ち返し
    call    GameShootBack
    
    ; ショットの状態の更新
    ld      a, #GAME_SHOT_STATE_NULL
    ld      GAME_SHOT_PARAM_STATE(iy), a
    ld      a, #APP_PHASE_NULL
    ld      GAME_SHOT_PARAM_PHASE(iy), a
    
    ; 敵の走査の完了
8$:
    ld      de, #GAME_ENEMY_PARAM_SIZE
    add     ix, de
    djnz    1$
    
    ; ショットの走査の完了
9$:
    ld      de, #GAME_SHOT_PARAM_SIZE
    add     iy, de
    dec     c
    jr      nz, 0$
    
    ; 処理の終了
GameCheckShotEnemyEnd:
    
    ; 終了
    ret


; 自機と弾のヒットチェックを行う
;
GameCheckShipBullet:
    
    ; 自機の存在
    ld      iy, #_gameShip
    ld      a, GAME_SHIP_PARAM_NODAMAGE(iy)
    or      a
    jr      nz, GameCheckShipBulletEnd
    
    ; 弾の走査
    ld      ix, #_gameBullet
    ld      de, #GAME_BULLET_PARAM_SIZE
    ld      b, #GAME_BULLET_SIZE
0$:
    
    ; 弾の存在
    ld      a, GAME_BULLET_PARAM_STATE(ix)
    cp      #GAME_BULLET_STATE_NULL
    jr      z, 9$
    
    ; ヒットチェック
    ld      a, GAME_BULLET_PARAM_POINT_XI(ix)
    sub     GAME_SHIP_PARAM_POINT_X(iy)
    jr      nc, 1$
    neg
1$:
    cp      #0x06
    jr      nc, 9$
    ; ld      c, a
    ld      a, GAME_BULLET_PARAM_POINT_YI(ix)
    sub     GAME_SHIP_PARAM_POINT_Y(iy)
    jr      nc, 2$
    neg
2$:
    cp      #0x06
    jr      nc, 9$
    ; add     a, c
    ; cp      #0x06
    ; jr      nc, 9$
    
    ; 弾の状態の更新
    ld      a, #GAME_BULLET_STATE_NULL
    ld      GAME_BULLET_PARAM_STATE(ix), a
    ld      a, #APP_PHASE_NULL
    ld      GAME_BULLET_PARAM_PHASE(ix), a
    
    ; 自機の状態の更新
    ld      a, #GAME_SHIP_STATE_BOMB
    ld      GAME_SHIP_PARAM_STATE(iy), a
    ld      a, #APP_PHASE_NULL
    ld      GAME_SHIP_PARAM_PHASE(iy), a
    
    ; 弾の走査の完了
9$:
    add     ix, de
    djnz    0$
    
    ; 処理の終了
GameCheckShipBulletEnd:
    
    ; 終了
    ret


; 自機と敵のヒットチェックを行う
;
GameCheckShipEnemy:
    
    ; 自機の存在
    ld      iy, #_gameShip
    ld      a, GAME_SHIP_PARAM_NODAMAGE(iy)
    or      a
    jr      nz, GameCheckShipEnemyEnd
    
    ; 敵の走査
    ld      ix, #_gameEnemy
    ld      de, #GAME_ENEMY_PARAM_SIZE
    ld      b, #GAME_ENEMY_SIZE
0$:
    
    ; 敵の存在
    ld      a, GAME_ENEMY_PARAM_NODAMAGE(ix)
    or      a
    jr      nz, 9$
    
    ; ヒットチェック
    ld      a, GAME_ENEMY_PARAM_POINT_XI(ix)
    sub     GAME_SHIP_PARAM_POINT_X(iy)
    jr      nc, 1$
    neg
1$:
    cp      #0x08
    jr      nc, 9$
    ; ld      c, a
    ld      a, GAME_ENEMY_PARAM_POINT_YI(ix)
    sub     GAME_SHIP_PARAM_POINT_Y(iy)
    jr      nc, 2$
    neg
2$:
    cp      #0x08
    jr      nc, 9$
    ; add     a, c
    ; cp      #0x08
    ; jr      nc, 9$
    
    ; 倒した数の更新
    ld      hl, #_gameShootDown
    inc     (hl)
    
    ; 敵のノーダメージの更新
    ld      a, #0x80
    ld      GAME_ENEMY_PARAM_NODAMAGE(ix), a
    
    ; 敵の状態の更新
    ld      a, #GAME_ENEMY_STATE_BOMB
    ld      GAME_ENEMY_PARAM_STATE(ix), a
    ld      a, #APP_PHASE_NULL
    ld      GAME_ENEMY_PARAM_PHASE(ix), a
    
    ; 自機の状態の更新
    ld      a, #GAME_SHIP_STATE_BOMB
    ld      GAME_SHIP_PARAM_STATE(iy), a
    ld      a, #APP_PHASE_NULL
    ld      GAME_SHIP_PARAM_PHASE(iy), a
    
    ; 敵の走査の完了
9$:
    add     ix, de
    djnz    0$
    
    ; 処理の終了
GameCheckShipEnemyEnd:
    
    ; 終了
    ret


; 敵が弾を打ち返す
;
GameShootBack:
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    iy
    
    ; 敵が自機に近い場合は撃ち返さない
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_Y)
    sub     #0x20
    cp      GAME_ENEMY_PARAM_POINT_YI(ix)
    jr      nc, 00$
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_X)
    sub     #0x18
    cp      GAME_ENEMY_PARAM_POINT_XI(ix)
    jr      nc, 00$
    add     #0x30
    cp      GAME_ENEMY_PARAM_POINT_XI(ix)
    jp      nc, GameShootBackEnd
00$:
    
    ; ベクトルの取得
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_X)
    sub     GAME_ENEMY_PARAM_POINT_XI(ix)
    ld      h, a
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_Y)
    sub     GAME_ENEMY_PARAM_POINT_YI(ix)
    ld      l, a
    
    ; 必ず下向きに撃ち返す
    bit     #0x07, a
    jr      z, 10$
    sra     h
    srl     l
10$:
    
    ; 方向の取得
    call    _SystemGetAtan2
    ld      (gameBackAngle), a
    
    ; 弾のエントリの取得
    ld      iy, #_gameBulletEntry
    
    ; 弾の位置の設定
    ld      a, GAME_ENEMY_PARAM_POINT_XD(ix)
    ld      GAME_BULLET_PARAM_POINT_XD(iy), a
    ld      a, GAME_ENEMY_PARAM_POINT_XI(ix)
    ld      GAME_BULLET_PARAM_POINT_XI(iy), a
    ld      a, GAME_ENEMY_PARAM_POINT_YD(ix)
    ld      GAME_BULLET_PARAM_POINT_YD(iy), a
    ld      a, GAME_ENEMY_PARAM_POINT_YI(ix)
    ld      GAME_BULLET_PARAM_POINT_YI(iy), a
    
    ; 弾のエントリ
    ld      bc, #0x0500
20$:
    ld      hl, #backTypeTable
    ld      e, c
    ld      d, #0x00
    add     hl, de
    ld      a, (hl)
    ld      GAME_BULLET_PARAM_SPRITE_SRC_L(iy), a
    ld      hl, #backAngleTable
    add     hl, de
    ld      a, (gameBackAngle)
    add     a, (hl)
    push    af
    call    _SystemGetCos
    ld      (gameBackCos), hl
    pop     af
    call    _SystemGetSin
    ld      (gameBackSin), hl
    xor     a
    ld      GAME_BULLET_PARAM_SPEED_XD(iy), a
    ld      GAME_BULLET_PARAM_SPEED_XI(iy), a
    ld      GAME_BULLET_PARAM_SPEED_YD(iy), a
    ld      GAME_BULLET_PARAM_SPEED_YI(iy), a
    ld      hl, #backSpeedTable
    add     hl, de
    add     hl, de
    ld      a, (_appTimer + 0)
    sla     a
    sla     a
    sla     a
    sla     a
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      d, (hl)
    inc     hl
    ld      e, (hl)
    ld      a, d
    or      a
    jr      z, 22$
21$:
    ld      a, (gameBackCos + 0)
    add     a, GAME_BULLET_PARAM_SPEED_XD(iy)
    ld      GAME_BULLET_PARAM_SPEED_XD(iy), a
    ld      a, (gameBackCos + 1)
    adc     a, GAME_BULLET_PARAM_SPEED_XI(iy)
    ld      GAME_BULLET_PARAM_SPEED_XI(iy), a
    ld      a, (gameBackSin + 0)
    add     a, GAME_BULLET_PARAM_SPEED_YD(iy)
    ld      GAME_BULLET_PARAM_SPEED_YD(iy), a
    ld      a, (gameBackSin + 1)
    adc     a, GAME_BULLET_PARAM_SPEED_YI(iy)
    ld      GAME_BULLET_PARAM_SPEED_YI(iy), a
    dec     d
    jr      nz, 21$
22$:
    ld      a, e
    or      a
    jr      z, 24$
    ld      hl, (gameBackCos)
    sra     h
    rr      l
    ld      (gameBackCos), hl
    ld      hl, (gameBackSin)
    sra     h
    rr      l
    ld      (gameBackSin), hl
23$:
    ld      a, (gameBackCos + 0)
    add     a, GAME_BULLET_PARAM_SPEED_XD(iy)
    ld      GAME_BULLET_PARAM_SPEED_XD(iy), a
    ld      a, (gameBackCos + 1)
    adc     a, GAME_BULLET_PARAM_SPEED_XI(iy)
    ld      GAME_BULLET_PARAM_SPEED_XI(iy), a
    ld      a, (gameBackSin + 0)
    add     a, GAME_BULLET_PARAM_SPEED_YD(iy)
    ld      GAME_BULLET_PARAM_SPEED_YD(iy), a
    ld      a, (gameBackSin + 1)
    adc     a, GAME_BULLET_PARAM_SPEED_YI(iy)
    ld      GAME_BULLET_PARAM_SPEED_YI(iy), a
    dec     e
    jr      nz, 23$
24$:
    call    _GameBulletEntry
    inc     c
    dec     b
    jp      nz, 20$
    
    ; 処理の終了
GameShootBackEnd:
    
    ; レジスタの復帰
    pop     iy
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret


; 定数の定義
;

; 撃ち返しデータ
;
backTypeTable:
    
    .db     0x00, 0x01, 0x01, 0x00, 0x00

backAngleTable:
    
    .db     0x00, 0x0c, 0xf4, 0x18, 0xe8

backSpeedTable:
    
;    .db     0x03, 0x00, 0x02, 0x01, 0x02, 0x01, 0x03, 0x00, 0x03, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db     0x02, 0x01, 0x02, 0x00, 0x02, 0x00, 0x02, 0x01, 0x02, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db     0x02, 0x00, 0x01, 0x01, 0x01, 0x01, 0x02, 0x00, 0x02, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db     0x01, 0x01, 0x01, 0x00, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .db     0x01, 0x01, 0x01, 0x00, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff


; MML データ
;
mmlNull:
    
    .db     0x00

mmlStartChannel0:
    
    .ascii  "T1S0M12V16"
    .ascii  "L0O6CO5BAGFEDCO4BAG"
    .ascii  "L3O3GO4CO3GO4CECEGEGO5C5R5"
    .ascii  "L3O3GO4CO3GO4CECEGEGO5C5R5"
    .ascii  "L1O4E3DD#DD#DD#DD#DD#DD#DD#DD#"
    .ascii  "L0O4CDEFGABO5C"
    .ascii  "L0O4CDEFGABO5C"
    .ascii  "L0O4CDEFGABO5C"
    .ascii  "R5"
    .db     0x00

mmlStartChannel1:
    
    .ascii  "T1V16"
    .ascii  "L0RRRRRRRRRRR"
    .ascii  "L5RRRRRRR"
    .ascii  "L5RRRRRRR"
    .ascii  "L3RRRRRRRRR"
    .ascii  "L0RRRRRRRR"
    .ascii  "L0RRRRRRRR"
    .ascii  "L0RRRRRRRR"
    .ascii  "R5"
    .db     0x00

mmlStartChannel2:
    
    .ascii  "T1V16"
    .ascii  "L0RRRRRRRRRRR"
    .ascii  "L5RRRRRRR"
    .ascii  "L5RRRRRRR"
    .ascii  "L3RRRRRRRRR"
    .ascii  "L0RRRRRRRR"
    .ascii  "L0RRRRRRRR"
    .ascii  "L0RRRRRRRR"
    .ascii  "R5"
    .db     0x00

mmlHiScoreChannel0:
    
    .ascii  "T2S0M12V16L3"
    .ascii  "O5D5RDD#FG6"
    .ascii  "R9"
    .db     0x00

mmlHiScoreChannel1:
    
    .ascii  "T2V16L3"
    .ascii  "O4A5RAA#O5CD6"
    .ascii  "R9"
    .db     0x00

mmlHiScoreChannel2:
    
    .ascii  "T2V16L3"
    .ascii  "O4F#5RF#GAB6"
    .ascii  "R9"
    .db     0x00



; DATA 領域
;
    .area   _DATA


; 変数の定義
;

; フラグ
;
_gameFlag::
    
    .ds     1

; 倒した数
;
_gameShootDown::
    
    .ds     1

; カウント
;
gameCount:
    
    .ds     1

; 撃ち返し
;
gameBackAngle:
    
    .ds     1

gameBackCos:
    
    .ds     2

gameBackSin:
    
    .ds     2


