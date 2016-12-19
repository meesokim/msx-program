; EnemyBigCore.s : 敵／ビッグコア
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

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 敵を生成する
;
_EnemyBigCoreGenerate::
    
    ; レジスタの保存
    
    ; ジェネレータの取得
    ld      iy, #_enemyGenerator
    
    ; 敵の生成／コア
    call    _EnemyGetEmpty
;   jr      c, 09$
    ld      a, #ENEMY_TYPE_BIGCORE_CORE
    ld      ENEMY_TYPE(ix), a
    xor     a
    ld      ENEMY_STATE(ix), a
    ld      a, #0xa0
    ld      ENEMY_POSITION_X(ix), a
    ld      a, #0xe0
    ld      ENEMY_POSITION_Y(ix), a
    ld      a, #0xe
    ld      ENEMY_HP(ix), a
    ld      ENEMY_PARAM_0(ix), a
    
    ; コアの保存
    push    ix
    
    ; 敵の生成／ボディ
    call    _EnemyGetEmpty
;   jr      c, 09$
    ld      a, #ENEMY_TYPE_BIGCORE_BODY
    ld      ENEMY_TYPE(ix), a
    xor     a
    ld      ENEMY_STATE(ix), a
;   ld      a, #0xa0
;   ld      ENEMY_POSITION_X(ix), a
;   ld      a, #0xe0
;   ld      ENEMY_POSITION_Y(ix), a
    ld      a, #0xff
    ld      ENEMY_HP(ix), a
    
    ; コアの参照の取得
    pop     hl
    ld      ENEMY_PARAM_0(ix), l
    ld      ENEMY_PARAM_1(ix), h
    
    ; 生成の完了
    xor     a
    ld      ENEMY_GENERATOR_TYPE(iy), a
    ld      ENEMY_GENERATOR_STATE(iy), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 敵を更新する／コア
;
_EnemyBigCoreUpdateCore::
    
    ; レジスタの保存
    
    ; 初期化の開始
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$
    
    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:
    
    ; 登場
    ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 19$
    ld      a, ENEMY_POSITION_Y(ix)
    cp      #0x61
    jr      c, 10$
    sub     #0x04
    ld      ENEMY_POSITION_Y(ix), a
    jp      nc, 90$
10$:
    ld      a, ENEMY_POSITION_X(ix)
    cp      #0x39
    jr      c, 11$
    sub     #0x04
    ld      ENEMY_POSITION_X(ix), a
    jp      nc, 90$
11$:
    ld      a, #0x02
    ld      ENEMY_STATE(ix), a
    jp      90$
19$:
    
    ; ビームを撃つ
    dec     a
    jr      nz, 29$
    ld      h, ENEMY_POSITION_X(ix)
    ld      l, ENEMY_POSITION_Y(ix)
    call    _EnemyBeamGenerate
    ld      a, #0x20
    ld      ENEMY_TIMER(ix), a
    ld      a, #0x03
    ld      ENEMY_STATE(ix), a
    jp      90$
29$:
    
    ; 待機
    dec     a
    jr      nz, 39$
    dec     ENEMY_TIMER(ix)
    jr      nz, 90$
    call    _SystemGetRandom
    and     #0x18
    add     a, #0x18
    ld      c, a
    ld      a, (_ship + SHIP_POSITION_Y)
    ld      b, a
    ld      a, ENEMY_POSITION_Y(ix)
    cp      #0x88
    jr      nc, 30$
    cp      #0x38
    jr      c, 32$
    cp      b
    jr      c, 32$
    jr      nz, 30$
    cp      #0x64
    jr      c, 32$
;   jr      30$
30$:
    sub     c
    cp      #0x28
    jr      nc, 31$
    ld      a, #0x28
31$:
    ld      ENEMY_TIMER(ix), a
    ld      a, #0x04
    ld      ENEMY_STATE(ix), a
    jr      90$
32$:
    add     a, c
    cp      #0x98
    jr      c, 33$
    ld      a, #0x98
33$:
    ld      ENEMY_TIMER(ix), a
    ld      a, #0x05
    ld      ENEMY_STATE(ix), a
    jr      90$
39$:
    
    ; 移動↑
    dec     a
    jr      nz, 49$
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #0x04
    ld      ENEMY_POSITION_Y(ix), a
    cp      ENEMY_TIMER(ix)
    jr      nc, 90$
    ld      a, ENEMY_TIMER(ix)
    ld      ENEMY_POSITION_Y(ix), a
    ld      a, #0x02
    ld      ENEMY_STATE(ix), a
    jr      90$
49$:
    
    ; 移動↓
;   dec     a
;   jr      nz, 59$
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, #0x04
    ld      ENEMY_POSITION_Y(ix), a
    cp      ENEMY_TIMER(ix)
    jr      c, 90$
    ld      a, ENEMY_TIMER(ix)
    ld      ENEMY_POSITION_Y(ix), a
    ld      a, #0x02
    ld      ENEMY_STATE(ix), a
;   jr      90$
59$:
    
    ; ＨＰの監視
90$:
    ld      a, ENEMY_HP(ix)
    cp      ENEMY_PARAM_0(ix)
    jr      z, 91$
    ld      ENEMY_PARAM_0(ix), a
    
    ; ＳＥの再生
    ld      hl, #enemyBigCoreSeHit
    ld      (_soundRequest + 0x0006), hl
91$:
    
    ; 更新の完了
;99$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 敵を更新する／ボディ
;
_EnemyBigCoreUpdateBody::
    
    ; レジスタの保存
    
    ; 初期化の開始
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$
    
    ; アニメーションの設定
    ld      a, #0x0c
    ld      ENEMY_ANIMATION(ix), a
    
    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:
    
    ; ＨＰの再設定
    ld      a, #0xff
    ld      ENEMY_HP(ix), a
    
    ; コアの取得
    ld      l, ENEMY_PARAM_0(ix)
    ld      h, ENEMY_PARAM_1(ix)
    push    hl
    pop     iy
    
    ; コアの監視
    ld      a, ENEMY_TYPE(iy)
    cp      #ENEMY_TYPE_BIGCORE_CORE
    jr      nz, 19$
    ld      a, ENEMY_POSITION_X(iy)
    ld      ENEMY_POSITION_X(ix), a
    ld      a, ENEMY_POSITION_Y(iy)
    ld      ENEMY_POSITION_Y(ix), a
    jr      99$
19$:

    ; アニメーションの監視
    ld      a, ENEMY_ANIMATION(ix)
    cp      #0x0c
    jr      nz, 20$
    
    ; ＳＥの再生
    ld      hl, #enemyBigCoreSeBomb
    ld      (_soundRequest + 0x0006), hl
20$:
    
    ; アニメーションの更新
    dec     ENEMY_ANIMATION(ix)
    jr      nz, 99$
    
    ; 敵の削除
    xor     a
    ld      ENEMY_TYPE(ix), a

    ; 更新の完了
99$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 敵を描画する／コア
;
_EnemyBigCoreRenderCore::
    
    ; レジスタの保存
    
    ; 位置の取得
    ld      a, ENEMY_POSITION_Y(ix)
    and     #0xf8
    ld      b, #0x00
    add     a, a
    rl      b
    add     a, a
    rl      b
    ld      c, ENEMY_POSITION_X(ix)
    srl     c
    srl     c
    srl     c
    add     a, c
    sub     #0x06
    ld      c, a
    
    ; パターンを置く
    ld      a, ENEMY_POSITION_Y(ix)
    cp      #0xc0
    jr      nc, 19$
    ld      hl, #_appPatternName
    add     hl, bc
    ex      de, hl
    ld      iy, #_enemyCollision
    add     iy, bc
    ld      a, ENEMY_HP(ix)
    add     a, #0x01
    rla
    rla
    rla
    and     #0xf0
    ld      c, a
    ld      b, #0x00
    ld      hl, #enemyBigCoreCorePatternName
    add     hl, bc
    ld      c, ENEMY_INDEX(ix)
    ld      b, #0x0c
10$:
    ld      a, (hl)
    or      a
    jr      z, 11$
    ld      (de), a
    ld      0(iy), c
11$:
    inc     hl
    inc     de
    inc     iy
    djnz    10$
19$:
    
    ; レジスタの復帰
    
    ; 終了
    ret
    
; 敵を描画する／ボディ
;
_EnemyBigCoreRenderBody::
    
    ; レジスタの保存
    
    ; 位置の取得
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #0x20
    and     #0xf8
    ld      b, #0x00
    add     a, a
    rl      b
    add     a, a
    rl      b
    ld      c, ENEMY_POSITION_X(ix)
    srl     c
    srl     c
    srl     c
    add     a, c
    sub     #0x06
    ld      c, a
    
    ; パターンを置く
    ld      hl, #_appPatternName
    add     hl, bc
    ex      de, hl
    ld      iy, #_enemyCollision
    add     iy, bc
    ld      hl, #enemyBigCoreBodyPatternName
    ld      c, ENEMY_INDEX(ix)
    ld      b, ENEMY_POSITION_Y(ix)
    srl     b
    srl     b
    srl     b
    ld      a, #0x1b
    sub     b
    jr      c, 19$
    inc     a
    cp      #0x09
    jr      c, 10$
    ld      a, #0x09
10$:
    ld      b, a
11$:
    push    bc
    ld      b, ENEMY_ANIMATION(ix)
12$:
    ld      a, (hl)
    or      a
    jr      z, 13$
    ld      (de), a
    ld      0(iy), c
13$:
    inc     hl
    inc     de
    inc     iy
    djnz    12$
    ld      a, #0x0c
    sub     ENEMY_ANIMATION(ix)
    ld      c, a
;   ld      b, #0x00
    add     hl, bc
    add     a, #0x14
    ld      c, a
    ex      de, hl
    add     hl, bc
    ex      de, hl
    add     iy, bc
    pop     bc
    djnz    11$
19$:

    ; レジスタの復帰
    
    ; 終了
    ret
    
; 定数の定義
;

; パターンネーム
;
enemyBigCoreCorePatternName:

    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0xb1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0xb1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0xb1, 0x00, 0xb3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0xb1, 0x00, 0xb2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0xb1, 0x00, 0xb2, 0xb3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0xb1, 0x00, 0xb2, 0xb2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0xb1, 0x00, 0xb2, 0xb2, 0xb3, 0x00, 0x00, 0x00, 0x00, 0x00

enemyBigCoreBodyPatternName:

    .db     0x00, 0x00, 0x60, 0x00, 0x00, 0x61, 0x62, 0x63, 0x00, 0x00, 0x00, 0x00
    .db     0x64, 0x65, 0x66, 0x67, 0x68, 0xa0, 0x69, 0x6a, 0x6b, 0x00, 0x00, 0x00
    .db     0x6c, 0x6d, 0x6e, 0x6f, 0xa0, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x00
    .db     0x76, 0x77, 0x78, 0xa0, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7e, 0x7f
    .db     0xa1, 0xa2, 0xa3, 0xa0, 0xa4, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x86, 0x87, 0x88, 0xa0, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8e, 0x8f
    .db     0x9c, 0x9d, 0x9e, 0x9f, 0xa0, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x00
    .db     0x94, 0x95, 0x96, 0x97, 0x98, 0xa0, 0x99, 0x9a, 0x9b, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x90, 0x00, 0x00, 0x91, 0x92, 0x93, 0x00, 0x00, 0x00, 0x00

; ＳＥ
;
enemyBigCoreSeHit:

    .ascii  "T1V15-L0O7A"
    .db     0x00

enemyBigCoreSeBomb:

    .ascii  "T1V15L0"
    .ascii  "O3GO2D-O3EO2D-O3CO2D-O2GD-ED-"
    .ascii  "O2CO1D-O2D-O1CO2CO1D-O2D-O1CO2CO1D-O2D-O1CO2CO1D-O2D-O1C"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

