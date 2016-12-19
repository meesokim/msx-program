// Platinum Plug-In(ppi) definition file

#ifndef __PLATINUM_PLUGIN_H__
#define __PLATINUM_PLUGIN_H__
#pragma once

#include <windows.h>

// Plugin����
#define PPITYPE_IMPORT			0x01	// �v���O�C����Import�֐����T�|�[�g���܂�
#define PPITYPE_EXPORT			0x02	// �v���O�C����Export�֐����T�|�[�g���܂�
#define PPITYPE_FILEFORMAT		0x04	// �v���O�C���̓t�@�C���t�H�[�}�b�g�Ƃ��ċ@�\���܂�

// �v���O���X�R�[���o�b�N���Ԃ��߂�l
#define PPICALLBACK_ABORT		0	// ���[�U�����~��I�������i���₩�ɏ����𒆒f���ĉ������j
#define PPICALLBACK_OK			1	// OK.�i�����𑱍s���ĉ������j

// �Ăяo�����֕ԋp����߂�l
#define PPIRET_OK				0	// ����I��
#define PPIRET_UNSUPPORTED		1	// ���̃t�@�C���̓T�|�[�g���Ă��܂���
#define PPIRET_NOTIMPLEMENTED	2	// �������̊֐��ł�
#define PPIRET_INVALIDPARAMS	3	// �������s���ł�
#define PPIRET_INVALIDFILE		4	// �t�@�C�����j�����Ă��܂�
#define PPIRET_FILEERR			5	// �t�@�C���G���[���������܂���
#define PPIRET_OUTOFMEMORY		6	// ���������s�����Ă��܂�
#define PPIRET_ABORT			7	// �R�[���o�b�N�֐�����PPICALLBACK_ABORT���󂯎�����̂ŏ����𒆎~���܂���
#define PPIRET_INTERNALERR		8	// �����G���[���������܂���

#define SAFE_GLOBAL_FREE(p) if (p != NULL) { ::GlobalFree(p); p = NULL; }

// �v���O���X�o�[���������邽�߂̃R�[���o�b�N�֐�
// nNow		���݂̏����P��
// nMax		�����P�ʂ̍ő�l
// lpszMsg	�������e��ʒm���邽�߂̃��b�Z�[�W�i���b�Z�[�W�������ꍇ��NULL��n���܂��j
typedef BYTE (__stdcall* PPI_PROGRESS_CALLBACK)(int nNow, int nMax, LPCTSTR lpszMsg);

#pragma pack(push, 1)
struct PlatinumPluginInfo
{
	char szPluginName[128];		// �v���O�C���̖��O
	char szFileFilter[128];		// �T�|�[�g����t�@�C���̃t�B���^������
	DWORD dwFlags;				// �t���O(PPITYPE_IMPORT and(or) PPITYPE_EXPORT or PPITYPE_FILEFORMAT)
};

// Platinum���Ǘ�����f�[�^�\��
// Export���ɂ͂��̃f�[�^�\����C�ӂ̌`�ŏo�͂��ĉ�����
// Import���ɂ͕K�v�ɉ����ă������[�����蓖�ăf�[�^��ǂݍ���ŉ�����
struct PlatinumData
{
	// �K�{�f�[�^
	struct Important
	{
		struct Header
		{
			DWORD dwMapWidth;		// �}�b�v�̉���
			DWORD dwMapHeight;		// �}�b�v�̍���
			DWORD dwChipWidth;		// �`�b�v(�p�[�c)�̉���
			DWORD dwChipHeight;		// �`�b�v(�p�[�c)�̍���
			BYTE byLayerCount;		// ���C����(1�ȏ�)
			BYTE byBitCount;		// 1�`�b�v�̃f�[�^��(8 or 16)
			BYTE byRelativePath;	// 0 = �p�X���t�@�C�����݂̂Ŋi�[, 1 = �p�X�𑊑΃p�X�Ŋi�[
			BYTE reserved;			// �\��
		};
		struct Layer
		{
			LPTSTR lpszLayerName;		// ���C�����B�C�ӂ̖��O�ɂ���ꍇ��NULL���w��\(��1���Q�Ɓj
			LPTSTR lpszLayerChipName;	// �摜�̃p�X�B���蓖�ĂȂ��ꍇ��NULL���w��\(��1���Q�Ɓj
			BYTE	byVisible;			// �����
			WORD*	pData;				// �}�b�v�z��(��1���Q�Ɓj
		};
		Header	header;
		Layer*	pLayers;	// ���C���z��(��1���Q�Ɓj
	} important;

	// �I�v�V�����f�[�^
	struct Optional
	{
		struct Colorkey
		{
			BYTE byUse;		// ���ߏ���(0 = ���� / 1 = �L��)
			DWORD dwColor;	// ���ߐF(0x00BBGGRR)
			BYTE reserved;	// �\��
		};
		struct InvisiblePatrs
		{
			BYTE byUse;			// �����p�[�c(0 = ���� / 1 = �L��)
			WORD wInvisible;	// �����p�[�c�ԍ�
			BYTE reserved;		// �\��
		};
		struct EditorEnv
		{
			BYTE byShowGrid;		// �O���b�h(0 = ��\�� / 1 = �\��)
			BYTE byShowData;		// �p�[�c�ԍ�(0 = ��\�� / 1 = �\��)
			BYTE byShowIndex;		// �g�p���܂���
			BYTE byShowCursorGrid;	// �J�[�\���O���b�h(0 = ��\�� / 1 = �\��)
			BYTE byShowMarker;		// �}�[�J�[(0 = ��\�� / 1 = �\��)
			BYTE byShowFog;			// �t�H�O���[�h(0 = ���� / 1 = �L��)
		};
		struct GridColor
		{
			DWORD dwGridColor;	// �O���b�h�̐F(0x00BBGGRR)
			DWORD dwCGridColor;	// �J�[�\���O���b�h�̐F(0x00BBGGRR)
		};
		struct HiddenData
		{
			DWORD dwSize;	// �f�[�^�̃T�C�Y(dwSize == 0 �̏ꍇ pData == NULL �ł�)
			void* pData;	// �f�[�^(��1���Q��)
		};

		EditorEnv		env;
		Colorkey		colorkey;
		InvisiblePatrs	invisible;
		GridColor		gridColor;
		WORD			wZoomRatio;
		LPTSTR			lpszComment;	// �}�b�v�R�����g(��1���Q��)
		HiddenData		hidden;			// ���[�U�f�[�^(��2���Q��)
	} optional;
};
#pragma pack(pop)

	// ��1
	// Import���ɂ�GlobalAlloc(GPTR, size)�ɂă������[���蓖�Ă��s���Ă��������B
	// �������[�̊J���͌Ăяo�����ōs���Ă���̂Ŋ֐����甲����O�ɊJ�����Ȃ��ł��������B
	// �G���[�����������ꍇ�̓v���O�C�����œK�؂Ƀ������[���J�����Ă��������B

	// ��2
	// �t�@�C�������R�Ƀf�[�^���i�[���鎖���o����̈�ł��B
	// Import���ɂ��̗̈�ɃT�C�Y�ƃf�[�^��ݒ肷�鎖�ɂ��Platinum���ɕێ�����A
	// Export���ɍēx���̃f�[�^���v���O�C���Ɉ����n����̂Ńt�@�C���ɋL�^����Ȃǂ��ĉ������B
	// ����͎�Ƀv���O�C�����ŕ\�������_�C�A���O�Ȃǂ�����͂��ꂽ�f�[�^��ۑ�����ꍇ�Ɏg�p����܂��B

#endif //__PLATINUM_PLUGIN_H__