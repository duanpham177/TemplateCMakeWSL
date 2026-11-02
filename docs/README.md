# CMakeWSL – Template build đa nền tảng (Windows + WSL)

Template CMake C++20 build được trên Windows (MSVC) và WSL (nhiều phiên bản GCC/Clang), dùng `CMakePresets.json`.

## Cấu trúc

```
CMakeWSL/
├── CMakeLists.txt          # Project gốc: cờ compiler chung (project_options)
├── CMakePresets.json       # Toàn bộ preset configure/build
├── build-win.bat           # Build 1 preset Windows
├── build-wsl.sh            # Build 1 preset WSL
├── build-wsl-all.sh        # Build mọi preset WSL có compiler
├── build-all.bat           # Build tất cả (Windows + WSL) từ Windows
├── .vscode/settings.json   # Ép CMake Tools dùng presets
├── CMakeWSL/               # Source + CMakeLists của target
└── out/build/<preset>/     # Thư mục build (mỗi preset một thư mục)
```

## CMakeLists

- Gốc: `project(... LANGUAGES C CXX)`, xuất `compile_commands.json`, C++ standard bắt buộc, tắt extension.
- Target `project_options` (INTERFACE) giữ cờ cảnh báo theo compiler:
  - MSVC: `/W4 /permissive- /utf-8`
  - GCC/Clang: `-Wall -Wextra -Wpedantic` + màu diagnostics.
- Mỗi target link `project_options` bằng `target_link_libraries(<target> PRIVATE project_options)`.

## Presets

| Nhóm | Configure preset | Ghi chú |
|---|---|---|
| Windows | `x64-debug`, `x64-release`, `x86-debug`, `x86-release` | MSVC `cl.exe` + Ninja, chỉ khi host là Windows |
| WSL (đơn giản) | `wsl-gcc-debug/release`, `wsl-clang-debug/release` | `gcc`/`clang` mặc định của hệ thống |
| WSL (đa phiên bản) | `wsl-gcc-11/12/13`, `wsl-clang-14/15/16` | Ninja Multi-Config; Debug/Release chọn ở build preset |

Preset ẩn: `windows-base`, `linux-base` (điều kiện theo `hostSystemName`), `wsl-multi-base`.

Build preset đa phiên bản đặt tên `wsl-<compiler>-<ver>-<debug|release>`, ví dụ `wsl-gcc-12-release`.

### Thêm một phiên bản compiler

1. Copy một khối như `wsl-gcc-12` trong `configurePresets`, đổi tên và compiler:
   ```json
   {
     "name": "wsl-gcc-14", "displayName": "WSL GCC 14", "inherits": "wsl-multi-base",
     "cacheVariables": { "CMAKE_C_COMPILER": "gcc-14", "CMAKE_CXX_COMPILER": "g++-14" }
   }
   ```
2. Thêm 2 build preset:
   ```json
   { "name": "wsl-gcc-14-debug",   "configurePreset": "wsl-gcc-14", "configuration": "Debug" },
   { "name": "wsl-gcc-14-release", "configurePreset": "wsl-gcc-14", "configuration": "Release" }
   ```
3. Cài compiler trong WSL: `sudo apt install g++-14`.

`build-wsl-all.sh` suy compiler từ tên preset (`wsl-gcc-14-*` → `g++-14`), nên giữ đúng quy ước đặt tên.

## Yêu cầu

- Windows: Visual Studio (C++ tools), CMake. Ninja lấy từ Visual Studio.
- WSL: `sudo apt install build-essential clang ninja-build cmake`. Ninja Multi-Config cần CMake ≥ 3.17.

## Cách build

### Script

```bat
build-win.bat x64-release                 :: 1 preset Windows (mặc định x64-debug)
build-all.bat                              :: Windows + WSL (distro mặc định)
build-all.bat Ubuntu-22.04 "gcc-1[12]"     :: chỉ định distro và lọc regex
```
```bash
./build-wsl.sh wsl-clang-release          # 1 preset WSL (mặc định wsl-gcc-debug)
./build-wsl-all.sh                         # mọi preset WSL; thiếu compiler thì SKIP
```

`build-wsl-all.sh` in cuối cùng danh sách `OK` / `SKIP` / `FAIL`; exit code khác 0 nếu có `FAIL`. `build-all.bat` cũng trả exit code khác 0 khi có lỗi.

### CMake thủ công

```bash
cmake --preset wsl-gcc-12
cmake --build --preset wsl-gcc-12-release
```

### VS Code

1. Cài extension **CMake Tools** (và **WSL** nếu build trong WSL).
2. Windows: chọn configure preset `x64-debug` ở thanh trạng thái rồi Build.
3. WSL: "WSL: Reopen Folder in WSL", sau đó chọn preset `wsl-*`.

`.vscode/settings.json` đặt `cmake.useCMakePresets` = `always`.

## Chạy kết quả

- Windows: `out\build\x64-debug\CMakeWSL\CMakeWSL.exe`
- WSL (preset đơn giản): `out/build/wsl-gcc-debug/CMakeWSL/CMakeWSL`
- WSL (multi-config): `out/build/wsl-gcc-12/CMakeWSL/Debug/CMakeWSL`

## Lưu ý

- Mỗi preset có thư mục build riêng nên các lần build không ghi đè nhau.
- Cảnh báo `D9025 overriding /W3 with /W4` của MSVC là vô hại.
