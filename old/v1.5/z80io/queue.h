#pragma once


template<int SIZE>
class Queue
{
	volatile uint8_t m_Data[SIZE];
	volatile uint16_t m_Write;
	volatile uint16_t m_Read;
	
public:	
	void init()
	{
		m_Write=0;
		m_Read=0;
	}
		
	void push(uint8_t value)
	{
		if (!full())
		{
			m_Data[m_Write]=value;
			m_Write=((m_Write+1)&(SIZE-1));
		}
	}
	
	uint8_t pop()
	{
		if (empty()) return 0;
		uint8_t res = m_Data[m_Read];
		m_Read=((m_Read+1)&(SIZE-1));
		return res;
	}
	
	bool empty() const
	{
		return m_Write==m_Read;
	}

	bool full() const
	{
		uint16_t w=m_Write+1;
		w=(w&(SIZE-1));
		return (w==m_Read);
	}
};
