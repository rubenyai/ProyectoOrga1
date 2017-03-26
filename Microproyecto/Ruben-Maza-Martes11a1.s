.section .data 		
	#strings de comparaciones
	shell: 		.asciz ">>"
	string: 	.asciz "%s" 
	entero:		.asciz "%d"
	setsys: 	.asciz "setsys"
	chsys:		.asciz "chsys"
	add:		.asciz "add"
	sub:		.asciz "sub"
	and:		.asciz "and"
	or:			.asciz "or"
	xor:		.asciz "xor"
	exit:		.asciz "exit"
	separa1:	.asciz "+ "
	separa2:	.asciz "  "
	salto:		.asciz "\n"
	
	#valores
	valor1:	  	.long 0
	valor2:	  	.long 0
	tempnum:	.long 0
	tempnum2:	.long 0
	tempnum3:	.long 0
	
	#arreglos de 8 para binario, ya que nuestras operaciones seran de 1 byte
	arreglo1:	.long 0,0,0,0,0,0,0,0
	arreglo2:	.long 0,0,0,0,0,0,0,0
	resulbin:	.long 0,0,0,0,0,0,0,0
	
	#arreglo de 2 para hexadecimal, ya que nuestras operaciones son de 2 bits
	par1:	   .long 0,0
	par2:	   .long 0,0
	resulhexa: .long 0,0
	
	#flags
	setsysflag: .long 0   #si es 2 es que esta en binario, si esta en 16 es que es hexadecimal, si esta 
	chsysflag:  .long 0
		
	#mensajes shell#
	base2:		.asciz "Cambiando a sistema en base 2 \n"
	base16:		.asciz "Cambiando a sistema en base 16 \n"
	linea:      .asciz "------------------------- "
	syscambio:  .asciz "--Selecciona base \n" 
	signo:      .asciz "+ "
	overflow:   .asciz "--Overflow \n"
	
	#mensajes error#
	err_chsys:  .asciz "Error de CHSYS, no se ha establecido SETSYS \n"
	err_setch:  .asciz "Error de SETSYS, no se ha usado CHSYS para cambiar el actual sistema \n"
	err_setnum: .asciz "Error de SETSYS, sistema no soportado, introduzca 16 para hexa o 2 para bin \n"
	err_invalido: .asciz "Error de OPERACION, no se ha seleccionado un sistema 16 o 2 \n"


.section .bss 	
	temp:	  	.space 4
	
	
.section .text


.globl _start
_start: 

inicializacion:
	movl $0, chsysflag #0 significa que no se puede utilizar chsys, no se ha utilizado antes setsys
	movl $1, setsysflag  #1 significa que no hay sistema seleccionado
	movl $0,valor1
	movl $0,valor2

mensaje_shell:
	leal shell, %eax
	pushl %eax
	call printf
	addl $4, %esp
	
leer: #se lee el string proporcionado por el usuario
	leal temp, %eax	
	pushl %eax	
	leal string, %eax	
	pushl %eax	
	call scanf	
	addl $8, %esp	
	
	
# #############################################################################
# Deteccion de strings ########################################################
# #############################################################################		
	
exits: #validamos si es exit
	movl temp,%eax
	movl exit,%ebx
	cmpl %eax,%ebx
	je fin

chsyss: #validamos si es chsys, solo se puede usar cuando el flag de chsys esta desactivado (ya se ha usado setsys)
	movl temp,%eax
	movl chsys,%ebx
	cmpl %eax,%ebx
	je chsysverificacion
			
setsysnum: #validamos si es setsys
	movl temp,%eax
	movl setsys,%ebx
	cmp %eax,%ebx
	je setnum
	
adds:
	movl temp,%eax
	movl add,%ebx
	cmpl %eax,%ebx
	je add_proc

subs:
	movl temp,%eax
	movl sub,%ebx
	cmpl %eax,%ebx
	je sub_proc
	
ands:
	movl temp,%eax
	movl and,%ebx
	cmpl %eax,%ebx
	je and_proc

xors:
	movl temp,%eax
	movl xor,%ebx
	cmpl %eax,%ebx
	je xor_proc

ors:
	movl temp,%eax
	movl or,%ebx
	cmpl %eax,%ebx
	jne or_proc

condicional_evitar: #evitamos que el programa siga a los condicionales
	jmp mensaje_shell

# #############################################################################
# Verificaciones ##############################################################
# #############################################################################
setnum:
	#comprobacion si setsys es 1, es decir, se puede cambiar el sistema
	movl setsysflag,%eax
	movl $1,%ebx
	cmpl %eax,%ebx
	jne  mensaje_setsysnochsys

	leal tempnum, %eax	
	pushl %eax	
	leal entero, %eax	
	pushl %eax	
	call scanf	
	addl $8, %esp
    #comparamos si hay un 16 o 2
	movl tempnum, %eax
	movl $2,%ebx
	cmpl %eax,%ebx
	je set2  #verificamos si podemos cambiar el sistema
	movl $16,%ebx
	cmpl %eax,%ebx
	je set16 #verificamos si podemos cambiar el sistema
	jmp mensaje_setnum
	
set2:
	leal base2, %eax
	pushl %eax
	call printf
	
	movl $2,setsysflag
	movl $1,chsysflag
	jmp mensaje_shell
	
set16:
	leal base16, %eax
	pushl %eax
	call printf
	
	movl $16,setsysflag
	movl $1,chsysflag
	addl $4, %esp
	jmp mensaje_shell	

chsysverificacion: #verificamos si chsys puede usarse, si no es 1, es q no se ha usado setsys por primera vez
	movl chsysflag,%eax
	movl $0,%ebx
	cmpl %eax,%ebx
	jne chsyscambio
	jmp mensaje_chsys
	
chsyscambio:
	leal syscambio, %eax
	pushl %eax
	call printf
	
	movl $1,setsysflag
	jmp mensaje_shell
	
# #############################################################################	
# procedimientos separacion binario y hexa  ###################################
# #############################################################################

leer_valores: #procedimiento de lectura de valores
	pushl %ebp
	movl %esp,%ebp
	leal valor1, %eax	
	pushl %eax	
	leal entero, %eax	
	pushl %eax	
	call scanf	
	addl $8, %esp
	
	leal valor2, %eax	
	pushl %eax	
	leal entero, %eax	
	pushl %eax	
	call scanf	
	addl $8, %esp
	
	movl setsysflag,%eax
	movl $1, %ebx
	cmpl %eax,%ebx
	je mensaje_sistemainvalido
	
	leave
	ret

add_proc:
	call  leer_valores
	
	#si tiene un sistema valido, revisamos entonces si es 2 o 16
	#verificacion si es binario
	movl setsysflag,%eax
	movl $2, %ebx
	cmpl %eax,%ebx
	je add_binario
	
	#verificacion si es hexadecimal
	movl setsysflag,%eax
	movl $16, %ebx
	cmpl %eax,%ebx
	je add_hexadecimal

sub_proc:
	call  leer_valores
	
	#si tiene un sistema valido, revisamos entonces si es 2 o 16
	#verificacion si es binario
	movl setsysflag,%eax
	movl $2, %ebx
	cmpl %eax,%ebx
	je sub_binario
	
	#verificacion si es hexadecimal
	movl setsysflag,%eax
	movl $16, %ebx
	cmpl %eax,%ebx
	je sub_hexadecimal

and_proc:
	call  leer_valores
	
	#si tiene un sistema valido, revisamos entonces si es 2 o 16
	#verificacion si es binario
	movl setsysflag,%eax
	movl $2, %ebx
	cmpl %eax,%ebx
	je and_binario
	
	#verificacion si es hexadecimal
	movl setsysflag,%eax
	movl $16, %ebx
	cmpl %eax,%ebx
	je and_hexadecimal

or_proc:
	call  leer_valores
	
	#si tiene un sistema valido, revisamos entonces si es 2 o 16
	#verificacion si es binario
	movl setsysflag,%eax
	movl $2, %ebx
	cmpl %eax,%ebx
	je or_binario
	
	#verificacion si es hexadecimal
	movl setsysflag,%eax
	movl $16, %ebx
	cmpl %eax,%ebx
	je or_hexadecimal

xor_proc:
	call  leer_valores
	
	#si tiene un sistema valido, revisamos entonces si es 2 o 16
	#verificacion si es binario
	movl setsysflag,%eax
	movl $2, %ebx
	cmpl %eax,%ebx
	je xor_binario
	
	#verificacion si es hexadecimal
	movl setsysflag,%eax
	movl $16, %ebx
	cmpl %eax,%ebx
	je xor_hexadecimal

# #############################################################################	
# procedimientos binario ######  ##############################################
# #############################################################################
llenar_arreglos:
	pushl %ebp
	movl %esp,%ebp
	pushl valor1
	call llenar_arreglo1
	addl $4,%esp
	
	pushl valor2
	call llenar_arreglo2
	addl $4,%esp
	leave
	ret


#add y sub son lo mismo, son sumas
sub_binario:
add_binario: 
	call llenar_arreglos
	movl $0,tempnum # acarreo
	
	#codigo suma y resta
	movl $8,%edi #contador
	ciclosuma:
		cmpl $-1,%edi
		je finciclosuma
		
		#hacemos el and por cada variable
		movl arreglo1(,%edi,4),%eax
		movl arreglo2(,%edi,4),%ebx
		cmpl
		
		cmpl $1,%eax
		je sumauno
		jne sumacero
		
		sumacero:
			movl $0,%eax
			movl %eax,resulbin(,%edi,4) # escribe caracter
			jmp sumaya
		sumauno:
			movl $1,%eax
			movl %eax,resulbin(,%edi,4) # escribe caracter
			jmp sumaya
	sumaya:	
		incl %edi
		jmp ciclosuma

	finciclosuma:
	
	call impresion_binaria
	jmp mensaje_shell


and_binario:
	call llenar_arreglos
	
	#codigo and
	movl $0,%edi #contador
	ciclo1:
		cmpl $8,%edi
		je finciclo1
		
		#hacemos el and por cada variable
		movl arreglo1(,%edi,4),%eax
		movl arreglo2(,%edi,4),%ebx
		andl %ebx,%eax
		
		cmpl $1,%eax
		je anduno
		jne andcero
		
		andcero:
			movl $0,%eax
			movl %eax,resulbin(,%edi,4) # escribe caracter
			jmp andya
		anduno:
			movl $1,%eax
			movl %eax,resulbin(,%edi,4) # escribe caracter
			jmp andya
	andya:	
		incl %edi
		jmp ciclo1

	finciclo1:	
	call impresion_binaria
	jmp mensaje_shell

or_binario:
	call llenar_arreglos	
	#codigo or
	
	movl $0,%edi #contador
	ciclo2:
		cmpl $8,%edi
		je finciclo2
		
		#hacemos el and por cada variable
		movl arreglo1(,%edi,4),%eax
		movl arreglo2(,%edi,4),%ebx
		orl %ebx,%eax
		
		cmpl $1,%eax
		je oruno
		jne orcero
		
		orcero:
			movl $0,%eax
			movl %eax,resulbin(,%edi,4) # escribe caracter
			jmp orya
		oruno:
			movl $1,%eax
			movl %eax,resulbin(,%edi,4) # escribe caracter
			jmp orya
	orya:	
		incl %edi
		jmp ciclo2
	
	finciclo2:	
	call impresion_binaria
	jmp mensaje_shell

xor_binario:
	call llenar_arreglos	
	#codigo xor
		movl $0,%edi #contador
	ciclo3:
		cmpl $8,%edi
		je finciclo3
		
		#hacemos el and por cada variable
		movl arreglo1(,%edi,4),%eax
		movl arreglo2(,%edi,4),%ebx
		xorl %ebx,%eax
		
		cmpl $1,%eax
		je xoruno
		jne xorcero
		
		xorcero:
			movl $0,%eax
			movl %eax,resulbin(,%edi,4) # escribe caracter
			jmp xorya
		xoruno:
			movl $1,%eax
			movl %eax,resulbin(,%edi,4) # escribe caracter
			jmp xorya
	xorya:	
		incl %edi
		jmp ciclo3
	
	finciclo3:	
	
	call impresion_binaria
	jmp mensaje_shell

# #############################################################################	
# procedimientos hexa #########  ##############################################
# #############################################################################
#and y sub son lo mismo son sumas
sub_hexadecimal:
add_hexadecimal:

and_hexadecimal:

or_hexadecimal:

xor_hexadecimal:

# #############################################################################	
# impresion procedimientos binarios #########  ################################
# #############################################################################

llenar_arreglo1:
	pushl %ebp
	movl %esp,%ebp
	movl 8(%ebp), %esi
	#Hacemos comparaciones sucesivas para llenar el arreglo
		movl $7, %ebx	# indice para el arreglo
		movl $10000000, tempnum
		movl $0, tempnum2
		movl %esi,tempnum3
	verif3:	
		cmpl $-1, %ebx	
		jng finverif3
		movl tempnum3, %eax #nuestro numero
		movl tempnum,%ecx  #cifra por la que dividimos
		
		#division para saber si es 1 o 0
		cltd
		idivl %ecx
		movl %eax,%ecx #resultado sera 0 o 1
		movl %edx,tempnum3						
		cmpl $1,%ecx		
		
		je uno1
		jne cero1
		
		cero1:
			movl $0,%eax
			movl tempnum2,%edi
			movl %eax,arreglo1(,%edi,4) # escribe caracter
			jmp ok1
		uno1:
			movl $1,%eax
			movl tempnum2,%edi
			movl %eax,arreglo1(,%edi,4) # escribe caracter
		
		ok1:
			incl %edi
			movl %edi,tempnum2
			decl %ebx	# idecrementa el indice
			#creamos nuestro operador para dividir
			movl $1,%eax
			movl %ebx,%edi
		multiplica1:
			cmpl $0,%edi
			je sigue1
			imul $10, %eax
			decl %edi
			jmp multiplica1
		sigue1:
		movl %eax,tempnum
		
		jmp verif3	# lee siguiente caracter
	finverif3:	
	leave
	ret
	
llenar_arreglo2:
	pushl %ebp
	movl %esp,%ebp
	movl 8(%ebp), %esi
	#Hacemos comparaciones sucesivas para llenar el arreglo
		movl $7, %ebx	# indice para el arreglo
		movl $10000000, tempnum
		movl $0, tempnum2
		movl %esi,tempnum3
	verif4:	
		cmpl $-1, %ebx	
		jng finverif4
		movl tempnum3, %eax #nuestro numero
		movl tempnum,%ecx  #cifra por la que dividimos
		
		#multiplicacion y division para saber si es 1 o 0
		cltd
		idivl %ecx
		
		movl %eax,%ecx #resultado sera 0 o 1
		
		movl %edx,tempnum3						
		cmpl $1,%ecx		
		
		je uno2
		jne cero2
		
		cero2:
			movl $0,%eax
			movl tempnum2,%edi
			movl %eax,arreglo2(,%edi,4) # escribe caracter
			incl %edi
			movl %edi,tempnum2
			jmp ok2
		uno2:
			movl $1,%eax
			movl tempnum2,%edi
			movl %eax,arreglo2(,%edi,4) # escribe caracter
			incl %edi
			movl %edi,tempnum2
			jmp ok2
		
		ok2:
		decl %ebx	# idecrementa el indice
		#creamos nuestro operador para dividir
		movl $1,%eax
		movl %ebx,%edi
		multiplica2:
			cmpl $0,%edi
			je sigue2
			imul $10, %eax
			decl %edi
			jmp multiplica2
		sigue2:
		movl %eax,tempnum
		
		jmp verif4	# lee siguiente caracter
	finverif4:	
	leave
	ret


impresion_binaria:
	pushl %ebp
	movl %esp,%ebp
	leal separa1,%ecx
	pushl %ecx
	call printf
	addl $4, %esp

	#imprimimos arreglo 1
		movl $0, %ebx	# indice para el arreglo
	verif:	
		cmpl $8, %ebx	
		je finverif	
		movl arreglo1(,%ebx,4),%eax	# lee caracter
			
		pushl %eax
		leal entero,%ecx
		pushl %ecx
		call printf
		addl $8, %esp
		
		incl %ebx	# incrementa el indice
		jmp verif	# lee siguiente caracter
	finverif:	
		#imprimimos el salto
		leal salto,%ecx
		pushl %ecx
		call printf
		addl $4, %esp
	
	#imprimimos separacion 
		leal separa2,%ecx
		pushl %ecx
		call printf
		addl $4, %esp
	
	#imprimimos arreglo 2
		movl $0, %ebx	# indice para el arreglo
	verif1:	
		cmpl $8, %ebx	
		je finverif1	
		movl arreglo2(,%ebx,4),%eax	# lee caracter
			
		pushl %eax
		leal entero,%ecx
		pushl %ecx
		call printf
		addl $8, %esp
		
		incl %ebx	# incrementa el indice
		jmp verif1	# lee siguiente caracter
	finverif1:	
		#imprimimos el salto
		leal salto,%ecx
		pushl %ecx
		call printf
		addl $4, %esp
		
		#imprimimos linea 
		leal linea,%ecx
		pushl %ecx
		call printf
		addl $4, %esp
		
		#imprimimos el salto
		leal salto,%ecx
		pushl %ecx
		call printf
		addl $4, %esp
		
		#imprimimos separacion 
		leal separa2,%ecx
		pushl %ecx
		call printf
		addl $4, %esp
	
	#imprimimos resultado
		movl $0, %ebx	# indice para el arreglo
	verif2:	
		cmpl $8, %ebx	
		je finverif2	
		movl resulbin(,%ebx,4),%eax	# lee caracter
			
		pushl %eax
		leal entero,%ecx
		pushl %ecx
		call printf
		addl $8, %esp
		
		incl %ebx	# incrementa el indice
		jmp verif2	# lee siguiente caracter
	finverif2:	
		#imprimimos el salto
		leal salto,%ecx
		pushl %ecx
		call printf
		addl $4, %esp	
	leave
	ret
	

# #############################################################################	
# impresion procedimientos hexadecimales ######### ############################
# #############################################################################

impresion_hexadecimal:


# #############################################################################	
# mensajes ####################################################################
# #############################################################################

mensaje_chsys: #mensaje de error cuando no hemos establecido primeramente setsys antes de usar chsys
	leal err_chsys, %eax
	pushl %eax
	call printf
	addl $4, %esp
	jmp mensaje_shell
	
mensaje_setnum: #mensaje de error cuando introducimos un sistema invalido, solo puede ser binario o hexa
	leal err_setnum, %eax
	pushl %eax
	call printf
	addl $4, %esp
	jmp mensaje_shell
	
mensaje_setsysnochsys: #mensaje de error cuando estamos usando un sistema y usamos setsys sin haber usado chsys
	leal err_setch, %eax
	pushl %eax
	call printf
	addl $4, %esp
	jmp mensaje_shell
	
mensaje_sistemainvalido: #mensaje de error, cuando se hace una operacion sin seleccionar un sistema 2 o 16
	leal err_invalido, %eax
	pushl %eax
	call printf
	addl $4, %esp
	jmp mensaje_shell
	

# #############################################################################	
# fin #########################################################################
# #############################################################################
fin: #finaliza programa

	movl $1, %eax
	movl $0, %ebx
	int $0x80

