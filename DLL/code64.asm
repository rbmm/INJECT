
WSTRING macro text
  FORC arg, text
  DW '&arg'
  ENDM
  DW 0
endm

.code

UserNormalRoutine proc

DllName$ = 20h
hmod$	=  30h

	; params:
	; rcx -> ImageBase;
	; rdx -> unused
	;  r8 -> unused
	
	ALIGN		2
	nop
	call		@@0
	WSTRING		<{EBB50DDB-F6AA-492d-94E3-1D51B299F627}.DLL>
@@0:
	pop			rdx				; rdx -> LibName
	mov			[rsp + 08h],rcx ; rcx -> ImageBase
	mov			[rsp + 10h],rdi
	mov			[rsp + 18h],rbp
	sub			rsp,48h
	
	mov			rdi,rdx			; rdi -> LibName
	xor			eax,eax
	repne		scasw
	sub			rdi,rdx
	mov			DllName$[rsp + 2],di
	dec			edi
	dec			edi
	mov			DllName$[rsp + 0],di
	mov			DllName$[rsp + 8],rdx
	
	mov         rax,gs:[60h]	; rax = ProcessEnvironmentBlock
	mov         rax,[rax+18h]	; rax = Ldr
	mov         rax,[rax+30h]	; rax = InInitializationOrderModuleList.Flink 
	mov         rcx,[rax+10h]	; rax = DllBase (ntdll.dll)
	mov			rbp,rcx			; rbp -> ntdll.dll
	call		@@1
	db			'LdrLoadDll',0
@@1:
	pop			rdx
	call		getprocaddr
	test		rax,rax
	jz			@@2
	
	lea			r9,hmod$[rsp]
	lea			r8,DllName$[rsp]
	xor			rcx,rcx
	mov			rdx,rcx
	call		rax				; LdrLoadDll
	
@@2:
	call		@@3
	db			'NtUnmapViewOfSection',0
@@3:
	pop			rdx
	mov			rcx,rbp
	call		getprocaddr
	
	add			rsp,48h
	mov			rdi,[rsp + 10h]
	mov			rbp,[rsp + 18h]

	test		rax,rax
	jnz			@@4
	ret
@@4:

	mov			rdx,[rsp + 8h]	; ImageBase
	xor			rcx,rcx
	dec			rcx				; NtCurrentProcess()
	jmp			rax				; NtUnmapViewOfSection
	
UserNormalRoutine endp

getprocaddr proc private

	push		r12
	push		rbp
	push		rsi 
	push		rdi 
	push		rbx 

	mov         rbx,rcx ; rbx -> PIMAGE_DOS_HEADER
	mov			rdi,rdx ; name
	xor			al,al
	repne		scasb
	sub			rdi,rdx
	mov			rbp,rdi ; rbp - name length
	
	movsxd      rax,dword ptr [rbx+3Ch] ; e_lfanew
	mov         eax,[rbx+rax+88h] ; pinth->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress
	add         rax,rbx ; rax -> PIMAGE_EXPORT_DIRECTORY
	
	mov         r9d,[rax+18h] ; NumberOfNames
	test        r9d,r9d
	je          @@5 
	
	mov         r12d,[rax+1Ch] ; AddressOfFunctions
	mov         r11d,[rax+20h] ; AddressOfNames
	mov         r10d,[rax+24h] ; AddressOfNameOrdinals
	add         r10,rbx 
	add         r11,rbx 
	add         r12,rbx 

	xor         r8d,r8d 
@@1:
	lea         eax,[r8d+r9d] 
	shr         eax,1 ; eax - index - [r8d, eax) : [eax, r9d)
	
	mov         edi,[r11+rax*4] ; AddressOfNames[eax]
	add         rdi,rbx ; rdi -> export name
	
	mov			rcx,rbp ; name length
	mov			rsi,rdx ; name
	
	repe		cmpsb
	
	jnz			@@2
	
	movzx       eax,word ptr [r10+rax*2] ; eax = AddressOfNameOrdinals[eax]
	mov         eax,dword ptr [r12+rax*4] ; eax = AddressOfFunctions[eax]
	add         rax,rbx
	jmp         @@6
	
@@2:
	js			@@3

	lea         r8d,[eax+1]
	jmp         @@4
@@3:
	mov         r9d,eax 
@@4:
	cmp         r8d,r9d ; [r8d, r9d) 
	jb          @@1
@@5:
	xor         eax,eax
@@6:

	pop			rbx 
	pop			rdi 
	pop			rsi 
	pop			rbp
	pop			r12
	ret
	
getprocaddr endp


end