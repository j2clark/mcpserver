@echo off
rem UV Wrapper for Claude Desktop MCP Server
rem Configure Python environment - UPDATE THESE PATHS FOR YOUR SYSTEM
set PYTHONHOME=C:\Python312
set PATH=C:\Python312\Scripts;C:\Python312;C:\Program Files\Git\bin;%PATH%

rem Configure UV paths - UPDATE THESE PATHS FOR YOUR SYSTEM
set UV_CACHE_DIR=%USERPROFILE%\AppData\Local\uv\cache
set UV_VIRTUALENV=%USERPROFILE%\AppData\Local\uv\venv

rem Execute UVX with all arguments
uvx %*