#include "xmodem.h"

#define SOH 1
#define EOT 4
#define ACK 6
#define NAK 0x15
#define ETB 0x17
#define CAN 0x18

byte send(byte* data);
byte receive(byte*);

unsigned short calcrc16(const byte* ptr, byte count)
{
	unsigned short crc=0;
	byte i;
	while (count-- > 0)
	{
		crc = crc ^ (unsigned short)*ptr++ << 8;
		i = 8;
		do
		{
			if (crc & 0x8000)
				crc = crc << 1 ^ 0x1021;
			else
				crc = crc << 1;
		} while (--i);
	}
	return crc;
}

byte verify_packet(const byte* packet)
{
	unsigned short crc = calcrc16(packet+3, 128);
	unsigned short given = (((unsigned short)packet[131]) << 8) | packet[132];
	return (crc == given ? 1 : 0);
}

void bmemcpy(byte* dst, const byte* src, byte len)
{
	while (len--) *dst++ = *src++;
}

unsigned short xmodem_receive(byte* destination)
{
	unsigned short total = 0;
	byte packet[133];
	byte C = 'C';
	byte data=0;
	byte pos = 0;
	byte fail_count = 0;
	byte last_valid_packet = 0;
	while (1)
	{
		send(&C);
		fail_count = 0;
		while (pos < 133)
		{
			if (receive(&data))
			{
				fail_count = 0;
				if (pos == 0)
				{
					if (data == EOT || data==ETB)
					{
						data = ACK;
						send(&data);
						return total;
					}
					if (data != SOH) continue;
				}
				{
					packet[pos++] = data;
					if (pos == 133)
					{
						if (verify_packet(packet))
						{
							if (packet[1] == last_valid_packet)
							{
								data = NAK;
								send(&data);
							}
							else
							{
								bmemcpy(destination, packet + 3, 128);
								destination += 128;
								total += 128;
								data = ACK;
								send(&data);
								last_valid_packet = packet[1];
							}
						}
						else
						{
						}
						pos = 0;
					}
				}
			}
			else
				if (++fail_count>100) break;
		}
	}
}