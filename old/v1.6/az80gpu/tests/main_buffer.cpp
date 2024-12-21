#include <iostream>
#include <thread>
#include <random>

class RandomGenerator
{
	std::mt19937_64 engine;
	std::uniform_int_distribution<int> uniform;
public:
	RandomGenerator() 
		: engine(1) 
		, uniform(0,255)
	{}
	uint8_t gen()
	{
		return uint8_t(uniform(engine) & 255);
	}
};

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
	uint8_t pop()
	{
		if (empty()) return 0;
		uint8_t res = m_Data[m_Read];
		++m_Read;
		return res;
	}
};

CircularBuffer queue;
bool done = false;

int total_bytes = 0;
int total_fulls = 0;
int total_empties = 0;

void Producer()
{
	RandomGenerator rnd;
	while (!done)
	{
		if (!queue.full())
		{
			uint8_t value = rnd.gen();
			queue.push(value);
			++total_bytes;
		}
		else ++total_fulls;
	}
}

void Consumer()
{
	RandomGenerator rnd;
	while (!done)
	{
		if (!queue.empty())
		{
			uint8_t value = queue.pop();
			uint8_t expected = rnd.gen();
			if (value != expected)
			{
				std::cout << "Failed\n";
			}
		}
		else total_empties++;
	}
}

int main(int argc, char* argv[])
{
	std::thread consumer_thread(Consumer);
	std::thread producer_thread(Producer);
	std::cin.ignore();
	done = true;
	producer_thread.join();
	consumer_thread.join();
	std::cout << "Total bytes " << total_bytes << std::endl;
	std::cout << "Total fulls " << total_fulls << std::endl;
	std::cout << "Total empties " << total_empties << std::endl;
	return 0;
}
