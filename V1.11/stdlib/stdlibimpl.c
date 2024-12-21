#include "stdlib.h"

byte testabi(byte a, const char* name, word b)
{
	byte w=name[0];
	return w+b+a;
}

char strncmp_impl(const char* a, const char* b, byte n)
{
	if (!a && !b) return 0;
	if (!a) return 1;
	if (!b) return -1;
	for(;n>0;--n)
	{
		if (*a==0 && *b==0) return 0;
		if (*a==0) return 1;
		if (*b==0) return -1;
		if (*a==*b) 
		{
			++a;
			++b;
			continue;
		}
		return *a<*b?-1:1;
	}
	return 0;
}

char strcmp_impl(const char* a, const char* b)
{
	return strncmp_impl(a,b,255);
}

typedef struct _DivMod
{
	word a;
	byte b;
} DivMod;

void print_char(byte b);
void div_mod(DivMod* dm);

void print_word_impl(word w)
{
	DivMod dm;
	if (w==0) print_char('0');
	else
	{
		byte i;
		char text[5];
		i=0;
		while (w>0)
		{
			dm.a=w;
			dm.b=10;
			div_mod(&dm);
			text[i++]=48+dm.b;
			w=dm.a;
		}
		do
		{
			print_char(text[--i]);
		} while (i>0);
	}	
}