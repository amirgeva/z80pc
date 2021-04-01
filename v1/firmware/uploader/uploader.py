#!/usr/bin/env python3
'''

    Memory programmer.  Upload using serial port, a ROM image into the
    target memory.  Upload in 54 bytes chunks and verify by reading back

    Usage:   uploader.py  <COM> <FILE>

    Example:  uploader.py COM5 os.bin

'''
import sys
import serial
import time


def calculate_crc16(buffer):
    '''
    Calculate the CRC16 value of a buffer.  Should match the firmware version
    :param buffer: byte array or list of 8 bit integers
    :return: a 16 bit unsigned integer crc result
    '''
    result = 0
    for b in buffer:
        data = int(b) ^ (result & 0xFF)
        data = data ^ ((data << 4) & 0xFF)
        result = ((data << 8) | (result >> 8)) ^ (data >> 4) ^ (data << 3)
        result = result & 0xFFFF
    return result


# Header prefix for messages
MAGIC = [0x12, 0x34, 0x56, 0x78]


def create_empty_message(address, length):
    '''
    Create an empty message with a header filled, but without command or data
    :param address: 16 bit unsigned memory address
    :param length:  length of data (0-54)
    :return: a message list
    '''
    msg = [0] * 64
    for i in range(4):
        msg[i] = MAGIC[i]
    msg[5] = address & 0xFF
    msg[6] = (address >> 8) & 0xFF
    msg[7] = length & 0xFF
    return msg


def place_crc(msg):
    '''
    Calculate the CRC value of a message, and place it in the right spot
    :param msg: Message to be processed.  Modified in place
    :return:
    '''
    crc = calculate_crc16(msg[4:62])
    msg[62] = crc & 0xFF
    msg[63] = (crc >> 8) & 0xFF


def create_reset_message():
    msg = create_empty_message(0,0)
    msg[4]=3
    place_crc(msg)
    return msg


def create_query_message(address, length):
    '''
    Create a memory read message (command 2)
    :param address: 16 bit unsigned memory address
    :param length:  length of data
    :return: Message ready to be sent
    '''
    msg = create_empty_message(address, length)
    msg[4] = 2
    place_crc(msg)
    return msg


def create_programming_message(address, data):
    '''
    Create a memory write message (command 1)
    :param address: 16 bit unsigned memory address
    :param data:    list of data (up to 54 elements)
    :return: Message ready to be sent
    '''
    length = min(54, len(data))
    msg = create_empty_message(address, length)
    msg[4] = 1
    for i in range(length):
        msg[8 + i] = data[i]
    place_crc(msg)
    return msg


def verify_header(msg, n):
    '''
    Verify the header of the incoming has a valid MAGIC number
    :param msg: Message buffer
    :param n: How many bytes received so far (1-4)
    :return: True if message header is ok so far
    '''
    for i in range(min(4, n)):
        if msg[i] != MAGIC[i]:
            return False
    return True


def verify_crc(msg):
    '''
    Check incoming CRC is valid
    :param msg: Incoming message
    :return: True if message is ok
    '''
    crc = calculate_crc16(msg[4:62])
    return msg[62] == (crc & 0xFF) and msg[63] == ((crc >> 8) & 0xFF)


def verify_ack(msg, data):
    '''
    Compare incoming data with the expected values
    :param msg: Incoming message
    :param data: Expected data
    :return: True if they match
    '''
    for i in range(len(data)):
        if msg[8 + i] != data[i]:
            print(f"Sent: {data}")
            print(f"Recv: {msg[8:62]}")
            return False
    return True


def wait_for_result(ser, data):
    '''
    Wait for an incoming message
    Timeout if nothing arrives in a 1 second interval
    Then verify and compare to expected data
    :param ser: Serial port
    :param data: Expected data
    :return: True only if received data matches
    '''
    msg = [0] * 64
    pos = 0
    while True:
        b = ser.read(1)
        if len(b) < 1:
            print(f"Timeout pos={pos}")
            return False
        msg[pos] = int(b[0])
        pos = pos + 1
        if not verify_header(msg, pos):
            print("Skipping until header")
            pos = 0
        if pos == 64:
            if not verify_crc(msg):
                print("CRC Failed")
                return False
            return verify_ack(msg, data)


def main():
    if len(sys.argv) != 3:
        print("Usage: uploader.py <COMPORT> <FILE>")
    else:
        try:
            data = open(sys.argv[2], 'rb').read()
            #ser = serial.serialwin32.Serial(sys.argv[1], baudrate=115200, timeout=1.0)
            ser = serial.Serial(sys.argv[1], baudrate=115200, timeout=5.0)
            time.sleep(5)
            # Split up data into 54 byte chunks
            n = (len(data) + 53) // 54
            queue = []
            start = 0
            for i in range(n):
                stop = min(start + 54, len(data))
                queue.append((start, stop))
                start = stop
            trial = 0
            total_trials = 4
            fail_count = 0
            while len(queue) > 0 and trial < total_trials:
                trial = trial + 1
                print(f"Trial {trial}, Sending {len(queue)} packets")
                print("Write")
                for item in queue:
                    sys.stdout.write(f'{item[0]}\r')
                    sys.stdout.flush()
                    sub = data[item[0]:item[1]]
                    msg = create_programming_message(item[0], sub)
                    ser.write(bytes(msg))
                leftover = []
                time.sleep(4)
                print("Verify")
                for item in queue:
                    sys.stdout.write(f'{item[0]}\r')
                    sys.stdout.flush()
                    sub = data[item[0]:item[1]]
                    msg = create_query_message(item[0], len(sub))
                    ser.write(bytes(msg))
                    if not wait_for_result(ser, sub):
                        fail_count = fail_count + 1
                        print(f"Failed address: {item[0]}")
                        leftover.append(item)
                    if fail_count > 100:
                        break
                queue = leftover
                if fail_count > 10:
                    break
            if len(queue) > 0:
                print(f"Could not send {len(queue)} packets after {total_trials} trials")
            else:
                msg = create_reset_message()
                ser.write(bytes(msg))
        except FileNotFoundError:
            print(f"File not found: {sys.argv[2]}")


if __name__ == '__main__':
    main()
