
#pragma once

#include "..\\plugin.h"

#define EXPORT extern "C" __declspec(dllexport)

EXPORT void	GetPlatinumPluginInfo(PlatinumPluginInfo* pPluginInfo);
EXPORT int	Export(HWND hWndParent, LPCTSTR lpszFileName, const PlatinumData* pData, PPI_PROGRESS_CALLBACK fnCallback);
EXPORT int	Import(HWND hWndParent, LPCTSTR lpszFileName, PlatinumData* pData, PPI_PROGRESS_CALLBACK fnCallback);
EXPORT int	IsSupported(LPCTSTR lpszFileName);
