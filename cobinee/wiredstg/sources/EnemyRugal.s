; EnemyRugal.s : 敵／ルグル
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
_EnemyRugalGenerate::
    
    ; レジスタの保存
    
    ; ジェネレータの取得
    ld      iy, #_enemyGenerator
    
    ; 初期化の開始
    ld      a, ENEMY_GENERATOR_STATE(iy)
    or      a
    jr      nz, 09$
    
    ; 生成数の設定
    ld      a, #0x03
    ld      ENEMY_GENERATOR_LENGTH(iy), a
    
    ; タイマの設定
    ld      a, #0x01
    ld      ENEMY_GENERATOR_TIMER(iy), a
    
    ; パラメータの設定
    ld      a, ENEMY_GENERATOR_TYPE(iy)
    cp      #ENEMY_TYPE_RUGAL_BACK
    ld      a, #0xff
    adc     a, #0x00
    ld      ENEMY_GENERATOR_PARAM_0(iy), a
    
    ; 初期化の完了
    inc     ENEMY_GENERATOR_STATE(iy)
09$:
    
    ; タイマの更新
    dec     ENEMY_GENERATOR_TIMER(iy)
    jr      nz, 19$
    ld      a, #0x10
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
    call    _SystemGetRandom
    and     #0x07
    add     a, a
    add     a, a
    add     a, a
    ld      c, a
    add     a, a
    add     a, c
    add     a, #0x20
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
_EnemyRugalUpdate::
    
    ; レジスタの保存
    
    ; 初期化の開始
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$
    
    ; パラメータの設定
    xor     a
    ld      ENEMY_PARAM_0(ix), a
    ld      a, ENEMY_TYPE(ix)
    sub     #ENEMY_TYPE_RUGAL_FRONT
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, #0x68
    ld      ENEMY_PARAM_1(ix), a
    
    ; ショットの設定
    call    _SystemGetRandom
    and     #0x3f
    add     #0x40
    ld      ENEMY_SHOT(ix), a
    
    ; アニメーションの設定
    ld      a, ENEMY_PARAM_1(ix)
    ld      ENEMY_ANIMATION(ix), a
    
    ; タイマの設定
    ld      a, #0x40
    ld      ENEMY_TIMER(ix), a
    
    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:
    
    ; 移動
    ld      a, ENEMY_TYPE(ix)
    cp      #ENEMY_TYPE_RUGAL_FRONT
    ld      a, ENEMY_POSITION_X(ix)
    jr      nz, 10$
    inc     a
    jr      z, 98$
    jr      11$
10$:
    or      a
    jr      z, 98$
    dec     a
11$:
    ld      ENEMY_POSITION_X(ix), a
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, ENEMY_PARAM_0(ix)
    cp      #0xc0
    jr      nc, 98$
    ld      ENEMY_POSITION_Y(ix), a
    
    ; 方向転換
    dec     ENEMY_TIMER(ix)
    jr      nz, 29$
    ld      a, (_ship + SHIP_POSITION_Y)
    sub     ENEMY_POSITION_Y(ix)
    jr      nc, 20$
    cp      #0xf8
    ld      a, #0x00
    sbc     #0x00
    jr      21$
20$:
    cp      #0x08
    ld      a, #0x01
    sbc     #0x00
21$:
    ld      ENEMY_PARAM_0(ix), a
    add     a, a
    add     a, ENEMY_PARAM_1(ix)
    ld      ENEMY_ANIMATION(ix), a
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x10
    ld      ENEMY_TIMER(ix), a
29$:

    ; ショットの更新
90$:
    dec     ENEMY_SHOT(ix)
    jr      nz, 99$
    ld      h, ENEMY_POSITION_X(ix)
    ld      l, ENEMY_POSITION_Y(ix)
    call    _BulletGenerate
    call    _SystemGetRandom
    and     #0x3f
    add     #0x40
    ld      ENEMY_SHOT(ix), a
    jr      99$
    
    ; 敵の削除
98$:
    xor     a
    ld      ENEMY_TYPE(ix), a
    
    ; 更新の完了
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

