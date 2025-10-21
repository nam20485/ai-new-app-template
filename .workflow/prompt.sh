#!/bin/sh

# add if state,ment to branch on different LLM clients
# based on $1 argument passed to the script: "claude" or "opencode"
# otherwise show usage and exit

echo "[prompt.sh - v0.1.1] - invoke LLM client with prompt"
echo "----------------------------------------------------"
echo ""
case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
  claude)
    # claude code to orchestrate project setup
    client="claude"
    cliargs="--verbose --permission-mode bypassPermissions"
    prompt="/orchestrate-project-setup"
    ;;
  opencode)
    # opencode code to orchestrate project setup
    client="opencode"
    cliargs="--prompt"
    prompt="/orchestrate-project-setup"
    ;;
  *)
    echo "Usage: $0 {claude|opencode}"
    exit 1
    ;;
esac

echo "invoking: \"$client $cliargs $prompt\"..."

# execute the orchestration command to the LLM client
$client $cliargs $prompt