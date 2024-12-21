#pragma once

class CircularBuffer
{
	volatile uint8_t m_Data[65536];
	volatile uint16_t m_Write;
	volatile uint16_t m_Read;
public:
	CircularBuffer() 
		: m_Write(0)
		, m_Read(0)
	{}

	bool empty() const { return m_Read == m_Write; }
	bool full() const { return uint16_t(m_Write + 1) == m_Read; }
	bool push(uint8_t data)
	{
		if (!full())
		{
			m_Data[m_Write] = data;
			++m_Write;
			return true;
		}
		return false;
	}
	bool pop(uint8_t& value)
	{
		if (empty()) return false;
		value = m_Data[m_Read];
		++m_Read;
		return true;
	}
};
