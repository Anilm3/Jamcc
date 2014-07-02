extern printf
extern getchar

section .bss

section .data
	str0	db "fibonacci(",0
	str1	db ") : ",0
	str2	db "%s%d%s%d%c",0

section .text

	global main

fun0:
	enter 0,0

	;IF

	;IF : condition
	mov eax, dword [ebp + 8]
	mov ebx, 2
	cmp eax, ebx
	setl al
	movzx eax, al
	cmp eax, 0
	jz if00
	;End IF : codition

	;IF : content
	mov eax, dword [ebp + 8]
	leave
	ret 4
	;End IF : content
	jmp endif0
if00:

	;ELSE : content
	mov eax, dword [ebp + 8]
	mov ebx, 1
	sub eax, ebx
	push eax
	call fun0
	mov eax, eax
	push eax
	mov ebx, dword [ebp + 8]
	mov ecx, 2
	sub ebx, ecx
	push ebx
	call fun0
	mov ebx, eax
	pop eax
	add eax, ebx
	leave
	ret 4
	;End ELSE : content
endif0:
	;End IF

	leave
	ret 4

main:
	enter 8,0

	;For loop

	;For : initialization
	mov eax, 0
	mov dword [esp + 0], eax
	mov eax, dword [esp + 0]
	;End For : initialization
l0:

	;For : condition
	mov eax, dword [esp + 0]
	mov ebx, 10
	cmp eax, ebx
	setl al
	movzx eax, al
	cmp eax, 0
	jz lr0
	;End For : codition

	;For : content

	;Expression
	mov eax, dword [esp + 0]
	push eax
	call fun0
	mov eax, eax
	mov dword [esp + 4], eax
	mov eax, dword [esp + 4]
	;End Expression

	;Print routine
	sub esp, 24
	mov eax, dword str0
	mov dword [esp + 4], eax
	mov eax, dword [esp + 24]
	mov dword [esp + 8], eax
	mov eax, dword str1
	mov dword [esp + 12], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 16], eax
	mov eax, dword 10
	mov dword [esp + 20], eax
	mov eax, dword str2
	mov dword [esp], eax
	call printf
	add esp, 24
	;End Print routine
	;End For : content

	;For : step
ls0:
	mov eax, dword [esp + 0]
	mov ebx, 1
	add eax, ebx
	mov dword [esp + 0], eax
	mov eax, dword [esp + 0]
	;End For : step
	jmp l0
lr0:
	;End For loop

	leave
	ret 0

