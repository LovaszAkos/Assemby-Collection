code	segment para	public	'code'

assume cs:code, ds:code, es:nothing, ss:nothing

stbisz	equ	128			; STACK m�ret a rendszerh�v�shoz
;
segres = ((stacke - start) + 10fh) / 16 ; Paragrafussz�m
;
	.486
;
	org	80h

counte	db	?			; A sz�ml�l� by�jt
	db	?			; A hat�rol� helye
parsor	db	126 dup(?)		; A parancssor b�jtjai

	org	100h
start:
	cld				; El�refele csin�lja
	mov	sp,offset stacke	; Ez marad a STACK sz�m�ra
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
	mov	ax,cs			; Hogy ha elromlott vissza�lljon
	mov	ds,ax			; DS <- CS
	mov	ah,9			; A ki�rat�s k�dja
	int	21h			; Ki�rat�s a DOS-sal
	mov	ah,4ch			; Kil�p�s k�dja
	mov	al,cl			; Nem sikeres jelz�ssel l�pek ki
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
; Megn�zem, hogy mennyi a hely
;
	mov	ah,4ah			; Meg akarom m�dos�tan a helyemet
	mov	bx,0ffffh		; Ennyi �gy sem lesz
	int	21h			; K�rem a DOS-t
	mov	ax,cs			; Ez a jelenlegi
	mov	cx,segres		; Ez a k�l�nbs�g
	add	ax,cx			; Ez az �j szegmens
	mov	ds,ax			; Ez az adatr�sz�
	mov	es,ax			; Ez az adatr�sz�
	sub	bx,cx			; Ennyi maradt szegmensben
	and	ebx,0ffffh		; A fels� r�sz t�rl�se
	shl	ebx,2			; A hossz 4 b�jtosan
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
; K�sz a param�ter beolvas�sa.
; 1-re �ll�tom az eredm�nyter�letet (0! �s 1! �rt�ke)
;
	xor	edi,edi 		; Az eredm�ny kezd�c�me
;
; A ter�letet null�zom, majd az elej�re 1-et teszek
;
	xor	eax,eax 		; Ezt teszem ki a ciklusban
	mov	dx,ds			; Ez a szegmensem
tertor:
	mov	[di],eax		; Kitettem az 0-t
	add	di,4			; Tolom tov�bb
	jnz	short megtar		; Nem, m�g nem az
	add	dx,1000h		; Eltolom 64K-t
	mov	ds,dx			; Ez az �j
megtar:
	dec	ebx			; Sz�ml�l� cs�kkent�se
	jnz	short tertor		; A t�bbit null�zom
;
; Egyel kisebb a dekodol�s eredm�ny�t t�rol� c�m
;
	add	di,-1			; Lecs�kkentem
	jc	short segnem		; A szegmenset nem kell
	add	dx,-1000h		; �gy vissza a szegmens
segnem:
	mov	cs:[tblcim],di		; A v�gc�m offszetje
	mov	cs:[tblseg],dx		; A v�gc�m szegmense
	xor	edi,edi 		; Itt lesz az eleje
	mov	bx,es			; Ez az eredeti
	mov	ds,bx			; DS is az eredeti
	inc	ax			; AX (EAX) <- 1
	mov	[di],ax 		; Kitettem az 1-et
	mov	cs:[hatcim],di		; A nem nulla offszetje
	mov	cs:[hatseg],ds		; A nem nulla szegmense
;
; Indul a sz�m�t�s
; Input:  EBP
; Output: Eredm�nyter�let DS szerint
;
	mov	edi,1			; Ezzel kezdem
nitucs:
	cmp	ebp,edi 		; Enn�l kisebb?
	jbe	short kesvan		; Nem, k�sz is az eredm�ny
;
; Az eredm�nyt�rol�t, meg kell szorozni a k�vetkez�vel
;
faktci:
	inc	edi			; Ezzel fog szorozni
	xor	si,si			; SI <- eredm�nyt�rol� c�me
	mov	bx,es			; BX <- eredm�nyt�rol� szegmense
	mov	ds,bx			; Kezdj�k a szegmenssel is
;
; Az els� �rt�k c�m�nek �s "el�zm�ny�nek" be�ll�t�sa
;
	xor	edx,edx 		; Ezt teszem majd a hely�re
;
; Mehet a szorz�s ciklusa
;
meneve:
	xchg	[si],edx		; Hely�re az eredm�ny
	mov	eax,edx 		; EAX <- k�vetkez� szorzand�
szorel:
	mul	edi			; EDX:EAX <- EAX * EDI
;
; G�rgetem az eredm�nyt az alacsonyabb helyi�rt�kekre
;
	add	[si],eax		; Kiteszem a szorzat L r�sz�t
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
	cmp	bx,cs:[hatseg]		; A null�k szegmense?
	jnz	short szorto		; Nem, m�g nem az
	cmp	cs:[hatcim],si		; El�rte a null�kat?
	jz	short nitucs		; Igen, kil�pek a ciklusb�l
;
; Nem nulla amit szorozni kell, l�pek a k�vetkez� c�mre
;
szorto:
	add	si,4			; �tl�pem az aktu�list
	jnz	short cineto		; Nem kell �tl�pni
	add	bx,1000h		; Eltolom 64K-t
	mov	ds,bx			; Ez az �j
;
; Az �j nagyobb mint az eddigi szorz�s hat�ra?
;
cineto:
	cmp	cs:[hatseg],bx		; A v�gs� szegmens?
	ja	short meneve		; Nem, m�g szorzok tov�bb
	jnz	short segnag		; Igen kell
	cmp	cs:[hatcim],si		; El�rte a v�g�t?
	jae	short meneve		; Nem, m�g szorzok tov�bb
;
; Igen, akkor ez az �j hat�r
;
segnag:
	mov	cs:[hatcim],si		; A nem nulla offszetje
	mov	cs:[hatseg],ds		; A nem nulla szegmense
	dec	ecx			; �j hat�r sz�letett
	js	elfhel			; Elfogyna a hely, v�ge lesz
	jmp	short meneve		; M�g nem �rt a v�g�re, szorz�s
;
; Megn�zem, hogy van-e gond a darabsz�mmal
;
kesvan:
	add	ecx,-2			; Az elej�n r�gt�n 1 van + hely
	js	elfhel			; Elfogyna a hely, v�ge lesz
;
; Az eredm�nyter�leten tal�lhat� bin�ris �rt�k 10-es sz�mrendszerbe
;
	xor	edi,edi 		; Ennyi az elt�rolt karaktersz�m
	mov	ebx,10			; Ennyivel osztogatok majd
kellme:
	xor	edx,edx 		; Ez a H r�sz els�nek
	xor	ebp,ebp 		; Nulla jelz�
	mov	si,cs:[hatcim]		; Az eredm�nyt�rol� c�me
	mov	cx,cs:[hatseg]		; Az eredm�nyt�rol� szegmense
	mov	ds,cx			; M�solat
	jmp	short elfert		; Kezdje az ellen�rz�st
;
; Megkeresem a nem nulla els� �rt�ket
;
modtta:
	add	si,-4			; Visszal�pek, ez az utols� elem
	jc	short rafert		; M�g nem kell szegmenset
	add	cx,-1000h		; �gy vissza a szegmens
	mov	ds,cx			; L�pek vissza
	mov	cs:[hatseg],cx		; A kisebb c�m szegmense
rafert:
	mov	cs:[hatcim],si		; A kisebb c�m offszetje
elfert:
	or	[si],ebp		; Nulla?
	jz	modtta			; Igen, akkor nem osztogatom
;
; Indul a ter�let oszt�sa 10-el
;
egyosz:
	mov	eax,[si]		; Az osztand�
	div	ebx			; Elosztom, EAX <- h�nyados
	mov	[si],eax		; H�nyados a hely�re
	or	ebp,eax 		; Nulla vizsg�lat is
	mov	ax,es			; Ez a kezd� szegmens
	cmp	ax,cx			; El�rte ezt a szegmenst?
	jnz	short simdes		; Nem, akkor osztogatok tov�bb
	or	si,si			; El�rte az elej�t?
	jz	short oszveg		; Igen, k�sz az oszt�s
simdes:
	add	si,-4			; Visszafele egyet (4 b�jtot)
	jc	short egyosz		; M�g nem m�dosul a szegmens
	add	cx,-1000h		; �gy vissza a szegmens
	mov	ds,cx			; L�pek vissza
	jmp	short egyosz		; Elosztom minden elem�t
;
; Megvan a marad�k, �s a h�nyados is, egy f�l b�jtba pakolom
;
oszveg:
	mov	si,cs:[tblcim]		; Itt van a dek�dolt c�m
	mov	ds,cs:[tblseg]		; Ebben a szegmensben
	test	di,1			; Ez a sz�ml�l�
	jz	short legals		; Ez az els�
	shl	dl,4			; L�ptetem feljebb
	or	[si],dl 		; R�m�solom az el�z�eket
	mov	ax,ds			; Ez a szegmens
	or	si,si			; N�veltem
	jnz	short demeve		; Nincs gond
	add	ax,-1000h		; �gy vissza a szegmens
	mov	cs:[tblseg],ax		; �gy vissza a szegmens
	mov	ds,ax			; Az ellen�rz�shez
demeve:
	dec	si			; El�z� c�mre
	mov	cs:[tblcim],si		; Itt van az �j c�m
	jmp	short nemgot		; Mehet a sz�ml�l�s, kit�ve
legals:
	mov	ax,si			; M�solat
	and	eax,3			; Egy dplasz� elejen lehet
	cmp	ax,3			; Most ment �j duplasz�ra?
	jnz	short neduel		; Nem, akor nem vizsg�lom
;
; Megn�zem, hogy maradt-e m�g hely az osztand� el�tt
;
	xor	ax,si			; AX <-SI AND FFFC duplasz�c�m
	cmp	dword ptr [eax],0	; El�rte a bels� hat�rt?
	jz	short neduel		; M�g nem, �rte el, tov�bbmehet
;
; Bizony elfogyott a hely
;
elfhel:
	mov	dx,offset dekbaj	; A t�l nagy sz�veg c�me
	mov	cl,3			; Hibak�d
	jmp	kilhib			; Hibaki�rat�s
neduel:
	mov	[si],dl 		; Elmentem a marad�kot
nemgot:
	inc	edi			; No meg sz�molom is
	or	ebp,ebp 		; Kell m�g osztani?
	jnz	kellme			; M�g van mit, a h�nyados nem 0
;
; A h�nyados nulla lett, j�het a ki�rat�s
;
	mov	ebp,edi 		; Darabsz�m m�solat
	mov	si,cs:[tblcim]		; Itt van a dek�dolt c�m
	mov	ds,cs:[tblseg]		; Ebben a szegmensben
	xor	di,di			; A ki�r�s c�me
	test	bp,1			; P�ratlan?
	jnz	short alertk		; Kiteszem
	inc	ebp			; Mivel cs�kkentem is
	inc	si			; Most n�velni kell
	jmp	short nempar		; Kiteszem
kezcim:
	mov	al,[si] 		; Vissza a 4 sz�mjegy
	shr	al,4			; Alulra a magas �rt�k
	and	al,0fh			; Csak a sz�mjegy maradjon
	or	al,'0'                  ; Karakterr� konvert�lom
	stosb				; Kiteszem a karaktert
	dec	ebp			; Egyet kitettem
alertk:
	lodsb				; Vissza a 2 sz�mjegy
	and	al,0fh			; Csak a sz�mjegy maradjon
	or	al,'0'                  ; Karakterr� konvert�lom
	stosb				; Kiteszem a karaktert
	or	si,si			; El�rte az elej�t?
nempar:
	jnz	short nemcim		; Mehet, nincs szegmens v�lt�s
	mov	dx,ds			; Eddig ez volt
	add	dx,1000h		; A k�vetkez�re
	mov	ds,dx			; DS a k�vetkez�re
nemcim:
	cmp	di,0fffdh		; El�rt a v�g�re?
	jae	short akkoki		; Igen, ki�rat�s j�n
	mov	ax,es			; Innen olvasom
	mov	cx,ds			; Ide teszem
	cmp	ax,cx			; Ide �rt
	jnz	short darano		; Mehet tov�bb
	cmp	si,di			; El�rte a ki�ratand�t?
	jnz	short darano		; Nem, sz�ml�lok tov�bb
akkoki:
	call	stdowr			; Ki�rok
	xor	di,di			; A ki�r�s c�me
darano:
	dec	ebp			; Sz�ml�l�t cs�kkentem
	jnz	short kezcim		; Kiteszem a karaktereket
	or	di,di			; �ppen k�sz is volt?
	jz	short nemtun		; Igen, �ppen k�sz is volt
	call	stdowr			; Ki�rok
;
; K�sz a ki�r�s, kil�pek
;
nemtun:
	mov	ax,4c00h		; Sikeres jelz�ssel l�pek ki
	int	21h			; DOS h�v�s kil�p�sre
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	A karakteres ter�let ki�rat�sa			;
;	a STANDARD OUTPUT-ra.				;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
stdowr:
	xor	dx,dx			; Az elej�t�l
	mov	cx,di			; Ennyit kell
	mov	bx,1			; A standrd outputba
	push	ds			; Elrontom
	mov	ax,es			; Ide pakoltam
	mov	ds,ax			; A karakterek szegmense
	mov	ah,40h			; DOS ki�rat�s f�jlba k�dja
	int	21h			; Ki�rat�s k�r�s
	pop	ds			; Vissza a beolvas�s szegmense
	ret				; K�sz a ki�rat�s

;
helpsz	db	'Faktori�lis sz�m�t�.', 13, 10
	db	'Haszn�lata: FAKT32 �rt�k', 13, 10
	db	'Nagy �rt�kekn�l (> 50000) t�bb percig is sz�molhat!', 13, 10, '$'
;
nagysz	db	'A k�rt �rt�k t�l nagy eredm�nyt ad!', 13, 10
	db	'K�rj�l kisebbet.', 13, 10, '$'

dekbaj	db	'Kisz�molni kisz�moltam (bin�risan), de nem tudom decim�lisra alak�tani!', 13, 10
	db	'K�rj�l kisebbet.', 13, 10, '$'
;
fogkel	equ	($ - start) and 3	; Sz�ra igaz�t�s
;
	if	fogkel NE 0
;
	db	4 - fogkel dup (?)     ; Csak akkor foglalok, ha kell
;
	endif
;
vegcim	dw	?			; A ter�letemen t�li c�m
vegseg	dw	?			; A ter�letemen t�li szegmens
;
hatcim	dw	?			; A nem nulla c�me
hatseg	dw	?			; A nem nulla szegmense
;
tblcim	dw	?			; A decim�lis 4 bitek c�me
tblseg	dw	?			; A decim�lis 4 bitek szegmense
;
	db	stbisz dup(?)		; A STACK minimuma
;
stmara	equ	($ - start) and 15	; Paragrfusra igaz�t�s
;
	if	stmara NE 0
;
	db	16 - stmara dup (?)	; Csak akkor foglalok, ha kell
;
	endif
;
stacke	label	word
;
code	ends
	end	start

