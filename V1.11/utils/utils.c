#include "utils.h"

void exit(int);

word multiply(word a, word b)
{
	if (a == 0 || b == 0) return 0;
	word res = 0;
	while (b > 0)
	{
		if (b & 1) res += a;
		b = b >> 1;
		a = a << 1;
	}
	return res;
}

void error_exit(word line, const char* msg, int rc)
{
#ifdef DEV
	printf("%s\nError in line %d\n", msg, line);
#else
	(void)msg;
	(void)rc;
	(void)line;
#endif
	exit(rc);
}

word min(word a, word b)
{
	return a < b ? a : b;
}

word max(word a, word b)
{
	return a > b ? a : b;
}

