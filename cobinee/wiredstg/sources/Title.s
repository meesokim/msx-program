; Title.s : タイトル
;


; モジュール宣言
;
    .module Title

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Title.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; タイトルを初期化する
;
_TitleInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; パターンのクリア
    ld      hl, #(_appPatternName + 0x0000)
    ld      de, #(_appPatternName + 0x0001)
    ld      bc, #0x02ff
    xor     a
    ld      (hl), a
    ldir
    
    ; パターンネームの転送
    call    _AppTransferPatternName
    
    ; パターンジェネレータの設定
    ld      a, #(APP_PATTERN_GENERATOR_TABLE_0 >> 11)
    ld      (_videoRegister + VDP_R4), a
    
    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; ビデオレジスタの転送
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; 状態の設定
    xor     a
    ld      (titleState), a
    ld      a, #APP_STATE_TITLE_UPDATE
    ld      (_appState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; タイトルを更新する
;
_TitleUpdate::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; 初期化の開始
    ld      a, (titleState)
    or      a
    jr      nz, 09$
    
    ; アニメーションの初期化
    xor     a
    ld      (titleAnimation), a
    
    ; タイマの初期化
;   xor     a
    ld      (titleTimer), a
    
    ; 初期化の完了
    ld      hl, #titleState
    inc     (hl)
09$:
    
    ; 乱数の更新
    call    _SystemGetRandom
    
    ; SPACE キーの監視
    ld      hl, #titleState
    ld      a, (hl)
    dec     a
    jr      nz, 19$
    
    ; タイマの更新
    ld      hl, #titleTimer
    inc     (hl)
    
    ; SPACE キーの押下
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 90$
    ld      hl, #titleState
    inc     (hl)
    
    ; アニメーションの設定
    ld      a, #0x60
    ld      (titleAnimation), a
    
    ; ジングルの再生
    ld      hl, #titleJingle0
    ld      (_soundRequest + 0x0000), hl
    ld      hl, #titleJingle1
    ld      (_soundRequest + 0x0002), hl
    ld      hl, #titleJingle2
    ld      (_soundRequest + 0x0004), hl
    jr      90$
    
    ; SPACE キー監視の完了
19$:
    
    ; タイマの更新
    ld      hl, #titleTimer
    ld      a, (hl)
    add     a, #0x08
    ld      (hl), a
    
    ; ジングルの監視
    ld      hl, (_soundPlay + 0x0000)
    ld      a, h
    or      l
    jr      nz, 29$
    
;   ; 描画の停止
;   ld      hl, #(_videoRegister + VDP_R1)
;   res     #VDP_R1_BL, (hl)
    
;   ; ビデオレジスタの転送
;   ld      hl, #_request
;   set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; ゲームの開始
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_appState), a
;   jr      90$
    
    ; ジングル監視の完了
29$:
    
    ; アニメーションの更新
90$:
    ld      hl, #titleAnimation
    ld      a, (hl)
    cp      #0x60
    adc     a, #0x00
    ld      (hl), a
    ld      hl, #titleLogoString
    ld      de, #(_appPatternName + 0x00c0)
    ld      c, a
    ld      b, #0x00
    ldir
    
    ; ハイスコアの描画
    ld      a, (titleAnimation)
    cp      #0x60
    jr      c, 98$
    ld      hl, #titleScoreString
    ld      de, #(_appPatternName + 0x0187)
    ld      bc, #0x0011
    ldir
    ld      hl, #_appScore
    ld      de, #(_appPatternName + 0x0190)
    ld      bc, #0x0650
91$:
    ld      a, (hl)
    or      a
    jr      nz, 92$
    inc     hl
    inc     de
    djnz    91$
    jr      93$
92$:
    ld      a, (hl)
    add     a, c
    ld      (de), a
    inc     hl
    inc     de
    djnz    92$
    ld      a, c
    ld      (de), a
93$:
    
    ; SPACE キーの描画
    ld      a, (titleTimer)
    and     #0x10
    ld      c, a
    ld      b, #0x00
    ld      hl, #titleSpaceString
    add     hl, bc
    ld      de, #(_appPatternName + 0x0228)
    ld      bc, #0x0f
    ldir
    
    ; アニメーションの完了
98$:
    call    _AppTransferPatternName
    
    ; 更新の完了
99$:

    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; 定数の定義
;

; ロゴ
;
titleLogoString:

    .db     0x00, 0x00, 0x00, 0x00, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0xa0, 0xa1
    .db     0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0xb0, 0xb1
    .db     0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x8a, 0x8b, 0x8c, 0x8d, 0x9a
    .db     0x9b, 0x9c, 0x9d, 0x9e, 0x9f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

; スコア
;
titleScoreString:

    .db     0x68, 0x69, 0x4d, 0x73, 0x63, 0x6f, 0x72, 0x65, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x50

; SPACE キー
;
titleSpaceString:

    .db     0x70, 0x72, 0x65, 0x73, 0x73, 0x00, 0x73, 0x70, 0x61, 0x63, 0x65, 0x00, 0x62, 0x61, 0x72, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

; ジングル
;
titleJingle0:

    .ascii  "T2V15-L1"
;   .ascii  "O4BO5DGBG5R7"
    .ascii  "O5G5BGDO4BR7"
    .db     0x00

titleJingle1:

    .ascii  "T2V15-L1"
;   .ascii  "O4DGBO5DO4B5R7"
    .ascii  "O4B5O5DO4BGDR7"
    .db     0x00
    
titleJingle2:

    .ascii  "T2V15-L1"
;   .ascii  "O3G4O4DO3G5R7"
    .ascii  "O3G5O4DO3G4R7"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
titleState:

    .ds     1

; アニメーション
;
titleAnimation:

    .ds     1

; タイマ
;
titleTimer:

    .ds     1
