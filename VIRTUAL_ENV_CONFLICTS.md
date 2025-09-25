# Managing pip and uv Virtual Environment Conflicts

## The Problem

When developing Python applications that use modern tooling like MCP (Model Context Protocol), you may encounter conflicts between traditional pip-based workflows and newer uv-based tooling. This document explains why these conflicts occur and provides a practical solution.

## Background: The Python Packaging Ecosystem Transition

### Traditional Approach: pip + venv
```bash
python -m venv .venv
.venv/Scripts/activate  # Windows
pip install package-name
```

### Modern Approach: uv
```bash
uv venv
uv add package-name
uv run python script.py
```

## Why Conflicts Occur

### 1. Different Virtual Environment Structures
- **pip + venv**: Creates a standard Python virtual environment with pip installed
- **uv venv**: Creates a virtual environment optimized for uv, often without pip

### 2. Path Resolution Conflicts
When you mix approaches:
```bash
# Create with uv
uv venv .venv

# Activate and try to use pip
.venv/Scripts/activate
pip install something  # May fail or install to wrong location
```

Result: `python` points to the venv, but `pip` may point to the global installation.

### 3. Package Manager Clobbering
- uv expects to manage the entire environment lifecycle
- pip expects a standard Python environment structure
- When tools try to modify the same `.venv` directory, they can corrupt each other's work

## The MCP-Specific Issue

The MCP Inspector tool is hardcoded to use uv commands:
```bash
uv run --with mcp mcp run screenshot.py
```

This creates problems when:
1. You develop using pip-based workflows
2. The MCP Inspector tries to use uv to run your server
3. uv attempts to manage/recreate your pip-created `.venv`
4. File permission conflicts and environment corruption occur

## The Solution: Separate Named Environments

### Step 1: Create Your Development Environment
```bash
# Use a named environment for your development work
python -m venv .venv-yourname
.venv-yourname/Scripts/activate

# Install your dependencies with pip
pip install "mcp[cli]>=1.14.1" "pyautogui>=0.9.54"

# Develop and test your code
python screenshot.py
```

### Step 2: Let MCP Inspector Create Its Own Environment
```bash
# Run the MCP development server
mcp dev screenshot.py
```

The MCP Inspector will:
- Create its own `.venv` directory using uv
- Use this uv-managed environment for tooling
- Not conflict with your named development environment

### Final Project Structure
```
your-project/
├── .venv/                 # Created by uv for MCP Inspector
├── .venv-yourname/        # Your pip development environment
├── screenshot.py
├── pyproject.toml
└── .gitignore
```

### Git Configuration
Add to `.gitignore`:
```
.venv/
.venv-*/
__pycache__/
*.pyc
```

## Benefits of This Approach

1. **No Environment Corruption**: Each tool uses its preferred package manager
2. **Clean Development**: Your development environment stays under your control
3. **Tool Compatibility**: MCP Inspector gets the uv environment it expects
4. **Team Friendly**: Others can use the same pattern with their own named environments
5. **No Configuration Hacks**: No need to override default tool behavior

## Alternative Approaches (Not Recommended)

### Option 1: Pure uv Workflow
```bash
uv venv
uv add dependencies
uv run mcp dev screenshot.py
```
**Downside**: Forces you to adopt uv for all development work

### Option 2: Manual Inspector Configuration
Change MCP Inspector settings to use `python` instead of `uv`
**Downside**: Non-standard, requires manual configuration for each project

### Option 3: Separate Environments with Different Names
Create `.venv-dev` for development and `.venv-tools` for tooling
**Downside**: More complex, requires remembering which environment to use when

## Troubleshooting

### Environment Still Corrupted?
```bash
# Nuclear option: remove all virtual environments
Remove-Item -Recurse -Force .venv*
# Start fresh with the named environment approach
```

### Permission Errors on Windows?
```bash
# Take ownership of the directory
takeown /f .venv /r /d y
icacls .venv /grant administrators:F /t
Remove-Item -Recurse -Force .venv
```

### MCP Inspector Still Using Wrong Environment?
Verify the Inspector created its own `.venv` directory. If not, check that you're running `mcp dev` from the project root directory.

## Conclusion

The Python packaging ecosystem is in transition from pip-based workflows to modern tools like uv. During this transition period, conflicts are inevitable when different tools expect different package managers.

The named environment approach provides a clean solution that respects both workflows without requiring configuration changes or forcing adoption of new tooling across your entire development process.

This pattern can be applied to any situation where modern Python tooling conflicts with traditional development workflows.