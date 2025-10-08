:: 双击这个文件即可。它会调用上面的 PowerShell 脚本。
:: 保存位置：E:\Workshop\Codes\watch-docs\update_deploy.cmd
@echo off
pushd %~dp0
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0\update_deploy.ps1"
set ERR=%ERRORLEVEL%
popd
pause
exit /b %ERR%
