extern printf
extern getchar

section .bss
	var0	resb 1
	var1	resb 1
	var2	resd 1
	var3	resd 1
	var4	resd 5

section .data
	var5	db 1
	var6	db 97
	var7	dd 20
	var8	dd 2.000000
	var9	dd 1, 2, 3, 4, 5
	var10	db "Hello World",10,"",0
	str0	db " : ",0
	str1	db " ",0
	str2	db " ",0
	str3	db "",10,"",0
	str4	db "%s%s%d%s%c%s%d%s",0
	str5	db "varintiv = [",0
	str6	db "%s",0
	str7	db ", ",0
	str8	db "%d%s",0
	str9	db "]",10,"",0
	str10	db "%d%s",0
	str11	db "Entrando en for",10,"",0
	str12	db "%s",0
	str13	db "Primo 2",10,"",0
	str14	db "%s",0
	str15	db "Primo 3",10,"",0
	str16	db "%s",0
	str17	db "Primo 5",10,"",0
	str18	db "%s",0
	str19	db "Primo 7",10,"",0
	str20	db "%s",0
	str21	db "Final en breve",10,"",0
	str22	db "%s",0
	str23	db "Esperado: 14 ",0
	str24	db "Obtenido: ",0
	str25	db "",10,"",0
	str26	db "%s%s%d%s",0
	str27	db "Saliendo de for",10,"",0
	str28	db "%s",0
	str29	db "Entrando en while",10,"",0
	str30	db "%s",0
	str31	db " iteraciones para salir",10,"",0
	str32	db "%d%s",0
	str33	db "Esperado: 15 ",0
	str34	db "Obtenido: ",0
	str35	db "",10,"",0
	str36	db "%s%s%d%s",0
	str37	db "Esperado: 5 ",0
	str38	db "Obtenido: ",0
	str39	db "",10,"",0
	str40	db "%s%s%d%s",0
	str41	db "Esperado: 50 ",0
	str42	db "Obtenido: ",0
	str43	db "",10,"",0
	str44	db "%s%s%d%s",0
	str45	db "Esperado: 2 ",0
	str46	db "Obtenido: ",0
	str47	db "",10,"",0
	str48	db "%s%s%d%s",0
	str49	db "Esperado: 0 ",0
	str50	db "Obtenido: ",0
	str51	db "",10,"",0
	str52	db "%s%s%d%s",0
	str53	db "Esperado: 1 ",0
	str54	db "Obtenido: ",0
	str55	db "",10,"",0
	str56	db "%s%s%d%s",0
	str57	db "Esperado: 0 ",0
	str58	db "Obtenido: ",0
	str59	db "",10,"",0
	str60	db "%s%s%d%s",0
	str61	db "Esperado: 1 ",0
	str62	db "Obtenido: ",0
	str63	db "",10,"",0
	str64	db "%s%s%d%s",0
	str65	db "Esperado: 0 ",0
	str66	db "Obtenido: ",0
	str67	db "",10,"",0
	str68	db "%s%s%d%s",0
	str69	db "Esperado: 0 ",0
	str70	db "Obtenido: ",0
	str71	db "",10,"",0
	str72	db "%s%s%d%s",0
	str73	db "Esperado: 1 ",0
	str74	db "Obtenido: ",0
	str75	db "",10,"",0
	str76	db "%s%s%d%s",0
	str77	db "Esperado: 320 ",0
	str78	db "Obtenido: ",0
	str79	db "",10,"",0
	str80	db "%s%s%d%s",0
	str81	db "Esperado: 0 ",0
	str82	db "Obtenido: ",0
	str83	db "",10,"",0
	str84	db "%s%s%d%s",0
	str85	db "Esperado: 0 ",0
	str86	db "Obtenido: ",0
	str87	db "",10,"",0
	str88	db "%s%s%d%s",0
	str89	db "Esperado: 15 ",0
	str90	db "Obtenido: ",0
	str91	db "",10,"",0
	str92	db "%s%s%d%s",0
	str93	db "Esperado: 15 ",0
	str94	db "Obtenido: ",0
	str95	db "",10,"",0
	str96	db "%s%s%d%s",0
	str97	db "Esperado: 1 ",0
	str98	db "Obtenido: ",0
	str99	db "",10,"",0
	str100	db "%s%s%d%s",0
	str101	db "Esperado: 1 ",0
	str102	db "Obtenido: ",0
	str103	db "",10,"",0
	str104	db "%s%s%d%s",0
	str105	db "Esperado: 25 ",0
	str106	db "Obtenido: ",0
	str107	db "%s%s%d%c",0
	str108	db "Llamada a funcion",0
	str109	db "Pulse enter para finalizar...",10,"",0
	str110	db "%s",0

section .text

	global main

fun0:
	enter 0,0

	;Print routine
	sub esp, 36
	mov eax, dword [ebp + 8]
	mov dword [esp + 4], eax
	mov eax, dword str0
	mov dword [esp + 8], eax
	mov eax, dword [ebp + 12]
	mov dword [esp + 12], eax
	mov eax, dword str1
	mov dword [esp + 16], eax
	movsx eax, byte [ebp + 16]
	mov dword [esp + 20], eax
	mov eax, dword str2
	mov dword [esp + 24], eax
	movsx eax, byte [ebp + 20]
	mov dword [esp + 28], eax
	mov eax, dword str3
	mov dword [esp + 32], eax
	mov eax, dword str4
	mov dword [esp], eax
	call printf
	add esp, 36
	;End Print routine

	;Print routine
	sub esp, 8
	mov eax, dword str5
	mov dword [esp + 4], eax
	mov eax, dword str6
	mov dword [esp], eax
	call printf
	add esp, 8
	;End Print routine

	;For loop

	;For : initialization
	mov eax, 0
	mov dword [ebp + 12], eax
	mov eax, dword [ebp + 12]
	;End For : initialization
l0:

	;For : condition
	mov eax, dword [ebp + 12]
	mov ebx, 5
	cmp eax, ebx
	setl al
	movzx eax, al
	cmp eax, 0
	jz lr0
	;End For : codition

	;For : content

	;IF

	;IF : condition
	mov eax, dword [ebp + 12]
	mov ebx, 4
	cmp eax, ebx
	setne al
	movzx eax, al
	cmp eax, 0
	jz if00
	;End IF : codition

	;IF : content

	;Print routine
	sub esp, 12
	mov eax, dword [ebp + 12]
	sal eax, 2
	mov eax, dword [var9 + eax]
	mov dword [esp + 4], eax
	mov eax, dword str7
	mov dword [esp + 8], eax
	mov eax, dword str8
	mov dword [esp], eax
	call printf
	add esp, 12
	;End Print routine
	;End IF : content
	jmp endif0
if00:

	;ELSE : content

	;Print routine
	sub esp, 12
	mov eax, dword [ebp + 12]
	sal eax, 2
	mov eax, dword [var9 + eax]
	mov dword [esp + 4], eax
	mov eax, dword str9
	mov dword [esp + 8], eax
	mov eax, dword str10
	mov dword [esp], eax
	call printf
	add esp, 12
	;End Print routine
	;End ELSE : content
endif0:
	;End IF
	;End For : content

	;For : step
ls0:
	mov eax, dword [ebp + 12]
	mov ebx, 1
	add eax, ebx
	mov dword [ebp + 12], eax
	mov eax, dword [ebp + 12]
	;End For : step
	jmp l0
lr0:
	;End For loop

	leave
	ret 16

main:
	enter 12,0
	mov dword [esp + 8], 20

	;Print routine
	sub esp, 8
	mov eax, dword str11
	mov dword [esp + 4], eax
	mov eax, dword str12
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
l1:

	;For : condition
	mov eax, dword [esp + 0]
	mov ebx, 10
	cmp eax, ebx
	setl al
	movzx eax, al
	cmp eax, 0
	jz lr1
	;End For : codition

	;For : content

	;For loop

	;For : initialization
	mov eax, 0
	mov dword [esp + 4], eax
	mov eax, dword [esp + 4]
	;End For : initialization
l2:

	;For : condition
	mov eax, dword [esp + 4]
	mov ebx, 2
	cmp eax, ebx
	setl al
	movzx eax, al
	cmp eax, 0
	jz lr2
	;End For : codition

	;For : content

	;SWITCH
	mov eax, dword [esp + 0]
case00:
	cmp eax, 2
	jne case01

	;Print routine
	sub esp, 8
	mov eax, dword str13
	mov dword [esp + 4], eax
	mov eax, dword str14
	mov dword [esp], eax
	call printf
	add esp, 8
	;End Print routine
	jmp endswtch0
case01:
	cmp eax, 3
	jne case02

	;Print routine
	sub esp, 8
	mov eax, dword str15
	mov dword [esp + 4], eax
	mov eax, dword str16
	mov dword [esp], eax
	call printf
	add esp, 8
	;End Print routine
	jmp endswtch0
case02:
	cmp eax, 5
	jne case03

	;Print routine
	sub esp, 8
	mov eax, dword str17
	mov dword [esp + 4], eax
	mov eax, dword str18
	mov dword [esp], eax
	call printf
	add esp, 8
	;End Print routine
	jmp endswtch0
case03:
	cmp eax, 7
	jne case04

	;Print routine
	sub esp, 8
	mov eax, dword str19
	mov dword [esp + 4], eax
	mov eax, dword str20
	mov dword [esp], eax
	call printf
	add esp, 8
	;End Print routine
	jmp endswtch0
case04:

	;IF

	;IF : condition
	mov eax, dword [esp + 0]
	mov ebx, 9
	cmp eax, ebx
	sete al
	movzx eax, al
	cmp eax, 0
	jz if10
	;End IF : codition

	;IF : content

	;Print routine
	sub esp, 8
	mov eax, dword str21
	mov dword [esp + 4], eax
	mov eax, dword str22
	mov dword [esp], eax
	call printf
	add esp, 8
	;End Print routine
	;End IF : content
	jmp endif1
if10:

	;ELSIF : condition
	mov eax, dword [esp + 0]
	mov edx, eax
	sar edx, 31
	mov ebx, 2
	idiv ebx
	mov eax, edx
	mov ebx, 0
	cmp eax, ebx
	sete al
	movzx eax, al
	cmp eax, 0
	jz if11
	;End ELSIF : codition

	;ELSIF : content

	;Expression
	mov eax, dword [esp + 8]
	mov ebx, 1
	sub eax, ebx
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression
	;End ELSIF : content
	jmp endif1
if11:

	;ELSE : content

	;Expression
	mov eax, dword [esp + 8]
	mov ebx, 1
	add eax, ebx
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression
	;End ELSE : content
endif1:
	;End IF
endswtch0:
	;End SWITCH
	;End For : content

	;For : step
ls2:
	mov eax, dword [esp + 4]
	mov ebx, 1
	add eax, ebx
	mov dword [esp + 4], eax
	mov eax, dword [esp + 4]
	;End For : step
	jmp l2
lr2:
	;End For loop
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

	;Print routine
	sub esp, 20
	mov eax, dword str23
	mov dword [esp + 4], eax
	mov eax, dword str24
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str25
	mov dword [esp + 16], eax
	mov eax, dword str26
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Print routine
	sub esp, 8
	mov eax, dword str27
	mov dword [esp + 4], eax
	mov eax, dword str28
	mov dword [esp], eax
	call printf
	add esp, 8
	;End Print routine

	;Print routine
	sub esp, 8
	mov eax, dword str29
	mov dword [esp + 4], eax
	mov eax, dword str30
	mov dword [esp], eax
	call printf
	add esp, 8
	;End Print routine

	;While loop
ls3:

	;While : condition
	mov eax, dword [esp + 8]
	mov ebx, 0
	cmp eax, ebx
	setne al
	movzx eax, al
	cmp eax, 0
	jz lr3
	;End while : codition

	;While : content

	;Expression
	mov eax, dword [esp + 8]
	mov ebx, 1
	sub eax, ebx
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 12
	mov eax, dword [esp + 20]
	mov dword [esp + 4], eax
	mov eax, dword str31
	mov dword [esp + 8], eax
	mov eax, dword str32
	mov dword [esp], eax
	call printf
	add esp, 12
	;End Print routine
	;End While : content
	jmp ls3
lr3:
	;End While loop

	;Expression
	mov eax, 10
	mov dword [esp + 0], eax
	mov eax, dword [esp + 0]
	;End Expression

	;Expression
	mov eax, 5
	mov dword [esp + 4], eax
	mov eax, dword [esp + 4]
	;End Expression

	;Expression
	mov eax, dword [esp + 0]
	mov ebx, dword [esp + 4]
	add eax, ebx
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str33
	mov dword [esp + 4], eax
	mov eax, dword str34
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str35
	mov dword [esp + 16], eax
	mov eax, dword str36
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, dword [esp + 0]
	mov ebx, dword [esp + 4]
	sub eax, ebx
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str37
	mov dword [esp + 4], eax
	mov eax, dword str38
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str39
	mov dword [esp + 16], eax
	mov eax, dword str40
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, dword [esp + 0]
	mov ebx, dword [esp + 4]
	imul eax, ebx
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str41
	mov dword [esp + 4], eax
	mov eax, dword str42
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str43
	mov dword [esp + 16], eax
	mov eax, dword str44
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, dword [esp + 0]
	mov edx, eax
	sar edx, 31
	mov ebx, dword [esp + 4]
	idiv ebx
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str45
	mov dword [esp + 4], eax
	mov eax, dword str46
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str47
	mov dword [esp + 16], eax
	mov eax, dword str48
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, dword [esp + 0]
	mov edx, eax
	sar edx, 31
	mov ebx, dword [esp + 4]
	idiv ebx
	mov eax, edx
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str49
	mov dword [esp + 4], eax
	mov eax, dword str50
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str51
	mov dword [esp + 16], eax
	mov eax, dword str52
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, dword [esp + 0]
	mov ebx, dword [esp + 4]
	cmp eax, ebx
	setg al
	movzx eax, al
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str53
	mov dword [esp + 4], eax
	mov eax, dword str54
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str55
	mov dword [esp + 16], eax
	mov eax, dword str56
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, dword [esp + 0]
	mov ebx, dword [esp + 4]
	cmp eax, ebx
	setl al
	movzx eax, al
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str57
	mov dword [esp + 4], eax
	mov eax, dword str58
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str59
	mov dword [esp + 16], eax
	mov eax, dword str60
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, dword [esp + 0]
	mov ebx, dword [esp + 4]
	cmp eax, ebx
	setge al
	movzx eax, al
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str61
	mov dword [esp + 4], eax
	mov eax, dword str62
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str63
	mov dword [esp + 16], eax
	mov eax, dword str64
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, dword [esp + 0]
	mov ebx, dword [esp + 4]
	cmp eax, ebx
	setle al
	movzx eax, al
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str65
	mov dword [esp + 4], eax
	mov eax, dword str66
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str67
	mov dword [esp + 16], eax
	mov eax, dword str68
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, dword [esp + 0]
	mov ebx, dword [esp + 4]
	cmp eax, ebx
	sete al
	movzx eax, al
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str69
	mov dword [esp + 4], eax
	mov eax, dword str70
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str71
	mov dword [esp + 16], eax
	mov eax, dword str72
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, dword [esp + 0]
	mov ebx, dword [esp + 4]
	cmp eax, ebx
	setne al
	movzx eax, al
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str73
	mov dword [esp + 4], eax
	mov eax, dword str74
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str75
	mov dword [esp + 16], eax
	mov eax, dword str76
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, dword [esp + 0]
	mov ecx, dword [esp + 4]
	sal eax, cl
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str77
	mov dword [esp + 4], eax
	mov eax, dword str78
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str79
	mov dword [esp + 16], eax
	mov eax, dword str80
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, dword [esp + 0]
	mov ecx, dword [esp + 4]
	sar eax, cl
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str81
	mov dword [esp + 4], eax
	mov eax, dword str82
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str83
	mov dword [esp + 16], eax
	mov eax, dword str84
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, dword [esp + 0]
	mov ebx, dword [esp + 4]
	and eax, ebx
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str85
	mov dword [esp + 4], eax
	mov eax, dword str86
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str87
	mov dword [esp + 16], eax
	mov eax, dword str88
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, dword [esp + 0]
	mov ebx, dword [esp + 4]
	or eax, ebx
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str89
	mov dword [esp + 4], eax
	mov eax, dword str90
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str91
	mov dword [esp + 16], eax
	mov eax, dword str92
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, dword [esp + 0]
	mov ebx, dword [esp + 4]
	xor eax, ebx
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str93
	mov dword [esp + 4], eax
	mov eax, dword str94
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str95
	mov dword [esp + 16], eax
	mov eax, dword str96
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, dword [esp + 0]
	mov ebx, dword [esp + 4]
	cmp eax, 0
	setne al
	movsx eax, al
	cmp ebx, 0
	setne bl
	movsx ebx, bl
	and eax, ebx
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str97
	mov dword [esp + 4], eax
	mov eax, dword str98
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str99
	mov dword [esp + 16], eax
	mov eax, dword str100
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, dword [esp + 0]
	mov ebx, dword [esp + 4]
	cmp eax, 0
	setne al
	movsx eax, al
	cmp ebx, 0
	setne bl
	movsx ebx, bl
	or eax, ebx
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str101
	mov dword [esp + 4], eax
	mov eax, dword str102
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword str103
	mov dword [esp + 16], eax
	mov eax, dword str104
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, dword [esp + 0]
	push eax
	mov eax, dword [esp + 8]
	mov ecx, dword [esp + 4]
	imul eax, ecx
	mov edx, eax
	sar edx, 31
	mov ebx, 5
	idiv ebx
	mov ebx, eax
	pop eax
	add eax, ebx
	mov ebx, 7
	add eax, ebx
	mov ebx, dword [esp + 8]
	mov ecx, 2
	imul ebx, ecx
	sub eax, ebx
	mov dword [esp + 8], eax
	mov eax, dword [esp + 8]
	;End Expression

	;Print routine
	sub esp, 20
	mov eax, dword str105
	mov dword [esp + 4], eax
	mov eax, dword str106
	mov dword [esp + 8], eax
	mov eax, dword [esp + 28]
	mov dword [esp + 12], eax
	mov eax, dword 10
	mov dword [esp + 16], eax
	mov eax, dword str107
	mov dword [esp], eax
	call printf
	add esp, 20
	;End Print routine

	;Expression
	mov eax, 0
	push eax
	mov eax, 97
	push eax
	mov eax, 1
	push eax
	mov eax, dword str108
	push eax
	call fun0
	mov eax, eax
	;End Expression

	;Print routine
	sub esp, 8
	mov eax, dword str109
	mov dword [esp + 4], eax
	mov eax, dword str110
	mov dword [esp], eax
	call printf
	add esp, 8
	;End Print routine

	;Scan char routine
	call getchar
	mov dword [esp + 8], eax

	leave
	ret 0

