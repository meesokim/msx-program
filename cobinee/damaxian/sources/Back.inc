; Back.inc : 背景
;



; マクロの定義
;

; パターンネームテーブルオフセットアドレス
;
BACK_PATTERN_NAME_TABLE_HISCORE     =   ( 4 * 0x20 + 25)
BACK_PATTERN_NAME_TABLE_SCORE       =   ( 7 * 0x20 + 25)
BACK_PATTERN_NAME_TABLE_RATE        =   (18 * 0x20 + 27)
BACK_PATTERN_NAME_TABLE_TIMER       =   (20 * 0x20 + 27)
BACK_PATTERN_NAME_TABLE_LOGO        =   (10 * 0x20 +  4)
BACK_PATTERN_NAME_TABLE_MESSAGE     =   (12 * 0x20 +  4)

; メッセージ
;
BACK_MESSAGE_START      =   0
BACK_MESSAGE_TIMEUP     =   1
BACK_MESSAGE_GAMEOVER   =   2
BACK_MESSAGE_HISCORE    =   3



; 外部関数宣言
;

    .globl  _BackLoad
    .globl  _BackUpdate
    .globl  _BackTransferHiscore
    .globl  _BackTransferStatus
    .globl  _BackStoreLogo
    .globl  _BackRestoreLogo
    .globl  _BackStoreMessage
    .globl  _BackRestoreMessage




; 外部変数宣言
;




