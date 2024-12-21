import time
import serial
import threading

done = False
s1 = serial.Serial('COM7', 9600, timeout=0.1)


def t1():
    with open("t.log", 'wb') as f:
        while not done:
            d = s1.read(1)
            if len(d) > 0:
                f.write(d)
                s1.write(d)
                s1.flush()


def kbd():
    input()
    global done
    done = True


def main():
    th1 = threading.Thread(target=t1)
    thk = threading.Thread(target=kbd)
    for i in range(2500):
        if (i % 100) == 99:
            print(i + 1)
        s1.write(b'AAAAAAAAAA')
    th1.start()
    thk.start()
    thk.join()
    th1.join()


if __name__ == '__main__':
    main()
