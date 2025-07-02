#!/bin/bash

# Script to extract conversation history from Claude session JSONL files
# Usage: ./extract_conversation.sh <jsonl_file> [output_format] [options]
# Output formats: text (default), markdown, html
# Options: --include-tool-content (show full tool input/output)

if [ $# -lt 1 ]; then
    echo "Usage: $0 <jsonl_file> [output_format] [options]"
    echo "Output formats: text (default), markdown, html"
    echo "Options: --include-tool-content (show full tool input/output)"
    exit 1
fi

JSONL_FILE="$1"
FORMAT="${2:-text}"
INCLUDE_TOOL_CONTENT=false

# Check for options
for arg in "$@"; do
    if [ "$arg" = "--include-tool-content" ]; then
        INCLUDE_TOOL_CONTENT=true
    fi
done

if [ ! -f "$JSONL_FILE" ]; then
    echo "Error: File '$JSONL_FILE' not found"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed"
    exit 1
fi

# Extract session summary if available
SUMMARY=$(jq -r 'select(.type == "summary") | .summary' "$JSONL_FILE" 2>/dev/null | head -1)

# Function to extract content from different message structures
extract_content() {
    jq -r --argjson include_tool "$INCLUDE_TOOL_CONTENT" '
        if .message then
            if .message.content then
                if (.message.content | type) == "array" then
                    .message.content | map(
                        if type == "object" then
                            if .text then .text
                            elif .type == "text" and .text then .text
                            elif .type == "tool_use" then 
                                if $include_tool then
                                    "=== Tool use: " + .name + " ===\n" + (.input | tostring)
                                else
                                    "[Tool use: " + .name + "]"
                                end
                            elif .type == "tool_result" then 
                                if $include_tool then
                                    "=== Tool result ===\n" + (.content // "No result")
                                else
                                    "[Tool result]"
                                end
                            else "[" + (.type // "unknown") + "]"
                            end
                        else .
                        end
                    ) | join("\n")
                else
                    .message.content
                end
            else
                "No content"
            end
        elif .content then
            if (.content | type) == "array" then
                .content | map(
                    if type == "object" then
                        if .text then .text
                        elif .type == "text" and .text then .text
                        elif .type == "tool_use" then 
                            if $include_tool then
                                "=== Tool use: " + .name + " ===\n" + (.input | tostring)
                            else
                                "[Tool use: " + .name + "]"
                            end
                        elif .type == "tool_result" then 
                            if $include_tool then
                                "=== Tool result ===\n" + (.content // "No result")
                            else
                                "[Tool result]"
                            end
                        else "[" + (.type // "unknown") + "]"
                        end
                    else .
                    end
                ) | join("\n")
            else
                .content
            end
        else
            "No content"
        end
    '
}

# Output based on format
case "$FORMAT" in
    "markdown")
        echo "# Claude Session Conversation History"
        echo
        if [ -n "$SUMMARY" ]; then
            echo "## Summary: $SUMMARY"
            echo
        fi
        echo "## Conversation"
        echo
        
        cat "$JSONL_FILE" | while IFS= read -r line; do
            TYPE=$(echo "$line" | jq -r '.type // empty')
            if [[ "$TYPE" == "user" || "$TYPE" == "human" || "$TYPE" == "assistant" ]]; then
                TIMESTAMP=$(echo "$line" | jq -r '.timestamp // empty')
                CONTENT=$(echo "$line" | extract_content)
                
                echo "### ${TYPE^^}"
                [[ -n "$TIMESTAMP" ]] && echo "**Time:** $TIMESTAMP"
                echo
                echo "$CONTENT"
                echo
                echo "---"
                echo
            fi
        done
        ;;
        
    "html")
        cat << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Claude Session History</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        .user, .human { background-color: #e3f2fd; padding: 10px; margin: 10px 0; border-radius: 5px; }
        .assistant { background-color: #f5f5f5; padding: 10px; margin: 10px 0; border-radius: 5px; }
        .timestamp { color: #666; font-size: 0.9em; }
        pre { white-space: pre-wrap; word-wrap: break-word; }
        .summary { background-color: #fff3cd; padding: 10px; border-radius: 5px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <h1>Claude Session Conversation History</h1>
EOF
        
        if [ -n "$SUMMARY" ]; then
            echo "    <div class='summary'><strong>Summary:</strong> $SUMMARY</div>"
        fi
        
        echo "    <div class='conversation'>"
        
        cat "$JSONL_FILE" | while IFS= read -r line; do
            TYPE=$(echo "$line" | jq -r '.type // empty')
            if [[ "$TYPE" == "user" || "$TYPE" == "human" || "$TYPE" == "assistant" ]]; then
                TIMESTAMP=$(echo "$line" | jq -r '.timestamp // empty')
                CONTENT=$(echo "$line" | extract_content | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g')
                
                echo "    <div class='$TYPE'>"
                echo "        <strong>${TYPE^^}</strong>"
                [[ -n "$TIMESTAMP" ]] && echo "        <div class='timestamp'>$TIMESTAMP</div>"
                echo "        <pre>$CONTENT</pre>"
                echo "    </div>"
            fi
        done
        
        cat << EOF
    </div>
</body>
</html>
EOF
        ;;
        
    *)  # Default text format
        echo "=== CLAUDE SESSION CONVERSATION HISTORY ==="
        echo
        if [ -n "$SUMMARY" ]; then
            echo "SUMMARY: $SUMMARY"
            echo
        fi
        echo "CONVERSATION:"
        echo "============="
        echo
        
        cat "$JSONL_FILE" | while IFS= read -r line; do
            TYPE=$(echo "$line" | jq -r '.type // empty')
            if [[ "$TYPE" == "user" || "$TYPE" == "human" || "$TYPE" == "assistant" ]]; then
                TIMESTAMP=$(echo "$line" | jq -r '.timestamp // empty')
                CONTENT=$(echo "$line" | extract_content)
                
                echo "[${TYPE^^}]${TIMESTAMP:+ @ $TIMESTAMP}"
                echo "$CONTENT"
                echo
                echo "----------------------------------------"
                echo
            fi
        done
        ;;
esac