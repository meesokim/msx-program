; Enemy.s : エネミー
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Stage.inc"
    .include	"Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; エネミーを初期化する
;
_EnemyInitialize::
    
    ; レジスタの保存
    
    ; レジスタの復帰
    
    ; 終了
    ret
    
; エネミーを作成する
;
_EnemyCreate::

    ; レジスタの保存
    
    ; エネミーの初期化
    ld      hl, #(_enemy + 0x0000)
    ld      de, #(_enemy + 0x0001)
    ld      bc, #(ENEMY_N * ENEMY_SIZE - 1)
    xor     a
    ld      (hl), a
    ldir

    ; エネミーの作成
    ld      a, (_appGame)
    or      a
    jr      z, 19$
    ld      a, (_stageNo)
    and     #0x03
    jr      z, 19$
    ld      ix, #_enemy
    ld      b, a
    call    _SystemGetRandom
    ld      c, a
10$:
    rrc     c
    push    bc
    jr      c, 11$
    call    EnemyCrabCreate
    jr      12$
11$:
    call    EnemySpinCreate
12$:
    ld      bc, #ENEMY_SIZE
    add     ix, bc
    pop     bc
    djnz    10$
19$:

    ; 状態の設定
    xor     a
    ld      (_enemyState), a

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを更新する
;
_EnemyUpdate::
    
    ; レジスタの保存
    
    ; 初期化処理
    ld      a, (_enemyState)
    ld      c, a
    and     #0x0f
    jr      nz, 09$

    ; 状態の設定
    ld      ix, #_enemy
    ld      de, #ENEMY_SIZE
    ld      b, #ENEMY_N
00$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 01$
    ld      ENEMY_STATE(ix), c
01$:
    add     ix, de
    djnz    00$

    ; 初期化の完了
    ld      hl, #_enemyState
    inc     (hl)
09$:

    ; エネミーの走査
    ld      ix, #_enemy
    ld      b, #ENEMY_N
10$:
    push    bc

    ; 状態別の処理
    ld      hl, #11$
    push    hl
    ld      a, ENEMY_TYPE(ix)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyTypeProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      a, ENEMY_STATE(ix)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      l, a
    ld      h, #0x00
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
11$:

    ; エネミー走査の完了
    ld      bc, #ENEMY_SIZE
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを描画する
;
_EnemyRender::
    
    ; レジスタの保存
    
    ; エネミーの走査
    ld      ix, #_enemy
    ld      de, #0x0000
    ld      b, #ENEMY_N
10$:
    push    bc

    ; エネミーの存在
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 19$
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      z, 19$

    ; スプライトの表示
    ld      hl, #(_sprite + GAME_SPRITE_ENEMY)
    add     hl, de
    ld      a, ENEMY_POSITION_Y(ix)
;   sub     #0x0f
;   sub     #0x01
;   add     a, #0x10
    ld      (hl), a
    inc     hl
    ld      a, ENEMY_POSITION_X(ix)
    sub     #0x08
    ld      (hl), a
    inc     hl
    ld      a, ENEMY_PATTERN(ix)
    ld      (hl), a
    inc     hl
    ld      a, ENEMY_COLOR(ix)
    ld      (hl), a
;   inc     hl

    ; スプライトの更新
    ld      a, e
    add     a, #0x04
    and     #(0x04 * ENEMY_N - 1)
    ld      e, a

    ; エネミー走査の完了
19$:
    ld      bc, #ENEMY_SIZE
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; 他のオブジェクトとのヒット判定を行う
;
_EnemyHit::

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; なにもしない
;
EnemyNull:

    ; レジスタの保存

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを開く
;
EnemyOpen:

    ; レジスタの保存

    ; 初期化処理
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 色の設定
    ld      a, #ENEMY_COLOR_SMOKE
    ld      ENEMY_COLOR(ix), a

    ; アニメーションの設定
    ld      a, #0x40
    ld      ENEMY_ANIMATION(ix), a

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; アニメーションの更新
    dec     ENEMY_ANIMATION(ix)
    jr      nz, 10$
    ld      a, #ENEMY_STATE_STAY
    ld      ENEMY_STATE(ix), a
10$:

    ; パターンの更新
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x10
    rrca
    rrca
    add     a, #0xe0
    ld      ENEMY_PATTERN(ix), a

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを閉じる
;
EnemyClose:

    ; レジスタの保存

    ; 初期化処理
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 色の設定
    ld      a, #ENEMY_COLOR_SMOKE
    ld      ENEMY_COLOR(ix), a

    ; アニメーションの設定
    ld      a, #0x20
    ld      ENEMY_ANIMATION(ix), a

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; アニメーションの更新
    dec     ENEMY_ANIMATION(ix)
    jr      nz, 10$
    xor     a
    ld      ENEMY_TYPE(ix), a
10$:

    ; パターンの更新
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x10
    rrca
    rrca
    add     a, #0xe0
    ld      ENEMY_PATTERN(ix), a

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーが待機する
;
EnemyStay:

    ; レジスタの保存

    ; 初期化処理
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; パターンと色の設定
    ld      hl, #enemyPatternStay
    call    EnemySetPattern

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを殺す
;
EnemyKill:

    ; レジスタの保存

    ; 初期化処理
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; パターンと色の設定
    ld      hl, #enemyPatternKill
    call    EnemySetPattern

    ; 速度の設定
    ld      a, #-0x40
    ld      ENEMY_ANIMATION(ix), a

    ; ＳＥの再生
    ld      hl, #enemySoundKill
    ld      (_soundRequest + 0x0006), hl

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 落下
    ld      a, ENEMY_ANIMATION(ix)
    cp      #0x40
    jr      c, 10$
    cp      #0x80
    jr      c, 11$
10$:
    add     a, #0x04
    ld      ENEMY_ANIMATION(ix), a
11$:
    sra     a
    sra     a
    sra     a
    sra     a
    add     a, ENEMY_POSITION_Y(ix)
    ld      ENEMY_POSITION_Y(ix), a
    cp      #0xc0
    jr      c, 19$
    cp      #0xd0
    jr      nc, 19$

    ; 落下の完了
    xor     a
    ld      ENEMY_TYPE(ix), a
;   ld      ENEMY_STATE(ix), a
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーのパターンと色を設定する
;
EnemySetPattern:

    ; レジスタの保存

    ; テーブルからパターンと色を設定
    ld      a, ENEMY_TYPE(ix)
    add     a, a
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      a, (hl)
    ld      ENEMY_PATTERN(ix), a
    inc     hl
    ld      a, (hl)
    ld      ENEMY_COLOR(ix), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを配置する
;
EnemyLocate:

    ; レジスタの保存

    ; 配置
    call    _SystemGetRandom
    and     #0x0f
    cp      #0x0c
    jr      c, 10$
    call    _SystemGetRandom
    and     #0x07
    add     a, #0x02
10$:
    add     a, #0x02
    ld      e, a
    ld      d, #0x00
    ld      hl, #_stage
    add     hl, de
    ld      bc, #0x0010
11$:
    ld      a, (hl)
    and     #0x3f
    jr      nz, 12$
    ld      a, #0x10
    add     a, d
    ld      d, a
    add     hl, bc
    jr      11$
12$:
    ld      a, e
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, #0x08
    ld      ENEMY_POSITION_X(ix), a
    dec     d
    ld      ENEMY_POSITION_Y(ix), d

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが左右に移動する
;
EnemyMoveLeftRight:

    ; レジスタの保存

    ; 向きの取得
    ld      a, ENEMY_DIRECTION(ix)
    rrca
    ld      a, ENEMY_POSITION_X(ix)
    jr      c, 10$

    ; ←に移動
    sub     #0x09
    ld      c, #0xff
    jr      11$

    ; →に移動
10$:
    add     a, #0x08
    ld      c, #0x01

    ; 衝突判定
11$:
    and     #0xf0
    rrca
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #_stage
    add     hl, de
    push    hl
    ld      a, ENEMY_POSITION_Y(ix)
    and     #0xf0
    ld      e, a
;   ld      d, #0x00
    add     hl, de
    ld      a, (hl)
    pop     hl
    and     #0x3f
    jr      nz, 12$
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #0x0f
    and     #0xf0
    ld      e, a
;   ld      d, #0x00
    add     hl, de
    ld      a, (hl)
    and     #0x3f
    jr      nz, 12$
    ld      a, ENEMY_POSITION_X(ix)
    add     a, c
    ld      ENEMY_POSITION_X(ix), a
    jr      19$

    ; Ｕターン
12$:
    ld      a, ENEMY_DIRECTION(ix)
    xor     #0x01
    ld      ENEMY_DIRECTION(ix), a

    ; 移動の完了
19$:

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが上下に移動する
;
EnemyMoveUpDown:

    ; レジスタの保存

    ; 向きの取得
    ld      a, ENEMY_DIRECTION(ix)
    rrca
    rrca
    ld      a, ENEMY_POSITION_Y(ix)
    jr      c, 10$

    ; ↑に移動
    sub     #0x10
    jr      c, 12$
    ld      c, #0xff
    jr      11$

    ; ↓に移動
10$:
    inc     a
    ld      c, #0x01

    ; 衝突判定
11$:
    and     #0xf0
    ld      e, a
    ld      d, #0x00
    ld      hl, #_stage
    add     hl, de
    push    hl
    ld      a, ENEMY_POSITION_X(ix)
    sub     #0x08
    and     #0xf0
    rrca
    rrca
    rrca
    rrca
    ld      e, a
;   ld      d, #0x00
    add     hl, de
    ld      a, (hl)
    pop     hl
    and     #0x3f
    jr      nz, 12$
    ld      a, ENEMY_POSITION_X(ix)
    add     a, #0x07
    and     #0xf0
    rrca
    rrca
    rrca
    rrca
    ld      e, a
;   ld      d, #0x00
    add     hl, de
    ld      a, (hl)
    and     #0x3f
    jr      nz, 12$
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, c
    ld      ENEMY_POSITION_Y(ix), a
    jr      19$

    ; Ｕターン
12$:
    ld      a, ENEMY_DIRECTION(ix)
    xor     #0x02
    ld      ENEMY_DIRECTION(ix), a

    ; 移動の完了
19$:

    ; レジスタの復帰

    ; 終了
    ret

; カニを作成する
;
EnemyCrabCreate:

    ; レジスタの保存

    ; 種類の設定
    ld      a, #ENEMY_TYPE_CRAB
    ld      ENEMY_TYPE(ix), a

    ; 状態の設定
    xor     a
    ld      ENEMY_STATE(ix), a

    ; 向きの設定
    call    _SystemGetRandom
    and     #0x01
    ld      ENEMY_DIRECTION(ix), a

    ; 位置の設定
    call    EnemyLocate

    ; レジスタの復帰
    
    ; 終了
    ret

; カニが移動する
;
EnemyCrabMove:
    
    ; レジスタの保存
    
    ; 速度の制御
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x03
    jr      nz, 19$

    ; 地面との判定
    ld      a, ENEMY_POSITION_Y(ix)
    inc     a
    and     #0xf0
    ld      e, a
    ld      d, #0x00
    ld      hl, #_stage
    add     hl, de
    ld      a, ENEMY_DIRECTION(ix)
    rrca
    ld      a, ENEMY_POSITION_X(ix)
    jr      c, 10$
    sub     #0x09
    jr      11$
10$:
    add     a, #0x08
11$:
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
    jr      nz, 12$
    ld      a, ENEMY_DIRECTION(ix)
    xor     #0x01
    ld      ENEMY_DIRECTION(ix), a
    jr      19$

    ; 左右の移動
12$:
    call    EnemyMoveLeftRight

    ; 移動の完了
19$:

    ; パターンの更新
    inc     ENEMY_ANIMATION(ix)
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x08
    rrca
    add     a, #0xa8
    ld      ENEMY_PATTERN(ix), a
    ld      a, #ENEMY_COLOR_CRAB
    ld      ENEMY_COLOR(ix), a

    ; レジスタの復帰
    
    ; 終了
    ret

; スピナを作成する
;
EnemySpinCreate:

    ; レジスタの保存

    ; 種類の設定
    ld      a, #ENEMY_TYPE_SPIN
    ld      ENEMY_TYPE(ix), a

    ; 状態の設定
    xor     a
    ld      ENEMY_STATE(ix), a

    ; 向きの設定
    call    _SystemGetRandom
    and     #0x03
    ld      ENEMY_DIRECTION(ix), a

    ; 位置の設定
    call    EnemyLocate
    srl     ENEMY_POSITION_Y(ix)

    ; レジスタの復帰
    
    ; 終了
    ret

; スピナが移動する
;
EnemySpinMove:
    
    ; レジスタの保存
    
    ; 速度の制御
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x01
    jr      nz, 19$

    ; 左右の移動
    call    EnemyMoveLeftRight
    call    EnemyMoveUpDown

    ; 移動の完了
19$:

    ; パターンの更新
    inc     ENEMY_ANIMATION(ix)
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x08
    rrca
    add     a, #0xc8
    ld      ENEMY_PATTERN(ix), a
    ld      a, #ENEMY_COLOR_SPIN
    ld      ENEMY_COLOR(ix), a

    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
enemyTypeProc:

    .dw     enemyNullProc
    .dw     enemyCrabProc
    .dw     enemySpinProc

enemyNullProc:

    .dw     EnemyNull

enemyCrabProc:
    
    .dw     EnemyNull
    .dw     EnemyOpen
    .dw     EnemyStay
    .dw     EnemyCrabMove
    .dw     EnemyKill
    .dw     EnemyClose
    
enemySpinProc:
    
    .dw     EnemyNull
    .dw     EnemyOpen
    .dw     EnemyStay
    .dw     EnemySpinMove
    .dw     EnemyKill
    .dw     EnemyClose

; パターン
;
enemyPatternStay:

    .db     0x00, ENEMY_COLOR_NULL
    .db     0xa8, ENEMY_COLOR_CRAB
    .db     0xc8, ENEMY_COLOR_SPIN

enemyPatternKill:

    .db     0x00, ENEMY_COLOR_NULL
    .db     0xb0, ENEMY_COLOR_KILL
    .db     0xd0, ENEMY_COLOR_KILL

; サウンド
;
enemySoundKill:

    .ascii  "T1V15L1O4CF"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; エネミー
;
_enemy::

    .ds     ENEMY_SIZE * ENEMY_N

; 状態
;
_enemyState::

    .ds     0x01
