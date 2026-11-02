# CMakeList.txt : CMake project for CMakeWSL, include source and define
# project specific logic here.
#

# Add source to this project's executable.
add_executable (CMakeWSL "CMakeWSL.cpp" "CMakeWSL.h")

target_link_libraries(CMakeWSL PRIVATE project_options)

if (CMAKE_VERSION VERSION_GREATER 3.12)
  set_property(TARGET CMakeWSL PROPERTY CXX_STANDARD 20)
endif()

# TODO: Add tests and install targets if needed.
