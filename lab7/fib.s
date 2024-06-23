.globl fib
fib:
    MOV r0, #1 // num1 = 1
    MOV r1, #1 // num2 = 1
    MOV r9, #255
    MOV r8, #254 
    LDR r2, [r9] // n = m[255]
    MOV r3, #2 // count = 2
    MOV r4, #0 // r4 = 0
    MOV r5, #1 // r5 = 1
    B loop

loop: CMP r3, r2
      BLT num1 // if count < n
      B Exit

num1: AND r6, r3, r5 // r6 = count%2
      CMP r6, r4 // compare (count%2, 0)
      BNE num2 // if count%2 != 0 -> num2
      ADD r0, r0, r1 // num1 = num1 + num2
      ADD r3, r3, r5 // count = count + 1
      B loop

num2: ADD r1, r0, r1 // num2 = num1 + num2
      ADD r3, r3, r5 // count = count + 1
      B loop

Exit: AND r6, r3, r5
      CMP r6, r4
      BNE m_254_num2
      STR r0, [r8]

m_254_num2 STR r1, [r8]
