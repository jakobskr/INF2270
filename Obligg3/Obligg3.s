#Navn: sprinter
#Synopsis: Writes a format string into a Result
#return: Number of writes written to the Result
#C-signature: int sprinter (unsigned char* res, unsigned char* format, ...)
#Registre: 
#				%ECX - Antall Bytes skrevet
#				%ebx - Result
#				%edx - Format String
#				%ESI - Temporary storage registers
#				%EDI -  -||-
#				%EAX -  -||-
.globl sprinter

sprinter:
	pushl 	%ebp				#Standard Start
	movl 	%esp, %ebp			#Standard Start

	pushl	%esi 				#pushes %esi to the stack
	pushl 	%edi 				#pushes %edi to the stack
	movl	8(%ebp), %ebx 		#Move Result pointer to %ebx
	movl	12(%ebp), %edx 		#Move Old String pointer to %edx
	movl	$0, %ecx 			#Sets byte counter to 0
	addl	$16, %ebp			#ebp now points to the first argument provided

main_loop: 
	movb 	(%edx), %al   		#moves the first byte from format into %al

	cmpb 	$37,%al 			#Check if %al is %
	je		format 				#if % detected jump to format handler
	
	cmpb	$0,%al  			#Check if %al is \0
	je		end 				#if \0 detected jump to end
	
	movb	%al, (%ebx) 		#else move %al to the Result
	jmp		inc_cnt 			#jump to increase_counters

#Finds out which format it read
format:
	incl	%edx 				#moves unto the next byte in format

	movb	(%edx), %al  		#moves the current byte into %al

	cmpb	$37, %al 			#%% 
	je		f_percent           #jmps to f_percent if '%'' is detected

	cmpb	$99, %al 			#%c char given
	je		f_char				#jmps to f_char if 'c' is detected

	cmpb	$115, %al 			#%s string given 
	je		f_string 			#jmps to f_string if 's' is detected

	cmpb	$120, %al 			#%x hex given
	je 	f_hex 					#jmps to f_hex if 'x' is detected

	cmpb 	$35, %al 			#%# 
	je 		f_hash 				#jmps to f_hash if '#' is detected

	cmpb	$117, %al 			#%u
	je 		f_unsigned_int 		#jmps to f_unsigned int if 'u' is detected

	cmpb	$100, %al 			#%d
	je		f_signed_int 		#jmps to f_signed_int if 'd' detected  

	movb	$63, (%ebx)			#Did not recognize the given format, writes '?' to Result

	jmp		inc_cnt 			#jmps to increase_counters since we did not detect a valid format


#read %%
f_percent:
	movb	$37,(%ebx) 			#writes '%' to the Result
	jmp   	inc_cnt 			#jmps to increase_counters

f_char: 						
	movb	(%ebp), %al 		#moves argument pointed by %ebp into %al
	movb	%al, (%ebx) 		#writes the argument char into the Result
	addl	$4,%ebp 			#moves the argument pointer to the next argument
	jmp 	inc_cnt 			#jmps to increase_counters

f_string:
	movl 	(%ebp), %eax 		#moves the argument pointed by %ebp into %eax
	movb	(%eax), %al 		#moves the current byte pointed by %eax into %al

	cmpb	$0, %al 			#Check if we have reached the end of the string
	je		f_string_finished 	#jmps to String finsihed if \0 detected

	movb	%al, (%ebx) 		#writes the byte at %al into the Result
	incl	(%ebp) 				#increases string pointer
	incl	%ebx 				#increases Result pointer
	incl	%ecx 				#increases bytes written counter
 
	jmp 	f_string 			#jmps to f_string

f_string_finished:
	incl	%edx 				#increases format pointer
	addl	$4, %ebp 			#moves the argument pointer to the next argument
	jmp 	main_loop 			#returns to the main_loop

f_hash:
	incl 	%edx 				#increases format pointer
	movb  	(%edx), %al 		#moves first byte of format into %al
	cmpb 	$120, %al 			#compares %al with 'x'
	je		f_hash_x 			#jmps to f_hash_x if 'x' detected
	movb	$63, (%ebx)			#Did not recognize the given format, writes '?' to Result
	jmp		inc_cnt 			#jmps to increase_counters

f_hash_x: 						
	movb	$48, (%ebx) 		#writes '0' to Result
	incl 	%ebx 				#increases result pointer
	incl 	%ecx 				#increases bytes written counter
	movb 	$120, (%ebx) 		#writes 'x' to Result
	incl	%ebx 				#increases Result pointer
	incl	%ecx 				#increases bytes written counter
	jmp 	f_hex 				#jmps to f_hex

f_hex:
	push 	%edx 				#pushes format into stack, as we have to use the %edx register for divl
	movl	(%ebp), %eax 		#moves the argument into %eax,
	movl	$0, %esi       		#sets %esi to 0, esi the total number of digits found

find_hex_digit: 				
	movl 	$16, %edi 			#moves 16 into %edi
	movl	$0, %edx 			#sets %edx to 0 
	divl	%edi 				#divides %eas by %edi, with the quotient stored in %eax and the rest %edx
	cmp 	$9, %edx 			#compares %edx with 9, as we have to either use a-f or 0-9 and they are stored in different places in the ascii table
	ja		greater_than_9		#jmps to greater_than_9 if %edx is greater than 9

	addl 	$48, %edx 			#moves the ascii table pointer from '\0' to '0' so that we get the correct digit
	push 	%edx 				#pushes the rest onto the stack, the first rest will be the LSD, and the last rest will be the MSD, as the stack is LIFO
	incl 	%esi 				#increases the digit counter

	jmp 	more_hex 			#jmp to more_hex to see if there are more digits

greater_than_9:
	addl 	$87, %edx 			#moves the ascii table pointer to 'W' (10 places before 'a') so we get the correct Hex-digit
	push 	%edx 				#pushes the rest onto the stack, the first rest will be the LSD, and the last rest will be the MSD, as the stack is LIFO
	incl 	%esi 				#increases the digit counter
	jmp 	more_hex 			#jmps to more_hex

more_hex:
	cmp 	$0,%eax 			#checks if eax is 0, if it is then we have found all the digits 
	jz		write_digits 		#jmps to write_digits if all the digits are found
	jmp 	find_hex_digit 		#else jmps to find_hex_digit to find the next digit

write_digits:
	popl	%edx				#pops the MSD digit stored in the stack to %edx
	movb 	%dl, (%ebx) 		#writes the byte to Result
	incl	%ebx 				#increases Result pointer
	incl	%ecx 				#increas the bytes written counter
	decl  	%esi 				#decreases the digit_counter
	jnz 	write_digits 		#while (%esi != 0) jmps to write_digit
	addl	$4, %ebp			#Moves the argument pointer to the next argument
	popl	%edx 				#gets the format pointer from the stack
	incl	%edx 				#increases the format pointer

	jmp 	main_loop 			#returns to the main_loop

f_signed_int:
	push 	%edx 				#pushes the format pointer to the stack
	movl 	(%ebp), %eax 		#moves the int argument to %eax
	movl 	$0, %esi 			#sets %esi to 0, esi the total number of digits found
	cmp 	$0, %eax 			#checks if %eax is negative or not
	jge		find_int_digit 		#jmps to find_int_digit if %eax is positive
 
	movb	$45, (%ebx) 		#writes '-' to Result
	incl	%ebx 				#increases the Result pointer
	incl	%ecx 				#increas the bytes written pointer
	negl 	%eax 				#negates the int argument
	jmp 	find_int_digit 		#jmps to find int_digit


f_unsigned_int:
	push 	%edx 				#pushes the format pointer to the stack
	movl 	(%ebp), %eax 		#moves the int argument to %eax
	movl 	$0, %esi 			#sets %esi to 0, esi the total number of digits found

find_int_digit:
	movl	$10, %edi 			#sets %edi to 10
	movl	$0, %edx 			#sets %edx to 0
	divl	%edi 				#divides %eas by %edi, with the quotient stored in %eax and the rest %edx
	addl 	$48, %edx 			#moves the ascii table pointer to point at '0', so we get the correct bytes written to result
	push 	%edx 			 	#pushes the rest onto the stack, the first rest will be the LSD, and the last rest will be the MSD, as the stack is LIFO
	incl 	%esi 				#increases the digit counter by 1

	cmp 	$0, %eax 			#checks if the qoutient is zero, if it is then we have found all the digits
	je		write_digits 		#jmps to write_digits as we have found all the digits

	jmp 	find_int_digit 		#jmps to find_int_digit to find the next int digit

inc_cnt:
	incl	%edx 				#increases the format pointer by 1
	incl	%ebx 				#increases the Result pointer by 1
	incl	%ecx 				#increases the bytes written counter by 1
	jmp		main_loop 			#returns to main_loop

end:
	movb	$0, (%ebx) 			#adding a \0 Byte to the Result
	movl	%ecx, %eax 			#putting bytes read into return adress
	popl	%edi 				#restoring %EDI
	popl 	%esi 				#restoring %ESI
	popl 	%ebp				#Standard return
	ret 						#Returns Bytes copied
