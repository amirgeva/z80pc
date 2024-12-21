#include <thread>
#include <chrono>
#include <opencv2/opencv.hpp>
#include <sercom.h>

using namespace std::chrono_literals;
using namespace sercom;

#pragma pack(push, 1)

struct State
{
	uint16_t addr;
	uint8_t data;
	uint8_t flags;

	void print() const
	{
		const char* hex = "0123456789ABCDEF";

		for (int shift = 12; shift >= 0; shift -= 4)
			std::cout << hex[(addr >> shift) & 15];
		std::cout << "  ";

		for (int shift = 4; shift >= 0; shift -= 4)
			std::cout << hex[(data >> shift) & 15];
		std::cout << "  ";

		if ((flags & 0x10) != 0) std::cout << " M1";
		if ((flags & 0x08) != 0) std::cout << " WR";
		if ((flags & 0x04) != 0) std::cout << " RD";
		if ((flags & 0x02) != 0) std::cout << " MREQ";
		if ((flags & 0x01) != 0) std::cout << " IORQ";
		std::cout << std::endl;
	}
};

class StateMonitor
{
	std::shared_ptr<Serial>		m_Serial;
public:
	StateMonitor()
		: m_Serial(Serial::create("COM14",115200))
	{}

	State sample()
	{
		constexpr uint8_t MAGIC[] = { 0x12,0x43,0x78,0xFA };
		const uint8_t c=65;
		m_Serial->send(&c, 1);
		std::vector<uint8_t> buffer, cur;
		buffer.reserve(256);
		size_t pos = 0;
		size_t wait_count = 0;
		size_t fail_count = 0;
		while (true)
		{
			size_t n = m_Serial->data_available();
			if (n == 0)
			{
				std::this_thread::sleep_for(10ms);
				if (++wait_count >= 10)
				{
					wait_count = 0;
					if (++fail_count >= 10) throw std::runtime_error("Failed to sample state");
					m_Serial->send(&c, 1);
				}
			}
			else
			{
				cur.resize(n);
				m_Serial->receive(cur);
				buffer.insert(buffer.end(), cur.begin(), cur.end());
				while (buffer.size() >= 8)
				{
					bool failed = false;
					for (size_t i = 0; i < 4; ++i)
					{
						if (buffer[i] != MAGIC[i])
						{
							buffer.erase(buffer.begin(), buffer.begin() + i + 1);
							failed = true;
							break;
						}
					}
					if (!failed)
					{
						State res;
						res.addr = (uint16_t(buffer[5]) << 8) | buffer[4];
						res.data = buffer[6];
						res.flags = buffer[7];
						return res;
					}
				}
			}
		}
	}
};


int main(int argc, char* argv[])
{
	cv::namedWindow("w");
	try
	{
		auto dbg_serial = Serial::create("COM16", 115200);
		StateMonitor sm;
		int k = 0;
		while ((k=cv::waitKey(10))!=27)
		{
			size_t n = dbg_serial->data_available();
			if (n > 0)
			{
				std::string s(n, ' ');
				dbg_serial->receive((uint8_t*)&s[0], n);
				std::cout << s;
			}
			if (k == 32)
			{
				std::cout << "------------------------------\n";
				State s = sm.sample();
				s.print();
				const uint8_t c = 65;
				dbg_serial->send(&c, 1);
				std::this_thread::sleep_for(10ms);
				s = sm.sample();
				s.print();
			}
		}
	}
	catch (const std::exception& e)
	{
		std::cerr << e.what() << std::endl;
	}
	return 0;
}