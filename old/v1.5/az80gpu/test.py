import serial


def main():
    s = serial.Serial('COM11', 115200)
    s.write(b'\x1e\x05Hello')
    s.flush()


if __name__=='__main__':
    main()
