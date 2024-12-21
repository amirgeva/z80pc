#include <FS.h>
#include <SD.h>
#include <SPI.h>
#include "zsd.h"

static bool sd_active = false;

#define SD_MOSI      13
#define SD_MISO      34
#define SD_SCK       14
#define SD_CS_PIN    15

SPIClass SPISD(HSPI);

class SDManager
{
  File    m_DirFile;
  File    m_DataFile;
  size_t  m_DataLeft;
public:
  SDManager()
  {}
  
  bool open_dir(const char* path)
  {
    m_DirFile = SD.open(path);
    if (!m_DirFile) return false;
    if (!m_DirFile.isDirectory()) return false;
    return true;
  }

  bool get_next_file(char* name_buffer, int max_len, bool& is_dir, uint32_t& file_size)
  {
    if (max_len<=0) return false;
    name_buffer[0]=0;
    File f = m_DirFile.openNextFile();
    if (!f) return false;
    is_dir = f.isDirectory();
    file_size = f.size();
    const char* name = f.name();
    int len = strlen(name);
    if (len>=max_len) return false;
    strcpy(name_buffer, name);
    return true;
  }

  bool open_data_file(const char* path)
  {
    m_DataFile = SD.open(path);
    if (m_DataFile)
    {
      m_DataLeft=m_DataFile.size();
      return true;
    }
    m_DataLeft=0;
    return false;
  }

  size_t read_data(uint8_t* buffer, size_t max_len)
  {
    size_t cur = min(max_len, m_DataLeft);
    if (cur>0)
      m_DataFile.read(buffer, cur);
    return cur;
  }
} g_SD;


void sd_init()
{
  Serial.println("Initializing SD");
  SPISD.begin(SD_SCK, SD_MISO, SD_MOSI);
  sd_active = SD.begin(SD_CS_PIN,SPISD);
  if (!sd_active)
  {
    Serial.println("SD not found");
    return;
  }
  uint8_t cardType = SD.cardType();
  if(cardType == CARD_NONE)
  {
    Serial.println("No SD card attached");
    return;
  }

    Serial.print("SD Card Type: ");
    if(cardType == CARD_MMC){
        Serial.println("MMC");
    } else if(cardType == CARD_SD){
        Serial.println("SDSC");
    } else if(cardType == CARD_SDHC){
        Serial.println("SDHC");
    } else {
        Serial.println("UNKNOWN");
    }
    uint64_t cardSize = SD.cardSize() / (1024 * 1024);
    Serial.printf("SD Card Size: %lluMB\n", cardSize);
}

void sd_loop()
{
  
}
