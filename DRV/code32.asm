.686p

extern __imp_@ObfDereferenceObject@4:DWORD
extern _g_DriverObject:DWORD

extern ?_RundownRoutine@NT@@YGXPAU_KAPC@1@@Z : PROC ; void __stdcall NT::_RundownRoutine(struct NT::_KAPC *)
extern ?_NormalRoutine@NT@@YGXPAU_KAPC@1@PAXPAUDLL_INFORMATION@1@@Z : PROC ; void __stdcall NT::_NormalRoutine(struct NT::_KAPC *,void *,struct NT::DLL_INFORMATION *)
extern ?_KernelRoutine@NT@@YGXPAU_KAPC@1@PAP6GXPAX11@ZPAPAX33@Z : PROC ; void __stdcall NT::_KernelRoutine(struct NT::_KAPC *,void (__stdcall **)(void *,void *,void *),void **,void **,void **)

_TEXT SEGMENT

?RundownRoutine@NT@@YGXPAU_KAPC@1@@Z proc
		mov eax,[esp]
		xchg [esp+1*4],eax
		mov [esp],eax
		call ?_RundownRoutine@NT@@YGXPAU_KAPC@1@@Z
		mov ecx,_g_DriverObject
		jmp __imp_@ObfDereferenceObject@4
?RundownRoutine@NT@@YGXPAU_KAPC@1@@Z endp

?KernelRoutine@NT@@YGXPAU_KAPC@1@PAP6GXPAX11@ZPAPAX33@Z proc
		mov eax,[esp]
		xchg [esp+5*4],eax
		xchg [esp+4*4],eax
		xchg [esp+3*4],eax
		xchg [esp+2*4],eax
		xchg [esp+1*4],eax
		mov [esp],eax
		call ?_KernelRoutine@NT@@YGXPAU_KAPC@1@PAP6GXPAX11@ZPAPAX33@Z
		mov ecx,_g_DriverObject
		jmp __imp_@ObfDereferenceObject@4
?KernelRoutine@NT@@YGXPAU_KAPC@1@PAP6GXPAX11@ZPAPAX33@Z endp

?NormalRoutine@NT@@YGXPAX00@Z proc
		mov eax,[esp]
		xchg [esp+3*4],eax
		xchg [esp+2*4],eax
		xchg [esp+1*4],eax
		mov [esp],eax
		call ?_NormalRoutine@NT@@YGXPAU_KAPC@1@PAXPAUDLL_INFORMATION@1@@Z
		mov ecx,_g_DriverObject
		jmp __imp_@ObfDereferenceObject@4
?NormalRoutine@NT@@YGXPAX00@Z endp

_TEXT ENDS

END