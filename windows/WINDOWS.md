# Claude Desktop MCP Servers on Windows

## Environment: npx

Airbnb Example:
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

AirBnB requires nodejs version 20.18.1 or higher

```shell
node --version
```

If you have an older version, upgrade from https://nodejs.org or use nvm-windows.
```shell
choco upgrade nodejs
```

## Environment: uvx

Custom example
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

This example requires uvx and Git to be installed on Windows.

```shell
uvx --version
git --version
```

To install:
```shell
choco install uv
choco install git
```

**Git PATH Issue**: If `where git` returns nothing, Git is not properly in PATH:
- Add `C:\Program Files\Git\bin` to system PATH
- Or reinstall: `choco install git --force`
- Restart Claude Desktop after PATH changes

For local development, use:
```json
{
  "mcpServers": {
    "mcpserver": {
      "command": "uvx",
      "args": [
        "--from",
        "<path-to-your-local-repo>",
        "mcp-server"
      ]
    }
  }
}
```

### MCP Server Errors on Windows
From [Fixing Claude Desktop MCP Server Connection Issues on Windows: A Complete Guide](https://medium.com/@Snaved88/fixing-claude-desktop-mcp-server-connection-issues-on-windows-a-complete-guide-36e9e17e21fa):

After extensive troubleshooting, we identified two root causes:

* **Environment Isolation**: __Claude Desktop doesn't inherit your full system PATH__

Solution: Use a wrapper for uvx execution instead of direct execution

1. Copy [uv-wrapper.bat](uv-wrapper.bat) to your user directory: `%USERPROFILE%\uv-wrapper.bat`
2. Edit the wrapper file to update paths for your system
3. Modify the mcpServer config as follows:

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

**Note**: Replace `<YourUsername>` with your actual Windows username in the command path.