	title	File kre�l�s
;
verzio	equ	 105			; Verzi�sz�m (1.05)
;
vernum	macro
	defver	%verzio
	endm
;
defver	macro	vnum
num	=	0
	irpc	x,vnum
	db	'&x&'
	if	num eq 0
	db	'.'
	endif
num	=	num + 1
	endm
	endm
;
code	segment para	public	'code'
;
assume cs:code, ds:code, es:nothing, ss:nothing
;
marhos	equ	65535 - vegpoi + 1
;
	org	100h
start:
	mov	ah,4ah			; M�dos�t�s k�r�s k�dja
	mov	bx,1000h		; 64K legyen
	int	21h			; Gyere DOS, m�dos�tsd ha tudod
	mov	dx,offset kevmem	; Hibasz�veg
	jc	kiirba			; Ha nincs el�g
	mov	sp,offset stpoin	; Ez saj�t ter�letre mutat
	mov	si,81h			; Itt van a parancssor eleje
elejei:
	lodsb				; Karakter bet�lt�s
	cmp	al,' '                  ; Sz�k�zzel van ez elej�n ?
	jz	elejei			; Igen, elimin�lom
	cmp	al,9			; Tabul�tor van ez elej�n ?
	jz	elejei			; Igen, elimin�lom
	cmp	al,0dh			; CR itt ?
	jz	vegbaj			; Igen, help lesz
	lea	dx,[si - 1]		; Ez a file-n�v leje
	mov	ds:[6ch],dx		; Itt lesz a n�vkezdet
talfiu:
	lodsb				; Karakter bet�lt�s
mehet:
	or	al,al			; Nulla ?
	jne	nestri			; Igen, HELP ki�rat�sra
vegbaj:
	mov	dx,offset help		; Ez a HELP c�me
kiirba:
	mov	ah,9			; Stringki�rat�s k�dja
	jmp	kilsta			; St�tusszal kil�p�s
nestri:
	cmp	al,0dh			; CR ?
	je	vegbaj			; Igen, HELP ki�rat�sra
	cmp	al,9			; V�ge a n�vnek ?
	je	neveta			; Igen, ellen�rz�m
	cmp	al,' '                  ; V�ge a n�vnek ?
	jne	talfiu			; Nem, k�vetkez� karakter kell
neveta:
	mov	byte ptr [si - 1],0	; A file-n�v v�g�re 0 byte
	call	longco			; BP:CX <- konstans
	jc	conros			; Hib�s valami
	mov	[hosout],cx		; Konstans L r�sz
	mov	[hosout + 2],bp 	; Konstans H r�sz
crvane:
	lodsb				; Karakter behozatal
	cmp	al,' '                  ; Sz�k�z k�veti ?
	jz	crvane			; Igen, �tl�pem
	cmp	al,9			; TAB k�veti ?
	jz	crvane			; Igen, �tl�pem
	or	al,al			; Ez a befejez� karakter ?
	je	sibefs			; Igen, sikeres a hossz
	cmp	al,0dh			; Ez a befejez� karakter ?
	je	sibefs			; Igen, sikeres a hossz
	cmp	al,'/'                  ; Kapcsol� ?
	je	katava			; Igen, van kapcsol�
conros:
	mov	dx,offset conhib	; Hibasz�veg c�me
kiirbs:
	jmp	short kiirba		; Hibaki�rat�sra
katava:
	lodsb				; Karakter behozatal
	cmp	al,'f'                  ; Kis f ?
	jz	fkatal			; Igen j� a kapcsol�
	cmp	al,'F'                  ; Nagy F ?
	jnz	vegbaj			; Nem, helpet adjunk
fkatal:
	mov	di,offset fillte	; Ide teszem majd le
	lodsb				; Beolvasom a karaktert
	cmp	al,'r'                  ; V�letlen sz�m ?
	jz	random			; Igen, az lesz
	cmp	al,'R'                  ; V�letlen sz�m ?
	jnz	prokon			; Nem, pr�b�ljuk konstansnak
random:
	lodsb				; Beolvasom a hat�rol�t
	cmp	al,' '                  ; Sz�k�z ?
	jz	random			; Igen, �tl�pem
	cmp	al,9			; TAB ?
	jz	random			; Igen, �tl�pem
	cmp	al,0dh			; A v�gjel ?
	jnz	conros			; Rossz a konstans
	mov	[filldb],-1		; Kiteszem a jelet
sibefs:
	jmp	sibefe			; Teljesen k�sz
prokon:
	mov	bx,4			; A hossza
	cmp	al,'q'                  ; Duplaszavas ?
	jz	tokial			; Igen, byte-os a t�lt�s
	cmp	al,'Q'                  ; Duplaszavas ?
	jz	tokial			; Igen, byte-os a t�lt�s
	mov	bx,2			; A hossza
	cmp	al,'w'                  ; Szavas ?
	jz	tokial			; Igen, byte-os a t�lt�s
	cmp	al,'W'                  ; Szavas ?
	jz	tokial			; Igen, byte-os a t�lt�s
	dec	bx			; BX <- 1
	cmp	al,'b'                  ; Byte-os ?
	jz	tokial			; Igen, byte-os a t�lt�s
	cmp	al,'B'                  ; Byte-os ?
	jz	tokial			; Igen, byte-os a t�lt�s
karkoo:
	dec	si			; Visszal�pek
tokial:
	lodsb				; Karakter behozatal
	cmp	al,'"'                  ; Karakterkezdet ?
	jz	talkoe			; Igen, ez a kezdet
	cmp	al,''''                 ; Karakterkezdet ?
	jnz	konfel			; Nem, konstanssal pr�b�lkozom
talkoe:
	mov	ah,al			; M�solat r�la
	xor	cx,cx			; Kezd� karaktersz�m
tokabe:
	lodsb				; AL <- karakter
	cmp	al,ah			; Karakterkezdet p�rja ?
	jnz	filkam			; Ki lehet tenni
	add	[filldb],cx		; Kiteszem a darabot
	jmp	short kabeol		; Sikeresen befejezte
filkam:
	stosb				; Kiteszem
	inc	cx			; Darabsz�m n�vel�s
	jmp	short tokabe		; Mehet tov�bb
konfel:
	dec	si			; Vissza a karakterre
	push	di			; Elrontja
	call	longco			; BP:CX <- konstans
	pop	di			; Vissza
	jnc	filkae			; Sikeres volt a beolvas�s
fillro:
	mov	dx,offset filhib	; Hibasz�veg c�me
	jmp	short kiirbs		; Ki�ratom
filkae:
	cmp	bx,4			; Duplaszavas ?
	jz	duptol			; Igen, duplaszavas
	cmp	bx,2			; Szavas ?
	jz	wordto			; Igen, szavas
	or	bp,bp			; H r�sz nulla ?
	jnz	fillro			; Nem, nem sikeres
	or	ch,ch			; Csak byte m�ret� ?
	jnz	fillro			; Nem, nem sikeres
filkao:
	mov	[di],cl 		; Kiteszem
	jmp	short konhov		; Ki lett t�ve
duptol:
	mov	[di],cx 		; L r�sz
	mov	[di + 2],bp		; H r�sz
	jmp	short konhov		; Ki lett t�ve
wordto:
	or	bp,bp			; H r�sz nulla ?
	jnz	fillro			; Nem, nem sikeres
	mov	[di],cx 		; L r�sz
konhov:
	add	[filldb],bx		; A t�lt�s hossza
	add	di,bx			; Puffereltol�s
kabeol:
	lodsb				; Beolvasom a hat�rol�t
	cmp	al,' '                  ; Sz�k�z ?
	jz	kabeol			; Igen, �tl�pem
	cmp	al,9			; TAB ?
	jz	kabeol			; Igen, �tl�pem
	cmp	al,0dh			; A v�gjel ?
	jz	sibefe			; Igen, k�sz vagyok, de teljesen
	cmp	al,','                  ; Elv�laszt� ?
	jnz	karkoo			; Nem elv�laszt�
kakave:
	lodsb				; Beolvasom a hat�rol�t
	cmp	al,' '                  ; Sz�k�z ?
	jz	kakave			; Igen, �tl�pem
	cmp	al,9			; TAB ?
	jz	kakave			; Igen, �tl�pem
	cmp	al,0dh			; A v�gjel ?
	jz	fillro			; Igen, ez itt hiba
	jmp	short karkoo		; Mehet az olvas�sra
sibefe:
	mov	dx,ds:[6ch]		; Itt lesz a n�vkezdet
	dec	byte ptr [status]	; Igy most 2 lesz
	push	dx			; A n�v c�m�nek ment�se
	mov	ax,3d01h		; Nyit�s �r�sra k�dja
	int	21h			; Gyere DOS, nyisd meg a file-t
	pop	dx			; N�v visszahozatal
	jnc	opesik			; Ha sikeres a nyit�s
	mov	ah,3ch			; Kre�l�s k�dja
	xor	cx,cx			; Ez a file attributuma
	int	21h			; Gyere DOS, kre�lj file-t
	jnc	kresik			; Siker�lt neki
	mov	dx,offset opehib	; Ez a nyit�shiba sz�veg c�me
	jmp	kiirbs			; Nem sikeres a kre�l�s
kresik:
	dec	byte ptr [status]	; Igy most 1 lesz
opesik:
	mov	bx,ax			; Ez a file-sz�m
	xor	cx,cx			; Hossz H r�sz
	mov	dx,cx			; Hossz L r�sz
	mov	ax,4202h		; Pozicion�l�s a v�g�hez k�dja
	int	21h			; Gyere DOS, vidd a pointert
	mov	[erehos + 2],dx 	; Hossz H r�sz
	mov	[erehos],ax		; Hossz L r�sz
	mov	cx,[hosout + 2] 	; Hossz H r�sz
	mov	dx,[hosout]		; Hossz L r�sz
	mov	ax,4200h		; Pozicion�l�s k�dja
	int	21h			; Gyere DOS, vidd a pointert
	mov	ah,40h			; Ir�s k�dja
	xor	cx,cx			; Az �r�s hossza 0
	int	21h			; Gyere DOS, v�gk ki a hosszat
	xor	dx,dx			; L r�sz
	mov	cx,dx			; H r�sz
	mov	ax,4202h		; Pozicion�l�s a v�g�hez k�dja
	int	21h			; Gyere DOS, mutasd a v�g�t
	cmp	dx,[hosout + 2] 	; Azonos a kiv�nttal ?
	jne	hoszba			; Nem, hibaki�rat�sra
	cmp	ax,[hosout]		; Azonos a kiv�nttal ?
	je	mehhot			; Igen, siker�lt
hoszba:
	mov	dx,offset ninjoh	; Hosszhiba sz�veg c�me
	jmp	zafio			; Z�r�sra
mehhot:
	mov	cx,[erehos + 2] 	; Az eredeti hossz H r�sz
	mov	dx,[erehos]		; Az eredeti hossz L r�sz
	mov	ax,4200h		; Pozicion�l�s a v�g�re
	int	21h			; Gyere DOS, menj a file v�g�re
	mov	ax,[erehos]		; Az eredeti hossz L r�sz
	sub	[hosout],ax		; Levonom az L r�szt
	mov	ax,[erehos + 2] 	; Az eredeti hossz H r�sz
	sbb	[hosout + 2],ax 	; Levonom a H r�szt
	jc	ninmit			; Nincs mit t�lteni
	mov	ax,[hosout]		; L r�sz
	or	ax,[hosout + 2] 	; H r�sz, nulla ?
	jz	ninmit			; Ha nem kell t�lteni m�r
	mov	ax,[filldb]		; Ennyit kell t�ltenem
	or	ax,ax			; Kell t�ltenem egy�ltal�n ?
	jz	ninmit			; Nincs mivel t�lteni
	mov	dx,offset fillte	; A saj�t ter�letem
	cmp	ax,-1			; V�letlensz�m ?
	jz	cikfet			; Igen, azzal t�lt�m fel
	mov	si,dx			; A saj�t ter�letem
	mov	di,dx			; Innen viszi is ki
	add	di,ax			; Ide tegye ki
	mov	cx,marhos		; A t�lt�s hossza
	sub	cx,ax			; Ennyi m�r ki van t�ltve
	cld				; El�refele
	rep	movsb			; Ciklusban t�lt�s
	jmp	short kitpum		; Mehet kivinni
cikfet:
	call	velkez			; Kezd��rt�kek be�ll�t�sa
kitpum:
	mov	cx,marhos		; Alap�rtelmez�s
	cmp	word ptr [hosout + 2],0 ; Van b�ven ?
	jnz	emarad			; Igen, CX marad
	cmp	[hosout],cx		; Van b�ven ?
	jae	emarad			; Igen, CX marad
	mov	cx,[hosout]		; Ennyi lesz
emarad:
	jcxz	mohera			; Nincs mit csin�lni
	sub	[hosout],cx		; Ennyit most kiviszek
	sbb	[hosout + 2],0		; H r�szre is �tviszem
	mov	ax,[filldb]		; Ennyit kell t�ltenem
	inc	ax			; V�letlensz�m
	jnz	mohera			; Nem, mehet a ki�r�s
	call	velkit			; Kit�lt�m
mohera:
	mov	ah,40h			; Az �r�s k�dja
	int	21h			; Gyere DOS, �rd ki a file-ba
	cmp	ax,cx			; Kivitte ?
	jnz	nemvik			; Nem vitte ki
	mov	ax,[hosout]		; L r�sz
	or	ax,[hosout + 2] 	; H r�sz, nulla ?
	jnz	kitpum			; Nem, t�lt�m tov�bb
ninmit:
	mov	byte ptr [status],0	; Sikeres volt
	mov	ah,3eh			; Z�r�s k�dja
kilsta:
	int	21h			; Gyere DOS, z�rd le
	mov	al,[status]		; Ez a kil�p�s visszat�r�si k�dja
	mov	ah,4ch			; Kil�p�s k�dja
	int	21h			; Gyere DOS, befejeztem
nemvik:
	mov	dx,offset nensif	; Nem vitte ki c�me
zafio:
	mov	ah,3eh			; Z�r�s k�dja
	int	21h			; Gyere DOS, z�rd le
	jmp	kiirba			; Hibaki�rat�sra
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	BP:CX-be konstans beolvas�sa.			;
;	Haszn�lhat� formul�k:  123456789  -> 123456789	;
;			       cd5595h	  -> 123456789	;
;			       63252625o  -> 123456789	;
;			       1000b	  ->	     8	;
;			       8k	  ->	  8192	;
;			       8m	  ->   8388608	;
;							;
;	Input:	SI <- stringkezdet			;
;							;
;	Output: BP:CX <- a beolvasott konstans		;
;		SI <- a konstansot k�vet� karakter	;
;		CY <- 1 ha nem j� a konstans		;
;		CY <- 0 ha j� a konstans		;
;							;
;	Ront:	AX, DX, DI				;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
longco:
	mov	ah,0			; AH <- 0
	mov	di,si			; Itt kezd�dik a string
folele:
	lodsb				; Karakter behozatal
	cmp	al,'A'                  ; A bet�k el�tt van ?
	jb	rogsam			; Igen, akkor elemezze
	cmp	al,'Z'                  ; A nagybet�k r�sze ?
	jbe	nagybe			; Igen, akkor elemezze
	cmp	al,'a'                  ; A kisbet�k el�tt van ?
	jb	roscon			; Igen, hib�s a konstans
	cmp	al,'z'                  ; A kisbet�k ut�n van ?
	jae	roscon			; Igen, hib�s a konstans
	sub	al,'a'-'A'              ; �talak�tom nagybet�re
nagybe:
	cmp	al,'B'                  ; Bin�ris, vagy HEX 'B' ?
	jnz	nemabi			; Nem bin�ris
	test	ah,00000111b		; Bin�ris lehet ?
	jnz	folelh			; Nem bin�ris, hexa
	call	hatvan			; Hat�rol� ?
	jnz	folelh			; Nem bin�ris, hexa
	mov	cx,2			; Szorz�
	jmp	short elezar		; Elemz�s v�ge
roscon:
	stc				; Hibajel
	ret				; Nincs tov�bb
nemabi:
	cmp	al,'F'                  ; A hexadecim�lis tartom�ny ?
	ja	nemhex			; Nem az a tartom�ny
folelh:
	or	ah,00000111b		; Hexadecim�lis
	jmp	short folele		; Folytassa
nemhex:
	cmp	al,'O'                  ; Okt�lis jelz� ?
	jnz	nemokt			; Nem okt�lis jelz�
	test	ah,00000110b		; Volt nem ide val� ?
	jnz	roscon			; Hib�s konstans
	mov	cx,8			; Szorz�
	jmp	short elezar		; Elemz�s v�ge
nemokt:
	cmp	al,'H'                  ; Hexa jelz� ?
	jnz	nemhej			; Nem hexa jelz�
	mov	cx,16			; Szorz�
	jmp	short elezar		; Elemz�s v�ge
nemhej:
	cmp	al,'M'                  ; Mega jelz� ?
	jz	megaje			; Igen, folytattom
	cmp	al,'K'                  ; Kilo jelz� ?
	jnz	roscon			; Nem kilo jelz�
megaje:
	test	ah,00000100b		; Volt nem ide val� ?
	jnz	roscon			; Hib�s konstans
	mov	cx,10			; Szorz�
elezar:
	call	hatvan			; Hat�rol� ?
	jz	konjel			; Igen, beolvashatom
roscse:
	jmp	short roscon		; Hib�s konstans
rogsam:
	cmp	al,' '                  ; Hat�rol� ?
	jz	konrea			; Igen, elemzem
	cmp	al,9			; Hat�rol� ?
	jz	konrea			; Igen, elemzem
	cmp	al,','                  ; Hat�rol� ?
	jz	konrea			; Igen, elemzem
	cmp	al,0dh			; Hat�rol� ?
	jz	konrea			; Igen, elemzem
	or	al,al			; Hat�rol� ?
	jz	konrea			; Igen, elemzem
	cmp	al,'0'                  ; Kisebb mint a '0' karakter ?
	jb	roscon			; Ha kisebb
	cmp	al,'2'                  ; Kisebb mint a '2' karakter ?
	jb	folels			; Igen, lehet bin�ris
	or	ah,00000001b		; Legal�bb okt�lis
	cmp	al,'8'                  ; Kisebb mint a '8' karakter ?
	jb	folels			; Igen, lehet okt�lis
	or	ah,00000011b		; Legal�bb decim�lis
	cmp	al,'9'                  ; Kisebb, vagy a '9' karakter ?
	ja	roscse			; Hib�s a konstans
folels:
	jmp	folele			; Igen, lehet decim�lis
konrea:
	test	ah,00000100b		; Volt hex sz�m ?
	jnz	roscse			; Igen, hib�s
	mov	cx,10			; Decim�lis szorz�
konjel:
	mov	si,di			; Itt kezdett
	mov	di,cx			; Ez a szorz�
	xor	cx,cx			; Ez lesz a hossz L byte
	mov	bp,cx			; Ez lesz a hossz H byte
konjeu:
	lodsb				; Ez a konstans eleme
	cmp	al,'0'                  ; Sz�mjegy ?
	jb	konenm			; Kisebb v�ge a keres�snek
	cmp	al,'9'                  ; Sz�mjegy ?
	jbe	szamje			; Most sz�mjegy
	cmp	al,'a'                  ; Lehet kisbet� ?
	jb	nemkis			; Nem kisbet�
	sub	al,'a'-'A'              ; �talak�tom nagybet�re
nemkis:
	cmp	al,'M'                  ; Ez az 'M' ?
	jz	komega			; Igen, konstans v�ge
	cmp	al,'K'                  ; Ez a 'K' ?
	jz	kokilo			; Igen, konstans v�ge
	cmp	al,'H'                  ; Ez a 'H' ?
	jz	konend			; Igen, konstans v�ge
	cmp	al,'O'                  ; Ez az 'O' ?
	jz	konend			; Igen, konstans v�ge
	cmp	al,'B'                  ; Ez a 'B' ?
	jnz	nemabj			; Nem a bin�ris jelz�
	cmp	di,2			; A v�g�t jelzi ?
	jz	konend			; Igen, konstans v�ge
nemabj:
	cmp	al,'F'                  ; Nagyobb ?
	ja	konenm			; Igen, v�ge a konstansnak
	sub	al,7			; Konstansos�tom
szamje:
	and	ax,1111b		; Csak az als� bitek kellenek
	push	ax			; Elmentem
	mov	ax,bp			; AX <- H r�sz
	mul	di			; A konstanssal szorzom
	or	dx,dx			; T�lcsordult ?
	jnz	roscse			; Igen, rossz a konstans
	mov	bp,ax			; Vissza a szorzat
	mov	ax,cx			; AX <- L r�sz
	mul	di			; A konstanssal szorzom
	mov	cx,ax			; A szorzat L r�sze vissza
	add	bp,dx			; A H r�sz�tvitele
	jc	roscss			; T�lcsordult
	pop	ax			; Vissza
	add	cx,ax			; L r�sz
	adc	bp,0			; H r�sz
	jnc	konjeu			; Olvassa tov�bb
roscss:
	jmp	roscon			; T�lcsordult
komega:
	mov	di,1024 		; Ez az 1K �rt�ke
	mov	ax,bp			; AX <- H r�sz
	mul	di			; A konstanssal szorzom
	or	dx,dx			; T�lcsordult ?
	jnz	roscss			; Igen, rossz a konstans
	mov	bp,ax			; Vissza a szorzat
	mov	ax,cx			; AX <- L r�sz
	mul	di			; A konstanssal szorzom
	mov	cx,ax			; A szorzat L r�sze vissza
	add	bp,dx			; A H r�sz�tvitele
	jc	roscss			; T�lcsordult
kokilo:
	mov	di,1024 		; Ez az 1K �rt�ke
	mov	ax,bp			; AX <- H r�sz
	mul	di			; A konstanssal szorzom
	or	dx,dx			; T�lcsordult ?
	jnz	roscss			; Igen, rossz a konstans
	mov	bp,ax			; Vissza a szorzat
	mov	ax,cx			; AX <- L r�sz
	mul	di			; A konstanssal szorzom
	mov	cx,ax			; A szorzat L r�sze vissza
	add	bp,dx			; A H r�sz�tvitele
	jc	roscss			; T�lcsordult
	inc	si			; Hogy a DEC hat�stalan legyen
konenm:
	dec	si			; Idegen karakter volt
konend:
	clc				; Siker�lt
	ret				; Megvan a konstans
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	Hat�rol� vizsg�lat.				;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hatvan:
	push	si			; Nem romolhat el
	lodsb				; Beolvasom
	cmp	al,'/'                  ; Kapcsol� jel ?
	jz	eleveg			; Igen, keresek tov�bb
	cmp	al,','                  ; Vessz� ?
	jz	eleveg			; Igen, keresek tov�bb
	cmp	al,' '                  ; Sz�k�z ?
	jz	eleveg			; Igen, keresek tov�bb
	cmp	al,9			; Tabul�tor ?
	jz	eleveg			; Igen, keresek tov�bb
	cmp	al,0dh			; Csak ennyi ?
	jz	eleveg			; Igen, itt a v�ge
	or	al,al			; Null byte ?
eleveg:
	pop	si			; Vissza ami romlott
	ret				; Megvan a konstans
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	V�letlen byte-kit�teli ciklus.			;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
velkit:
	push	cx			; Elrontom a sz�ml�l�t
	mov	di,dx			; M�solat a c�mr�l
	push	dx			; A c�m is elromlik
	mov	ax,[elovet]		; Az el�z� v�letlen �rt�ke
veleci:
	mul	[atarol]		; Megszorzom az A �rt�k�vel
	add	ax,[btarol]		; Eltolom B-vel
	adc	dx,0			; Eltolom B-vel
	rcr	dx,1			; Felezem a H r�szt
	rcr	ax,1			; Felezem az L r�szt
	stosb				; V�letlen �rt�k kit�tel
	loop	veleci			; Kit�lt�m a puffert
	mov	[elovet],ax		; Kiteszem a folytat�shoz
	pop	dx			; Vissza
	pop	cx			; Vissza a sz�ml�l�
	ret				; K�sz
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	A v�letlensz�m kezd� �rt�kei.			;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
velkez:
	push	dx			; Ez most elromlana
	push	cx			; Ez most elromlana
	xor	ax,ax			; Ez lesz a szegmens �rt�ke
	mov	ds,ax			; DS <- 0
	cwd				; DX <- 0
csinat:
	mov	cx,4000h		; Ennyi duplasz� sz� 64K
	xor	si,si			; SI <- 0
cikelo:
	add	ax,[si] 		; V�letlensz�m kialak�t�s
	add	dx,[si + 2]		; V�letlensz�m kialak�t�s
	add	si,4			; Eltolom
	loop	cikelo			; Ciklusban
	mov	cx,ds			; DS m�solat
	add	cx,1000h		; Eltolom
	mov	ds,cx			; Vissza
	cmp	cx,3000h		; El�rte ?
	jnz	csinat			; Nem, tov�bb
	mov	cx,cs			; Ezt kell
	mov	ds,cx			; DS <- CS
	add	[elovet],ax		; Eltolom 1.
	add	[elovet],dx		; Eltolom 2.
	add	ax,cx			; M�g CS is seg�t
ismlep:
	shl	dx,1			; * 2
	shl	dx,1			; * 4
	jnz	simato			; Ha nem nulla
nutain:
	mov	dx,0100101010000000b	; Nulla eset�n
simato:
	test	dx,1110000000000000b	; El�g nagy ?
	jz	ismlep			; Nem el�g nagy
	inc	dx			; Van �rt�k
	jz	nutain			; Nulla lett volna
	mov	[atarol],dx		; A szorz� k�sz
megyor:
	or	ax,1			; Legyen p�ratlan
megyko:
	cmp	ax,2048 		; Nagyobb ?
	ja	mehrat			; Nem nagyobb
	shl	ax,1			; * 2
	jmp	short megyor		; Megy az OR �jra
mehrat:
	mov	[btarol],ax		; Ez lesz az eltol�
	mov	cx,3			; Kezd� oszt�
primci:
	mov	ax,[btarol]		; Ezt vizsg�lom
	xor	dx,dx			; DX <- 0
	div	cx			; Elosztom
	or	dx,dx			; Marad�k van ?
	jnz	eznemo			; Igen, ez nem az oszt�ja
	mov	ax,[btarol]		; Ez ami nem pr�m sz�m
	inc	ax			; Eltolom
	inc	ax			; Eltolom
	jmp	short megyko		; Mehet vissza
eznemo:
	inc	cx			; L�pek
	inc	cx			; L�pek
	cmp	cx,[btarol]		; El�rte ?
	jb	primci			; Nem, megy tov�bb
	pop	cx			; Sz�ml�l� vissza
	pop	dx			; C�m vissza
	ret				; K�sz, [btarol] <- primsz�m
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	A sz�vegeket, byte-os v�ltoz�kat ide teszem.	;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
status	db	3			; St�tusz helye
;
help	db	0ah, 0dh
	db	'�res file-t kre�l� program. ('
	vernum
	db	')', 0ah, 0ah, 0dh
	db	'Haszn�lata: FCRE file-specifik�ci� hossz[ /f???]',0dh,0ah,0ah
	db	'A hossz alap�rtelmez�sben decim�lis.',0ah,0dh
	db	'M�s sz�mrendszerhez a konstans v�g�re kell tenni a jel�l�st.',0ah,0dh
	db	'H -> hexadecim�lis, O -> okt�lis, B -> bin�ris. Decim�lis rendszerben a hossz',0ah,0dh
	db	'v�g�re tett K kilo, az M megabyte-os foglal�st jelent.', 0ah, 0dh
	db	'Pl.: 1000b, 377o, 1bh, 22k, 5m.', 0ah, 0dh
	db	'Az "F" kapcsol�val t�lt� stringet adhatunk meg. Pl.: /f''Z'' vagy /f90 vagy', 0ah, 0dh
	db	'/f5ah Z bet�vel t�lti fel, a /f''Zoli'' ZoliZoliZoli... stringgel t�lti fel.', 0ah, 0dh
	db	'A t�lt� karaktereket sz�k�zzel, tabul�torral vagy vessz�vel v�laszthatjuk el.', 0ah, 0dh
	db	'Pl.: Kicsi + CR + LF legyen a t�lt�s: /f''Kicsi'' 13, 10', 0ah, 0dh
	db	'Ha a konstansokat t�pussal kiv�njuk ell�tni, az F ut�n haszn�ljunk t�pusjelz�t.', 0ah, 0dh
	db	'A t�pusjelz� B, W vagy Q lehet. A B byte-os a W szavas, a Q duplaszavas', 0ah, 0dh
	db	'�rt�keket jelent. Pl. /fw456dh', 0ah, 0dh
	db	'A /fr kapcsol�val �lv�letlensz�mmal fogja a karaktereket helyettes�teni.', 0ah, 0dh
	db	'Ha nincs t�lt�karakter megadva, csak hosszbe�ll�t�st v�gez.', 0ah, 0dh
	db	'L�tez� file-t csak a kieg�sz�t� r�szen t�lti fel.', 0ah, 0dh
	db	'$'
;
kevmem	db	'Nincs el�g mem�ri�m.$'
;
ninjoh	db	'Nem siker�lt a hossz v�ltoztat�sa.$'
;
opehib	db	'Sikertelen file-kre�l�s.$'
;
conhib	db	'Hib�s hosszmegad�s.$'
;
filhib	db	'Hib�s a t�lt�karakter(ek) megad�sa.$'
;
nensif	db	'Nem siker�lt a file-t felt�lteni.$'
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	Ha nem p�ros c�men kezd�dnek, eltolom.		;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
	if	($ - start) and 1
;
	db	1 dup(?)		; Ha nem p�ros c�men van
;
	endif
;
filldb	dw	0			; A t�lt�s darabsz�ma
;
elovet	dw	1 dup(?)		; A v�letlen el�z� �rt�ke
atarol	dw	1 dup(?)		; A v�letlen szorz�ja
btarol	dw	1 dup(?)		; A v�letlen eltol�ja
erehos	dw	2 dup(?)		; Az eredeti hossz
hosout	dw	2 dup(?)		; A l�trehozand� hossz
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	Ugy foglalok a STACK sz�m�ra, hogy		;
;	kieg�sz�tem paragrafusra.			;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
	dw	512 dup(?)		; Minimum ennyi a STACK
;
fogkel	equ	($ - start) and 15	; Ennyi van t�l a paragrafuson
;
	if	fogkel NE 0
;
	db	16 - fogkel  dup(?)	; Kieg�sz�tem
;
	endif
;
stpoin	label	word			; Ez lesz a STACKPOINTER
;
vegpoi	equ	(($ - start) + 100h) ; Ennyi maradt a 64K-b�l
;
fillte	label	byte		       ; Itt lesz felt�ltve
;
code	ends
	end	start
