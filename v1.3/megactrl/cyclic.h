#pragma once

typedef uint8_t byte;

template<uint16_t N>
class CyclicBuffer
{
  enum { MASK=N-1 };
  static inline uint16_t wrap(uint16_t a) { return (a & uint16_t(MASK)); }
  byte m_Buffer[N];
  uint16_t m_Read, m_Write;
public:
  CyclicBuffer()
    : m_Read(0)
    , m_Write(0)
  {}

  bool     empty() const { return (m_Read == m_Write); }
  bool     full() const { return (wrap(m_Write + 1) == m_Read); }
  uint16_t size() const { return wrap(m_Write - m_Read); }
  
  void push(byte b)
  {
    if (!full())
    {
      m_Buffer[m_Write++] = b;
      m_Write=wrap(m_Write);
    }
  }
  
  byte peek() const
  {
	  if (empty()) return 0;
	  return m_Buffer[m_Read];
  }
  
  byte pop()
  {
    if (empty()) return 0;
    byte res=m_Buffer[m_Read++];
    m_Read=wrap(m_Read);
    return res;
  }
};
