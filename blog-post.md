# I Hooked Claude Code Up to Grafana (Because Why Not?)

## Treating your AI coding assistant like a production service, with full observability

You know what your AI coding assistant needs? **A full production monitoring stack with Prometheus, OpenTelemetry, Grafana, and 22 dashboard panels.**

Is this overkill? Absolutely. Is it awesome? Also yes.

Claude Code has become my pair programming partner, my code reviewer, my commit message writer. It's basically a critical part of my development workflow. And you know what I do with critical services? I monitor them. With graphs. Lots of graphs.

That's when I realized: **I have better observability for my coffee machine than I do for my AI development tools.** And that felt wrong.

## The Curiosity Gap: What's Actually Happening Under the Hood?

If you're using Claude Code daily (and if you're reading this, you probably are), you're in the same boat. We've all adopted AI-assisted development at breakneck speed, but we're completely blind to what's actually happening.

Claude Code gives you... nothing. No built-in metrics. No usage dashboards. No insights into what's happening behind the scenes. It's like running a production service without any monitoring. And that just feels weird.

This creates some interesting questions:
- **What's actually happening when I use Claude?** How many tokens? Which models?
- **Is prompt caching doing anything?** Is it working as expected?
- **What patterns emerge from my usage?** When do I use it most? For what tasks?
- **How much work is Claude doing vs how much am I doing?** Curious about that ratio.

And here's the thing: we monitor everything else. Your servers, your databases, your coffee maker probably has more telemetry than your AI coding assistant. (Sure, costs matter too, but most of us are on fixed-price plans anyway—the real gap is visibility.)

## What I Built: Production-Grade Monitoring for Claude Code

I decided to solve this the way we solve observability for everything else in tech: **with real monitoring tools.**

The result is a complete monitoring stack that tracks everything Claude Code does, giving you the same level of visibility you'd expect from any production service.

Here's what it looks like:

```
Claude Code
    ↓ (OTLP telemetry)
OpenTelemetry Collector (:4318)
    ↓ (Prometheus metrics)
Prometheus (:9090)
    ↓ (PromQL queries)
Grafana Dashboard (:3000)
    ↓ (Beautiful visualizations)
Your Browser
```

**What it tracks:**
- 🎯 **Token usage** - Input, output, and cache hits/creation by model
- 📝 **Code changes** - Lines of code accepted from Claude suggestions
- 🔄 **Git activity** - Commits and PRs created via Claude Code
- ⚡ **Performance metrics** - Cache efficiency, productivity ratio, and more
- 💰 **Usage costs** - Real-time cost estimates (handy if you're on pay-as-you-go)

Imagine opening a dashboard and seeing:
- **Sessions This Week**: 42 (you've been busy!)
- **Tokens Used**: 15,432 (12% served from cache)
- **Productivity Ratio**: 3.2x (Claude is doing 3x more work than you)
- **Cache Efficiency**: 68% (nice optimization!)

That's not theoretical. That's what I see every day now.

## The Tech Stack (Yes, It's Overkill. Delightfully So.)

I built this using the same observability stack you'd use for monitoring production microservices:

**OpenTelemetry Collector** receives metrics from Claude Code via OTLP (the industry standard for telemetry). It's like having a metrics gateway that speaks fluent AI.

**Prometheus** stores all the time-series data with 30-day retention. Every token, every cost calculation, every cache hit—all tracked over time so you can spot trends.

**Grafana** visualizes everything with a dashboard that has 22 panels showing different aspects of your Claude Code usage. It's beautiful, it's detailed, and it's actually useful.

**Docker Compose** ties it all together. Everything runs locally on your machine—no cloud services, no external dependencies, no data leaving your computer.

Why this stack? Because it's:
- Industry-standard (the same tools used by Google, Netflix, etc.)
- Free and open-source
- Production-ready and battle-tested
- Completely private (runs on your machine)

*Note: This is based on the excellent [Sealos blog post](https://sealos.io/blog/claude-code-metrics) about Claude Code metrics, but I've enhanced it with automation and better developer experience.*

## The Good Part: Setup Takes 5 Minutes ⚡

Here's where it gets fun. I made this **ridiculously easy** to set up.

Three commands. That's it.

```bash
# 1. Create data directories
make setup

# 2. Start the monitoring stack
make start

# 3. Configure Claude Code telemetry
make setup-telemetry
```

**What just happened?**

**Step 1** creates the necessary directories for Prometheus and Grafana to store data. Permission handling included.

**Step 2** spins up three Docker containers in the background:
- OpenTelemetry Collector (ready to receive metrics)
- Prometheus (scraping metrics every 10 seconds)
- Grafana (auto-configured with the dashboard)

**Step 3** is my favorite. It's an interactive script that:
- Detects your shell (bash, zsh, or fish)
- Finds your shell config file automatically
- Adds the necessary environment variables
- Applies them to your current session
- Verifies everything works

**No manual config file editing. No copying and pasting environment variables. It just works.**

Here's what the script configures for you:

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
export OTEL_SERVICE_NAME=claude-code
```

Then you open `http://localhost:3000` in your browser, login with `admin/admin`, and boom—you have a fully functional metrics dashboard.

**Time from clone to insights: 5 minutes.** I've timed it.

## The Dashboard: Where the Magic Happens 📊

Let me show you the insights that changed how I use Claude Code.

### Cache Efficiency: The Optimization Puzzle

The first panel I check every morning is **Cache Efficiency**. This metric is oddly satisfying to optimize.

Prompt caching is Claude's way of reusing context across requests—cached tokens get processed way faster and more efficiently. But is it actually working? Are you hitting the cache or missing it?

I thought I was doing fine. Turns out, I was at **45% cache efficiency**. After optimizing my workflow (better prompt structure, reusing context), I'm now at **78%**. That's a 33% improvement—and honestly, making that gauge go from red to green is just... nice.

The dashboard shows you this in real-time. When you see red, you know there's room to optimize. And optimizing is fun.

### Productivity Ratio: Measuring the AI/Human Balance

This metric is **CLI Time ÷ User Time**. In other words: How much work is Claude doing compared to how much time you're spending typing?

My current ratio is **3.2x**. For every hour I spend typing prompts and reviewing code, Claude spends 3.2 hours generating code, running tools, and making changes.

It's fascinating data. You can actually see the balance between human guidance and AI execution. (And yes, if your manager asks "is this AI thing working?", a 3x multiplier is a pretty good answer.)

### Token Distribution: Seeing the Flow

The pie chart showing token distribution is a beautiful window into what's actually happening. **23% of my tokens are cache reads**, **12% are cache creation**, and the rest split between input and output tokens.

You can literally see the flow of data through Claude's system. Which models am I using most? Turns out, mostly Sonnet for general work, with occasional Opus for complex tasks. The dashboard makes these patterns visible in ways that are just... satisfying to look at.

Understanding how tokens flow helps you optimize your usage patterns—not just for efficiency, but because seeing how things work under the hood is genuinely interesting.

## The Real-World Impact

After running this for a month, here's what I've learned:

**Visibility is Valuable** 👁️
Just seeing what's happening is worth it. I now know exactly what Claude is doing, when, and how. It's like turning on the lights in a room you've been working in blind. The data itself is fascinating.

**Usage Patterns** 🕐
Turns out, I use Claude most heavily between 2-4pm (post-lunch productivity slump). Knowing this, I batch my complex tasks for that window when I know I have AI support. These patterns are interesting to discover.

**Productivity Data** 📈
Last week, Claude Code generated **2,847 lines of code** across 42 sessions. I committed 18 PRs, 14 of which had significant Claude contributions. It's cool data to have (and yes, useful for sprint reviews if needed).

**Optimization Opportunities** ⚡
I found that 30% of my prompts weren't leveraging the cache effectively. Small changes to my workflow (breaking large contexts into reusable parts) increased cache hits by 40%. Making systems more efficient is satisfying.

**And Yes, Cost Insights Too** 💰
If you're on a pay-as-you-go plan, the cache optimization insights can actually save you money. But honestly? Most of us are on fixed-price plans anyway. The real value is understanding what's happening under the hood.

## What Makes This Special

You might be thinking: "Isn't this just the Sealos tutorial?"

Yes and no. The foundation is from that excellent blog post, but I've added several enhancements that make it much easier to use:

✅ **Automated Setup Script**
The `setup-telemetry.sh` script auto-detects your shell (bash/zsh/fish), finds your config file, and configures everything automatically. No manual editing of dotfiles.

✅ **Makefile for Everything**
Simple commands like `make start`, `make health`, `make logs`. No memorizing Docker commands.

✅ **Comprehensive Documentation**
README, QUICK_START guide, and troubleshooting docs. Everything you need to get running and stay running.

✅ **Official Dashboard**
Using the exact Grafana dashboard from the official gist, with 22 panels covering every metric Claude Code exposes.

✅ **Recording Rules**
Pre-computed Prometheus queries for expensive calculations (cache efficiency, cost ratios). Your dashboard stays fast even with months of data.

✅ **Complete Docker Compose Stack**
Everything configured and ready to go. Health monitoring, proper networking, persistent storage—production-grade setup.

The full project is available on GitHub (link at the end).

## Getting Started

Ready to get visibility into your Claude Code usage?

**Prerequisites:**
- Docker and Docker Compose
- Claude Code CLI
- 5 minutes of your time

**Setup:**
1. Clone the repository
2. Run `make setup` to create directories
3. Run `make start` to spin up the stack
4. Run `make setup-telemetry` to configure Claude Code
5. Open `http://localhost:3000` and explore

**After setup:**
- Run any Claude Code command
- Wait ~90 seconds for metrics to appear
- Start exploring your usage patterns
- Optimize based on what you learn

The dashboard updates every 30 seconds, Prometheus scrapes every 10 seconds, and Claude Code exports metrics every 60 seconds. You'll see data flow almost immediately.

## The Bottom Line

If you're using Claude Code daily, you deserve visibility into what it's doing. Not because you need to justify costs (though sure, that too), but because **seeing what's happening under the hood is just inherently valuable**.

This isn't about necessity—it's about treating your AI tools with the same observability love you give your production services. Is it overkill to hook up a CLI tool to Grafana? Maybe. Is it delightful? Absolutely.

The best part? **It takes 5 minutes to set up and runs forever.** The insights you get will change how you think about AI-assisted development.

## Try It Yourself

I'd love to hear what insights you discover. Set it up, run it for a week, and let me know:
- What surprised you most about your usage?
- Did you find any optimization opportunities?
- What metrics would you want to see that aren't there yet?

**GitHub Repository**: [Link to your repo]

The stack is free, open-source, and runs entirely on your machine. Your data never leaves your computer.

Give it a try. Sometimes the best projects are the ones where you ask "can I?" instead of "should I?"

---

*Have questions? Found an issue? Want to contribute? Drop a comment below or open an issue on GitHub. I'm always looking to improve this.*

*Using Claude Code for your team? I'd love to hear about your experience with team-wide metrics and observability.*

---

## Technical Appendix (For the Curious)

### What Metrics Are Tracked?

Claude Code exposes these metrics via OpenTelemetry:

- `claude_code_session_total` - Session starts
- `claude_code_token_usage_tokens_total` - Tokens by type (input, output, cache_read, cache_creation)
- `claude_code_cost_usage_USD_total` - Estimated costs
- `claude_code_lines_of_code_count_total` - Lines of code changes
- `claude_code_commit_count_total` - Git commits
- `claude_code_pull_request_total` - Pull requests created
- `claude_code_code_edit_tool_decision_total` - Accept/reject decisions
- `claude_code_active_time_seconds_total` - User vs CLI time

### Architecture Details

The OpenTelemetry Collector receives metrics via OTLP on port 4318 (HTTP) and 4317 (gRPC). It batches them every 10 seconds and exposes them in Prometheus format on port 8889.

Prometheus scrapes this endpoint every 10 seconds and stores the time-series data with configurable retention (default: 30 days).

Grafana queries Prometheus via PromQL and renders dashboards. The datasource is auto-provisioned, and the dashboard JSON is loaded automatically on startup.

Everything runs in Docker containers with proper networking, health monitoring, and persistent volumes for data storage.

### Performance Impact

The monitoring stack uses approximately:
- **OpenTelemetry Collector**: ~50MB RAM
- **Prometheus**: ~200-500MB RAM (scales with retention)
- **Grafana**: ~100-200MB RAM

Total disk usage: ~1-2GB for 30 days of metrics at typical usage rates.

Impact on Claude Code: Negligible. Metrics export happens asynchronously and doesn't affect command execution.

### Customizing the Dashboard

The Grafana dashboard JSON is fully editable. You can:
- Add new panels with custom PromQL queries
- Adjust time ranges and refresh intervals
- Create alerts for cost thresholds
- Export data for external analysis

See the project README for detailed customization instructions.
