import serial

STATUS_ACK = 0
STATUS_LEN_ERROR = 1
STATUS_DATA = 2


def calculate_crc16(buffer):
    """
    Calculate the CRC16 value of a buffer.  Should match the firmware version
    :param buffer: byte array or list of 8 bit integers
    :return: a 16 bit unsigned integer crc result
    """
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
    """
    Create an empty message with a header filled, but without command or data
    :param address: 16 bit unsigned memory address
    :param length:  length of data (0-54)
    :return: a message list
    """
    msg = [0] * 64
    for i in range(4):
        msg[i] = MAGIC[i]
    msg[5] = address & 0xFF
    msg[6] = (address >> 8) & 0xFF
    msg[7] = length & 0xFF
    return msg


def place_crc(msg):
    """
    Calculate the CRC value of a message, and place it in the right spot
    :param msg: Message to be processed.  Modified in place
    :return:
    """
    crc = calculate_crc16(msg[4:62])
    msg[62] = crc & 0xFF
    msg[63] = (crc >> 8) & 0xFF


def create_reset_message():
    msg = create_empty_message(0, 0)
    msg[4] = 3
    place_crc(msg)
    return msg


def create_clock_message():
    msg = create_empty_message(0, 0)
    msg[4] = 4
    place_crc(msg)
    return msg

def create_auto_clock_message():
    msg = create_empty_message(0, 0)
    msg[4] = 5
    place_crc(msg)
    return msg

def create_query_message(address, length):
    """
    Create a memory read message (command 2)
    :param address: 16 bit unsigned memory address
    :param length:  length of data
    :return: Message ready to be sent
    """
    msg = create_empty_message(address, length)
    msg[4] = 2
    place_crc(msg)
    return msg


def create_programming_message(address, data):
    """
    Create a memory write message (command 1)
    :param address: 16 bit unsigned memory address
    :param data:    list of data (up to 54 elements)
    :return: Message ready to be sent
    """
    length = min(52, len(data))
    msg = create_empty_message(address, length)
    msg[4] = 1
    for i in range(length):
        msg[10 + i] = data[i]
    place_crc(msg)
    return msg


def verify_header(msg, n):
    """
    Verify the header of the incoming has a valid MAGIC number
    :param msg: Message buffer
    :param n: How many bytes received so far (1-4)
    :return: True if message header is ok so far
    """
    for i in range(min(4, n)):
        if msg[i] != MAGIC[i]:
            return False
    return True


def verify_crc(msg):
    """
    Check incoming CRC is valid
    :param msg: Incoming message
    :return: True if message is ok
    """
    crc = calculate_crc16(msg[4:62])
    return msg[62] == (crc & 0xFF) and msg[63] == ((crc >> 8) & 0xFF)


def receive_message(ser):
    """
    Wait for an incoming message
    Timeout if nothing arrives in a 1 second interval
    :param ser: Serial port
    :return: Message content, or None
    """
    msg = [0] * 64
    pos = 0
    while True:
        b = ser.read(1)
        if len(b) < 1:
            print(f"Timeout pos={pos}")
            return None
        msg[pos] = int(b[0])
        pos = pos + 1
        if pos <= 4 and not verify_header(msg, pos):
            print("Skipping until header")
            pos = 0
        if pos == 64:
            if not verify_crc(msg):
                print("CRC Failed")
                return None
            return msg


class Mega:
    def __init__(self):
        port = open('megaport.cfg').readline().strip()
        self.ser = serial.Serial(port, 115200, timeout=1)

    def send_message(self, msg):
        if not isinstance(msg, bytes):
            msg = bytes(msg)
        while True:
            self.ser.write(msg)
            response = receive_message(self.ser)
            if response is None:
                continue
            if response[9] == STATUS_ACK:
                break
            if response[9] == STATUS_DATA:
                return response
        return None

    def write_memory(self, address, data):
        n = len(data)
        i = 0
        while i < n:
            print(f"Sending address {i}")
            cur = min(n - i, 52)
            block = data[i:(i + cur)]
            msg = create_programming_message(address, block)
            self.send_message(msg)
            i = i + cur
            address = address + cur

    def read_memory(self, address: int, length: int):
        i = 0
        result = []
        while i < length:
            print(f"Sending address {i}")
            cur = min(length - i, 52)
            msg = create_query_message(address, cur)
            response = self.send_message(msg)
            if response:
                result.extend(response[10:(10 + cur)])
            i = i + cur
            address = address + cur
        return result

    def clock_read_bus(self):
        msg = create_clock_message()
        response = self.send_message(msg)
        if response is None:
            return 0, 0, 0
        address = response[10] | (response[11] << 8)
        data = response[12]
        flags = response[13]
        return address, data, flags

    def auto_clock(self):
        msg = create_auto_clock_message()
        response = self.send_message(msg)