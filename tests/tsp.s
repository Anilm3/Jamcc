extern printf
extern getchar

section .bss
	var0	resd 10
	var1	resd 100

section .data
	var2	dd 10
	var3	dd 1, 1, 5, 5, 2, 3, 4, 5, 9, 2, 3, 4, 10, 15, 1, 0, 5, 19, 4, 8
	var4	dd 2147483647
	str0	db "Solucion: ",0
	str1	db "%s",0
	str2	db " ",0
	str3	db "%d%s",0
	str4	db "",10,"",0
	str5	db "%s",0

section .text

	global main

fun0:
	enter 0,0

	;IF

	;IF : condition
	mov eax, dword [ebp + 8]
	mov ebx, 0
	cmp eax, ebx
	setl al
	movzx eax, al
	cmp eax, 0
	jz if00
	;End IF : codition

	;IF : content
	mov eax, dword [ebp + 8]
	neg eax
	leave
	ret 4
	;End IF : content
	jmp endif0
if00:

	;ELSE : content
	mov eax, dword [ebp + 8]
	leave
	ret 4
	;End ELSE : content
endif0:
	;End IF

	leave
	ret 4

fun1:
	enter 0,0
	mov eax, dword [ebp + 12]
	mov ebx, dword [ebp + 8]
	sub eax, ebx
	push eax
	call fun0
	mov eax, eax
	push eax
	mov ebx, dword [ebp + 20]
	mov ecx, dword [ebp + 16]
	sub ebx, ecx
	push ebx
	call fun0
	mov ebx, eax
	pop eax
	add eax, ebx
	leave
	ret 16

	leave
	ret 16

fun2:
	enter 12,0
	mov dword [esp + 8], 0

	;For loop

	;For : initialization
	mov eax, 0
	mov dword [esp + 0], eax
	mov eax, dword [esp + 0]
	;End For : initialization
l0:

	;For : condition
	mov eax, dword [esp + 0]
	mov ebx, dword [var2]
	mov ecx, 1
	sub ebx, ecx
	cmp eax, ebx
	setl al
	movzx eax, al
	cmp eax, 0
	jz lr0
	;End For : codition

	;For : content

	;Expression
	mov eax, dword [esp + 0]
	mov ebx, 1
	add eax, ebx
	mov dword [esp + 4], eax
	mov eax, dword [esp + 4]
	;End Expression

	;Expression
	mov eax, dword [esp + 8]
	mov ebx, dword [esp + 0]
	sal ebx, 2
	add ebx, dword [ebp + 8]
	mov ebx, dword [ebx]
	mov ecx, dword [var2]
	imul ebx, ecx
	mov ecx, dword [esp + 4]
	sal ecx, 2
	add ecx, dword [ebp + 8]
	mov ecx, dword [ecx]
	add ebx, ecx
	sal ebx, 2
	mov ebx, dword [var1 + ebx]
	add eax, ebx
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression
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

	;IF

	;IF : condition
	mov eax, dword [var4]
	mov ebx, dword [esp + 8]
	cmp eax, ebx
	setg al
	movzx eax, al
	cmp eax, 0
	jz endif1
	;End IF : codition

	;IF : content

	;Expression
	mov eax, dword [esp + 8]
	mov dword [var4], eax
	mov eax, dword [var4]
	;End Expression

	;For loop

	;For : initialization
	mov eax, 0
	mov dword [esp + 0], eax
	mov eax, dword [esp + 0]
	;End For : initialization
l1:

	;For : condition
	mov eax, dword [esp + 0]
	mov ebx, dword [var2]
	cmp eax, ebx
	setl al
	movzx eax, al
	cmp eax, 0
	jz lr1
	;End For : codition

	;For : content

	;Expression
	mov eax, dword [esp + 0]
	sal eax, 2
	add eax, dword [ebp + 8]
	mov eax, dword [eax]
	mov ebx, dword [esp + 0]
	sal ebx, 2
	mov dword [var0 + ebx], eax
	mov eax, dword [esp + 0]
	sal eax, 2
	mov eax, dword [var0 + eax]
	;End Expression
	;End For : content

	;For : step
ls1:
	mov eax, dword [esp + 0]
	mov ebx, 1
	add eax, ebx
	mov dword [esp + 0], eax
	mov eax, dword [esp + 0]
	;End For : step
	jmp l1
lr1:
	;End For loop
	;End IF : content
endif1:
	;End IF

	leave
	ret 4

fun3:
	enter 16,0

	;For loop

	;For : initialization
	mov eax, 0
	mov dword [esp + 0], eax
	mov eax, dword [esp + 0]
	;End For : initialization
l2:

	;For : condition
	mov eax, dword [esp + 0]
	mov ebx, dword [var2]
	cmp eax, ebx
	setl al
	movzx eax, al
	cmp eax, 0
	jz lr2
	;End For : codition

	;For : content

	;Expression
	mov eax, 0
	cmp eax, 0
	setg al
	movzx eax, al
	mov byte [esp + 12], al
	movsx eax, byte [esp + 12]
	;End Expression

	;For loop

	;For : initialization
	mov eax, 0
	mov dword [esp + 4], eax
	mov eax, dword [esp + 4]
	;End For : initialization
l3:

	;For : condition
	mov eax, dword [esp + 4]
	mov ebx, dword [ebp + 12]
	cmp eax, ebx
	setl al
	movzx eax, al
	cmp eax, 0
	jz lr3
	;End For : codition

	;For : content

	;IF

	;IF : condition
	mov eax, dword [esp + 4]
	sal eax, 2
	add eax, dword [ebp + 8]
	mov eax, dword [eax]
	mov ebx, dword [esp + 0]
	cmp eax, ebx
	sete al
	movzx eax, al
	cmp eax, 0
	jz endif2
	;End IF : codition

	;IF : content

	;Expression
	mov eax, 1
	cmp eax, 0
	setg al
	movzx eax, al
	mov byte [esp + 12], al
	movsx eax, byte [esp + 12]
	;End Expression
	jmp lr3
	;End IF : content
endif2:
	;End IF
	;End For : content

	;For : step
ls3:
	mov eax, dword [esp + 4]
	mov ebx, 1
	add eax, ebx
	mov dword [esp + 4], eax
	mov eax, dword [esp + 4]
	;End For : step
	jmp l3
lr3:
	;End For loop

	;IF

	;IF : condition
	movsx eax, byte [esp + 12]
	cmp eax, 0
	jz endif3
	;End IF : codition

	;IF : content
	jmp ls2
	;End IF : content
endif3:
	;End IF

	;IF

	;IF : condition
	mov eax, dword [ebp + 12]
	mov ebx, dword [var2]
	mov ecx, 1
	sub ebx, ecx
	cmp eax, ebx
	sete al
	movzx eax, al
	cmp eax, 0
	jz if40
	;End IF : codition

	;IF : content

	;Expression
	mov eax, dword [esp + 0]
	mov ebx, dword [ebp + 12]
	sal ebx, 2
	add ebx, dword [ebp + 8]
	mov dword [ebx], eax
	mov eax, dword [ebp + 12]
	sal eax, 2
	add eax, dword [ebp + 8]
	mov eax, dword [eax]
	;End Expression

	;Expression
	mov eax, dword [ebp + 8]
	push eax
	call fun2
	mov eax, eax
	;End Expression
	;End IF : content
	jmp endif4
if40:

	;ELSE : content

	;Expression
	mov eax, dword [esp + 0]
	mov ebx, dword [ebp + 12]
	sal ebx, 2
	add ebx, dword [ebp + 8]
	mov dword [ebx], eax
	mov eax, dword [ebp + 12]
	sal eax, 2
	add eax, dword [ebp + 8]
	mov eax, dword [eax]
	;End Expression

	;Expression
	mov eax, dword [ebp + 12]
	mov ebx, 1
	add eax, ebx
	push eax
	mov eax, dword [ebp + 8]
	push eax
	call fun3
	mov eax, eax
	;End Expression
	;End ELSE : content
endif4:
	;End IF
	;End For : content

	;For : step
ls2:
	mov eax, dword [esp + 0]
	mov ebx, 1
	add eax, ebx
	mov dword [esp + 0], eax
	mov eax, dword [esp + 0]
	;End For : step
	jmp l2
lr2:
	;End For loop

	leave
	ret 8

main:
	enter 60,0

	;For loop

	;For : initialization
	mov eax, 0
	mov dword [esp + 0], eax
	mov eax, dword [esp + 0]
	;End For : initialization
l4:

	;For : condition
	mov eax, dword [esp + 0]
	mov ebx, dword [var2]
	cmp eax, ebx
	setl al
	movzx eax, al
	cmp eax, 0
	jz lr4
	;End For : codition

	;For : content

	;For loop

	;For : initialization
	mov eax, 0
	mov dword [esp + 4], eax
	mov eax, dword [esp + 4]
	;End For : initialization
l5:

	;For : condition
	mov eax, dword [esp + 4]
	mov ebx, dword [var2]
	cmp eax, ebx
	setl al
	movzx eax, al
	cmp eax, 0
	jz lr5
	;End For : codition

	;For : content

	;Expression
	mov eax, dword [esp + 0]
	mov ebx, dword [var2]
	imul eax, ebx
	mov ebx, dword [esp + 4]
	add eax, ebx
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Expression
	mov eax, dword [esp + 4]
	mov ebx, 2
	imul eax, ebx
	mov ebx, 1
	add eax, ebx
	sal eax, 2
	mov eax, dword [var3 + eax]
	push eax
	mov eax, dword [esp + 4]
	mov ebx, 2
	imul eax, ebx
	mov ebx, 1
	add eax, ebx
	sal eax, 2
	mov eax, dword [var3 + eax]
	push eax
	mov eax, dword [esp + 12]
	mov ebx, 2
	imul eax, ebx
	sal eax, 2
	mov eax, dword [var3 + eax]
	push eax
	mov eax, dword [esp + 12]
	mov ebx, 2
	imul eax, ebx
	sal eax, 2
	mov eax, dword [var3 + eax]
	push eax
	call fun1
	mov eax, eax
	mov ebx, dword [esp + 8]
	sal ebx, 2
	mov dword [var1 + ebx], eax
	mov eax, dword [esp + 8]
	sal eax, 2
	mov eax, dword [var1 + eax]
	;End Expression
	;End For : content

	;For : step
ls5:
	mov eax, dword [esp + 4]
	mov ebx, 1
	add eax, ebx
	mov dword [esp + 4], eax
	mov eax, dword [esp + 4]
	;End For : step
	jmp l5
lr5:
	;End For loop
	;End For : content

	;For : step
ls4:
	mov eax, dword [esp + 0]
	mov ebx, 1
	add eax, ebx
	mov dword [esp + 0], eax
	mov eax, dword [esp + 0]
	;End For : step
	jmp l4
lr4:
	;End For loop

	;Expression
	mov eax, 0
	push eax
	lea eax, [esp + 24]
	push eax
	call fun3
	mov eax, eax
	;End Expression

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
	mov dword [esp + 0], eax
	mov eax, dword [esp + 0]
	;End For : initialization
l6:

	;For : condition
	mov eax, dword [esp + 0]
	mov ebx, dword [var2]
	cmp eax, ebx
	setl al
	movzx eax, al
	cmp eax, 0
	jz lr6
	;End For : codition

	;For : content

	;Print routine
	sub esp, 12
	mov eax, dword [esp + 12]
	sal eax, 2
	mov eax, dword [var0 + eax]
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
ls6:
	mov eax, dword [esp + 0]
	mov ebx, 1
	add eax, ebx
	mov dword [esp + 0], eax
	mov eax, dword [esp + 0]
	;End For : step
	jmp l6
lr6:
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

