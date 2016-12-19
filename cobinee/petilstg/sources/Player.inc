; Player.inc : プレイヤー
;


; マクロの定義
;

; 倒された理由
PLAYER_OVER_NULL    =   0x00
PLAYER_OVER_KILLED  =   0x01
PLAYER_OVER_EMPTY   =   0x02

; 外部関数宣言
;

    .globl  _PlayerInitialize
    .globl  _PlayerReset
    .globl  _PlayerUpdate
    .globl  _PlayerRender

; 外部変数宣言
;

    .globl  _playerOver
    .globl  _playerEnergy
    .globl  _playerShield
    .globl  _playerDamage
    .globl  _playerHitCount
