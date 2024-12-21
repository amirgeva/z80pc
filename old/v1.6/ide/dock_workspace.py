import os
from PyQt5.QtCore import Qt
from PyQt5.QtGui import QFont
from PyQt5.QtWidgets import QTreeWidget, QTreeWidgetItem
from pane_widget import PaneWidget


class WorkspaceDock(PaneWidget):
    def __init__(self):
        super().__init__('Workspace', QTreeWidget, Qt.LeftDockWidgetArea)
        self.widget.setFont(QFont('Courier New'))
        self.widget.setColumnCount(1)
        self.root_folder = ''
        self.source_extensions = {'.c', '.h', '.zasm'}
        self.widget.itemDoubleClicked.connect(self.on_double_click)
        self.callbacks=[]

    def add_callback(self, cb):
        self.callbacks.append(cb)

    def set_root_folder(self, root_folder: str):
        self.root_folder = root_folder
        files = os.listdir(self.root_folder)
        files = [f for f in files if os.path.splitext(f)[1] in self.source_extensions]
        self.widget.clear()
        src_item = QTreeWidgetItem(self.widget, ['Sources'])
        self.widget.addTopLevelItem(src_item)
        for filename in files:
            src_item.addChild(QTreeWidgetItem(src_item, [filename]))

    def on_double_click(self, item, column):
        for cb in self.callbacks:
            cb(item.text(0))

    def update(self):
        pass
