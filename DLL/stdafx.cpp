#include "stdafx.h"

void* RtlGetProcessHeap()
{
	return NT::RtlGetCurrentPeb()->ProcessHeap;
}

void* __cdecl operator new[](size_t ByteSize)
{
	return NT::RtlAllocateHeap(RtlGetProcessHeap(), 0, ByteSize);
}

void* __cdecl operator new(size_t ByteSize)
{
	return NT::RtlAllocateHeap(RtlGetProcessHeap(), 0, ByteSize);
}

void __cdecl operator delete(void* Buffer)
{
	NT::RtlFreeHeap(RtlGetProcessHeap(), 0, Buffer);
}

void __cdecl operator delete[](void* Buffer)
{
	NT::RtlFreeHeap(RtlGetProcessHeap(), 0, Buffer);
}
