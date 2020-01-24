# PizzaCalc

### Problem Specification:
Write a program called PizzaCalc to identify the most cost-effective pizza one can order
The tool will take a file as an input (eg., “./PizzaCalc pizzainfo.txt”). The format of this file is as
follows. The file is a series of pizza stats, where each entry is 3 lines long. The first line is a name to
identify the pizza (a string with no spaces), the second line is the diameter of the pizza in inches (a float),
and the third line is the cost of the pizza in dollars (another float). After the last pizza in the list, the last
line of the file is the string “DONE”. 

For example:
``DominosLarge
14
7.99
DominosMedium
12
6.99
DONE``

Your program should output a number of lines equal to the number of pizzas, and each line is the pizza’s
name and pizza-per-dollar (in^2/USD). The lines should be sorted in descending order of pizza-per-dollar,
and you must write your own sorting function (you can’t just use the qsort library function). Pizzas with
equal pizza-per-dollar should be sorted alphabetically (e.g. based on the strcmp function). For example:

``DominosLarge 19.26633793
DominosMedium 16.17987633
BobsPizza 11.2
JimsPizza 11.2``

You may assume that pizza names will be less than 64 characters.
To mitigate the divide-by-zero situation, if the cost of the pizza is zero, the pizza-per-dollar should simply
be zero (as the free pizza must be some kind of trap). A pizza with diameter zero will naturally also have
a pizza-per-dollar of zero, as mathematical points are not edible. If your program is fed an empty file the
program should print the following and exit:

``PIZZA FILE IS EMPTY``

This program only optimizes single pizza prices, but of course most pizza deals involve getting multiple pizzas;
we’ll ignore this fact. We also are ignoring toppings, pizza thickness, quality, etc. You are welcome to enhance your
pizza calculator further outside of class. 

Files of the wrong format will not be fed to your program. In all cases, your program should exit with
status 0 (i.e., main should return 0).

#### Important notes:
* You will need to use dynamic allocation/deallocation of memory, and points will be deducted
for improper memory management (e.g., never deallocating any memory that you allocated).
The test script checks for this, but to actually diagnose memory leaks, you use valgrind with
the --leak-check=yes option. (-50% penalty per test with a memory leak!)
* You may NOT read in the input file more than once. This means you cannot count the number
of entries ahead of time -- you will instead need to allocate memory dynamically over the
course of the run. Many programming problems tasks involve input of unknown size that you
cannot simply read twice; dynamic memory management is therefore essential. (-50% penalty
overall!)
* Internally, C’s fopen() call malloc’s space to keep track of the open file. Therefore, to avoid a
memory leak (and the accompanying penalty), you must fclose() the opened file before
exiting.
* Be sure that your main function returns EXIT_SUCCESS (0) on a successful run. (-25% penalty per
test with a non-zero exit status!)
* The self-tester, when looking at floats, checks to see they’re within 0.1%, so you don’t have to
worry if you’re off by a tiny amount from the published outputs due to floating point error.
