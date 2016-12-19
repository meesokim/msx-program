; Pilot.s : �p�C���b�g
;


; ���W���[���錾
;
    .module Pilot

; �Q�ƃt�@�C��
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include	"Game.inc"
    .include	"Pilot.inc"

; �}�N���̒�`
;

; �A�j���[�V����
PILOT_ANIMATION_TIMER       =   0x00
PILOT_ANIMATION_SPRITE      =   0x01
PILOT_ANIMATION_SPRITE_L    =   0x01
PILOT_ANIMATION_SPRITE_H    =   0x02
PILOT_ANIMATION_DX          =   0x03
PILOT_ANIMATION_LEFT        =   0x04
PILOT_ANIMATION_RIGHT       =   0x05
PILOT_ANIMATION_SIZE        =   0x06



; CODE �̈�
;
    .area   _CODE

; �p�C���b�g������������
;
_PilotInitialize::
    
    ; ���W�X�^�̕ۑ�
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �p�C���b�g�����Z�b�g����
;
_PilotReset::
    
    ; ���W�X�^�̕ۑ�
    
    ; �p�C���b�g�̏�����
    ld      a, #PILOT_STATE_START
    ld      (_pilotState), a
    xor     a
    ld      (_pilotTurn), a
    ld      (_pilotRange + PILOT_RANGE_LEFT), a
    ld      a, #0x90
    ld      (_pilotRange + PILOT_RANGE_TOP), a
    ld      a, #0x0f
    ld      (_pilotRange + PILOT_RANGE_RIGHT), a
    ld      a, #0xa0
    ld      (_pilotRange + PILOT_RANGE_BOTTOM), a
    ld      hl, #0xa000
    ld      (pilotPosition), hl
    ld      hl, #pilotAnimationStart
    ld      (pilotAnimation), hl
    xor     a
    ld      (pilotAnimationFrame), a
    ld      a, (hl)
    ld      (pilotAnimationTimer), a
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �p�C���b�g���X�V����
;
_PilotUpdate::
    
    ; ���W�X�^�̕ۑ�
    
    ;�@�A�j���[�V�����̎擾
    ld      a, (pilotAnimationFrame)
    ld      e, a
    ld      d, #0x00
    ld      ix, (pilotAnimation)
    add     ix, de
    
    ; ���֓]��
    ld      a, (_pilotState)
    cp      #PILOT_STATE_WALK_RIGHT
    jr      nz, 19$
    ld      a, (pilotPosition + 0x00)
    add     a, PILOT_ANIMATION_RIGHT(ix)
    ld      e, a
    cp      #0xf8
    jr      c, 10$
    ld      a, #0xf8
    jr      11$
10$:
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$
    ld      a, e
11$:
    ld      (pilotPosition + 0x00), a
    ld      ix, #pilotAnimationTurnLeft
    ld      (pilotAnimation), ix
    ld      a, #PILOT_STATE_TURN_LEFT
    ld      (_pilotState), a
    xor     a
    ld      (pilotAnimationFrame), a
    ld      a, PILOT_ANIMATION_TIMER(ix)
    ld      (pilotAnimationTimer), a
    ld      hl, #_pilotTurn
    inc     (hl)
19$:

    ; �E�֓]��
    ld      a, (_pilotState)
    cp      #PILOT_STATE_WALK_LEFT
    jr      nz, 29$
    ld      a, (pilotPosition + 0x00)
    add     a, PILOT_ANIMATION_LEFT(ix)
    ld      e, a
    cp      #0x08
    jr      nc, 20$
    ld      a, #0x08
    jr      21$
20$:
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 29$
    ld      a, e
21$:
    ld      (pilotPosition + 0x00), a
    ld      ix, #pilotAnimationTurnRight
    ld      (pilotAnimation), ix
    ld      a, #PILOT_STATE_TURN_RIGHT
    ld      (_pilotState), a
    xor     a
    ld      (pilotAnimationFrame), a
    ld      a, PILOT_ANIMATION_TIMER(ix)
    ld      (pilotAnimationTimer), a
    ld      hl, #_pilotTurn
    inc     (hl)
29$:
    
    ; �A�j���[�V�����̍X�V
    
    ; �^�C�}�̍X�V
    ld      hl, #pilotAnimationTimer
    dec     (hl)
    jr      nz, 39$
    
    ; �t���[���̍X�V
    ld      a, (pilotAnimationFrame)
    add     a, #0x06
    ld      e, a
    ld      d, #0x00
    ld      ix, (pilotAnimation)
    add     ix, de
    ld      a, PILOT_ANIMATION_TIMER(ix)
    or      a
    ld      a, e
    jr      nz, 38$
    
    ; START �̍X�V
    ld      a, (_pilotState)
    cp      #PILOT_STATE_START
    jr      nz, 30$
    ld      ix, #pilotAnimationWalkRight
    ld      (pilotAnimation), ix
    ld      a, #PILOT_STATE_WALK_RIGHT
    ld      (_pilotState), a
    xor     a
    jr      38$
    
    ; WALK RIGHT �̍X�V
30$:
    cp      #PILOT_STATE_WALK_RIGHT
    jr      nz, 31$
    ld      ix, #pilotAnimationWalkRight
    xor     a
    jr      38$
    
    ; WALK LEFT �̍X�V
31$:
    cp      #PILOT_STATE_WALK_LEFT
    jr      nz, 32$
    ld      ix, #pilotAnimationWalkLeft
    xor     a
    jr      38$

    ; TURN RIGHT �̍X�V
32$:    
    cp      #PILOT_STATE_TURN_RIGHT
    jr      nz, 33$
    ld      ix, #pilotAnimationWalkRight
    ld      (pilotAnimation), ix
    ld      a, #PILOT_STATE_WALK_RIGHT
    ld      (_pilotState), a
    xor     a
    jr      38$

    ; TURN LEFT �̍X�V
33$:    
    cp      #PILOT_STATE_TURN_LEFT
    jr      nz, 39$
    ld      ix, #pilotAnimationWalkLeft
    ld      (pilotAnimation), ix
    ld      a, #PILOT_STATE_WALK_LEFT
    ld      (_pilotState), a
    xor     a
;   jr      38$
    
    ; �t���[���̍Đݒ�
38$:
    ld      (pilotAnimationFrame), a
    ld      hl, #(pilotPosition + 0x00)
    ld      a, (hl)
    add     a, PILOT_ANIMATION_DX(ix)
    ld      (hl), a
    ld      a, PILOT_ANIMATION_TIMER(ix)
    ld      (pilotAnimationTimer), a
    
    ; �A�j���[�V�����X�V�̊���
39$:
    
    ; �͈͂̎擾
    ld      iy, #_pilotRange
    ld      de, (pilotPosition)
    ld      a, e
    add     a, PILOT_ANIMATION_LEFT(ix)
    ld      PILOT_RANGE_LEFT(iy), a
    ld      a, e
    add     a, PILOT_ANIMATION_RIGHT(ix)
    ld      PILOT_RANGE_RIGHT(iy), a
    ld      a, d
    ld      PILOT_RANGE_BOTTOM(iy), a
    sub     #0x10
    ld      PILOT_RANGE_TOP(iy), a
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret
    
; �p�C���b�g��`�悷��
;
_PilotRender::
    
    ; ���W�X�^�̕ۑ�
    
    ; �X�v���C�g�̕`��
    ld      a, (pilotAnimationFrame)
    ld      e, a
    ld      d, #0x00
    ld      ix, (pilotAnimation)
    add     ix, de
    ld      e, PILOT_ANIMATION_SPRITE_L(ix)
    ld      d, PILOT_ANIMATION_SPRITE_H(ix)
    ld      ix, #pilotSprite
    add     ix, de
    ld      hl, #(_sprite + GAME_SPRITE_PILOT)
    ld      bc, (pilotPosition) 
    ld      a, 0x00(ix)
    add     a, b
    ld      (hl), a
    inc     hl
    ld      a, 0x01(ix)
    add     a, c
    ld      (hl), a
    inc     hl
    ld      a, 0x02(ix)
    ld      (hl), a
    inc     hl
    ld      a, 0x03(ix)
    ld      (hl), a
    inc     hl
    ld      a, 0x04(ix)
    add     a, b
    ld      (hl), a
    inc     hl
    ld      a, 0x05(ix)
    add     a, c
    ld      (hl), a
    inc     hl
    ld      a, 0x06(ix)
    ld      (hl), a
    inc     hl
    ld      a, 0x07(ix)
    ld      (hl), a
;   inc     hl
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �萔�̒�`
;

; �A�j���[�V����
;
pilotAnimationStart:
    
    .db     0x04, 0x00, 0x00, 0x00, 0x00, 0x04
    .db     0x04, 0x08, 0x00, 0x00, 0x00, 0x04
    .db     0x04, 0x10, 0x00, 0x00, 0x00, 0x06
    .db     0x04, 0x18, 0x00, 0x00, 0x00, 0x07
    .db     0x04, 0x20, 0x00, 0x00, 0x00, 0x08
    .db     0x04, 0x28, 0x00, 0x01, 0x00, 0x0b
    .db     0x00

pilotAnimationWalkRight:
    
    .db     0x04, 0x30, 0x00, 0x03, 0x00, 0x0a
    .db     0x04, 0x38, 0x00, 0x07, 0x00, 0x08
    .db     0x04, 0x40, 0x00, 0x02, 0x00, 0x0c
    .db     0x04, 0x48, 0x00, 0x03, 0x00, 0x0c
    .db     0x04, 0x50, 0x00, 0x05, 0x00, 0x08
    .db     0x04, 0x58, 0x00, 0x04, 0x00, 0x0b
    .db     0x00
    
pilotAnimationWalkLeft:
    
    .db     0x04, 0x60, 0x00, 0xfd, 0xf6, 0x00
    .db     0x04, 0x68, 0x00, 0xf9, 0xf8, 0x00
    .db     0x04, 0x70, 0x00, 0xfe, 0xf4, 0x00
    .db     0x04, 0x78, 0x00, 0xfd, 0xf4, 0x00
    .db     0x04, 0x80, 0x00, 0xfb, 0xf8, 0x00
    .db     0x04, 0x88, 0x00, 0xfc, 0xf5, 0x00
    .db     0x00
    
pilotAnimationTurnRight:
    
    .db     0x04, 0x90, 0x00, 0x00, 0x00, 0x0a
    .db     0x04, 0x98, 0x00, 0xff, 0x00, 0x07
    .db     0x04, 0xa0, 0x00, 0xf9, 0x00, 0x0c
    .db     0x04, 0xa8, 0x00, 0x02, 0x00, 0x0d
    .db     0x04, 0xb0, 0x00, 0x00, 0x00, 0x0c
    .db     0x04, 0xb8, 0x00, 0x03, 0x00, 0x0c
    .db     0x04, 0xc0, 0x00, 0x06, 0x00, 0x0c
    .db     0x04, 0xc8, 0x00, 0x00, 0x00, 0x09
    .db     0x00
    
pilotAnimationTurnLeft:
    
    .db     0x04, 0xd0, 0x00, 0x00, 0xf6, 0x00
    .db     0x04, 0xd8, 0x00, 0x01, 0xf9, 0x00
    .db     0x04, 0xe0, 0x00, 0x07, 0xf4, 0x00
    .db     0x04, 0xe8, 0x00, 0xfe, 0xf3, 0x00
    .db     0x04, 0xf0, 0x00, 0x00, 0xf4, 0x00
    .db     0x04, 0xf8, 0x00, 0xfd, 0xf4, 0x00
    .db     0x04, 0x00, 0x01, 0xfb, 0xf4, 0x00
    .db     0x04, 0x08, 0x01, 0x00, 0xf7, 0x00
    .db     0x00
    
; �X�v���C�g
;
pilotSprite:
    
    .db     0xf0, 0x00, 0x20, 0x0f, 0xec, 0x01, 0x38, 0x0f  ; 000: �� Start
    .db     0xf0, 0x00, 0x24, 0x0f, 0xec, 0x02, 0x38, 0x0f
    .db     0xf0, 0x00, 0x28, 0x0f, 0xec, 0x03, 0x38, 0x0f
    .db     0xf0, 0x00, 0x2c, 0x0f, 0xec, 0x04, 0x38, 0x0f
    .db     0xf0, 0x00, 0x30, 0x0f, 0xec, 0x06, 0x38, 0x0f
    .db     0xf0, 0x00, 0x34, 0x0f, 0xec, 0x09, 0x38, 0x0f
    .db     0xf0, 0x00, 0x40, 0x0f, 0xec, 0x08, 0x38, 0x0f  ; 030: �� Walk
    .db     0xf0, 0x00, 0x44, 0x0f, 0xed, 0x05, 0x38, 0x0f
    .db     0xf0, 0x00, 0x48, 0x0f, 0xec, 0x08, 0x38, 0x0f
    .db     0xf0, 0x00, 0x4c, 0x0f, 0xec, 0x09, 0x38, 0x0f
    .db     0xf0, 0x00, 0x50, 0x0f, 0xed, 0x06, 0x38, 0x0f
    .db     0xf0, 0x00, 0x54, 0x0f, 0xec, 0x09, 0x38, 0x0f
    .db     0xf0, 0xf1, 0x60, 0x0f, 0xec, 0xf5, 0x3c, 0x0f  ; 060: �� Walk
    .db     0xf0, 0xf1, 0x64, 0x0f, 0xed, 0xf8, 0x3c, 0x0f
    .db     0xf0, 0xf1, 0x68, 0x0f, 0xec, 0xf5, 0x3c, 0x0f
    .db     0xf0, 0xf1, 0x6c, 0x0f, 0xec, 0xf4, 0x3c, 0x0f
    .db     0xf0, 0xf1, 0x70, 0x0f, 0xed, 0xf7, 0x3c, 0x0f
    .db     0xf0, 0xf1, 0x74, 0x0f, 0xec, 0xf4, 0x3c, 0x0f
    .db     0xf0, 0x00, 0xa0, 0x0f, 0xec, 0x04, 0x3c, 0x0f  ; 090: �� Turn
    .db     0xf0, 0x00, 0xa4, 0x0f, 0xec, 0x02, 0x3c, 0x0f
    .db     0xf0, 0x00, 0xa8, 0x0f, 0xed, 0x07, 0x3c, 0x0f
    .db     0xf0, 0x00, 0xac, 0x0f, 0xed, 0x09, 0x5c, 0x0f
    .db     0xf0, 0x00, 0xb0, 0x0f, 0xf0, 0x09, 0x7c, 0x0f
    .db     0xf0, 0x00, 0xb4, 0x0f, 0xef, 0x07, 0x78, 0x0f
    .db     0xf0, 0x00, 0xb8, 0x0f, 0xee, 0x06, 0x78, 0x0f
    .db     0xf0, 0x00, 0xbc, 0x0f, 0xee, 0x08, 0x38, 0x0f
    .db     0xf0, 0xf1, 0x80, 0x0f, 0xec, 0xf9, 0x38, 0x0f  ; 0d0: �� Turn
    .db     0xf0, 0xf1, 0x84, 0x0f, 0xec, 0xfb, 0x38, 0x0f
    .db     0xf0, 0xf1, 0x88, 0x0f, 0xed, 0xf6, 0x38, 0x0f
    .db     0xf0, 0xf1, 0x8c, 0x0f, 0xed, 0xf5, 0x58, 0x0f
    .db     0xf0, 0xf1, 0x90, 0x0f, 0xf0, 0xf5, 0x78, 0x0f
    .db     0xf0, 0xf1, 0x94, 0x0f, 0xef, 0xf7, 0x7c, 0x0f
    .db     0xf0, 0xf1, 0x98, 0x0f, 0xee, 0xf8, 0x7c, 0x0f
    .db     0xf0, 0xf1, 0x9c, 0x0f, 0xee, 0xf6, 0x3c, 0x0f


; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

; ���
;
_pilotState::

    .ds     1

; �����]���̉�
;
_pilotTurn::

    .ds     1

; �͈�
;
_pilotRange::

    .ds     PILOT_RANGE_SIZE

; �ʒu
;
pilotPosition:

    .ds     2

; �A�j���[�V����
;
pilotAnimation:
    
    .ds     2

pilotAnimationFrame:

    .ds     1

pilotAnimationTimer:

    .ds     1
