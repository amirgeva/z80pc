from PyQt5.QtCore import Qt
from PyQt5.QtGui import QFont, QKeyEvent
from PyQt5.QtWidgets import QWidget
from pane_widget import PaneWidget


class InputWidget(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self._callbacks = []
        self.setFocusPolicy(Qt.ClickFocus)

    def add_callback(self, cb):
        self._callbacks.append(cb)

    def keyPressEvent(self, event: QKeyEvent) -> None:
        for cb in self._callbacks:
            cb(event.text())


class InputDock(PaneWidget):
    def __init__(self):
        super().__init__('Input', InputWidget, Qt.BottomDockWidgetArea)
        self.widget.setFont(QFont('Courier New'))

    def add_callback(self, cb):
        self.widget.add_callback(cb)

    def keyPressEvent(self, event: QKeyEvent) -> None:
        self.widget.keyPressEvent(event)
