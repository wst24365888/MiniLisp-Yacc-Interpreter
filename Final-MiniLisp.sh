bison -d Final-MiniLisp.y
flex Final-MiniLisp.l
gcc -c Final-MiniLisp.tab.c
gcc -c lex.yy.c
gcc lex.yy.o Final-MiniLisp.tab.o -lfl

# ./a.out < Final-MiniLisp.in

for file in ./test_data/*
do
    # ./smli < "$file"
    # echo -e "\n<!-------- ${file##*/} --------!>\n"
    echo -e "\n--------------\n"
    cat "$file"
    echo -e "\noutput =>\n"
    ./a.out < "$file"
done

echo ""

rm Final-MiniLisp.tab.c
rm Final-MiniLisp.tab.h
rm Final-MiniLisp.tab.o
rm lex.yy.c
rm lex.yy.o
rm a.out