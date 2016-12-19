; GameShip.s : ゲーム画面／自機
;



; モジュール宣言
;
    .module Game


; 参照ファイル
;
    .include    "bios.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include    "Game.inc"
    .include    "GameShip.inc"
    .include    "GameShot.inc"



; CODE 領域
;
    .area   _CODE


; 自機を初期化する
;
_GameShipInitialize::
    
    ; 状態の設定
    ld      a, #GAME_SHIP_STATE_PLAY
    ld      (_gameShip + GAME_SHIP_PARAM_STATE), a
    xor     a
    ld      (_gameShip + GAME_SHIP_PARAM_PHASE), a
    
    ; 終了
    ret


; 自機を更新する
;
_GameShipUpdate::
    
    ; 状態の取得
    ld      a, (_gameShip + GAME_SHIP_PARAM_STATE)
    
    ; なし
    cp      #GAME_SHIP_STATE_NULL
    jr      nz, 0$
    call    GameShipNull
    jr      GameUpdateEnd
0$:
    
    ; 操作
    cp      #GAME_SHIP_STATE_PLAY
    jr      nz, 1$
    call    GameShipPlay
    jr      GameUpdateEnd
1$:
    
    ; 爆発
    cp      #GAME_SHIP_STATE_BOMB
    jr      nz, 2$
    call    GameShipBomb
    jr      GameUpdateEnd
2$:
    
    ; 更新の終了
GameUpdateEnd:
    
    ; 終了
    ret


; 自機はなし
;
GameShipNull:
    
    ; 状態の取得
    ld      a, (_gameShip + GAME_SHIP_PARAM_PHASE)
    or      a
    jr      nz, GameShipNullMain
    
    ; ノーダメージの設定
    ld      a, #0x80
    ld      (_gameShip + GAME_SHIP_PARAM_NODAMAGE), a
    
    ; 状態の更新
    ld      hl, (_gameShip + GAME_SHIP_PARAM_PHASE)
    inc     (hl)
    
    ; 待機の処理
GameShipNullMain:
    
    ; 処理の完了
GameShipNullDone:
    
    ; 描画の開始
    ld      a, #0xc0
    ld      (_sprite + GAME_SPRITE_SHIP + 0x00), a
    ld      (_sprite + GAME_SPRITE_SHIP + 0x01), a
    ld      (_sprite + GAME_SPRITE_SHIP + 0x02), a
    ld      (_sprite + GAME_SPRITE_SHIP + 0x03), a
    
    ; 処理の終了
GameShipNullEnd:
    
    ; 終了
    ret


; 自機を操作する
;
GameShipPlay:
    
    ; 状態の取得
    ld      a, (_gameShip + GAME_SHIP_PARAM_PHASE)
    or      a
    jr      nz, GameShipPlayMain
    
    ; 位置の設定
    ld      a, #0x60
    ld      (_gameShip + GAME_SHIP_PARAM_POINT_X), a
    ld      a, #0xc8
    ld      (_gameShip + GAME_SHIP_PARAM_POINT_Y), a
    
    ; ノーダメージの設定
    ld      a, #0x80
    ld      (_gameShip + GAME_SHIP_PARAM_NODAMAGE), a
    
    ; 状態の更新
    ld      hl, #(_gameShip + GAME_SHIP_PARAM_PHASE)
    inc     (hl)
    
    ; 待機処理
GameShipPlayMain:
    
    ; ノーダメージの更新
    ld      hl, #(_gameShip + GAME_SHIP_PARAM_NODAMAGE)
    ld      a, (hl)
    or      a
    jr      z, 00$
    dec     (hl)
00$:
    
    ; 自機を定位置に移動
    ld      hl, #(_gameShip + GAME_SHIP_PARAM_POINT_Y)
    ld      a, (hl)
    cp      #0xb1
    jr      c, GameShipPlayMove
    dec     (hl)
    jr      GameShipPlayDone
    
    ; 移動処理
GameShipPlayMove:
    
    ; 操作可能かどうか
    ld      hl, #_gameFlag
    bit     #GAME_FLAG_PLAYABLE, (hl)
    jr      z, GameShipPlayDone
    
    ; Ｘ方向の移動
    ld      hl, #(_gameShip + GAME_SHIP_PARAM_POINT_X)
    
    ; ←が押された
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 10$
    ld      a, (hl)
    cp      #(0x08 + 2)
    jr      c, 10$
    dec     (hl)
    dec     (hl)
    jr      GameShipPlayShot
10$:
    
    ; →が押された
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 11$
    ld      a, (hl)
    cp      #(0xb8 - 0)
    jr      nc, 11$
    inc     (hl)
    inc     (hl)
11$:
    
    ; 発射処理
GameShipPlayShot:
    
    ; A ボタンが押された
    ld      a, (_input + INPUT_BUTTON_SPACE)
    cp      #0x01
    jr      nz, GameShipPlayDone
    
    ; ショットのエントリ
    call    _GameShotEntry
    
    ; 処理の完了
GameShipPlayDone:
    
    ; 描画の開始
    ld      a, (_gameShip + GAME_SHIP_PARAM_NODAMAGE)
    and     #0b00000010
    sla     a
    ld      c, a
    ld      b, #0x00
    ld      hl, #shipSpriteTable
    add     hl, bc
    ld      de, #(_sprite + GAME_SPRITE_SHIP)
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_X)
    ld      b, a
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_Y)
    ld      c, a
    call    _SystemSetSprite
    
    ; 処理の終了
GameShipPlayEnd:
    
    ; 終了
    ret


; 自機が爆発する
;
GameShipBomb::
    
    ; 状態の取得
    ld      a, (_gameShip + GAME_SHIP_PARAM_PHASE)
    or      a
    jr      nz, GameShipBombMain
    
    ; ノーダメージの設定
    ld      a, #0x80
    ld      (_gameShip + GAME_SHIP_PARAM_NODAMAGE), a
    
    ; アニメーションの設定
    xor     a
    ld      (_gameShip + GAME_SHIP_PARAM_ANIMATION), a
    
    ; 演奏の開始
    ld      hl, #mmlBombChannel0
    ld      (_soundRequest + 0), hl
    
    ; 状態の更新
    ld      hl, #(_gameShip + GAME_SHIP_PARAM_PHASE)
    inc     (hl)
    
    ; 爆発の処理
GameShipBombMain:
    
    ; アニメーションの更新
    ld      hl, #(_gameShip + GAME_SHIP_PARAM_ANIMATION)
    inc     (hl)
    ld      a, (hl)
    cp      #0x1f
    jr      nz, GameShipBombDone
    
    ; 状態の更新
    ld      a, #GAME_SHIP_STATE_PLAY
    ld      (_gameShip + GAME_SHIP_PARAM_STATE), a
    xor     a
    ld      (_gameShip + GAME_SHIP_PARAM_PHASE), a
    
    ; 処理の完了
GameShipBombDone:
    
    ; 描画の開始
    ld      a, (_gameShip + GAME_SHIP_PARAM_ANIMATION)
    and     #0b00011000
    srl     a
    ld      c, a
    ld      b, #0x00
    ld      hl, #bombSpriteTable
    add     hl, bc
    ld      de, #(_sprite + GAME_SPRITE_SHIP)
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_X)
    ld      b, a
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_Y)
    ld      c, a
    call    _SystemSetSprite
    
    ; 処理の終了
GameShipBombEnd:
    
    ; 終了
    ret


; 定数の定義
;

; 自機データ
;
shipSpriteTable:
    
    .db     0xf8, 0xf8, 0x00, 0x0f
    .db     0xf8, 0xf8, 0x04, 0x0f

; 爆発データ
;
bombSpriteTable:
    
    .db     0xf8, 0xf8, 0x10, 0x06
    .db     0xf8, 0xf8, 0x14, 0x0a
    .db     0xf8, 0xf8, 0x18, 0x06
    .db     0xf8, 0xf8, 0x1c, 0x0f

; MML データ
;
mmlBombChannel0:
    
    .ascii  "T1V15L0"
    .ascii  "O4CO3BAGABO4CDEFGG#R1GFEDCDFGABO5CC#R1CO4BAGAO5CDEGG#R1GFEDCDFGABO6CDO5A#"
    .db     0x00



; DATA 領域
;
    .area   _DATA


; 変数の定義
;

; パラメータ
;
_gameShip::
    
    .ds     GAME_SHIP_PARAM_SIZE



