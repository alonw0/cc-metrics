# Claude Code Metrics Dashboard

A comprehensive monitoring stack for tracking Claude Code usage metrics, costs, and performance using OpenTelemetry, Prometheus, and Grafana.

Based on the [Sealos blog post](https://sealos.io/blog/claude-code-metrics).

## Features

- **Real-time Metrics Tracking**: Monitor Claude Code sessions, token usage, costs, commits, and more
- **Comprehensive Dashboard**: 20+ panels showing key metrics, efficiency gauges, trends, and distributions
- **Cost Analysis**: Track costs by model, session, and time period
- **Cache Efficiency Monitoring**: Visualize prompt caching effectiveness
- **Productivity Insights**: Measure CLI vs user active time ratios
- **Auto-provisioning**: Dashboard and datasources automatically configured on startup

## Architecture

```
Claude Code
    ↓ (OTLP HTTP/gRPC - metrics + logs)
OpenTelemetry Collector (:4318/:4317)
    ├─→ Prometheus metrics (:8889)
    │       ↓
    │   Prometheus (:9090)
    └─→ JSON logs (file)
            ↓
        Promtail
            ↓
        Loki (:3100)
            ↓ (PromQL + LogQL queries)
        Grafana (:3000)
            ↓ (Dashboard visualization)
        Your Browser
```

## Metrics Tracked

- **Sessions**: Total Claude Code session starts
- **Tokens**: Usage by type (input, output, cache_read, cache_creation) and model
- **Costs**: Estimated USD costs with per-model breakdown
- **Code Changes**: Lines added/removed from accepted edits
- **Git Activity**: Commits and pull requests created
- **Edit Decisions**: Accept/reject choices on code suggestions
- **Active Time**: User input time vs CLI processing time
- **Prompt Length**: Average character count of user prompts (via Loki logs)

## Prerequisites

- Docker and Docker Compose
- Claude Code CLI

## Quick Start

### 1. Clone or Download This Repository

```bash
cd claude-metrics2
```

### 2. Set Up Data Directories

```bash
make setup
```

Or manually:
```bash
mkdir -p data/prometheus data/grafana data/loki data/otel-logs
chmod 777 data/grafana data/prometheus data/loki data/otel-logs
```

### 3. Start the Monitoring Stack

```bash
make start
```

Or using Docker Compose:
```bash
docker-compose up -d
```

### 4. Verify Services Are Running

```bash
make health
```

Or check manually:
- OpenTelemetry Collector: http://localhost:13133
- Prometheus: http://localhost:9090/targets
- Loki: http://localhost:3100/ready
- Grafana: http://localhost:3000/api/health

#### Services Overview

The monitoring stack consists of five services:

1. **OpenTelemetry Collector** (localhost:4318/4317)
   - Receives telemetry from Claude Code via OTLP
   - Exports metrics to Prometheus
   - Writes logs to JSON file for Promtail

2. **Prometheus** (localhost:9090)
   - Stores time-series metrics data
   - Provides PromQL query interface

3. **Loki** (localhost:3100)
   - Stores log data from Claude Code events
   - Enables LogQL queries for log-based metrics

4. **Promtail**
   - Reads logs from OTel Collector
   - Ships logs to Loki with structured metadata

5. **Grafana** (localhost:3000)
   - Visualizes metrics from Prometheus and Loki
   - Provides unified dashboard interface

### 5. Configure Claude Code Telemetry

**Option A: Automated Setup (Recommended)**

Run the setup script to automatically configure your shell:

```bash
make setup-telemetry
```

Or run directly:
```bash
./setup-telemetry.sh
```

This will:
- Detect your shell (bash/zsh/fish)
- Add environment variables to your shell configuration
- Apply settings to your current session
- Provide verification and next steps

**Option B: Manual Setup**

Add these environment variables to your shell configuration (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
export OTEL_SERVICE_NAME=claude-code
```

Then reload your shell:
```bash
source ~/.bashrc  # or ~/.zshrc
```

### 6. Access Grafana Dashboard

1. Open http://localhost:3000 in your browser
2. Login with default credentials:
   - Username: `admin`
   - Password: `admin` (change this on first login)
3. Navigate to **Dashboards** → **Claude Code Metrics**

### 7. Start Using Claude Code

Run Claude Code commands and metrics will start appearing in Grafana within 75-90 seconds (60s export interval + 15s scrape interval).

## Makefile Commands

```bash
make start           # Start all services
make stop            # Stop all services
make restart         # Restart all services
make logs            # View logs from all services
make logs-grafana    # View Grafana logs only
make logs-prometheus # View Prometheus logs only
make logs-otel       # View OpenTelemetry Collector logs only
make health          # Check health status of all services
make status          # Show running containers
make setup           # Create data directories with proper permissions
make setup-telemetry # Configure Claude Code telemetry (interactive)
make clean           # Stop services and remove data volumes
```

## Dashboard Overview

### Row 1: Key Metrics (Stat Panels)
- Total Sessions
- Total Commits
- Lines of Code Changed (net)
- Total Cost (USD)
- Active Time (seconds)
- Average Prompt Length (characters)

### Row 2: Efficiency Gauges
- **Cache Efficiency %**: Percentage of cache hits vs input tokens
- **Productivity Ratio**: CLI processing time / User input time
- **Cost per 1K Tokens**: Average cost per 1000 output tokens

### Row 3: Distribution Charts (Pie Charts)
- Token Distribution by Type
- Tokens by Model
- Active Time Split (user vs CLI)

### Row 4: Cost Analysis
- Cost by Model (bar gauge)
- Recent Sessions (table)

### Row 5: Time Series Trends
- Token Usage Over Time (stacked area)
- Cost Over Time (line chart)
- Active Time Patterns (stacked bars)

### Row 6: Additional Metrics
- Pull Requests Created
- Code Edit Decisions (accept/reject)
- Lines Added
- Lines Removed

## Configuration

### Environment Variables

Create a `.env` file (see `.env.example`):

```bash
# Grafana
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=your_secure_password

# Optional: Change service URLs
GF_SERVER_ROOT_URL=http://localhost:3000
```

### Data Retention

Prometheus is configured with 30-day retention. To change this, edit `docker-compose.yml`:

```yaml
prometheus:
  command:
    - "--storage.tsdb.retention.time=90d"  # Change to desired retention
```

### Recording Rules

Pre-computed metrics for better dashboard performance are defined in `configs/prometheus/recording_rules.yml`:

- `claude_code:cache_efficiency:ratio` - Cache hit rate
- `claude_code:cost_per_1k_tokens:ratio` - Cost efficiency
- `claude_code:productivity:ratio` - Productivity ratio

## Troubleshooting

### No Data in Grafana

1. Check if Claude Code telemetry is enabled:
   ```bash
   echo $CLAUDE_CODE_ENABLE_TELEMETRY
   ```

2. Verify OpenTelemetry Collector is receiving data:
   ```bash
   make logs-otel
   ```

3. Check Prometheus targets:
   - Open http://localhost:9090/targets
   - Ensure `otel-collector` target is UP

4. Verify metrics in Prometheus:
   - Open http://localhost:9090
   - Query: `claude_code_session_total`

### Permission Errors

If you see permission errors with Grafana or Prometheus:

```bash
sudo chown -R 472:472 data/grafana
sudo chown -R 65534:65534 data/prometheus
```

### Services Won't Start

Check service logs:
```bash
make logs
```

Ensure ports are not already in use:
```bash
lsof -i :3000  # Grafana
lsof -i :9090  # Prometheus
lsof -i :4318  # OTLP HTTP
```

### Dashboard Panels Show "No Data"

1. Check time range - metrics export every 60 seconds
2. Verify you've run Claude Code commands after configuring telemetry
3. Check PromQL query in panel for errors
4. Ensure metric names match (dots become underscores)

## Advanced Usage

### Custom Dashboards

The provisioned dashboard allows UI updates. You can:
1. Modify panels in Grafana UI
2. Save changes
3. Export JSON via Share → Export
4. Replace `configs/grafana/dashboards/claude-code-metrics.json`

### Alerting

Add alert rules to Prometheus (`configs/prometheus/alert_rules.yml`):

```yaml
groups:
  - name: claude_code_alerts
    rules:
      - alert: HighCost
        expr: sum(rate(claude_code_cost_usage_USD_total[1h])) > 10
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High Claude Code costs detected"
```

Then add to `prometheus.yml`:
```yaml
rule_files:
  - '/etc/prometheus/recording_rules.yml'
  - '/etc/prometheus/alert_rules.yml'
```

### Remote Storage

To send metrics to remote Prometheus-compatible storage:

Add to `prometheus.yml`:
```yaml
remote_write:
  - url: "https://your-remote-storage/api/v1/write"
    basic_auth:
      username: user
      password: pass
```

## Stopping the Stack

```bash
make stop
```

To remove all data:
```bash
make clean
```

## Security Notes

- Default Grafana credentials are `admin/admin` - **change these immediately**
- The stack is configured for local development
- For production deployment:
  - Use strong passwords
  - Enable HTTPS
  - Configure authentication
  - Restrict network access
  - Use Docker secrets for credentials

## Data Flow Timing

- Claude Code exports metrics every 60 seconds
- Prometheus scrapes OTLP collector every 10 seconds
- Grafana refreshes every 30 seconds
- Total latency: ~75-90 seconds from event to dashboard

## Resource Usage

Typical resource consumption:
- OpenTelemetry Collector: ~50MB RAM
- Prometheus: ~200-500MB RAM (depends on retention)
- Grafana: ~100-200MB RAM

## Project Structure

```
claude-metrics2/
├── docker-compose.yml           # Service orchestration
├── Makefile                     # Common operations
├── README.md                    # This file
├── .env.example                 # Environment variables template
├── .gitignore                   # Git ignore rules
├── configs/
│   ├── otel-collector/
│   │   └── config.yaml          # OTLP receiver configuration
│   ├── prometheus/
│   │   ├── prometheus.yml       # Scrape configuration
│   │   └── recording_rules.yml  # Pre-computed metrics
│   └── grafana/
│       ├── datasources/
│       │   └── prometheus.yml   # Datasource provisioning
│       └── dashboards/
│           ├── dashboard.yml    # Dashboard provisioning config
│           └── claude-code-metrics.json  # Main dashboard
└── data/
    ├── prometheus/              # Time-series data (gitignored)
    └── grafana/                 # Grafana database (gitignored)
```

## Contributing

Issues and improvements welcome! This is a monitoring setup based on the Sealos blog post.

## License

MIT

## References

- [Sealos Blog Post](https://sealos.io/blog/claude-code-metrics)
- [Claude Code Documentation](https://docs.anthropic.com/claude/docs/claude-code)
- [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
