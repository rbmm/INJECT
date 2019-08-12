#include "StdAfx.h"

_NT_BEGIN
extern "C"
{
	extern const UINT_PTR __security_cookie = 0;
}
#include "log.h"

void OnDllLoad(PVOID hmod, PCUNICODE_STRING DllName);

VOID CALLBACK LdrDllNotification(
								 _In_     LDR_DLL_NOTIFICATION_REASON NotificationReason,
								 _In_     PCLDR_DLL_NOTIFICATION_DATA NotificationData,
								 _In_opt_ PVOID                       /*Context*/
								 )
{
	DbgPrint("%x %p %wZ\r\n", NotificationReason, NotificationData->DllBase, NotificationData->FullDllName);
}


LONG
WINAPI
UnhandledExceptionFilter(::PEXCEPTION_POINTERS ExceptionInfo)
{
	::PEXCEPTION_RECORD ExceptionRecord = ExceptionInfo->ExceptionRecord;
	DWORD ExceptionCode = ExceptionRecord->ExceptionCode;
	PULONG_PTR ExceptionInformation = ExceptionRecord->ExceptionInformation;

	MEMORY_BASIC_INFORMATION mbi;
	PVOID ppv[16];
	static LONG sn = 64;

	switch(ExceptionCode)
	{
	case STATUS_ACCESS_VIOLATION:
		if (0 <= ZwQueryVirtualMemory(NtCurrentProcess(), (PVOID)ExceptionInformation[1], MemoryBasicInformation, &mbi, sizeof(mbi), 0))
		{
			DbgPrint("AV: %p/%p s=%x t=%x p=%x\r\n", mbi.AllocationBase, mbi.BaseAddress, mbi.State, mbi.Type, mbi.Protect);
		}
		if (ULONG n = RtlCaptureStackBackTrace(0, RTL_NUMBER_OF(ppv), ppv, 0))
		{
			do 
			{
				DbgPrint("%p\r\n", ppv[--n]);
			} while (n);
		}
		break;
	case DBG_PRINTEXCEPTION_C:
		if (0 <= InterlockedDecrement(&sn))
		{
			if (DWORD len = (DWORD)ExceptionInformation[0])
			{
				Log::write( (PVOID)ExceptionInformation[1], len );
				DbgPrint("\r\n");
			}
		}
	case DBG_PRINTEXCEPTION_WIDE_C:
		return EXCEPTION_CONTINUE_EXECUTION;
	}

	static UNICODE_STRING empty;
	PCUNICODE_STRING pus = &empty;
	_LDR_DATA_TABLE_ENTRY* ldte;
	PVOID hmod = 0;
	if (0 <= LdrFindEntryForAddress(ExceptionRecord->ExceptionAddress, ldte))
	{
		hmod = ldte->DllBase;
		pus = &ldte->BaseDllName;
	}
	WCHAR sz[512], *c;
	c = sz + swprintf(sz, L"%wZ(%p):%08x at %p [", pus, hmod, ExceptionCode, ExceptionRecord->ExceptionAddress);
	if (DWORD NumberParameters = ExceptionRecord->NumberParameters)
	{
		do 
		{
			c += swprintf(c, L" %p", (PVOID)*ExceptionInformation++);
		} while (--NumberParameters);
	}

	c[0]= ']', c[1] = 0;

	DbgPrint("%S\r\n", sz);

	Log::Flush();

	return EXCEPTION_CONTINUE_SEARCH;
}

BOOLEAN WINAPI DllMain( HMODULE /*hmod*/, DWORD ul_reason_for_call, PVOID )
{
	static PVOID gCookie, gVex;

	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
		Log::Init();
		DbgPrint("DLL_PROCESS_ATTACH\r\n");

		gVex = RtlAddVectoredExceptionHandler(TRUE, UnhandledExceptionFilter);
		LdrRegisterDllNotification(0, LdrDllNotification, 0, &gCookie);
		break;

	case DLL_PROCESS_DETACH:
		if (gCookie) LdrUnregisterDllNotification(gCookie);

		if (gVex)
		{
			RtlRemoveVectoredExceptionHandler(gVex);
		}
		DbgPrint("DLL_PROCESS_DETACH\r\n");
		Log::Close();
		break;
	}

	return TRUE;
}

_NT_END
