; Stage.s : ステージ
;


; モジュール宣言
;
    .module Stage

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Stage.inc"
    .include    "Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ステージを初期化する
;
_StageInitialize::
    
    ; レジスタの保存
    
    ; ステージ番号の初期化
    ld      a, #0xff
    ld      (_stageNo), a

    ; レジスタの復帰
    
    ; 終了
    ret
    
; ステージを作成する
;
_StageCreate::

    ; レジスタの保存
    
    ; ステージ番号の更新
    ld      hl, #_stageNo
    inc     (hl)

    ; 地面の作成
    ld      hl, #(_stage + 0x0000)
    xor     a
    ld      b, #0xa0
100$:
    ld      (hl), a
    inc     hl
    djnz    100$
    dec     a
    ld      b, #0x10
101$:
    ld      (hl), a
    inc     hl
    djnz    101$
    ld      a, (_stageType)
    or      a
    jr      nz, 190$
    call    _SystemGetRandom
    and     #0b10101010
    ld      e, a
    rrca
    or      e
    ld      hl, #(_stage + 0x0091)
    call    110$
    call    _SystemGetRandom
    ld      hl, #(_stage + 0x0081)
    call    110$
    jr      190$
110$:
    ld      e, a
    ld      b, #0x07
111$:
    xor     a
    sla     e
    rla
    ld      (hl), a
    inc     hl
    ld      (hl), a
    inc     hl
    djnz    111$
    inc     hl
    inc     hl
    ld      e, l
    ld      d, h
    ld      bc, #0xfff0
    add     hl, bc
    ld      b, #0x0e
112$:
    ld      a, (de)
    and     (hl)
    ld      (hl), a
    inc     hl
    inc     de
    djnz    112$
    ret
190$:
    
    ; 左右の壁の作成
    ld      hl, #(_stage + 0x0000)
    ld      de, #0x000f
    ld      b, #0x0a
20$:
    ld      (hl), e
    add     hl, de
    ld      (hl), e
    inc     hl
    djnz    20$
    
    ; 壁のパターンの構築
    ld      ix, #(_stage + 0x0000)
    ld      d, #0x00
    ld      bc, #0xb000
30$:
    ld      a, 0x00(ix)
    or      a
    jr      z, 39$
    ld      e, d
    ld      a, c
    cp      #0x10
    jr      c, 32$
    ld      a, -0x10(ix)
    or      a
    jr      z, 32$
31$:
    set     #0x00, e
32$:
    ld      a, c
    cp      #0xa0
    jr      nc, 33$
    ld      a, 0x10(ix)
    or      a
    jr      z, 34$
33$:
    set     #0x01, e
34$:
    ld      a, c
    or      a
    jr      z, 35$
    ld      a, -0x01(ix)
    or      a
    jr      z, 36$
35$:
    set     #0x02, e
36$:
    ld      a, c
    cp      #0xaf
    jr      nc, 37$
    ld      a, 0x01(ix)
    or      a
    jr      z, 38$
37$:
    set     #0x03, e
38$:
    ld      0x00(ix), e
39$:
    inc     ix
    inc     c
    djnz    30$
    
    ; 角のパターンの構築
    ld      ix, #(_stage + 0x0000)
    ld      d, #0x00
    ld      bc, #0xb000
40$:
    ld      a, 0x00(ix)
    cp      #0x0f
    jr      nz, 49$
    ld      e, #0x10
    ld      a, c
    cp      #0x11
    jr      c, 41$
    ld      a, -0x11(ix)
    or      a
    jr      z, 42$
41$:
    set     #0x00, e
42$:
    ld      a, c
    cp      #0x0f
    jr      c, 43$
    ld      a, -0x0f(ix)
    or      a
    jr      z, 44$
43$:
    set     #0x01, e
44$:
    ld      a, c
    cp      #0x91
    jr      nc, 45$
    ld      a, 0x0f(ix)
    or      a
    jr      z, 46$
45$:
    set     #0x02, e
46$:
    ld      a, c
    cp      #0x8f
    jr      nc, 47$
    ld      a, 0x11(ix)
    or      a
    jr      z, 48$
47$:
    set     #0x03, e
48$:
    ld      0x00(ix), e
49$:
    inc     ix
    inc     c
    djnz    40$
    
    ; ブロックの作成
    ld      a, (_stageType)
    or      a
    jp      nz, 509$
    call    _SystemGetRandom
    rrca
    jp      c, 506$
    rrca
    jr      c, 503$
500$:
;   call    _SystemGetRandom
    and     #0x03
    ld      e, a
    ld      d, #0x00
    ld      hl, #(_stage + 0x00a1)
    add     hl, de
    call    530$
    inc     hl
    call    _SystemGetRandom
    and     #0x07
    inc     a
    call    510$
    ld      bc, #0x0200
501$:
    ld      a, (hl)
    or      a
    jr      z, 502$
    inc     b
    inc     hl
    jr      501$
502$:
    ld      a, b
    add     a, e
    cp      #0x0c
    jp      nc, 540$
    ld      b, a
    ld      e, c
    ld      d, #0x00
    add     hl, de
    call    _SystemGetRandom
    and     #0x30
    ld      c, a
    ld      e, a
;   ld      d, #0x00
;   or      a
    sbc     hl, de
    call    _SystemGetRandom
    and     #0x03
    inc     a
    ld      e, a
;   ld      d, #0x00
    add     hl, de
    call    _SystemGetRandom
    and     #0x03
    inc     a
    call    510$
    jr      501$
503$:
;   call    _SystemGetRandom
    and     #0x03
    ld      e, a
    ld      d, #0x00
    ld      hl, #(_stage + 0x00ae)
;   or      a
    sbc     hl, de
    call    530$
    dec     hl
    call    _SystemGetRandom
    and     #0x07
    inc     a
    call    520$
    ld      bc, #0x0d00
504$:
    ld      a, (hl)
    or      a
    jr      z, 505$
    dec     b
    dec     hl
    jr      504$
505$:
    ld      a, b
    sub     e
    jp      c, 540$
    cp      #0x04
    jp      c, 540$
    ld      b, a
    ld      e, c
    ld      d, #0x00
    add     hl, de
    call    _SystemGetRandom
    and     #0x30
    ld      c, a
    ld      e, a
;   ld      d, #0x00
;   or      a
    sbc     hl, de
    call    _SystemGetRandom
    and     #0x03
    inc     a
    ld      e, a
;   ld      d, #0x00
;   or      a
    sbc     hl, de
    call    _SystemGetRandom
    and     #0x03
    inc     a
    call    520$
    jr      504$
506$:
;   call    _SystemGetRandom
    and     #0x03
    inc     a
    ld      b, a
    ld      a, #0x10
    sub     b
    rra
    ld      e, a
    ld      d, #0x00
    ld      hl, #(_stage + 0x00a0)
    add     hl, de
    dec     hl
    call    530$
    inc     hl
    ld      a, b
    call    510$
    push    hl
    call    _SystemGetRandom
    and     #0x30
    ld      e, a
;   ld      d, #0x00
;   or      a
    sbc     hl, de
    call    _SystemGetRandom
    and     #0x03
    add     a, #0x02
    ld      e, a
;   ld      d, #0x00
;   or      a
    sbc     hl, de
    call    _SystemGetRandom
    and     #0x03
    inc     a
    call    520$
    pop     hl
507$:
    ld      a, (hl)
    or      a
    jr      z, 508$
    inc     hl
    jr      507$
508$:
    call    _SystemGetRandom
    and     #0x30
    ld      e, a
;   ld      d, #0x00
;   or      a
    sbc     hl, de
    call    _SystemGetRandom
    and     #0x03
    inc     a
    ld      e, a
;   ld      d, #0x00
    add     hl, de
    call    _SystemGetRandom
    and     #0x03
    inc     a
    call    510$
    jr      540$
509$:
    jr      540$
510$:
    push    hl
    push    bc
    push    de
    ld      e, l
    ld      d, h
    ld      bc, #0x0010
    add     hl, bc
    ex      de, hl
    ld      c, #0x20
    ld      b, a
511$:
    ld      a, (de)
    or      (hl)
    jr      nz, 512$
    ld      (hl), c
    inc     hl
    inc     de
    djnz    511$
512$:
    pop     de
    pop     bc
    pop     hl
    ret
520$:
    push    hl
    push    bc
    push    de
    ld      e, l
    ld      d, h
    ld      bc, #0x0010
    add     hl, bc
    ex      de, hl
    ld      c, #0x20
    ld      b, a
521$:
    ld      a, (de)
    or      (hl)
    jr      nz, 522$
    ld      (hl), c
    dec     hl
    dec     de
    djnz    521$
522$:
    pop     de
    pop     bc
    pop     hl
    ret
530$:
    push    de
    ld      de, #0xfff0
531$:
    add     hl, de
    ld      a, (hl)
    or      a
    jr      nz, 531$
    add     hl, de
    add     hl, de
    add     hl, de
    pop     de
    ret

    ; ブロックの設定
540$:
    xor     a
    ld      hl, #stageBlock
    ld      b, #STAGE_BLOCK_SIZE
541$:
    ld      (hl), a
    inc     hl
    djnz    541$

    ; コイン入りブロックの作成
550$:
    ld      a, (_appGame)
    or      a
    jr      z, 559$
    call    _SystemGetRandom
    rrca
    jr      nc, 559$
    and     #0x0f
    ld      e, a
    ld      d, #0x00
    ld      c, #0x10
551$:
    ld      hl, #_stage
    add     hl, de
    ld      b, #0x0b
552$:
    ld      a, (hl)
    cp      #0x20
    jr      nz, 553$
    ld      a, b
    cp      #(0x0b - 0x05)
    jr      c, 554$
    push    hl
    push    de
    ld      de, #0x0030
    add     hl, de
    ld      a, (hl)
    pop     de
    pop     hl
    and     #0x3f
    jr      nz, 554$
553$:
    push    de
    ld      de, #0x0010
    add     hl, de
    pop     de
    djnz    552$
    ld      a, e
    inc     a
    and     #0x0f
    ld      e, a
    dec     c
    jr      nz, 551$
    xor     a
    jr      559$
554$:
    ld      a, #0x25
    ld      (hl), a
559$:

    ; ヒントの設定
560$:
    or      a
    jr      z, 561$
    ld      a, #(0x05 * 0x04)
561$:
    ld      de, #_stage
    sbc     hl, de
    ld      de, #(stageHint + STAGE_HINT_STATE)
    ld      (de), a
;   ld      de, #(stageHint + STAGE_HINT_POSITION_X)
    inc     de
    ld      a, l
    and     #0x0f
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      (de), a
;   ld      de, #(stageHint + STAGE_HINT_POSITION_Y)
    inc     de
    ld      a, l
    and     #0xf0
    ld      (de), a

    ; コインの作成
    ld      a, (_stageType)
    or      a
    jr      nz, 630$
    ld      hl, #(_stage + 0x00a1)
    ld      de, #0xfff0
    ld      b, #0x0e
600$:
    push    hl
    push    bc
    ld      c, #0x0b
601$:
    ld      a, (hl)
    and     #0x3f
    jr      z, 602$
    add     hl, de
    dec     c
    jr      z, 609$
    jr      601$
602$:
    push    hl
    ld      b, #0x03
603$:
    dec     hl
    call    620$
    jr      nz, 604$
    call    610$
    djnz    603$
604$:
    pop     hl
    push    hl
    ld      b, #0x03
605$:
    inc     hl
    call    620$
    jr      nz, 606$
    call    610$
    djnz    605$
606$:
    pop     hl
    call    610$
607$:
    ld      a, (hl)
    and     #0x3f
    jr      nz, 601$
    add     hl, de
    dec     c
    jr      nz, 607$
609$:
    pop     bc
    pop     hl
    inc     hl
    djnz    600$
    jr      630$
610$:
    push    hl
    push    bc
    ld      b, #0x04
611$:
    ld      a, #0x40
    ld      (hl), a
    add     hl, de
    dec     c
    jr      z, 619$
    ld      a, (hl)
    and     #0x3f
    jr      nz, 619$
    djnz    611$
619$:
    pop     bc
    pop     hl
    ret
620$:
    push    hl
    push    bc
    xor     a
    ld      b, #0x05
621$:
    or      (hl)
    add     hl, de
    dec     c
    jr      z, 629$
    djnz    621$
629$:
    pop     bc
    pop     hl
    and     #0x3f
    ret

    ; コインを数える
630$:
    ld      hl, #_stageCoinRest
    xor     a
    ld      (hl), a
    ld      de, #_stage
    ld      b, #0xb0
631$:
    ld      a, (de)
    cp      #0x40
    jr      nz, 632$
    inc     (hl)
    jr      633$
632$:
    and     #0xf0
    cp      #0x20
    jr      nz, 633$
    ld      a, (de)
    and     #0x0f
    add     a, (hl)
    ld      (hl), a
633$:
    inc     de
    djnz    631$

    ; コインの設定
    xor     a
    ld      hl, #stageCoin
    ld      b, #(STAGE_COIN_SIZE * STAGE_COIN_N)
640$:
    ld      (hl), a
    inc     hl
    djnz    640$
    ld      (stageCoinIndex + 0x0000), a
    ld      (stageCoinIndex + 0x0001), a
    ld      hl, #stageCoinEntry
    ld      b, #((STAGE_COIN_ENTRY + 0x01) * 0x02)
641$:
    ld      (hl), a
    inc     hl
    djnz    641$

    ; パターンネームの作成
    ld      ix, #_stage
    ld      iy, #(_appPatternName + 0x0040)
    ld      d, #0x00
    ld      c, #0x0b
70$:
    ld      b, #0x10
71$:
    ld      a, 0x00(ix)
    cp      #0x20
    jr      c, 72$
    and     #0xf0
    rrca
    rrca
    ld      e, a
    ld      hl, #stagePatternName
    jr      73$
72$:
    add     a, a
    add     a, a
    ld      e, a
    ld      hl, #stagePatternNameWall
73$:
    add     hl, de
    ld      a, (hl)
    ld      0x00(iy), a
    inc     hl
    ld      a, (hl)
    ld      0x01(iy), a
    inc     hl
    ld      a, (hl)
    ld      0x20(iy), a
    inc     hl
    ld      a, (hl)
    ld      0x21(iy), a
;   inc     hl
    inc     ix
    inc     iy
    inc     iy
    djnz    71$
    ld      e, #0x20
    add     iy, de
    dec     c
    jr      nz, 70$

    ; 状態の設定
    xor     a
    ld      (_stageState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ステージを更新する
;
_StageUpdate::
    
    ; レジスタの保存
    
    ; 状態別の処理
    ld      a, (_stageState)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #stageProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; ステージを描画する
;
_StageRender::
    
    ; レジスタの保存
    
    ; ブロックの描画
    call    StageRenderBlock

    ; コインの描画
    call    StageRenderCoin

    ; ヒントの描画
    call    StageRenderHint

    ; レジスタの復帰
    
    ; 終了
    ret

; 他のオブジェクトとのヒット判定を行う
;
_StageHit::

    ; レジスタの保存

    ; ブロックがパンチされた
    ld      hl, #(stageBlock + STAGE_BLOCK_STATE)
    ld      a, (hl)
    rlca
    jr      nc, 19$

    ; コインとの判定
    rrca
    and     #0x7f
    ld      (hl), a
    ld      a, (stageBlock + STAGE_BLOCK_OFFSET)
    sub     #0x10
    call    _StageGetFieldCoin

    ; エネミーとの判定
    ld      a, (stageBlock + STAGE_BLOCK_POSITION_X)
    ld      d, a
    add     a, #0x10
    ld      e, a
    ld      a, (stageBlock + STAGE_BLOCK_POSITION_Y)
    ld      h, a
    add     a, #0x10
    ld      l, a
    ld      ix, #_enemy
    ld      b, #ENEMY_N
10$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 11$
    ld      a, ENEMY_STATE(ix)
    cp      #ENEMY_STATE_MOVE
    jr      nz, 11$
    ld      a, ENEMY_POSITION_X(ix)
    add     a, #0x07
    cp      d
    jr      c, 11$
    sub     #0x0f
    cp      e
    jr      nc, 11$
    ld      a, ENEMY_POSITION_Y(ix)
    cp      h
    jr      c, 11$
    sub     #0x0f
    cp      l
    jr      nc, 11$
    ld      a, #ENEMY_STATE_KILL
    ld      ENEMY_STATE(ix), a
11$:
    push    de
    ld      de, #ENEMY_SIZE
    add     ix, de
    pop     de
    djnz    10$

    ; 判定の完了
19$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; なにもしない
;
StageNull:

    ; レジスタの保存

    ; レジスタの復帰
    
    ; 終了
    ret

; ステージを開閉する
;
StageSwitch:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (_stageState)
    and     #0x0f
    jr      nz, 09$

    ; パターンネームのクリア
    ld      a, (_stageState)
    and     #0xf0
    cp      #STAGE_STATE_CLOSE
    jr      nz, 00$
    ld      hl, #(_appPatternName + 0x0040)
    ld      de, #(_appPatternName + 0x0041)
    ld      bc, #(0x02c0 - 0x0001)
    xor     a
    ld      (hl), a
    ldir
00$:

    ; カウンタの設定
    ld      a, #(0x0b * 0x02 * 0x04)
    ld      (stageCount), a

    ; 初期化の完了
    ld      hl, #_stageState
    inc     (hl)
09$:

    ; カウンタの更新
    ld      hl, #stageCount
    dec     (hl)
    ld      c, (hl)

    ; ステージの更新
    ld      a, (_stageState)
    and     #0xf0
    cp      #STAGE_STATE_CLOSE
    jr      nz, 11$
    ld      a, c
    and     #0x07
    jr      nz, 11$
    ld      a, c
    and     #0xf8
    ld      d, #0x00
    add     a, a
    rl      d
    ld      e, a
    ld      hl, #_stage
    add     hl, de
    xor     a
    ld      b, #0x10
10$:
    ld      (hl), a
    inc     hl
    djnz    10$
11$:

    ; パターンネームの更新
    ld      a, c
    and     #0x03
    jr      nz, 12$
    ld      a, c
    and     #0xfc
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    ld      hl, #(_appPatternName + 0x0040)
    add     hl, de
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0040)
    add     hl, de
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST), hl
    ld      a, #0x20
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)

    ; 更新の完了
12$:
    ld      a, c
    or      a
    jr      nz, 19$
    ld      (_stageState), a
19$:

    ; ブロックの更新
    call    StageSwitchBlock

    ; コインの更新
    call    StageSwitchCoin
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ステージをプレイする
;
StagePlay:

    ; レジスタの保存

    ; ブロックの更新
    call    StagePlayBlock

    ; コインの更新
    call    StagePlayCoin

    ; ヒントの更新
    call    StagePlayHint

    ; レジスタの復帰
    
    ; 終了
    ret

; ブロックを開閉する
;
StageSwitchBlock:

    ; レジスタの保存

    ; ブロックのクリア
    ld      hl, #(stageBlock + STAGE_BLOCK_STATE)
    ld      a, (hl)
    and     #0x7f
    ld      (hl), a

    ; ブロックの更新
    call    StageUpdateBlock

    ; レジスタの復帰
    
    ; 終了
    ret

; ブロックをプレイする
;
StagePlayBlock:

    ; レジスタの保存
    
    ; ブロックの復帰
    ld      a, (stageBlock + STAGE_BLOCK_STATE)
    dec     a
    jr      nz, 19$
    call    StageRestoreBlock
19$:

    ; ブロックの更新
    call    StageUpdateBlock

    ; レジスタの復帰
    
    ; 終了
    ret

; ブロックを描画する
;
StageRenderBlock:

    ; レジスタの保存

    ; スプライトの描画
    ld      hl, #(_sprite + GAME_SPRITE_BLOCK)
    ld      a, (stageBlock + STAGE_BLOCK_STATE)
    or      a
    jr      z, 19$
    ld      a, (stageBlock + STAGE_BLOCK_POSITION_Y)
    add     a, #(0x10 - 0x01)
    ld      (hl), a
    inc     hl
    ld      a, (stageBlock + STAGE_BLOCK_POSITION_X)
    ld      (hl), a
    inc     hl
    ld      a, #0x04
    ld      (hl), a
    inc     hl
    ld      a, #0x05
    ld      (hl), a
;   inc     hl
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; ブロックを下からパンチする
;
_StagePunchBlock::

    ; レジスタの保存

    ; クリッピング
    cp      #0xb0
    jr      nc, 18$

    ; ブロックの存在
    ld      e, a
    ld      d, #0x00
    ld      hl, #_stage
    add     hl, de
    ld      a, (hl)
    and     #0xf0
    cp      #0x20
    jr      nz, 18$
    
    ; コインの獲得
    push    de
    ld      a, e
    call    _StageGetBlockCoin
    
    ; ブロックの復帰
    call    StageRestoreBlock
    pop     de

    ; ブロックの設定
    ld      hl, #(stageBlock + STAGE_BLOCK_STATE)
    ld      a, #(0x11 + 0x80)
    ld      (hl), a
;   ld      hl, #(stageBlock + STAGE_BLOCK_OFFSET)
    inc     hl
    ld      a, e
    ld      (hl), a
;   ld      hl, #(stageBlock + STAGE_BLOCK_POSITION_X)
    inc     hl
    and     #0x0f
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      (hl), a
;   ld      hl, #(stageBlock + STAGE_BLOCK_POSITION_Y)
    inc     hl
    ld      a, e
    and     #0xf0
    sub     #0x04
    ld      (hl), a

    ; パターンネームの更新
    ld      a, e
    and     #0x0f
    add     a, a
    ld      l, a
    ld      h, d
    ld      a, e
    and     #0xf0
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    add     hl, de
    ex      de, hl
    ld      hl, #(_appPatternName + 0x0040)
    add     hl, de
    push    hl
    pop     ix
    xor     a
    ld      0x00(ix), a
    ld      0x01(ix), a
    ld      0x20(ix), a
    ld      0x21(ix), a
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0040)
    add     hl, de
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST), hl
    ld      a, #0x22
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)

    ; パンチの完了
    scf
    jr      19$
18$:
    or      a
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; ブロックを更新する
;
StageUpdateBlock:

    ; レジスタの保存

    ; ブロックの更新
    ld      hl, #(stageBlock + STAGE_BLOCK_STATE)
    ld      a, (hl)
    or      a
    jr      z, 19$
    dec     (hl)
    and     #0x03
    jr      nz, 19$
    ld      hl, #(stageBlock + STAGE_BLOCK_POSITION_Y)
    inc     (hl)
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; ブロックを復帰する
;
StageRestoreBlock:

    ; レジスタの保存

    ; ブロックの存在
    ld      a, (stageBlock + STAGE_BLOCK_STATE)
    or      a
    jr      z, 19$

    ; パターンネームの更新
    ld      a, (stageBlock + STAGE_BLOCK_OFFSET)
    ld      c, a
    and     #0x0f
    add     a, a
    ld      l, a
    ld      h, #0x00
    ld      a, c
    and     #0xf0
    add     a, a
    ld      d, #0x00
    rl      d
    add     a, a
    rl      d
    ld      e, a
    add     hl, de
    ex      de, hl
    ld      hl, #(_appPatternName + 0x0040)
    add     hl, de
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_SRC), hl
    push    hl
    pop     ix
    ld      b, #0x00
    ld      hl, #_stage
    add     hl, bc
    ld      a, (hl)
    and     #0xf0
    rrca
    rrca
    ld      c, a
    ld      hl, #stagePatternName
    add     hl, bc
    ld      a, (hl)
    ld      0x00(ix), a
    inc     hl
    ld      a, (hl)
    ld      0x01(ix), a
    inc     hl
    ld      a, (hl)
    ld      0x20(ix), a
    inc     hl
    ld      a, (hl)
    ld      0x21(ix), a
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0040)
    add     hl, de
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_DST), hl
    ld      a, #0x22
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)
    
    ; 復帰の完了
19$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; コインを開閉する
;
StageSwitchCoin:

    ; レジスタの保存

    ; コインの更新
    call    StageUpdateCoin

    ; レジスタの復帰

    ; 終了
    ret

; コインをプレイする
;
StagePlayCoin:

    ; レジスタの保存

    ; 登録されたコインの走査
    ld      ix, #stageCoinEntry
    ld      b, #STAGE_COIN_ENTRY
10$:
    ld      a, 0x00(ix)
    or      a
    jr      nz, 11$
    inc     ix
    inc     ix
    djnz    10$
    jp      19$
11$:
    ld      e, a
    ld      d, #0x00
    
    ; ステージ内のコインの数の減少
    ld      hl, #_stageCoinRest
    dec     (hl)

    ; 獲得したコインの総数の増加
    ld      hl, #(_gameCoin + 0x0003)
12$:
    ld      a, (hl)
    inc     a
    ld      (hl), a
    cp      #0x0a
    jr      c, 13$
    xor     a
    ld      (hl), a
    dec     hl
    jr      12$
13$:

    ; コインの設定
    ld      hl, #(stageCoin + STAGE_COIN_STATE)
    ld      bc, (stageCoinIndex)
    add     hl, bc
    ld      a, #STAGE_COIN_SIZE
    add     a, c
    and     #0x0f
    ld      (stageCoinIndex + 0x0000), a
    ld      a, #0x11
    ld      (hl), a
;   ld      hl, #(stageCoin + STAGE_COIN_OFFSET)
    inc     hl
    ld      a, e
    ld      (hl), a
;   ld      hl, #(stageCoin + STAGE_COIN_POSITION_X)
    inc     hl
    and     #0x0f
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      (hl), a
;   ld      hl, #(stageCoin + STAGE_COIN_POSITION_Y)
    inc     hl
    ld      a, e
    and     #0xf0
    sub     #0x0c
    ld      (hl), a

    ; ステージからの削除
    ld      a, 0x01(ix)
    or      a
    jr      nz, 14$
    ld      hl, #_stage
    add     hl, de
    xor     a
    ld      (hl), a

    ; パターンネームの更新
    ld      a, e
    and     #0x0f
    add     a, a
    ld      l, a
    ld      h, d
    ld      a, e
    and     #0xf0
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    add     hl, de
    ex      de, hl
    ld      hl, #(_appPatternName + 0x0040)
    add     hl, de
    push    hl
    pop     iy
    xor     a
    ld      0x00(iy), a
    ld      0x01(iy), a
    ld      0x20(iy), a
    ld      0x21(iy), a
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0040)
    add     hl, de
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_DST), hl
    ld      a, #0x22
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)
14$:

    ; エントリからの削除
15$:
    ld      a, 0x02(ix)
    ld      0x00(ix), a
    ld      b, 0x03(ix)
    ld      0x01(ix), b
    inc     ix
    inc     ix
    or      b
    jr      nz, 15$

    ; ＳＥの再生
    ld      hl, #stageSoundCoin
    ld      (_soundRequest + 0x0006), hl

    ; コイン獲得の完了
19$:

    ; コインの更新
    call    StageUpdateCoin

    ; レジスタの復帰

    ; 終了
    ret

; コインを描画する
;
StageRenderCoin:

    ; レジスタの保存

    ; スプライトの描画
    ld      hl, #(_sprite + GAME_SPRITE_COIN)
    ld      ix, #stageCoin
    ld      de, #STAGE_COIN_SIZE
    ld      b, #STAGE_COIN_N
10$:
    ld      a, STAGE_COIN_STATE(ix)
    or      a
    jr      z, 11$
    ld      a, STAGE_COIN_POSITION_Y(ix)
    add     a, #(0x10 - 0x01)
    ld      (hl), a
    inc     hl
    ld      a, STAGE_COIN_POSITION_X(ix)
    ld      (hl), a
    inc     hl
    ld      a, STAGE_COIN_STATE(ix)
    and     #0x08
    rrca
    add     a, #0x08
    ld      (hl), a
    inc     hl
    ld      a, #0x0b
    ld      (hl), a
    inc     hl
11$:
    add     ix, de
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; フィールド上のコインを獲得する
;
_StageGetFieldCoin::

    ; レジスタの保存

    ; クリッピング
    cp      #0xb0
    jr      nc, 18$

    ; コインの存在
    ld      e, a
    ld      d, #0x00
    ld      hl, #_stage
    add     hl, de
    ld      a, (hl)
    cp      #0x40
    jr      nz, 18$
    
    ; コインの登録
    ld      ix, #stageCoinEntry
    ld      b, #STAGE_COIN_ENTRY
10$:
    ld      a, 0x00(ix)
    or      a
    jr      z, 12$
    cp      e
    jr      nz, 11$
    ld      a, 0x01(ix)
    or      a
    jr      z, 18$
11$:
    inc     ix
    inc     ix
    djnz    10$
    jr      18$
12$:
    ld      0x00(ix), e
    ld      0x01(ix), d
13$:

    ; コイン登録の完了
    scf
    jr      19$
18$:
    or      a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ブロック中のコインを獲得する
;
_StageGetBlockCoin::

    ; レジスタの保存

    ; クリッピング
    cp      #0xb0
    jr      nc, 18$

    ; コインのあるブロックの存在
    ld      e, a
    ld      d, #0x00
    ld      hl, #_stage
    add     hl, de
    ld      a, (hl)
    cp      #0x21
    jr      c, 18$
    cp      #0x30
    jr      nc, 18$
    
    ; コインの登録
    ld      ix, #stageCoinEntry
    ld      b, #STAGE_COIN_ENTRY
10$:
    ld      a, 0x00(ix)
    or      a
    jr      z, 11$
    inc     ix
    inc     ix
    djnz    10$
    jr      18$
11$:
    dec     d
    ld      0x00(ix), e
    ld      0x01(ix), d
    dec     (hl)
    ld      a, (hl)
    and     #0x0f
    jr      nz, 12$
    ld      a, #0x30
    ld      (hl), a
12$:

    ; コイン登録の完了
    scf
    jr      19$
18$:
    or      a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; コインを更新する
;
StageUpdateCoin:

    ; レジスタの保存

    ; コインの更新
    ld      ix, #stageCoin
    ld      de, #STAGE_COIN_SIZE
    ld      b, #STAGE_COIN_N
10$:
    ld      a, STAGE_COIN_STATE(ix)
    or      a
    jr      z, 11$
    dec     STAGE_COIN_STATE(ix)
    dec     STAGE_COIN_POSITION_Y(ix)
11$:
    add     ix, de
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; ヒントをプレイする
; 
StagePlayHint:

    ; レジスタの保存

    ; ヒントの更新
    ld      hl, #(stageHint + STAGE_HINT_STATE)
    ld      a, (hl)
    or      a
    jr      z, 19$
    dec     (hl)
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ヒントを描画する
; 
StageRenderHint:

    ; レジスタの保存

    ; スプライトの描画
    ld      a, (stageHint + STAGE_HINT_STATE)
    or      a
    jr      z, 19$
    ld      c, a
    ld      hl, #(_sprite + GAME_SPRITE_HINT)
    ld      a, (stageHint + STAGE_HINT_POSITION_Y)
    add     a, #(0x10 - 0x01)
    ld      (hl), a
    inc     hl
    ld      a, (stageHint + STAGE_HINT_POSITION_X)
    ld      (hl), a
    inc     hl
    ld      a, c
    and     #0x1c
    add     a, #0x88
    ld      (hl), a
    inc     hl
    ld      a, #0x0f
    ld      (hl), a
;   inc     hl
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
stageProc:
    
    .dw     StageNull
    .dw     StageSwitch
    .dw     StagePlay
    .dw     StageSwitch

; パターンネーム
;
stagePatternName:

    .db     0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00
    .db     0x68, 0x69, 0x6a, 0x6b
    .db     0x6c, 0x6d, 0x6e, 0x6f
    .db     0x78, 0x79, 0x7a, 0x7b

; パターンネーム（壁）
;
stagePatternNameWall:

    ; NORMAL
    .db     0x00, 0x00, 0x00, 0x00
    .db     0x64, 0x67, 0x74, 0x77
    .db     0x44, 0x47, 0x54, 0x57
    .db     0x4c, 0x4f, 0x5c, 0x5f
    .db     0x46, 0x47, 0x76, 0x77
    .db     0x66, 0x67, 0x76, 0x77
    .db     0x46, 0x47, 0x56, 0x57
    .db     0x4e, 0x4f, 0x5e, 0x5f
    .db     0x44, 0x45, 0x74, 0x75
    .db     0x64, 0x65, 0x74, 0x75
    .db     0x44, 0x45, 0x54, 0x55
    .db     0x4c, 0x4d, 0x5c, 0x5d
    .db     0x48, 0x49, 0x5a, 0x5b
    .db     0x4a, 0x4b, 0x5a, 0x5b
    .db     0x48, 0x49, 0x58, 0x59
    .db     0x20, 0x20, 0x20, 0x20
    
    ; CORNER
    .db     0x62, 0x61, 0x52, 0x51
    .db     0x40, 0x61, 0x52, 0x51
    .db     0x62, 0x43, 0x52, 0x51
    .db     0x42, 0x41, 0x52, 0x51
    .db     0x62, 0x61, 0x70, 0x51
    .db     0x60, 0x50, 0x52, 0x51
    .db     0x62, 0x43, 0x70, 0x51
    .db     0x40, 0x41, 0x50, 0x51
    .db     0x62, 0x61, 0x52, 0x73
    .db     0x40, 0x61, 0x52, 0x73
    .db     0x62, 0x63, 0x52, 0x53
    .db     0x42, 0x43, 0x52, 0x53
    .db     0x62, 0x61, 0x72, 0x71
    .db     0x60, 0x61, 0x70, 0x71
    .db     0x62, 0x63, 0x72, 0x73
    .db     0x00, 0x00, 0x00, 0x00

; サウンド
;
stageSoundCoin:
    
    .ascii  "T1V15-4O5B3O6E9"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ステージ
;
_stage::

    .ds     0xb0

; 状態
;
_stageState::

    .ds     0x01

; 番号
;
_stageNo::

    .ds     0x01

; 種類
;
_stageType::

    .ds     0x01
    
; カウンタ
;
stageCount:

    .ds     0x01

; ブロック
;
stageBlock:

    .ds     STAGE_BLOCK_SIZE

; コイン
;
_stageCoinRest::

    .ds     0x01

stageCoin:

    .ds     STAGE_COIN_SIZE * STAGE_COIN_N

stageCoinIndex:

    .ds     0x02

stageCoinEntry:

    .ds     (STAGE_COIN_ENTRY + 0x01) * 0x02

; ヒント
;
stageHint:

    .ds     STAGE_HINT_SIZE