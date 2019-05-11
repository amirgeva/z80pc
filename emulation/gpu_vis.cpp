#include <opencv2/opencv.hpp>
#include <chrono>
#include <protocol.h>
#include <cxx/xstring.h>

extern Protocol prot;

void screen_to_image(const Screen& scr, cv::Mat& image)
{
  const Color* ptr = scr.get_buffer();
  uint8_t* dst = image.data;
  for (int i = 0; i < (WIDTH * HEIGHT); ++i)
  {
    const Color& c = ptr[i];
    *dst++ = ((c & 0x000F) << 4) | (c & 0x000F);
    *dst++ = ((c & 0x01F0) >> 1) | ((c & 0x01F0) >> 5);
    *dst++ = ((c & 0x3E00) >> 6) | ((c & 0x3E00) >> 10);
  }
}

std::string str(double d)
{
  std::ostringstream os;
  os << d;
  std::string s = os.str();
  int p = int(s.find('.'));
  if (p > 0) s = s.substr(0, p + 2);
  return s;
}


cv::Mat image(HEIGHT, WIDTH, CV_8UC3);
auto last = std::chrono::system_clock::now();
double fps = 30;

void vis_init()
{
  cv::namedWindow("scr", cv::WINDOW_NORMAL);
}

void vis_draw(uint8_t& key)
{
  screen_to_image(prot.get_screen(), image);
  auto cur = std::chrono::system_clock::now();
  double dt = 0.001 * std::chrono::duration_cast<std::chrono::milliseconds>(cur - last).count();
  last = cur;
  fps = 0.95 * fps + 0.05 / dt;
  //cv::putText(image, str(fps), cv::Point(10, 10), CV_FONT_HERSHEY_PLAIN, 1, cv::Scalar(255, 255, 255, 255), 1);
  //static int frame_num = 0;
  //cxx::xstring filename = "frame_" + cxx::xstring_utils::pad(++frame_num, 6, '0') + ".png";
  //cv::imwrite(filename, image);
  cv::imshow("scr", image);
  int k = cv::waitKey(10);
  if (k > 0) key = uint8_t(k & 255);
}

void redraw_screen()
{
  uint8_t key;
  vis_draw(key);
}

uint8_t vis_wait(int ms)
{
  int k= cv::waitKey(ms);
  if (k > 0) return uint8_t(k & 255);
  return 0;
}