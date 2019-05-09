#include <chrono>
#include "protocol.h"

Protocol prot;

unsigned long millis()
{
  static auto start = std::chrono::system_clock::now();
  auto cur = std::chrono::system_clock::now();
  return uint32_t(std::chrono::duration_cast<std::chrono::milliseconds>(cur - start).count());
}
