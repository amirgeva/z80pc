import cv2
import socket
import numpy as np

import argh


def main():
    cv2.namedWindow("Keyboard")
    img = np.zeros((256, 256), dtype=np.uint8)
    cv2.putText(img, "Keyboard", (20, 100), cv2.FONT_HERSHEY_PLAIN, 2.0, (255, 128, 255), 2)
    cv2.imshow("Keyboard", img)
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    key = 0
    while key != 27:
        key = cv2.waitKeyEx()
        s.sendto(bytes(str(key), "ascii"), ("localhost", 0xEBD))


if __name__ == '__main__':
    argh.dispatch_command(main)
