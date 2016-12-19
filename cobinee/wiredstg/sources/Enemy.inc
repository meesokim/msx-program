; Enemy.inc : 敵
;


; マクロの定義
;

; 敵
ENEMY_TYPE                  =   0x00
ENEMY_STATE                 =   0x01
ENEMY_POSITION_X            =   0x02
ENEMY_POSITION_Y            =   0x03
ENEMY_INDEX                 =   0x04
ENEMY_HP                    =   0x05
ENEMY_SHOT                  =   0x06
ENEMY_ANIMATION             =   0x0a
ENEMY_TIMER                 =   0x0b
ENEMY_PARAM_0               =   0x0c
ENEMY_PARAM_1               =   0x0d
ENEMY_PARAM_2               =   0x0e
ENEMY_PARAM_3               =   0x0f
ENEMY_SIZE                  =   0x10
ENEMY_N                     =   0x10

; ジェネレータ
ENEMY_GENERATOR_PHASE       =   0x00
ENEMY_GENERATOR_TYPE        =   0x01
ENEMY_GENERATOR_STATE       =   0x02
ENEMY_GENERATOR_LENGTH      =   0x03
ENEMY_GENERATOR_TIMER       =   0x04
ENEMY_GENERATOR_PARAM_0     =   0x05
ENEMY_GENERATOR_PARAM_1     =   0x06
ENEMY_GENERATOR_PARAM_2     =   0x07
ENEMY_GENERATOR_SIZE        =   0x08

; 段階
ENEMY_PHASE_NULL            =   0x00
ENEMY_PHASE_NORMAL          =   0x01
ENEMY_PHASE_WARNING         =   0x02
ENEMY_PHASE_BOSS            =   0x03

; 種類
ENEMY_TYPE_NULL             =   0x00
ENEMY_TYPE_BOMB             =   0x01
ENEMY_TYPE_FANS_FRONT       =   0x02
ENEMY_TYPE_FANS_BACK        =   0x03
ENEMY_TYPE_RUGAL_FRONT      =   0x04
ENEMY_TYPE_RUGAL_BACK       =   0x05
ENEMY_TYPE_GARUN_FRONT      =   0x06
ENEMY_TYPE_GARUN_BACK       =   0x07
ENEMY_TYPE_DEE01_UPPER      =   0x08
ENEMY_TYPE_DEE01_LOWER      =   0x09
ENEMY_TYPE_DUCKER_UPPER     =   0x0a
ENEMY_TYPE_DUCKER_LOWER     =   0x0b
ENEMY_TYPE_BIGCORE_CORE     =   0x0c
ENEMY_TYPE_BIGCORE_BODY     =   0x0d
ENEMY_TYPE_BEAM             =   0x0e

; 状態
ENEMY_STATE_NULL            =   0x00

; 外部関数宣言
;

    .globl  _EnemyInitialize
    .globl  _EnemyUpdate
    .globl  _EnemyRender
    .globl  _EnemyGetEmpty
    .globl  _EnemyBombUpdate
    .globl  _EnemyBombRender
    .globl  _EnemyFansGenerate
    .globl  _EnemyFansUpdate
    .globl  _EnemyRugalGenerate
    .globl  _EnemyRugalUpdate
    .globl  _EnemyGarunGenerate
    .globl  _EnemyGarunUpdate
    .globl  _EnemyDee01Generate
    .globl  _EnemyDee01Update
    .globl  _EnemyDuckerGenerate
    .globl  _EnemyDuckerUpdate
    .globl  _EnemyBigCoreGenerate
    .globl  _EnemyBigCoreUpdateCore
    .globl  _EnemyBigCoreUpdateBody
    .globl  _EnemyBigCoreRenderCore
    .globl  _EnemyBigCoreRenderBody
    .globl  _EnemyBeamGenerate
    .globl  _EnemyBeamUpdate
    .globl  _EnemyBeamRender

; 外部変数宣言
;

    .globl  _enemy
    .globl  _enemyN
    .globl  _enemyGenerator
    .globl  _enemyCollision
