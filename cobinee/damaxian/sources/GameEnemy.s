; GameEnemy.s : ゲーム画面／敵
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
    .include    "GameEnemy.inc"



; CODE 領域
;
    .area   _CODE


; 敵を初期化する
;
_GameEnemyInitialize::
    
    ; 敵の走査
    ld      ix, #_gameEnemy
    ld      bc, #((GAME_ENEMY_SIZE << 8) | 0x0000)
0$:
    
    ; 位置の設定
    ld      a, c
    sla     a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyPointTable
    add     hl, de
    ld      a, (hl)
    ld      GAME_ENEMY_PARAM_POINT_XS(ix), a
    inc     hl
    ld      a, (hl)
    ld      GAME_ENEMY_PARAM_POINT_YS(ix), a
    
    ; スプライトの設定
    ld      a, c
    sla     a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemySpritePatternTable
    add     hl, de
    ld      a, (hl)
    ld      GAME_ENEMY_PARAM_SPRITE_SRC_L(ix), a
    inc     hl
    ld      a, (hl)
    ld      GAME_ENEMY_PARAM_SPRITE_SRC_H(ix), a
    ld      a, c
    sla     a
    sla     a
    ld      GAME_ENEMY_PARAM_SPRITE_OFFSET(ix), a
    
    ; 状態の設定
    ld      a, #GAME_ENEMY_STATE_IN
    ld      GAME_ENEMY_PARAM_STATE(ix), a
    xor     a
    ld      GAME_ENEMY_PARAM_PHASE(ix), a
    
    ; 次の敵
    ld      de, #GAME_ENEMY_PARAM_SIZE
    add     ix, de
    inc     c
    djnz    0$
    
    ; スプライトオフセットの初期化
    xor     a
    ld      (spriteOffset + 0), a
    ld      a, #GAME_SPRITE_ENEMY
    ld      (spriteOffset + 1), a
    
    ; 終了
    ret


; 敵を更新する
;
_GameEnemyUpdate::
    
    ; 敵の走査
    ld      ix, #_gameEnemy
    ld      b, #GAME_ENEMY_SIZE
GameEnemyUpdateLoop:
    
    ; レジスタの保存
    push    bc
    
    ; 状態の取得
    ld      a, GAME_ENEMY_PARAM_STATE(ix)
    
    ; なし
    cp      #GAME_ENEMY_STATE_NULL
    jr      nz, 00$
    call    GameEnemyNull
    jr      GameEnemyUpdateNext
00$:
    
    ; イン
    cp      #GAME_ENEMY_STATE_IN
    jr      nz, 01$
    call    GameEnemyIn
    jr      GameEnemyUpdateNext
01$:
    
    ; 待機
    cp      #GAME_ENEMY_STATE_STAY
    jr      nz, 02$
    call    GameEnemyStay
    jr      GameEnemyUpdateNext
02$:
    
    ; ターン
    cp      #GAME_ENEMY_STATE_TURN
    jr      nz, 03$
    call    GameEnemyTurn
    jr      GameEnemyUpdateNext
03$:
    
    ; アプローチ
    cp      #GAME_ENEMY_STATE_APPROACH
    jr      nz, 04$
    call    GameEnemyApproach
    jr      GameEnemyUpdateNext
04$:
    
    ; 爆発
    cp      #GAME_ENEMY_STATE_BOMB
    jr      nz, 05$
    call    GameEnemyBomb
    jr      GameEnemyUpdateNext
05$:
    
    ; 次の敵
GameEnemyUpdateNext:
    pop     bc
    ld      de, #GAME_ENEMY_PARAM_SIZE
    add     ix, de
    djnz    GameEnemyUpdateLoop
    
    ; 更新の終了
GameEnemyUpdateEnd:
    
    ; スプライトオフセットの更新
    ld      hl, #spriteOffset
    ld      a, (hl)
    add     a, #0x04
    cp      #(GAME_ENEMY_SIZE * 0x04)
    jr      c, 10$
    xor     a
10$:
    ld      (hl), a
    inc     hl
    ld      a, #GAME_SPRITE_ENEMY_OFFSET
    sub     (hl)
    ld      (hl), a
    
    ; 終了
    ret


; 敵はなし
;
GameEnemyNull:
    
    ; 状態の取得
    ld      a, GAME_ENEMY_PARAM_PHASE(ix)
    or      a
    jr      nz, GameEnemyNullMain
    
    ; ノーダメージの設定
    ld      a, #0x80
    ld      GAME_ENEMY_PARAM_NODAMAGE(ix), a
    
    ; 状態の更新
    inc     GAME_ENEMY_PARAM_PHASE(ix)
    
    ; 待機の処理
GameEnemyNullMain:
    
    ; 処理の完了
GameEnemyNullDone:
    
    ; 描画の開始
    ld      hl, #spriteOffset
    ld      a, (hl)
    inc     hl
    add     a, GAME_ENEMY_PARAM_SPRITE_OFFSET(ix)
    cp      #(GAME_ENEMY_SIZE * 0x04)
    jr      c, 0$
    sub     #(GAME_ENEMY_SIZE * 0x04)
0$:
    add     a, (hl)
    ld      c, a
    ld      b, #0x00
    ld      hl, #_sprite
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
GameEnemyNullEnd:
    
    ; 終了
    ret


; 敵がインする
;
GameEnemyIn:
    
    ; 状態の取得
    ld      a, GAME_ENEMY_PARAM_PHASE(ix)
    or      a
    jr      nz, GameEnemyInMain
    
    ; 位置の設定
    ld      a, GAME_ENEMY_PARAM_POINT_XS(ix)
    ld      GAME_ENEMY_PARAM_POINT_XI(ix), a
    ld      a, #0xf4
    ld      GAME_ENEMY_PARAM_POINT_YI(ix), a
    xor     a
    ld      GAME_ENEMY_PARAM_POINT_XD(ix), a
    ld      GAME_ENEMY_PARAM_POINT_YD(ix), a
    
    ; 方向の設定
    ld      a, #0x40
    ld      GAME_ENEMY_PARAM_ANGLE(ix), a
    
    ; ノーダメージの設定
    xor     a
    ld      GAME_ENEMY_PARAM_NODAMAGE(ix), a
    
    ; カウントの設定
    ld      a, #0x40
    sub     GAME_ENEMY_PARAM_POINT_YS(ix)
    ld      GAME_ENEMY_PARAM_COUNT0(ix), a
    
    ; アニメーションの設定
    xor     a
    ld      GAME_ENEMY_PARAM_ANIMATION(ix), a
    
    ; 状態の更新
    inc     GAME_ENEMY_PARAM_PHASE(ix)
    
    ; インの処理
GameEnemyInMain:
    
    ; カウントの更新
    ld      a, GAME_ENEMY_PARAM_COUNT0(ix)
    or      a
    jr      z, 00$
    sub     #0x02
    ld      GAME_ENEMY_PARAM_COUNT0(ix), a
    jr      GameEnemyInDone
00$:
    
    ; 位置の更新
    ld      a, GAME_ENEMY_PARAM_POINT_YI(ix)
    cp      GAME_ENEMY_PARAM_POINT_YS(ix)
    jr      z, 10$
    add     #0x02
    ld      GAME_ENEMY_PARAM_POINT_YI(ix), a
    jr      GameEnemyInDone
10$:
    
    ; 方向の更新
    ld      a, GAME_ENEMY_PARAM_ANGLE(ix)
    cp      #0xc0
    jr      z, 20$
    sub     #0x08
    ld      GAME_ENEMY_PARAM_ANGLE(ix), a
    jr      GameEnemyInDone
20$:
    
    ; 状態の設定
    ld      a, #GAME_ENEMY_STATE_STAY
    ld      GAME_ENEMY_PARAM_STATE(ix), a
    xor     a
    ld      GAME_ENEMY_PARAM_PHASE(ix), a
    
    ; 処理の完了
GameEnemyInDone:
    
    ; 敵の描画
    call    GameEnemyDraw
    
    ; 処理の終了
GameEnemyInEnd:
    
    ; 終了
    ret


; 敵が待機する
;
GameEnemyStay:
    
    ; 状態の取得
    ld      a, GAME_ENEMY_PARAM_PHASE(ix)
    or      a
    jr      nz, GameEnemyStayMain
    
    ; カウントの設定
    ld      a, (_appTimer + 0)
    sla     a
    ld      c, a
    ld      b, #0x00
    ld      hl, #enemyStayTable
    add     hl, bc
    call    _SystemGetRandom
    and     (hl)
    inc     hl
    add     a, (hl)
    ld      GAME_ENEMY_PARAM_COUNT0(ix), a
    ld      a, #0x40
    ld      GAME_ENEMY_PARAM_COUNT1(ix), a
    
    ; 状態の更新
    inc     GAME_ENEMY_PARAM_PHASE(ix)
    
    ; 待機の処理
GameEnemyStayMain:
    
    ; 操作可能かどうか
    ld      hl, #_gameFlag
    bit     #GAME_FLAG_PLAYABLE, (hl)
    jr      z, GameEnemyStayDone
    
    ; カウントの更新
    ld      a, GAME_ENEMY_PARAM_COUNT0(ix)
    or      a
    jr      z, 0$
    dec     GAME_ENEMY_PARAM_COUNT0(ix)
    jr      GameEnemyStayDone
0$:
    ld      a, GAME_ENEMY_PARAM_COUNT1(ix)
    or      a
    jr      z, 1$
    dec     GAME_ENEMY_PARAM_COUNT1(ix)
    jr      GameEnemyStayDone
1$:
    
    ; 状態の設定
    ld      a, #GAME_ENEMY_STATE_TURN
    ld      GAME_ENEMY_PARAM_STATE(ix), a
    xor     a
    ld      GAME_ENEMY_PARAM_PHASE(ix), a
    
    ; 処理の完了
GameEnemyStayDone:
    
    ; 敵の描画
    call    GameEnemyDraw
    
    ; 処理の終了
GameEnemyStayEnd:
    
    ; 終了
    ret


; 敵がターンする
;
GameEnemyTurn:
    
    ; 状態の取得
    ld      a, GAME_ENEMY_PARAM_PHASE(ix)
    or      a
    jr      nz, GameEnemyTurnMain
    
    ; 回転の設定
    ld      a, #0x02
    ld      GAME_ENEMY_PARAM_TURN(ix), a
    call    _SystemGetRandom
    and     #0b00010000
    jr      nz, 00$
    ld      a, #0xfe
    ld      GAME_ENEMY_PARAM_TURN(ix), a
00$:
    
    ; 演奏の開始
    ld      hl, #mmlTurnChannel1
    ld      (_soundRequest + 2), hl
    
    ; 状態の更新
    inc     GAME_ENEMY_PARAM_PHASE(ix)
    
    ; ターンの処理
GameEnemyTurnMain:
    
    ; 方向の更新
    ld      a, GAME_ENEMY_PARAM_TURN(ix)
    add     a, GAME_ENEMY_PARAM_ANGLE(ix)
    ld      GAME_ENEMY_PARAM_ANGLE(ix), a
    cp      #0x40
    jr      nz, 10$
    
    ; 状態の更新
    ld      a, #GAME_ENEMY_STATE_APPROACH
    ld      GAME_ENEMY_PARAM_STATE(ix), a
    xor     a
    ld      GAME_ENEMY_PARAM_PHASE(ix), a
10$:
    
    ; 位置の更新
    
    ; X 方向は x1.5 の移動
    ld      a, GAME_ENEMY_PARAM_ANGLE(ix)
    call    _SystemGetCos
    ld      a, GAME_ENEMY_PARAM_POINT_XD(ix)
    add     a, l
    ld      c, a
    ld      a, GAME_ENEMY_PARAM_POINT_XI(ix)
    adc     a, h
    ld      b, a
    sra     h
    rr      l
    ld      a, c
    add     a, l
    ld      GAME_ENEMY_PARAM_POINT_XD(ix), a
    ld      a, b
    adc     a, h
    ld      GAME_ENEMY_PARAM_POINT_XI(ix), a
    
    ; Y 方向は x2.0 の移動
    ld      a, GAME_ENEMY_PARAM_ANGLE(ix)
    call    _SystemGetSin
    sla     l
    rl      h
    ld      a, GAME_ENEMY_PARAM_POINT_YD(ix)
    add     a, l
    ld      GAME_ENEMY_PARAM_POINT_YD(ix), a
    ld      a, GAME_ENEMY_PARAM_POINT_YI(ix)
    adc     a, h
    ld      GAME_ENEMY_PARAM_POINT_YI(ix), a
    
    ; 画面端の制御
    jr      21$
    ld      a, GAME_ENEMY_PARAM_POINT_XI(ix)
    cp      #0x08
    jr      nc, 20$
    ld      a, #0x08
    ld      GAME_ENEMY_PARAM_POINT_XI(ix), a
    xor     a
    ld      GAME_ENEMY_PARAM_POINT_XD(ix), a
    ld      a, #0x80
    sub     GAME_ENEMY_PARAM_ANGLE(ix)
    ld      GAME_ENEMY_PARAM_ANGLE(ix), a
    ld      a, GAME_ENEMY_PARAM_TURN(ix)
    xor     #0xff
    inc     a
    ld      GAME_ENEMY_PARAM_TURN(ix), a
20$:
    ld      a, GAME_ENEMY_PARAM_POINT_XI(ix)
    cp      #0xb8
    jr      c, 21$
    ld      a, #0xb8
    ld      GAME_ENEMY_PARAM_POINT_XI(ix), a
    xor     a
    ld      GAME_ENEMY_PARAM_POINT_XD(ix), a
    ld      a, #0x80
    sub     GAME_ENEMY_PARAM_ANGLE(ix)
    ld      GAME_ENEMY_PARAM_ANGLE(ix), a
    ld      a, GAME_ENEMY_PARAM_TURN(ix)
    xor     #0xff
    inc     a
    ld      GAME_ENEMY_PARAM_TURN(ix), a
21$:
    
    ; 処理の完了
GameEnemyTurnDone:
    
    ; 敵の描画
    call    GameEnemyDraw
    
    ; 処理の終了
GameEnemyTurnEnd:
    
    ; 終了
    ret


; 敵がアプローチする
;
GameEnemyApproach:
    
    ; 状態の取得
    ld      a, GAME_ENEMY_PARAM_PHASE(ix)
    or      a
    jr      nz, GameEnemyApproachMain
    
    ; 状態の更新
    inc     GAME_ENEMY_PARAM_PHASE(ix)
    
    ; アプローチの処理
GameEnemyApproachMain:
    
    ; 方向の更新
    ld      a, GAME_ENEMY_PARAM_POINT_XI(ix)
    cp      #0xe0
    jr      c, 00$
    ld      a, #0xfe
    jr      02$
00$:
    ld      hl, #(_gameShip + GAME_SHIP_PARAM_POINT_X)
    cp      (hl)
    jr      nz, 01$
    xor     a
    jr      02$
01$:
    ld      a, #0x02
    jr      nc, 02$
    ld      a, #0xfe
02$:
    add     a, GAME_ENEMY_PARAM_ANGLE(ix)
    cp      #0x22
    jr      nc, 03$
    ld      a, #0x22
03$:
    cp      #0x5e
    jr      c, 04$
    ld      a, #0x5e
04$:
    ld      GAME_ENEMY_PARAM_ANGLE(ix), a
    
    ; 位置の更新
    call    _SystemGetCos
    sla     l
    rl      h
    ld      a, GAME_ENEMY_PARAM_POINT_XD(ix)
    add     a, l
    ld      GAME_ENEMY_PARAM_POINT_XD(ix), a
    ld      a, GAME_ENEMY_PARAM_POINT_XI(ix)
    adc     a, h
    ld      GAME_ENEMY_PARAM_POINT_XI(ix), a
    
    ; 位置の更新
    ld      a, GAME_ENEMY_PARAM_ANGLE(ix)
    call    _SystemGetSin
    sla     l
    rl      h
    ld      a, GAME_ENEMY_PARAM_POINT_YD(ix)
    add     a, l
    ld      GAME_ENEMY_PARAM_POINT_YD(ix), a
    ld      a, GAME_ENEMY_PARAM_POINT_YI(ix)
    adc     a, h
    ld      GAME_ENEMY_PARAM_POINT_YI(ix), a
    
    ; 移動の完了
    ld      a, GAME_ENEMY_PARAM_POINT_YI(ix)
    cp      #0xc8
    jr      c, GameEnemyApproachDone
    
    ; 状態の更新
    ld      a, #GAME_ENEMY_STATE_IN
    ld      GAME_ENEMY_PARAM_STATE(ix), a
    xor     a
    ld      GAME_ENEMY_PARAM_PHASE(ix), a
    
    ; 処理の完了
GameEnemyApproachDone:
    
    ; 敵の描画
    call    GameEnemyDraw
    
    ; 処理の終了
GameEnemyApproachEnd:
    
    ; 終了
    ret


; 敵が爆発する
;
GameEnemyBomb:
    
    ; 状態の取得
    ld      a, GAME_ENEMY_PARAM_PHASE(ix)
    or      a
    jr      nz, GameEnemyBombMain
    
    ; ノーダメージの設定
    ld      a, #0x80
    ld      GAME_ENEMY_PARAM_NODAMAGE(ix), a
    
    ; アニメーションの設定
    xor     a
    ld      GAME_ENEMY_PARAM_ANIMATION(ix), a
    
    ; 演奏の開始
    ld      hl, #mmlBombChannel2
    ld      (_soundRequest + 4), hl
    
    ; 状態の更新
    inc     GAME_ENEMY_PARAM_PHASE(ix)
    
    ; 爆発の処理
GameEnemyBombMain:
    
    ; アニメーションの更新
    inc     GAME_ENEMY_PARAM_ANIMATION(ix)
    ld      a, GAME_ENEMY_PARAM_ANIMATION(ix)
    cp      #0x1f
    jr      nz, GameEnemyBombDone
    
    ; 状態の更新
    ld      a, #GAME_ENEMY_STATE_IN
    ld      GAME_ENEMY_PARAM_STATE(ix), a
    xor     a
    ld      GAME_ENEMY_PARAM_PHASE(ix), a
    
    ; 処理の完了
GameEnemyBombDone:
    
    ; 描画の開始
    ld      hl, #spriteOffset
    ld      a, (hl)
    inc     hl
    add     a, GAME_ENEMY_PARAM_SPRITE_OFFSET(ix)
    cp      #(GAME_ENEMY_SIZE * 0x04)
    jr      c, 0$
    sub     #(GAME_ENEMY_SIZE * 0x04)
0$:
    add     a, (hl)
    ld      c, a
    ld      b, #0x00
    ld      hl, #_sprite
    add     hl, bc
    ld      d, h
    ld      e, l
    ld      a, GAME_ENEMY_PARAM_ANIMATION(ix)
    and     #0b00011000
    srl     a
    ld      c, a
    ld      b, #0x00
    ld      hl, #bombSpriteTable
    add     hl, bc
    ld      b, GAME_ENEMY_PARAM_POINT_XI(ix)
    ld      c, GAME_ENEMY_PARAM_POINT_YI(ix)
    call    _SystemSetSprite
    
    ; 処理の終了
GameEnemyBombEnd:
    
    ; 終了
    ret


; 敵を描画する
;
GameEnemyDraw::
    
    ; アニメーションの更新
    inc     GAME_ENEMY_PARAM_ANIMATION(ix)
    
    ; 描画の開始
    ld      hl, #spriteOffset
    ld      a, (hl)
    inc     hl
    add     a, GAME_ENEMY_PARAM_SPRITE_OFFSET(ix)
    cp      #(GAME_ENEMY_SIZE * 0x04)
    jr      c, 0$
    sub     #(GAME_ENEMY_SIZE * 0x04)
0$:
    add     a, (hl)
    ld      c, a
    ld      b, #0x00
    ld      hl, #_sprite
    add     hl, bc
    ld      d, h
    ld      e, l
    ld      a, GAME_ENEMY_PARAM_ANGLE(ix)
    add     a, #0x20
    and     #0b11000000
    srl     a
    srl     a
    srl     a
    ld      c, a
    ld      b, #0x00
    ld      l, GAME_ENEMY_PARAM_SPRITE_SRC_L(ix)
    ld      h, GAME_ENEMY_PARAM_SPRITE_SRC_H(ix)
    add     hl, bc
    ld      a, GAME_ENEMY_PARAM_ANIMATION(ix)
    and     #0b00001000
    srl     a
    ld      c, a
    ld      b, #0x00
    add     hl, bc
    ld      b, GAME_ENEMY_PARAM_POINT_XI(ix)
    ld      c, GAME_ENEMY_PARAM_POINT_YI(ix)
    ld      a, b
    cp      #0xe0
    jr      c, 1$
    cp      #0xf8
    jr      nc, 1$
    ld      a, #0xc0
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    jr      2$
1$:
    call    _SystemSetSprite
2$:
    
    ; 終了
    ret


; 定数の定義
;

; 敵データ
;
enemyPointTable:
    
    .db     0x40, 0x10
    .db     0x80, 0x10
    .db     0x30, 0x28
    .db     0x50, 0x28
    .db     0x70, 0x28
    .db     0x90, 0x28
    .db     0x40, 0x40
    .db     0x60, 0x40
    .db     0x80, 0x40

enemyStayTable:
    
    .db     0x7f, 0x00
    .db     0x7f, 0x40
    .db     0xff, 0x00
    .db     0xff, 0x00

enemySpriteTable:
    
    .db     0xf8, 0xf8, 0x80, 0x0a      ; 0:→
    .db     0xf8, 0xf8, 0x84, 0x0a
    .db     0xf8, 0xf8, 0x88, 0x0a      ; 0:↓
    .db     0xf8, 0xf8, 0x8c, 0x0a
    .db     0xf8, 0xf8, 0x90, 0x0a      ; 0:←
    .db     0xf8, 0xf8, 0x94, 0x0a
    .db     0xf8, 0xf8, 0x98, 0x0a      ; 0:↑
    .db     0xf8, 0xf8, 0x9c, 0x0a
    .db     0xf8, 0xf8, 0xa0, 0x06      ; 1:→
    .db     0xf8, 0xf8, 0xa4, 0x06
    .db     0xf8, 0xf8, 0xa8, 0x06      ; 1:↓
    .db     0xf8, 0xf8, 0xac, 0x06
    .db     0xf8, 0xf8, 0xb0, 0x06      ; 1:←
    .db     0xf8, 0xf8, 0xb4, 0x06
    .db     0xf8, 0xf8, 0xb8, 0x06      ; 1:↑
    .db     0xf8, 0xf8, 0xbc, 0x06
    .db     0xf8, 0xf8, 0xc0, 0x0d      ; 2:→
    .db     0xf8, 0xf8, 0xc4, 0x0d
    .db     0xf8, 0xf8, 0xc8, 0x0d      ; 2:↓
    .db     0xf8, 0xf8, 0xcc, 0x0d
    .db     0xf8, 0xf8, 0xd0, 0x0d      ; 2:←
    .db     0xf8, 0xf8, 0xd4, 0x0d
    .db     0xf8, 0xf8, 0xd8, 0x0d      ; 2:↑
    .db     0xf8, 0xf8, 0xdc, 0x0d
    .db     0xf8, 0xf8, 0xe0, 0x04      ; 3:→
    .db     0xf8, 0xf8, 0xe4, 0x04
    .db     0xf8, 0xf8, 0xe8, 0x04      ; 3:↓
    .db     0xf8, 0xf8, 0xec, 0x04
    .db     0xf8, 0xf8, 0xf0, 0x04      ; 3:←
    .db     0xf8, 0xf8, 0xf4, 0x04
    .db     0xf8, 0xf8, 0xf8, 0x04      ; 3:↑
    .db     0xf8, 0xf8, 0xfc, 0x04

enemySpritePatternTable:
    
    .dw     enemySpriteTable + 0x0000
    .dw     enemySpriteTable + 0x0000
    .dw     enemySpriteTable + 0x0020
    .dw     enemySpriteTable + 0x0060
    .dw     enemySpriteTable + 0x0060
    .dw     enemySpriteTable + 0x0020
    .dw     enemySpriteTable + 0x0040
    .dw     enemySpriteTable + 0x0060
    .dw     enemySpriteTable + 0x0040

; 爆発データ
;
bombSpriteTable:
    
    .db     0xf8, 0xf8, 0x10, 0x06
    .db     0xf8, 0xf8, 0x14, 0x0a
    .db     0xf8, 0xf8, 0x18, 0x06
    .db     0xf8, 0xf8, 0x1c, 0x0f

; MML データ
;
mmlTurnChannel1:
    
    .ascii  "T1V15L1"
    .ascii  "O6CO5BA#AG#GF#FED#DDC#CO4BA#AAGF#FED#DC#CO3BA#AG#GF#FED#DC#CO2BA#A"
    .db     0x00

mmlBombChannel2:
    
    .ascii  "T1V15L0"
    .ascii  "O4AGFEDCAGFEDCCDEFGABO5CDEFGABO6CO5AFEDEF"
    .db     0x00



; DATA 領域
;
    .area   _DATA


; 変数の定義
;

; パラメータ
;
_gameEnemy::
    
    .ds     GAME_ENEMY_PARAM_SIZE * GAME_ENEMY_SIZE

; スプライトオフセット
;
spriteOffset:
    
    .ds     2



