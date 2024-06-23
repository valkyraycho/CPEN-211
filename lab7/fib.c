int main()
{
    int num1 = 1, num2 = 1;
    int n = m[255];
    int count = 2; // 1 1 2 3 4 5 6 7 
    while(count < n)
    {
        if(count%2 == 0) num1 = num1 + num2;
        else num2 = num1 + num2;
        count++;
    }
    if(count%2 == 0) m[254] = num1;
    else m[254] = num2;
    return 0;
}
// n = 5
// 1 1: count = 2
// 2 1: count = 3
// 3 2: count = 4
// 3 4: count = 5