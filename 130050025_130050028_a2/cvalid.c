#include <stdio.h>

// //Basic type int, float, char, enum, void */
// //Constructed types: pointers
// //Constructed types: arrays
// //Constructed type: structs


// /* ------------------------------------------------ */

// /* 1.   Any numeric  type is  compatible with  any other  numeric type
//   (there is an implicit coercion).   Similarly, an enumerated type is
//   compatible with any other numeric type and two enumerated types are
//   compatible with  each other. This  is because enumerated  types are
//   considered to  be ints.   When numeric  types are  converted to
//   each other through an implicit cast. */

// typedef enum {sun, mon, tue, wed, thu, fri, sat} days;
// typedef enum {true, false} boolean;

// int main ()
// {
//   float i; boolean k; days j;
//   j = i;
//   k = j;
// }

// //-------------------------------------------------

// //2. A  void type  is not  compatible with  any other  type. Variables
// //   cannot have the  void type. void* is compatible  with any pointer
// //   type. 

struct s{
  int a;
};

int fd(int i){
  
}

int main ()
{
  struct s p1[4][3], p2[2][3];
  p1-p2;
}

// /* ------------------------------------------------- */

// // 3. In  the case  of pointers  to numeric types,  two types  are the
// // compatible, if they point to  the same types.  This is interesting:
// // numeric  types are  freely  assignable to  each  other, pointer  to
// // numeric types are  not. There is an interesting reason  why this is
// // so.

// typedef int* t;
// typedef int* s;
// typedef float* r;

// int main ()
// {
//   t i; s j; r k; int* l;
//   l = i;
//   j = i;
//   //j = k;
//   //k = j;
// }

// // Pointers to  non-numeric types s and  t are compatible, if  s and t
// // are by themselves compatible.

// // struct types are compatible if they are declared in the same declaration

// typedef struct {int i;} s, t;
// typedef struct {int i;} r;

// int main ()
// {
//   t  i;
//   s  j;
//   r  k;
//   struct {int i;} l;
//   j = i;
//   j = k;
//   j = l;
//   l = k;







// }



// typedef struct {int i;} s, t;
// typedef struct {int i;} r;

// int main ()
// {
//   t*  i;
//   s*  j;
//   r*  k;
//   struct {int i;} *l;
//   j = i; //ok, s, t are compatible types, see below.
//   j = k; //not ok, r and s are not compatible types.
//   l = k; // not ok.
// }



// // ---------------------------------------------------------
// // Whole array assignment is not allowed.
// // A 1d array is a pointer to the elementtype
// // A 2d array is modelled as a pointer to an array of
// // elementtype
// // A 3d array is modelled as a pointer to a 2d array.


// typedef int a[7][8];

// void f(int (*i)[8]) // Notice the parenthesis around *i
// {
// }

// int main ()
// {
//   a j;      // essentially int (*.)[8]

//   f(j);     // therefore ok.
//   int  *i[5][6][7], *k[5][6][7]; // essentially int**.
//   i = j;    // not permitted, incompatible types int (*.)[8] and  int*.[5]
//   i = k;    // whole array assignment not allowed
// }


// /* ----------------------------------------------------- */
// /* Whole arrays can be passed to functions. */


// typedef int arr[7][8][9];

// void f(int(*i)[9])
// {
//   i[3][6] = 455;
// }
// int main ()
// {
//   int j[7][8][9];       
//   f(j[1]);     //   passing int(*.)[9]
// }

// //Case that specially applies to the lab assignment

// struct a{int x;};

// struct b{int x;};


// int main ()
// {
//   struct a i, j;  
//   struct b k;
//   i = j;    
//   i = k;    // incompatible types when assigning to type 
//             // {struct a} from type {struct b}
// }

// /* ----------------------------------------------------- */

// //There are  two names  for the  first struct  below.  "struct  a" and
// //"cell". Similarly there are two  names for the second struct "struct
// //b" and "cell1".
 
// typedef struct a
// {
//   int val;
//   struct a* next;
// } cell;

// typedef struct b
// {
//   int val;
//   struct a* next;
// } cell1;

// main ()
// {
//   cell p; cell1 q;
//   struct a r;
//   p = q;       // Not equal
//   p = r;       // Equal
// }

// /* ------------------------------------------------ */

// /* main () */
// /* { */
// /*   struct {int val} p; struct {int val} q; */
// /*   p = q; // Not equal */
// /* } */

// /* ------------------------------------------------ */
// /* // This type fails because each occurrence of */
// /* // struct {char c; char b;} defines a new type */
// /* // Therefor s and t are different types. However */
// /* // s and q are of the same type. */


// /* typedef struct {char c; char b;} s,q; */
// /* typedef struct {char c; char b;} t; */

// /* void f (s a) */
// /* {   */
// /* } */

// /* main() */
// /* { */
// /*   t b; */
// /*   f(b); */
// /* } */

// /* ------------------------------------------ */


// /* typedef struct a */
// /* { */
// /*   int val; */
// /*   struct a* next; */
// /* } cell; */

// /* typedef struct b */
// /* { */
// /*   int val; */
// /*   struct a* next; */
// /* } cell1; */

// /* int main () */
// /* { */
// /*   cell** p; cell1** q; */
// /*   struct a ** r; */
// /*   p = q; // Not equal */
// /*   p = r; // Equal */
// /* } */


// /* -------------------------------------------- */







// /* 
// Two types t1 and t2 are structurally equivalent if, any one of the following conditions hold:
// 1. t1 and t2 are eqivalent basic types or the same type name.
// 2. t1 and t2 are constructed by applying the same constructor 
//   on structurally equivalent types.
// 3. One of t1 or t2 is a name and the other is the type denoted by this name.
// */

// /* 
// Two types t1 and t2 are name equivalent if, 
// any one of the following conditions hold: 

// 1. t1 and t2 are equivalent basic types or the same type name. 
// 2. t1 and t2 are constructed by applying the same constructor on name equivalent types.  
// */




