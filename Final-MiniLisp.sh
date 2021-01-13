# cd /mnt/d/Dropbox/C_C++_C#/Compiler/Final-MiniLisp
cd /mnt/c/Users/Xyphuz/Dropbox/C_C++_C#/Compiler/Final-MiniLisp

bison -d Final-MiniLisp.y
flex Final-MiniLisp.l
gcc -c Final-MiniLisp.tab.c
gcc -c lex.yy.c
gcc lex.yy.o Final-MiniLisp.tab.o -lfl

# ./a.out < Final-MiniLisp.in

for file in /mnt/c/Users/Xyphuz/Dropbox/C_C++_C#/Compiler/Final-MiniLisp/test_data/*
# for file in /mnt/d/Dropbox/C_C++_C#/Compiler/Final-MiniLisp/test_data/*
do
    # ./smli < "$file"
    echo -e "\n<!-------- ${file##*/} --------!>\n"
    ./a.out < "$file"
done

echo ""

rm Final-MiniLisp.tab.c
rm Final-MiniLisp.tab.h
rm Final-MiniLisp.tab.o
rm lex.yy.c
rm lex.yy.o
rm a.out