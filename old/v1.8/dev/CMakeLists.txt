cmake_minimum_required(VERSION 3.16)
project(dev)

set(CMAKE_CXX_STANDARD 17)

find_package(OpenCV REQUIRED)
add_executable(fb fb.cpp)
include_directories(${OpenCV_INCLUDE_DIRS})
target_link_libraries(fb PRIVATE ${OpenCV_LIBS})
