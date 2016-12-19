; Enemy.s : 敵
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include	"Game.inc"
    .include    "Ship.inc"
    .include	"Enemy.inc"
    .include    "Bullet.inc"

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 敵を初期化する
;
_EnemyInitialize::
    
    ; レジスタの保存
    
    ; 敵の初期化
    ld      hl, #(_enemy + 0x0000)
    ld      de, #(_enemy + 0x0001)
    ld      bc, #(ENEMY_SIZE * ENEMY_N - 1)
    xor     a
    ld      (hl), a
    ldir
    ld      hl, #(_enemy + ENEMY_INDEX)
    ld      de, #ENEMY_SIZE
    ld      b, #ENEMY_N
    ld      a, #0x01
0$:
    ld      (hl), a
    add     hl, de
    inc     a
    djnz    0$
    ld      a, #0x07
    ld      (_enemyN), a
    
    ; ジェネレータの初期化
    ld      hl, #(_enemyGenerator + 0x0000)
    ld      de, #(_enemyGenerator + 0x0001)
    ld      bc, #(ENEMY_GENERATOR_SIZE)
    xor     a
    ld      (hl), a
    ldir
    ld      a, #ENEMY_PHASE_NORMAL
    ld      (_enemyGenerator + ENEMY_GENERATOR_PHASE), a
    
    ; コリジョンの初期化
    ld      hl, #(_enemyCollision + 0x0000)
    ld      de, #(_enemyCollision + 0x0001)
    ld      bc, #0x02ff
    xor     a
    ld      (hl), a
    ldir
    
    ; パターンジェネレータの設定
    ld      a, #(APP_PATTERN_GENERATOR_TABLE_1 >> 11)
    ld      (_videoRegister + VDP_R4), a
    
    ; ビデオレジスタの転送
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 敵を更新する
;
_EnemyUpdate::
    
    ; レジスタの保存
    
    ; コリジョンの初期化
    ld      hl, #(_enemyCollision + 0x0000)
    ld      de, #(_enemyCollision + 0x0001)
    ld      bc, #0x02ff
    xor     a
    ld      (hl), a
    ldir
    
    ; 敵の生成
    ld      hl, #19$
    push    hl
    ld      a, (_enemyGenerator + ENEMY_GENERATOR_TYPE)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyGenerateProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
19$:
    
    ; 敵の更新
    ld      ix, #_enemy
    ld      a, (_enemyN)
    ld      b, a
20$:
    ld      hl, #21$
    push    bc
    push    hl
    ld      a, ENEMY_TYPE(ix)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyUpdateProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
21$:
    pop     bc
    ld      de, #ENEMY_SIZE
    add     ix, de
    djnz    20$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 敵を描画する
;
_EnemyRender::
    
    ; レジスタの保存
    
    ; 種類別の描画
    ld      ix, #_enemy
    ld      a, (_enemyN)
    ld      b, a
10$:
    ld      hl, #11$
    push    bc
    push    hl
    ld      a, ENEMY_TYPE(ix)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyRenderProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
11$:
    pop     bc
    ld      de, #ENEMY_SIZE
    add     ix, de
    djnz    10$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ENEMY_TYPE_NULL を生成する
;
EnemyNullGenerate:
    
    ; レジスタの保存
    
    ; ジェネレータの取得
    ld      iy, #_enemyGenerator
    
    ; 通常戦の開始
    ld      a, ENEMY_GENERATOR_PHASE(iy)
    dec     a
    jr      nz, 19$
    
    ; 通常戦の初期化
    ld      a, ENEMY_GENERATOR_STATE(iy)
    or      a
    jr      nz, 10$
    ld      a, #0x08
    ld      ENEMY_GENERATOR_TIMER(iy), a
    inc     ENEMY_GENERATOR_STATE(iy)
10$:
    
    ; ボス登場の条件
    ld      hl, (_ship + SHIP_SHOT_L)
    ld      de, #0x0100
    or      a
    sbc     hl, de
    jr      nc, 18$

    ; タイマの更新
    dec     ENEMY_GENERATOR_TIMER(iy)
    jp      nz, 99$
    
    ; 敵の生成
    xor     a
    ld      ENEMY_GENERATOR_STATE(iy), a
    call    _SystemGetRandom
    rra
    rra
    and     #0x1f
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyGenerateType
    add     hl, de
    ld      a, (hl)
    ld      ENEMY_GENERATOR_TYPE(iy), a
    jp      99$
    
    ; 通常戦の完了
18$:
    ld      a, #ENEMY_PHASE_WARNING
    ld      ENEMY_GENERATOR_PHASE(iy), a
    xor     a
    ld      ENEMY_GENERATOR_STATE(iy), a
    jp      99$
19$:
    
    ; 警告の開始
    dec     a
    jr      nz, 29$
    
    ; 警告の初期化
    ld      a, ENEMY_GENERATOR_STATE(iy)
    or      a
    jr      nz, 20$
    ld      a, #0x30
    ld      ENEMY_GENERATOR_TIMER(iy), a
    inc     ENEMY_GENERATOR_STATE(iy)
20$:
    
    ; 敵の監視
    ld      hl, #(_enemy + ENEMY_TYPE)
    ld      de, #ENEMY_SIZE
    ld      a, (_enemyN)
    ld      b, a
    xor     a
21$:
    or      (hl)
    add     hl, de
    djnz    21$
    or      a
    jr      nz, 99$
    
    ; タイマの更新
    dec     ENEMY_GENERATOR_TIMER(iy)
    jr      nz, 99$
    
    ; ビッグコアの生成
    ld      a, #ENEMY_TYPE_BIGCORE_CORE
    ld      ENEMY_GENERATOR_TYPE(iy), a
    xor     a
    ld      ENEMY_GENERATOR_STATE(iy), a
    
    ; パターンジェネレータの設定
    ld      a, #(APP_PATTERN_GENERATOR_TABLE_2 >> 11)
    ld      (_videoRegister + VDP_R4), a
    
    ; ビデオレジスタの転送
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; 警告の完了
    ld      a, #ENEMY_PHASE_BOSS
    ld      ENEMY_GENERATOR_PHASE(iy), a
    xor     a
    ld      ENEMY_GENERATOR_STATE(iy), a
    jr      99$
29$:
    
    ; ボス戦の開始
    dec     a
    jr      nz, 39$
    
    ; ボス戦の初期化
    ld      a, ENEMY_GENERATOR_STATE(iy)
    or      a
    jr      nz, 30$
    ld      a, #0x60
    ld      ENEMY_GENERATOR_TIMER(iy), a
    inc     ENEMY_GENERATOR_STATE(iy)
30$:
    
    ; ボスの監視
    ld      hl, #(_enemy + ENEMY_TYPE)
    ld      de, #ENEMY_SIZE
    ld      a, (_enemyN)
    ld      b, a
    ld      a, #ENEMY_TYPE_BIGCORE_BODY
31$:
    cp      (hl)
    jr      z, 99$
    add     hl, de
    djnz    31$
    
    ; タイマの更新
    dec     ENEMY_GENERATOR_TIMER(iy)
    jr      nz, 99$
    
    ; 自機のリセット
    ld      hl, #0x0000
    ld      (_ship + SHIP_SHOT_L), hl
    
    ; 敵の増加
    ld      hl, #_enemyN
    ld      a, (hl)
    add     a, #0x03
    cp      #ENEMY_N
    jr      c, 32$
    ld      a, #ENEMY_N
32$:
    ld      (hl), a
    
    ; 弾の増加
    ld      hl, #_bulletN
    ld      a, (hl)
    add     a, #0x03
    cp      #BULLET_N
    jr      c, 33$
    ld      a, #BULLET_N
33$:
    ld      (hl), a
    
    ; パターンジェネレータの設定
    ld      a, #(APP_PATTERN_GENERATOR_TABLE_1 >> 11)
    ld      (_videoRegister + VDP_R4), a
    
    ; ビデオレジスタの転送
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; ボス戦の完了
    ld      a, #ENEMY_PHASE_NORMAL
    ld      ENEMY_GENERATOR_PHASE(iy), a
    xor     a
    ld      ENEMY_GENERATOR_STATE(iy), a
;   jr      99$
39$:

    ; 生成の完了
99$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ENEMY_TYPE_NULL を更新する
;
EnemyNullUpdate:
    
    ; レジスタの保存
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ENEMY_TYPE_NULL を描画する
;
EnemyNullRender:
    
    ; レジスタの保存
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 空の敵を取得する
;
_EnemyGetEmpty::
    
    ; レジスタの保存
    
    ; 空の敵の取得
    ld      ix, #_enemy
    ld      de, #ENEMY_SIZE
    ld      a, (_enemyN)
    ld      b, a
0$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 9$
    add     ix, de
    djnz    0$
    ld      ix, #0x0000
    scf
9$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 16x16 サイズのパターンを置く
;
EnemyPutPattern16x16:
    
    ; レジスタの保存
    
    ; クリッピングの取得
    ld      c, #0b00001111
    ld      a, ENEMY_POSITION_Y(ix)
    cp      #0x08
    jr      nc, 00$
    res     #0, c
    res     #1, c
00$:
    cp      #0xc0
    jr      c, 01$
    res     #2, c
    res     #3, c
01$:
    ld      a, ENEMY_POSITION_X(ix)
    cp      #0x08
    jr      nc, 02$
    res     #0, c
    res     #2, c
02$:
    
    ; パターンを置く
    ld      a, ENEMY_POSITION_Y(ix)
    and     #0xf8
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, ENEMY_POSITION_X(ix)
    srl     e
    srl     e
    srl     e
    add     a, e
    ld      e, a
    ld      hl, #(_appPatternName - 0x0021)
    add     hl, de
    ld      iy, #(_enemyCollision - 0x0021)
    add     iy, de
    ld      a, ENEMY_ANIMATION(ix)
    ld      b, ENEMY_INDEX(ix)
    rr      c
    jr      nc, 10$
    ld      (hl), a
    ld      0(iy), b
10$:
    inc     hl
    inc     iy
    inc     a
    rr      c
    jr      nc, 11$
    ld      (hl), a
    ld      0(iy), b
11$:
    ld      de, #0x001f
    add     hl, de
    add     iy, de
    add     a, #0x0f
    rr      c
    jr      nc, 12$
    ld      (hl), a
    ld      0(iy), b
12$:
    inc     hl
    inc     iy
    inc     a
    rr      c
    jr      nc, 13$
    ld      (hl), a
    ld      0(iy), b
13$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; ジェネレータ
;
enemyGenerateProc:

    .dw     EnemyNullGenerate
    .dw     EnemyNullGenerate
    .dw     _EnemyFansGenerate
    .dw     _EnemyFansGenerate
    .dw     _EnemyRugalGenerate
    .dw     _EnemyRugalGenerate
    .dw     _EnemyGarunGenerate
    .dw     _EnemyGarunGenerate
    .dw     _EnemyDee01Generate
    .dw     _EnemyDee01Generate
    .dw     _EnemyDuckerGenerate
    .dw     _EnemyDuckerGenerate
    .dw     _EnemyBigCoreGenerate
    .dw     0x0000
    .dw     _EnemyBeamGenerate

enemyGenerateType:

    .db     ENEMY_TYPE_FANS_FRONT
    .db     ENEMY_TYPE_FANS_FRONT
    .db     ENEMY_TYPE_FANS_FRONT
    .db     ENEMY_TYPE_FANS_FRONT
    .db     ENEMY_TYPE_FANS_FRONT
    .db     ENEMY_TYPE_FANS_BACK
    .db     ENEMY_TYPE_RUGAL_FRONT
    .db     ENEMY_TYPE_RUGAL_FRONT
    .db     ENEMY_TYPE_RUGAL_FRONT
    .db     ENEMY_TYPE_RUGAL_FRONT
    .db     ENEMY_TYPE_RUGAL_FRONT
    .db     ENEMY_TYPE_RUGAL_BACK
    .db     ENEMY_TYPE_GARUN_FRONT
    .db     ENEMY_TYPE_GARUN_FRONT
    .db     ENEMY_TYPE_GARUN_FRONT
    .db     ENEMY_TYPE_GARUN_FRONT
    .db     ENEMY_TYPE_GARUN_FRONT
    .db     ENEMY_TYPE_GARUN_FRONT
    .db     ENEMY_TYPE_GARUN_FRONT
    .db     ENEMY_TYPE_GARUN_BACK
    .db     ENEMY_TYPE_DEE01_UPPER
    .db     ENEMY_TYPE_DEE01_UPPER
    .db     ENEMY_TYPE_DEE01_UPPER
    .db     ENEMY_TYPE_DEE01_UPPER
    .db     ENEMY_TYPE_DEE01_LOWER
    .db     ENEMY_TYPE_DEE01_LOWER
    .db     ENEMY_TYPE_DEE01_LOWER
    .db     ENEMY_TYPE_DEE01_LOWER
    .db     ENEMY_TYPE_DUCKER_UPPER
    .db     ENEMY_TYPE_DUCKER_UPPER
    .db     ENEMY_TYPE_DUCKER_LOWER
    .db     ENEMY_TYPE_DUCKER_LOWER

; 更新
;
enemyUpdateProc:

    .dw     EnemyNullUpdate
    .dw     _EnemyBombUpdate
    .dw     _EnemyFansUpdate
    .dw     _EnemyFansUpdate
    .dw     _EnemyRugalUpdate
    .dw     _EnemyRugalUpdate
    .dw     _EnemyGarunUpdate
    .dw     _EnemyGarunUpdate
    .dw     _EnemyDee01Update
    .dw     _EnemyDee01Update
    .dw     _EnemyDuckerUpdate
    .dw     _EnemyDuckerUpdate
    .dw     _EnemyBigCoreUpdateCore
    .dw     _EnemyBigCoreUpdateBody
    .dw     _EnemyBeamUpdate

; 描画
;
enemyRenderProc:

    .dw     EnemyNullRender
    .dw     _EnemyBombRender
    .dw     EnemyPutPattern16x16
    .dw     EnemyPutPattern16x16
    .dw     EnemyPutPattern16x16
    .dw     EnemyPutPattern16x16
    .dw     EnemyPutPattern16x16
    .dw     EnemyPutPattern16x16
    .dw     EnemyPutPattern16x16
    .dw     EnemyPutPattern16x16
    .dw     EnemyPutPattern16x16
    .dw     EnemyPutPattern16x16
    .dw     _EnemyBigCoreRenderCore
    .dw     _EnemyBigCoreRenderBody
    .dw     _EnemyBeamRender


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 敵
;
_enemy::

    .ds     ENEMY_SIZE * ENEMY_N

_enemyN::

    .ds     1

; ジェネレータ
;
_enemyGenerator::

    .ds     ENEMY_GENERATOR_SIZE
    
; コリジョン
;
_enemyCollision::

    .ds     0x0300
