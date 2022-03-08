.386
.model flat,stdcall
option casemap:none

include windows.inc
include gdi32.inc
includelib gdi32.lib
include user32.inc
includelib user32.lib
include kernel32.inc
includelib kernel32.lib
include	msvcrt.inc
includelib msvcrt.lib
printf PROTO C :dword,:vararg
scanf  PROTO C :dword,:vararg
strlen PROTO C :dword
.data
hInstance dd ?  ;���Ӧ�ó���ľ��
hWinMain dd ?   ;��Ŵ��ڵľ��
hand dd ?
i dword 0
j dword 0
k dword 0
hGame dd 25 dup(?)

seed        dd          2314
max			dd			16
dat         dd          0
score        dd         0
randData    dd          0
changedW dd 1 ;�����Ƿ����ƶ�����ֵΪ0���ƶ�����Ϊ1
changedS dd 0 ;�����Ƿ����ƶ�����ֵΪ0���ƶ�����Ϊ1
changedA dd 1 ;�����Ƿ����ƶ�����ֵΪ0���ƶ�����Ϊ1
changedD dd 1 ;�����Ƿ����ƶ�����ֵΪ0���ƶ�����Ϊ1

gameIsEnd dd    0
gameIsWin dd 0
gameContinue dd 0
tmpMat dd 16 DUP(?)

Data byte 10 dup(?)

data dword 2 dup(0)
;score dword 435161643
num dword 16 dup(2048,0,0,0,2,0,0,0,0,0,0,0,0,0,4,2)
showButton byte ' ',0
button db 'button',0
edit db 'edit',0

gameMat dd 0,0,0,0
		dd 0,0,0,0
		dd 0,0,0,0
		dd 0,0,0,0

tmpGameMat  dd 0,0,0,0
			dd 0,0,0,0
			dd 0,0,0,0
			dd 0,0,0,0
overEdge dd ?
exchangeNum dd ?

row dd 1
col dd 1 

printf_pref db '%d',0ah,0
printf_d db '%c',0ah,0
scanf_sh byte '%c',0ah,0
printf_ok db 'it is ok',0ah,0

hdcIDB_BITMAP1 dd ?
hbmIDB_BITMAP1 dd ?
hdcIDB_BITMAP2 dd ?
hbmIDB_BITMAP2 dd ?
dwNow dd ?
IDB_BITMAP1 BYTE 'IDB_BITMAP1',0
IDB_BITMAP2 BYTE 'IDB_BITMAP2',0

.const
szClassName db 'MyClass',0
szCaptionMain db '2048',0
szText db 'Win32 Assembly,Simple and powerful!',0
szText1 byte "Welcome to 2048!",0
szText2 byte "Use WASD to move the tiles along the grid",0
szText5 byte "If two tiles of the same number touch, they'll merge",0
szText3 byte "Try to get a 2048 tile, or go as high as you can!",0
szText4 byte "The game will end if every tile gets filled and you can't merge any tiles",0
szText7 byte "Game Is Over",0
szText6 byte "2048",0
szText8 byte "Congratulations!",0
szText9 byte "You have won this game!",0
szText10 byte "You are so great!",0
szText11 byte "Thank you for playing!",0
szText12 byte "Now you can choose 'YES' to continue,or 'No' to quit",0
IDM EQU 101
BITMAP2 EQU 104

.code
gameWin proc
	invoke MessageBox,hWinMain,offset szText8,offset szText6,MB_OK
	.if eax == IDOK
		invoke MessageBox,hWinMain,offset szText9,offset szText6,MB_OK
		.if eax == IDOK
			invoke MessageBox,hWinMain,offset szText10,offset szText6,MB_OK
			.if eax == IDOK
				invoke MessageBox,hWinMain,offset szText11,offset szText6,MB_OK
				.if eax == IDOK
					invoke MessageBox,hWinMain,offset szText12,offset szText6,MB_YESNO
					.if eax == IDYES
						mov gameContinue,1
					.elseif eax == IDNO
						invoke DestroyWindow,hWinMain
						invoke PostQuitMessage,NULL
					.endif
				.endif
			.endif
		.endif
	.endif
	ret
	
gameWin endp
random32       proc    random_seed:DWORD,max_val:DWORD 
                push ecx
                push edx
                call       GetTickCount ;��ȡϵͳʱ��
                mov        ecx,random_seed
                add        eax,ecx 
                rol        ecx,1
                add        ecx,666h 
                mov        random_seed,ecx 

                mov     ecx,32

    crc_bit:    shr        eax,1
                jnc        loop_crc_bit 
                xor        eax,0edb88320h

    loop_crc_bit:
                loop        crc_bit
                mov         ecx,max_val

                xor         edx,edx ;��16λ���
                div         ecx
                xchg        edx,eax ;��������eax
                or          eax,eax

				mov			randData,eax
                cmp     gameMat[eax*4],0
                je      inital_mat

                mov     ecx,16
                mov     randData,eax
                xor     eax,eax     ;���tmpָ��
                xor     edx,edx     ;���gameָ��

    get_emp:    
                cmp     gameMat[edx*4],0
                jne      cmp_ne      ;����Ϊ��
                
                mov     tmpMat[eax*4],edx
                inc     eax
    cmp_ne:         
                inc     edx
                loop    get_emp
                ;eax���tmp����

                mov     ecx,eax
                xor     edx,edx
                mov     eax,randData
                div     ecx
                xchg    edx,eax ;eaxΪtmpָ��

                mov     edx,tmpMat[eax*4]
                mov     randData,edx
    inital_mat:
                mov     eax,randData
                mov     gameMat[eax*4],2
                pop edx
                pop ecx
                ret        
    random32    Endp

getscore       proc
            push    ecx
            push    edx

            mov     ecx,0
            xor     eax,eax
			mov     score,0
 cul_score:
            mov     edx,gameMat[ecx*4]
            mov     eax,score
            .if     edx==0
            .elseif     edx==2
                
            .elseif     edx==4
                add     eax,4
            .elseif     edx==8
                add     eax,16
            .elseif     edx==16
                add     eax,48
            .elseif     edx==32
                add     eax,128
            .elseif     edx==64
                add     eax,320
            .elseif     edx==128
                add     eax,768
            .elseif     edx==256
                add     eax,1792
            .elseif     edx==512
                add     eax,4096
            .elseif     edx==1024
                add     eax,9216
            .elseif     edx==2048
                add     eax,20480
            .else
                add eax,45036
            .endif
            mov     score,eax
            inc     ecx
            cmp     ecx,16
            jb    cul_score
			
			
			.if score >= 20480
				mov gameIsWin,1
			.endif
            pop     edx
            pop     ecx

            ret
getscore        Endp




moveW proc far C uses eax ebx ecx edx
	MOV changedW,0
	mov ecx,4
	mov col,ecx
	mov row,1
w:
	mov col,ecx
	mov row,1

	jmp w_trav

w_end:
	loop w

	;invoke printf,offset printf_pref,gameMat[48]
	ret
w_trav:
	imul eax,row,4
	add eax,col
	sub eax,5
	mov edx,gameMat[eax*4];�����˱Ƚ���
	mov ebx,eax

	cmp row,1
	je w_merge

	cmp row,2
	je w_fore

	cmp row,3
	je w_fore

	cmp row,4
	je w_fore

	jmp w_trav

w_mov:
	inc row
	cmp row,5
	jb w_trav

	jmp w_end
	ret ;������retЩʲô��������

w_merge:
	cmp edx,0
	je w_mov

	add ebx,4

	cmp ebx,16
	jae w_mov

	cmp eax,ebx
	je w_merge

	cmp gameMat[ebx*4],0
	je w_merge

	cmp gameMat[ebx*4],edx
	je w_equ
	jmp w_mov

w_equ:
	imul edx,2
	mov gameMat[eax*4],edx
	mov gameMat[ebx*4],0

    mov exchangeNum,edx
	mov edx,1
	mov changedW,edx
	mov edx,exchangeNum

	jmp w_mov

w_fore:
	cmp edx,0
	je w_mov
	mov ebx,eax
	sub ebx,4
	cmp gameMat[ebx*4],0
	je w_zero
	jmp w_merge

w_zero:
	mov gameMat[ebx*4],edx
	mov gameMat[eax*4],0

    mov exchangeNum,edx
	mov edx,1
	mov changedW,edx
	mov edx,exchangeNum
    
	mov eax,ebx
	sub ebx,4
	;�߽���
	cmp ebx,4000 ;-1�ķ����ʾ��0�ȴ�С
	ja w_merge

	cmp gameMat[ebx*4],0
	je w_zero
	jmp w_merge

moveW endp

moveD proc far C uses eax ebx ecx edx
	mov ecx,4
	mov col,ecx
	mov row,4
	MOV changedD,0

d:

	mov row,ecx
	mov col,4

	jmp d_trav

d_end:
	loop d

	;invoke printf,offset printf_pref,gameMat[28]
	ret
d_trav:
	imul eax,row,4
	add eax,col
	sub eax,5
	mov edx,gameMat[eax*4];�����˱Ƚ���
	mov ebx,eax

	cmp col,4
	je d_merge

	cmp col,3
	je d_fore

	cmp col,2
	je d_fore

	cmp col,1
	je d_fore

	jmp d_trav
d_mov:

	dec col
	cmp col,0
	ja d_trav
	jmp d_end
	ret
d_merge:
	cmp edx,0
	je d_mov
	;mov ebx,eax
	dec ebx
	mov overEdge,eax
	mov eax,row
	dec eax
	imul eax,4
	dec eax
	cmp eax,ebx
	je d_mov
	mov eax,overEdge
	cmp eax,ebx
	je d_merge
	cmp gameMat[ebx*4],0
	je d_merge
	cmp gameMat[ebx*4],edx
	je d_equ
	jmp d_mov

d_equ:
	imul edx,2
	mov gameMat[eax*4],edx
	mov gameMat[ebx*4],0

    mov exchangeNum,edx
	mov edx,1
	mov changedD,edx
	mov edx,exchangeNum

	jmp d_mov
d_fore:
	cmp edx,0
	je d_mov
	mov ebx,eax
	inc ebx
	cmp gameMat[ebx*4],0
	je d_zero
	jmp d_merge
d_zero:
	mov gameMat[ebx*4],edx
	mov gameMat[eax*4],0

    mov exchangeNum,edx
	mov edx,1
	mov changedD,edx
	mov edx,exchangeNum
    
	mov eax,ebx
	inc ebx
	mov overEdge,ebx
	mov ebx,row
	imul ebx,4
	cmp overEdge,ebx
	je d_merge
	mov ebx,overEdge
	cmp gameMat[ebx*4],0
	je d_zero
	jmp d_merge
moveD endp

moveA proc far C uses eax ebx ecx edx
	mov changedA,0
	mov ecx,4
	mov row,ecx
	mov col,1
a:
	mov row,ecx
	mov col,1

	jmp a_trav

a_end:
	loop a

	;invoke printf,offset printf_pref,gameMat[8]
	ret

a_trav:
	imul eax,row,4
	add eax,col
	sub eax,5
	mov edx,gameMat[eax*4];����Ƚ���
	mov ebx,eax

	cmp col,1
	je a_merge

	cmp col,2
	je a_fore

	cmp col,3
	je a_fore

	cmp col,4
	je a_fore

	jmp a_trav

a_mov: ;�ƶ�
	inc col
	cmp col,5
	jb a_trav

	jmp a_end
	ret ;������retЩʲô��������
a_merge:
	cmp edx,0
	je a_mov

	inc ebx

	;cmp ebx,5
	;jae a_mov
	mov overEdge,eax
	mov eax,row
	;dec eax
	imul eax,4
	;dec eax
	cmp eax,ebx
	je a_mov
	mov eax,overEdge

	cmp eax,ebx
	je a_merge

	cmp gameMat[ebx*4],0
	je a_merge

	cmp gameMat[ebx*4],edx
	je a_equ
	jmp a_mov

a_equ:
	imul edx,2
	mov gameMat[eax*4],edx
	mov gameMat[ebx*4],0

    mov exchangeNum,edx
	mov edx,1
	mov changedA,edx
	mov edx,exchangeNum
    
	jmp a_mov

a_fore:
	cmp edx,0
	je a_mov
	mov ebx,eax
	dec ebx
	cmp gameMat[ebx*4],0
	je a_zero
	jmp a_merge

a_zero:
	mov gameMat[ebx*4],edx
	mov gameMat[eax*4],0

	mov exchangeNum,edx
	mov edx,1
	mov changedA,edx
	mov edx,exchangeNum

	mov eax,ebx
	dec ebx
	;�߽���
	mov overEdge,ebx
	mov ebx,row
	dec ebx
	imul ebx,4
	dec ebx
	cmp overEdge,ebx
	je a_merge
	mov ebx,overEdge

	cmp gameMat[ebx*4],0
	je a_zero
	jmp a_merge


moveA endp

moveS proc far C uses eax ebx ecx edx
	mov ecx,4
	mov row,ecx
	mov col,4
	mov changedS,0


s:
	mov col,ecx
	mov row,4

	jmp s_trav

s_end:
	loop s

	;invoke printf,offset printf_pref,gameMat[36]
	ret
s_trav:
	imul eax,row,4
	add eax,col
	sub eax,5
	mov edx,gameMat[eax*4];�����˱Ƚ���
	mov ebx,eax

	cmp row,4
	je s_merge

	cmp row,3
	je s_fore

	cmp row,2
	je s_fore

	cmp row,1
	je s_fore

	jmp s_trav
s_mov:
	dec row
	cmp row,0
	ja s_trav

	jmp s_end
	ret ;������retЩʲô��������

s_merge:
	cmp edx,0
	je s_mov

	sub ebx,4

	cmp ebx,400
	jae s_mov

	cmp eax,ebx
	je s_merge

	cmp gameMat[ebx*4],0
	je s_merge

	cmp gameMat[ebx*4],edx
	je s_equ
	jmp s_mov
s_equ:
	imul edx,2
	mov gameMat[eax*4],edx
	mov gameMat[ebx*4],0

    mov exchangeNum,edx
	mov edx,1
	mov changedS,edx
	mov edx,exchangeNum

	jmp s_mov

s_fore:
	cmp edx,0
	je s_mov
	mov ebx,eax
	add ebx,4
	cmp gameMat[ebx*4],0
	je s_zero
	jmp s_merge
s_zero:
	mov gameMat[ebx*4],edx
	mov gameMat[eax*4],0

    mov exchangeNum,edx
	mov edx,1
	mov changedS,edx
	mov edx,exchangeNum

	mov eax,ebx
	add ebx,4
	;�߽���
	cmp ebx,16 ;-1�ķ����ʾ��0�ȴ�С
	jae s_merge

	cmp gameMat[ebx*4],0
	je s_zero
	jmp s_merge

moveS endp



gameEnd       proc
			
            push    ecx
            push    edx
			mov ecx,16
			mov esi,0
		L1:
			push gameMat[esi*4]
			pop tmpGameMat[esi*4]
			inc esi
			loop L1
			invoke moveW
			
			mov ecx,16
			mov esi,0
		L2:
			push tmpGameMat[esi*4]
			pop gameMat[esi*4]
			inc esi
			loop L2
			invoke moveA
			mov ecx,16
			mov esi,0
		L3:
			push tmpGameMat[esi*4]
			pop gameMat[esi*4]
			inc esi
			loop L3
			invoke moveS

			mov ecx,16
			mov esi,0
		L4:
			push tmpGameMat[esi*4]
			pop gameMat[esi*4]
			inc esi
			loop L4
			invoke moveD

			mov ecx,16
			mov esi,0
		L5:
			push tmpGameMat[esi*4]
			pop gameMat[esi*4]
			inc esi
			loop L5

			XOR EAX,EAX
            mov     eax,changedW
            add     eax,changedS
            add     eax,changedA
            add     eax,changedD

            cmp     eax,0
            jne      end_node

            mov       eax,1
            mov      gameIsEnd,eax
    end_node:
            pop     edx
            pop     edx

            ret
gameEnd        Endp


num2byte proc far C uses eax esi ecx,number:dword

	xor eax,eax
	xor edx,edx
	xor ebx,ebx
	mov eax,number
	mov ecx,10

L1:
	inc ebx
	idiv ecx
	add edx,30H
	push edx
	xor edx,edx
	cmp eax,0
	jg L1

	mov esi,0
L2:
	dec ebx
	pop eax
	mov byte ptr Data[esi],al
	inc esi
	cmp ebx,0
	jg L2
	mov Data[esi],0
	ret

num2byte endp

DrawScore proc far C uses eax esi ecx edx,hWnd
	
	invoke num2byte,score
	invoke CreateWindowEx,NULL,offset edit,offset Data,\
	WS_CHILD or WS_VISIBLE,420,38,150,15,\  ;10��10��200��30����ť�ߴ��С������ȡ�����
	hWnd,17,hInstance,NULL  ;1��ʾ�ð�ť�ľ����1 

	ret

DrawScore endp

DrawGame proc far C uses eax esi ecx edx,hWnd
	
	local @hFont:HFONT
	local @logfont:LOGFONT
	invoke RtlZeroMemory,addr @logfont,sizeof @logfont
	mov @logfont.lfCharSet,GB2312_CHARSET
	mov @logfont.lfHeight,-40
	invoke CreateFontIndirect,addr @logfont
	mov @hFont,eax

	mov i,0
	jmp L2
L1:
	mov eax,i
	add eax,1
	mov i,eax
L2:
	cmp i,4
	jge L7
L3:
	mov j,0
	jmp L5
L4:
	mov eax,j
	add eax,1
	mov j,eax
L5:
	cmp j,4
	jge L1
L6:
	imul eax,i,100
	add eax,140
	imul ecx,j,100
	add ecx,100
	imul edx,i,4
	add edx,j
	invoke num2byte,dword ptr gameMat[edx*4]
	.IF Data[0] =='0'
		invoke CreateWindowEx,NULL,offset button,offset showButton,\
		WS_CHILD or WS_VISIBLE OR WS_BORDER,ecx,eax,100,100,\  ;10��10��200��30����ť�ߴ��С������ȡ�����
		hWnd,edx,hInstance,NULL  ;1��ʾ�ð�ť�ľ����1
	.else
		invoke CreateWindowEx,NULL,offset button,offset Data,\
		WS_CHILD or WS_VISIBLE OR WS_BORDER,ecx,eax,100,100,\  ;10��10��200��30����ť�ߴ��С������ȡ�����
		hWnd,edx,hInstance,NULL  ;1��ʾ�ð�ť�ľ����1
	.endif
	imul edx,i,4
	add edx,j
	mov hGame[edx*4],eax
	invoke SendMessage,eax,WM_SETFONT,@hFont,1
	
	jmp L4
L7:
	invoke CreateWindowEx,NULL,offset edit,offset szText1,\
	WS_CHILD or WS_VISIBLE,100,60,120,15,\
	hWnd,16,hInstance,NULL
	MOV hGame[64],eax
	invoke CreateWindowEx,NULL,offset edit,offset szText2,\
	WS_CHILD or WS_VISIBLE,100,75,400,15,\
	hWnd,17,hInstance,NULL
	mov hGame[68],eax
	invoke CreateWindowEx,NULL,offset edit,offset szText5,\
	WS_CHILD or WS_VISIBLE,100,90,400,15,\
	hWnd,18,hInstance,NULL
	mov hGame[72],eax
	invoke CreateWindowEx,NULL,offset edit,offset szText3,\
	WS_CHILD or WS_VISIBLE,100,105,400,15,\
	hWnd,19,hInstance,NULL
	mov hGame[76],eax
	invoke CreateWindowEx,NULL,offset edit,offset szText4,\
	WS_CHILD or WS_VISIBLE,100,120,400,15,\
	hWnd,20,hInstance,NULL
	mov hGame[80],eax
	invoke num2byte,score
	invoke CreateWindowEx,NULL,offset edit,offset Data,\
	WS_CHILD or WS_VISIBLE,420,38,150,15,\  ;10��10��200��30����ť�ߴ��С������ȡ�����
	hWnd,21,hInstance,NULL  ;1��ʾ�ð�ť�ľ����1 
	mov hGame[84],eax

	xor eax,eax
	ret

DrawGame endp

DestoryGame proc far C uses eax esi ecx edx
	mov i,0
	mov eax,0
L1:
	mov eax,i
	mov edx,hGame[eax*4]
	invoke DestroyWindow,edx
	mov eax,i
	add eax,1
	mov i,eax
	CMP i,21
	jbe L1
    
	ret

DestoryGame endp

UpdataGame proc far C uses eax esi ecx edx,hWnd
	mov i,0
	jmp L2
L1:
	mov eax,i
	add eax,1
	mov i,eax
L2:
	cmp i,4
	jge L7
L3:
	mov j,0
	jmp L5
L4:
	mov eax,j
	add eax,1
	mov j,eax
L5:
	cmp j,4
	jge L1
L6:
	imul eax,i,100
	add eax,140
	imul ecx,j,100
	add ecx,100
	imul edx,i,4
	add edx,j
	
	invoke num2byte,dword ptr gameMat[edx*4]
	imul edx,i,4
	add edx,j
	.IF Data[0] =='0'
		INVOKE SetWindowText,hGame[edx*4],offset showButton
	.else
		INVOKE SetWindowText,hGame[edx*4],offset Data
	.endif

	JMP L4
L7:
	invoke num2byte,score
	INVOKE SetWindowText,hGame[84],offset Data
	xor eax,eax
	ret

UpdataGame endp

ReStartGame proc far C uses eax esi ecx edx
	mov ecx,16
	mov esi,0
L1:
	mov gameMat[esi*4],0
	inc esi
	loop L1
	mov gameIsEnd,0
	mov gameIsWin,0
	mov gameContinue,0
	mov score,0
	INVOKE random32,dat,max
	INVOKE random32,dat,max
	ret

ReStartGame endp
_ProcWinMain proc uses ebx edi esi,hWnd,uMsg,wParam,lParam  ;���ڹ���
	local @stPs:PAINTSTRUCT
	local @stRect:RECT
	local @hDc
	LOCAL @oldPen:HPEN
	local @hBm
	
	mov eax,uMsg  ;uMsg����Ϣ���ͣ��������WM_PAINT,WM_CREATE

	.if eax==WM_PAINT  ;������Լ����ƿͻ�����������Щ���룬����һ�δ򿪴��ڻ���ʾʲô��Ϣ
		

		invoke BeginPaint,hWnd,addr @stPs
		
		

		mov dwNow,IDM
		invoke GetDC, hWnd
		mov @hDc,eax

		invoke CreateCompatibleDC,@hDc
		mov hdcIDB_BITMAP1,eax
		
		invoke CreateCompatibleDC,@hDc
		mov hdcIDB_BITMAP2,eax

		invoke CreateCompatibleBitmap, @hDc,150,80
		mov hbmIDB_BITMAP1,eax

		invoke CreateCompatibleBitmap, @hDc,90,60
		mov hbmIDB_BITMAP2,eax

		invoke LoadBitmap,hInstance,dwNow
		mov @hBm,eax
		invoke SelectObject,hdcIDB_BITMAP1,hbmIDB_BITMAP1
		invoke CreatePatternBrush,@hBm
		push eax
		invoke SelectObject,hdcIDB_BITMAP1,eax
		invoke PatBlt,hdcIDB_BITMAP1,0,0,150,80,PATCOPY
		;invoke BitBlt,@hDc,0,0,48,48,hdcIDB_BITMAP1,0,0,SRCCOPY
		invoke DeleteObject,eax
		invoke BitBlt,@hDc,90,0,150,80,hdcIDB_BITMAP1,0,0,SRCCOPY
		
		invoke LoadBitmap,hInstance,BITMAP2
		mov @hBm,eax
		invoke SelectObject,hdcIDB_BITMAP2,hbmIDB_BITMAP2
		invoke CreatePatternBrush,@hBm
		push eax
		invoke SelectObject,hdcIDB_BITMAP2,eax
		invoke PatBlt,hdcIDB_BITMAP2,0,0,90,60,PATCOPY
		;invoke BitBlt,@hDc,0,0,48,48,hdcIDB_BITMAP1,0,0,SRCCOPY
		invoke DeleteObject,eax
		invoke BitBlt,@hDc,310,15,90,60,hdcIDB_BITMAP2,0,0,SRCCOPY
		invoke ReleaseDC,hWnd,@hDc

		invoke EndPaint,hWnd,addr @stPs
	
	.elseif eax==WM_CLOSE  ;���ڹر���Ϣ
		invoke DestroyWindow,hWinMain
		invoke PostQuitMessage,NULL

	.elseif eax==WM_CREATE  ;��������  ��������ʾ����һ����ť������button�ַ���ֵ��'button'�������ݶζ��壬��ʾҪ��������һ����ť��showButton��ʾ�ð�ť�ϵ���ʾ��Ϣ
		
		invoke DrawGame,hWnd

	.elseif eax== WM_CHAR
		MOV edx,wParam
		.if edx == 'W'
			
			invoke moveW
			.IF changedW == 1
				invoke random32,dat,max
			.endif
			INVOKE getscore
			;INVOKE DestoryGame
			INVOKE UpdataGame,hWnd
		.elseif edx == 'S'
			invoke moveS
			
			.IF changedS == 1
				invoke random32,dat,max
			.endif
			INVOKE getscore
			;INVOKE DestoryGame
			INVOKE UpdataGame,hWnd
		.elseif edx =='A'
			
			invoke moveA
			
			.IF changedA == 1
				invoke random32,dat,max
			.endif
			INVOKE getscore
			;INVOKE DestoryGame
			INVOKE UpdataGame,hWnd
		.elseif edx == 'D'

			invoke moveD
			
			.IF changedD == 1
				invoke random32,dat,max
			.endif
			INVOKE getscore
			;INVOKE DestoryGame
			INVOKE UpdataGame,hWnd
		.elseif edx =='J'
			mov gameIsEnd,1
		.endif

		.if gameContinue == 0
			.if gameIsWin == 1
				invoke gameWin
			.endif
		.endif
		invoke gameEnd
		.if gameIsEnd == 1
			invoke MessageBox,hWinMain,offset szText7,offset szText6,MB_OK
			.if eax == IDOK
				invoke ReStartGame
				INVOKE UpdataGame,hWnd
			.endif
		.endif

	;----------------------
	;��Ȼ���ⲿ�����Լ���ӵ���Ӧ�����¼��Ĵ��룬�����ĳ����ť������ð�ť�ᷢ��ʲô�µȡ�
	;������������Ϣ������WM_CREATE�������ڴ���ʱ��WM_COMMAND��ʾ�����ťʱ,��������ӷ�֧����д��Ӧ�Ĵ����¼��Ĵ���
	;----------------------

	.else  ;����Ĭ�ϴ�����������Ϣ
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.endif

	xor eax,eax
	ret
_ProcWinMain endp

_WinMain proc  ;���ڳ���
	local @stWndClass:WNDCLASSEX  ;������һ���ṹ����������������WNDCLASSEX��һ�������ඨ���˴��ڵ�һЩ��Ҫ���ԣ�ͼ�꣬��꣬����ɫ�ȣ���Щ�������ǵ������ݣ����Ƿ�װ��WNDCLASSEX�д��ݵġ�
	local @stMsg:MSG	;��������stMsg��������MSG����������Ϣ���ݵ�	

	invoke GetModuleHandle,NULL  ;�õ�Ӧ�ó���ľ�����Ѹþ����ֵ����hInstance�У������ʲô���򵥵�������ĳ������ı�ʶ�����ļ���������ھ��������ͨ������ҵ���Ӧ������
	mov hInstance,eax

	invoke RtlZeroMemory,addr @stWndClass,sizeof @stWndClass  ;��stWndClass��ʼ��ȫ0

	;ע�ᴰ����
	invoke LoadCursor,0,IDC_ARROW
	mov @stWndClass.hCursor,eax					;---------------------------------------
	push hInstance							;
	pop @stWndClass.hInstance					;
	mov @stWndClass.cbSize,sizeof WNDCLASSEX			;�ⲿ���ǳ�ʼ��stWndClass�ṹ�и��ֶε�ֵ�������ڵĸ�������
	mov @stWndClass.style,CS_HREDRAW or CS_VREDRAW			;���ŵĻ����ⲿ��ֱ��copy- -������Ϊ�˸ϻ����ҵ��ûʱ������
	mov @stWndClass.lpfnWndProc,offset _ProcWinMain			;
	;�������������ʵ����ָ���˸ô��ڳ���Ĵ��ڹ�����_ProcWinMain	;
	mov @stWndClass.hbrBackground,COLOR_WINDOW+1			;
	mov @stWndClass.lpszClassName,offset szClassName		;---------------------------------------
	invoke RegisterClassEx,addr @stWndClass  ;ע�ᴰ���࣬ע��ǰ����д����WNDCLASSEX�ṹ

	invoke CreateWindowEx,WS_EX_CLIENTEDGE,\  ;��������
			offset szClassName,offset szCaptionMain,\  ;szClassName��szCaptionMain���ڳ������ж�����ַ�������
			WS_OVERLAPPEDWINDOW,400,200,600,600,\	;szClassName�ǽ�������ʹ�õ������ַ���ָ�룬������'MyClass'����ʾ��'MyClass'��������������ڣ��������ӵ��'MyClass'����������
			NULL,NULL,hInstance,NULL		;����ĳ�'button'��ô�����Ľ���һ����ť��szCaptionMain��������Ǵ��ڵ����ƣ������ƻ���ʾ�ڱ�������
	mov hWinMain,eax  ;�������ں��������eax�У����ڰѾ������hWinMain�С�
	invoke ShowWindow,hWinMain,SW_SHOWNORMAL  ;��ʾ���ڣ�ע�⵽����������ݵĲ����Ǵ��ڵľ��������ǰ����˵�ģ�ͨ����������ҵ�������ʶ������
	invoke UpdateWindow,hWinMain  ;ˢ�´��ڿͻ���

	.while TRUE  ;�������޵���Ϣ��ȡ�ʹ����ѭ��
		invoke GetMessage,addr @stMsg,NULL,0,0  ;����Ϣ������ȡ����һ����Ϣ������stMsg�ṹ��
		.break .if eax==0  ;������˳���Ϣ��eax�����ó�0���˳�ѭ��
		invoke TranslateMessage,addr @stMsg  ;���ǰѻ��ڼ���ɨ����İ�����Ϣת���ɶ�Ӧ��ASCII�룬�����Ϣ����ͨ����������ģ��ⲽ������
		invoke DispatchMessage,addr @stMsg  ;���������������ҵ��ô��ڳ���Ĵ��ڹ��̣�ͨ���ô��ڹ�����������Ϣ
	.endw
	ret
_WinMain endp

main proc
	;invoke num2byte,score
	INVOKE random32,dat,max
	INVOKE random32,dat,max
	call _WinMain  ;������͵����˴��ڳ���ͽ���������������
	invoke ExitProcess,NULL
	ret
main endp
end main
