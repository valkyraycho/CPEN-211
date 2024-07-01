.globl binary_search
binary_search:
      // set initial values
      mov r4, #0 // r4 = startindex = 0
      sub r5, r2, #1 // r5 = endIndex = length(r2) - 1
      mov r6, r5, lsr #1 // r6 = middleIndex = endIndex(r5)/2
      mvn r7, #0 // r7 = keyIndex = -1
      mov r8, #1 // r8 = NumIters = 1
      mvn r9, #0 // use r9 = -1 instead of imm value

      // while loop
loop: cmp r7, r9 // check condition keyIndex == -1
      bne Exit // break from while loop if keyIndex != -1
      b check // otherwise, check startIndex > endIndex first
      
check: cmp r4, r5
       bls cmpval // if startIndex <= endIndex then start comparing values
       b Exit // otherwise, break from while loop

cmpval: ldr r10, [r0, r6, lsl #2] // r10 = numbers[middleIndex]
        cmp r10, r1
        bne CheckBigger // if numbers[middleIndex] != key then move to the next condition -> numbers [ middleIndex ] > key
        mov r7, r6 // if equal then keyIndex = middleIndex
        // not necessary to update the values since the loop is going to break
        b loop

CheckBigger: cmp r10, r1
             blt Smaller //check numbers [ middleIndex ] > key. If smaller or equal, then move to numbers [ middleIndex ] < key
             sub r5, r6, #1 // endIndex = middleIndex - 1
             sub r8, r8, #1 // NumIters-- (for mvn)
             mvn r10, r8 // numbers [ middleIndex ] = -NumIters
             str r10, [r0, r6, lsl #2] // (memory) numbers [ middleIndex ] = -NumIters
             sub r6, r5, r4 // middleIndex = endIndex - startIndex
             mov r6, r6, lsr #1 // middleIndex = (endIndex - startIndex)/2
             add r6, r4, r6 // middleIndex = startIndex + (endIndex - startIndex)/2
             add r8, r8, #2 // NumIters+=2 (should be NumIters++ but we NumIters-- before)
             b loop

Smaller: add r4, r6, #1 // startIndex = middleIndex + 1
         sub r8, r8, #1 // NumIters-- (for mvn)
         mvn r10, r8 // (register) numbers [ middleIndex ] = -NumIters
         str r10, [r0, r6, lsl #2] // (memory) numbers [ middleIndex ] = -NumIters
         sub r6, r5, r4 // middleIndex = endIndex - startIndex
         mov r6, r6, lsr #1 // middleIndex = (endIndex - startIndex)/2
         add r6, r4, r6 // middleIndex = startIndex + (endIndex - startIndex)/2
         add r8, r8, #2 // NumIters+=2 
         b loop        

Exit: mov r0,r7
      mov pc,lr
