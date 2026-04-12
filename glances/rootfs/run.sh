#!/usr/bin/env bashio
# shellcheck shell=bash
# ==============================================================================
# Home Assistant Community Add-on: Glances
# Run the Glances add-on
# ==============================================================================
#
# WHAT IS THIS FILE?!
#
# The Glances add-on runs in the host PID namespace, therefore it cannot
# use the regular S6-Overlay (v3 requires PID 1, which is impossible with
# host_pid: true). This script manually orchestrates services instead.
# ==============================================================================
/etc/cont-init.d/banner.sh
/etc/cont-init.d/glances.sh
/etc/cont-init.d/nginx.sh

# Restart nginx if it exits unexpectedly
nginx_supervisor() {
    while true; do
        /etc/services.d/nginx/run &
        NGINX_PID=$!
        wait "${NGINX_PID}" || true
        bashio::log.warning "Nginx exited unexpectedly, restarting..."
        sleep 1
    done
}

# Start Nginx with restart supervision
nginx_supervisor &

# Start Glances (includes InfluxDB/MQTT export when enabled)
exec /etc/services.d/glances/run
