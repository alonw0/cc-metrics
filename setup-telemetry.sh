#!/bin/bash

# Claude Code Telemetry Setup Script
# This script configures environment variables for Claude Code telemetry

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Environment variables to add
TELEMETRY_VARS='
# Claude Code Telemetry - Added by setup-telemetry.sh
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
export OTEL_SERVICE_NAME=claude-code
'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Claude Code Telemetry Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Detect shell
SHELL_NAME=$(basename "$SHELL")
echo -e "${BLUE}Detected shell:${NC} $SHELL_NAME"
echo ""

# Determine shell config file
case "$SHELL_NAME" in
    bash)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS uses .bash_profile
            SHELL_CONFIG="$HOME/.bash_profile"
            # Also check for .bashrc
            if [ -f "$HOME/.bashrc" ]; then
                SHELL_CONFIG="$HOME/.bashrc"
            fi
        else
            SHELL_CONFIG="$HOME/.bashrc"
        fi
        ;;
    zsh)
        SHELL_CONFIG="$HOME/.zshrc"
        ;;
    fish)
        SHELL_CONFIG="$HOME/.config/fish/config.fish"
        echo -e "${YELLOW}Note: Fish shell detected. The syntax will be converted automatically.${NC}"
        ;;
    *)
        echo -e "${RED}Unsupported shell: $SHELL_NAME${NC}"
        echo -e "${YELLOW}Please manually add the following to your shell configuration:${NC}"
        echo "$TELEMETRY_VARS"
        exit 1
        ;;
esac

echo -e "${BLUE}Shell configuration file:${NC} $SHELL_CONFIG"
echo ""

# Check if already configured
if grep -q "CLAUDE_CODE_ENABLE_TELEMETRY" "$SHELL_CONFIG" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Claude Code telemetry appears to already be configured in $SHELL_CONFIG${NC}"
    echo ""
    read -p "Do you want to update the configuration? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Skipping configuration update.${NC}"
        exit 0
    fi

    # Remove old configuration
    echo -e "${BLUE}Removing old configuration...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS sed
        sed -i '' '/# Claude Code Telemetry/,/export OTEL_SERVICE_NAME=claude-code/d' "$SHELL_CONFIG"
    else
        # Linux sed
        sed -i '/# Claude Code Telemetry/,/export OTEL_SERVICE_NAME=claude-code/d' "$SHELL_CONFIG"
    fi
fi

# Add configuration
echo -e "${BLUE}Adding telemetry configuration to $SHELL_CONFIG...${NC}"

if [ "$SHELL_NAME" = "fish" ]; then
    # Convert to fish syntax
    FISH_VARS='
# Claude Code Telemetry - Added by setup-telemetry.sh
set -gx CLAUDE_CODE_ENABLE_TELEMETRY 1
set -gx OTEL_METRICS_EXPORTER otlp
set -gx OTEL_LOGS_EXPORTER otlp
set -gx OTEL_EXPORTER_OTLP_PROTOCOL http/protobuf
set -gx OTEL_EXPORTER_OTLP_ENDPOINT http://localhost:4318
set -gx OTEL_SERVICE_NAME claude-code
'
    echo "$FISH_VARS" >> "$SHELL_CONFIG"
else
    echo "$TELEMETRY_VARS" >> "$SHELL_CONFIG"
fi

echo -e "${GREEN}✓ Configuration added successfully!${NC}"
echo ""

# Apply to current session
echo -e "${BLUE}Applying configuration to current session...${NC}"
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
export OTEL_SERVICE_NAME=claude-code

echo -e "${GREEN}✓ Environment variables set for current session${NC}"
echo ""

# Verify
echo -e "${BLUE}Verifying configuration...${NC}"
if [ "$CLAUDE_CODE_ENABLE_TELEMETRY" = "1" ]; then
    echo -e "${GREEN}✓ CLAUDE_CODE_ENABLE_TELEMETRY=${CLAUDE_CODE_ENABLE_TELEMETRY}${NC}"
else
    echo -e "${RED}✗ CLAUDE_CODE_ENABLE_TELEMETRY not set${NC}"
fi

if [ "$OTEL_EXPORTER_OTLP_ENDPOINT" = "http://localhost:4318" ]; then
    echo -e "${GREEN}✓ OTEL_EXPORTER_OTLP_ENDPOINT=${OTEL_EXPORTER_OTLP_ENDPOINT}${NC}"
else
    echo -e "${RED}✗ OTEL_EXPORTER_OTLP_ENDPOINT not set correctly${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo -e "1. ${BLUE}Reload your shell configuration:${NC}"
if [ "$SHELL_NAME" = "bash" ]; then
    echo -e "   ${YELLOW}source $SHELL_CONFIG${NC}"
elif [ "$SHELL_NAME" = "zsh" ]; then
    echo -e "   ${YELLOW}source $SHELL_CONFIG${NC}"
elif [ "$SHELL_NAME" = "fish" ]; then
    echo -e "   ${YELLOW}source $SHELL_CONFIG${NC}"
fi
echo ""
echo -e "   ${BLUE}Or open a new terminal window${NC}"
echo ""
echo -e "2. ${BLUE}Ensure the monitoring stack is running:${NC}"
echo -e "   ${YELLOW}make start${NC}"
echo ""
echo -e "3. ${BLUE}Verify services are healthy:${NC}"
echo -e "   ${YELLOW}make health${NC}"
echo ""
echo -e "4. ${BLUE}Use Claude Code and view metrics at:${NC}"
echo -e "   ${YELLOW}http://localhost:3000${NC} (Grafana)"
echo ""
echo -e "${BLUE}To verify telemetry is working:${NC}"
echo -e "   Run a Claude Code command and check:"
echo -e "   - ${YELLOW}make logs-otel${NC} (should show incoming metrics)"
echo -e "   - ${YELLOW}http://localhost:9090${NC} (Prometheus - query: claude_code_session_total)"
echo ""
