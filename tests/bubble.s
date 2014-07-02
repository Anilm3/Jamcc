extern printf
extern getchar

section .bss

section .data
	str0	db "Solucion: ",0
	str1	db "%s",0
	str2	db " ",0
	str3	db "%d%s",0
	str4	db "",10,"",0
	str5	db "%s",0

section .text

	global main

main:
	enter 104,0
	mov dword [esp + 80], 20
	mov dword [esp + 76], 20
	mov dword [esp + 72], 90
	mov dword [esp + 68], 44
	mov dword [esp + 64], 3
	mov dword [esp + 60], 9
	mov dword [esp + 56], 66
	mov dword [esp + 52], 0
	mov dword [esp + 48], 13
	mov dword [esp + 44], 10
	mov dword [esp + 40], 77
	mov dword [esp + 36], 81
	mov dword [esp + 32], 99
	mov dword [esp + 28], 19
	mov dword [esp + 24], 7
	mov dword [esp + 20], 11
	mov dword [esp + 16], 23
	mov dword [esp + 12], 34
	mov dword [esp + 8], 12
	mov dword [esp + 4], 2
	mov dword [esp + 0], 8

	;For loop

	;For : initialization
	mov eax, dword [esp + 80]
	mov ebx, 1
	sub eax, ebx
	mov dword [esp + 84], eax
	mov eax, dword [esp + 84]
	;End For : initialization
l0:

	;For : condition
	mov eax, dword [esp + 84]
	mov ebx, 0
	cmp eax, ebx
	setg al
	movzx eax, al
	cmp eax, 0
	jz lr0
	;End For : codition

	;For : content

	;Expression
	mov eax, 0
	mov dword [esp + 96], eax
	mov eax, dword [esp + 96]
	;End Expression

	;For loop

	;For : initialization
	mov eax, 0
	mov dword [esp + 88], eax
	mov eax, dword [esp + 88]
	;End For : initialization
l1:

	;For : condition
	mov eax, dword [esp + 88]
	mov ebx, dword [esp + 84]
	cmp eax, ebx
	setl al
	movzx eax, al
	cmp eax, 0
	jz lr1
	;End For : codition

	;For : content

	;Expression
	mov eax, dword [esp + 88]
	mov ebx, 1
	add eax, ebx
	mov dword [esp + 100], eax
	mov eax, dword [esp + 100]
	;End Expression

	;IF

	;IF : condition
	mov eax, dword [esp + 88]
	sal eax, 2
	mov eax, dword [esp + 0 + eax]
	mov ebx, dword [esp + 100]
	sal ebx, 2
	mov ebx, dword [esp + 0 + ebx]
	cmp eax, ebx
	setg al
	movzx eax, al
	cmp eax, 0
	jz endif0
	;End IF : codition

	;IF : content

	;Expression
	mov eax, dword [esp + 88]
	sal eax, 2
	mov eax, dword [esp + 0 + eax]
	mov dword [esp + 92], eax
	mov eax, dword [esp + 92]
	;End Expression

	;Expression
	mov eax, dword [esp + 100]
	sal eax, 2
	mov eax, dword [esp + 0 + eax]
	mov ebx, dword [esp + 88]
	sal ebx, 2
	mov dword [esp + 0 + ebx], eax
	mov eax, dword [esp + 88]
	sal eax, 2
	mov eax, dword [esp + 0 + eax]
	;End Expression

	;Expression
	mov eax, dword [esp + 92]
	mov ebx, dword [esp + 100]
	sal ebx, 2
	mov dword [esp + 0 + ebx], eax
	mov eax, dword [esp + 100]
	sal eax, 2
	mov eax, dword [esp + 0 + eax]
	;End Expression

	;Expression
	mov eax, 1
	mov dword [esp + 96], eax
	mov eax, dword [esp + 96]
	;End Expression
	;End IF : content
endif0:
	;End IF
	;End For : content

	;For : step
ls1:
	mov eax, dword [esp + 88]
	mov ebx, 1
	add eax, ebx
	mov dword [esp + 88], eax
	mov eax, dword [esp + 88]
	;End For : step
	jmp l1
lr1:
	;End For loop

	;IF

	;IF : condition
	mov eax, dword [esp + 96]
	mov ebx, 0
	cmp eax, ebx
	sete al
	movzx eax, al
	cmp eax, 0
	jz endif1
	;End IF : codition

	;IF : content

	;Expression
	mov eax, 0
	mov dword [esp + 84], eax
	mov eax, dword [esp + 84]
	;End Expression
	;End IF : content
endif1:
	;End IF
	;End For : content

	;For : step
ls0:
	mov eax, dword [esp + 84]
	mov ebx, 1
	sub eax, ebx
	mov dword [esp + 84], eax
	mov eax, dword [esp + 84]
	;End For : step
	jmp l0
lr0:
	;End For loop

	;Print routine
	sub esp, 8
	mov eax, dword str0
	mov dword [esp + 4], eax
	mov eax, dword str1
	mov dword [esp], eax
	call printf
	add esp, 8
	;End Print routine

	;For loop

	;For : initialization
	mov eax, 0
	mov dword [esp + 84], eax
	mov eax, dword [esp + 84]
	;End For : initialization
l2:

	;For : condition
	mov eax, dword [esp + 84]
	mov ebx, dword [esp + 80]
	cmp eax, ebx
	setl al
	movzx eax, al
	cmp eax, 0
	jz lr2
	;End For : codition

	;For : content

	;Print routine
	sub esp, 12
	mov eax, dword [esp + 96]
	sal eax, 2
	mov eax, dword [esp + 12 + eax]
	mov dword [esp + 4], eax
	mov eax, dword str2
	mov dword [esp + 8], eax
	mov eax, dword str3
	mov dword [esp], eax
	call printf
	add esp, 12
	;End Print routine
	;End For : content

	;For : step
ls2:
	mov eax, dword [esp + 84]
	mov ebx, 1
	add eax, ebx
	mov dword [esp + 84], eax
	mov eax, dword [esp + 84]
	;End For : step
	jmp l2
lr2:
	;End For loop

	;Print routine
	sub esp, 8
	mov eax, dword str4
	mov dword [esp + 4], eax
	mov eax, dword str5
	mov dword [esp], eax
	call printf
	add esp, 8
	;End Print routine

	leave
	ret 0

