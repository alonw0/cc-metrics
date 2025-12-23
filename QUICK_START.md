# Quick Start Guide

Get Claude Code metrics running in under 5 minutes!

## 🚀 One-Command Setup

```bash
# 1. Create data directories
make setup

# 2. Start the monitoring stack
make start

# 3. Configure Claude Code telemetry (interactive)
make setup-telemetry

# 4. Access Grafana
open http://localhost:3000
```

Login with `admin/admin` and navigate to the **Claude Code Metrics** dashboard.

## ✨ What Just Happened?

### Step 1: `make setup`
- Created `data/prometheus/`, `data/grafana/`, `data/loki/`, and `data/otel-logs/` directories
- Set proper permissions for Docker containers
- Ready for persistent data storage

### Step 2: `make start`
Started five Docker containers:
- **OpenTelemetry Collector** (localhost:4318) - Receives metrics and logs from Claude Code
- **Prometheus** (localhost:9090) - Stores time-series metrics
- **Loki** (localhost:3100) - Stores log data for log-based metrics
- **Promtail** - Ships logs from OTel to Loki
- **Grafana** (localhost:3000) - Visualizes metrics and logs

### Step 3: `make setup-telemetry`
The interactive script:
1. Detected your shell (bash/zsh/fish)
2. Added environment variables to your shell config
3. Applied settings to current session
4. Verified configuration

**Environment variables configured:**
```bash
CLAUDE_CODE_ENABLE_TELEMETRY=1
OTEL_METRICS_EXPORTER=otlp
OTEL_LOGS_EXPORTER=otlp
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
OTEL_SERVICE_NAME=claude-code
```

### Step 4: Access Grafana
- **URL**: http://localhost:3000
- **Username**: admin
- **Password**: admin (change on first login)
- **Dashboard**: Dashboards → Claude Code Metrics

## 📊 Dashboard Features

### Metrics Tracked
- **Sessions**: Total Claude Code sessions
- **Tokens**: Input, output, cache read/creation
- **Costs**: Real-time USD cost tracking
- **Code Changes**: Lines of code accepted
- **Git Activity**: Commits and PRs
- **Performance**: Cache efficiency, productivity ratio
- **Prompt Length**: Average character count of user prompts

### Key Panels
- **Cache Efficiency**: Percentage of tokens served from cache (saves money!)
- **Productivity Ratio**: CLI time / User time (higher = Claude doing more work)
- **Cost per 1K Tokens**: Track your spending per 1000 output tokens
- **Peak Leverage**: Maximum productivity achieved in time window
- **Average Prompt Length**: Character count of your prompts (via Loki logs)
- **Token Distribution**: Pie chart showing token types
- **Cost Over Time**: Track spending trends

## 🔍 Verify Everything Works

```bash
# 1. Check service health
make health

# Expected output:
# ✓ OpenTelemetry Collector: Healthy
# ✓ Prometheus: Healthy
# ✓ Grafana: Healthy
# ✓ OTLP Collector target is UP

# 2. View logs
make logs-otel    # Watch OpenTelemetry Collector receive metrics
make logs         # All services

# 3. Check Prometheus
open http://localhost:9090
# Query: claude_code_session_total
```

## 🎯 Start Using Claude Code

Now run any Claude Code command and watch metrics appear in Grafana!

**Metrics appear in ~75-90 seconds**:
- Claude Code exports every 60 seconds
- Prometheus scrapes every 10 seconds
- Grafana refreshes every 30 seconds

### Example Commands
```bash
# Any Claude Code command will generate metrics
claude "help me write a function"
claude "review this code"
claude "fix this bug"
```

### Watch Metrics Flow
```bash
# Terminal 1: Watch OpenTelemetry logs
make logs-otel

# Terminal 2: Use Claude Code
claude "write hello world"

# You'll see metrics being received in Terminal 1!
```

## 🛠️ Useful Commands

```bash
make help            # Show all commands
make status          # Show running containers
make restart         # Restart all services
make logs-grafana    # Grafana logs
make logs-prometheus # Prometheus logs
make clean           # Stop and remove all data (WARNING!)
```

## 🐛 Troubleshooting

### No metrics showing up?

**1. Check Claude Code telemetry is enabled:**
```bash
echo $CLAUDE_CODE_ENABLE_TELEMETRY  # Should output: 1
echo $OTEL_EXPORTER_OTLP_ENDPOINT   # Should output: http://localhost:4318
```

If not set:
```bash
# Re-run setup in new terminal
make setup-telemetry

# Or manually source your shell config
source ~/.bashrc  # or ~/.zshrc
```

**2. Check services are running:**
```bash
make health
make status
```

**3. Check OpenTelemetry Collector is receiving data:**
```bash
make logs-otel
# Should see incoming metrics after running Claude Code
```

**4. Check Prometheus is scraping:**
- Open http://localhost:9090/targets
- Target `otel-collector` should show "UP"

**5. Query Prometheus directly:**
- Open http://localhost:9090
- Query: `claude_code_token_usage_tokens_total`
- Should return results after using Claude Code

### Dashboard shows "No data"?

- **Wait 90 seconds** after running Claude Code command
- Check time range in Grafana (top right) - try "Last 1 hour"
- Verify you're looking at the right datasource (Prometheus)

### Ports already in use?

If you get "port already allocated" errors:
```bash
# Check what's using the ports
lsof -i :3000  # Grafana
lsof -i :9090  # Prometheus
lsof -i :4318  # OpenTelemetry

# Stop conflicting services or change ports in docker-compose.yml
```

## 🎓 Learn More

- **README.md**: Full documentation
- **CHANGES.md**: What changed from original to official gist
- **.env.example**: All configuration options
- **Blog Post**: https://sealos.io/blog/claude-code-metrics

## 🎉 Success!

You now have a complete Claude Code metrics monitoring system with:
- ✅ Real-time metrics collection
- ✅ Cost tracking
- ✅ Performance insights
- ✅ Productivity measurements
- ✅ Beautiful Grafana dashboards

Happy coding with Claude! 🤖
