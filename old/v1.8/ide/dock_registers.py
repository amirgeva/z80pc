from typing import Dict

from PyQt5.QtCore import Qt
from PyQt5.QtGui import QFont
from PyQt5.QtWidgets import QTreeWidget, QTreeWidgetItem
from pane_widget import PaneWidget


class RegistersDock(PaneWidget):
    def __init__(self):
        super().__init__('Registers', QTreeWidget, Qt.RightDockWidgetArea)
        self.widget.setFont(QFont('Courier New', 18))
        self.widget.setColumnCount(4)
        self.widget.setHeaderLabels(['Name', 'Hex', 'Dec', 'Dec 8'])
        self.regs: Dict[str, int] = {'AF': 0, 'BC': 0, 'DE': 0, 'HL': 0, 'SP': 0, 'IX': 0, 'IY': 0, 'PC': 0}
        self.update()

    def set_data(self, address: int, data: bytes):
        data = list(data)
        self.regs['AF'] = data[0] | (data[1] << 8)
        self.regs['BC'] = data[2] | (data[3] << 8)
        self.regs['DE'] = data[4] | (data[5] << 8)
        self.regs['HL'] = data[6] | (data[7] << 8)
        self.regs['SP'] = data[8] | (data[9] << 8)
        self.regs['IX'] = data[10] | (data[11] << 8)
        self.regs['IY'] = data[12] | (data[13] << 8)
        self.regs['PC'] = address
        self.update()

    def update(self):
        names = sorted(list(self.regs.keys()))
        self.widget.clear()
        for name in names:
            val = self.regs.get(name)
            item = QTreeWidgetItem(self.widget, [name, f'{val:04x}', str(val), f'{val >> 8}:{val & 255}'])
            self.widget.addTopLevelItem(item)
