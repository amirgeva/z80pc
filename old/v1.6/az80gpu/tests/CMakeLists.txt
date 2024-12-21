cmake_minimum_required(VERSION 3.16)
project(test_font)
find_package(OpenCV CONFIG REQUIRED)
add_executable(test_font main.cpp)
target_link_libraries(test_font PRIVATE opencv_ml opencv_dnn opencv_dpm opencv_hdf)

add_executable(test_buffer main_buffer.cpp)
