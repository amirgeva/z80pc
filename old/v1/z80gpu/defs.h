#pragma once

#include <cstdint>

namespace gpu {

  typedef uint16_t Color;

  template<class T>
  inline const T& Min(const T& a, const T& b) { return a < b ? a : b; }

}
