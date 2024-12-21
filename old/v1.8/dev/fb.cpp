#include <iostream>

inline uint16_t calculate_crc16(const uint8_t* buffer, int len)
{
	uint16_t result = 0;
	for (int i = 0; i < len; ++i)
	{
		uint8_t data = buffer[i] ^ uint8_t(result & 0xFF);
		data = data ^ (data << 4);
		result = ((uint16_t(data) << 8) | (result >> 8)) ^ (data >> 4) ^ (uint16_t(data) << 3);
	}
	return result;
}

int main(int argc, char* argv[])
{
	const uint8_t data[] = {
		0xea, 0x91, 0x05, 0xff, 0x41, 0x43, 0x4b, 0x0d, 0x0a, 0xd0
	};
	int n = data[2];
	std::cout << "n=" << n << std::endl;
	int type = data[3];
	std::cout << "type=" << type << std::endl;
	uint16_t crc = calculate_crc16(data + 3, n);
	std::cout << "CRC = " << std::hex << crc << std::endl;
	return 0;
}

