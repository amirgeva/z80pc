#pragma once

typedef unsigned char byte;
typedef unsigned short word;

void cls();
void print_text(const char* text);
void print_word(word w);
byte strlen(const char* text);
byte input_empty();
byte input_read();
byte strcmp(const char* a, const char* b);
byte strncmp(const char* a, const char* b, byte n);
void newline();
word rng();
void gpu_block(const byte* data);
void gpu_byte(const byte* data);
void gpu_flush();
void gpu_clear();
word timer();
byte list_dir(const byte* path, byte* filename, word* size);
byte list_next(byte* filename, word* size);
byte open_file(const byte* path, byte write);
word read_file(byte handle, byte* buffer, word size);
byte close_file(byte handle);
void bounds_check();
void load_sprites(const byte* path, byte index);
