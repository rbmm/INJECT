
#include "stdafx.h"

void* __cdecl operator new(size_t size, NT::POOL_TYPE PoolType)
{
	return NT::ExAllocatePool(PoolType, size);
}

void* __cdecl operator new[](size_t size, NT::POOL_TYPE PoolType)
{
	return NT::ExAllocatePool(PoolType, size);
}

void __cdecl operator delete(PVOID pv)
{
	NT::ExFreePool(pv);
}

void __cdecl operator delete(PVOID pv, size_t)
{
	NT::ExFreePool(pv);
}

void __cdecl operator delete[](PVOID pv)
{
	NT::ExFreePool(pv);
}
