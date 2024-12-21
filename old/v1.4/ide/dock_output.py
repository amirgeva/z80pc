import re
from PyQt5.QtCore import Qt
from PyQt5.QtGui import QFont
from PyQt5.QtWidgets import QListWidget, QListWidgetItem
from pane_widget import PaneWidget

code_line_pattern = r'(\w+\.\w+):(\d+)'


class OutputDock(PaneWidget):
    def __init__(self):
        super().__init__('Output', QListWidget, Qt.BottomDockWidgetArea)
        self.widget.setFont(QFont('Courier New'))
        # self.widget.selectionChanged.connect(self.on_select)
        self.widget.itemDoubleClicked.connect(self.on_item_dblclick)
        self._callbacks = []

    def add_callback(self, cb):
        self._callbacks.append(cb)

    def clear(self):
        self.widget.clear()

    def append_line(self, line: str):
        item = QListWidgetItem(line.strip())
        self.widget.addItem(item)
        self.widget.scrollToItem(item)

    def on_item_dblclick(self, item):
        text = item.text()
        m = re.match(code_line_pattern, text)
        if m:
            g = m.groups()
            filename = g[0]
            line_number = int(g[1])
            for cb in self._callbacks:
                cb(filename, line_number)
