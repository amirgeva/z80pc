from PyQt5.QtCore import Qt
from PyQt5.QtGui import QFont
from PyQt5.QtWidgets import QTextEdit
from pane_widget import PaneWidget


class MemoryDock(PaneWidget):
    def __init__(self):
        super().__init__('Memory', QTextEdit, Qt.RightDockWidgetArea)
        self.widget.setFont(QFont('Courier New'))
        self.ram = [0] * 65536
        self.update()

    def set_data(self, address: int, data: bytes):
        data = list(data)
        for i in range(len(data)):
            self.ram[i + address] = data[i]
        self.update()

    def get_data(self, address: int, length: int):
        return bytes(self.ram[address:(address + length)])

    def update(self):
        lines = []
        i = 0
        while i < 65536:
            row = self.ram[i:(i + 16)]
            row = [f'{b:02X}' for b in row]
            lines.append(f'{i:04x} {" ".join(row)}')
            i = i + 16
        self.widget.setPlainText('\n'.join(lines))
