@echo off
chcp 65001
cls

echo Love2D 打包脚本
echo 使用你的本地安装路径
echo.

REM 使用你提供的确切路径
set LOVE=E:\OS大作业\love
set Z7=D:\install\7-Zip
set GAME_NAME=MyGame

REM 检查路径
if not exist "%LOVE%\love.exe" (
    echo 错误: 找不到 love.exe 在 %LOVE%
    pause
    exit /b 1
)

if not exist "%Z7%\7z.exe" (
    echo 警告: 找不到 7z.exe，使用内置压缩
)

REM 创建输出目录
if exist "build" rmdir /s /q build
mkdir build

REM 创建临时目录
if exist "_temp" rmdir /s /q _temp
mkdir _temp

echo 复制文件到临时目录...

REM 复制文件
copy *.lua _temp\ >nul
if exist assets xcopy assets _temp\assets /E /I /H /Y >nul
if exist scenes xcopy scenes _temp\scenes /E /I /H /Y >nul

echo 创建 .love 文件...

REM 使用7-Zip创建.love文件
cd _temp
if exist "%Z7%\7z.exe" (
    "%Z7%\7z.exe" a -tzip ..\build\game.love * -r -mx=9 >nul
) else (
    REM 使用PowerShell作为后备
    powershell -Command "Compress-Archive -Path '*' -DestinationPath '..\build\game.zip' -Force" >nul
    if exist "..\build\game.zip" (
        move /y "..\build\game.zip" "..\build\game.love" >nul
    )
)
cd ..

echo 创建可执行文件...

REM 复制love.exe
copy "%LOVE%\love.exe" "build\%GAME_NAME%.exe" >nul

REM 合并.love文件
if exist "build\game.love" (
    copy /b "build\%GAME_NAME%.exe" + "build\game.love" "build\%GAME_NAME%.exe" >nul
)

echo 复制运行库...

REM 复制DLL
copy "%LOVE%\*.dll" build\ >nul

REM 清理临时文件
if exist _temp rmdir /s /q _temp
if exist "build\game.love" del "build\game.love"

echo.
echo ================================
echo 打包完成！
echo.
echo 游戏已打包到 build\ 文件夹
echo 主程序: %GAME_NAME%.exe
echo.
echo 按任意键打开文件夹...
pause >nul

start "" "build"