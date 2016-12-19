; Stage.inc : ステージ
;


; マクロの定義
;

; 状態
STAGE_STATE_NULL            =   0x00
STAGE_STATE_OPEN            =   0x10
STAGE_STATE_PLAY            =   0x20
STAGE_STATE_CLOSE           =   0x30

; 種類
STAGE_TYPE_NORMAL           =   0x00
STAGE_TYPE_EXTRA            =   0x01

; ブロック
STAGE_BLOCK_STATE           =   0x00
STAGE_BLOCK_OFFSET          =   0x01
STAGE_BLOCK_POSITION_X      =   0x02
STAGE_BLOCK_POSITION_Y      =   0x03
STAGE_BLOCK_SIZE            =   0x04

; コイン
STAGE_COIN_STATE            =   0x00
STAGE_COIN_OFFSET           =   0x01
STAGE_COIN_POSITION_X       =   0x02
STAGE_COIN_POSITION_Y       =   0x03
STAGE_COIN_SIZE             =   0x04
STAGE_COIN_N                =   0x04
STAGE_COIN_ENTRY            =   0x08

; ヒント
STAGE_HINT_STATE            =   0x00
STAGE_HINT_POSITION_X       =   0x01
STAGE_HINT_POSITION_Y       =   0x02
STAGE_HINT_SIZE             =   0x03

; 外部関数宣言
;

    .globl  _StageInitialize
    .globl  _StageCreate
    .globl  _StageUpdate
    .globl  _StageRender
    .globl  _StageHit
    .globl  _StagePunchBlock
    .globl  _StageGetFieldCoin
    .globl  _StageGetBlockCoin

; 外部変数宣言
;

    .globl  _stage
    .globl  _stageState
    .globl  _stageNo
    .globl  _stageType
    .globl  _stageCoinRest
