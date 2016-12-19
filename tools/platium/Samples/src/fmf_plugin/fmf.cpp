
#include "fmf.h"

#define FMF_TAG 0x5F464D46

typedef struct tag_FMFHeader {
	DWORD	dwIdentifier;	// �t�@�C�����ʎq 'FMF_'
	DWORD	dwSize;			// �w�b�_���������f�[�^�T�C�Y
	DWORD	dwWidth;		// �}�b�v�̉���
	DWORD	dwHeight;		// �}�b�v�̍���
	BYTE	byChipWidth;	// �}�b�v�`�b�v1�̕�(pixel)
	BYTE	byChipHeight;	// �}�b�v�`�b�v�P�̍���(pixel)
	BYTE	byLayerCount;	// ���C���[�̐�
	BYTE	byBitCount;		// ���C���f�[�^�̃r�b�g�J�E���g
} FMFHEADER;

//-----------------------------------------------------------------------------
// Plugin�̏���ݒ肷��
//
// ����
// pPluginInfo	: �v���O�C���̏���ݒ肷��\���̂̃|�C���^
//
// �߂�l
// �Ȃ�
//-----------------------------------------------------------------------------
EXPORT void GetPlatinumPluginInfo(PlatinumPluginInfo* pPluginInfo)
{
	// �A�o�E�g�{�b�N�X�ɕ\�������v���O�C���̖��O
	strncpy(pPluginInfo->szPluginName, "Fixed Mapdata File Import/Export Plugin 2005 (c) HyperDevice Software", 128);

	// �t�@�C���I���_�C�A���O�{�b�N�X�́u�t�@�C���̎�ށv�Ƀ��X�g�����t�B���^
	// �g���q�𕡐��w�肷��ꍇ��;�ŋ�؂��Ă��������@Fixed Mapdata File (*.fmf;*.fmm)|*.fmf;*.fmm�@�Ȃ�
	// 1�̃v���O�C���ŕ����̃t�B���^�͎w��o���܂���
	strncpy(pPluginInfo->szFileFilter, "Fixed Mapdata File (*.fmf)|*.fmf", 128);

	// �v���O�C���̓�����\���t���O
	// ���̏ꍇ�t�@�C�����j���[�́u�ǂݍ��݁v�u�����o���v����J�����t�@�C���I���_�C�A���O��
	// ���̃v���O�C�����I���\�ɂȂ�
	pPluginInfo->dwFlags = PPITYPE_IMPORT | PPITYPE_EXPORT;
}

//-----------------------------------------------------------------------------
// �ǂݍ��݉\�ȃt�@�C���Ȃ̂��𒲂ׂĂ��̌��ʂ�Ԃ�
// �l�Ŏg���悤�ȃv���O�C���̏ꍇ�͊g���q�̃`�F�b�N�����ł��ǂ�
// �t�@�C���̓��e���m�F���Ȃ��ꍇ�͍Œ���A�g���q�̃`�F�b�N�����͂��ĉ�����
//
// ����
// lpszFileName		: �I�����ꂽ�t�@�C���̃t���p�X
//
// �߂�l
// �ǂݍ��݉\		: PPIRET_OK
// �ǂݍ��ݕs�\	: PPIRET_UNSUPPORTED
//-----------------------------------------------------------------------------
EXPORT int IsSupported(LPCTSTR lpszFilePath)
{
	HANDLE hFile;
	hFile = CreateFile(	lpszFilePath, GENERIC_READ, FILE_SHARE_READ, NULL,
						OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hFile == INVALID_HANDLE_VALUE)
	{
		CloseHandle(hFile);
		return PPIRET_UNSUPPORTED;
	}
	
	DWORD dwIdentifier;
	DWORD dwWriteBytes;
	if (!ReadFile(hFile, &dwIdentifier, sizeof(DWORD), &dwWriteBytes, NULL) ||
		dwWriteBytes != sizeof(DWORD))
	{
		CloseHandle(hFile);
		return PPIRET_UNSUPPORTED;
	}

	CloseHandle(hFile);

	return dwIdentifier == FMF_TAG ? PPIRET_OK : PPIRET_UNSUPPORTED;
}

//-----------------------------------------------------------------------------
// �t�@�C���֏����o��
//
// ����
// hWndParent	: Platinum���C���E�B���h�E�̃E�B���h�E�n���h���B
// lpszFilePath	: �I�����ꂽ�t�@�C���̃t���p�X�B
// pData		: Platinum���Ǘ�����f�[�^�\���̂̃|�C���^�B���̃f�[�^���t�@�C���ɏ������݂܂��B
// fnCallback	: �v���O���X�o�[���X�V���邽�߂̃R�[���o�b�N�֐��B
// 				  fnCallback(���݂̃X�e�b�v, ���X�e�b�v��, ���b�Z�[�W);
//
// �߂�l
// ����I��		: PPIRET_OK
// �����̒��f	: PPIRET_ABORT
// ���̑��G���[	: PPIRET_�`�`
//-----------------------------------------------------------------------------
EXPORT int Export(HWND hWndParent, LPCTSTR lpszFilePath, const PlatinumData* pData, PPI_PROGRESS_CALLBACK fnCallback)
{
	if (hWndParent == NULL || lpszFilePath == NULL || pData == NULL || fnCallback == NULL)
		return PPIRET_INVALIDPARAMS;

	DWORD dwLayerSize = pData->important.header.dwMapWidth *
						pData->important.header.dwMapHeight *
						pData->important.header.byBitCount / 8;

	// FMF�t�@�C���̃w�b�_��p��
	FMFHEADER fmfHeader;
	fmfHeader.dwIdentifier	= FMF_TAG;
	fmfHeader.dwSize		= dwLayerSize * pData->important.header.byLayerCount;
	fmfHeader.dwWidth		= pData->important.header.dwMapWidth;
	fmfHeader.dwHeight		= pData->important.header.dwMapHeight;
	fmfHeader.byChipWidth	= (BYTE)pData->important.header.dwChipWidth;
	fmfHeader.byChipHeight	= (BYTE)pData->important.header.dwChipHeight;
	fmfHeader.byLayerCount	= pData->important.header.byLayerCount;
	fmfHeader.byBitCount	= pData->important.header.byBitCount;

	// �t�@�C���쐬
	HANDLE hFile;
	hFile = CreateFile(	lpszFilePath, GENERIC_WRITE, FILE_SHARE_READ, NULL,
						CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hFile == INVALID_HANDLE_VALUE)
	{
		CloseHandle(hFile);
		return PPIRET_FILEERR;
	}

	// �w�b�_�̏�������
	DWORD dwWriteBytes;
	if (!WriteFile(hFile, &fmfHeader, sizeof(FMFHEADER), &dwWriteBytes, NULL) ||
		dwWriteBytes != sizeof(FMFHEADER))
	{
		CloseHandle(hFile);
		return PPIRET_FILEERR;
	}

	// ���C���[����
	DWORD dwWriteSize = fmfHeader.byBitCount / 8;
	for (BYTE i = 0; i < fmfHeader.byLayerCount; i++)
	{
		// �f�[�^�̏�������
		for (DWORD k = 0; k < fmfHeader.dwWidth * fmfHeader.dwHeight; k++)
		{
			if (!WriteFile(hFile, &pData->important.pLayers[i].pData[k], dwWriteSize, &dwWriteBytes, NULL) || 
				dwWriteBytes != dwWriteSize)
			{
				CloseHandle(hFile);
				return PPIRET_FILEERR;
			}
		}

		// �v���O���X�o�[�̍X�V
		if (fnCallback(i, fmfHeader.byLayerCount, "writing...") == PPICALLBACK_ABORT)
		{
			CloseHandle(hFile);
			return PPIRET_ABORT;
		}
	}

	CloseHandle(hFile);
	return PPIRET_OK;
}

#define ABORT(ret) \
{ \
	for (int i = 0; i < pData->important.header.byLayerCount; i++) \
	{ \
		SAFE_GLOBAL_FREE(pData->important.pLayers[i].lpszLayerName); \
		SAFE_GLOBAL_FREE(pData->important.pLayers[i].lpszLayerChipName); \
		SAFE_GLOBAL_FREE(pData->important.pLayers[i].pData); \
	} \
	SAFE_GLOBAL_FREE(pData->important.pLayers); \
	SAFE_GLOBAL_FREE(pData->optional.lpszComment); \
	SAFE_GLOBAL_FREE(pData->optional.hidden.pData); \
	return ret; \
}

//-----------------------------------------------------------------------------
// �t�@�C���̓ǂݍ���
//
// ����
// hWndParent	: Platinum���C���E�B���h�E�̃E�B���h�E�n���h���B
// lpszFilePath	: �I�����ꂽ�t�@�C���̃t���p�X�B
// pData		: Platinum���Ǘ�����f�[�^�\���̂̃|�C���^�B���̃f�[�^���t�@�C���ɏ������݂܂��B
// fnCallback	: �v���O���X�o�[���X�V���邽�߂̃R�[���o�b�N�֐��B
// 				  fnCallback(���݂̃X�e�b�v, ���X�e�b�v��, ���b�Z�[�W);
//
// �߂�l
// ����I��		: PPIRET_OK
// �����̒��f	: PPIRET_ABORT
// ���̑��G���[	: PPIRET_�`�`
//
// ���l
// pData->important.pLayers �͊e���C���[���i�[����PlatinumData::Layer�^�̔z��ւ̃|�C���^�ł��B
// GlobalAlloc(GPTR...)���g�p���đS�Ẵ��C���[�����܂�T�C�Y�̔z����m�ۂ��܂��B
// pData->important.pLayers[n]->pData ��WORD�^�̔z��̃|�C���^�ł��B
// GlobalAlloc(GPTR...)���g�p���ăf�[�^�����܂�T�C�Y��1�����z����m�ۂ��Ă��������B
// �e���C���̃f�[�^�z��̃T�C�Y�͎��̂悤�Ɍv�Z���܂��B
// nSize =	pData->important.header.dwMapWidth *
// 			pData->important.header.dwMapHeight *
// 			sizeof(WORD);
//-----------------------------------------------------------------------------
EXPORT int Import(HWND hWndParent, LPCTSTR lpszFilePath, PlatinumData* pData, PPI_PROGRESS_CALLBACK fnCallback)
{
	if (hWndParent == NULL || lpszFilePath == NULL || pData == NULL || fnCallback == NULL)
		return PPIRET_INVALIDPARAMS;

	// �t�@�C�����J��
	HANDLE hFile;
	hFile = CreateFile(	lpszFilePath, GENERIC_READ, FILE_SHARE_READ, NULL,
						OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hFile == INVALID_HANDLE_VALUE)
	{
		CloseHandle(hFile);
		return PPIRET_FILEERR;
	}

	// �w�b�_�[����ǂݍ���Ŏ��ʎq���m�F����
	DWORD dwReadBytes;
	FMFHEADER fmfHeader;
	if (!ReadFile(hFile, &fmfHeader, sizeof(FMFHEADER), &dwReadBytes, NULL) ||
		dwReadBytes != sizeof(FMFHEADER))
	{
		CloseHandle(hFile);
		return PPIRET_INVALIDFILE;
	}
	if (memcmp(&fmfHeader.dwIdentifier, "FMF_", sizeof(DWORD)) != 0)
	{
		CloseHandle(hFile);
		return PPIRET_UNSUPPORTED;
	}

	// �Â��`����FMF�t�@�C��(8bit�p�[�c)�ł�byBitCount�ɂ�����̈�͎g���Ă��炸�A
	// Dirty bit(0xff)���i�[����Ă���̂ł���ɑΉ����Ă���
	if (fmfHeader.byBitCount == 255)
		fmfHeader.byBitCount = 8;

	// ���C���[�z����m��
	pData->important.pLayers = (PlatinumData::Important::Layer*)GlobalAlloc(GPTR, sizeof(PlatinumData::Important::Layer) * fmfHeader.byLayerCount);
	if (pData->important.pLayers == NULL)
	{
		CloseHandle(hFile);
		return PPIRET_OUTOFMEMORY;
	}

	// �e���C���[�̏���
	for (BYTE i = 0; i < fmfHeader.byLayerCount; i++)
	{
		// �f�[�^�z����m��
		// �t�@�C���`���Ɋ֌W�Ȃ�Platinum�����̃f�[�^�z���WORD�z��Ȃ̂�
		// sizeof(WORD)�P�ʂŃ��������m�ۂ��܂��B
		DWORD dwArraySize = fmfHeader.dwWidth * fmfHeader.dwHeight * sizeof(WORD);
		pData->important.pLayers[i].pData = (WORD*)GlobalAlloc(GPTR, dwArraySize);
		if (pData->important.pLayers[i].pData == NULL)
		{
			CloseHandle(hFile);
			ABORT(PPIRET_OUTOFMEMORY);
		}

		// �f�[�^��ǂ�
		DWORD dwReadSize = fmfHeader.byBitCount / 8;
		for (DWORD k = 0; k < fmfHeader.dwWidth * fmfHeader.dwHeight; k++)
		{
			if (!ReadFile(hFile, &pData->important.pLayers[i].pData[k], dwReadSize, &dwReadBytes, NULL) ||
				dwReadBytes != dwReadSize)
			{
				CloseHandle(hFile);
				ABORT(PPIRET_INVALIDFILE);
			}
		}
		pData->important.pLayers[i].byVisible = 1;

		// �v���O���X�o�[���X�V
		if (fnCallback(i, fmfHeader.byLayerCount, "reading...") == PPICALLBACK_ABORT)
		{
			CloseHandle(hFile);
			ABORT(PPIRET_ABORT);
		}
	}

	// �w�b�_������������
	pData->important.header.dwMapWidth		= fmfHeader.dwWidth;
	pData->important.header.dwMapHeight		= fmfHeader.dwHeight;
	pData->important.header.dwChipWidth		= fmfHeader.byChipWidth;
	pData->important.header.dwChipHeight	= fmfHeader.byChipHeight;
	pData->important.header.byBitCount		= fmfHeader.byBitCount;
	pData->important.header.byLayerCount	= fmfHeader.byLayerCount;
	pData->important.header.byRelativePath	= 0;
	pData->important.header.reserved		= 0;

	CloseHandle(hFile);
	return PPIRET_OK;
}






