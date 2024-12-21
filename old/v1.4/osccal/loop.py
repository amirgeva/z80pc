import sys
import serial
import threading

done = False
s1 = serial.Serial('COM5', 9600, timeout=0.1)
s2 = serial.Serial('COM7', 9600, timeout=0.1)


def t1():
    with open("t1.txt", 'wb') as f:
        while not done:
            d = s1.read(1)
            if len(d) > 0:
                sys.stdout.write(f'1{d}\r\n')
                f.write(d)
                s2.write(d)
                s2.flush()


def t2():
    with open("t2.txt", 'wb') as f:
        while not done:
            d = s2.read(1)
            if len(d) > 0:
                sys.stdout.write(f'2{d}\r\n')
                f.write(d)
                s1.write(d)
                s1.flush()


def kbd():
    input()
    global done
    done = True


def main():
    th1 = threading.Thread(target=t1)
    th2 = threading.Thread(target=t2)
    thk = threading.Thread(target=kbd)
    th1.start()
    th2.start()
    thk.start()
    thk.join()
    th1.join()
    th2.join()


if __name__ == '__main__':
    main()
