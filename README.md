# Claude Log Conversation Extractor

A command-line tool to extract and format conversation history from Claude session log files (JSONL format).

## Overview

Claude Code stores session logs in JSONL (JSON Lines) format, containing the full conversation history, metadata, and tool interactions. This script extracts human-readable conversation history from these log files and can output in multiple formats.

## Features

- Extract conversations from Claude session JSONL files
- Multiple output formats: plain text, Markdown, and HTML
- Handles various message structures (supports different Claude versions)
- Preserves timestamps and session metadata
- Clean, readable output suitable for documentation or review

## Installation

```bash
# Clone the repository
git clone https://github.com/oogaboogah272727/claude-log-conversation-extractor.git
cd claude-log-conversation-extractor

# Make the script executable
chmod +x extract_conversation.sh
```

### Requirements

- Bash (4.0+)
- `jq` - Command-line JSON processor
  ```bash
  # Ubuntu/Debian
  sudo apt-get install jq
  
  # macOS
  brew install jq
  
  # Other systems
  # Visit https://stedolan.github.io/jq/download/
  ```

## Usage

```bash
./extract_conversation.sh <jsonl_file> [output_format]
```

### Parameters

- `<jsonl_file>`: Path to the Claude session JSONL file (required)
- `[output_format]`: Output format - `text` (default), `markdown`, or `html` (optional)

### Examples

```bash
# Extract as plain text (default)
./extract_conversation.sh ~/.claude/projects/my-project/session.jsonl

# Extract as Markdown
./extract_conversation.sh ~/.claude/projects/my-project/session.jsonl markdown

# Extract as HTML and save to file
./extract_conversation.sh ~/.claude/projects/my-project/session.jsonl html > conversation.html
```

## Claude Log Files

### Location

Claude stores session logs in the following directory structure:

```
~/.claude/projects/<project-folder>/<session-id>.jsonl
```

Where:
- `~/.claude/` is the Claude configuration directory
- `<project-folder>` is derived from your working directory's full path
- `<session-id>` is a UUID for each Claude session

### Project Folder Naming Convention

The project folder name is created by converting your working directory's absolute path:
- All forward slashes (`/`) are replaced with hyphens (`-`)
- The folder name starts with a hyphen

Examples:
- Working in `/home/alice/projects/my-website` → Logs in `~/.claude/projects/-home-alice-projects-my-website/`
- Working in `/home/bob/My Big Project` → Logs in `~/.claude/projects/-home-bob-My Big Project/`
- Working in `/var/www/client_app` → Logs in `~/.claude/projects/-var-www-client_app/`

Note: The project folder name preserves spaces and special characters from your directory names.

### Finding Your Session Logs

```bash
# List all Claude project directories
ls -la ~/.claude/projects/

# Find recent session files (modified in last 24 hours)
find ~/.claude/projects/ -name "*.jsonl" -type f -mtime -1

# Find logs for a specific project (use wildcards for partial matches)
ls -la ~/.claude/projects/*my-website*/

# Find the most recent session file across all projects
find ~/.claude/projects/ -name "*.jsonl" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-

# Find logs for your current working directory
PROJECT_DIR=$(pwd | sed 's|/|-|g')
ls -la ~/.claude/projects/"$PROJECT_DIR"/
```

### Session File Structure

Each session creates a new JSONL file named with a UUID:
- Example: `6dfe6d65-a9e7-4b2d-95d5-a3057310ecbb.jsonl`
- Files are created when a session starts and appended to throughout the session
- Multiple sessions in the same project directory will create separate files

### JSONL Structure

Each line in the JSONL file is a JSON object representing an event. Common event types include:

```json
{
  "type": "summary",
  "summary": "Session description",
  "timestamp": "2025-07-02T21:55:13.491Z"
}

{
  "type": "user",
  "message": {
    "content": "User's message content",
    "role": "user"
  },
  "timestamp": "2025-07-02T21:55:13.491Z"
}

{
  "type": "assistant",
  "message": {
    "content": "Claude's response",
    "role": "assistant",
    "model": "claude-3-5-sonnet"
  },
  "timestamp": "2025-07-02T21:55:17.902Z"
}
```

## Output Formats

### Text Format
Simple, terminal-friendly output with clear separation between messages.

```
[USER] @ 2025-07-02T21:55:13.491Z
What is the capital of France?

----------------------------------------

[ASSISTANT] @ 2025-07-02T21:55:17.902Z
The capital of France is Paris.

----------------------------------------
```

### Markdown Format
Perfect for documentation or importing into Markdown-based tools.

```markdown
### USER
**Time:** 2025-07-02T21:55:13.491Z

What is the capital of France?

---

### ASSISTANT
**Time:** 2025-07-02T21:55:17.902Z

The capital of France is Paris.

---
```

### HTML Format
Styled HTML output suitable for web viewing or archiving.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

Created by [Mike Olsen](https://github.com/oogaboogah272727)

## Acknowledgments

- Built for use with [Claude Code](https://github.com/anthropics/claude-code) by Anthropic
- Uses [jq](https://stedolan.github.io/jq/) for JSON processing