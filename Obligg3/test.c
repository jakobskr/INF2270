#include <stdio.h>

typedef unsigned char uc;


extern int stringcpy(char* ns, char* os, ...);

int main (void) {
	uc t1[2000], t2[2000];
	char* os = "Hello %% %c %s %#x %d  World 69";
	//printf("nineteen() = %d\n", nineteen());
	//printf("incr(15) = %d\n", incr(15));
	printf("%#x \n", &t1);
	printf("%x \n", 55);
	printf("%d %s | %s \n", stringcpy(t2, os, 'x', "alle fuglar"), os, t2);
	return 0;
}

