; EnemyFans.s : 敵／ファン
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

; 敵を生成する
;
_EnemyFansGenerate::
    
    ; レジスタの保存
    
    ; ジェネレータの取得
    ld      iy, #_enemyGenerator
    
    ; 初期化の開始
    ld      a, ENEMY_GENERATOR_STATE(iy)
    or      a
    jr      nz, 09$
    
    ; 生成数の設定
    call    _SystemGetRandom
    and     #0x01
    add     a, a
    add     a, #0x04
    ld      ENEMY_GENERATOR_LENGTH(iy), a
    
    ; タイマの設定
    ld      a, #0x01
    ld      ENEMY_GENERATOR_TIMER(iy), a
    
    ; パラメータの設定
    ld      a, ENEMY_GENERATOR_TYPE(iy)
    cp      #ENEMY_TYPE_FANS_BACK
    ld      a, #0xff
    adc     a, #0x00
    ld      ENEMY_GENERATOR_PARAM_0(iy), a
    call    _SystemGetRandom
    and     #0x80
    add     a, #0x20
    ld      ENEMY_GENERATOR_PARAM_1(iy), a
    
    ; 初期化の完了
    inc     ENEMY_GENERATOR_STATE(iy)
09$:
    
    ; タイマの更新
    dec     ENEMY_GENERATOR_TIMER(iy)
    jr      nz, 19$
    ld      a, #0x04
    ld      ENEMY_GENERATOR_TIMER(iy), a
    
    ; 生成の開始
    call    _EnemyGetEmpty
    jr      c, 19$
    
    ; 敵の生成
    ld      a, ENEMY_GENERATOR_TYPE(iy)
    ld      ENEMY_TYPE(ix), a
    xor     a
    ld      ENEMY_STATE(ix), a
    ld      a, ENEMY_GENERATOR_PARAM_0(iy)
    ld      ENEMY_POSITION_X(ix), a
    ld      a, ENEMY_GENERATOR_PARAM_1(iy)
    ld      ENEMY_POSITION_Y(ix), a
    ld      a, #0x01
    ld      ENEMY_HP(ix), a
    
    ; 生成数の更新
    dec     ENEMY_GENERATOR_LENGTH(iy)
    jr      nz, 19$
    
    ; 生成の完了
    xor     a
    ld      ENEMY_GENERATOR_TYPE(iy), a
    ld      ENEMY_GENERATOR_STATE(iy), a
19$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 敵を更新する
;
_EnemyFansUpdate::
    
    ; レジスタの保存
    
    ; 初期化の開始
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$
    
    ; ショットの設定
    call    _SystemGetRandom
    and     #0x1f
    add     #0x08
    ld      ENEMY_SHOT(ix), a
    
    ; アニメーションの設定
    ld      a, #0x60
    ld      ENEMY_ANIMATION(ix), a
    
    ; タイマの設定
    ld      a, #0x04
    ld      ENEMY_TIMER(ix), a
    
    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:
    
    ; 移動
    ld      a, ENEMY_TYPE(ix)
    cp      #ENEMY_TYPE_FANS_FRONT
    jr      nz, 10$
    call    EnemyFansFrontMove
    jr      19$
10$:
    call    EnemyFansBackMove
19$:

    ; ショットの更新
90$:
    dec     ENEMY_SHOT(ix)
    jr      nz, 91$
    ld      h, ENEMY_POSITION_X(ix)
    ld      l, ENEMY_POSITION_Y(ix)
    call    _BulletGenerate
    call    _SystemGetRandom
    and     #0x1f
    add     #0x30
    ld      ENEMY_SHOT(ix), a

    ; アニメーションの更新
91$:
    dec     ENEMY_TIMER(ix)
    jr      nz, 99$
    ld      a, ENEMY_ANIMATION(ix)
    add     a, #0x02
    cp      #0x66
    jr      c, 92$
    ld      a, #0x60
92$:
    ld      ENEMY_ANIMATION(ix), a
    ld      a, #0x04
    ld      ENEMY_TIMER(ix), a
    jr      99$
    
    ; 更新の完了
99$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 敵が移動する／→
;
EnemyFansFrontMove:
    
    ; レジスタの保存
    
    ; 移動（→）
    ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 19$
    ld      a, ENEMY_POSITION_X(ix)
    add     a, #0x04
    jp      c, 98$
    ld      ENEMY_POSITION_X(ix), a
    cp      #0xd0
    jr      c, 99$
    ld      a, (_ship + SHIP_POSITION_Y)
    cp      ENEMY_POSITION_Y(ix)
    ld      a, #0x02
    adc     a, #0x00
    ld      ENEMY_STATE(ix), a
    jr      99$
19$:
    
    ; 移動（↓）
;   ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 29$
    ld      a, ENEMY_POSITION_X(ix)
    sub     #0x04
    jr      c, 98$
    ld      ENEMY_POSITION_X(ix), a
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, #0x04
    cp      #0xc0
    jr      nc, 98$
    ld      ENEMY_POSITION_Y(ix), a
    ld      b, a
    ld      a, (_ship + SHIP_POSITION_Y)
    cp      b
    jr      nc, 99$
    ld      a, #0x04
    ld      ENEMY_STATE(ix), a
    jr      99$
29$:

    ; 移動（↑）
;   ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 39$
    ld      a, ENEMY_POSITION_X(ix)
    sub     #0x04
    jr      c, 98$
    ld      ENEMY_POSITION_X(ix), a
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #0x04
    jr      c, 98$
    ld      ENEMY_POSITION_Y(ix), a
    ld      b, a
    ld      a, (_ship + SHIP_POSITION_Y)
    cp      b
    jr      c, 99$
    ld      a, #0x04
    ld      ENEMY_STATE(ix), a
    jr      99$
39$:

    ; 移動（←）
;   ld      a, ENEMY_STATE(ix)
;   dec     a
;   jr      nz, 49$
    ld      a, ENEMY_POSITION_X(ix)
    sub     #0x04
    jr      c, 98$
    ld      ENEMY_POSITION_X(ix), a
    jr      99$
49$:
    
    ; 敵の削除
98$:
    xor     a
    ld      ENEMY_TYPE(ix), a
    
    ; 移動の完了
99$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 敵が移動する／←
;
EnemyFansBackMove:
    
    ; レジスタの保存
    
    ; 移動（←）
    ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 19$
    ld      a, ENEMY_POSITION_X(ix)
    sub     #0x04
    ld      ENEMY_POSITION_X(ix), a
    cp      #0x30
    jp      nc, 99$
    ld      a, (_ship + SHIP_POSITION_Y)
    cp      ENEMY_POSITION_Y(ix)
    ld      a, #0x02
    adc     a, #0x00
    ld      ENEMY_STATE(ix), a
    jr      99$
19$:
    
    ; 移動（↓）
;   ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 29$
    ld      a, ENEMY_POSITION_X(ix)
    add     a, #0x04
    jr      c, 98$
    ld      ENEMY_POSITION_X(ix), a
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, #0x04
    cp      #0xc0
    jr      nc, 98$
    ld      ENEMY_POSITION_Y(ix), a
    ld      b, a
    ld      a, (_ship + SHIP_POSITION_Y)
    cp      b
    jr      nc, 99$
    ld      a, #0x04
    ld      ENEMY_STATE(ix), a
    jr      99$
29$:

    ; 移動（↑）
;   ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 39$
    ld      a, ENEMY_POSITION_X(ix)
    add     a, #0x04
    jr      c, 98$
    ld      ENEMY_POSITION_X(ix), a
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #0x04
    jr      c, 98$
    ld      ENEMY_POSITION_Y(ix), a
    ld      b, a
    ld      a, (_ship + SHIP_POSITION_Y)
    cp      b
    jr      c, 99$
    ld      a, #0x04
    ld      ENEMY_STATE(ix), a
    jr      99$
39$:

    ; 移動（→）
;   ld      a, ENEMY_STATE(ix)
;   dec     a
;   jr      nz, 49$
    ld      a, ENEMY_POSITION_X(ix)
    add     a, #0x04
    jr      c, 98$
    ld      ENEMY_POSITION_X(ix), a
    jr      99$
49$:
    
    ; 敵の削除
98$:
    xor     a
    ld      ENEMY_TYPE(ix), a
    
    ; 移動の完了
99$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

