#=============================================
.eqv STACK_SIZE 2048
#=============================================
.data
# obszar na zapamiętanie adresu stosu systemowego
sys_stack_addr: .word 0
# deklaracja własnego obszaru stosu
stack: .space STACK_SIZE
# ============================================
    global_array:   .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    array_size:     .word 10
    result:         .word 0


.text
# czynności inicjalizacyjne
    sw $sp, sys_stack_addr # zachowanie adresu stosu systemowego
#la $sp, sys_stack_addr+STACK_SIZE # zainicjowanie obszaru stosu
    la $sp, sys_stack_addr+STACK_SIZE # zainicjowanie obszaru stosu
    
# początek programu programisty - zakładamy, że main
# wywoływany jest tylko raz
main:

    la $t0, global_array
    lw $t5, array_size
    
    sw $t0, ($sp)  # ładujemy pierwszy argument zmienną int (*array) /adres początku tablicy array/
    subi $sp, $sp, 4 #przesuwamy wskaźnik wierzhołku stosu o 4 bajty w dół 
    sw $t5, ($sp) # ładujemy drugi argument zmienną int (array_size)
    subi $sp, $sp, 4 #przesuwamy wskaźnik wierzhołku stosu o 4 bajty w dół 
    
    #subi $sp, $sp, 8 # rezerwujemy miejsce na stosie dla dwóch int argumentów (8 = 2 * 4 bajty)
    

    jal sum
# miejsce powrotu z funkcji 'sum'    
 
    lw $t7, ($sp) # pobiera ze stosu wartość zwróconą przez wywołany podprogram   

    addi $sp, $sp, 12 # przesuwa wskaźnik stosu tak aby usunąć z niego wartość zwracaną 
    		     # oraz argumenty podprogramu położone na stos przed jego wywołaniem
    
    li $v0, 1               # Wypisz wynik suma
    move $a0, $t7
    syscall
    
    lw $sp, sys_stack_addr # odtworzenie wskaźnika stosu
			   # systemowego
    
    # Koniec programu
    li $v0, 10
    syscall

#strona wywołana    
sum:    

# ciało programu . . .

    subi $sp, $sp, 4 # przesuwa adres wierzchołka stosu tak aby zrobić miejsce na wartość zwracaną (int)
    sw $ra, ($sp)    # umieszcza na wierzchołku stosu adres powrotu z rejestru $ra
    subi $sp, $sp, 8 # rezerwujemy miejsce pod dwie zmienne lokalne (int i, int s) 
    
# początek funkcji 
    sw $zero, 0($sp)   # s = 0;
    lw $t0, 16($sp)	# array_size
    lw $t5, 20($sp)	# *array
    subi $t0, $t0, 1		# i = array_size - 1;
    
    move $t6, $zero
    
           
loop:
    
    lw $t8, ($t5)
    add $t6, $t6, $t8	    # wyliczamy sumę s=s+array[i] /i - $t1/
    sw $t6, 0($sp) # zapisuje znaczenie 's' na stosie  
    addi $t5, $t5, 4	    # przesuwamy wskaźnik na następny element tablicy array[i]
    subi $t0, $t0, 1	    # iterator i = i - 1
    
    bgez $t0, loop # while ( i >= 0 )

# Powrót - strona wywołana
sw $t6, 12($sp) # zapisuje na stosie (w miejscu poprzednio zarezerwowanym do tego celu) wartość zwracaną

addi $sp, $sp, 8 # przesuwa wskaźnik stosu tak aby usunąć ze stosu zmienne lokalne
lw $ra, ($sp) # pobiera ze stosu adres powrotu i umieszcza go w rejestrze $ra
addi $sp, $sp, 4 # przesuwa wskaźnik stosu tak aby na wierzchołku stosu znalazła się wartość zwracana
jr $ra # wykonuje powrót rozkazem jr $ra
