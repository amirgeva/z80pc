cmake_minimum_required(VERSION 3.16)
project(sdbg)

find_package(OpenCV REQUIRED)

add_executable(sdbg main.cpp)
target_include_directories(sdbg PRIVATE ${OpenCV_INCLUDE})
target_link_libraries(sdbg PUBLIC sercom ${OpenCV_LIBS})

add_subdirectory(sercom)