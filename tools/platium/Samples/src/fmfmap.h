//-----------------------------------------------------------------------------
// Platinum���o�͂���*.fmf�t�@�C����ǂݏo���N���X
// �ǐ��d���ɏ����Ă���̂Ō������d���������ꍇ�͏��������Ďg�p���Ă��������B
//-----------------------------------------------------------------------------
#ifndef __CLASS_FMFMAP_H__
#define __CLASS_FMFMAP_H__
#pragma once

#include <windows.h>

// FMF�t�@�C���w�b�_ (20 bytes)
typedef struct tag_FMFHeader
{
	DWORD	dwIdentifier;	// �t�@�C�����ʎq 'FMF_'
	DWORD	dwSize;			// �w�b�_���������f�[�^�T�C�Y
	DWORD	dwWidth;		// �}�b�v�̉���
	DWORD	dwHeight;		// �}�b�v�̍���
	BYTE	byChipWidth;	// �}�b�v�`�b�v1�̕�(pixel)
	BYTE	byChipHeight;	// �}�b�v�`�b�v�P�̍���(pixel)
	BYTE	byLayerCount;	// ���C���[�̐�
	BYTE	byBitCount;		// ���C���f�[�^�̃r�b�g�J�E���g
}FMFHEADER;

class CFmfMap
{
public:
	// �\�z/����
	CFmfMap(void);
	~CFmfMap();

	// �}�b�v���J���ăf�[�^��ǂݍ���
	BOOL Open(const char *szFilePath);

	// �}�b�v���J����Ă��邩
	BOOL IsOpen() const;

	// �}�b�v���������J��
	void Close(void);
		
	// �w�背�C���[�̐擪�A�h���X�𓾂�
	void* GetLayerAddr(BYTE byLayerIndex) const;
	
	// ���C���ԍ��ƍ��W���w�肵�Ē��ڃf�[�^��Ⴄ
	int GetValue(BYTE byLayerIndex, DWORD dwX, DWORD dwY) const;

	// ���C���ԍ��ƍ��W���w�肵�ăf�[�^���Z�b�g
	void SetValue(BYTE byLayerIndex, DWORD dwX, DWORD dwY, int nValue);

	// �w�b�_�̏��𓾂�
	DWORD GetMapWidth(void) const;
	DWORD GetMapHeight(void) const;
	BYTE GetChipWidth(void) const;
	BYTE GetChipHeight(void) const;
	BYTE GetLayerCount(void) const;
	BYTE GetLayerBitCount(void) const;
protected:
	// FMF�t�@�C���w�b�_�\����
	FMFHEADER	m_fmfHeader;
	// ���C���[�f�[�^�ւ̃|�C���^
	BYTE* 		m_pLayerAddr;
};

/*	�T���v��
int Hoge(const char *filePath)
{
	CFmfMap map;
	BYTE* pLayer;

	if (!map.Open(filePath))
	{
		// �}�b�v���J���Ȃ��B
		return 1;
	}

	// 0�ԁi��ԉ��̃��C���[�j�̃A�h���X��Ⴄ
	pLayer = (BYTE*)map.GetLayerAddr(0)
	if (lpLayer == NULL)
	{
		map.Close();
		return 1;
	}

	DWORD width = map.GetMapWidth();
	DWORD height = map.GetMapHeight();
	DWORD cWidth = map.GetChipWidth();
	DWORD cHeight = map.GetChipHeight();
	int srcX, srcY;
	BYTE index;	
	
	// �}�b�v�̕`��
	for (DWORD y = 0; y < height; y++)
	{
		for (DWORD x = 0; x < width ; x++)
		{
			index = *(pLayer + y * width + x);
			// �܂���
			index = map.GetValue(0, x, y);
			
			// index�ɂ̓}�b�v���W(x, y)�̃}�b�v�f�[�^�������Ă�̂�
			// �p�[�c�摜(srcHDC)����value�Ɍ�������`���Z�o���ĕ`�揈�����s���B
			// �}�b�v��8bit�̏ꍇ�p�[�c�̃A���C�������g��16�A16bit�Ȃ�256�B
			srcX = (index % 16) * cWidth;
			srcY = (index / 16) * cHeight;
			BitBlt(	dstHDC, x * cWidth, y * cHeight, cWidth, cHeight,
					srcHDC, srcX, srcY, SRCCOPY);
		}
	}

	// ���W(15,10)�̃f�[�^�����o���ꍇ
	value = *(pLayer + 10 * width + 15);
	
	// ����
	map.Close();
	
	return 0;
}
*/

#endif