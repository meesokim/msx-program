
#include "fmf.h"

#define FMF_TAG 0x5F464D46

typedef struct tag_FMFHeader {
	DWORD	dwIdentifier;	// ファイル識別子 'FMF_'
	DWORD	dwSize;			// ヘッダを除いたデータサイズ
	DWORD	dwWidth;		// マップの横幅
	DWORD	dwHeight;		// マップの高さ
	BYTE	byChipWidth;	// マップチップ1つの幅(pixel)
	BYTE	byChipHeight;	// マップチップ１つの高さ(pixel)
	BYTE	byLayerCount;	// レイヤーの数
	BYTE	byBitCount;		// レイヤデータのビットカウント
} FMFHEADER;

//-----------------------------------------------------------------------------
// Pluginの情報を設定する
//
// 引数
// pPluginInfo	: プラグインの情報を設定する構造体のポインタ
//
// 戻り値
// なし
//-----------------------------------------------------------------------------
EXPORT void GetPlatinumPluginInfo(PlatinumPluginInfo* pPluginInfo)
{
	// アバウトボックスに表示されるプラグインの名前
	strncpy(pPluginInfo->szPluginName, "Fixed Mapdata File Import/Export Plugin 2005 (c) HyperDevice Software", 128);

	// ファイル選択ダイアログボックスの「ファイルの種類」にリストされるフィルタ
	// 拡張子を複数指定する場合は;で区切ってください　Fixed Mapdata File (*.fmf;*.fmm)|*.fmf;*.fmm　など
	// 1つのプラグインで複数のフィルタは指定出来ません
	strncpy(pPluginInfo->szFileFilter, "Fixed Mapdata File (*.fmf)|*.fmf", 128);

	// プラグインの特性を表すフラグ
	// この場合ファイルメニューの「読み込み」「書き出し」から開かれるファイル選択ダイアログで
	// このプラグインが選択可能になる
	pPluginInfo->dwFlags = PPITYPE_IMPORT | PPITYPE_EXPORT;
}

//-----------------------------------------------------------------------------
// 読み込み可能なファイルなのかを調べてその結果を返す
// 個人で使うようなプラグインの場合は拡張子のチェックだけでも良い
// ファイルの内容を確認しない場合は最低限、拡張子のチェックだけはして下さい
//
// 引数
// lpszFileName		: 選択されたファイルのフルパス
//
// 戻り値
// 読み込み可能		: PPIRET_OK
// 読み込み不可能	: PPIRET_UNSUPPORTED
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
// ファイルへ書き出し
//
// 引数
// hWndParent	: Platinumメインウィンドウのウィンドウハンドル。
// lpszFilePath	: 選択されたファイルのフルパス。
// pData		: Platinumが管理するデータ構造体のポインタ。このデータをファイルに書き込みます。
// fnCallback	: プログレスバーを更新するためのコールバック関数。
// 				  fnCallback(現在のステップ, 総ステップ数, メッセージ);
//
// 戻り値
// 正常終了		: PPIRET_OK
// 処理の中断	: PPIRET_ABORT
// その他エラー	: PPIRET_～～
//-----------------------------------------------------------------------------
EXPORT int Export(HWND hWndParent, LPCTSTR lpszFilePath, const PlatinumData* pData, PPI_PROGRESS_CALLBACK fnCallback)
{
	if (hWndParent == NULL || lpszFilePath == NULL || pData == NULL || fnCallback == NULL)
		return PPIRET_INVALIDPARAMS;

	DWORD dwLayerSize = pData->important.header.dwMapWidth *
						pData->important.header.dwMapHeight *
						pData->important.header.byBitCount / 8;

	// FMFファイルのヘッダを用意
	FMFHEADER fmfHeader;
	fmfHeader.dwIdentifier	= FMF_TAG;
	fmfHeader.dwSize		= dwLayerSize * pData->important.header.byLayerCount;
	fmfHeader.dwWidth		= pData->important.header.dwMapWidth;
	fmfHeader.dwHeight		= pData->important.header.dwMapHeight;
	fmfHeader.byChipWidth	= (BYTE)pData->important.header.dwChipWidth;
	fmfHeader.byChipHeight	= (BYTE)pData->important.header.dwChipHeight;
	fmfHeader.byLayerCount	= pData->important.header.byLayerCount;
	fmfHeader.byBitCount	= pData->important.header.byBitCount;

	// ファイル作成
	HANDLE hFile;
	hFile = CreateFile(	lpszFilePath, GENERIC_WRITE, FILE_SHARE_READ, NULL,
						CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hFile == INVALID_HANDLE_VALUE)
	{
		CloseHandle(hFile);
		return PPIRET_FILEERR;
	}

	// ヘッダの書き込み
	DWORD dwWriteBytes;
	if (!WriteFile(hFile, &fmfHeader, sizeof(FMFHEADER), &dwWriteBytes, NULL) ||
		dwWriteBytes != sizeof(FMFHEADER))
	{
		CloseHandle(hFile);
		return PPIRET_FILEERR;
	}

	// レイヤー処理
	DWORD dwWriteSize = fmfHeader.byBitCount / 8;
	for (BYTE i = 0; i < fmfHeader.byLayerCount; i++)
	{
		// データの書き込み
		for (DWORD k = 0; k < fmfHeader.dwWidth * fmfHeader.dwHeight; k++)
		{
			if (!WriteFile(hFile, &pData->important.pLayers[i].pData[k], dwWriteSize, &dwWriteBytes, NULL) || 
				dwWriteBytes != dwWriteSize)
			{
				CloseHandle(hFile);
				return PPIRET_FILEERR;
			}
		}

		// プログレスバーの更新
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
// ファイルの読み込み
//
// 引数
// hWndParent	: Platinumメインウィンドウのウィンドウハンドル。
// lpszFilePath	: 選択されたファイルのフルパス。
// pData		: Platinumが管理するデータ構造体のポインタ。このデータをファイルに書き込みます。
// fnCallback	: プログレスバーを更新するためのコールバック関数。
// 				  fnCallback(現在のステップ, 総ステップ数, メッセージ);
//
// 戻り値
// 正常終了		: PPIRET_OK
// 処理の中断	: PPIRET_ABORT
// その他エラー	: PPIRET_～～
//
// 備考
// pData->important.pLayers は各レイヤーを格納するPlatinumData::Layer型の配列へのポインタです。
// GlobalAlloc(GPTR...)を使用して全てのレイヤーが収まるサイズの配列を確保します。
// pData->important.pLayers[n]->pData はWORD型の配列のポインタです。
// GlobalAlloc(GPTR...)を使用してデータが収まるサイズの1次元配列を確保してください。
// 各レイヤのデータ配列のサイズは次のように計算します。
// nSize =	pData->important.header.dwMapWidth *
// 			pData->important.header.dwMapHeight *
// 			sizeof(WORD);
//-----------------------------------------------------------------------------
EXPORT int Import(HWND hWndParent, LPCTSTR lpszFilePath, PlatinumData* pData, PPI_PROGRESS_CALLBACK fnCallback)
{
	if (hWndParent == NULL || lpszFilePath == NULL || pData == NULL || fnCallback == NULL)
		return PPIRET_INVALIDPARAMS;

	// ファイルを開く
	HANDLE hFile;
	hFile = CreateFile(	lpszFilePath, GENERIC_READ, FILE_SHARE_READ, NULL,
						OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hFile == INVALID_HANDLE_VALUE)
	{
		CloseHandle(hFile);
		return PPIRET_FILEERR;
	}

	// ヘッダー情報を読み込んで識別子を確認する
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

	// 古い形式のFMFファイル(8bitパーツ)ではbyBitCountにあたる領域は使われておらず、
	// Dirty bit(0xff)が格納されているのでこれに対応しておく
	if (fmfHeader.byBitCount == 255)
		fmfHeader.byBitCount = 8;

	// レイヤー配列を確保
	pData->important.pLayers = (PlatinumData::Important::Layer*)GlobalAlloc(GPTR, sizeof(PlatinumData::Important::Layer) * fmfHeader.byLayerCount);
	if (pData->important.pLayers == NULL)
	{
		CloseHandle(hFile);
		return PPIRET_OUTOFMEMORY;
	}

	// 各レイヤーの処理
	for (BYTE i = 0; i < fmfHeader.byLayerCount; i++)
	{
		// データ配列を確保
		// ファイル形式に関係なくPlatinum内部のデータ配列はWORD配列なので
		// sizeof(WORD)単位でメモリを確保します。
		DWORD dwArraySize = fmfHeader.dwWidth * fmfHeader.dwHeight * sizeof(WORD);
		pData->important.pLayers[i].pData = (WORD*)GlobalAlloc(GPTR, dwArraySize);
		if (pData->important.pLayers[i].pData == NULL)
		{
			CloseHandle(hFile);
			ABORT(PPIRET_OUTOFMEMORY);
		}

		// データを読む
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

		// プログレスバーを更新
		if (fnCallback(i, fmfHeader.byLayerCount, "reading...") == PPICALLBACK_ABORT)
		{
			CloseHandle(hFile);
			ABORT(PPIRET_ABORT);
		}
	}

	// ヘッダ情報を書き込む
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






