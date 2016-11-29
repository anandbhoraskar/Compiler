struct s1{
  int aa,a,b[2];
};

// struct s2{
//   struct s1 a1;
//   struct s1* b;
//   int * a[2][2];
// };

// struct s1 a(){
//   struct s1 v;
//   (&v)->a = 1;
//   (v.b[1]) = 5;
//   v.b[2-1] = 7;
//   v.c = 9;
//   return v;
// }

// int main ()
// {
//   struct s1 obj1;
//   // obj1 = a();
//   a();
//   ;;;;;;;;
//   return 0;
// }    
void fun(){}
int fun1(){}
struct s1 fun2(int a,struct s1 e){
  return e;
}

int main(){
  int a[3],*b,z;
  float c,*d;
  void *f;
  struct s1 e,*e1,e2;
  z=1;
  // a[0] = 0;
  // f = 0;
  // f = a[0];
  // d = 12;
  // !(e);
  !(d);
  !(f);
  // -d;
  // !(fun());
  // printf("%d %d\n",!(d), d);
  // printf("%d %d\n",!(f), f);
  c = -1.4546;
  d = &c;
  // f++;
  // d++;
  c++;
  // (fun())++;
  // (fun1())++;
  // &(fun1());
  // a++;
  // a[1]++;
  // (&a)++;
  // (a+*b)++;
  // e++;
  // -e;
  // !e;
  // &e;
  // *e;
  // e <= e1;
  // e && 1;
  // 1 && e;
  // e && e1;
  // e || 1;
  f && 1;
  f || 1;
  a[0] = 11;
  a[1] = 12;
  a[2] = 13;
  b=&a[2];
  // *b = 1;
  // b = b-1;
  // *b = 1;
  // b = b-1;
  // *b = 1;
  // b = b-1;
  e.aa = 21;
  e.a = 22;
  e.b[0] = 23;
  e.b[1] = 24;
  e1 = &e;
  e2 = fun2(1,fun2(1,e));
  // printf("%f %f %d %d %d %d\n",0.0,-0.0,!0.0,!-0.0,0.0||0,-0.0||0);
  // printf("YOLO:",*b,a[2],*b+a[1],c,b,*d,!1.4,!-0.1,!0.0,0.001 && 1, 0.001 && -1, 0.0001 || 0.000);
  // printf("\n");
  printf(b,b++,b);
  printf("YOLO1:",e2.aa,e2.a,e2.b[0],e2.b[1],e1->aa,e1->a,e1->b[0],e1->b[1]);
  // printf(c++,c);
  // printf("\nYOLO3:",(z + z++) + (z++ + z));
  // printf("%d\n", (z + z++) + z);
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
}