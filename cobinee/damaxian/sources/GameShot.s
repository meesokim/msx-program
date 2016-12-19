; GameShot.s : ゲーム画面／ショット
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


; ショットを初期化する
;
_GameShotInitialize::
    
    ; ショットの走査
    ld      ix, #_gameShot
    ld      de, #GAME_SHOT_PARAM_SIZE
    ld      bc, #((GAME_SHOT_SIZE << 8) | 0x0000)
0$:
    
    ; インデックスの設定
    ld      GAME_SHOT_PARAM_INDEX(ix), c
    
    ; 状態の設定
    ld      a, #GAME_SHOT_STATE_NULL
    ld      GAME_SHOT_PARAM_STATE(ix), a
    xor     a
    ld      GAME_SHOT_PARAM_PHASE(ix), a
    
    ; 次のショット
    add     ix, de
    inc     c
    djnz    0$
    
    ; 終了
    ret


; ショットを更新する
;
_GameShotUpdate::
    
    ; ショットの走査
    ld      ix, #_gameShot
    ld      b, #GAME_SHOT_SIZE
GameShotUpdateLoop:
    
    ; レジスタの保存
    push    bc
    
    ; 状態の取得
    ld      a, GAME_SHOT_PARAM_STATE(ix)
    
    ; なし
    cp      #GAME_SHOT_STATE_NULL
    jr      nz, 0$
    call    GameShotNull
    jr      GameShotUpdateNext
0$:
    
    ; 移動
    cp      #GAME_SHOT_STATE_MOVE
    jr      nz, 1$
    call    GameShotMove
    jr      GameShotUpdateNext
1$:
    
    ; 次のショット
GameShotUpdateNext:
    pop     bc
    ld      de, #GAME_SHOT_PARAM_SIZE
    add     ix, de
    djnz    GameShotUpdateLoop
    
    ; 更新の終了
GameShotUpdateEnd:
    
    ; 終了
    ret


; ショットはなし
;
GameShotNull:
    
    ; 状態の取得
    ld      a, GAME_SHOT_PARAM_PHASE(ix)
    or      a
    jr      nz, GameShotNullMain
    
    ; 状態の更新
    inc     GAME_SHOT_PARAM_PHASE(ix)
    
    ; 待機の処理
GameShotNullMain:
    
    ; 処理の完了
GameShotNullDone:
    
    ; 描画の開始
    ld      c, GAME_SHOT_PARAM_INDEX(ix)
    sla     c
    sla     c
    ld      b, #0x00
    ld      hl, #(_sprite + GAME_SPRITE_SHOT)
    add     hl, bc
    ld      a, #0xc0
    ld      (hl), a
    inc     hl
    ld      (hl), a
    inc     hl
    ld      (hl), a
    inc     hl
    ld      (hl), a
    
    ; 処理の終了
GameShotNullEnd:
    
    ; 終了
    ret


; ショットが移動する
;
GameShotMove:
    
    ; 状態の取得
    ld      a, GAME_SHOT_PARAM_PHASE(ix)
    or      a
    jr      nz, GameShotMoveMain
    
    ; 位置の初期化
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_X)
    ld      GAME_SHOT_PARAM_POINT_X(ix), a
    ld      a, (_gameShip + GAME_SHIP_PARAM_POINT_Y)
    ld      GAME_SHOT_PARAM_POINT_Y(ix), a
    
    ; 演奏の開始
    ld      hl, #mmlChannel0
    ld      (_soundRequest + 0), hl
    
    ; 状態の更新
    inc     GAME_SHOT_PARAM_PHASE(ix)
    
    ; 移動の処理
GameShotMoveMain:
    
    ; 移動
    ld      a, GAME_SHOT_PARAM_POINT_Y(ix)
    sub     #0x04
    ld      GAME_SHOT_PARAM_POINT_Y(ix), a
    
    ; 移動の完了
    cp      #0xf0
    jr      c, GameShotMoveDone
    cp      #0xf9
    jr      nc, GameShotMoveDone
    
    ; 状態の更新
    ld      a, #GAME_SHOT_STATE_NULL
    ld      GAME_SHOT_PARAM_STATE(ix), a
    xor     a
    ld      GAME_SHOT_PARAM_PHASE(ix), a
    
    ; 処理の完了
GameShotMoveDone:
    
    ; 描画の開始
    ld      c, GAME_SHOT_PARAM_INDEX(ix)
    sla     c
    sla     c
    ld      b, #0x00
    ld      hl, #(_sprite + GAME_SPRITE_SHOT)
    add     hl, bc
    ld      d, h
    ld      e, l
    ld      hl, #shotSpriteTable
    ld      b, GAME_SHOT_PARAM_POINT_X(ix)
    ld      c, GAME_SHOT_PARAM_POINT_Y(ix)
    call    _SystemSetSprite
    
    ; 処理の終了
GameShotMoveEnd:
    
    ; 終了
    ret


; ショットをエントリする
;
_GameShotEntry::
    
    ; レジスタの保存
    push    bc
    push    de
    push    ix
    
    ; ショットの走査
    ld      ix, #_gameShot
    ld      de, #GAME_SHOT_PARAM_SIZE
    ld      b, #GAME_SHOT_SIZE
0$:
    ld      a, GAME_SHOT_PARAM_STATE(ix)
    cp      #GAME_SHOT_STATE_NULL
    jr      z, 1$
    add     ix, de
    djnz    0$
    jr      GameShotEntryEnd
1$:
    
    ; 状態の更新
    ld      a, #GAME_SHOT_STATE_MOVE
    ld      GAME_SHOT_PARAM_STATE(ix), a
    xor     a
    ld      GAME_SHOT_PARAM_PHASE(ix), a
    
    ; エントリの終了
GameShotEntryEnd:
    
    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    
    ; 終了
    ret


; 定数の定義
;


; ショットデータ
;
shotSpriteTable:
    
    .db     0xfc, 0xf8, 0x08, 0x0f

; MML データ
;
mmlChannel0:
    
    .ascii  "T1V15L0"
    .ascii  "O5C#CC#RCO4BA#AG#GFD#C#O3BG#"
    .db     0x00



; DATA 領域
;
    .area   _DATA


; 変数の定義
;

; パラメータ
;
_gameShot::
    
    .ds     GAME_SHOT_PARAM_SIZE * GAME_SHOT_SIZE



