#include <iostream>
// #include <print>
using namespace std;

int main()
{
    // Using cout to print plain text
    cout<<"Hello world";
    // The above line prints hello world but it doesnt print a new line afterwords
    // To print a new line after, we need to use \n or endl
    cout<<"Today is a new day!\n";
    cout<<"The city is doing well!"<<endl;

    // Using cout to print a variable
    int age =20;
    cout<< "Xavier is only"<< age <<"Years old!" << endl;

    // In modern ccpp, we have print along with cout
    // But print is part of the header file - print, so we need to include that!
    /*
    print("Hello World");
    std::print("{}",age);
    */
    
    // cpp can also use c style printf for printing
    printf("Hello World"); //This again doesnt print on new lines
    printf("\nAustin is the capital of Texas\n");

    string name = "Nathan Ellis";
    cout << name <<endl;
    return 0;
}