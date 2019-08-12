.686p

WSTRING macro text
  FORC arg, text
  DW '&arg'
  ENDM
  DW 0
endm

_TEXT SEGMENT

_UserNormalRoutine@12 proc

DllName$ = 0h
hmod$	=  8h
	
	; params:
	; [esp + 4] -> unused
	; [esp + 8] -> NtCurrentProcess()
	; [esp + 12] -> ImageBase

	ALIGN		2
	nop
	call		@@0
	WSTRING		<{EBB50DDB-F6AA-492d-94E3-1D51B299F627}.DLL>
@@0:
	pop			edx				; rdx -> LibName
	
	push		ebp
	push		edi
	sub			esp,0ch
	
	mov			ecx,esp
	mov			edi,edx			 
	xor			eax,eax
	repne		scasw
	sub			edi,edx
	mov			DllName$[esp + 2],di
	dec			edi
	dec			edi
	mov			DllName$[esp + 0],di
	mov			DllName$[esp + 4],edx
	
	mov         eax,fs:[30h]	; eax = ProcessEnvironmentBlock
	mov         eax,[eax+0ch]	; eax = Ldr
	mov         eax,[eax+1ch]	; eax = InInitializationOrderModuleList.Flink 
	mov         ecx,[eax+08h]	; eax = DllBase (ntdll.dll)
	mov			ebp,ecx			; ebp -> ntdll.dll
	call		@@1
	db			'LdrLoadDll',0
@@1:
	pop			edx
	call		getprocaddr
	test		eax,eax
	jz			@@2
	
	lea			ecx,hmod$[esp]
	lea			edx,DllName$[esp]
	push		ecx
	push		edx
	xor			ecx,ecx
	push		ecx
	push		ecx
	call		eax				; LdrLoadDll
	
@@2:
	call		@@3
	db			'NtUnmapViewOfSection',0
@@3:
	pop			edx
	mov			ecx,ebp
	call		getprocaddr
	
	add			esp,0ch
	pop			edi
	pop			ebp

	test		eax,eax
	jnz			@@4
	ret			12
@@4:

	pop			ecx				; ret eip
	mov			[esp],ecx
	jmp			eax				; NtUnmapViewOfSection
	
_UserNormalRoutine@12 endp

getprocaddr proc private

AddressOfFunctions$ = 16
AddressOfNames$ = 12
AddressOfNameOrdinals$ = 8
b$ = 4
a$ = 0

	push		ebp
	push		esi 
	push		edi 
	push		ebx
	
	sub			esp,20

	mov         ebx,ecx ; ebx -> PIMAGE_DOS_HEADER
	mov			edi,edx ; name
	xor			al,al
	repne		scasb
	sub			edi,edx
	mov			ebp,edi ; ebp - name length
	
	mov		    eax,dword ptr [ebx+3Ch] ; e_lfanew
	mov         eax,[ebx+eax+78h] ; pinth->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress
	add         eax,ebx ; eax -> PIMAGE_EXPORT_DIRECTORY
	
	mov         ecx,[eax+18h] ; NumberOfNames
	jecxz		@@5
	
	mov			b$[esp],ecx
	xor			ecx,ecx
	mov			a$[esp],ecx
	
	mov         ecx,[eax+1Ch] ; AddressOfFunctions
	add			ecx,ebx
	mov			AddressOfFunctions$[esp],ecx
	
	mov         ecx,[eax+20h] ; AddressOfNames
	add			ecx,ebx
	mov			AddressOfNames$[esp],ecx
	
	mov         ecx,[eax+24h] ; AddressOfNameOrdinals
	add			ecx,ebx
	mov			AddressOfNameOrdinals$[esp],ecx

@@1:
	mov			eax,a$[esp]
	add			eax,b$[esp]
	shr         eax,1 ; eax - index - [a, eax) : [eax, b)
	
	mov			ecx,AddressOfNames$[esp]
	mov         edi,[ecx+eax*4] ; AddressOfNames[eax]
	add         edi,ebx ; edi -> export name
	
	mov			ecx,ebp ; name length
	mov			esi,edx ; name
	
	repe		cmpsb
	
	jnz			@@2
	
	mov			ecx,AddressOfNameOrdinals$[esp]
	movzx       eax,word ptr [ecx+eax*2] ; eax = AddressOfNameOrdinals[eax]
	mov			ecx,AddressOfFunctions$[esp]
	mov         eax,dword ptr [ecx+eax*4] ; eax = AddressOfFunctions[eax]
	add         eax,ebx
	jmp         @@6
	
@@2:
	js			@@3

	inc			eax
	mov			a$[esp],eax
	jmp         @@4
@@3:
	mov         b$[esp],eax 
@@4:
	mov			eax,a$[esp]
	cmp         eax,b$[esp] ; [a, b) 
	jb          @@1
@@5:
	xor         eax,eax
@@6:

	add			esp,20
	
	pop			ebx 
	pop			edi 
	pop			esi 
	pop			ebp
	ret
	
getprocaddr endp

_TEXT ends

end