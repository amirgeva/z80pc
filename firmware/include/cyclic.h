#pragma once

typedef uint8_t byte;

class CyclicBuffer
{
  byte m_Buffer[256];
  byte m_Read, m_Write;
public:
  CyclicBuffer()
    : m_Read(0)
    , m_Write(0)
  {}

  bool empty() const { return (m_Read == m_Write); }
  bool full() const { return (byte(m_Write + 1) == m_Read); }
  byte size() const { return (m_Write - m_Read); }
  
  void push(byte b)
  {
    if (!full())
      m_Buffer[m_Write++] = b;
  }
  
  byte peek() const
  {
	  if (empty()) return 0;
	  return m_Buffer[m_Read];
  }
  
  byte pop()
  {
    if (empty()) return 0;
    return m_Buffer[m_Read++];
  }
};
