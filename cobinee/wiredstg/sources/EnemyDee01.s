; EnemyDee01.s : 敵／ディー０１
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
_EnemyDee01Generate::
    
    ; レジスタの保存
    
    ; ジェネレータの取得
    ld      iy, #_enemyGenerator
    
    ; 初期化の開始
    ld      a, ENEMY_GENERATOR_STATE(iy)
    or      a
    jr      nz, 09$
    
    ; 地面のチェック
    ld      a, ENEMY_GENERATOR_TYPE(iy)
    cp      #ENEMY_TYPE_DEE01_UPPER
    jr      nz, 00$
    ld      a, (_groundGenerator + GROUND_GENERATOR_UPPER_STATE)
    cp      #GROUND_GENERATOR_STATE_FLAT
    jr      nz, 18$
    ld      a, (_groundGenerator + GROUND_GENERATOR_UPPER_LENGTH)
    cp      #0x08
    jr      c, 18$
    jr      01$
00$:
    ld      a, (_groundGenerator + GROUND_GENERATOR_LOWER_STATE)
    cp      #GROUND_GENERATOR_STATE_FLAT
    jr      nz, 18$
    ld      a, (_groundGenerator + GROUND_GENERATOR_LOWER_LENGTH)
    cp      #0x08
    jr      c, 18$
01$:
    
    ; 生成数の設定
    call    _SystemGetRandom
    and     #0x03
    jr      nz, 02$
    inc     a
02$:
    ld      ENEMY_GENERATOR_LENGTH(iy), a
    
    ; タイマの設定
    ld      a, #0x02
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
    ld      a, #0x02
    ld      ENEMY_GENERATOR_TIMER(iy), a
    
    ; 生成の開始
    call    _EnemyGetEmpty
    jr      c, 19$
    
    ; 敵の生成
    ld      a, ENEMY_GENERATOR_TYPE(iy)
    ld      ENEMY_TYPE(ix), a
    xor     a
    ld      ENEMY_STATE(ix), a
    ld      ENEMY_POSITION_X(ix), a
    ld      a, ENEMY_TYPE(ix)
    cp      #ENEMY_TYPE_DEE01_UPPER
    ld      a, #0x18
    jr      z, 10$
    ld      a, #0xb0
10$:
    ld      ENEMY_POSITION_Y(ix), a
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
_EnemyDee01Update::
    
    ; レジスタの保存
    
    ; 初期化の開始
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$
    
    ; パラメータの設定
    xor     a
    ld      ENEMY_PARAM_0(ix), a
    
    ; ショットの設定
    call    _SystemGetRandom
    and     #0x3f
    add     #0x40
    ld      ENEMY_SHOT(ix), a
    
    ; アニメーションの設定
;   xor     a
;   ld      ENEMY_ANIMATION(ix), a
    
    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:
    
    ; 移動（→）
    ld      a, (_gameScroll)
    or      a
    jr      nz, 19$
    ld      a, ENEMY_POSITION_X(ix)
    add     a, #0x08
    jp      c, 98$
    ld      ENEMY_POSITION_X(ix), a
19$:
    
    ; 向きの取得
    ld      a, ENEMY_TYPE(ix)
    cp      #ENEMY_TYPE_DEE01_UPPER
    jr      nz, 22$
    ld      h, ENEMY_POSITION_X(ix)
    ld      l, ENEMY_POSITION_Y(ix)
    ld      a, (_ship + SHIP_POSITION_X)
    srl     a
    srl     h
    sub     h
    ld      h, a
    ld      a, #0x40
    jr      c, 20$
    ld      a, (_ship + SHIP_POSITION_Y)
    srl     a
    srl     l
    sub     l
    ld      l, a
    ld      a, #0x00
    jr      c, 20$
    call    _SystemGetAtan2
20$:
    ld      c, #0x00
    cp      #0x10
    jr      c, 21$
    inc     c
    cp      #0x30
    jr      c, 21$
    inc     c
21$:
    ld      a, c
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, #0xac
    ld      ENEMY_ANIMATION(ix), a
    jr      29$
22$:
    ld      h, ENEMY_POSITION_X(ix)
    ld      l, ENEMY_POSITION_Y(ix)
    ld      a, (_ship + SHIP_POSITION_X)
    srl     a
    srl     h
    sub     h
    ld      h, a
    ld      a, #0xc0
    jr      c, 23$
    ld      a, (_ship + SHIP_POSITION_Y)
    srl     a
    srl     l
    sub     l
    ld      l, a
    ld      a, #0x00
    jr      nc, 23$
    call    _SystemGetAtan2
23$:
    or      a
    jr      nz, 24$
    dec     a
24$:
    ld      c, #0x00
    or      a
    jr      z, 25$
    cp      #0xf0
    jr      nc, 25$
    inc     c
    cp      #0xd0
    jr      nc, 25$
    inc     c
25$:
    ld      a, c
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, #0xae
    ld      ENEMY_ANIMATION(ix), a
;   jr      29$
29$:
    
    ; ショットの更新
90$:
    ld      a, (_ship + SHIP_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    jr      c, 99$
    dec     ENEMY_SHOT(ix)
    jr      nz, 99$
    ld      h, ENEMY_POSITION_X(ix)
    ld      l, ENEMY_POSITION_Y(ix)
    call    _BulletGenerate
    call    _SystemGetRandom
    and     #0x3f
    add     #0x30
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

