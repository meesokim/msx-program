; EnemyBomb.s : 敵／爆発
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
    .include	"Enemy.inc"
    .include    "Bullet.inc"

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 敵を生成する
;
_EnemyBombGenerate::
    
    ; レジスタの保存
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 敵を更新する
;
_EnemyBombUpdate::
    
    ; レジスタの保存
    
    ; 初期化の開始
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$
    
    ; アニメーションの設定
    ld      a, #0x40
    ld      ENEMY_ANIMATION(ix), a
    
    ; タイマの設定
    ld      a, #0x02
    ld      ENEMY_TIMER(ix), a
    
    ; 撃ち返し
    ld      h, ENEMY_POSITION_X(ix)
    ld      l, ENEMY_POSITION_Y(ix)
    call    _BulletGenerate

    ; ＳＥの再生
    ld      hl, #enemyBombSe
    ld      (_soundRequest + 0x0006), hl
    
    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:
    
    ; アニメーションの更新
90$:
    dec     ENEMY_TIMER(ix)
    jr      nz, 99$
    ld      a, ENEMY_ANIMATION(ix)
    add     a, #0x02
    cp      #0x46
    jr      nc, 98$
    ld      ENEMY_ANIMATION(ix), a
    ld      a, #0x02
    ld      ENEMY_TIMER(ix), a
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

; 敵を描画する
;
_EnemyBombRender::
    
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
    ld      a, ENEMY_ANIMATION(ix)
    ld      b, ENEMY_INDEX(ix)
    rr      c
    jr      nc, 10$
    ld      (hl), a
10$:
    inc     hl
    inc     a
    rr      c
    jr      nc, 11$
    ld      (hl), a
11$:
    ld      de, #0x001f
    add     hl, de
    add     a, #0x0f
    rr      c
    jr      nc, 12$
    ld      (hl), a
12$:
    inc     hl
    inc     a
    rr      c
    jr      nc, 13$
    ld      (hl), a
13$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; ＳＥ
;
enemyBombSe:

    .ascii  "T1V15L0O4GFEDCO3BAG"
    .db     0x00

; DATA 領域
;
    .area   _DATA

; 変数の定義
;

