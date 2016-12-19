; Player.s : プレイヤ
;


; モジュール宣言
;
    .module Player

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Stage.inc"
    .include	"Player.inc"
    .include    "Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; プレイヤを初期化する
;
_PlayerInitialize::
    
    ; レジスタの保存
    
    ; プレイヤの初期化
    ld      hl, #playerDefault
    ld      de, #_player
    ld      bc, #PLAYER_SIZE
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret
    
; プレイヤを作成する
;
_PlayerCreate::

    ; レジスタの保存
    
    ; プレイヤの設定
    ld      hl, #(_player + PLAYER_POSITION_X)
    ld      a, (hl)
    cp      #0x18
    jr      nc, 10$
    ld      a, #0x18
10$:
    cp      #0xe8
    jr      c, 11$
    ld      a, #0xe8
11$:
    ld      (hl), a
    ld      a, #0xef
    ld      (_player + PLAYER_POSITION_Y), a
    xor     a
    ld      (_player + PLAYER_STATE), a
    ld      (_player + PLAYER_SPEED_Y), a
    ld      (_player + PLAYER_FLAG), a

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを更新する
;
_PlayerUpdate::
    
    ; レジスタの保存
    
    ; フラグの監視
    ld      hl, #(_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_BIT_PAUSE, (hl)
    jr      nz, 90$

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_player + PLAYER_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; 更新の完了
90$:

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを描画する
;
_PlayerRender::
    
    ; レジスタの保存
    
    ; プレイヤの存在
    ld      a, (_player + PLAYER_STATE)
    or      a
    jr      z, 90$

    ; スプライトの表示
    ld      hl, #(_player + PLAYER_SPRITE_0)
    ld      de, #playerColor
    ld      bc, #0x0300
10$:
    push    hl
    push    de
    ld      e, (hl)
    ld      d, #0x00
    ld      hl, #_sprite
    add     hl, de
    pop     de
    ld      a, (_player + PLAYER_POSITION_Y)
;   sub     #0x0f
;   sub     #0x01
;   add     a, #0x10
    ld      (hl), a
    inc     hl
    ld      a, (_player + PLAYER_POSITION_X)
    sub     #0x08
    ld      (hl), a
    inc     hl
    ld      a, (_player + PLAYER_PATTERN)
    add     a, c
    ld      (hl), a
    inc     hl
    ld      a, (de)
    ld      (hl), a
;   inc     hl
    pop     hl
    inc     hl
    inc     de
    ld      a, c
    add     a, #0x20
    ld      c, a
    djnz    10$

    ; スプライトの更新
    ld      a, (_player + PLAYER_SPRITE_0)
    ld      hl, (_player + PLAYER_SPRITE_1)
    ld      (_player + PLAYER_SPRITE_0), hl
    ld      (_player + PLAYER_SPRITE_2), a
    
    ; 表示の完了
90$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 他のオブジェクトとのヒット判定を行う
;
_PlayerHit::

    ; レジスタの保存

    ; ブロックをパンチ
    ld      hl, #(_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_BIT_PUNCH, (hl)
    jr      z, 11$
    res     #PLAYER_FLAG_BIT_PUNCH, (hl)
    ld      a, (_player + PLAYER_DIRECTION)
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerPunchBlock
    add     hl, de
    ld      b, #0x02
10$:
    push    bc
    ld      de, (_player + PLAYER_POSITION_X)
    ld      a, (hl)
    inc     hl
    add     a, e
    and     #0xf0
    rrca
    rrca
    rrca
    rrca
    ld      e, a
    ld      a, (hl)
    inc     hl
    add     a, d
    and     #0xf0
    add     a, e
    push    hl
    call    _StagePunchBlock
    pop     hl
    pop     bc
    jr      c, 11$
    djnz    10$
11$:

    ; コインの獲得
    ld      de, #playerGetCoin
    ld      b, #0x04
20$:
    push    bc
    ld      hl, (_player + PLAYER_POSITION_X)
    ld      a, (de)
    inc     de
    add     a, l
    and     #0xf0
    rrca
    rrca
    rrca
    rrca
    ld      l, a
    ld      a, (de)
    inc     de
    add     a, h
    and     #0xf0
    add     a, l
    push    de
    call    _StageGetFieldCoin
    pop     de
    pop     bc
    jr      c, 21$
    djnz    20$
21$:
    
    ; エネミーとの判定
    ld      a, (_player + PLAYER_POSITION_X)
    sub     #0x05
    ld      d, a
    add     a, #0x0a
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     #0x0d
    ld      h, a
    add     a, #0x0e
    ld      l, a
    ld      ix, #_enemy
    ld      b, #ENEMY_N
30$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 32$
    ld      a, ENEMY_STATE(ix)
    cp      #ENEMY_STATE_MOVE
    jr      nz, 32$
    ld      a, ENEMY_POSITION_X(ix)
    add     a, #0x07
    cp      d
    jr      c, 32$
    sub     #0x0f
    cp      e
    jr      nc, 32$
    ld      a, ENEMY_POSITION_Y(ix)
    cp      h
    jr      c, 32$
    sub     #0x0f
    cp      l
    jr      nc, 32$
    sub     h
    jr      c, 31$
    cp      #0x08
    jr      c, 31$
    ld      a, #ENEMY_STATE_KILL
    ld      ENEMY_STATE(ix), a
    ld      hl, #(_player + PLAYER_SPEED_Y)
    ld      a, (hl)
    rlca
    jr      c, 32$
    rrca
    neg
    ld      (hl), a
    jr      32$
31$:
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_BIT_MISS, (hl)
    jr      39$
32$:
    push    de
    ld      de, #ENEMY_SIZE
    add     ix, de
    pop     de
    djnz    30$
39$:

    ; レジスタの復帰

    ; 終了
    ret

; なにもしない
;
PlayerNull:

    ; レジスタの保存

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤが歩く
;
PlayerWalk:
    
    ; レジスタの保存
    
    ; ←→の移動
    call    PlayerMoveLeftRight

    ; SPACE キーの監視
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 10$

    ; ＳＥの再生
    ld      hl, #playerSoundJump
    ld      (_soundRequest + 0x0006), hl
    
    ; 速度の設定
    ld      a, #-0x4a
    ld      (_player + PLAYER_SPEED_Y), a

    ; 状態の更新
    ld      a, #PLAYER_STATE_JUMP
    ld      (_player + PLAYER_STATE), a
    jr      19$

    ; 落下の可能性
10$:
    ld      a, #0x0c
    ld      (_player + PLAYER_SPEED_Y), a
    call    PlayerMoveUpDown
    ld      a, (_player + PLAYER_SPEED_Y)
    or      a
    jr      z, 19$

    ; 状態の更新
    ld      a, #PLAYER_STATE_FALL
    ld      (_player + PLAYER_STATE), a

    ; 移動の完了
19$:

    ; アニメーションの更新
    ld      a, (_player + PLAYER_SPEED_X)
    or      a
    jr      nz, 20$
    ld      (_player + PLAYER_ANIMATION), a
    ld      a, (_player + PLAYER_DIRECTION)
    jr      21$
20$:
    and     #0x80
    rla
    ccf
    adc     a, #0x00
    ld      (_player + PLAYER_DIRECTION), a
21$:
    add     a, a
    add     a, a
    ld      e, a
    ld      hl, #(_player + PLAYER_ANIMATION)
    inc     (hl)
    ld      a, (hl)
    rrca
    rrca
    and     #0x03
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerPatternWalk
    add     hl, de
    ld      a, (hl)
    ld      (_player + PLAYER_PATTERN), a
29$:

    ; 歩きの完了
90$:

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤが飛ぶ
;
PlayerJump:
    
    ; レジスタの保存

    ; 初期化処理
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; アニメーションの設定
    ld      a, (_player + PLAYER_DIRECTION)
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerPatternJump
    add     hl, de
    ld      a, (hl)
    ld      (_player + PLAYER_PATTERN), a

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; ←→の移動
    call    PlayerMoveLeftRight

    ; ↓の移動
    call    PlayerMoveUpDown
    ld      a, (_player + PLAYER_SPEED_Y)
    rlca
    jr      c, 19$
    ld      a, #PLAYER_STATE_FALL
    ld      (_player + PLAYER_STATE), a
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤが落ちる
;
PlayerFall:
    
    ; レジスタの保存
    
    ; ←→の移動
    call    PlayerMoveLeftRight

    ; ↓の移動
    call    PlayerMoveUpDown
    ld      a, (_player + PLAYER_SPEED_Y)
    or      a
    jr      nz, 19$
    ld      a, #PLAYER_STATE_WALK
    ld      (_player + PLAYER_STATE), a
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤがミスする
;
PlayerMiss:
    
    ; レジスタの保存
    
    ; 初期化処理
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; プレイヤの設定
    ld      a, #-0x40
    ld      (_player + PLAYER_SPEED_Y), a

    ; アニメーションの設定
    xor     a
    ld      (_player + PLAYER_ANIMATION), a

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; やられ
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    cp      #0x01
    jr      nz, 19$

    ; アニメーションの更新
    ld      hl, #(_player + PLAYER_ANIMATION)
    ld      a, (hl)
    inc     a
    and     #0x1f
    ld      (hl), a
    ld      a, #0x80
    ld      (_player + PLAYER_PATTERN), a
    jr      nz, 90$

    ; やられの完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
    jr      90$
19$:

    ; 落下
    cp      #0x02
    jr      nz, 29$

    ; アニメーションの更新
    ld      hl, #(_player + PLAYER_ANIMATION)
    ld      a, (hl)
    inc     a
    ld      (hl), a
    and     #0x08
    rrca
    add     a, #0x80
    ld      (_player + PLAYER_PATTERN), a

    ; ↓へ移動
    ld      hl, #(_player + PLAYER_SPEED_Y)
    ld      a, (hl)
    cp      #0x40
    jr      c, 20$
    cp      #0x80
    jr      c, 21$
20$:
    add     a, #0x04
    ld      (hl), a
21$:
    sra     a
    sra     a
    sra     a
    sra     a
    ld      hl, #(_player + PLAYER_POSITION_Y)
    add     a, (hl)
    ld      (hl), a
    cp      #0xc0
    jr      c, 90$
    cp      #0xd0
    jr      nc, 90$

    ; 落下の完了
    xor     a
    ld      (_player + PLAYER_STATE), a
    jr      90$
29$:

    ; ゲームオーバーの完了
90$:

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを←→に移動する
;
PlayerMoveLeftRight:
    
    ; レジスタの保存
    
    ; 速度の更新
    ld      de, #(_player + PLAYER_SPEED_X)
    ld      a, (_player + PLAYER_DIRECTION)
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 10$
    ld      hl, #playerMoveLeftSpeed
    add     hl, bc
    ld      a, (de)
    sub     (hl)
    jp      p, 19$
    inc     hl
    cp      (hl)
    jr      nc, 19$
    ld      a, (hl)
    jr      19$
10$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 11$
    ld      hl, #playerMoveRightSpeed
    add     hl, bc
    ld      a, (de)
    add     a, (hl)
    jp      m, 19$
    inc     hl
    cp      (hl)
    jr      c, 19$
    ld      a, (hl)
    jr      19$
11$:
    ld      c, #0x03
    ld      a, (_player + PLAYER_SPEED_Y)
    or      a
    jr      z, 12$
    ld      c, #0x01
12$:
    ld      a, (de)
    or      a
    jr      z, 19$
    jp      p, 13$
    add     a, c
    jr      nc, 19$
    xor     a
    jr      19$
13$:
    sub     c
    jr      nc, 19$
    xor     a
19$:
    ld      (de), a
    
    ; 移動
    ld      hl, #(_player + PLAYER_POSITION_X)
;   ld      a, (_player + PLAYER_SPEED_X)
    sra     a
    sra     a
    sra     a
    sra     a
    jp      z, 290$
    jp      p, 210$

    ; ←へ移動
200$:
    add     a, (hl)
    ld      (hl), a
    sub     #0x08
    call    230$
    ld      de, #(_player + PLAYER_POSITION_Y)
    ld      a, (de)
    sub     #0x0f
    call    220$
    jr      nz, 201$
    ld      a, (de)
    call    220$
    jr      z, 290$
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 201$
    ld      a, (de)
    dec     a
    call    220$
    jr      nz, 201$
    ex      de, hl
    dec     (hl)
    jr      290$
201$:
    ld      hl, #(_player + PLAYER_POSITION_X)
    ld      a, (hl)
    sub     #0x08
    and     #0xf0
    add     a, #0x17
    ld      (hl), a
    jr      290$

    ; →へ移動
210$:
    add     a, (hl)
    ld      (hl), a
    add     a, #0x08
    call    230$
    ld      de, #(_player + PLAYER_POSITION_Y)
    ld      a, (de)
    sub     #0x0f
    call    220$
    jr      nz, 211$
    ld      a, (de)
    call    220$
    jr      z, 290$
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 211$
    ld      a, (de)
    dec     a
    call    220$
    jr      nz, 211$
    ex      de, hl
    dec     (hl)
    jr      290$
211$:
    ld      hl, #(_player + PLAYER_POSITION_X)
    ld      a, (hl)
    add     a, #0x08
    and     #0xf0
    sub     #0x08
    ld      (hl), a
    jr      290$

    ; ステージとの判定
220$:
    push    hl
    cp      #0xb0
    jr      nc, 228$
    and     #0xf0
    ld      c, a
    ld      b, #0x00
    add     hl, bc
    ld      a, (hl)
    and     #0x3f
    jr      229$
228$:
    xor     a
229$:
    pop     hl
    ret

    ; ステージの位置の計算
230$:
    and     #0xf0
    rrca
    rrca
    rrca
    rrca
    ld      c, a
    ld      b, #0x00
    ld      hl, #_stage
    add     hl, bc
    ret

    ; 移動の完了
290$:

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを↑↓に移動する
;
PlayerMoveUpDown:
    
    ; レジスタの保存
    
    ; 速度の更新
    ld      hl, #(_player + PLAYER_SPEED_Y)
    ld      e, #0x04
    ld      a, (hl)
    rlca
    jr      nc, 10$
    ld      e, #0x08
    ld      a, (_input + INPUT_BUTTON_SPACE)
    or      a
    jr      z, 10$
    ld      e, #0x03
10$:
    ld      a, e
    add     a, (hl)
    jp      m, 11$
    cp      #0x40
    jr      c, 11$
    ld      a, #0x40
11$:
    ld      (hl), a
    
    ; 移動
    ld      hl, #(_player + PLAYER_POSITION_Y)
;   ld      a, (_player + PLAYER_SPEED_Y)
    sra     a
    sra     a
    sra     a
    sra     a
    jp      p, 210$

    ; ↑へ移動
200$:
    add     a, (hl)
    ld      (hl), a
    sub     #0x10
    cp      #0xb0
    jp      nc, 290$
    and     #0xf0
    ld      e, a
    ld      d, #0x00
    ld      hl, #_stage
    add     hl, de
    ld      a, (_player + PLAYER_POSITION_X)
    call    220$
    jr      z, 201$
    ld      hl, #(_player + PLAYER_POSITION_Y)
    ld      a, (hl)
    sub     #0x10
    and     #0xf0
    add     a, #0x1f
    ld      (hl), a
    ld      hl, #(_player + PLAYER_SPEED_Y)
    ld      a, (hl)
    add     a, #0x10
    neg
    xor     a
    ld      (hl), a
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_BIT_PUNCH, (hl)
    jr      290$
201$:
    ld      a, (_player + PLAYER_POSITION_X)
    sub     #0x07
    call    220$
    jr      z, 202$
    ld      hl, #(_player + PLAYER_POSITION_X)
    inc     (hl)
;   ld      a, (hl)
;   and     #0xf8
;   add     a, #0x07
;   ld      (hl), a
    xor     a
    ld      (_player + PLAYER_SPEED_X), a
    jr      290$
202$:
    ld      a, (_player + PLAYER_POSITION_X)
    add     a, #0x07
    call    220$
    jr      z, 290$
    ld      hl, #(_player + PLAYER_POSITION_X)
    dec     (hl)
;   ld      a, (hl)
;   add     a, #0x07
;   and     #0xf8
;   sub     #0x08
;   ld      (hl), a
    xor     a
    ld      (_player + PLAYER_SPEED_X), a
    jr      290$

    ; ↓へ移動
210$:
    add     a, (hl)
    ld      (hl), a
    cp      #0xb0
    jr      nc, 290$
    and     #0xf0
    ld      e, a
    ld      d, #0x00
    ld      hl, #_stage
    add     hl, de
    ld      a, (_player + PLAYER_POSITION_X)
    sub     #0x07
    call    220$
    jr      nz, 211$
    ld      a, (_player + PLAYER_POSITION_X)
    add     a, #0x07
    call    220$
    jr      z, 290$
211$:
    ld      hl, #(_player + PLAYER_POSITION_Y)
    ld      a, (hl)
    and     #0xf0
    dec     a
    ld      (hl), a
    xor     a
    ld      (_player + PLAYER_SPEED_Y), a
    jr      290$

    ; ステージとの判定
220$:
    push    hl
    and     #0xf0
    rrca
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      a, (hl)
    and     #0x3f
    pop     hl
    ret

    ; 移動の完了
290$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; デフォルト値
;
playerDefault:

    .db     PLAYER_STATE_NULL
    .db     PLAYER_DIRECTION_RIGHT
    .db     0x78, 0xf0
    .db     0x00, 0x00
    .db     0x3c
    .db     0x00
    .db     GAME_SPRITE_PLAYER_0, GAME_SPRITE_PLAYER_1, GAME_SPRITE_PLAYER_2
    .db     PLAYER_FLAG_NULL

; 状態別の処理
;
playerProc:
    
    .dw     PlayerNull
    .dw     PlayerWalk
    .dw     PlayerJump
    .dw     PlayerFall
    .dw     PlayerMiss

; パターン
;
playerPatternWalk:

    .db     0x24, 0x20, 0x24, 0x28
    .db     0x34, 0x30, 0x34, 0x38

playerPatternJump:

    .db     0x2c
    .db     0x3c

; カラー
;
playerColor:

    .db     0x06, 0x04, 0x0a

; 移動
;
playerMoveLeftSpeed:

    .db     0x04, 0xe0
    .db     0x04, 0xf0

playerMoveRightSpeed:

    .db     0x04, 0x10
    .db     0x04, 0x20

; ブロック
;
playerPunchBlock:

    .db     0x00, 0xf0
    .db     0xf8, 0xef
    .db     0x07, 0xf0
    .db     0x00, 0xf0
    .db     0x00, 0xf0
    .db     0x07, 0xf0
    .db     0xf8, 0xf0

; コイン
;
playerGetCoin:

    .db     0xf9, 0xf1
    .db     0x07, 0xf1
    .db     0xf9, 0x00
    .db     0x07, 0x00

; サウンド
;
playerSoundJump:
    
    .ascii  "T1V15L0O4A1O3ABO4C+D+FGABO5C+D+FGA"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; プレイヤ
;
_player::

    .ds     PLAYER_SIZE
