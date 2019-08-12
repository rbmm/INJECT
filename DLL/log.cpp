#include "StdAfx.h"

_NT_BEGIN

#include "log.h"

PCWSTR GetVarString(PCUNICODE_STRING pus)
{
	_PEB* peb = RtlGetCurrentPeb();

	PCWSTR lpsz = (PCWSTR)peb->ProcessParameters->Environment;

	while (*lpsz)
	{
		UNICODE_STRING us;
		RtlInitUnicodeString(&us, lpsz);

		if (RtlPrefixUnicodeString(pus, &us, TRUE))
		{
			return (PCWSTR)RtlOffsetToPointer(lpsz, pus->Length);
		}

		lpsz += wcslen(lpsz) + 1;
	}

	return 0;
}

namespace Log {

HANDLE g_hLog;

NTSTATUS Flush()
{
	IO_STATUS_BLOCK iosb;
	return ZwFlushBuffersFile(g_hLog, &iosb);
}

NTSTATUS Init()
{
	STATIC_UNICODE_STRING(LOCALAPPDATA, "TMP=");

	if (PCWSTR path = GetVarString(&LOCALAPPDATA))
	{
		PUNICODE_STRING ImagePathName = &RtlGetCurrentPeb()->ProcessParameters->ImagePathName;
		ULONG hash;
		RtlHashUnicodeString(ImagePathName, TRUE, HASH_STRING_ALGORITHM_DEFAULT, &hash);
#ifndef _WIN64
		hash--;
#endif
		STATIC_UNICODE_STRING(sep, "\\");
		USHORT pos;
		if (0 <= RtlFindCharInUnicodeString(RTL_FIND_CHAR_IN_UNICODE_STRING_START_AT_END, ImagePathName, &sep, &pos))
		{
			pos += sizeof(WCHAR);
			ImagePathName->Buffer = (PWSTR)RtlOffsetToPointer(ImagePathName->Buffer, pos);
			ImagePathName->Length -= pos;
			ImagePathName->MaximumLength -= pos;
		}
		
		size_t cb = wcslen(path) * sizeof (WCHAR) + ImagePathName->Length + 128;
		
		PWSTR lpsz = (PWSTR)alloca(cb);

		swprintf_s(lpsz,cb / sizeof(WCHAR), L"\\GLOBAL??\\%s\\%x.%x.%wZ.log",
			path, (ULONG)(ULONG_PTR)((_TEB*)NtCurrentTeb())->ClientId.UniqueProcess, hash, ImagePathName);

		UNICODE_STRING ObjectName;
		RtlInitUnicodeString(&ObjectName, lpsz);
		OBJECT_ATTRIBUTES oa = { sizeof(oa), 0, &ObjectName };
		IO_STATUS_BLOCK iosb;

		return NtCreateFile(&g_hLog, FILE_APPEND_DATA | SYNCHRONIZE, 
			&oa, &iosb, 0, 0, FILE_SHARE_READ, FILE_OVERWRITE_IF, 
			FILE_SYNCHRONOUS_IO_NONALERT, 0, 0);
	}

	return STATUS_UNSUCCESSFUL;
}

void printf(PCSTR format, ...)
{
	if (g_hLog)
	{
		va_list args;
		va_start(args, format);
		char buf[0x800];
		int len = _vsnprintf_s(buf, RTL_NUMBER_OF(buf), _TRUNCATE, format, args);
		if (0 < len)
		{
			IO_STATUS_BLOCK iosb;
			NtWriteFile(g_hLog, 0, 0, 0, &iosb, buf, len * sizeof(CHAR), 0, 0);
		}
	}
}

void write(LPCVOID data, DWORD cb)
{
	IO_STATUS_BLOCK iosb;
	g_hLog ? NtWriteFile(g_hLog, 0, 0, 0, &iosb, (void*)data, cb, 0, 0) : STATUS_INVALID_HANDLE;
}

NTSTATUS Close()
{
	return g_hLog ? NtClose(g_hLog) : STATUS_INVALID_HANDLE;
}

}
_NT_END