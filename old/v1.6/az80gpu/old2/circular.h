#pragma once

#include <cstdint>
#include <atomic>

class CircularBuffer
{
	uint8_t* m_Buffer;
	uint32_t m_Size;
	uint16_t m_Mask;
	//volatile uint32_t m_ReadPointer, m_WritePointer;
	std::atomic<uint16_t> m_ReadPointer, m_WritePointer;
public:
	CircularBuffer() : m_Buffer(0), m_Size(0), m_Mask(0), m_ReadPointer(0), m_WritePointer(0) {}
	// Size must be power of 2
	CircularBuffer(uint8_t* buffer, uint32_t size)
		: m_Buffer(buffer)
		, m_Size(size)
		, m_Mask(size - 1)
		, m_ReadPointer(0)
		, m_WritePointer(0)
	{}
	
	void init(uint8_t* buffer, uint32_t size)
	{
		m_Buffer = buffer;
		m_Size = size;
		m_Mask = size - 1;
		m_ReadPointer = 0;
		m_WritePointer = 0;
	}

	bool empty() const
	{
		return m_ReadPointer == m_WritePointer;
	}

	bool full() const
	{
		//return ((m_WritePointer + 1) & m_Mask) == m_ReadPointer;
		return uint16_t(m_WritePointer + 1) == m_ReadPointer;
	}

	uint32_t size() const
	{
		uint16_t res=m_WritePointer;
		res-=m_ReadPointer;
		return res;
		//return (m_WritePointer-m_ReadPointer)&m_Mask;
	}

	void push(uint8_t byte)
	{
		m_Buffer[m_WritePointer++] = byte;
		//m_Buffer[m_WritePointer] = byte;
		//m_WritePointer = (m_WritePointer + 1) & m_Mask;
	}

	uint8_t pop()
	{
		return m_Buffer[m_ReadPointer++];
		//uint8_t r = m_Buffer[m_ReadPointer];
		//m_ReadPointer = (m_ReadPointer + 1) & m_Mask;
		//return r;
	}
};
