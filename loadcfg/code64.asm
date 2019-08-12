.code

_guard_check_icall_nop proc
	ret
_guard_check_icall_nop endp

_guard_dispatch_icall_nop proc
	jmp rax
_guard_dispatch_icall_nop endp

end