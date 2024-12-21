#include <opencv2/opencv.hpp>
#include "../font.h"

int main(int argc, char* argv[])
{
	cv::Mat image(16, 8, CV_8UC1);
	int c = 65;
	int i = c * 16;
	for (int j = 0; j < 16; ++j)
	{
		uint8_t* row = image.ptr(j);
		int k = font[i + j];
		for (int l = 0; l < 8; ++l)
		{
			row[l] = pixels_lut[8 * k + l];
		}
	}
	cv::imshow("vis", image);
	cv::waitKey();
	return 0;
}
