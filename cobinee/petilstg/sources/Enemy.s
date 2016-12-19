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
    .include	"Game.inc"
    .include	"Unit.inc"
    .include	"Enemy.inc"

; マクロの定義
;

; データ
ENEMY_DATA_HP       =   0x00
ENEMY_DATA_ATTACK   =   0x01
ENEMY_DATA_INTERVAL =   0x02
ENEMY_DATA_X_SPEED  =   0x04
ENEMY_DATA_X_ACCEL  =   0x05
ENEMY_DATA_X_TARGET =   0x06
ENEMY_DATA_Y_SPEED  =   0x08
ENEMY_DATA_Y_ACCEL  =   0x09
ENEMY_DATA_Y_TARGET =   0x0a
ENEMY_DATA_Z_SPEED  =   0x0c
ENEMY_DATA_Z_ACCEL  =   0x0d
ENEMY_DATA_Z_TARGET =   0x0e
ENEMY_DATA_SIZE     =   0x10


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

; エネミーをリセットする
;
_EnemyReset::
    
    ; レジスタの保存
    
    ; 生成した／倒された数の初期化
    ld      hl, #_enemyBorned
    ld      de, #_enemyKilled
    xor     a
    ld      b, #UNIT_TYPE_N
0$:
    ld      (hl), a
    ld      (de), a
    inc     hl
    inc     de
    djnz    0$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを更新する
;
_EnemyUpdate::
    
    ; レジスタの保存
    
    ; エネミーの更新
    ld      ix, #(_unit + UNIT_ENEMY * UNIT_SIZE)
    ld      bc, #((UNIT_ENEMY_N << 8) + 0x00)
0$:
    push    bc
    ld      a, UNIT_TYPE(ix)
    or      a
    jr      nz, 1$
    call    EnemyBorn
    jr      9$
1$:
    ld      a, ENEMY_UNIT_HP(ix)
    or      a
    jr      nz, 2$
    call    EnemyBomb
    jr      9$
2$:
    call    EnemyDamage
    call    EnemyFire
    call    EnemyMove
9$:
    ld      de, #UNIT_SIZE
    add     ix, de
    pop     bc
    inc     c
    djnz    0$
    
    ; レジスタの復帰
    
    ; 終了
    ret
    
; エネミーを描画する
;
_EnemyRender::
    
    ; レジスタの保存
    
    ; レーダーの描画
    ld      ix, #(_unit + UNIT_ENEMY)
    ld      iy, #(_sprite + GAME_SPRITE_RADAR)
    ld      hl, #0x080f
    ld      b, #UNIT_ENEMY_N
0$:
    ld      a, UNIT_TYPE(ix)
    or      a
    jr      z, 1$
    ld      a, ENEMY_UNIT_HP(ix)
    or      a
    jr      z, 1$
    ld      a, UNIT_X_POSITION_H(ix)
    add     a, #0x20
    cp      #0x40
    jr      nc, 1$
    add     #(0x60 - 1)
    ld      c, a
    ld      a, UNIT_Z_POSITION_H(ix)
    add     a, #0x20
    cp      #0x40
    jr      nc, 1$
    add     a, #(0x80 - 1)
    ld      0x00(iy), a
    ld      0x01(iy), c
    ld      0x02(iy), h
    ld      0x03(iy), l
1$:
    ld      de, #0x04
    add     iy, de
    ld      de, #UNIT_SIZE
    add     ix, de
    djnz    0$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを生成する 
;
EnemyBorn:
    
    ; レジスタの保存
    
    ; 生成するエネミーの取得
    ld      a, (_enemyKilled + UNIT_TYPE_REGIT)
    cp      #0x04
    ld      a, #UNIT_TYPE_REGIT
    jp      c, 09$
    ld      a, (_enemyBorned + UNIT_TYPE_ZGOCKY)
    ld      e, a
    or      a
    ld      a, #UNIT_TYPE_ZGOCKY
    jp      z, 09$
    ld      a, (_enemyKilled + UNIT_TYPE_ZGOCKY)
    cp      #0x02
    jr      nc, 00$
    or      a
    ld      a, #UNIT_TYPE_REGIT
    jp      z, 09$
    cp      e
    ld      a, #UNIT_TYPE_ZGOCKY
    jr      z, 09$
    call    _SystemGetRandom
    and     #0x01
    add     a, #UNIT_TYPE_REGIT
    jr      09$
00$:
    ld      a, (_enemyBorned + UNIT_TYPE_GASTIMA)
    or      a
    ld      a, #UNIT_TYPE_GASTIMA
    jr      z, 09$
    ld      a, (_enemyKilled + UNIT_TYPE_GASTIMA)
    or      a
    jr      nz, 01$
    call    _SystemGetRandom
    and     #0x01
    add     a, #UNIT_TYPE_REGIT
    jr      09$
01$:
    ld      a, (_enemyBorned + UNIT_TYPE_MAZRASTER)
    or      a
    ld      a, #UNIT_TYPE_MAZRASTER
    jr      z, 09$
    ld      a, (_enemyKilled + UNIT_TYPE_MAZRASTER)
    or      a
    jr      nz, 02$
    ld      a, #UNIT_TYPE_ZGOCKY
    jr      09$
    call    _SystemGetRandom
    and     #0x03
    cp      #0x01
    adc     a, #(UNIT_TYPE_REGIT - 0x01)
    jr      09$
02$:
    ld      a, (_enemyBorned + UNIT_TYPE_YGGDRASILL)
    or      a
    jr      nz, 03$
    ld      a, (_enemyBorned + UNIT_TYPE_NULL)
    ld      e, a
    ld      a, (_enemyKilled + UNIT_TYPE_NULL)
    cp      e
    ld      a, #UNIT_TYPE_YGGDRASILL
    jr      z, 09$
    jp      90$
03$:
    ld      a, (_enemyKilled + UNIT_TYPE_YGGDRASILL)
    or      a
    jr      nz, 04$
    jp      90$
04$:
    ld      a, (_enemyBorned + UNIT_TYPE_G_RACH)
    or      a
    ld      a, #UNIT_TYPE_G_RACH
    jr      z, 09$
    ld      a, (_enemyBorned + UNIT_TYPE_KABAKALI)
    or      a
    ld      a, #UNIT_TYPE_KABAKALI
    jr      z, 09$
    ld      a, (_enemyKilled + UNIT_TYPE_G_RACH)
    ld      e, a
    ld      a, (_enemyKilled + UNIT_TYPE_KABAKALI)
    add     a, e
    cp      #0x02
    ld      a, #UNIT_TYPE_WUXIA
    jr      c, 09$
    jp      90$
09$:
    
    ; エネミーの生成
    ld      UNIT_TYPE(ix), a
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      iy, #enemyData
    add     iy, de
    ld      UNIT_COLOR(ix), d
    call    _SystemGetRandom
    sra     a
    sra     a
    ld      l, a
    ld      h, a
    call    _SystemGetRandom
    and     #0x03
    jr      nz, 10$
    ld      l, #-0x20
    jr      13$
10$:
    dec     a
    jr      nz, 11$
    ld      l, #0x20
    jr      13$
11$:
    dec     a
    jr      nz, 12$
    ld      h, #-0x20
    jr      13$
12$:
    ld      h, #0x20
13$:
    call    _SystemGetRandom
    sra     a
    sra     a
    sra     a
    sra     a
    ld      e, a
    ld      a, ENEMY_DATA_X_TARGET(iy)
    ld      UNIT_X_POSITION_L(ix), d
    ld      UNIT_X_POSITION_H(ix), h
    ld      a, ENEMY_DATA_Y_TARGET(iy)
    ld      UNIT_Y_POSITION_L(ix), d
    ld      UNIT_Y_POSITION_H(ix), e
    ld      a, ENEMY_DATA_Z_TARGET(iy)
    ld      UNIT_Z_POSITION_L(ix), d
    ld      UNIT_Z_POSITION_H(ix), l
    ld      a, ENEMY_DATA_HP(iy)
    ld      ENEMY_UNIT_HP(ix), a
    ld      ENEMY_UNIT_DAMAGE(ix), d
    ld      ENEMY_UNIT_ATTACK(ix), d
    ld      a, ENEMY_DATA_INTERVAL(iy)
    ld      ENEMY_UNIT_INTERVAL(ix), a
    call    _SystemGetRandom
    and     ENEMY_UNIT_INTERVAL(ix)
    add     a, #0x08
    ld      ENEMY_UNIT_FIRE(ix), a
    ld      a, ENEMY_DATA_X_SPEED(iy)
    sla     h
    jr      c, 14$
    neg
14$:
    ld      ENEMY_UNIT_X_SPEED(ix), d
    ld      ENEMY_UNIT_X_LIMIT(ix), a
    ld      a, ENEMY_DATA_X_ACCEL(iy)
    sra     a
    ld      ENEMY_UNIT_X_ACCEL(ix), a
    ld      a, ENEMY_DATA_Y_SPEED(iy)
    sla     e
    jr      c, 15$
    neg
15$:
    ld      ENEMY_UNIT_Y_SPEED(ix), d
    ld      ENEMY_UNIT_Y_LIMIT(ix), a
    ld      a, ENEMY_DATA_Y_ACCEL(iy)
    sra     a
    ld      ENEMY_UNIT_Y_ACCEL(ix), a
    ld      a, ENEMY_DATA_Z_SPEED(iy)
    sla     l
    jr      c, 16$
    neg
16$:
    ld      ENEMY_UNIT_Z_SPEED(ix), d
    ld      ENEMY_UNIT_Z_LIMIT(ix), a
    ld      a, ENEMY_DATA_Z_ACCEL(iy)
    sra     a
    ld      ENEMY_UNIT_Z_ACCEL(ix), a
    
    ; 生成した数の更新
    ld      e, UNIT_TYPE(ix)
    ld      d, #0x00
    ld      hl, #_enemyBorned
    inc     (hl)
    add     hl, de
    inc     (hl)
    
    ; スプライトジェネレータの設定
    ld      a, e
    ld      e, #(APP_SPRITE_GENERATOR_TABLE_0 >> 11)
    cp      #(UNIT_TYPE_MAZRASTER + 0x01)
    jr      c, 20$
    ld      e, #(APP_SPRITE_GENERATOR_TABLE_1 >> 11)
    cp      #(UNIT_TYPE_YGGDRASILL + 0x01)
    jr      c, 20$
    ld      e, #(APP_SPRITE_GENERATOR_TABLE_2 >> 11)
20$:
    ld      a, e
    ld      (_videoRegister + VDP_R6), a
    
    ; ビデオレジスタの転送
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; 生成の完了
90$:

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーがダメージを受ける
;
EnemyDamage:
    
    ; レジスタの保存
    
    ; ダメージの更新
    ld      a, ENEMY_UNIT_DAMAGE(ix)
    or      a
    jr      z, 0$
    dec     ENEMY_UNIT_DAMAGE(ix)
    ld      a, #0x01
0$:
    ld      UNIT_COLOR(ix), a

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーがショットを撃つ
;
EnemyFire:
    
    ; レジスタの保存
    
    ; ショットを撃つ
    ld      a, ENEMY_UNIT_DAMAGE(ix)
    or      a
    jr      nz, 9$
    ld      a, ENEMY_UNIT_ATTACK(ix)
    or      a
    jr      nz, 9$
    ld      a, ENEMY_UNIT_FIRE(ix)
    or      a
    jr      nz, 0$
    call    _SystemGetRandom
    and     #0x7f
    add     a, #0x40
    call    _SystemGetRandom
    and     ENEMY_UNIT_INTERVAL(ix)
    add     a, #0x08
    ld      ENEMY_UNIT_FIRE(ix), a
    jr      9$
0$:
    ld      a, UNIT_DIV_Z(ix)
    or      a
    jr      z, 9$
    dec     ENEMY_UNIT_FIRE(ix)
    jr      nz, 9$
    ld      a, UNIT_TYPE(ix)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #(enemyData + ENEMY_DATA_ATTACK)
    add     hl, de
    ld      a, (hl)
    ld      ENEMY_UNIT_ATTACK(ix), a
9$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーが移動する
;
EnemyMove:
    
    ; レジスタの保存
    
    ; データの取得
    ld      a, UNIT_TYPE(ix)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      iy, #enemyData
    add     iy, de
    
    ; Ｘの移動
    dec     ENEMY_UNIT_X_ACCEL(ix)
    jr      nz, 03$
    ld      a, ENEMY_UNIT_X_LIMIT(ix)
    cp      ENEMY_UNIT_X_SPEED(ix)
    jr      z, 01$
    jp      m, 00$
    inc     ENEMY_UNIT_X_SPEED(ix)
    jr      02$
00$:
    dec     ENEMY_UNIT_X_SPEED(ix)
    jr      02$
01$:
    ld      a, UNIT_X_POSITION_H(ix)
    sub     ENEMY_DATA_X_TARGET(iy)
    xor     ENEMY_UNIT_X_SPEED(ix)
    jp      m, 02$
    ld      a, ENEMY_UNIT_X_LIMIT(ix)
    neg
    ld      ENEMY_UNIT_X_LIMIT(ix), a
02$:
    ld      a, ENEMY_DATA_X_ACCEL(iy)
    ld      ENEMY_UNIT_X_ACCEL(ix), a
03$:
    ld      e, ENEMY_UNIT_X_SPEED(ix)
    ld      d, e
    xor     a
    rl      d
    sbc     #0x00
    ld      d, a
    ld      l, UNIT_X_POSITION_L(ix)
    ld      h, UNIT_X_POSITION_H(ix)
    add     hl, de
    add     hl, de
    add     hl, de
    add     hl, de
    ld      UNIT_X_POSITION_L(ix), l
    ld      UNIT_X_POSITION_H(ix), h
    
    ; Ｙの移動
    dec     ENEMY_UNIT_Y_ACCEL(ix)
    jr      nz, 13$
    ld      a, ENEMY_UNIT_Y_LIMIT(ix)
    cp      ENEMY_UNIT_Y_SPEED(ix)
    jr      z, 11$
    jp      m, 10$
    inc     ENEMY_UNIT_Y_SPEED(ix)
    jr      12$
10$:
    dec     ENEMY_UNIT_Y_SPEED(ix)
    jr      12$
11$:
    ld      a, UNIT_Y_POSITION_H(ix)
    sub     ENEMY_DATA_Y_TARGET(iy)
    xor     ENEMY_UNIT_Y_SPEED(ix)
    jp      m, 12$
    ld      a, ENEMY_UNIT_Y_LIMIT(ix)
    neg
    ld      ENEMY_UNIT_Y_LIMIT(ix), a
12$:
    ld      a, ENEMY_DATA_Y_ACCEL(iy)
    ld      ENEMY_UNIT_Y_ACCEL(ix), a
13$:
    ld      e, ENEMY_UNIT_Y_SPEED(ix)
    ld      d, e
    xor     a
    rl      d
    sbc     #0x00
    ld      d, a
    ld      l, UNIT_Y_POSITION_L(ix)
    ld      h, UNIT_Y_POSITION_H(ix)
    add     hl, de
    add     hl, de
    add     hl, de
    add     hl, de
    ld      UNIT_Y_POSITION_L(ix), l
    ld      UNIT_Y_POSITION_H(ix), h
    
    ; Ｚの移動
    dec     ENEMY_UNIT_Z_ACCEL(ix)
    jr      nz, 23$
    ld      a, ENEMY_UNIT_Z_LIMIT(ix)
    cp      ENEMY_UNIT_Z_SPEED(ix)
    jr      z, 21$
    jp      m, 20$
    inc     ENEMY_UNIT_Z_SPEED(ix)
    jr      22$
20$:
    dec     ENEMY_UNIT_Z_SPEED(ix)
    jr      22$
21$:
    ld      a, UNIT_Z_POSITION_H(ix)
    sub     ENEMY_DATA_Z_TARGET(iy)
    xor     ENEMY_UNIT_Z_SPEED(ix)
    jp      m, 22$
    ld      a, ENEMY_UNIT_Z_LIMIT(ix)
    neg
    ld      ENEMY_UNIT_Z_LIMIT(ix), a
22$:
    ld      a, ENEMY_DATA_Z_ACCEL(iy)
    ld      ENEMY_UNIT_Z_ACCEL(ix), a
23$:
    ld      e, ENEMY_UNIT_Z_SPEED(ix)
    ld      d, e
    xor     a
    rl      d
    sbc     #0x00
    ld      d, a
    ld      l, UNIT_Z_POSITION_L(ix)
    ld      h, UNIT_Z_POSITION_H(ix)
    add     hl, de
    add     hl, de
    add     hl, de
    add     hl, de
    ld      UNIT_Z_POSITION_L(ix), l
    ld      UNIT_Z_POSITION_H(ix), h
    
    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーが爆発する 
;
EnemyBomb:
    
    ; レジスタの保存
    
    ; 爆発の更新
    ld      a, ENEMY_UNIT_DAMAGE(ix)
    dec     a
    ld      ENEMY_UNIT_DAMAGE(ix), a
    jr      z, 01$
    ld      a, UNIT_TYPE(ix)
    cp      #UNIT_TYPE_BOMB_0
    jr      nc, 00$
    ld      e, a
    ld      d, #0x00
    ld      hl, #_enemyKilled
    inc     (hl)
    add     hl, de
    inc     (hl)
00$:
    ld      a, ENEMY_UNIT_DAMAGE(ix)
    rra
    rra
    and     #0x01
    add     #UNIT_TYPE_BOMB_0
01$:
    ld      UNIT_TYPE(ix), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; データ
;
enemyData:

    .db       0,   0,   0,   0      ; 0 : ---
    .db       0,   0,   0,   0
    .db       0,   0,   0,   0
    .db       0,   0,   0,   0
    .db       1,   9,  63,   0      ; 1 : REGIT
;   .db       2, 128,  63,   0      ; 1 : REGIT
    .db      12,   4,   0,   0
    .db       4,   4,   0,   0
    .db      12,   6, -12,   0
    .db       2,  18,  31,   0      ; 2 : Z'GOCKY
    .db       8,   4,   0,   0
    .db       6,   4,   0,   0
    .db       8,  16,  -8,   0
    .db       4,  18,  15,   0      ; 3 : GASTIMA
    .db      12,   4,   0,   0
    .db       6,   4,   0,   0
    .db      12,   3,  -8,   0
    .db       8,  27,  15,   0      ; 4 : MAZRASTER
    .db       6,   6,   0,   0
    .db       3,   6,   0,   0
    .db       5,  12,  -6,   0
    .db      64,  36,  31,   0      ; 5 : YGGDRASILL
    .db       3,   9,   0,   0
    .db       3,   6,   0,   0
    .db       3,  12,  -6,   0
    .db       2,  18,  31,   0      ; 6 : WUXIA
    .db      12,   4,   0,   0
    .db       6,   4,   0,   0
    .db      12,   3,  -8,   0
    .db      48,  54,  15,   0      ; 7 : G-RACH
    .db       4,   8,   0,   0
    .db       4,   6,   0,   0
    .db       4,  12,  -8,   0
    .db      32,  27,   3,   0      ; 8 : KABAKALI
    .db      10,   4,   0,   0
    .db       6,   4,   0,   0
    .db      12,   3,  -8,   0

; ＳＥ
;
enemySeHit:

    .ascii  "T1V15L0O4CO3BAG-EDCO2BA"
    .db     0x00

enemySeBomb:

    .ascii  "T1V15L0O4CO3BAG-EDCO2BA"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 生成した数
;
_enemyBorned::

    .ds     UNIT_TYPE_N
    
; 倒された数
;
_enemyKilled::

    .ds     UNIT_TYPE_N
