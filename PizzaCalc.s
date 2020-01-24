#dmm107 :))
.text
.align 2

# area function: ret float
        # pizza->dia * pizza->dia * pi /4.0
# calc function: ret int (void)
        # pizza->area/pizza->cost
# sorting
        # insertion sort
# pizza struct
        # char title[256]
        # float diameter
        # float cost
        # float topr
        # struct pizza* next
        ### could we make the pizza struct more efficient by only storing topr?
        ### we would do that by calcing area, div by cost
# main function
        # open file, read name
                # this will get the "Name\n"
                # so you need to set the last character to NULL
        # store name in pizza struct
        # read float: dia
        # area(dia)
        # read float: cost
        # calc(area/cost)
        # store that in a pizza struct
        # read everything
        # sort everything
        # print everything
        # close file
        # happy
main:
        addiu $sp, $sp, -4 #expand the stack
        sw $ra, 0($sp) #save $ra to the stack, you trash it with the jals

        jal read #read and sort all the pizzas
        move $a0, $v0 #argument gets the linked list
       
        jal print #print everything
        
        lw $ra, 0($sp) #restore ra
        addiu $sp, $sp, 4 #collapse the stack
        jr $ra #DONE!!

print:
        #print the name, print topr
        #move along the list until node is null

        move $t0, $a0 #$s0 gets the first node in the list

    print_loop:
        beqz $t0, print_clean #as long as the node isn't null, keep going

        li $v0, 4 #print a string
        la $a0, 0($t0) #print name
        syscall #print!

        li $v0, 4 #print a string
        la $a0, spa #print a space
        syscall #print!

        li $v0, 2 #print a float
        l.s $f12, 256($t0) #print topr
        syscall #print!

        li $v0, 4 #print a string
        la $a0, nln #print nln
        syscall #print!

        lw $t0, 260($t0)#node = node.next
        j print_loop

    print_clean:
        jr $ra


read:
    #housekeeping
        addiu $sp, $sp, -32 #expand the stack
        sw $s0, 0($sp) #for count
        sw $s1, 4($sp) #for the new pizza
        sw $s2, 8($sp) #for the last pizza used
        sw $s4, 12($sp) #for pizza name
        sw $s5, 16($sp) #for "prev" pizza in sorting
        sw $s7, 20($sp) #for head pizza
        sw $s6, 24($sp) #for prev.next in sorting
        sw $ra, 28($sp) #save what is in $ra to the stack

        move $s0, $0 #count = 0

# READ PIZZA BELOW
	read_pizza_loop: 
    #GET NAME BELOW
        li $v0, 4 #print a string
        la $a0, name_msg 
        syscall #print!

        li $v0, 8 #read a string
        la $a0, buffer
        li $a1, 256
        move $s4, $a0
        syscall #pizza name in $s4

        move $a0, $s4 
        la $a1, str_done
        jal strcmp
        beqz $v0, read_clean

        li $v0, 9 #malloc
        li $a0, 264 #256 bytes for str, 4 bytes for topr, 4 bytes for next IN THAT ORDER
        syscall
  
        move $s1, $v0 #pizza struct is in $s1, this is "new" node

    #SET NAME (and NEXT if it's the first node)
        move $a0, $s4 #pizza name
        move $a1, $s1 #here's where you're copying to
        jal strcpy #copy the name

        li $v0, 4 #print a string
        la $a0, diam_msg #ask for diameter
        syscall #print!

        li $v0, 6 #read a float
        syscall # dia in $f0
         
    #AREA FUNCTION
        mtc1 $zero, $f7 #needed?
        c.eq.s $f0, $f7 #is the diameter 0?
        bc1t zed_dia #yes
        bc1f not_zed_dia #no

    not_zed_dia:
        li $t2, 1 #dia isn't zero
        mul.s $f0, $f0, $f0 # $f0 dia * dia
        l.s $f2, PI_OVER_FOUR # $f2 has number PI/4
        mul.s $f0, $f2, $f0 # $f0 has dia*dia*PI/4
        mov.s $f2, $f0 #now $f2 gets area
        j dia_not_zero

    zed_dia:
        s.s $f7, 256($s1) #save topr as 0
        li $t2, 0 #dia is zero, don't do anything with calc

    dia_not_zero:  
        li $v0, 4 #print a string
        la $a0, cost_msg #ask for cost
        syscall #print!
    #CALC FUNCTION  
        li $v0, 6 #read a float
        syscall #get cost in $f0

        beqz $t2, zed #if dia is zero, set topr to 0. but we had to ask for cost bc of the input conventions

        c.eq.s $f0, $f7
        bc1t zed #if $f0 is zero set topr to 0

        div.s $f0, $f2, $f0 # $f0 gets area/cost
    #SET TOPR
        s.s $f0, 256($s1) #set topr in the pizza node
        j sort

    zed:
        mtc1 $zero, $f0 #we trashed $f0 with the cost call, so reset it back to zero
        s.s $f0, 256($s1) #ACTUALLY set the topr to zero
        

    #INSERTION SORT
        #see pages 200 & 201 of the "nordic blue" notebook @me

        #     prev is in $s5
        #      new is in $s1
        #     next is in $s6
        #     head is in $s7
        # new.topr is in $f0
        #prev.topr is in $f2

    sort: 
        sw $0, 260($s1) #new.next = null
        beqz $s0, first_node
        li $t3, 1 #node we're working with below is head: $t3 = 1. no: $t3 = 0
        move $s5, $s7 #prev = head

    insert_loop: #we don't want to have to check to head again
        #again: if new.topr<next.topr, move along
        #again: if new.topr<prev.topr, and next.topr<new.topr, insert
        #and the alpha stuff

        l.s $f2, 256($s5) # $f2 = prev.topr

        c.lt.s $f0, $f2 #is new.topr<prev.topr
        bc1t new_less_than_prev

        c.eq.s, $f0, $f2
        bc1t new_equal_prev

        c.lt.s $f2, $f0 #is prev.topr<new.topr? if yes, insert new here
        bc1t prev_less_than_new #yes
        bc1f move_along

    prev_less_than_new:
        bne $t3, 1, insert_clean #you've messed up if this is true
        sw $s5, 260($s1) #set new to point to prev
        #addiu $s0, $s0, 1 #we've added a node
        move $s7, $s1 #the node we've added is at the top
    #NOT NEEDED?    
        #li $t3, 0 
        
        j insert_clean

    new_equal_prev:
        move $a0, $s1 #new.name
        move $a1, $s5 #prev.name

        jal strcmp

        beq $v0, -1, alpha_front #new.name comes before prev.name
        beq $v0,  0, alpha_front #new.name is prev.name, doesn't matter if you put it before or after so just do it before
        beq $v0,  1, check_bottom #new.name comes after prev.name, check if prev is the last node or if we need to move along

    check_bottom:
        lw $s6, 260($s5) #prev.next in $s6
        beqz $s6, insert_bottom #if the next node is null, insert this node at the bottom

        j move_along #otherwise move along

    new_less_than_prev:
        lw $s6, 260($s5) # $s6 = prev.next
        beqz $s6, insert_bottom #if prev is the last node, add new at the bottom

        l.s $f3, 256($s6) # $f3 = prev.next.topr

        c.lt.s $f3, $f0 #next.topr<new.topr<prev.topr
        bc1t insert_middle #it goes in the middle

        j move_along 

    alpha_front:
        sw $s1, 260($s2) #last points to new
        sw $s5, 260($s1) #new points to prev
        j insert_clean

    insert_bottom:
        sw $s1, 260($s5) #prev.next = new
        sw $0, 260($s1) #new.next = null
        j insert_clean

    insert_middle:
        sw $s1, 260($s5) #prev now points at new
        sw $s6, 260($s1) #new now points at prev's old next
        j insert_clean

    move_along:
        li $t3, 0 #because we're moving down the list, it's not the head node anymore
        move $s2, $s5 #the node we just looked at is now in $s2... saving this for alphabetizing purposes
        lw $s5, 260($s5) #prev=prev.next

        j insert_loop #keep looking for where new goes

    first_node:
        move $s7, $s1 #next $s1 to "head", which lives in $s7
        j insert_clean

    insert_clean: 
        addiu $s0, $s0, 1 #we've added a node
        j read_pizza_loop


#housekeeping - clean
    read_clean:
        move $v0, $s7 #$v0 gets the linked list
        lw $s0, 0($sp) #for count
        lw $s1, 4($sp) #for the new pizza
        lw $s2, 8($sp) #for the last pizza used
        lw $s4, 12($sp) #for pizza name
        lw $s5, 16($sp) #for "prev" pizza in sorting
        lw $s7, 20($sp) #for head pizza
        lw $s6, 24($sp) #for prev.next in sorting
        lw $ra, 28($sp) #restore $ra 
        addiu $sp, $sp, 32 #collapse the stack
        jr $ra
# READ PIZZA ABOVE

strcmp:
        #given two strings, $a0, $a1
        #check one letter at a time
        #check if the string is EOS
        #return -1 if a0<a1
        #return 0 if they match (in $v0)
        #return 1 if a0>a1

    compare:
        lb $t1, 0($a0)
        lb $t2, 0($a1)

        slt $t3, $t1, $t2 #if $t1<$t2 (alpha order) $t3 is 1
        bnez $t3, alpha

        slt $t4, $t2, $t1 #if $t2<$t1 (op-alpha order) $t4 is 1
        bnez $t4, not_alpha

        beqz $t1, same

        addiu $a0, $a0, 1
        addiu $a1, $a1, 1
        j compare

    alpha:
        li $v0, -1
        j cmp_clean

    not_alpha:
        li $v0, 1
        j cmp_clean

    same:
        move $v0, $0

    cmp_clean:
        jr $ra

strcpy:
        #copy the string a character at a time
        #until you hit the null terminator
        #but then strip off the \n character?
        #try it without, see what happens
        #$a0 is name, $a1 is $s1
        #lw $t0, $a0

        li $t1, 10
        move $t4, $a1

    strcpy_loop:
    	lb $t0, 0($a0)

    	#slt $t3, $t0, $t1 #if char is nln, $t3 is 0
    	beq $t1, $t0, cpy_zed

        sb $t0, 0($a1)

        addiu $a0, $a0, 1
        addiu $a1, $a1, 1

        j strcpy_loop

    cpy_zed:
    	sb $0, 0($a1) #delete the nln by making this the end

    strcpy_clean:
        jr $ra

.data
buffer: .space 256
PI_OVER_FOUR: .float 0.785398163397448309615
#debug_name: .asciiz "the name you just entered: "
#debug_save: .asciiz "saved name: "
#debug_copy: .asciiz "just copied: "
#debug_count: .asciiz "you're on pizza number "
name_msg: .asciiz "Pizza name: "
debug_head_name: .asciiz "\nhead pizza name: "
#debug_next: .asciiz "the next pizza is named "
#debug_done: .asciiiz "you've entered done!"
#debug_topr: .asciiz "topr calc'd for pizza: "
name: .asciiz ""
#debug_swap: .asciiz "swapping "
#debug_and: .asciiz " and "
diam_msg: .asciiz "Pizza diameter: "
cost_msg: .asciiz "Pizza cost: "
str_done: .asciiz "DONE\n"
spa: .asciiz " "
nln: .asciiz "\n"