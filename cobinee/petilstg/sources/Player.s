; Player.s : �v���C���[
;


; ���W���[���錾
;
    .module Player

; �Q�ƃt�@�C��
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include	"Player.inc"


; CODE �̈�
;
    .area   _CODE

; �v���C���[������������
;
_PlayerInitialize::
    
    ; ���W�X�^�̕ۑ�
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �v���C���[�����Z�b�g����
;
_PlayerReset::
    
    ; ���W�X�^�̕ۑ�
    
    ; �v���C���[�̏�����
    ld      hl, #0x4800
    ld      (_playerEnergy), hl
    ld      (_playerShield), hl
    xor     a
    ld      (_playerOver), a
    ld      (_playerDamage), a
    ld      (_playerHitCount), a
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �v���C���[���X�V����
;
_PlayerUpdate::
    
    ; ���W�X�^�̕ۑ�
    
    ; �V�[���h��G�l���M�[�̏���
    ld      a, (_playerOver)
    or      a
    call    z, PlayerCost
    
    ; �q�b�g�J�E���^�̍X�V
    ld      a, (_playerHitCount)
    or      a
    jr      z, 0$
    dec     a
    ld      (_playerHitCount), a
0$:
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret
    
; �v���C���[��`�悷��
;
_PlayerRender::
    
    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �V�[���h��G�l���M�[�������
;
PlayerCost:
    
    ; ���W�X�^�̕ۑ�
    
    ; ����G�l���M�[�̎擾
    ld      hl, #0x0001
    
    ; �ړ��ɂ�����
    ld      a, (_gameMoveZ)
    or      a
    jr      z, 00$
    inc     hl
00$:
    
    ; �_���[�W�ɂ��V�[���h�̌���
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

    ; �V�[���h�̉�
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

    ; �G�l���M�[�̏���
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

    ; ���W�X�^�̕��A
    
    ; �I��
    ret

; �萔�̒�`
;

; �r�d
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


; DATA �̈�
;
    .area   _DATA

; �ϐ��̒�`
;

; �|���ꂽ���R
;
_playerOver::

    .ds     1

; �G�l���M�[
;
_playerEnergy::

    .ds     2

; �V�[���h
;
_playerShield::

    .ds     2
    
; �_���[�W
;
_playerDamage::

    .ds     1
    
; �q�b�g�J�E���^
;
_playerHitCount::

    .ds     1
