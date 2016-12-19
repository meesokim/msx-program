// Platinum Plug-In(ppi) definition file

#ifndef __PLATINUM_PLUGIN_H__
#define __PLATINUM_PLUGIN_H__
#pragma once

#include <windows.h>

// Plugin特性
#define PPITYPE_IMPORT			0x01	// プラグインはImport関数をサポートします
#define PPITYPE_EXPORT			0x02	// プラグインはExport関数をサポートします
#define PPITYPE_FILEFORMAT		0x04	// プラグインはファイルフォーマットとして機能します

// プログレスコールバックが返す戻り値
#define PPICALLBACK_ABORT		0	// ユーザが中止を選択した（速やかに処理を中断して下さい）
#define PPICALLBACK_OK			1	// OK.（処理を続行して下さい）

// 呼び出し元へ返却する戻り値
#define PPIRET_OK				0	// 正常終了
#define PPIRET_UNSUPPORTED		1	// このファイルはサポートしていません
#define PPIRET_NOTIMPLEMENTED	2	// 未実装の関数です
#define PPIRET_INVALIDPARAMS	3	// 引数が不正です
#define PPIRET_INVALIDFILE		4	// ファイルが破損しています
#define PPIRET_FILEERR			5	// ファイルエラーが発生しました
#define PPIRET_OUTOFMEMORY		6	// メモリが不足しています
#define PPIRET_ABORT			7	// コールバック関数からPPICALLBACK_ABORTを受け取ったので処理を中止しました
#define PPIRET_INTERNALERR		8	// 内部エラーが発生しました

#define SAFE_GLOBAL_FREE(p) if (p != NULL) { ::GlobalFree(p); p = NULL; }

// プログレスバーを処理するためのコールバック関数
// nNow		現在の処理単位
// nMax		処理単位の最大値
// lpszMsg	処理内容を通知するためのメッセージ（メッセージが無い場合はNULLを渡せます）
typedef BYTE (__stdcall* PPI_PROGRESS_CALLBACK)(int nNow, int nMax, LPCTSTR lpszMsg);

#pragma pack(push, 1)
struct PlatinumPluginInfo
{
	char szPluginName[128];		// プラグインの名前
	char szFileFilter[128];		// サポートするファイルのフィルタ文字列
	DWORD dwFlags;				// フラグ(PPITYPE_IMPORT and(or) PPITYPE_EXPORT or PPITYPE_FILEFORMAT)
};

// Platinumが管理するデータ構造
// Export時にはこのデータ構造を任意の形で出力して下さい
// Import時には必要に応じてメモリーを割り当てデータを読み込んで下さい
struct PlatinumData
{
	// 必須データ
	struct Important
	{
		struct Header
		{
			DWORD dwMapWidth;		// マップの横幅
			DWORD dwMapHeight;		// マップの高さ
			DWORD dwChipWidth;		// チップ(パーツ)の横幅
			DWORD dwChipHeight;		// チップ(パーツ)の高さ
			BYTE byLayerCount;		// レイヤ数(1以上)
			BYTE byBitCount;		// 1チップのデータ量(8 or 16)
			BYTE byRelativePath;	// 0 = パスをファイル名のみで格納, 1 = パスを相対パスで格納
			BYTE reserved;			// 予約
		};
		struct Layer
		{
			LPTSTR lpszLayerName;		// レイヤ名。任意の名前にする場合はNULLを指定可能(※1を参照）
			LPTSTR lpszLayerChipName;	// 画像のパス。割り当てない場合はNULLを指定可能(※1を参照）
			BYTE	byVisible;			// 可視状態
			WORD*	pData;				// マップ配列(※1を参照）
		};
		Header	header;
		Layer*	pLayers;	// レイヤ配列(※1を参照）
	} important;

	// オプションデータ
	struct Optional
	{
		struct Colorkey
		{
			BYTE byUse;		// 透過処理(0 = 無効 / 1 = 有効)
			DWORD dwColor;	// 透過色(0x00BBGGRR)
			BYTE reserved;	// 予約
		};
		struct InvisiblePatrs
		{
			BYTE byUse;			// 透明パーツ(0 = 無効 / 1 = 有効)
			WORD wInvisible;	// 透明パーツ番号
			BYTE reserved;		// 予約
		};
		struct EditorEnv
		{
			BYTE byShowGrid;		// グリッド(0 = 非表示 / 1 = 表示)
			BYTE byShowData;		// パーツ番号(0 = 非表示 / 1 = 表示)
			BYTE byShowIndex;		// 使用しません
			BYTE byShowCursorGrid;	// カーソルグリッド(0 = 非表示 / 1 = 表示)
			BYTE byShowMarker;		// マーカー(0 = 非表示 / 1 = 表示)
			BYTE byShowFog;			// フォグモード(0 = 無効 / 1 = 有効)
		};
		struct GridColor
		{
			DWORD dwGridColor;	// グリッドの色(0x00BBGGRR)
			DWORD dwCGridColor;	// カーソルグリッドの色(0x00BBGGRR)
		};
		struct HiddenData
		{
			DWORD dwSize;	// データのサイズ(dwSize == 0 の場合 pData == NULL です)
			void* pData;	// データ(※1を参照)
		};

		EditorEnv		env;
		Colorkey		colorkey;
		InvisiblePatrs	invisible;
		GridColor		gridColor;
		WORD			wZoomRatio;
		LPTSTR			lpszComment;	// マップコメント(※1を参照)
		HiddenData		hidden;			// ユーザデータ(※2を参照)
	} optional;
};
#pragma pack(pop)

	// ※1
	// Import時にはGlobalAlloc(GPTR, size)にてメモリー割り当てを行ってください。
	// メモリーの開放は呼び出し側で行っているので関数から抜ける前に開放しないでください。
	// エラーが発生した場合はプラグイン側で適切にメモリーを開放してください。

	// ※2
	// ファイルが自由にデータを格納する事が出来る領域です。
	// Import時にこの領域にサイズとデータを設定する事によりPlatinum内に保持され、
	// Export時に再度このデータがプラグインに引き渡さるのでファイルに記録するなどして下さい。
	// これは主にプラグイン側で表示したダイアログなどから入力されたデータを保存する場合に使用されます。

#endif //__PLATINUM_PLUGIN_H__