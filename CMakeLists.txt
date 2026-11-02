# CMakeList.txt : Top-level CMake project file, do global configuration
# and include sub-projects here.
#
cmake_minimum_required (VERSION 3.8)

# Enable Hot Reload for MSVC compilers if supported.
if (POLICY CMP0141)
  cmake_policy(SET CMP0141 NEW)
  set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")
endif()

project ("CMakeWSL" LANGUAGES C CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Per-platform / per-compiler flags, applied to every target.
add_library(project_options INTERFACE)
if (MSVC)
  target_compile_options(project_options INTERFACE /W4 /permissive- /utf-8)
elseif (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(project_options INTERFACE -Wall -Wextra -Wpedantic)
  if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_compile_options(project_options INTERFACE -fdiagnostics-color=always)
  else()
    target_compile_options(project_options INTERFACE -fcolor-diagnostics)
  endif()
endif()

# Include sub-projects.
add_subdirectory ("CMakeWSL")
