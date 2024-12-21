import argh
import cv2
import numpy as np


def format_hex(value: int):
    return f'0x{value:02X}'


def print_lut(output, name, data_type, values):
    output.write(f'const {data_type} {name}[] = {{')
    i = 0
    for value in values:
        if (i & 15) == 0:
            output.write('\n\t')
        output.write(format_hex(value))
        if i < (len(values) - 1):
            output.write(',')
        i += 1
    output.write('\n};\n')


def generate_pixel_lut(output):
    lut = []
    for i in range(256):
        pixels = []
        k = i
        for j in range(8):
            pixels.append(255 if k & 1 != 0 else 0)
            k >>= 1
        lut.extend(reversed(pixels))
    print_lut(output, "pixels_lut", "uint8_t", lut)


def calc_bits(row: np.ndarray) -> int:
    value = 0
    for i in range(8):
        value <<= 1
        if row[i] > 0:
            value |= 1
    return value


def main(font_image: str, char_height: int = 16):
    with open('font.inl', 'w') as output:
        char_width: int = 8
        generate_pixel_lut(output)
        image = cv2.imread(font_image, cv2.IMREAD_GRAYSCALE)
        if image is None:
            print("Image not found")
            return
        y = 0
        x = 0
        char_lut = []
        while y < image.shape[0]:
            while x < image.shape[1]:
                sub = image[y:(y + char_height), x:(x + char_width)]
                for i in range(char_height):
                    char_lut.append(calc_bits(sub[i, :]))
                x += char_width
            x = 0
            y += char_height
        print_lut(output, 'font', 'uint8_t', char_lut)


if __name__ == '__main__':
    argh.dispatch_command(main)
