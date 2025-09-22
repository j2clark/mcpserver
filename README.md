# mcpserver

A Model Context Protocol (MCP) server that provides deployment and system management capabilities to Claude Desktop.

This is a test deployment from repo [j2clark/MCP](https://github.com/j2clark/MCP)

## Prerequisites

- Python 3.8+
- Git
- uvx (via `pip install uv` or `choco install uv`)

## Installation

1. Add the following configuration to your Claude Desktop config file:
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

## Verification

After restarting Claude Desktop, you should see the MCP server connection in the Claude interface. Test by asking Claude to use deployment-related functions.

## Windows Setup

Windows users may encounter PATH and environment issues. See [WINDOWS.md](windows/WINDOWS.md) for detailed Windows-specific setup instructions and troubleshooting.

## Troubleshooting

- Ensure uvx and git are in your system PATH
- Restart Claude Desktop after configuration changes
- Check Claude Desktop logs for connection errors