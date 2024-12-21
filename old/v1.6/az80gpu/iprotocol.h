#pragma once

#include <cstdint>

typedef uint8_t byte;

class ProtocolInterface
{
public:
    static void add_data(byte b);
    static void add_data(const byte* data, uint8_t len);
    static void loop();
};
