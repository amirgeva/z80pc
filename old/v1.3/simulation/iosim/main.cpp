#include <iostream>
#include <opencv2/opencv.hpp>


int main(int argc, char* argv[])
{
	cv::Mat image(480, 640, CV_8UC1);
	image = 0;
	cv::imshow("vis", image);
	cv::waitKey();
	return 0;
}
