; App.inc : �A�v���P�[�V����
;



; �}�N���̒�`
;

; ���[�h
;
APP_MODE_INIT       =   0
APP_MODE_LOAD       =   1
APP_MODE_TITLE      =   2
APP_MODE_GAME       =   3

; ���
;
APP_STATE_NULL      =   0
APP_PHASE_NULL      =   0



; �O���֐��錾
;

    .globl  _AppInitialize
    .globl  _AppUpdate



; �O���ϐ��錾
;

    ; ���[�h
    .globl  _appMode
    
    ; ���
    .globl  _appState
    .globl  _appPhase
    
    ; �n�C�X�R�A
    .globl  _appHiscore
    
    ; ���݂̃X�R�A
    .globl  _appScore
    
    ; �X�R�A�̔{��
    .globl  _appRate
    
    ; �^�C�}
    .globl  _appTimer


