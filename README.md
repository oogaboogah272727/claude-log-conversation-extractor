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
git clone https://github.com/SRKConsulting/claude-log-conversation-extractor.git
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
~/.claude/projects/<project-name>/<session-id>.jsonl
```

Where:
- `~/.claude/` is the Claude configuration directory
- `<project-name>` is derived from your working directory (e.g., `-home-mike-myproject`)
- `<session-id>` is a UUID for each Claude session

### Finding Your Session Logs

```bash
# List all Claude project directories
ls -la ~/.claude/projects/

# Find recent session files
find ~/.claude/projects/ -name "*.jsonl" -type f -mtime -1

# Find logs for a specific project
ls -la ~/.claude/projects/*myproject*/
```

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

Created by [SRK Consulting](https://github.com/SRKConsulting)

## Acknowledgments

- Built for use with [Claude Code](https://github.com/anthropics/claude-code) by Anthropic
- Uses [jq](https://stedolan.github.io/jq/) for JSON processing