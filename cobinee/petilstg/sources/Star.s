; Star.s : スター
;


; モジュール宣言
;
    .module Star

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include	"Star.inc"

; マクロの定義
;

; スター
STAR_N              =   0x10
STAR_E              =   0x00
STAR_COUNT          =   0x01
STAR_X_POSITION     =   0x02
STAR_X_DISTANCE     =   0x03
STAR_X_MOVE         =   0x04
STAR_Y_POSITION     =   0x05
STAR_Y_DISTANCE     =   0x06
STAR_Y_MOVE         =   0x07
STAR_SIZE           =   0x08


; CODE 領域
;
    .area   _CODE

; スターを初期化する
;
_StarInitialize::
    
    ; レジスタの保存
    
    ; スターの初期化
    ld      ix, #star
    ld      de, #STAR_SIZE
    ld      bc, #((STAR_N << 8) + 0x00)
0$:
    call    _SystemGetRandom
    and     #0x3f
    sub     #0x20
    ld      h, a
    call    _SystemGetRandom
    and     #0x1f
    sub     #0x14
    ld      l, a
    or      h
    jr      nz, 1$
    dec     l
1$:
    ld      0x00(ix), c
    ld      0x01(ix), c
    ld      0x02(ix), h
    ld      0x03(ix), c
    ld      0x04(ix), c
    ld      0x05(ix), l
    ld      0x06(ix), c
    ld      0x07(ix), c
    add     ix, de
    djnz    0$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; スターを更新する
;
_StarUpdate::
    
    ; レジスタの保存
    
    ; 速度の取得
    ld      a, (_gameMoveZ)
    ld      c, a
    ld      a, #0x80
    sub     c
    rra
    rra
    rra
    rra
    and     #0x0f
    ld      (starMoveZ), a
    ld      a, (_gameAccel)
    inc     a
    ld      (starAccel), a
    
    ; 移動の開始
    ld      ix, #star
    ld      b, #STAR_N
00$:
    push    bc
    
    ; 距離の取得
    ld      a, STAR_X_DISTANCE(ix)
    or      STAR_Y_DISTANCE(ix)
    jr      nz, 19$
    ld      d, STAR_X_POSITION(ix)
    ld      e, STAR_Y_POSITION(ix)
    ld      a, (_gameRotateY)
    or      a
    jp      p, 10$
    ld      a, d
    add     a, #0x20
    ld      d, a
    jr      11$
10$:
    jr      z, 11$
    ld      a, d
    sub     #0x20
    ld      d, a
11$:
    ld      a, (_gameRotateX)
    or      a
    jp      p, 12$
    ld      a, e
    add     a, #0x10
    ld      e, a
    jr      13$
12$:
    jr      z, 13$
    ld      a, e
    sub     #0x10
    ld      e, a
13$:
    ld      b, #0x00
    ld      a, d
    or      a
    jr      z, 14$
    ld      b, #0x01
    jp      p, 14$
    neg
    ld      b, #-0x01
14$:
    ld      d, a
    ld      c, #0x00
    ld      a, e
    or      a
    jr      z, 15$
    ld      c, #0x01
    jp      p, 15$
    neg
    ld      c, #-0x01
15$:
    ld      e, a
    cp      d
    jr      nc, 16$
    ld      a, d
16$:
    ld      STAR_E(ix), a
    ld      STAR_X_DISTANCE(ix), d
    ld      STAR_X_MOVE(ix), b
    ld      STAR_Y_DISTANCE(ix), e
    ld      STAR_Y_MOVE(ix), c
19$:
    
    ; 前進
    inc     STAR_COUNT(ix)
    ld      a, STAR_COUNT(ix)
    ld      hl, #starMoveZ
    cp      (hl)
    jr      c, 29$
    ld      a, (starAccel)
    ld      b, a
20$:
    push    bc
    ld      e, STAR_E(ix)
    ld      b, STAR_X_DISTANCE(ix)
    ld      c, STAR_Y_DISTANCE(ix)
    ld      a, b
    cp      c
    jr      c, 22$
    ld      a, e
    add     a, c
    ld      e, a
    sub     b
    jr      c, 21$
    ld      e, a
    ld      a, STAR_Y_POSITION(ix)
    add     a, STAR_Y_MOVE(ix)
    ld      STAR_Y_POSITION(ix), a
21$:
    ld      a, STAR_X_POSITION(ix)
    add     a, STAR_X_MOVE(ix)
    ld      STAR_X_POSITION(ix), a
    jr      24$
22$:
    ld      a, e
    add     a, b
    ld      e, a
    sub     c
    jr      c, 23$
    ld      e, a
    ld      a, STAR_X_POSITION(ix)
    add     a, STAR_X_MOVE(ix)
    ld      STAR_X_POSITION(ix), a
23$:
    ld      a, STAR_Y_POSITION(ix)
    add     a, STAR_Y_MOVE(ix)
    ld      STAR_Y_POSITION(ix), a
24$:
    xor     a
    ld      STAR_E(ix), e
    ld      STAR_COUNT(ix), a
    pop     bc
    djnz    20$
29$:
    
    ; 水平移動
    ld      d, STAR_X_POSITION(ix)
    ld      e, #0x00
    ld      a, (_gameRotateY)
    or      a
    jr      z, 39$
    ld      a, #0x02
    jp      m, 30$
    neg
30$:
    add     a, d
    ld      STAR_X_POSITION(ix), a
    ld      STAR_X_DISTANCE(ix), e
    ld      STAR_Y_DISTANCE(ix), e
39$:
    
    ; 垂直移動
    ld      d, STAR_Y_POSITION(ix)
    ld      e, #0x00
    ld      a, (_gameRotateX)
    or      a
    jr      z, 49$
    ld      a, #0x02
    jp      m, 40$
    neg
40$:
    add     a, d
    ld      STAR_Y_POSITION(ix), a
    ld      STAR_X_DISTANCE(ix), e
    ld      STAR_Y_DISTANCE(ix), e
49$:
    
    ; クリッピング
    ld      a, STAR_X_POSITION(ix)
    cp      #-31
    jr      nc, 50$
    cp      #32
    jr      nc, 59$
50$:
    ld      a, STAR_Y_POSITION(ix)
    cp      #-19
    jp      nc, 90$
    cp      #12
    jp      c, 90$
59$:
    
    ; スターの再生
    call    _SystemGetRandom
    ld      h, a
    call    _SystemGetRandom
    ld      l, a
    ld      a, (_gameRotateY)
    or      a
    jr      z, 60$
    ld      d, a
    ld      a, (_gameRotateX)
    or      a
    jr      z, 63$
    call    _SystemGetRandom
    bit     #4, a
    jr      z, 63$
    jr      65$
60$:
    ld      a, (_gameRotateX)
    or      a
    jr      nz, 65$
    
    ; スターの再生／前進
    ld      a, h
    and     #0x1f
    sub     #0x10
    ld      h, a
    ld      b, #0x00
    or      a
    jr      z, 61$
    ld      b, #0x01
    jp      p, 61$
    neg
    ld      b, #-0x01
61$:
    ld      d, a
    ld      a, l
    and     #0x0f
    sub     #0x0a
    ld      l, a
    ld      c, #0x00
    or      a
    jr      z, 62$
    ld      c, #0x01
    jp      p, 62$
    neg
    ld      c, #-0x01
62$:
    ld      e, a
    xor     a
    ld      STAR_E(ix), a
    ld      STAR_COUNT(ix), a
    ld      STAR_X_POSITION(ix), h
    ld      STAR_X_DISTANCE(ix), d
    ld      STAR_X_MOVE(ix), b
    ld      STAR_Y_POSITION(ix), l
    ld      STAR_Y_DISTANCE(ix), e
    ld      STAR_Y_MOVE(ix), c
    jr      69$
    
    ; スターの再生／水平移動
63$:
    ld      a, (_gameRotateY)
    rla
    jr      nc, 64$
    ld      a, h
    and     #0x0f
    neg
    sub     #0x10
    ld      h, a
    ld      a, l
    and     #0x1f
    sub     #0x14
    ld      l, a
    jr      68$
64$:
    ld      a, h
    and     #0x0f
    add     a, #0x10
    ld      h, a
    ld      a, l
    and     #0x1f
    sub     #0x14
    ld      l, a
    jr      68$
    
    ; スターの再生／垂直移動
65$:
    ld      a, (_gameRotateX)
    rla
    jr      nc, 66$
    ld      a, h
    and     #0x3f
    sub     #0x1f
    ld      h, a
    ld      a, l
    and     #0x0f
    neg
    sub     #0x04
    ld      l, a
    jr      68$
66$:
    ld      a, h
    and     #0x3f
    sub     #0x20
    ld      h, a
    ld      a, l
    and     #0x07
    add     a, #0x04
    ld      l, a
    
    ; スターの再生／移動
68$:
    xor     a
    ld      STAR_X_POSITION(ix), h
    ld      STAR_X_DISTANCE(ix), a
    ld      STAR_Y_POSITION(ix), l
    ld      STAR_Y_DISTANCE(ix), a
69$:
    
    ; 次のスターへ
90$:
    ld      bc, #STAR_SIZE
    add     ix, bc
    pop     bc
    dec     b
    jp      nz, 00$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; スターを描画する
;
_StarRender::

    ; レジスタの保存
    
    ; パターンネームのクリア
    ld      hl, #(_gamePatternName + 0x0000)
    ld      de, #(_gamePatternName + 0x0001)
    ld      bc, #(0x0200 - 1)
    ld      a, #0x40
    ld      (hl), a
    ldir
    
    ; パターンネームの設定
    ld      ix, #star
    ld      b, #STAR_N
0$:
    ld      hl, #(_gamePatternName + 0x0000)
    ld      c, #0x01
    ld      a, STAR_Y_POSITION(ix)
    add     a, #0x14
    srl     a
    jr      nc, 1$
    sla     c
    sla     c
1$:
    ld      e, a
    xor     a
    sla     e
    rla
    sla     e
    rla
    sla     e
    rla
    sla     e
    rla
    sla     e
    rla
    ld      d, a
    add     hl, de
    ld      a, STAR_X_POSITION(ix)
    add     a, #0x20
    srl     a
    jr      nc, 2$
    sla     c
2$:
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      a, (hl)
    or      c
    ld      (hl), a
    ld      de, #STAR_SIZE
    add     ix, de
    djnz    0$
    
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

; スター
;
star:

    .ds     STAR_N * STAR_SIZE
    
; 速度
;
starMoveZ:

    .ds     1

starAccel:

    .ds     1

