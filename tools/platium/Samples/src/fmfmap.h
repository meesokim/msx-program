//-----------------------------------------------------------------------------
// Platinumが出力する*.fmfファイルを読み出すクラス
// 可読性重視に書いてあるので効率を重視したい場合は書き換えて使用してください。
//-----------------------------------------------------------------------------
#ifndef __CLASS_FMFMAP_H__
#define __CLASS_FMFMAP_H__
#pragma once

#include <windows.h>

// FMFファイルヘッダ (20 bytes)
typedef struct tag_FMFHeader
{
	DWORD	dwIdentifier;	// ファイル識別子 'FMF_'
	DWORD	dwSize;			// ヘッダを除いたデータサイズ
	DWORD	dwWidth;		// マップの横幅
	DWORD	dwHeight;		// マップの高さ
	BYTE	byChipWidth;	// マップチップ1つの幅(pixel)
	BYTE	byChipHeight;	// マップチップ１つの高さ(pixel)
	BYTE	byLayerCount;	// レイヤーの数
	BYTE	byBitCount;		// レイヤデータのビットカウント
}FMFHEADER;

class CFmfMap
{
public:
	// 構築/消滅
	CFmfMap(void);
	~CFmfMap();

	// マップを開いてデータを読み込む
	BOOL Open(const char *szFilePath);

	// マップが開かれているか
	BOOL IsOpen() const;

	// マップメモリを開放
	void Close(void);
		
	// 指定レイヤーの先頭アドレスを得る
	void* GetLayerAddr(BYTE byLayerIndex) const;
	
	// レイヤ番号と座標を指定して直接データを貰う
	int GetValue(BYTE byLayerIndex, DWORD dwX, DWORD dwY) const;

	// レイヤ番号と座標を指定してデータをセット
	void SetValue(BYTE byLayerIndex, DWORD dwX, DWORD dwY, int nValue);

	// ヘッダの情報を得る
	DWORD GetMapWidth(void) const;
	DWORD GetMapHeight(void) const;
	BYTE GetChipWidth(void) const;
	BYTE GetChipHeight(void) const;
	BYTE GetLayerCount(void) const;
	BYTE GetLayerBitCount(void) const;
protected:
	// FMFファイルヘッダ構造体
	FMFHEADER	m_fmfHeader;
	// レイヤーデータへのポインタ
	BYTE* 		m_pLayerAddr;
};

/*	サンプル
int Hoge(const char *filePath)
{
	CFmfMap map;
	BYTE* pLayer;

	if (!map.Open(filePath))
	{
		// マップが開けない。
		return 1;
	}

	// 0番（一番下のレイヤー）のアドレスを貰う
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
	
	// マップの描画
	for (DWORD y = 0; y < height; y++)
	{
		for (DWORD x = 0; x < width ; x++)
		{
			index = *(pLayer + y * width + x);
			// または
			index = map.GetValue(0, x, y);
			
			// indexにはマップ座標(x, y)のマップデータが入ってるので
			// パーツ画像(srcHDC)からvalueに見合う矩形を算出して描画処理を行う。
			// マップが8bitの場合パーツのアラインメントは16、16bitなら256。
			srcX = (index % 16) * cWidth;
			srcY = (index / 16) * cHeight;
			BitBlt(	dstHDC, x * cWidth, y * cHeight, cWidth, cHeight,
					srcHDC, srcX, srcY, SRCCOPY);
		}
	}

	// 座標(15,10)のデータを取り出す場合
	value = *(pLayer + 10 * width + 15);
	
	// 閉じる
	map.Close();
	
	return 0;
}
*/

#endif