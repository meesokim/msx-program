; System.inc : システムライブラリ
;


; マクロの定義
;

; フラグ
;
FLAG_H_TIMI             =   0
FLAG_SOUND_SLEEP        =   1
FLAG_CANCEL             =   7

; リクエスト
;
REQUEST_NULL            =   0
REQUEST_VIDEO_REGISTER  =   1
REQUEST_VRAM            =   2

; キー入力
;
INPUT_KEY_UP            =   0
INPUT_KEY_DOWN          =   1
INPUT_KEY_LEFT          =   2
INPUT_KEY_RIGHT         =   3
INPUT_BUTTON_SPACE      =   4
INPUT_BUTTON_SHIFT      =   5
INPUT_BUTTON_ESC        =   6
INPUT_BUTTON_STOP       =   7
INPUT_SIZE              =   8

; ビデオ
;
VIDEO_TEXT1                                 =   0
VIDEO_TEXT1_PATTERN_NAME_TABLE              =   0x0000
VIDEO_TEXT1_PATTERN_GENERATOR_TABLE         =   0x0800
VIDEO_TEXT1_COLOR_TABLE                     =   0x0000
VIDEO_TEXT1_SPRITE_ATTRIBUTE_TABLE          =   0x1b00
VIDEO_TEXT1_SPRITE_GENERATOR_TABLE          =   0x3800
VIDEO_GRAPHIC1                              =   1
VIDEO_GRAPHIC1_PATTERN_NAME_TABLE           =   0x1800
VIDEO_GRAPHIC1_PATTERN_GENERATOR_TABLE      =   0x0000
VIDEO_GRAPHIC1_COLOR_TABLE                  =   0x2000
VIDEO_GRAPHIC1_SPRITE_ATTRIBUTE_TABLE       =   0x1b00
VIDEO_GRAPHIC1_SPRITE_GENERATOR_TABLE       =   0x3800
VIDEO_GRAPHIC2                              =   2
VIDEO_GRAPHIC2_PATTERN_NAME_TABLE           =   0x1800
VIDEO_GRAPHIC2_PATTERN_GENERATOR_TABLE      =   0x0000
VIDEO_GRAPHIC2_COLOR_TABLE                  =   0x2000
VIDEO_GRAPHIC2_SPRITE_ATTRIBUTE_TABLE       =   0x1b00
VIDEO_GRAPHIC2_SPRITE_GENERATOR_TABLE       =   0x3800
VIDEO_MULTICOLOR                            =   3
VIDEO_MULTICOLOR_PATTERN_NAME_TABLE         =   0x0800
VIDEO_MULTICOLOR_PATTERN_GENERATOR_TABLE    =   0x0000
VIDEO_MULTICOLOR_COLOR_TABLE                =   0x2000
VIDEO_MULTICOLOR_SPRITE_ATTRIBUTE_TABLE     =   0x1b00
VIDEO_MULTICOLOR_SPRITE_GENERATOR_TABLE     =   0x3800
VIDEO_TRANSFER_VRAM_0                       =   0
VIDEO_TRANSFER_VRAM_1                       =   1
VIDEO_TRANSFER_VRAM_2                       =   2
VIDEO_TRANSFER_VRAM_3                       =   3
VIDEO_TRANSFER_VRAM_SIZE                    =   4
VIDEO_TRANSFER_SRC                          =   0
VIDEO_TRANSFER_DST                          =   2
VIDEO_TRANSFER_BYTES                        =   4
VIDEO_TRANSFER_SIZE                         =   5
VIDEO_TRANSFER_VRAM_0                       =   0
VIDEO_TRANSFER_VRAM_0_SRC                   =   0
VIDEO_TRANSFER_VRAM_0_DST                   =   2
VIDEO_TRANSFER_VRAM_0_BYTES                 =   4
VIDEO_TRANSFER_VRAM_1                       =   5
VIDEO_TRANSFER_VRAM_1_SRC                   =   5
VIDEO_TRANSFER_VRAM_1_DST                   =   7
VIDEO_TRANSFER_VRAM_1_BYTES                 =   9
VIDEO_TRANSFER_VRAM_2                       =   10
VIDEO_TRANSFER_VRAM_2_SRC                   =   10
VIDEO_TRANSFER_VRAM_2_DST                   =   12
VIDEO_TRANSFER_VRAM_2_BYTES                 =   14
VIDEO_TRANSFER_VRAM_3                       =   15
VIDEO_TRANSFER_VRAM_3_SRC                   =   15
VIDEO_TRANSFER_VRAM_3_DST                   =   17
VIDEO_TRANSFER_VRAM_3_BYTES                 =   19

; 外部関数宣言
;

    ; システム
    .globl  _SystemInitialize
    
    ; キー入力
    .globl  _SystemInitializeInput
    .globl  _SystemUpdateInput
    
    ; ビデオ
    .globl  _SystemInitializeVideo
    .globl  _SystemSetScreenMode
    .globl  _SystemTransferVideoRegister
    .globl  _SystemTransferVram
    
    ; スプライト
    .globl  _SystemClearSprite
    .globl  _SystemTransferSprite
    .globl  _SystemSetSprite
    
    ; サウンド
    .globl  _SystemInitializeSound
    .globl  _SystemUpdateSound
    .globl  _SystemSuspendSound
    .globl  _SystemResumeSound
    
    ; 乱数
    .globl  _SystemGetRandom
    
    ; デバッグ
    .globl  _SystemPutRegisterA

; 外部変数宣言
;

    ; フラグ
    .globl  _flag
    
    ; リクエスト
    .globl  _request
    
    ; キー入力
    .globl  _input
    
    ; ビデオ
    .globl  _videoPort
    .globl  _videoRegister
    .globl  _videoTransfer
    
    ; スプライト
    .globl  _sprite
    
    ; サウンド
    .globl  _soundRequest
    .globl  _soundHead
    .globl  _soundPlay
