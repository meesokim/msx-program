; EnemyDucker.s : 敵／ダッカー
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
    .include    "Ground.inc"
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
_EnemyDuckerGenerate::
    
    ; レジスタの保存
    
    ; ジェネレータの取得
    ld      iy, #_enemyGenerator
    
    ; 初期化の開始
    ld      a, ENEMY_GENERATOR_STATE(iy)
    or      a
    jr      nz, 09$
    
    ; 地面のチェック
    ld      a, (_ground + 0x003f)
    or      a
    jr      z, 18$
    
    ; 生成数の設定
    ld      a, #0x01
    ld      ENEMY_GENERATOR_LENGTH(iy), a
    
    ; タイマの設定
    ld      a, #0x01
    ld      ENEMY_GENERATOR_TIMER(iy), a
    
    ; 初期化の完了
    inc     ENEMY_GENERATOR_STATE(iy)
09$:
    
    ; スクロールの監視
    ld      a, (_gameScroll)
    or      a
    jr      nz, 19$
    
    ; タイマの更新
    dec     ENEMY_GENERATOR_TIMER(iy)
    jr      nz, 19$
    ld      a, #0x20
    ld      ENEMY_GENERATOR_TIMER(iy), a
    
    ; 生成の開始
    call    _EnemyGetEmpty
    jr      c, 19$
    
    ; 敵の生成
    ld      a, ENEMY_GENERATOR_TYPE(iy)
    ld      ENEMY_TYPE(ix), a
    xor     a
    ld      ENEMY_STATE(ix), a
    call    _SystemGetRandom
    cp      #0x40
    ld      a, #0x00
    sbc     #0x00
    ld      ENEMY_POSITION_X(ix), a
    ld      a, #0x01
    ld      ENEMY_HP(ix), a
    
    ; 生成数の更新
    dec     ENEMY_GENERATOR_LENGTH(iy)
    jr      nz, 19$
    
    ; 生成の完了
18$:
    xor     a
    ld      ENEMY_GENERATOR_TYPE(iy), a
    ld      ENEMY_GENERATOR_STATE(iy), a
19$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 敵を更新する
;
_EnemyDuckerUpdate::
    
    ; レジスタの保存
    
    ; 初期化の開始
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$
    
    ; パラメータの設定
    xor     a
    ld      ENEMY_PARAM_0(ix), a
    ld      a, #0x04
    ld      ENEMY_PARAM_1(ix), a
    ld      a, ENEMY_TYPE(ix)
    sub     #ENEMY_TYPE_DUCKER_UPPER
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, #0xc0
    ld      ENEMY_PARAM_2(ix), a
    
    ; ショットの設定
    ld      a, #0x10
    ld      ENEMY_SHOT(ix), a
    
    ; アニメーションの設定
;   xor     a
;   ld      ENEMY_ANIMATION(ix), a
    
    ; タイマの設定
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x20
    ld      ENEMY_TIMER(ix), a
    
    ; 初期化の完了
    ld      a, ENEMY_POSITION_X(ix)
    cp      #0x80
    ld      a, #0x02
    sbc     #0x00
    ld      ENEMY_STATE(ix), a
09$:
    
    ; 移動（→）
    ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 19$
    ld      a, ENEMY_POSITION_X(ix)
    add     a, #0x02
    jp      c, 98$
    ld      ENEMY_POSITION_X(ix), a
    ld      a, ENEMY_TIMER(ix)
    and     #0x04
    srl     a
    add     a, ENEMY_PARAM_2(ix)
    ld      ENEMY_ANIMATION(ix), a
    dec     ENEMY_TIMER(ix)
    jp      nz, 80$
    call    _SystemGetRandom
    and     #0x1f
    add     a, #0x10
    ld      ENEMY_TIMER(ix), a
    ld      a, #0x03
    ld      ENEMY_STATE(ix), a
    jp      80$
19$:
    
    ; 移動（←）
;   ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 29$
    ld      a, ENEMY_POSITION_X(ix)
    sub     #0x02
    jp      c, 98$
    ld      ENEMY_POSITION_X(ix), a
    ld      a, ENEMY_TIMER(ix)
    and     #0x04
    srl     a
    add     a, #0x06
    add     a, ENEMY_PARAM_2(ix)
    ld      ENEMY_ANIMATION(ix), a
    dec     ENEMY_TIMER(ix)
    jr      nz, 80$
    call    _SystemGetRandom
    and     #0x1f
    add     a, #0x10
    ld      ENEMY_TIMER(ix), a
    ld      a, #0x03
    ld      ENEMY_STATE(ix), a
    jr      80$
29$:
    
    ; 待機
;   ld      a, ENEMY_STATE(ix)
;   dec     a
;   jr      nz, 39$
    ld      a, (_gameScroll)
    or      a
    jr      nz, 30$
    ld      a, ENEMY_POSITION_X(ix)
    add     a, #0x08
    jp      c, 98$
    ld      ENEMY_POSITION_X(ix), a
30$:
    dec     ENEMY_SHOT(ix)
    jr      nz, 31$
    ld      h, ENEMY_POSITION_X(ix)
    ld      l, ENEMY_POSITION_Y(ix)
    call    _BulletGenerate
    call    _SystemGetRandom
    and     #0x0f
    add     #0x10
    ld      ENEMY_SHOT(ix), a
31$:
    ld      a, (_ship + SHIP_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    ld      a, #0x04
    jr      nc, 32$
    ld      a, #0x0a
32$:
    add     a, ENEMY_PARAM_2(ix)
    ld      ENEMY_ANIMATION(ix), a
    dec     ENEMY_TIMER(ix)
    jr      nz, 80$
    xor     a
    dec     ENEMY_PARAM_1(ix)
    jr      z, 33$
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x10
33$:
    ld      ENEMY_TIMER(ix), a
    ld      a, (_ship + SHIP_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    ld      a, #0x01
    adc     a, #0x00
    ld      ENEMY_STATE(ix), a
39$:
    
    ; 高さの取得
80$:
    ld      a, ENEMY_POSITION_X(ix)
    srl     a
    srl     a
    srl     a
    ld      e, a
    ld      d, #0x00
    ld      a, ENEMY_TYPE(ix)
    cp      #ENEMY_TYPE_DUCKER_UPPER
    jr      nz, 82$
    ld      hl, #(_ground + 0x0020)
    add     hl, de
    ld      e, #0x20
    ld      bc, #0x0810
81$:
    ld      a, (hl)
    or      a
    jr      z, 89$
    add     hl, de
    ld      a, c
    add     a, b
    ld      c, a
    jr      81$
82$:
    ld      hl, #(_ground + 0x02e0)
    add     hl, de
    ld      e, #0x20
    ld      bc, #0x08b8
83$:
    ld      a, (hl)
    or      a
    jr      z, 89$
    sbc     hl, de
    ld      a, c
    sub     b
    ld      c, a
    jr      83$
89$:
    ld      ENEMY_POSITION_Y(ix), c
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

