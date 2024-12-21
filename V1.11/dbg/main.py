import sys

import argh
import numpy as np
import serial
import threading
import cv2

done = False


class StateReader:
    def __init__(self):
        self.ser = serial.Serial('COM14', 115200, timeout=1)
        self.terminating = False
        self.thread = threading.Thread(target=self.read_thread)
        self.thread.start()
        self.addr = 0
        self.data = 0
        self.flags = 0

    def shutdown(self):
        self.terminating = True
        self.thread.join()

    def print_state(self):
        flags = ''
        if (self.flags & 0x10) != 0:
            flags += " M1"
        if (self.flags & 0x08) != 0:
            flags += " WR"
        if (self.flags & 0x04) != 0:
            flags += " RD"
        if (self.flags & 0x02) != 0:
            flags += " MREQ"
        if (self.flags & 0x01) != 0:
            flags += " IORQ"
        s = f'{self.addr:04x} {self.data:02x} {flags}'
        print(s)

    @staticmethod
    def magic(buffer: bytearray):
        if len(buffer) < 4:
            return False
        return buffer[0] == 0x12 and buffer[1] == 0x43 and buffer[2] == 0x78 and buffer[3] == 0xFA

    def decode_state(self, buffer: bytearray):
        n = len(buffer)
        while n >= 8:
            if not self.magic(buffer):
                del buffer[0]
            else:
                self.addr = (buffer[4] << 8) | buffer[5]
                self.data = buffer[6]
                self.flags = buffer[7]
                del buffer[0:8]

    def read_thread(self):
        buffer = bytearray()
        while not self.terminating:
            data = self.ser.read(8)
            buffer.extend(data)
            self.decode_state(buffer)


def read_feedback(s: serial.Serial):
    while not done:
        data = s.readall()
        if len(data) > 0:
            sys.stdout.write(data.decode('ascii'))


def kbd():
    ctrl_ser = serial.Serial('COM16', 115200, timeout=0.1)
    feedback_thread = threading.Thread(target=read_feedback(ctrl_ser))
    feedback_thread.start()
    cv2.namedWindow('w')
    img = np.zeros((256, 256), dtype=np.uint8)
    cv2.imshow('w', img)
    while True:
        k = cv2.waitKey(100)
        if k == ord('q'):
            break
        if k == ord('m'):
            ctrl_ser.write(bytes([65] * 500))
            ctrl_ser.flush()
        if k == 32:
            ctrl_ser.write(b'C')
            ctrl_ser.flush()
    global done
    done = True
    feedback_thread.join()


def main():
    kbd_thread = threading.Thread(target=kbd)
    kbd_thread.start()
    sr = StateReader()
    while not done:
        sr.print_state()
    sr.shutdown()
    kbd_thread.join()


if __name__ == '__main__':
    argh.dispatch_command(main)
