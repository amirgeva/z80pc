#include <string.h>
#include "strhash.h"
#include "vector.h"
#include "memory.h"

#define MAX_LENGTH 13

void copy_n(char* dst, const char* src, int n)
{
	for (int i = 0; i < n; ++i, ++src, ++dst)
	{
		*dst = *src;
		if (*src == 0) break;
	}
}

int compare_n(const char* a, const char* b, int n)
{
	for (int i = 0; i < n; ++i)
	{
		if (*a < *b) return -1;
		if (*a > *b) return 1;
		if (*a == 0 && *b == 0) return 0;
	}
	return 0;
}


static word calculate_crc16(const byte* buffer, int len)
{
	word result = 0;
	for (int i = 0; i < len; ++i)
	{
		byte data = buffer[i] ^ (byte)(result & 0xFF);
		data = data ^ (data << 4);
		result = (((word)data << 8) | (result >> 8)) ^ (data >> 4) ^ ((word)data << 3);
	}
	return result;
}

static byte checksum(const char* text)
{
	const byte* bytes = (const byte*)text;
	byte res = 0xFF;
	for (; *bytes; ++bytes)
		res += *bytes;
	return res;
}

typedef struct text_node
{
	word id;
	char text[MAX_LENGTH+1];
} TextNode;

typedef TextNode* TextNodePtr;

struct str_hash_
{
	Vector* strings;
	word last_temporary;
};

StrHash* sh_init()
{
	StrHash* sh = (StrHash*)allocate(sizeof(StrHash));
	sh->strings = vector_new(sizeof(TextNode));
	sh->last_temporary = 0;
	return sh;
}

void sh_shut(StrHash* sh)
{
	vector_shut(sh->strings);
	release(sh);
}

word sh_get(StrHash* sh, const char* text)
{
	const size_t n=strlen(text);
	if (n >= MAX_LENGTH) return 0;
	const word crc = calculate_crc16(text, n);
	if (crc == 0) return 0;
	const word m = vector_size(sh->strings);
	TextNode* cur;
	for (word i = 0; i < m; ++i)
	{
		cur = (TextNode*)vector_access(sh->strings, i);
		if (cur->id == crc)
		{
			if (compare_n(text, cur->text, MAX_LENGTH) != 0)
			{
				#ifdef DEV
				// Same hash, not the same string.  Reject
				printf("'%s' same as '%s'\n", text, cur->text);
				#endif
				return 0;
			}
			return crc;
		}
	}
	TextNode new_node;
	copy_n(new_node.text, text, n);
	new_node.text[n] = 0;
	new_node.id = crc;
	if (!vector_push(sh->strings, &new_node)) return 0;
	return crc;
}

byte sh_text(StrHash* sh, char* text, word id)
{
	const word m = vector_size(sh->strings);
	TextNode* cur;
	for (word i = 0; i < m; ++i)
	{
		cur = (TextNode*)vector_access(sh->strings, i);
		if (cur->id == id)
		{
			copy_n(text, cur->text, MAX_LENGTH);
			return 1;
		}
	}
	return 0;
}

word sh_temp(StrHash* sh)
{
	static const char* hex = "0123456789ABCDEF";
	word id = 0;
	char temp_name[10];
	copy_n(temp_name, "TEMP", 4);
	while (id == 0)
	{
		++(sh->last_temporary);
		byte shift = 12;
		for (byte i = 0; i < 4; ++i)
		{
			temp_name[4 + i] = hex[(sh->last_temporary >> shift) & 15];
			shift -= 4;
		}
		temp_name[8] = 0;
		id = sh_get(sh, temp_name);
	}
	return id;
}

word sh_size(StrHash* sh)
{
	return vector_size(sh->strings);
}
