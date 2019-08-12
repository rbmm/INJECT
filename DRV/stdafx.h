// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//
#pragma once
#define _NTDRIVER_
#define NOWINBASEINTERLOCK
#define _NTOS_
#define _KERNEL_MODE
#include "../inc/StdAfx.h"

void* __cdecl operator new(size_t size, NT::POOL_TYPE PoolType = NT::PagedPool);

void* __cdecl operator new[](size_t size, NT::POOL_TYPE PoolType = NT::PagedPool);

void __cdecl operator delete(PVOID pv);

void __cdecl operator delete(PVOID pv, size_t);

void __cdecl operator delete[](PVOID pv);
