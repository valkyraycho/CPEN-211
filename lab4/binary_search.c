int binary_search ( int * numbers , int key , int length )
{
    int startIndex = 0; // MOV r4, #0
    int endIndex = length - 1; //SUB r5, r2, #1
    int middleIndex = endIndex /2; // MOV r6, r5, LSR #1
    int keyIndex = -1;
    int NumIters = 1;
    while ( keyIndex == -1) //CMP keyIndex, #-1(another reg) -> BNE Exit -> 
    {
        if ( startIndex > endIndex ) //CMP startIndex, endIndex -> BLS Exit
            break;
        //cmpval
        else if ( numbers [ middleIndex ] == key ) //CMP numbers [ middleIndex ], key -> BNE bigger -> MOV keyindex, middleIndex
            keyIndex = middleIndex ;
        //bigger:
        else if ( numbers [ middleIndex ] > key ) //CMP numbers [ middleIndex ] , key -> BLS else -> SUB endIndex, middleIndex, #1
            endIndex = middleIndex -1;
        //else
        else 
            startIndex = middleIndex +1;
        
        numbers [ middleIndex ] = - NumIters ;
        middleIndex = startIndex + ( endIndex - startIndex )/2;
        NumIters ++;
    }
    //Exit:
    return keyIndex ;
 }