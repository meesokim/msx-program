; Player.s : プレイヤー
;


; モジュール宣言
;
    .module Player

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include	"Player.inc"


; CODE 領域
;
    .area   _CODE

; プレイヤーを初期化する
;
_PlayerInitialize::
    
    ; レジスタの保存
    
    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤーをリセットする
;
_PlayerReset::
    
    ; レジスタの保存
    
    ; プレイヤーの初期化
    ld      hl, #0x4800
    ld      (_playerEnergy), hl
    ld      (_playerShield), hl
    xor     a
    ld      (_playerOver), a
    ld      (_playerDamage), a
    ld      (_playerHitCount), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤーを更新する
;
_PlayerUpdate::
    
    ; レジスタの保存
    
    ; シールドやエネルギーの消費
    ld      a, (_playerOver)
    or      a
    call    z, PlayerCost
    
    ; ヒットカウンタの更新
    ld      a, (_playerHitCount)
    or      a
    jr      z, 0$
    dec     a
    ld      (_playerHitCount), a
0$:
    
    ; レジスタの復帰
    
    ; 終了
    ret
    
; プレイヤーを描画する
;
_PlayerRender::
    
    ; レジスタの復帰
    
    ; 終了
    ret

; シールドやエネルギーを消費する
;
PlayerCost:
    
    ; レジスタの保存
    
    ; 消費エネルギーの取得
    ld      hl, #0x0001
    
    ; 移動による消費
    ld      a, (_gameMoveZ)
    or      a
    jr      z, 00$
    inc     hl
00$:
    
    ; ダメージによるシールドの減少
    ld      a, (_playerDamage)
    or      a
    jr      z, 19$
    push    hl
    ld      d, a
    ld      e, #0x00
    ld      hl, (_playerShield)
    ld      a, h
    or      l
    jr      z, 11$
    or      a
    sbc     hl, de
    jr      nc, 10$
    ld      hl, #0x0000
10$:
    ld      (_playerShield), hl
    ld      a, #0x08
    ld      (_playerHitCount), a
    ld      hl, #playerSeHit
    jr      18$
11$:
    ld      a, #PLAYER_OVER_KILLED
    ld      (_playerOver), a
    ld      a, #0x60
    ld      (_playerHitCount), a
    ld      hl, #playerSeBomb
18$:
    ld      (_soundRequest + 6), hl
    xor     a
    ld      (_playerDamage), a
    pop     hl
19$:

    ; シールドの回復
    ld      a, (_playerShield + 0x01)
    cp      #0x48
    jr      z, 29$
    ld      d, a
    ld      a, (_playerShield + 0x00)
    or      d
    jr      z, 29$
    push    hl
    ld      hl, (_playerShield)
    ld      de, #0x0010
    add     hl, de
    ex      de, hl
    ld      hl, #0x4800
    or      a
    sbc     hl, de
    jr      nc, 20$
    ld      de, #0x4800
20$:
    ex      de, hl
    ld      (_playerShield), hl
    pop     hl
    ld      de, #0x0004
    add     hl, de
29$:

    ; エネルギーの消費
    ld      b, h
    ld      c, l
    ld      hl, (_playerEnergy)
    or      a
    sbc     hl, bc
    jr      nc, 30$
    ld      hl, #0x0000
    ld      a, #PLAYER_OVER_EMPTY
    ld      (_playerOver), a
    ld      a, #0x60
    ld      (_playerHitCount), a
30$:
    ld      (_playerEnergy), hl

    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; ＳＥ
;
playerSeHit:

    .ascii  "T1V15L0O2GD-ED-GD-ED-GD-ED-GD-ED-"
    .db     0x00

playerSeBomb:

    .ascii  "T1V15L0"
    .ascii  "O2CO1D-O2D-O1CO2CO1D-O2D-O1CO2CO1D-O2D-O1CO2CO1D-O2D-O1C"
    .ascii  "O2CO1D-O2D-O1CO2CO1D-O2D-O1CO2CO1D-O2D-O1CO2CO1D-O2D-O1C"
    .ascii  "O2CO1D-O2D-O1CO2CO1D-O2D-O1CO2CO1D-O2D-O1CO2CO1D-O2D-O1C"
    .ascii  "O2CO1D-O2D-O1CO2CO1D-O2D-O1CO2CO1D-O2D-O1CO2CO1D-O2D-O1C"
    .ascii  "O2CO1D-O2D-O1CO2CO1D-O2D-O1CO2CO1D-O2D-O1CO2CO1D-O2D-O1C"
    .ascii  "O2CO1D-O2D-O1CO2CO1D-O2D-O1CO2CO1D-O2D-O1CO2CO1D-O2D-O1C"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 倒された理由
;
_playerOver::

    .ds     1

; エネルギー
;
_playerEnergy::

    .ds     2

; シールド
;
_playerShield::

    .ds     2
    
; ダメージ
;
_playerDamage::

    .ds     1
    
; ヒットカウンタ
;
_playerHitCount::

    .ds     1
