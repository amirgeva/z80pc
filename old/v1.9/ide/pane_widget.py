from PyQt5.QtWidgets import *


class PaneWidget(QDockWidget):
    def __init__(self, caption, widget_class, dock_area):
        super().__init__(caption)
        self.widget = widget_class(self)
        self.dock_area = dock_area
        self.setObjectName(caption)
        self.setAllowedAreas(dock_area)
        self.setWidget(self.widget)

    def get_dock_area(self):
        return self.dock_area

    def get_widget(self):
        return self.widget
