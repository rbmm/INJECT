extern g_DriverObject:QWORD
extern __imp_ObfDereferenceObject:QWORD

extern ?_RundownRoutine@NT@@YAXPEAU_KAPC@1@@Z : PROC ; void __cdecl NT::_RundownRoutine(struct NT::_KAPC *)
extern ?_NormalRoutine@NT@@YAXPEAU_KAPC@1@PEAXPEAUDLL_INFORMATION@1@@Z : PROC ; void __cdecl NT::_NormalRoutine(struct NT::_KAPC *,void *,struct NT::DLL_INFORMATION *)
extern ?_KernelRoutine@NT@@YAXPEAU_KAPC@1@PEAP6AXPEAX11@ZPEAPEAX33@Z : PROC ; void __cdecl NT::_KernelRoutine(struct NT::_KAPC *,void (__cdecl **)(void *,void *,void *),void **,void **,void **)

_TEXT segment

?RundownRoutine@NT@@YAXPEAU_KAPC@1@@Z proc
	sub rsp,40
	call ?_RundownRoutine@NT@@YAXPEAU_KAPC@1@@Z
	add rsp,40
	mov rcx,g_DriverObject
	jmp __imp_ObfDereferenceObject
?RundownRoutine@NT@@YAXPEAU_KAPC@1@@Z endp

?KernelRoutine@NT@@YAXPEAU_KAPC@1@PEAP6AXPEAX11@ZPEAPEAX33@Z proc
	mov rax,[rsp + 40]
	mov [rsp + 24],rax
	mov rax,[rsp]
	mov [rsp + 32],rax
	push rax
	call ?_KernelRoutine@NT@@YAXPEAU_KAPC@1@PEAP6AXPEAX11@ZPEAPEAX33@Z
	pop rax
	mov rax,[rsp + 32]
	mov [rsp],rax
	mov rcx,g_DriverObject
	jmp __imp_ObfDereferenceObject
?KernelRoutine@NT@@YAXPEAU_KAPC@1@PEAP6AXPEAX11@ZPEAPEAX33@Z endp

?NormalRoutine@NT@@YAXPEAX00@Z proc
	sub rsp,40
	call ?_NormalRoutine@NT@@YAXPEAU_KAPC@1@PEAXPEAUDLL_INFORMATION@1@@Z
	add rsp,40
	mov rcx,g_DriverObject
	jmp __imp_ObfDereferenceObject
?NormalRoutine@NT@@YAXPEAX00@Z endp

_TEXT ends

end