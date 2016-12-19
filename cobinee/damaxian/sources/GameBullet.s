; GameBullet.s : ゲーム画面／弾
;



; モジュール宣言
;
    .module Game


; 参照ファイル
;
    .include    "bios.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include    "Game.inc"
    .include    "GameBullet.inc"



; CODE 領域
;
    .area   _CODE


; 弾を初期化する
;
_GameBulletInitialize::
    
    ; 弾の走査
    ld      ix, #_gameBullet
    ld      bc, #((GAME_BULLET_SIZE << 8) | 0x0000)
0$:
    
    ; スプライトの設定
    ld      a, c
    sla     a
    sla     a
    ld      GAME_BULLET_PARAM_SPRITE_OFFSET(ix), a
    
    ; 状態の設定
    ld      a, #GAME_BULLET_STATE_NULL
    ld      GAME_BULLET_PARAM_STATE(ix), a
    xor     a
    ld      GAME_BULLET_PARAM_PHASE(ix), a
    
    ; 次の弾
    ld      de, #GAME_BULLET_PARAM_SIZE
    add     ix, de
    inc     c
    djnz    0$
    
    ; スプライトオフセットの初期化
    xor     a
    ld      (spriteOffset + 0), a
    ld      a, #GAME_SPRITE_BULLET
    ld      (spriteOffset + 1), a
    
    ; 終了
    ret


; 弾を更新する
;
_GameBulletUpdate::
    
    ; 弾の走査
    ld      ix, #_gameBullet
    ld      b, #GAME_BULLET_SIZE
GameBulletUpdateLoop:
    
    ; レジスタの保存
    push    bc
    
    ; 状態の取得
    ld      a, GAME_BULLET_PARAM_STATE(ix)
    
    ; なし
    cp      #GAME_BULLET_STATE_NULL
    jr      nz, 00$
    call    GameBulletNull
    jr      GameBulletUpdateNext
00$:
    
    ; 移動
    cp      #GAME_BULLET_STATE_MOVE
    jr      nz, 01$
    call    GameBulletMove
    jr      GameBulletUpdateNext
01$:
    
    ; 次の弾
GameBulletUpdateNext:
    pop     bc
    ld      de, #GAME_BULLET_PARAM_SIZE
    add     ix, de
    djnz    GameBulletUpdateLoop
    
    ; 更新の終了
GameBulletUpdateEnd:
    
    ; スプライトオフセットの更新
    ld      hl, #spriteOffset
    ld      a, (hl)
    add     a, #0x04
    cp      #(GAME_BULLET_SIZE * 0x04)
    jr      c, 10$
    xor     a
10$:
    ld      (hl), a
    inc     hl
    ld      a, #GAME_SPRITE_BULLET_OFFSET
    sub     (hl)
    ld      (hl), a
    
    ; 終了
    ret


; 弾はなし
;
GameBulletNull:
    
    ; 状態の取得
    ld      a, GAME_BULLET_PARAM_PHASE(ix)
    or      a
    jr      nz, GameBulletNullMain
    
    ; 状態の更新
    inc     GAME_BULLET_PARAM_PHASE(ix)
    
    ; 待機の処理
GameBulletNullMain:
    
    ; 処理の完了
GameBUlletNullDone:
    
    ; 描画の開始
    ld      hl, #spriteOffset
    ld      a, (hl)
    inc     hl
    add     a, GAME_BULLET_PARAM_SPRITE_OFFSET(ix)
    cp      #(GAME_BULLET_SIZE * 0x04)
    jr      c, 0$
    sub     #(GAME_BULLET_SIZE * 0x04)
0$:
    add     a, (hl)
    ld      c, a
    ld      b, #0x00
    ld      hl, #_sprite
    add     hl, bc
    ld      a, #0xc0
    ld      (hl), a
    inc     hl
    ld      (hl), a
    inc     hl
    ld      (hl), a
    inc     hl
    ld      (hl), a
    
    ; 処理の終了
GameBulletNullEnd:
    
    ; 終了
    ret


; 弾が移動する
;
GameBulletMove:
    
    ; 状態の取得
    ld      a, GAME_BULLET_PARAM_PHASE(ix)
    or      a
    jr      nz, GameBulletMoveMain
    
    ; 状態の更新
    inc     GAME_BULLET_PARAM_PHASE(ix)
    
    ; 待機の処理
GameBulletMoveMain:
    
    ; 移動
    ld      a, GAME_BULLET_PARAM_POINT_XD(ix)
    add     a, GAME_BULLET_PARAM_SPEED_XD(ix)
    ld      GAME_BULLET_PARAM_POINT_XD(ix), a
    ld      a, GAME_BULLET_PARAM_POINT_XI(ix)
    adc     a, GAME_BULLET_PARAM_SPEED_XI(ix)
    ld      GAME_BULLET_PARAM_POINT_XI(ix), a
    ld      a, GAME_BULLET_PARAM_POINT_YD(ix)
    add     a, GAME_BULLET_PARAM_SPEED_YD(ix)
    ld      GAME_BULLET_PARAM_POINT_YD(ix), a
    ld      a, GAME_BULLET_PARAM_POINT_YI(ix)
    adc     a, GAME_BULLET_PARAM_SPEED_YI(ix)
    ld      GAME_BULLET_PARAM_POINT_YI(ix), a
    
    ; 移動の完了
    ld      a, GAME_BULLET_PARAM_POINT_XI(ix)
    cp      #0xc4
    jr      nc, 00$
    ld      a, GAME_BULLET_PARAM_POINT_YI(ix)
    cp      #0xc4
    jr      c, GameBulletMoveDone
00$:
    
    ; 状態の更新
    ld      a, #GAME_BULLET_STATE_NULL
    ld      GAME_BULLET_PARAM_STATE(ix), a
    xor     a
    ld      GAME_BULLET_PARAM_PHASE(ix), a
    
    ; 処理の完了
GameBulletMoveDone:
    
    ; 描画の開始
    ld      hl, #spriteOffset
    ld      a, (hl)
    inc     hl
    add     a, GAME_BULLET_PARAM_SPRITE_OFFSET(ix)
    cp      #(GAME_BULLET_SIZE * 0x04)
    jr      c, 10$
    sub     #(GAME_BULLET_SIZE * 0x04)
10$:
    add     a, (hl)
    ld      c, a
    ld      b, #0x00
    ld      hl, #_sprite
    add     hl, bc
    ld      d, h
    ld      e, l
    ld      l, GAME_BULLET_PARAM_SPRITE_SRC_L(ix)
    ld      h, GAME_BULLET_PARAM_SPRITE_SRC_H(ix)
    ld      b, GAME_BULLET_PARAM_POINT_XI(ix)
    ld      c, GAME_BULLET_PARAM_POINT_YI(ix)
    ld      a, b
    cp      #0xe0
    jr      c, 11$
    cp      #0xf8
    jr      nc, 11$
    ld      a, #0xc0
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    jr      12$
11$:
    call    _SystemSetSprite
12$:
    
    ; 処理の終了
GameBulletMoveEnd:
    
    ; 終了
    ret


; 弾をエントリする
;
_GameBulletEntry::
    
    ; レジスタの保存
    push    bc
    push    de
    push    ix
    
    ; 弾の走査
    ld      ix, #_gameBullet
    ld      de, #GAME_BULLET_PARAM_SIZE
    ld      b, #GAME_BULLET_SIZE
0$:
    ld      a, GAME_BULLET_PARAM_STATE(ix)
    cp      #GAME_BULLET_STATE_NULL
    jr      z, 1$
    add     ix, de
    djnz    0$
    jr      GameBulletEntryEnd
1$:
    
    ; 位置の設定
    ld      a, (_gameBulletEntry + GAME_BULLET_PARAM_POINT_XD)
    ld      GAME_BULLET_PARAM_POINT_XD(ix), a
    ld      a, (_gameBulletEntry + GAME_BULLET_PARAM_POINT_XI)
    ld      GAME_BULLET_PARAM_POINT_XI(ix), a
    ld      a, (_gameBulletEntry + GAME_BULLET_PARAM_POINT_YD)
    ld      GAME_BULLET_PARAM_POINT_YD(ix), a
    ld      a, (_gameBulletEntry + GAME_BULLET_PARAM_POINT_YI)
    ld      GAME_BULLET_PARAM_POINT_YI(ix), a
    
    ; 速度の設定
    ld      a, (_gameBulletEntry + GAME_BULLET_PARAM_SPEED_XD)
    ld      GAME_BULLET_PARAM_SPEED_XD(ix), a
    ld      a, (_gameBulletEntry + GAME_BULLET_PARAM_SPEED_XI)
    ld      GAME_BULLET_PARAM_SPEED_XI(ix), a
    ld      a, (_gameBulletEntry + GAME_BULLET_PARAM_SPEED_YD)
    ld      GAME_BULLET_PARAM_SPEED_YD(ix), a
    ld      a, (_gameBulletEntry + GAME_BULLET_PARAM_SPEED_YI)
    ld      GAME_BULLET_PARAM_SPEED_YI(ix), a
    
    ; スプライトの設定
    ld      a, (_gameBulletEntry + GAME_BULLET_PARAM_SPRITE_SRC_L)
    sla     a
    sla     a
    ld      e, a
    ld      d, #0x00
    ld      hl, #bulletSpriteTable
    add     hl, de
    ld      GAME_BULLET_PARAM_SPRITE_SRC_L(ix), l
    ld      GAME_BULLET_PARAM_SPRITE_SRC_H(ix), h
    
    ; 状態の更新
    ld      a, #GAME_BULLET_STATE_MOVE
    ld      GAME_BULLET_PARAM_STATE(ix), a
    xor     a
    ld      GAME_BULLET_PARAM_PHASE(ix), a
    
    ; エントリの終了
GameBulletEntryEnd:
    
    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    
    ; 終了
    ret


; 定数の定義
;


; 弾データ
;
bulletSpriteTable:
    
    .db     0xf8, 0xf8, 0x40, 0x06
    .db     0xf8, 0xf8, 0x40, 0x04



; DATA 領域
;
    .area   _DATA


; 変数の定義
;

; パラメータ
;
_gameBullet::
    
    .ds     GAME_BULLET_PARAM_SIZE * GAME_BULLET_SIZE

; エントリ
;
_gameBulletEntry::
    
    .ds     GAME_BULLET_PARAM_SIZE

; スプライトオフセット
;
spriteOffset:
    
    .ds     2



