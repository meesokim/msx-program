
#include "fmfmap.h"

//-----------------------------------------------------------------------------
//	�R���X�g���N�^
//-----------------------------------------------------------------------------
CFmfMap::CFmfMap(void) : m_pLayerAddr(NULL)
{}
//-----------------------------------------------------------------------------
//	�f�X�g���N�^
//-----------------------------------------------------------------------------
CFmfMap::~CFmfMap()
{
	Close();
}	
//-----------------------------------------------------------------------------
//	�}�b�v���J���ăf�[�^��ǂݍ���
// �����F	szFilePath	= �}�b�v�t�@�C���̃p�X
// �߂�l:	����I��	= TRUE
//			�G���[		= FALSE
//-----------------------------------------------------------------------------
BOOL CFmfMap::Open(const char *szFilePath)
{
	Close();

	// �t�@�C�����J��
	HANDLE hFile = CreateFile(	szFilePath, GENERIC_READ, FILE_SHARE_READ, NULL,
								OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hFile == INVALID_HANDLE_VALUE)
		return FALSE;

	// �w�b�_����ǂ�
	DWORD dwReadBytes;
	if (!ReadFile(hFile, &m_fmfHeader, sizeof(FMFHEADER), &dwReadBytes, NULL) ||
		dwReadBytes != sizeof(FMFHEADER))
		goto error_return;

	// ���ʎq�̃`�F�b�N
	if (memcmp(&m_fmfHeader.dwIdentifier, "FMF_", 4) != 0)
		goto error_return;

	// �������m��
	m_pLayerAddr = new BYTE[m_fmfHeader.dwSize];
	if (m_pLayerAddr == NULL)
		goto error_return;

	// ���C���[�f�[�^��ǂ�
	if (!ReadFile(hFile, m_pLayerAddr, m_fmfHeader.dwSize, &dwReadBytes, NULL) ||
		dwReadBytes != m_fmfHeader.dwSize)
		goto error_return;
	
	// ����I��
	CloseHandle(hFile);
	return TRUE;

error_return:
	// �G���[�I��
	CloseHandle(hFile);
	Close();
	return FALSE;
}
//-----------------------------------------------------------------------------
// �}�b�v���J����Ă��邩
//-----------------------------------------------------------------------------
BOOL CFmfMap::IsOpen() const
{
	return m_pLayerAddr != NULL;
}
//-----------------------------------------------------------------------------
//	�}�b�v���������J��
//-----------------------------------------------------------------------------
void CFmfMap::Close(void)
{
	if (m_pLayerAddr != NULL)
	{
		delete [] m_pLayerAddr;
		m_pLayerAddr = NULL;
	}
}
//-----------------------------------------------------------------------------
//	�w�背�C���̐擪�A�h���X�𓾂�
//	�����F	���C���ԍ�
//	�߂�l:	����I��	= ���C���f�[�^�̃A�h���X
//			�G���[		= NULL
//	�e���C���f�[�^�͘A�������������̈�ɔz�u����Ă�̂�
//	�w�背�C���f�[�^�̃A�h���X���v�Z�ŋ��߂�B
//-----------------------------------------------------------------------------
void* CFmfMap::GetLayerAddr(BYTE byLayerIndex) const
{
	// �������`�F�b�N�A�͈̓`�F�b�N
	if ((m_pLayerAddr == NULL) || (byLayerIndex >= m_fmfHeader.byLayerCount))
		return NULL;

	BYTE bySize = m_fmfHeader.byBitCount / 8;
	return m_pLayerAddr + m_fmfHeader.dwWidth * m_fmfHeader.dwHeight * bySize * byLayerIndex;
}
//-----------------------------------------------------------------------------
// ���C���ԍ��ƍ��W���w�肵�Ē��ڃf�[�^��Ⴄ
// �����F
// 	byLayerIndex	= ���C���ԍ�
// 	dwX				= X���W�i0�`m_fmfHeader.dwWidth - 1�j
// 	dwY				= Y���W�i0�`m_fmfHeader.dwHeight - 1�j
// �߂�l�F
// 	����I��	= ���W�̒l
//	�G���[		= -1
//-----------------------------------------------------------------------------
int CFmfMap::GetValue(BYTE byLayerIndex, DWORD dwX, DWORD dwY) const
{
	int nIndex = -1;

	// �͈̓`�F�b�N
	if (byLayerIndex >= m_fmfHeader.byLayerCount ||
		dwX >= m_fmfHeader.dwWidth ||
		dwY >= m_fmfHeader.dwHeight)
		return nIndex;

	if (m_fmfHeader.byBitCount == 8)
	{
		// 8bit layer
		BYTE* pLayer = (BYTE*)GetLayerAddr(byLayerIndex);
		nIndex = *(pLayer + dwY * m_fmfHeader.dwWidth + dwX);
	}
	else
	{
		// 16bit layer	
		WORD* pLayer = (WORD*)GetLayerAddr(byLayerIndex);
		nIndex = *(pLayer + dwY * m_fmfHeader.dwWidth + dwX);
	}

	return nIndex;
}

//-----------------------------------------------------------------------------
// ���C���ԍ��ƍ��W���w�肵�ăf�[�^���Z�b�g
//-----------------------------------------------------------------------------
void CFmfMap::SetValue(BYTE byLayerIndex, DWORD dwX, DWORD dwY, int nValue)
{
	// �͈̓`�F�b�N
	if (byLayerIndex >= m_fmfHeader.byLayerCount ||
		dwX >= m_fmfHeader.dwWidth ||
		dwY >= m_fmfHeader.dwHeight)
		return;

	if (m_fmfHeader.byBitCount == 8)
	{
		// 8bit layer
		BYTE* pLayer = (BYTE*)GetLayerAddr(byLayerIndex);
		*(pLayer + dwY * m_fmfHeader.dwWidth + dwX) = (BYTE)nValue;
	}
	else
	{
		// 16bit layer	
		WORD* pLayer = (WORD*)GetLayerAddr(byLayerIndex);
		*(pLayer + dwY * m_fmfHeader.dwWidth + dwX) = (WORD)nValue;
	}
}

//-----------------------------------------------------------------------------
// �}�b�v�̉����𓾂�
//-----------------------------------------------------------------------------
DWORD CFmfMap::GetMapWidth(void) const
{
	return m_fmfHeader.dwWidth;
}
//-----------------------------------------------------------------------------
// �}�b�v�̍����𓾂�
//-----------------------------------------------------------------------------
DWORD CFmfMap::GetMapHeight(void) const
{
	return m_fmfHeader.dwHeight;
}
//-----------------------------------------------------------------------------
// �`�b�v�̉����𓾂�
//-----------------------------------------------------------------------------
BYTE CFmfMap::GetChipWidth(void) const
{
	return m_fmfHeader.byChipWidth;
}
//-----------------------------------------------------------------------------
// �`�b�v�̍����𓾂�
//-----------------------------------------------------------------------------
BYTE CFmfMap::GetChipHeight(void) const
{
	return m_fmfHeader.byChipHeight;
}
//-----------------------------------------------------------------------------
// ���C���[���𓾂�
//-----------------------------------------------------------------------------
BYTE CFmfMap::GetLayerCount(void) const
{
	return m_fmfHeader.byLayerCount;
}
//-----------------------------------------------------------------------------
// ���C���[�f�[�^�̃r�b�g�J�E���g�𓾂�
//-----------------------------------------------------------------------------
BYTE CFmfMap::GetLayerBitCount(void) const
{
	return m_fmfHeader.byBitCount;
}