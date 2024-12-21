#pragma once
typedef unsigned char byte;
typedef unsigned short word;


void cls();
void print_prompt();
byte strlen(const byte* text);
char strcmp(const char* a, const char* b);
byte input_empty();
byte input_read();
byte process_input();