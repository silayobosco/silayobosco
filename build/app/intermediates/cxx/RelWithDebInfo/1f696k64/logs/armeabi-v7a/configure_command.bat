@echo off
"C:\\Users\\johnb\\AppData\\Local\\Android\\Sdk\\cmake\\3.22.1\\bin\\cmake.exe" ^
  "-HC:\\Users\\johnb\\flutter\\packages\\flutter_tools\\gradle\\src\\main\\groovy" ^
  "-DCMAKE_SYSTEM_NAME=Android" ^
  "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" ^
  "-DCMAKE_SYSTEM_VERSION=23" ^
  "-DANDROID_PLATFORM=android-23" ^
  "-DANDROID_ABI=armeabi-v7a" ^
  "-DCMAKE_ANDROID_ARCH_ABI=armeabi-v7a" ^
  "-DANDROID_NDK=C:\\Users\\johnb\\AppData\\Local\\Android\\Sdk\\ndk\\27.0.12077973" ^
  "-DCMAKE_ANDROID_NDK=C:\\Users\\johnb\\AppData\\Local\\Android\\Sdk\\ndk\\27.0.12077973" ^
  "-DCMAKE_TOOLCHAIN_FILE=C:\\Users\\johnb\\AppData\\Local\\Android\\Sdk\\ndk\\27.0.12077973\\build\\cmake\\android.toolchain.cmake" ^
  "-DCMAKE_MAKE_PROGRAM=C:\\Users\\johnb\\AppData\\Local\\Android\\Sdk\\cmake\\3.22.1\\bin\\ninja.exe" ^
  "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=C:\\Users\\johnb\\AndroidStudioProjects\\MyApplication\\boda_boda_app\\build\\app\\intermediates\\cxx\\RelWithDebInfo\\1f696k64\\obj\\armeabi-v7a" ^
  "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=C:\\Users\\johnb\\AndroidStudioProjects\\MyApplication\\boda_boda_app\\build\\app\\intermediates\\cxx\\RelWithDebInfo\\1f696k64\\obj\\armeabi-v7a" ^
  "-DCMAKE_BUILD_TYPE=RelWithDebInfo" ^
  "-BC:\\Users\\johnb\\AndroidStudioProjects\\MyApplication\\boda_boda_app\\android\\app\\.cxx\\RelWithDebInfo\\1f696k64\\armeabi-v7a" ^
  -GNinja ^
  -Wno-dev ^
  --no-warn-unused-cli
