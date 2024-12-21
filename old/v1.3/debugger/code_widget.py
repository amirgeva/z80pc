from PyQt5.Qsci import QsciScintilla
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *


class CodeWidget(QsciScintilla):
    def __init__(self):
        super().__init__()
        self.setTabWidth(4)
        self.setMarginWidth(1, 100)
        self.setMarginLineNumbers(1, True)
        self.setAutoIndent(True)
        self.font = QFont('Courier New', 18)
        self.setFont(self.font)
        self.setMinimumSize(1024, 600)
        self.path = ''

    def select_line(self, y: int):
        self.setSelection(y-1, 0, y, 0)

    def open_file(self, path):
        try:
            self.setText(open(path).read())
            self.path = path
        except IOError:
            pass

    def on_save(self):
        try:
            if self.path:
                open(self.path,'w').write(self.text())
        except IOError:
            QMessageBox.critical(self,'Error','Failed to write file')