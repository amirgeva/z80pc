#pragma once

#include <iostream>
#include <fstream>
#include <sstream>
#include <filesystem>
namespace fs = std::filesystem;

static std::fstream g_File;
static bool         g_Writing=false;

inline bool open_write_file(const uint8_t* filename)
{
  g_Writing = true;
  g_File.open(filename, std::ios::out | std::ios::binary);
  return (!g_File.fail());
}

inline bool open_read_file(const uint8_t* filename)
{
  g_Writing = false;
  g_File.open(filename, std::ios::in | std::ios::binary);
  return (!g_File.fail());
}

inline bool open_append_file(const uint8_t* filename)
{
  g_Writing = true;
  g_File.open(filename, std::ios::app | std::ios::binary);
  return (!g_File.fail());
}

inline void close_file()
{
  g_File.close();
}

inline void erase_file(const uint8_t* filename)
{
  std::remove(reinterpret_cast<const char*>(filename));
}

inline void write_file(const uint8_t* buffer, int len)
{
  g_File.write(reinterpret_cast<const char*>(buffer), len);
}

inline uint8_t read_file(uint8_t* buffer, uint8_t len)
{
  g_File.read(reinterpret_cast<char*>(buffer), len);
  return uint8_t(g_File.gcount());
}

inline uint16_t get_file_size(const uint8_t* filename)
{
  return uint16_t(fs::file_size(reinterpret_cast<const char*>(filename)));
}

inline uint16_t get_files_number()
{
  uint16_t res = 0;
  for (const auto& entry : fs::directory_iterator(".")) ++res;
  return res;
}

inline bool get_file_name(uint8_t index, uint8_t* buffer)
{
  for (const auto& entry : fs::directory_iterator("."))
  {
    if (index == 0)
    {
      uint8_t j = 0;
      std::string name=entry.path().filename().string();
      for (auto& c : name)
      {
        buffer[j++] = uint8_t(c);
        if (j == 14)
        {
          buffer[j] = 0;
          break;
        }
      }
      return true;
    }
    --index;
  }
  return false;
}

template<typename F>
inline bool list_files(F f)
{
  for (const auto& entry : fs::directory_iterator("."))
  {
    for (auto& c : entry.path())
      f(c);
    f('\n');
  }
  return true;
}
