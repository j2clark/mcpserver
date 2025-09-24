# Complete MCP Development Setup Guide
## WSL + Windows + Claude Desktop

This guide consolidates lessons learned from extensive troubleshooting to provide a clean setup for MCP development using WSL with Claude Desktop on Windows.

## Quick Summary: The Key to Success

**CRITICAL**: Keep your Python/WSL tools completely separate from your Windows tools:

- **WSL Environment**: Use WSL's Python, Node.js, and uv for development
- **Windows Environment**: Use Windows tools only for Claude Desktop integration
- **Path Isolation**: Prevent Windows PATH from polluting WSL environment
- **Explicit Paths**: Always use full paths in Claude Desktop configs (never rely on PATH)
- **Wrapper Scripts**: Required for Windows uvx commands that need Git access

**The #1 mistake**: Mixing Windows and WSL tool installations causes mysterious failures.

## Part 1: Clean WSL Environment Setup

### 1.1 Prevent Windows PATH Pollution

**Problem**: Windows paths leak into WSL, causing tool conflicts and path issues.

**Solution**: Configure WSL to isolate environments:

```bash
sudo nano /etc/wsl.conf
```

Add:
```ini
[interop]
appendWindowsPath = false
```

Then restart WSL:
```cmd
wsl --shutdown
```

### 1.2 Install Modern Node.js in WSL

**Critical**: MCP Inspector requires Node.js 18+ in WSL, not Windows Node.js.

```bash
# Remove old Node.js if present
sudo apt remove --purge nodejs npm libnode-dev
sudo apt autoremove

# Install modern Node.js via NodeSource
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installation
node --version  # Should be v18+ or v20+
which node      # Should show /usr/bin/node
```

### 1.3 Install Python Tools in WSL Only

```bash
# Install uv in WSL
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc

# Verify WSL installation
which uv        # Should show /home/username/.local/bin/uv
which python3   # Should show /usr/bin/python3
```

### 1.4 Project Location Strategy

**CRITICAL PATH DECISION**: Choose ONE approach and stick with it throughout your setup.

**Option A: Windows-based Projects (Recommended for PyCharm users)**
- Projects stored in `%USERPROFILE%\git\` (Windows)
- Accessed from WSL via `/mnt/c/Users/<windows-username>/git/`
- **Pros**: Easy PyCharm integration, Windows file explorer access
- **Cons**: Slightly slower WSL file I/O

**Option B: WSL-native Projects**
- Projects stored in `~/projects/` (WSL home)
- **Pros**: Faster WSL file I/O
- **Cons**: Harder to access from Windows tools like PyCharm

**For this guide, we'll use Option A (Windows-based) since it matches PyCharm workflows.**

**Create proper virtual environments:**

```bash
# Use python3 to ensure WSL Python (not Windows Python)
python3 -m venv .venv
source .venv/bin/activate

# Or with uv
uv init
uv venv
uv add mcp[cli]

# Verify you're using WSL tools, not Windows
which python3   # Should show /usr/bin/python3 (WSL)
which python    # Should show .venv/bin/python (virtual env)
which uv        # Should show /home/username/.local/bin/uv (WSL)
```

## Part 2: Windows Environment for Claude Desktop

### 2.1 Required Windows Tools

Claude Desktop runs on Windows and needs these tools installed on Windows:

```cmd
# Install Node.js 20+ on Windows
choco install nodejs --version=20.18.1

# Install uv on Windows (for uvx commands)
choco install uv

# Install Git on Windows (ensure it's in PATH)
choco install git
```

### 2.2 Verify Windows PATH

```cmd
# Check versions
node --version     # Should be 20+
where.exe git      # Should find git.exe
uvx --version      # Should work

# Check PATH includes Git bin directory
echo %PATH% | findstr "Git"
```

### 2.3 Environment Wrapper (Required for Git-based UVX)

**Problem**: Claude Desktop doesn't properly inherit system PATH, causing Git not found errors.

**Solution**: Create a wrapper script that explicitly sets the environment:

**uv-wrapper.bat:**
```batch
@echo off
rem Configure Python environment
set PYTHONHOME=C:\Python312
set PATH=C:\Python312\Scripts;C:\Python312;C:\Program Files\Git\bin;%PATH%

rem Configure UV paths
set UV_CACHE_DIR=%USERPROFILE%\AppData\Local\uv\cache
set UV_VIRTUALENV=%USERPROFILE%\AppData\Local\uv\venv

rem Execute UVX with all arguments
uvx %*
```

## Part 3: Claude Desktop MCP Server Configuration

### 3.1 NPX Servers (Node.js packages)

**Example: AirBnB Server**
```json
{
  "mcpServers": {
    "airbnb": {
      "command": "npx",
      "args": [
        "-y",
        "@openbnb/mcp-server-airbnb",
        "--ignore-robots-txt"
      ]
    }
  }
}
```

**Requirements:**
- Node.js 20.18.1+ installed on Windows
- Internet connection for package download

### 3.2 UVX Servers (Python packages from Git)

**IMPORTANT**: Direct uvx commands with Git repos typically fail on Windows due to PATH issues. Use the wrapper approach.

**Recommended: Wrapper-based Configuration**
```json
{
  "mcpServers": {
    "mcpserver": {
      "command": "%USERPROFILE%\\git\\MCP\\uv-wrapper.bat",
      "args": [
        "--from",
        "git+https://github.com/j2clark/mcpserver.git",
        "mcp-server"
      ]
    }
  }
}
```

**Requirements:**
- `uv` installed on Windows
- Git installed on Windows and in PATH
- Wrapper script from [Section 2.3](#23-environment-wrapper-required-for-git-based-uvx)
- Internet connection for Git clone

**Direct uvx (Usually Fails on Windows):**
```json
{
  "mcpServers": {
    "mcpserver": {
      "command": "uvx",
      "args": [
        "--from",
        "git+https://github.com/j2clark/mcpserver.git",
        "mcp-server"
      ]
    }
  }
}
```
**Note**: This approach typically fails with "Git executable not found" errors on Windows.

### 3.3 Local Development Servers (WSL Projects)

**Prerequisites**: Ensure you have created a virtual environment in your project:
```bash
cd /mnt/c/Users/<windows-username>/git/MCP/notes
python3 -m venv .venv
source .venv/bin/activate
uv add mcp[cli]
```

**Example: Local WSL Project**
```json
{
  "mcpServers": {
    "LocalNotes": {
      "command": "wsl",
      "args": [
        "bash",
        "-c",
        "cd /mnt/c/Users/<windows-username>/git/MCP/notes && source .venv/bin/activate && ~/.local/bin/uv run local.py"
      ]
    }
  }
}
```

**Critical: Use explicit uv path!**

The command above uses `~/.local/bin/uv` instead of just `uv` because:
- WSL bash sessions launched by Claude Desktop don't inherit full PATH
- `bash: uv: command not found` is a common error
- Find your uv path with: `which uv` in WSL

**Key Points:**
- Use `wsl bash -c "command"` to execute WSL commands
- Use `/mnt/c/` paths to access Windows filesystem from WSL
- **Always use explicit tool paths** - this saves hours of debugging!
- Ensure your Python script calls `mcp.run()` at the end

### 3.4 Local Windows Development

**Example: Local Windows Project**
```json
{
  "mcpServers": {
    "local-project": {
      "command": "uvx",
      "args": [
        "--from",
        "%USERPROFILE%\\git\\MCP\\notes",
        "local"
      ]
    }
  }
}
```

## Part 4: Troubleshooting Guide

### 4.1 Common Error Patterns

**Git not found:**
```
Git executable not found. Ensure that Git is installed and available.
```
- **Fix**: Add `C:\Program Files\Git\bin` to Windows system PATH
- **Verify**: `where.exe git` should return git.exe path

**Node.js version too old:**
```
npm WARN EBADENGINE required: { node: '>=20.18.1' }
```
- **Fix**: Upgrade Node.js on Windows to version 20+
- **Verify**: `node --version`

**UV/UVX not found:**
```
'uvx' is not recognized as an internal or external command
```
- **Fix**: Install `uv` on Windows: `choco install uv`
- **Verify**: `uvx --version`

**WSL path issues:**
```
bash: uv: command not found
```
- **Fix**: Use explicit path: `~/.local/bin/uv`
- **Or**: Ensure uv is in WSL PATH

**Silent failures:**
```
Server started and connected successfully
(but no tools appear in Claude)
```
- **Fix**: Ensure your Python script calls `mcp.run()` at the end
- **Check**: MCP server logs for actual errors

### 4.2 Verification Checklist

**Before configuring Claude Desktop:**

```bash
# WSL Environment Check
cd /mnt/c/Users/<windows-username>/git/your-project
which python3    # /usr/bin/python3
which node       # /usr/bin/node
which uv         # /home/username/.local/bin/uv
node --version   # v18+ or v20+

# Test MCP server locally
mcp dev your-server.py
```

```cmd
# Windows Environment Check
node --version   # 20+
where.exe git    # Should find git.exe
uvx --version    # Should work
```

### 4.3 Claude Desktop Management

**Always restart Claude Desktop completely:**
1. Close Claude Desktop window
2. Right-click system tray icon → Quit
3. Restart Claude Desktop
4. Check logs: `%USERPROFILE%\AppData\Roaming\Claude\logs\`

## Part 5: Development Workflow (Windows-based Projects)

### 5.1 Project Creation (Windows)

```cmd
# 1. Create project in your git directory
cd %USERPROFILE%\git
git clone https://github.com/your-repo/my-mcp-server.git
cd my-mcp-server
```

### 5.2 WSL Development Environment

```bash
# 1. Navigate to Windows project from WSL
cd /mnt/c/Users/<windows-username>/git/my-mcp-server

# 2. Set up WSL environment
python3 -m venv .venv
source .venv/bin/activate
uv add mcp[cli]

# 3. Develop and test
mcp dev server.py
```

### 5.3 PyCharm Integration

- Open project: `%USERPROFILE%\git\my-mcp-server`
- Configure Python interpreter: Use WSL interpreter
- Terminal: Can use either Windows cmd or WSL bash

### 5.4 Claude Desktop Configuration

For local development, use the Windows-based path approach:

```json
{
  "mcpServers": {
    "local-project": {
      "command": "wsl",
      "args": [
        "bash",
        "-c",
        "cd /mnt/c/Users/<windows-username>/git/my-mcp-server && source .venv/bin/activate && ~/.local/bin/uv run server.py"
      ]
    }
  }
}
```

## Summary

This setup provides:
- **Clean WSL environment** isolated from Windows
- **Proper Windows tools** for Claude Desktop
- **Multiple MCP server deployment methods**
- **Comprehensive troubleshooting guide**

The key insight is that Claude Desktop runs on Windows but can execute WSL commands, requiring careful environment management and explicit tool paths.