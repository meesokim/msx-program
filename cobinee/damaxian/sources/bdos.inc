; bdos.inc : MSX-DOS �V�X�e���R�[��
;



; �}�N���̒�`
;

; �V�X�e���R�[���A�h���X
BDOS        =   0x0005

; TPA �A�h���X
TPA         =   0x0006

; �V�X�e���R�[��
INIDOS      =   0x00            ; �V�X�e�����Z�b�g
GETCON      =   0x01            ; �R���\�[������
PUTCON      =   0x02            ; �R���\�[���o��
GETAUX      =   0x03            ; �O������
PUTAUX      =   0x04            ; �O���o��
PUTLPT      =   0x05            ; �v�����^�o��
IODCN       =   0x06            ; ���ڃR���\�[�����o��
GETDCN1     =   0x07            ; ���ڃR���\�[�����͂��̂P
GETDCN2     =   0x08            ; ���ڃR���\�[�����͂��̂Q
PUTSTR      =   0x09            ; ������o��
GETSTR      =   0x0a            ; ���������
CHKCON      =   0x0b            ; �R���\�[���̏�ԃ`�F�b�N
GETVER      =   0x0c            ; �o�[�W�����ԍ��̎擾
RSTDSK      =   0x0d            ; �f�B�X�N���Z�b�g
CHGDRV      =   0x0e            ; �f�t�H���g�E�h���C�u�̕ύX
OPNFCB      =   0x0f            ; �t�@�C���̃I�[�v��
CLSFCB      =   0x10            ; �t�@�C���̃N���[�Y
FNDFCB1     =   0x11            ; �t�@�C���̌������̂P
FNDFCB2     =   0x12            ; �t�@�C���̌������̂Q
DELFCB      =   0x13            ; �t�@�C���̖���
SRDFCB      =   0x14            ; �V�[�P���V�����ȓǂݏo��
SWRFCB      =   0x15            ; �V�[�P���V�����ȏ����o��
CRTFCB      =   0x16            ; �t�@�C���̍쐬
RENFCB      =   0x17            ; �t�@�C�����̕ύX
GETLGV      =   0x18            ; ���O�C���E�x�N�g���̊l��
GETDRV      =   0x19            ; �f�t�H���g�E�h���C�u�̊l��
SETDMA      =   0x1a            ; �]����A�h���X�̐ݒ�
GETDSK      =   0x1b            ; �f�B�X�N���̊l��
RRDFCB      =   0x21            ; �����_���ȓǂݏo��
RWRFCB      =   0x22            ; �����_���ȏ����o��
GETLEN      =   0x23            ; �t�@�C���T�C�Y�̊l��
SETREC      =   0x24            ; �����_�����R�[�h�E�t�B�[���h�̐ݒ�
RWRREC      =   0x26            ; �����_���ȏ������݂��̂Q
RRDREC      =   0x27            ; �����_���ȓǂݏo�����̂Q
FILREC      =   0x28            ; �����_���ȏ������݂��̂R
GETDAT      =   0x2a            ; ���t�̊l��
SETDAT      =   0x2b            ; ���t�̐ݒ�
GETTIM      =   0x2c            ; �����̊l��
SETTIM      =   0x2d            ; �����̐ݒ�
SETVFY      =   0x2e            ; �x���t�@�C�E�t���O�̐ݒ�
ARDSEC      =   0x2f            ; �_���Z�N�^��p�����ǂݏo��
AWRSEC      =   0x30            ; �_���Z�N�^��p������������

