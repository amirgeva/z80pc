import sys

from PyQt5.QtCore import QCoreApplication
from PyQt5.QtWidgets import QApplication
from main_window import MainWindow
from protocol import set_protocol


def main():
    if len(sys.argv) > 1:
        set_protocol(sys.argv[1])
    app = QApplication(sys.argv)
    QCoreApplication.setOrganizationName("MLGSoft")
    QCoreApplication.setOrganizationDomain("mlgsoft.com")
    QCoreApplication.setApplicationName("z80 IDE")
    mw = MainWindow()
    mw.show()
    app.exec()


if __name__ == '__main__':
    main()
