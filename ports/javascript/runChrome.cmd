@echo off
setlocal
cd /d "%~dp0"
if exist "%localappdata%\google\chrome\application\chrome.exe" (
  start chrome "file://%cd%\ripple_cmd.html"
) else (
  echo Have to run this from Chrome... Sorry
  pause
)
endlocal