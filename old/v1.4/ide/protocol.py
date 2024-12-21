import sys
import time
from typing import List

from serial import Serial, SerialException
from threading import Thread

def fmt(data):
    if isinstance(data, bytearray):
        return fmt(list(data))
    if isinstance(data, int):
        return f'{data:02x}'
    if isinstance(data, bytes):
        return fmt(list(data))
    if isinstance(data, list):
        return ' '.join([f'{b:02x}' for b in data])
    return str(data)

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


def crc_list(payload: List[int]):
    crc = calculate_crc16(payload)
    return [crc & 255, (crc >> 8) & 255]


class Protocol:
    MAGIC = [0xEA, 0x91]

    def __init__(self):
        self.ser = Serial('COM7', 9600, timeout=0.1)
        self.response = bytearray()
        self.logfile = open('prot.log','w')
        self.thread = Thread(target=self.receive_thread)
        self.thread.start()
        self.buffer = bytearray()

    def shutdown(self):
        self.ser.close()
        self.thread.join()

    def send_payload(self, payload: List[int]):
        self.response = bytearray()
        msg = [0, 0] + self.MAGIC + [len(payload)] + payload + crc_list(payload) + [0, 0]
        # print(msg)
        self.logfile.write(f'> {fmt(msg)}\n')
        self.logfile.flush()
        self.ser.write(bytes(msg))
        self.ser.flush()

    def write_data(self, address: int, data):
        payload = [1, address & 255, (address >> 8) & 255] + list(data)
        self.send_payload(payload)

    def read_data(self, address: int, length: int):
        if length > 250:
            print("Invalid read length requested")
            return bytes()
        payload = [0, address & 255, (address >> 8) & 255, length]
        for trial in range(5):
            self.send_payload(payload)
            for wait_period in range(100):
                sys.stdout.write('.')
                time.sleep(0.02)
                if len(self.response) >= length:
                    print("Done")
                    return self.response[0:length]
            print("Retrying")
        print("Failed")
        return bytes()

    def trigger_interrupt(self):
        self.send_payload([3])

    def single_step(self):
        self.send_payload([2])
        for i in range(20):
            if len(self.response) >= 16:
                break
            time.sleep(0.05)
        return self.response

    def refresh(self):
        self.send_payload([5])
        for i in range(20):
            if len(self.response) >= 16:
                break
            time.sleep(0.05)
        return self.response

    def process(self):
        while len(self.buffer) > 5 and (self.buffer[0] != self.MAGIC[0] or self.buffer[1] != self.MAGIC[1]):
            del self.buffer[0]
        if len(self.buffer) > 5:
            payload_size = self.buffer[2]
            if len(self.buffer) >= payload_size + 5:
                packet = self.buffer[0:(payload_size + 5)]
                del self.buffer[0:(payload_size + 5)]
                self.logfile.write(f'< {fmt(packet)}\n')
                self.logfile.flush()
                crc = (packet[-1] << 8) | packet[-2]
                verify_crc = calculate_crc16(packet[3:-2])
                if crc != verify_crc:
                    self.logfile.write(f'crc={fmt(crc)}  verify={fmt(verify_crc)}\n')
                    self.logfile.flush()
                    print("CRC Mismatch")
                else:
                    self.logfile.write('valid\n')
                    payload = packet[3:-2]
                    self.response = payload

    def receive_thread(self):
        try:
            while True:
                data = self.ser.read(1)
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
