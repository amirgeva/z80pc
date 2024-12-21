# IO Serial Protocol

The protocol is packet based, with each packet up to 256 bytes.

## General Packet Structure

A packet is composed of the following bytes:

| Offset | Value                 |
|--------|-----------------------|
| 0      | 0xEA                  |
| 1      | 0x91                  |
| 2      | Length of payload (n) |
| 3..2+n | Payload               |
| 3+n    | LSB of crc16          |
| 4+n    | MSB of crc16          |

Notes:

 * CRC16 is calculated on the payload only (n bytes)


## Payload Structure

The payload is structured as follows:

| Offset | Value      |
|--------|------------|
| 0      | Command    |
| 1..n-1 | Parameters |

## Commands

| Command | Name         | Parameters                       | Response payload         |
|---------|--------------|----------------------------------|--------------------------|
| 0       | Read RAM     | LSB Addr, MSB Addr, Count        | Bytes read               |
| 1       | Write RAM    | LSB Addr, MSB Addr, Data         | None                     |
| 2       | Single Step  | None                             | Instruction Address      |
| 3       | Auto Clock   | None                             | None                     |


Notes:

 * In the write command, the number of bytes to be written is determined by the size of the packet.  All bytes after the address
 * Auto Clock provides a steady clock signal instead of the single stepping mode
 
