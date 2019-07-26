#include <iostream>
#include <fstream>
#include <thread>
#include <memory>
#include <unordered_map>
#include <unordered_set>
#include <cxx/xstring.h>
#include <QtWidgets/QApplication>
#include <QtWidgets/qmainwindow.h>
#include <QtWidgets/QWidget>
#include <QtWidgets/QMenu>
#include <QtWidgets/QMenuBar>
#include <QtGui/qfontdatabase.h>
#include <QtWidgets/qlistwidget.h>
#include <QtWidgets/qdockwidget.h>

#include "gui.h"

std::string hex(uint8_t b);
std::string hex16(uint16_t u);

void redraw_screen();

static bool done = false;

typedef std::shared_ptr<QAction> action_ptr;

class QCodeView : public QListWidget
{
  std::unordered_map<uint16_t, int> m_AddressMap;
  std::unordered_set<int> m_Breakpoints;

  void load_source(const cxx::xstring& filename)
  {
    std::ifstream fin(filename);
    if (fin.fail()) return;
    cxx::xstring line;
    int i = 0;
    while (line.read_line(fin))
    {
      line = cxx::xstring_utils::pad(i++, 4, ' ') + ": " + line;
      addItem(QString(line));
    }
  }

  void load_listing(const cxx::xstring& filename)
  {
    std::ifstream fin(filename);
    if (fin.fail()) return;
    cxx::xstring line;
    int i = 0;
    while (line.read_line(fin))
    {
      std::istringstream is(line);
      unsigned addr;
      int line_number;
      is >> std::hex >> addr;
      is >> std::dec >> line_number;
      m_AddressMap[addr] = line_number-1;
    }
  }
public:
  QCodeView(QWidget* parent = nullptr)
    : QListWidget(parent)
  {
    setFont(QFontDatabase::systemFont(QFontDatabase::FixedFont));
    connect(this, &QListWidget::itemDoubleClicked, this, &QCodeView::double_click);
  }

  bool is_breakpoint_at_address(uint16_t addr)
  {
    auto it = m_AddressMap.find(addr);
    if (it == m_AddressMap.end()) return false;
    int line = it->second;
    return m_Breakpoints.count(line) > 0;
  }

  void load_code(const cxx::xstring& source, const cxx::xstring& listing)
  {
    load_source(source);
    load_listing(listing);
  }

  void set_current_address(uint16_t addr)
  {
    auto it = m_AddressMap.find(addr);
    if (it != m_AddressMap.end())
    {
      int line_number = it->second;
      setCurrentRow(line_number);
    }
  }

  void double_click(QListWidgetItem* item)
  {
    int row = currentRow();
    auto it = m_Breakpoints.find(row);
    if (it == m_Breakpoints.end())
    {
      m_Breakpoints.insert(row);
      item->setBackground(Qt::red);
    }
    else
    {
      m_Breakpoints.erase(it);
      item->setBackground(Qt::white);
    }
  }
};

typedef std::vector<cxx::xstring> str_vec;

class TextList : public QListWidget
{
public:
  TextList(QWidget* parent = nullptr)
    : QListWidget(parent)
  {
    setFont(QFontDatabase::systemFont(QFontDatabase::FixedFont));
  }

  void set_values(const str_vec& vals)
  {
    clear();
    for (const auto& v : vals)
      addItem(QString(v));
  }
};


class MainWindow : public QMainWindow
{
  std::vector<action_ptr> m_Actions;
  typedef void (MainWindow::* callback)();
  action_ptr create_action(const char* text, QMenu* add_to_menu = nullptr, callback func = nullptr, const char* shortcut="")
  {
    auto a = std::make_shared<QAction>(text, this);
    m_Actions.push_back(a);
    if (shortcut && *shortcut)
      a->setShortcut(QString(shortcut));
    if (add_to_menu)
      add_to_menu->addAction(a.get());
    if (func)
      connect_menu_item(a, func);
    return a;
  }
  template<typename P>
  void connect_menu_item(action_ptr action, P func)
  {
    connect(action.get(), &QAction::triggered, this, func);
  }

  Z80Context* m_CPU;
  uint8_t*    m_RAM;
  QCodeView   m_CodeView;
  TextList*   m_Registers;
  TextList*   m_Memory;
  uint16_t    m_StopOnSP;
  bool        m_Stopped;
  bool        m_StopOnNext;
  int         m_SkipCount;

  cxx::xstring flags_str(uint8_t F)
  {
    static const cxx::xstring Names = "CNP_H_ZS";
    cxx::xstring res;
    for (int i = 0; i < 8; ++i)
      if ((F & (1 << i)) != 0) res += Names.substr(i, 1);
      else res += "_";
    return res;
  }

  void update_views()
  {
    str_vec lines;
#define ADD(x) lines.push_back(#x+cxx::xstring(": ")+hex(m_CPU->R1.br.x))
#define ADD16(x) lines.push_back(#x+cxx::xstring(": ")+hex16(m_CPU->R1.wr.x))
    ADD(A);
    ADD(B);
    ADD(C);
    ADD(D);
    ADD(E);
    ADD(H);
    ADD(L);
    lines.push_back("F: " + flags_str(m_CPU->R1.br.F));
    ADD16(BC);
    ADD16(DE);
    ADD16(HL);
    ADD16(IX);
    ADD16(IY);
    ADD16(SP);
    lines.push_back("PC: " + hex16(m_CPU->PC));
    m_Registers->set_values(lines);
    lines.clear();
    uint16_t a = 0;
    for (size_t i = 0; i < 256; ++i)
    {
      cxx::xstring line=hex16(a)+": ";
      for (size_t j = 0; j < 16; ++j, ++a)
        line += hex(m_RAM[i * 16 + j]) + " ";
      lines.push_back(line);
    }
    m_Memory->set_values(lines);
  }
public:
  MainWindow(Z80Context* cpu, uint8_t* ram, QWidget* parent = nullptr)
    : QMainWindow(parent)
    , m_CPU(cpu)
    , m_RAM(ram)
    , m_Stopped(true)
    , m_StopOnNext(false)
    , m_StopOnSP(0)
    , m_SkipCount(0)
  {
    QMenu* file = menuBar()->addMenu("&File");
    create_action("&Quit", file, &MainWindow::quit);
    QMenu* run = menuBar()->addMenu("&Run");
    create_action("&Over", run, &MainWindow::step_over, "F10");
    create_action("&Into", run, &MainWindow::step_into, "F11");
    create_action("&Thousand", run, &MainWindow::thousand, "F8");
    create_action("&Continue", run, &MainWindow::cont, "F5");
    create_action("&Return", run, &MainWindow::ret, "Shift+F11");

    setCentralWidget(&m_CodeView);

    QDockWidget* dock = new QDockWidget(tr("Registers"), this);
    dock->setAllowedAreas(Qt::LeftDockWidgetArea | Qt::RightDockWidgetArea);
    m_Registers = new TextList(dock);
    dock->setWidget(m_Registers);
    addDockWidget(Qt::RightDockWidgetArea, dock);

    dock = new QDockWidget(tr("Memory"), this);
    dock->setAllowedAreas(Qt::LeftDockWidgetArea | Qt::RightDockWidgetArea);
    m_Memory = new TextList(dock);
    dock->setWidget(m_Memory);
    addDockWidget(Qt::RightDockWidgetArea, dock);
  }

  void thousand()
  {
    m_SkipCount = 1000;
    m_Stopped = false;
  }

  void step_into()
  {
    m_StopOnNext = true;
    m_Stopped = false;
  }

  void step_over()
  {
    m_StopOnSP = m_CPU->R1.wr.SP-1;
    m_Stopped = false;
  }

  void cont()
  {
    m_Stopped = false;
  }

  void ret()
  {
    m_StopOnSP = m_CPU->R1.wr.SP;
    m_Stopped = false;
  }

  bool stopped() const
  {
    return m_Stopped;
  }

  void load_code(const cxx::xstring& source, const cxx::xstring& listing)
  {
    m_CodeView.load_code(source,listing);
  }

  void set_current_address(uint16_t addr)
  {
    if (m_SkipCount > 0)
    {
      if (--m_SkipCount == 0)
        stop(addr);
    }
    if (m_Stopped) stop(addr);
    if (m_StopOnNext) 
    { 
      m_StopOnNext = false; 
      stop(addr);
    }
    if (m_CodeView.is_breakpoint_at_address(addr)) stop(addr);
    if (m_StopOnSP > 0 && m_CPU->R1.wr.SP > m_StopOnSP)
    {
      stop(addr);
      m_StopOnSP = 0;
    }
  }

  void stop(uint16_t addr)
  {
    m_Stopped = true;
    m_CodeView.set_current_address(addr);
    update_views();
    redraw_screen();
  }

  void closeEvent(QCloseEvent * event)
  {
    done = true;
  }

  void quit()
  {
    done = true;
  }
};

std::unique_ptr<QApplication> app;
std::unique_ptr<MainWindow> win;



void gui_init(Z80Context* cpu, uint8_t* ram)
{
  int argc = 1;
  const char* argv[] = { "test" };
  app = std::make_unique<QApplication>(argc, const_cast<char**>(argv));
  win = std::make_unique<MainWindow>(cpu,ram);
  win->resize(1920, 1080);
  win->setWindowTitle("Debugger");
  win->show();
}

bool gui_sync()
{
  if (!app || !win) return true;
  while (!done && win->stopped())
    app->sync();
  return !done;
}

void gui_load_code(const cxx::xstring& source, const cxx::xstring& listing)
{
  if (win)
    win->load_code(source,listing);
}

void gui_update(Z80Context* cpu)
{
  if (win)
    win->set_current_address(cpu->PC);
}
