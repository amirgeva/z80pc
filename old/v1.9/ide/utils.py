import json
from typing import List

from PyQt5 import QtGui, QtWidgets
from os.path import dirname, basename, isfile, join
import glob


def format_menu_name(name: str) -> str:
    return name.lower().replace(' ', '_')


def create_menu_bar(main_win, mb, description: str):
    data = json.loads(description)
    for menu in data:
        menu_name = menu[0]
        items = menu[1]
        m = mb.addMenu(menu_name)
        for item in items:
            parts = item.split('\t')
            name = parts[0]
            action = QtWidgets.QAction(name, m)
            handler_name = f'on_{format_menu_name(menu_name)}_{format_menu_name(name)}'
            try:
                handler = getattr(main_win, handler_name)
            except AttributeError:
                handler = lambda: main_win.on_dock_window(name)
            action.triggered.connect(handler)
            if len(parts) > 1:
                action.setShortcut(parts[1])
            m.addAction(action)


def get_dock_names():
    modules = glob.glob(join(dirname(__file__), "*.py"))
    docks: List[str] = [basename(f)[:-3] for f in modules if isfile(f)]
    docks = [d for d in docks if d.startswith('dock_')]
    items = [f'{d[5:].capitalize()}' for d in docks]
    return docks, items


def generate_dock_items():
    _, items = get_dock_names()
    items = [f'"{item}"' for item in items]
    return ','.join(items)
