#pragma once


class Protocol
{
public:
    static void add_data(byte b);
    static void add_data(const byte* data, uint8_t len);
};

