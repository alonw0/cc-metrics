.PHONY: help start stop restart logs logs-grafana logs-prometheus logs-otel health clean setup setup-telemetry status

help:
	@echo "Claude Code Metrics - Available Commands:"
	@echo ""
	@echo "  make start          - Start all services in detached mode"
	@echo "  make stop           - Stop all services"
	@echo "  make restart        - Restart all services"
	@echo "  make logs           - View logs from all services (follow mode)"
	@echo "  make logs-grafana   - View Grafana logs only"
	@echo "  make logs-prometheus- View Prometheus logs only"
	@echo "  make logs-otel      - View OpenTelemetry Collector logs only"
	@echo "  make health         - Check health status of all services"
	@echo "  make status         - Show running containers"
	@echo "  make setup          - Create data directories with proper permissions"
	@echo "  make setup-telemetry- Configure Claude Code telemetry environment variables"
	@echo "  make clean          - Stop services and remove data volumes"
	@echo ""

start:
	@echo "Starting Claude Code Metrics stack..."
	docker-compose up -d
	@echo ""
	@echo "Services starting up. Check status with: make status"
	@echo "Access Grafana at: http://localhost:3000 (admin/admin)"
	@echo "Access Prometheus at: http://localhost:9090"
	@echo ""

stop:
	@echo "Stopping Claude Code Metrics stack..."
	docker-compose down
	@echo "All services stopped."

restart: stop start

logs:
	@echo "Following logs from all services (Ctrl+C to exit)..."
	docker-compose logs -f

logs-grafana:
	@echo "Following Grafana logs (Ctrl+C to exit)..."
	docker-compose logs -f grafana

logs-prometheus:
	@echo "Following Prometheus logs (Ctrl+C to exit)..."
	docker-compose logs -f prometheus

logs-otel:
	@echo "Following OpenTelemetry Collector logs (Ctrl+C to exit)..."
	docker-compose logs -f otel-collector

health:
	@echo "Checking service health..."
	@echo ""
	@echo "OpenTelemetry Collector:"
	@curl -s http://localhost:13133 > /dev/null && echo "  ✓ Healthy" || echo "  ✗ Unhealthy"
	@echo ""
	@echo "Prometheus:"
	@curl -s http://localhost:9090/-/healthy > /dev/null && echo "  ✓ Healthy" || echo "  ✗ Unhealthy"
	@echo ""
	@echo "Loki:"
	@curl -s http://localhost:3100/ready > /dev/null && echo "  ✓ Healthy" || echo "  ✗ Unhealthy"
	@echo ""
	@echo "Grafana:"
	@curl -s http://localhost:3000/api/health > /dev/null && echo "  ✓ Healthy" || echo "  ✗ Unhealthy"
	@echo ""
	@echo "Prometheus Targets:"
	@curl -s http://localhost:9090/api/v1/targets | grep -q '"health":"up"' && echo "  ✓ OTLP Collector target is UP" || echo "  ✗ OTLP Collector target is DOWN"
	@echo ""

status:
	@echo "Service Status:"
	@docker-compose ps

clean:
	@echo "WARNING: This will stop all services and remove all data!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	@echo "Stopping services..."
	docker-compose down -v
	@echo "Removing data directories..."
	rm -rf data/prometheus/* data/grafana/* data/loki/* data/otel-logs/*
	@echo "Clean complete. Run 'make setup' to recreate directories."

setup:
	@echo "Creating data directories..."
	mkdir -p data/prometheus data/grafana data/loki data/otel-logs
	@echo "Setting permissions..."
	chmod 777 data/grafana data/prometheus data/loki data/otel-logs
	@echo "Setup complete. Run 'make start' to start services."
	@echo ""
	@echo "Next: Configure Claude Code telemetry with: make setup-telemetry"
	@echo ""

setup-telemetry:
	@./setup-telemetry.sh
