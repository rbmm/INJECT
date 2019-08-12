#pragma once

namespace Log {
	NTSTATUS Init();
	NTSTATUS Close();
	void write(LPCVOID data, DWORD cb);
	void printf(PCSTR format, ...);
	NTSTATUS Flush();
};

#define DbgPrint Log::printf