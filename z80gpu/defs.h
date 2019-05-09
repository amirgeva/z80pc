#pragma once

#include <cstdint>

typedef uint16_t Color;

template<class T>
inline const T& Min(const T& a, const T& b) { return a < b ? a : b; }
