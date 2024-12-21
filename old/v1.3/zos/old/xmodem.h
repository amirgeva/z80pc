#pragma once

#ifdef __cplusplus
extern "C" {
#endif

	typedef unsigned char byte;
	unsigned short xmodem_receive(byte* destination);

#ifdef __cplusplus
}
#endif
