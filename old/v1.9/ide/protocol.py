import re
import sys
import time
from typing import List
import subprocess as sp
from serial import Serial, SerialException
from threading import Thread

READ_DATA = 0
WRITE_DATA = 1
SINGLE_STEP = 2
TRIGGER_INTERRUPT = 3
REFRESH = 5
TRIGGER_RESET = 7
KEYBOARD_INPUT = 6
AUTO_CLOCK = 8
RUN_TO = 9
DEBUG_PRINT = 255

bus_pattern = re.compile(r'([0-9a-f][0-9a-f]) ([0-9a-f][0-9a-f]) ([0-9a-f][0-9a-f]) ([0-9a-f][0-9a-f])')
flags_map = ['IORQ', 'MREQ', 'RD', 'WR', 'M1']


def fmt(data, delimiter):
    if isinstance(data, bytearray):
        return fmt(list(data), delimiter)
    if isinstance(data, int):
        return f'{data:02x}'
    if isinstance(data, bytes):
        return fmt(list(data), delimiter)
    if isinstance(data, list):
        return delimiter.join([f'{b:02x}' for b in data])
    return str(data)


def parse_data(text: str) -> bytes:
    text = text.strip()
    data = []
    i = 0
    while i < len(text) - 1:
        data.append(int(text[i:(i + 2)], 16))
        i += 2
    return bytes(data)


def calculate_crc16(buffer):
    """
    Calculate the CRC16 value of a buffer.  Should match the firmware version
    :param buffer: byte array or list of 8-bit integers
    :return: a 16-bit unsigned integer crc result
    """
    result = 0
    for b in buffer:
        data = int(b) ^ (result & 0xFF)
        data ^= ((data << 4) & 0xFF)
        result = ((data << 8) | (result >> 8)) ^ (data >> 4) ^ (data << 3)
        result &= 0xFFFF
    return result


def crc_list(payload: List[int]):
    crc = calculate_crc16(payload)
    return [crc & 255, (crc >> 8) & 255]


class SerialProtocol:
    MAGIC = [0xEA, 0x91]

    def __init__(self, port: str = 'COM11'):
        self.ser = Serial(port, baudrate=115200, timeout=0.1)
        self.response = bytearray()
        self.logfile = open('prot.log', 'w')
        self.binary_log = open('incoming.bin', 'wb')
        self.thread = Thread(target=self.receive_thread)
        self.thread.start()
        self.buffer = bytearray()

    def shutdown(self):
        self.ser.close()
        self.thread.join()

    def send_payload(self, payload: List[int]):
        self.response = bytearray()
        msg = [0, 0] + self.MAGIC + [len(payload)] + payload + crc_list(payload) + [0, 0]
        self.logfile.write(f'> {fmt(msg, " ")}\n')
        self.logfile.flush()
        self.ser.write(bytes(msg))
        self.ser.flush()

    def write_data(self, address: int, data):
        payload = [WRITE_DATA, address & 255, (address >> 8) & 255] + list(data)
        self.send_payload(payload)

    def read_data(self, address: int, length: int):
        if length > 248:
            print("Invalid read length requested")
            return bytes()
        payload = [READ_DATA, address & 255, (address >> 8) & 255, length]
        for trial in range(5):
            self.send_payload(payload)
            for wait_period in range(100):
                sys.stdout.write('.')
                sys.stdout.flush()
                time.sleep(0.02)
                if len(self.response) > length and self.response[0] == READ_DATA:
                    print("Done")
                    return self.response[1:]
            print("Retrying")
        print("Failed")
        return bytes()

    def trigger_interrupt(self):
        self.send_payload([TRIGGER_INTERRUPT])

    def trigger_reset(self):
        self.send_payload([TRIGGER_RESET])

    def send_input(self, text: str):
        print(f'Sending "{text}"')
        payload = [KEYBOARD_INPUT]
        payload.extend(list(bytes(text, 'ascii')))
        self.send_payload(payload)

    def single_step(self):
        self.send_payload([SINGLE_STEP])
        for i in range(4):
            if len(self.response) > 16 and self.response[0] == SINGLE_STEP:
                break
            time.sleep(0.05)
        return self.response[1:]

    def auto_clock(self):
        self.send_payload([AUTO_CLOCK])

    def run_to(self, address):
        payload = [RUN_TO, address & 255, (address >> 8) & 255]
        self.send_payload(payload)
        if False:
            for wait_period in range(100):
                sys.stdout.write('.')
                sys.stdout.flush()
                time.sleep(0.02)
                if len(self.response) > 0 and self.response[0] == RUN_TO:
                    return self.response[1:]
        return bytes()

    def refresh(self):
        self.send_payload([REFRESH])
        for i in range(20):
            if len(self.response) > 16 and self.response[0] == REFRESH:
                break
            time.sleep(0.05)
        return self.response[1:]

    def process(self):
        while len(self.buffer) > 5 and (self.buffer[0] != self.MAGIC[0] or self.buffer[1] != self.MAGIC[1]):
            del self.buffer[0]
        if len(self.buffer) > 5:
            payload_size = self.buffer[2]
            if len(self.buffer) >= payload_size + 5:
                packet = self.buffer[0:(payload_size + 5)]
                del self.buffer[0:(payload_size + 5)]
                self.logfile.write(f'< {fmt(packet, " ")}\n')
                self.logfile.flush()
                crc = (packet[-1] << 8) | packet[-2]
                verify_crc = calculate_crc16(packet[3:-2])
                if crc != verify_crc:
                    self.logfile.write(f'crc={fmt(crc, " ")}  verify={fmt(verify_crc, " ")}\n')
                    self.logfile.flush()
                    print("CRC Mismatch")
                else:
                    self.logfile.write('valid\n')
                    self.logfile.flush()
                    payload = packet[3:-2]
                    if payload[0] == DEBUG_PRINT:
                        text = payload[1:].decode('ascii').strip()
                        m = re.match(bus_pattern, text)
                        if m:
                            g = m.groups()
                            addr = g[0] + g[1]
                            data = g[2]
                            sflags = ''
                            flags = int(g[3], 16)
                            for i in range(5):
                                if (flags & (1 << i)) == 0:
                                    sflags = sflags + ' ' + flags_map[i]
                            print(f'{addr} {data} {sflags}')
                        else:
                            print(text)
                    else:
                        self.response = payload

    def receive_thread(self):
        try:
            while True:
                data = self.ser.read()
                if data:
                    self.binary_log.write(data)
                    self.binary_log.flush()
                # if data:
                #     sys.stdout.write(f'{data[0]:02X} ')

                # if len(data) > 0:
                #    print(list(data))
                self.buffer.extend(data)
                if len(self.buffer) > 5:
                    self.process()
        except TypeError:
            pass
        except AttributeError:
            pass
        except SerialException:
            pass


class SimulatorProtocol:
    def __init__(self):
        self.process = sp.Popen(['zshell.exe'], stdin=sp.PIPE, stdout=sp.PIPE)

    def _send(self, cmd):
        self.process.stdin.write(bytes(cmd + "\r\n", 'ascii'))
        self.process.stdin.flush()

    def shutdown(self):
        self._send('sd')

    def send_input(self, text: str):
        pass

    def write_data(self, address: int, data: bytes):
        self._send(f"w {address} {fmt(data, '')}")

    def _read_response(self):
        while True:
            result = self.process.stdout.readline().decode('ascii')
            if not result.startswith('['):
                break
        return result

    def read_data(self, address: int, length: int):
        self._send(f"r {address} {length}")
        result = self._read_response()
        return parse_data(result)

    def trigger_interrupt(self):
        pass

    def trigger_reset(self):
        self._send("rst")

    def auto_clock(self):
        self._send("run")

    def run_to(self, addr):
        self._send(f't {addr}')
        result = self._read_response()
        return parse_data(result)

    def single_step(self):
        self._send('s')
        result = self._read_response()
        return parse_data(result)

    def refresh(self):
        return self.read_data(0xF0, 16)

    def send_payload(self):
        pass


protocol_to_use = SerialProtocol


def create_protocol():
    return protocol_to_use()


def set_protocol(protocol_type: str):
    global protocol_to_use
    if protocol_type == "Simulator":
        protocol_to_use = SimulatorProtocol
    elif protocol_type == "Serial":
        protocol_to_use = SerialProtocol
    else:
        raise RuntimeError("Invalid Protocol")


def test_protocol():
    prot = create_protocol()
    prot.read_data(0, 32)
    prot.shutdown()


if __name__ == '__main__':
    test_protocol()
