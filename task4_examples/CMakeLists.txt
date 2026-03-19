cmake_minimum_required(VERSION 3.20)

project(Task4_Examples)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

# 示例程序列表
set(EXAMPLE_SOURCES
    01_constant_folding.cpp
    02_mem2reg.cpp
    03_static_call_counter.cpp
)

# 为每个示例程序创建可执行文件
foreach(SOURCE ${EXAMPLE_SOURCES})
    get_filename_component(EXEC_NAME ${SOURCE} NAME_WE)
    add_executable(${EXEC_NAME} ${SOURCE})
    
    # 设置输出目录
    set_target_properties(${EXEC_NAME} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/examples"
    )
endforeach()

# 创建一个目标来构建所有示例
add_custom_target(examples
    COMMAND ${CMAKE_COMMAND} --build . --target all
    DEPENDS ${EXAMPLE_SOURCES}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
