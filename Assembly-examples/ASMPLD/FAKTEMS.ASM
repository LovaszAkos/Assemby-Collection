code	segment para	public	'code'

assume cs:code, ds:code, es:nothing, ss:nothing

	.486
;
versio	equ	 100			; Verzi�sz�m (1.00)
;
kiisec	equ	3 * 18			; Ki�rat�s 3 m�sodpercenk�nt
;
hndnum	macro
	hndver	%versio
	endm

vernum	macro
	defver	%versio
	endm

hndver	macro	vnum
	irpc	x,vnum
	db	'&x&'
	endm
	endm

defver	macro	vnum
num	=	0
	irpc	x,vnum
	db	'&x&'
	if	num eq 0
	db	'.'
	endif
num	=	num+1
	endm
	endm

;
	org	80h

counte	db	?			; A sz�ml�l� by�jt
	db	?			; A hat�rol� helye
parsor	db	126 dup(?)		; A parancssor b�jtjai

	org	100h
start:
	mov	ah,34h			; Aktivit�s k�rd�se
	int	21h			; DOS h�v�s
	mov	[dosakt],bx		; IT. offszet
	mov	[dosakt + 2],es 	; IT. szegmens
	mov	dx,offset connam	; A CON neve
	mov	ax,3d01h		; Megnyitjuk �r�sra
	int	21h			; DOS h�v�s
	mov	[handco],ax		; A CON f�jlsz�ma
;
; Az IT. vektorok kit�lt�se
;
	mov	ax,3508h		; IT. vektor tartalom lek�rdez�s
	int	21h			; DOS h�v�s
	mov	[int08c],bx		; IT. offszet
	mov	[int08c + 2],es 	; IT. szegmens
	mov	ax,3523h		; IT. vektor tartalom lek�rdez�s
	int	21h			; DOS h�v�s
	mov	[int23c],bx		; IT. offszet
	mov	[int23c + 2],es 	; IT. szegmens
;
; IT. vektor �tir�ny�t�sa
;
	mov	dx,offset int08r	; Ide mutasson
	cli				; IT. tilt�s
	mov	ax,2508h		; IT. vektor tartalom m�dos�t�s
	int	21h			; DOS h�v�s
	mov	dx,offset int23r	; Ide mutasson
	mov	ax,2523h		; IT. vektor tartalom m�dos�t�s
	int	21h			; DOS h�v�s
	sti				; IT. enged�ly
	cld				; El�refele csin�lja
	mov	cl,[counte]		; CL <- darabsz�m
	mov	ch,0			; CX <- darabsz�m
	cmp	cx,2			; Ennyi van legal�bb?
	jb	short helple		; Ha nincs parancssor, help
	xor	ebp,ebp 		; Itt fogom gy�jteni
	mov	ebx,10			; Ezzel szorozgatok
	mov	si, offset parsor	; Innen olvasok be
	dec	cx			; A hat�rol� levonva
;
; Beolvasom a parancsssor karakter�t
;
beolci:
	lodsb				; AL <- parancssor karakter
;
; Ellen�rz�m, hogy sz�mjegy ASCII karakter-e
;
	cmp	al,'0'                  ; Enn�l kisebb?
	jb	short helple		; Igen ez hiba
	cmp	al,'9'                  ; Enn�l nagyobb?
	jbe	short karoke		; Nem, akkor megfelel
;
; Vagy nincs param�ter, vagy nem j�, vagy t�l nagy az �rt�k
;
helple:
	mov	dx,offset helpsz	; A help sz�veg c�me
	mov	cl,1			; Hibak�d
	mov	ah,9			; A ki�rat�s k�dja
	jmp	short kilhib		; Hib�val kil�pek
;
; Vagy nincs param�ter, vagy nem j�, vagy t�l nagy az �rt�k
;
helpna:
	mov	dx,offset nagysz	; A t�l nagy sz�veg c�me
	mov	cl,2			; Hibak�d
kilhib:
	push	dx			; Elrontan�
	call	kiioff			; Kikapcsolom a sz�vegeket
	pop	dx			; Vissza a sz�vegc�m
	mov	ah,9			; A ki�rat�s k�dja
	int	21h			; Ki�rat�s a DOS-sal
kiloke:

	call	helyre			; Visszaadom ami nem az eny�m
	mov	al,cl			; Kil�p�si k�d
	mov	ah,4ch			; Kil�p�s DOS-ba k�dja
	int	21h			; DOS h�v�s kil�p�sre
;
; �talak�tom az ASCII karaktert numerikuss�
;
karoke:
	and	eax,0fh 		; Csak a sz�m �rt�ke maradjon
;
; Az eddig t�rolt �rt�ket megszorzom 10-el, majd hozz�adom a sz�mot
;
	xchg	ebp,eax 		; AX <- szorzand�, BP <- sz�mjegy
	mul	ebx			; Megszorzom 10-el
	jc	short helpna		; T�l nagy lett
	add	ebp,eax 		; �sszeadom a beolvasottal
	jc	short helpna		; T�l nagy lett
	loop	beolci			; Beolvas� ciklus
;
; Megn�zem, hogy van-e EMS
;
	mov	dx,offset emmszo	; Ezt a file-t nyitjuk
	mov	ax,3d00h		; Megnyitjuk olvas�sra
	int	21h			; DOS h�v�s
	jc	short hibemm		; Ha nincs, ki�rjuk
	mov	bx,ax			; File-sz�m �tpakol�s
	mov	ax,4400h		; IOCTL h�v�s k�dja
	int	21h			; DOS h�v�s
	test	dl,80h			; Eszk�z ?
	je	short hibemm		; Ez file, nincs EMS
	mov	ax,4407h		; IOCTL h�v�s k�dja
	int	21h			; DOS h�v�s
	or	al,al			; Van EMS ?
	je	short hibemm		; Nincs EMS
	mov	ah,3eh			; CLOSE k�dja
	int	21h			; DOS h�v�s
	mov	ah,46h			; EMS verzi� k�rd�s
	int	67h			; EMS h�v�s
	or	ah,ah			; Sikeres a h�v�s ?
	jne	short hibemm		; Hib�s, nincs EMS
	cmp	al,32h			; BCD 3.2 verzi�
	jae	short emmoke		; Hib�s, nincs EMS
hibemm:
	mov	dx,offset emsros	; Hib�s EMS sz�veg c�me
	mov	cl,3			; Hibak�d
	jmp	kilhib			; Mehet a hibaki�r�s
;
; Beolvasom a haszn�lhat� m�retet
;
emmoke:
	mov	si,ax			; Eltessz�k a verzi�t
	mov	ah,42h			; M�retlek�rdez�s k�dja
	int	67h			; EMS h�v�s
	or	ah,ah			; Sikeres volt a h�v�s ?
	jne	hibemm			; Ha nem sikeres a h�v�s
;
; A m�retet lefoglalom magamnak
;
	and	ebx,0fffch		; �gy 64K-s darabok lesznek
	je	short hibemm		; Ha nincs marad�k
	mov	[darmar],ebx		; A m�retet elt�rolom
	mov	ah,43h			; Szegmens open k�dja
	int	67h			; EMS h�v�s
	or	ah,ah			; Sikeres volt a h�v�s ?
	jne	short hibemm		; Ha nem sikeres a h�v�s
	mov	[hndems],dx		; Elpakoljuk a file-sz�mot
	cmp	si,40h			; Van 4.0 legal�bb ?
	jb	short ninanv		; Nincs
	mov	si,offset fakemh	; � a tulajdonos
	mov	ax,5301h		; Tulajdonos be�ll�t�s k�dja
	int	67h			; Tulajdonos k�rd�s
	or	ah,ah			; Sikeres volt a h�v�s ?
	jne	short hibemm		; Ha nem sikeres a h�v�s
ninanv:
	mov	ah,41h			; Szegmensk�r�s k�dja
	int	67h			; EMS h�v�s
	or	ah,ah			; Sikeres volt a h�v�s ?
	jne	short hibemm		; Ha nem sikeres a h�v�s
	mov	es,bx			; Ez az adatr�sz�
sivata:
	mov	ebx,[darmar]		; A m�ret 16K-s lapokban
	and	ebx,0ffffh		; A fels� r�sz t�rl�se
	shl	ebx,12			; A hossz 4 b�jtosan
	mov	[darmar],ebx		; Eltettem a m�retet
	mov	eax,ebx 		; Ez a hossz m�solata
;
; Kisz�m�tom a hat�rt, azaz elosztom  (ln 16) / (ln 10) = (log 16)
; �rt�k�vel. Legfeljebb eddig terjedhet a szorzat.
; Ezt 25000/30103 �rt�ke (1.20412) k�zel�ti.
;
	mov	edi,25000		; Ennyivel szorzom
	mul	edi			; Megszoroztam (EDX:EAX)
	mov	edi,30103		; Ennyivel osztom
	div	edi			; EAX-ben a maxim�lis szorzat
	mov	ecx,eax 		; Darabsz�m maximum
;
; K�sz a param�ter beolvas�sa, sz�vegkezdet
;
	xor	ebx,ebx 		; Kezd��rt�k
	mov	[hatter],ebx		; Kezdetben
	mov	byte ptr [consti],0	; Sz�ml�l�
	mov	[teelis],offset faktke	; Ez a k�vetkez� feladat

;
; 1-re �ll�tom az eredm�nyter�letet (0! �s 1! �rt�ke)
;
	xor	edi,edi 		; Az eredm�ny kezd�c�me
	mov	ebx,[darmar]		; Ez a darab 4 b�jtosan
tertor:
	call	edibea			; Be�ll�tom az oldal lek�pz�st
megtar:
	xor	eax,eax 		; Ezt teszem ki a ciklusban
	mov	cx,16384		; Ennyiszer 4 b�jt a 64K
	rep	stosd			; Kitettem az 0-t
	add	edi,10000h		; Eltoltam
	sub	ebx,16384		; Sz�ml�l� cs�kkent�se
	jnz	short tertor		; A t�bbit null�zom
	dec	edi			; Lecs�kkentem
	mov	[tblcim],edi		; A v�gc�m offszetje
	xor	edi,edi 		; Itt lesz az eleje
	call	edibea			; Be�ll�tom az oldal lek�pz�st
	mov	al,1			; AL <- 1
	mov	es:[di],al		; Kitettem az 1-et
	mov	[hatcim],edi		; A nem nulla offszetje
;
; Indul a sz�m�t�s
; Input:  EBP
; Output: Eredm�nyter�let az EMS mem�ri�ban
;
	mov	edi,1			; Ezzel kezdem
nitucs:
	cmp	ebp,edi 		; Enn�l kisebb?
	jbe	short kesvan		; Nem, k�sz is az eredm�ny
;
; Az eredm�nyt�rol�t, meg kell szorozni a k�vetkez�vel
;
	inc	edi			; Ezzel fog szorozni
	mov	[hatter],edi		; Hogy a h�tt�r is boldoguljon
	xor	esi,esi 		; SI <- eredm�nyt�rol� c�me
	call	esibea			; Be�ll�tom az oldal lek�pz�st
;
; Az els� �rt�k c�m�nek �s "el�zm�ny�nek" be�ll�t�sa
;
	xor	edx,edx 		; Ezt teszem majd a hely�re
;
; Mehet a szorz�s ciklusa
;
meneve:
	xchg	es:[si],edx		; Hely�re az eredm�ny
	mov	eax,edx 		; EAX <- k�vetkez� szorzand�
szorel:
	mul	edi			; EDX:EAX <- EAX * EDI
;
; G�rgetem az eredm�nyt az alacsonyabb helyi�rt�kekre
;
	add	es:[si],eax		; Kiteszem a szorzat L r�sz�t
	adc	edx,0			; CY �tvitel
;
; A tov�bbi �rt�kek m�r ezzel futnak le. Megn�zem, hogy
; kell-e egy�ltal�n tov�bb szorozgatni. (nem null�t kellene-e
; szorozgatni �rtelmetlen�l, hossz� ciklusban.) Ha nulla, v�ge a
; szorozgat�snak, azaz ciklusv�g
;
szorci:
	or	edx,edx 		; Nulla lenne?
	jnz	short szorto		; Nem, mehet tov�bb
	cmp	[hatcim],esi		; El�rte a null�kat?
	jz	short nitucs		; Igen, kil�pek a ciklusb�l
;
; Nem nulla amit szorozni kell, l�pek a k�vetkez� c�mre
;
szorto:
	add	esi,4			; �tl�pem az aktu�list
;
; Az �j nagyobb mint az eddigi szorz�s hat�ra?
;
	cmp	[hatcim],esi		; El�rte a v�g�t?
	jae	short nemmod		; Most nem kell m�dos�tani
;
; Igen, akkor ez az �j hat�r
;
	mov	[hatcim],esi		; A nem nulla offszetje
	dec	ecx			; �j hat�r sz�letett
	js	short elfhel		; M�r el is fogyott
;
; Az �j c�m m�g el�rhet� sz�momra?
;
nemmod:
	or	si,si			; A c�m be�ll�t�s kell?
	jnz	short meneve		; Nem, m�g nem kell
	call	esibea			; Be�ll�tom az oldal lek�pz�st
	jmp	short meneve		; M�g nem �rt a v�g�re, szorz�s
;
; Megn�zem, hogy van-e gond a darabsz�mmal
;
kesvan:
	add	ecx,-2			; Az elej�n r�gt�n 1 van + hely
	jns	short marhel		; Maradt m�g hely
;
; Bizony elfogyott a hely
;
elfhel:
	mov	dx,offset dekbaj	; A t�l nagy sz�veg c�me
	mov	cl,3			; Hibak�d
	jmp	kilhib			; Hibaki�rat�s
;
; Az eredm�nyter�leten tal�lhat� bin�ris �rt�k 10-es sz�mrendszerbe
;
marhel:
	call	kiioff			; Kikapcsolom a sz�vegeket
	cmp	byte ptr [kiivol],0	; Volt ki�r�s jelz�s?
	jz	short kiikih		; Nem volt, �n sem �rok ki
	mov	bx,offset faktbe	; Sz�vegki�rat�s c�me
	call	conras			; CON-ra kiteszem a sz�veget
kiikih:
	xor	edi,edi 		; Ennyi az elt�rolt karaktersz�m
	mov	[hatter],edi		; Kezdetben
	mov	[elosmp],di		; Kezdetben
	mov	ebx,10			; Ennyivel osztogatok majd
	mov	[consti],bh		; Sz�ml�l�
	mov	[teelis],offset dekrin	; Ez a k�vetkez� feladat
kellme:
	xor	edx,edx 		; Ez a H r�sz els�nek
	xor	ebp,ebp 		; Nulla jelz�
	mov	esi,[hatcim]		; Az eredm�nyt�rol� c�me
	call	esibea			; Be�ll�tom az oldal lek�pz�st
	jmp	short elfert		; Kezdje az ellen�rz�st
;
; Megkeresem a nem nulla els� �rt�ket
;
modtta:
	add	esi,-4			; Visszal�pek, ez az utols� elem
	cmp	si,0fffch		; El�rt a k�vetkez�re?
	jnz	short rafert		; Nem kell �j lek�pz�s
	call	esibea			; Be�ll�tom az oldal lek�pz�st
rafert:
	mov	[hatcim],esi		; A kisebb c�m offszetje
elfert:
	or	es:[si],ebp		; Nulla?
	jz	modtta			; Igen, akkor nem osztogatom

;
; Indul a ter�let oszt�sa 10-el
;
egyosz:
	mov	eax,es:[si]		; Az osztand�
	div	ebx			; Elosztom, EAX <- h�nyados
	mov	es:[si],eax		; H�nyados a hely�re
	or	ebp,eax 		; Nulla vizsg�lat is
	or	esi,esi 		; El�rte az elej�t?
	jz	short oszveg		; Igen, k�sz az oszt�s
simdes:
	add	esi,-4			; Visszafele egyet (4 b�jtot)
	cmp	si,0fffch		; Az alja nulla volt?
	jnz	short egyosz		; M�g nem m�dosul a szegmens
	call	esibea			; Be�ll�tom az oldal lek�pz�st
	jmp	short egyosz		; Elosztom minden elem�t
;
; Megvan a marad�k, �s a h�nyados is, egy f�l b�jtba pakolom
;
oszveg:
	mov	si,[tcimta]		; Itt van a t�rol�si c�m
	test	di,1			; Ez a sz�ml�l�
	jz	short legals		; Ez az els�
	shl	dl,4			; L�ptetem feljebb
	or	[si],dl 		; R�m�solom az el�z�eket
	cmp	si,offset lapcim	; N�veltem
	jnz	short demeve		; Nincs gond
	call	kimake			; Kim�solom a szegmenset
	jnz	elfhel			; Elfogyott a hely
	mov	si,offset lapcim + 16384; Itt folytassa
demeve:
	dec	si			; El�z� c�mre
	mov	[tcimta],si		; Itt van az �j c�m
	jmp	short nemgot		; Mehet a sz�ml�l�s, kit�ve
legals:
	mov	[si],dl 		; Elmentem a marad�kot
nemgot:
	inc	edi			; No meg sz�molom is
	mov	[hatter],edi		; A sz�ml�l� m�solata
	or	ebp,ebp 		; Kell m�g osztani?
	jnz	kellme			; M�g van mit, a h�nyados nem 0
	call	kimake			; Kim�solom az utols� szegmenset
	sub	[tcimta],offset lapcim	; Eddig �rta tele
	call	kiioff			; Kikapcsolom a ki�rat�st
;
; A h�nyados nulla lett, j�het a ki�rat�s
;
sturic:
	mov	si,offset lapcim	; Ide dek�doljon
	call	bemake			; Bem�solom az aktu�list
	mov	ebp,edi 		; Darabsz�m m�solat
	mov	di,[tcimta]		; Itt van a dek�dolt tartalom
	test	bp,1			; P�ratlan?
	jnz	short nempar		; Kiteszem
	inc	di			; K�vetkez�
kezcim:
	test	di,3fffh		; Itt folytatassa?
	jnz	short kezpvi		; Mehet, nincs szegmens v�lt�s
	call	bemake			; Bem�solom az aktu�list
	xor	di,di			; Elej�r�l
kezpvi:
	mov	al,es:[di]		; Vissza a 2 sz�mjegy
	shr	al,4			; Alulra a magas �rt�k
	and	al,0fh			; Csak a sz�mjegy maradjon
	or	al,'0'                  ; Karakterr� konvert�lom
	mov	[si],al 		; Kiteszem a karaktert
	inc	si			; Kitettem, h�t n�velem
	dec	ebp			; Egyet kitettem
nempar:
	mov	al,es:[di]		; Vissza a 2 sz�mjegy
	inc	di			; Megn�velem, mert dek�doltam
	and	al,0fh			; Csak a sz�mjegy maradjon
	or	al,'0'                  ; Karakterr� konvert�lom
	mov	[si],al 		; Kiteszem a karaktert
	inc	si			; Kitettem, h�t n�velem
	cmp	si,offset lapcim + 16383; Itt folytassa
	jb	short darano		; Nem, sz�ml�lok tov�bb
	call	stdowr			; Ki�rok
darano:
	dec	ebp			; Sz�ml�l�t cs�kkentem
	jnz	short kezcim		; Kiteszem a karaktereket
	call	stdowr			; Ki�rok
;
; K�sz a ki�r�s, kil�pek
;
	mov	cl,0			; Sikeres jelz�ssel l�pek ki
	jmp	kiloke			; Sikeresen kil�pek
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	A karakteres ter�let ki�rat�sa			;
;	a STANDARD OUTPUT-ra.				;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
stdowr:
	mov	dx,offset lapcim	; Az elej�t�l
	mov	cx,si			; Ez a m�r meg�rt c�m
	sub	cx,dx			; CX <- darabsz�m
	jcxz	nimiki			; Nincs mit kivinni
	mov	bx,1			; A standrd outputba
	mov	ah,40h			; DOS ki�rat�s f�jlba k�dja
	int	21h			; Ki�rat�s k�r�s
	mov	si,offset lapcim	; Az elej�t�l
nimiki:
	ret				; K�sz a ki�rat�s
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	64K lek�pz�se EDI szerint.			;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
edibea:
	push	edi			; Elrontan�m
	shr	edi,16			; Ez a 64K sorsz�ma
	shl	di,2			; Ez a 16K sorsz�ma
	cmp	[aktlek],di		; Ez van �ppen lek�pezve?
	jz	short akvaed		; Igen, �ppen ez van
	mov	[aktlek],di		; Ez lesz lek�pezve
	push	cx			; Elrontan�m
	push	bx			; Elrontan�m
	mov	cx,4			; Ennyiszer kell
lekmad:
	mov	ax,cx			; AL <- lapsz�m + 1
	dec	ax			; AL <- lapsz�m
	mov	bx,di			; Ez a lek�pzend� lapsz�m
	mov	ah,44h			; MAP k�dja
	mov	dx,[hndems]		; Ez a file-sz�m
	int	67h			; EMS h�v�s
	inc	di			; A k�vetkez� lap
	loop	lekmad			; Ha t�bb lapot kell lek�pezni
	pop	bx			; Vissza a lapsz�m t�rol�ja
	pop	cx			; Vissza a sz�ml�l�
akvaed:
	pop	edi			; Vissza a c�m
	ret				; Visszat�r�s
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	64K lek�pz�se ESI szerint.			;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
esibea:
	push	esi			; Elrontan�m
	shr	esi,16			; Ez a 64K sorsz�ma
	shl	si,2			; Ez a 16K sorsz�ma
	cmp	[aktlek],si		; Ez van �ppen lek�pezve?
	jz	short akvaep		; Igen, �ppen ez van
	mov	[aktlek],si		; Ez lesz lek�pezve
	push	cx			; Elrontan�m
	push	bx			; Elrontan�m
	push	dx			; Elrontan�m
	mov	cx,4			; Ennyiszer kell
lekmas:
	mov	ax,cx			; AL <- lapsz�m + 1
	dec	ax			; AL <- lapsz�m
	mov	bx,si			; Ez a lek�pzend� lapsz�m
	mov	ah,44h			; MAP k�dja
	mov	dx,[hndems]		; Ez a file-sz�m
	int	67h			; EMS h�v�s
	inc	si			; A k�vetkez� lap
	loop	lekmas			; Ha t�bb lapot kell lek�pezni
	pop	dx			; Vissza a lapsz�m t�rol�ja
	pop	bx			; Vissza a lapsz�m t�rol�ja
	pop	cx			; Vissza a sz�ml�l�
akvaep:
	pop	esi			; Vissza a c�m
	ret				; Visszat�r�s
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	A 16K-s lap kim�sol�sa az EMS-be.		;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
kimake:
	push	cx			; Elrontan�m
	push	ebx			; Elrontan�m
	push	esi			; Elrontan�m
	push	edi			; Elrontan�m
	mov	ah,47h			; Save k�dja
	mov	dx,[hndems]		; Ez a file-sz�m
	int	67h			; EMS h�v�s
	mov	ebx,[tblcim]		; Ez a c�me az eredm�nynek
	shr	ebx,14			; �gy lapc�m lett bel�le
	mov	ax,4400h		; A legals� lapra m�solom
	int	67h			; EMS h�v�s
	xor	di,di			; A c�lter�let az 1. 16K
	xor	eax,eax 		; Ezt vizsg�lom
	mov	cx,4096 		; Ennyi lapb�l �ll
	repe	scasd			; Mind nulla?
	jnz	short bajmas		; Nem mind nulla
	mov	si,offset lapcim	; A m�soland� ter�let eleje
	xor	di,di			; A c�lter�let az 1. 16K
	mov	cx,4096 		; 16K 4 b�jtosan
	rep	movsd			; Duplaszavas m�sol�s
	sub	dword ptr [tblcim],16384; El�z� lap c�me
	mov	ah,48h			; Vissza�ll�t�s
	int	67h			; EMS h�v�s
	or	ah,ah			; St�tusz be�ll�t�s
bajmas:
	pop	edi			; Vissza a m�sol�s ut�n
	pop	esi			; Vissza a m�sol�s ut�n
	pop	ebx			; Vissza a m�sol�s ut�n
	pop	cx			; Vissza a m�sol�s ut�n
	ret				; M�solat
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	A 16K-s lek�pz�se.				;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bemake:
	push	ebx			; Elrontan�m
	add	dword ptr [tblcim],16384; El�z� lap c�me
	mov	ebx,[tblcim]		; Ez a c�me az eredm�nynek
	shr	ebx,14			; �gy lapc�m lett bel�le
	mov	ax,4400h		; A legals� lapra m�solom
	mov	dx,[hndems]		; Ez a file-sz�m
	int	67h			; EMS h�v�s
	pop	ebx			; Vissza a m�sol�s ut�n
simare:
	ret				; M�solat
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	Ki�rat�si teend� kikapcsol�sa.			;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
kiioff:
	mov	bx, offset simare	; K�sz vagyok
	xchg	[teelis],bx		; Nincs feladat
	cmp	byte ptr [kiivol],0	; Volt ki�r�s jelz�s?
	jz	short megnek		; Nem, akkor nem csin�lok semmit
	call	bx			; Az eredeti feladatot megh�vom
	mov	bx,offset crlfco	; CR LF ki�rat�s
	call	conras			; CON-ra kiteszem a sz�veget
megnek:
	ret				; K�sz a ki�rat�s kikapcsol�s
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	Teend� els� l�p�s dek�dol�s alatt.		;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dekrin:
	mov	bx,offset dekszo	; Sz�vegc�m
	jmp	short szofol		; Folytassuk ugyan �gy
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	Teend� els� l�p�s faktori�lissz�m�t�s alatt.	;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
faktke:
	mov	bx,offset faktin	; Sz�vegc�m
szofol:
	mov	byte ptr [kiivol],1	; Volt ki�r�s jelz�s
	call	conras			; CON-ra kiteszem a sz�veget
	mov	[teelis],offset faktko	; Ez a k�vetkez� feladat
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	V�ltoz� ki�rat�sa faktori�lis sz�m�t�s alatt.	;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
faktko:
	mov	bx,offset bckspa	; Karakter a visszal�p�shez
	mov	cl,[consti]		; Sz�ml�l�
	mov	ch,0			; H r�sz t�rl�s
	sub	bx,cx			; A kezd�c�m visszafele
	call	conras			; Visszal�pkedek
	xor	cx,cx			; Kezd� darabsz�m
	mov	eax,[hatter]		; Ezt kell k�ratni
	mov	ebx,10			; Ennyivel osztok
megosz:
	xor	edx,edx 		; A H r�sze
	div	ebx			; Elosztom 10-el
	or	dl,'0'                  ; Karakterr� a marad�k
	push	dx			; Elmentem a karaktert
	inc	cx			; Sz�ml�l�val k�vetem
	or	eax,eax 		; Kell m�g
	jnz	megosz			; M�g osztani kell
	mov	[consti],cl		; Sz�ml�l�
megkar:
	mov	dx,sp			; Karakter
	push	cx			; A sz�ml�l� k�s�bbre
	mov	cx,1			; Csak egyet
	call	conwri			; Kitettem
	pop	cx			; Vissza a sz�ml�l�
	pop	dx			; A ki�rt ki�r�t�se
	loop	megkar			; Ki a t�bbi is
	ret				; K�sz
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	A BX kit�tele a CON-ra. 			;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
conras:
	mov	dx,bx			; Itt fog kezdeni
kivaci:
	cmp	byte ptr [bx],0 	; V�gjel ?
	jz	short conraw		; Igen, megvan
	inc	bx			; Megyek a c�men
	jmp	short kivaci		; Keressen tov�bb
conraw:
	mov	cx,bx			; A v�gc�m
	sub	cx,dx			; CX <- darabsz�m
conwri:
	mov	bx,[handco]		; Ez a CON f�jlsz�m
	mov	ah,40h			; Ki�r�s f�jlba k�dja
	int	21h			; A DOS-sal ki�r�sm a k�perny�re
	ret				; K�sz a ki�r�s
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	A timer IT. k�dr�sze.				;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
int08r:
	pushf				; �gy IT. szer� lesz bel�le
	call	dword ptr cs:[int08c]	; Ez az eredeti feladat
	sti				; IT. j�het
;
; A sz�ml�l� n�vel�se
;
	inc	word ptr cs:[elosmp]	; N�velem a sz�ml�l�t
;
; Ki�r�si hat�r vizsg�lat
;
	cmp	word ptr cs:[elosmp],kiisec; El�rte?
	jnz	short donect		; Nem most m�g v�runk
;
; Lehetne ki�rni, szabad a DOS
;
	push	es			; DOS foglalts�gvizsg�lat miatt
	push	ebx			; DOS foglalts�gvizsg�lat miatt
	les	bx,dword ptr cs:[dosakt]; Aktivit�s FLAG
	cmp	byte ptr es:[bx],0	; Szabad a DOS?
	jz	short dossza		; Igen, szabad
;
; Nem szabad, visszakorrig�lok, hogy legk�zelebbi IT.-n�l ki�rhasson
;
	dec	word ptr cs:[elosmp]	; Vissza, hogy bek�vetkezzen
	jmp	short donesz		; Mehet tov�bb
dossza:
	push	ds			; Ez romlik
	push	eax			; Ebbe teszem a H sz�t
	push	ecx			; Ez is romlik
	push	edx			; Ez is romlik
	mov	ax,cs			; Szegmenslap
	mov	ds,ax			; Kit�ltve
	call	word ptr [teelis]	; Teend�
	mov	word ptr [elosmp],0	; Kezdje el�r�l
	pop	edx			; Regiszter vissza
	pop	ecx			; Regiszter vissza
	pop	eax			; Regiszter vissza
	pop	ds			; Szegmensregiszter vissza
donesz:
	pop	ebx			; Regiszter vissza
	pop	es			; Szegmensregiszter vissza
donect:
	iret				; K�sz vagyok
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	CNTRL BREAK reag�l�s.				;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
int23r:
	push	ds			; Elromlik
	push	es			; Elromlik
	pusha				; Mentegetek
	mov	ax,cs			; Szegmenslap
	mov	ds,ax			; Kit�ltve
	call	helyre			; Mindent �ll�tsunk helyre
	popa				; Vissza
	pop	es			; Szegmens vissza
	pop	ds			; Szegmens vissza
	stc				; Ki kell l�pni jelz�s
	retf				; Visszat�r�s jelz�ssel
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	Helyre�ll�tom a v�ltoztat�sokat.		;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
helyre:
	mov	dx,[hndems]		; Ez a file-sz�m
	or	dx,dx			; Ez �l�?
	jz	short nefoem		; Nem, nincs foglalva
	mov	ah,45h			; Visszad�s k�dja
	int	67h			; EMS h�v�s
nefoem:
	xor	ax,ax			; AX <- vektorok szegmense
	mov	es,ax			; ES <- vektorter�let
	mov	ax,cs			; Ez a szegmensem
nemazv:
	sti				; M�r lehet IT.
	nop				; Itt j�het az IT.
	cli				; IT. nem lehet
	cmp	word ptr es:[8 * 4],offset int08r ; Ez van ott ?
	jne	short nemazv		; Nem, nem vessz�k ki
	cmp	word ptr es:[(8 * 4) + 2],ax ; Ez van ott ?
	jne	short nemazv		; Nem, nem vessz�k ki
	cmp	word ptr es:[23h * 4],offset int23r ; Ez van ott ?
	jne	short nemazv		; Nem, nem vessz�k ki
	cmp	word ptr es:[(23h * 4) + 2],ax ; Ez van ott ?
	jne	short nemazv		; Nem, nem vessz�k ki
	mov	ax,[int08c]		; Offszet
	mov	es:[8 * 4],ax		; Offszet ki
	mov	ax,[int08c + 2] 	; Szegmens
	mov	es:[(8 * 4) + 2],ax	; Szegmens ki
	mov	ax,[int23c]		; Offszet
	mov	es:[23h * 4],ax 	; Offszet ki
	mov	ax,[int23c + 2] 	; Szegmens
	mov	es:[(23h * 4) + 2],ax	; Szegmens ki
	sti				; M�r lehet IT.
	ret				; Helyre�ll�t�s k�sz
;
fakemh	db	'FAKT!'                 ; EMS handle tulajdonos sz�veg
	hndnum				; Verzi� a handle-hoz
;
emmszo	db	'EMMXXXX0',0            ; EMS neve
;
connam	db	'CON', 0                ; A CONSOLE perif�ria neve
;
emsros	db	'EMS hiba, vagy nem megfelel� verzi� !', 13, 10, '$'
;
helpsz	db	'Faktori�lis sz�m�t�.', 13, 10
	db	'Haszn�lata: FAKTEMS �rt�k', 13, 10
	db	'Nagy �rt�kekn�l (> 50000) t�bb percig is sz�molhat!', 13, 10, '$'
;
nagysz	db	'A k�rt �rt�k t�l nagy eredm�nyt ad!', 13, 10
	db	'K�rj�l kisebbet.', 13, 10, '$'

dekbaj	db	'Kisz�molni kisz�moltam (bin�risan), de nem tudom decim�lisra alak�tani!', 13, 10
	db	'K�rj�l kisebbet.', 13, 10, '$'

faktin	db	13, 'Faktori�lis sz�m�t�s: ', 0
;
dekszo	db	13, 'Az eddig dek�dolt sz�mjegyek sz�ma: ', 0
;
faktbe	db	'A faktori�lis kisz�m�t�sa (bin�risan) k�sz, dek�dol�s k�vetkezik.', 13, 10, 0
;
	db	13 dup(8)		; Visszal�p�sek
bckspa	db	0
;
crlfco	db	13, 10, 0
;
kiivol	db	0			; Ki�r�s jelz�s
consti	db	?			; A ki�r�s hossza
;
fogkel	equ	($ - start) and 1	; Sz�ra igaz�t�s
;
	if	fogkel NE 0
;
	db	0			; Eltolom sz�ra
;
	endif
;
teelis	dw	simare			; Nincs teend�
hndems	dw	0			; Handle t�rol�
elosmp	dw	0			; A sz�ml�l�
aktlek	dw	0ffffh			; A lek�pz�s jelenleg
tcimta	dw	lapcim + 16383		; A ter�let c�me
handco	dw	?			; A CON f�jlsz�ma
dosakt	dw	?, ?			; A DOS foglalts�gi bit
;
fogdup	equ	($ - start) and 2	; Dupla sz�ra igaz�t�s
;
	if	fogdup NE 0
;
	dw	?			; Eltol�s duplasz�ra
;
	endif
;
int08c	dw	?,?			; 8-as vektor tartalma
;
int23c	dw	?,?			; 8-as vektor tartalma
;
darmar	dd	?			; Az EMS m�rete 16K-s lapokban
;
hatcim	dd	?			; A nem nulla c�me
;
tblcim	dd	?			; A decim�lis 4 bitek c�me
;
hatter	dd	?			; Ezt �rogatja ki
;
lapcim	label	dword
	db	16384 dup(?)		; 16K-s EMS lapt�rol�
;
code	ends
	end	start

