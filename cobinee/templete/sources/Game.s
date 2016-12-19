; Game.s : ゲーム
;


; モジュール宣言
;
    .module Game

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; パターンネームの設定
    ld      hl, #(_appPatternName + 0x0000)
    ld      de, #(_appPatternName + 0x0001)
    ld      bc, #0x02ff
    xor     a
    ld      (hl), a
    ldir
    ld      hl, #(_appPatternName + 0x0200)
    ld      de, #0x8081
    ld      b, #0x10
10$:
    ld      (hl), d
    inc     hl
    ld      (hl), e
    inc     hl
    djnz    10$
    ld      de, #0x8283
    ld      b, #0x10
11$:
    ld      (hl), d
    inc     hl
    ld      (hl), e
    inc     hl
    djnz    11$
    
    ; パターンネームの転送
    call    _AppTransferPatternName
    
    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; ビデオレジスタの転送
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; 状態の設定
    ld      a, #GAME_STATE_NULL
    ld      (gameState), a
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_appState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを更新する
;
_GameUpdate::
    
    ; レジスタの保存
    
    ; 初期化の開始
    ld      a, (gameState)
    or      a
    jr      nz, 09$
    
    ; 位置の初期化
    ld      hl, #0x8080
    ld      (gamePosition), hl
    
    ; ジャンプの初期化
    ld      a, #0x08
    ld      (gameJump), a
    
    ; アニメーションの初期化
    xor     a
    ld      (gameAnimation), a
    
    ; ＢＧＭの再生
    ld      hl, #gameSoundBgm0
    ld      (_soundRequest + 0x0000), hl
    ld      hl, #gameSoundBgm1
    ld      (_soundRequest + 0x0002), hl
    
    ; 初期化の完了
    ld      a, #GAME_STATE_WALK
    ld      (gameState), a
09$:
    
    ; 歩行の開始
    ld      a, (gameState)
    cp      #GAME_STATE_WALK
    jr      nz, 19$
    
    ; アニメーションの更新
    ld      hl, #gameAnimation
    ld      a, (hl)
    inc     a
    and     #0x0f
    ld      (hl), a
    
    ; 位置の更新
    ld      hl, #(gamePosition + 0x00)
    inc     (hl)
    
    ; SPACE バーの入力
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 90$
    
    ; ジャンプの設定
    ld      a, #0xf0
    ld      (gameJump), a
    
    ; ＳＥの再生
    ld      hl, #gameSoundJump
    ld      (_soundRequest + 0x0006), hl
    
    ; 歩行の完了
    ld      a, #GAME_STATE_JUMP
    ld      (gameState), a
19$:
    
    ; ジャンプの開始
    ld      a, (gameState)
    cp      #GAME_STATE_JUMP
    jr      nz, 29$
    
    ; アニメーションの更新
    ld      a, #0x10
    ld      (gameAnimation), a
    
    ; 位置の更新
    ld      hl, #(gamePosition + 0x00)
    inc     (hl)
    inc     hl
    ld      de, #gameJump
    ld      a, (de)
    sra     a
    sra     a
    add     a, (hl)
    ld      (hl), a
    cp      #0x80
    jr      nc, 20$
    ex      de, hl
    inc     (hl)
    jr      90$
20$:
    ld      a, #0x80
    ld      (hl), a
    
    ; ジャンプの完了
    ld      a, #GAME_STATE_WALK
    ld      (gameState), a
29$:

    ; 描画の開始
90$:
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; スプライトの描画
    ld      hl, #gameAnimation
    ld      a, (hl)
    add     a, a
    add     a, a
    and     #0xf0
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameSprite
    add     hl, de
    ld      de, #(_sprite + GAME_SPRITE_NULL)
    ld      b, #0x03
91$:
    ld      a, (gamePosition + 0x01)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (gamePosition + 0x00)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    djnz    91$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; スプライト
;
gameSprite:

    .db     0xef, 0xf8, 0x20, 0x0a, 0xef, 0xf8, 0x40, 0x0c, 0xef, 0xf8, 0x60, 0x08, 0x00, 0x00, 0x00, 0x00
    .db     0xef, 0xf8, 0x24, 0x0a, 0xef, 0xf8, 0x44, 0x0c, 0xef, 0xf8, 0x64, 0x08, 0x00, 0x00, 0x00, 0x00
    .db     0xef, 0xf8, 0x28, 0x0a, 0xef, 0xf8, 0x48, 0x0c, 0xef, 0xf8, 0x68, 0x08, 0x00, 0x00, 0x00, 0x00
    .db     0xef, 0xf8, 0x24, 0x0a, 0xef, 0xf8, 0x44, 0x0c, 0xef, 0xf8, 0x64, 0x08, 0x00, 0x00, 0x00, 0x00
    .db     0xef, 0xf8, 0x2c, 0x0a, 0xef, 0xf8, 0x4c, 0x0c, 0xef, 0xf8, 0x6c, 0x08, 0x00, 0x00, 0x00, 0x00

; サウンド
;
gameSoundBgm0:
    
    .ascii  "T1V15-4L5"
    .ascii  "O4CO5CO3AO4AO3B-O4B-R7R9"
    .ascii  "O4CO5CO3AO4AO3B-O4B-R7R9"
    .ascii  "O3FO4FO3DO4DO3E-O4E-R7R9"
    .ascii  "O3FO4FO3DO4DO3E-O4E-R7R9"
    .ascii  "R7T5L0O4E-DD-T1RL7CE-DO3A-GO4D-"
    .ascii  "L0T5O4CG-E-T1RT5EB-AT1R"
    .ascii  "L1T5O4A-E-O3BT1RT5B-AA-T1R"
    .ascii  "L9RRR"
    .db     0xff

gameSoundBgm1:
    
    .ascii  "T1V15-4L5"
    .ascii  "O3CO4CO2AO3AO2B-O3B-R7R9"
    .ascii  "O3CO4CO2AO3AO2B-O3B-R7R9"
    .ascii  "O2FO3FO2DO3DO2E-O3E-R7R9"
    .ascii  "O2FO3FO2DO3DO2E-O3E-R7R9"
    .ascii  "R7T5L0O3E-DD-T1RL7CE-DO2A-GO3D-"
    .ascii  "L0T5O3CG-E-T1RT5EB-AT1R"
    .ascii  "L1T5O3A-E-O2BT1RT5B-AA-T1R"
    .ascii  "L9RRR"
    .db     0xff
    
gameSoundJump:
    
    .ascii  "T1V15L0O4A1O3ABO4C+D+FGABO5C+D+FGA"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
gameState:
    
    .ds     1

; 位置
;
gamePosition:

    .ds     2

; ジャンプ
;
gameJump:

    .ds     1

; アニメーション
;
gameAnimation:

    .ds     1