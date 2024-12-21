from PyQt5.QtCore import *


class Config:
    def __init__(self):
        self.cfg = QSettings()

    def get(self, name):
        return self.cfg.value(name, '')

    def set(self, name, value):
        self.cfg.setValue(name, value)
        self.cfg.sync()


