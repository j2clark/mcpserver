# Claude Desktop MCP Server Setup

A Model Context Protocol (MCP) server that provides deployment and system management capabilities to Claude Desktop.

## Quick Installation

### Prerequisites
- Python 3.8+
- Git
- uvx (via `pip install uv` or `choco install uv`)

### Configuration

1. Add the following to your Claude Desktop config file:
   - **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
   - **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`

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

2. Restart Claude Desktop

### Verification

After restarting Claude Desktop, you should see the MCP server connection in the Claude interface. Test by asking Claude to use deployment-related functions.

## Windows Troubleshooting

If you encounter issues on Windows:

### Git PATH Issues
If you get "Git executable not found" errors:
- Add `C:\Program Files\Git\bin` to system PATH
- Or reinstall: `choco install git --force`
- Restart Claude Desktop after PATH changes

### Environment Wrapper Solution
If direct uvx commands fail, use a wrapper script:

1. Create `uv-wrapper.bat`:
```batch
@echo off
set PATH=C:\Python312\Scripts;C:\Python312;C:\Program Files\Git\bin;%PATH%
uvx %*
```

2. Update config to use wrapper:
```json
{
	"mcpServers": {
		"mcpserver": {
			"command": "C:\\Users\\<YourUsername>\\uv-wrapper.bat",
			"args": [
				"--from",
				"git+https://github.com/j2clark/mcpserver.git",
				"mcp-server"
			]
		}
	}
}
```

## Advanced Setup

For development setup with WSL, local projects, and comprehensive troubleshooting, see [WINDOWS_WSL_SETUP.md](WINDOWS_WSL_SETUP.md).

## Support

- Check Claude Desktop logs: `%APPDATA%\Roaming\Claude\logs\`
- Ensure all prerequisites are installed and in PATH
- Restart Claude Desktop completely after configuration changes