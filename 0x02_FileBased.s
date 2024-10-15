.data 
    m: .space 4  #numar de linii
    n: .space 4  #numar de coloane
    p: .space 4  #numar celulelor vii
    k: .space 4 #numar de evolutie
    val_de_copiat: .space 4     #variabila pentru a stoca valoarea celulei cand se copiaza matricea evoluata in orig
    vecini_3: .long 3 #pentru comparare nr vecini
    vecini_2: .long 2  #pentru comparare nr vecini, dupa terminarea forului de directie 
    valoare_celula_moarta: .long 0
    valoare_celula_vie: .long 1   #pt comparare la detectarea vecinilor
    index_curent_incarcare_matrice_evol: .space 4
    evol_curente: .long 0    # numarul de evolutii pentru primul for 
    index_curent_vectori_directie: .long 0      #indexul in di si dj pt al 4lea for
    lungime_vec_directie: .long 8     #pentru al 4lea for, for-ul de directie
    dim_max: .long 20     #dimensiunea maxima a matricii dupa bordare
    vecini: .space 4 #numarul de vecini pentru o celula
    iii: .space 4   # index i pentru a transfera matricea ev in matrice
    jjj: .space 4 #index j pentru a transfera matricea ev in matrice
    di: .long -1,-1,-1,0,1,1,1,0  #vector de directie i pt vecini
    dj: .long -1,0,1,1,1,0,-1,-1  #vector de directie j pt vecini
    format: .asciz "%ld"    #formatul de citire int C (scanf)
    index: .space 4     #pentru imput in matrice
    matrice_initiala: .space 1600   #matricea in sine, INDEXATA DE LA 1!
    matrice_dupa_evolutie: .space 1600 #matrice care se umple dupa o evolutie, tot indexata de la 1
    left: .space 4    #coordonate pentru celulele vii
    right: .space 4     #idem ca precedentul 
    index_linie: .space 4     # index pentru linii la afisare matricii
    index_coloane: .space 4   #index pentru coloane (afisare matrice)
    nl: .ascii "\n"      #for new line when printing matrix 
    format_printf: .asciz "%ld "       #print matrix format
    index_linie_copiere: .space 4     #variabile separate, altfel nu sunt destui registrii 
    index_coloana_copiere: .space 4     #idem ca variabila de mai sus 
    filename: .asciz "out.txt"     #nume fisier iesire
    fptr: .long 0   #echivalent la FILE* FPTR din C
    arg_write: .asciz "w" #pentru scriere in fisier out.txt
    arg_read: .asciz "r"    #pentru citire in in.txt
    current: .space 4      #memorare valoare curenta din matrice pentru printare
    format_string: .asciz "%s"      #pentru a printa un new line
    nw_ln: .asciz "\n"    #caracterul new line 
    filename_read: .asciz "in.txt"    #nume fisier intrare 
 
.text 
    #macro pentru citit constante  din fisier 
    .macro scan var
        pushl \var 
        pushl $format
	pushl fptr
        call fscanf 
	popl %ebx
        popl %ebx 
        popl %ebx 
    .endm

    #exit macro pentru modificare usoara exit code 
    .macro exit code 
        movl $1, %eax 
        movl \code, %ebx 
        int $0x80
    .endm 

    .global main 
        
	    tentativa_creare:  #daca se ajunge aici, celula este cu siguranta moarta, si daca sunt 3 vecini, creare cel
		    movl vecini, %eax 
		    cmpl %eax, vecini_3
		    je creare 
		    movl $0, vecini
		    incl index_coloane
		    jmp bucla_coloane
		    
	    creare:
		#creare celula noua, celula veche fiind moarta
		    lea matrice_dupa_evolutie, %edi 
		    movl index_curent_incarcare_matrice_evol, %ebx 
		    movl $1, (%edi, %ebx,4)
		    
		    movl $0, vecini
		    incl index_coloane
		    jmp bucla_coloane
		    
	    ultrapopulare:      #celulaa noua este moarta
		    lea matrice_dupa_evolutie, %edi 
		    movl index_curent_incarcare_matrice_evol, %ebx 
		    movl $0, (%edi, %ebx,4)
		    
		    movl $0, vecini
		    incl index_coloane
		    jmp bucla_coloane
	    
	    continuitate:    #celula ramane vie 
		    lea matrice_dupa_evolutie, %edi 
		    movl index_curent_incarcare_matrice_evol, %ebx 
		    movl $1, (%edi, %ebx,4)
		    
		    movl $0, vecini
		    incl index_coloane
		    jmp bucla_coloane	


	return:
        	ret 
        scan_matrice:     #label pentru citirea matricii initiale
            movl index, %ecx 
            cmp %ecx, p
            je return 

            scan $left
            scan $right

            movl left, %eax 
            incl %eax 
            movl $0, %edx
            mull dim_max
            addl right, %eax
            incl %eax  
            leal matrice_initiala, %edi 
            movl $1, (%edi, %eax, 4)

            incl index 
            jmp scan_matrice

	pre_evolutie:
		#aici se copiaza continutul matricei evoluate in matricea initiala
		movl $1, index_linie_copiere
		bucla_linii_copiere:
			movl index_linie_copiere, %ecx 
			cmpl %ecx, dim_max
			jl evolutie

			movl $1, index_coloana_copiere

			bucla_coloane_copiere:
				movl index_coloana_copiere, %ecx 
				cmpl %ecx, dim_max
				je nl_copiere
				movl index_linie_copiere, %eax 
				movl $0, %edx 
				mull dim_max
				addl index_coloana_copiere, %eax 
				lea matrice_dupa_evolutie, %edi
				movl (%edi, %eax, 4), %ebx 

				lea matrice_initiala, %edi
				movl %ebx, (%edi, %eax,4)

				incl index_coloana_copiere
				jmp bucla_coloane_copiere
		nl_copiere:
			incl index_linie_copiere
			jmp bucla_linii_copiere

        
        evolutie:    #cod pentru o k-evolutie 
            movl evol_curente, %edx 
            cmpl %edx,k
            je return
            incl evol_curente
            movl $1, index_linie
            bucla_linii:
                movl index_linie, %ecx 
                cmpl %ecx, m
                jl pre_evolutie
                movl $1, index_coloane
                bucla_coloane:
                    movl index_coloane, %ecx 
                    cmpl %ecx, n
                    jl new_line_afisare_matrice
                    
		    bucla_directie:
                        #reinitializare index 
			movl $0, iii
                        movl $0, jjj
                        
			movl index_curent_vectori_directie, %edx 
                        cmpl %edx, lungime_vec_directie
                        je pre_bucla_coloane
			
			#parcurgere di, dj si matrice initiala cu lea 
                        lea di, %edi 
                        movl (%edi,%edx,4), %eax 
                        addl index_linie, %eax 
                        movl %eax, iii
                        lea dj, %edi
                        movl (%edi, %edx,4), %eax 
                        addl index_coloane, %eax 
                        movl %eax, jjj
                        movl iii, %eax 
                        movl $0, %edx
                        mull dim_max
                        addl jjj, %eax
                        lea matrice_initiala, %edi
                        movl (%edi,%eax,4), %ebx 
			cmpl %ebx, valoare_celula_vie
			
			je inc_vecini

                        incl index_curent_vectori_directie
                        jmp bucla_directie
                    
		    pre_bucla_coloane:
                        #reinitializeaza indexul in di si dj
                        #aici o sa intre verificarea celulelor
                        movl $0, index_curent_vectori_directie
					
			#aici incepe calculul indexului matrice_evol[i][j]			
			movl index_linie, %eax 
			movl $0, %edx 
			mull dim_max 
			addl index_coloane, %eax 

			movl %eax, index_curent_incarcare_matrice_evol
			#aici se termina calculul indexului matrice_evol[i][j]
			
			#verificam intai daca celula este vie la [i][j]

			lea matrice_initiala, %edi 
			movl (%edi, %eax,4), %eax 
			cmpl %eax, valoare_celula_moarta
			je tentativa_creare 
			
			#daca se ajunge aici, celula este cu siguranta vie
		    	#in %ebx e tinut indexul matricei initiale
			movl vecini, %eax 
			cmpl vecini_3, %eax 
			jg ultrapopulare     #daca sare la ultrapopulare, are cel putin 4 vecini
			je continuitate      #daca sare aici, intra la categoria continuitate celule cu 3 vecini
			
			cmpl %eax, vecini_2
			je continuitate 

			#daca ajunge aici, moare celula in generatia urmatoare

			lea matrice_dupa_evolutie, %edi 
			movl index_curent_incarcare_matrice_evol, %ebx 
			movl $0, (%edi, %ebx,4)
						
			movl $0, vecini    #reseteaza numarul de vecini pentru celula urmato
                        incl index_coloane
                        jmp bucla_coloane
		    inc_vecini:
		    	#incrementeaza numarul de vecini 
			incl vecini
			incl index_curent_vectori_directie
			#sare la loc in bucla vectorilor de directie
			jmp bucla_directie
		   
    new_line_afisare_matrice:
	incl index_linie
	jmp bucla_linii

	printare_matrice:
	    movl $1, index_linie
	    for_linii:
	    	movl index_linie, %ecx 
		cmpl %ecx, m
		jl return 

		movl $1, index_coloane
		for_coloane:
		    movl index_coloane, %ecx 
		    cmpl %ecx, n
		    jl printare_nl
		    
		    movl index_linie, %eax 
		    movl $0, %edx 	
	 	    mull dim_max
	 	    addl index_coloane, %eax 
		    lea matrice_initiala, %edi 
		    movl (%edi, %eax,4), %ebx 
		    movl %ebx, current 

		    #write

		    pushl current
		    pushl $format_printf
		    pushl fptr
		    call fprintf
		    popl %ebx 
		    popl %ebx
		    popl %ebx  

		    pushl fptr
		    call fflush 
		    popl %ebx 

		    incl index_coloane
		    jmp for_coloane
		
		printare_nl:
		    #afisarea unui caracter \n
		    pushl $nw_ln 
		    pushl $format_string
		    pushl fptr
		    call fprintf
		    popl %ebx 
		    popl %ebx 
		    popl %ebx 
		    pushl fptr
		    call fflush 
		    popl %ebx 
		
		    incl index_linie
		    jmp for_linii
	
	#sfarsit cod printare matrice_evoluata 

        
    main:
	#deschidere in.txt
	pushl $arg_read
	pushl $filename_read
	call fopen 
	popl %ebx 
	popl %ebx 
	movl %eax, fptr

	#scanare constante
	scan $m
        scan $n
        scan $p

        movl $0, index     
        call scan_matrice    #scanam matricea initiala
        
        scan $k   #scanam numarul de evolutii

        #aici incepe codul evolutiilor
        
        call evolutie

	#dupa evolutii, deschidem fisierul out.txt si scriem valorile in acel fisier 
	pushl $arg_write
	pushl $filename
	call fopen 
	popl %ebx 
	popl %ebx 
	movl %eax, fptr

	call printare_matrice

        #iesire program cu codul 0    
        exit $0


 
