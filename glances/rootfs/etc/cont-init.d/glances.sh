#!/usr/bin/env bashio
# shellcheck shell=bash
# ==============================================================================
# Home Assistant Community App: Glances
# Configures Glances
# ==============================================================================
declare host
declare protocol
bashio::require.unprotected

# Ensure the app configuration directory exists
mkdir -p /config

# Migrate app data from the Home Assistant config directory,
# to the app configuration directory.
if ! bashio::fs.file_exists '/config/glances/glances.conf' \
    && bashio::fs.file_exists '/homeassistant/glances/glances.conf'; then
    mv /homeassistant/glances /config/ \
        || bashio::exit.nok "Failed to migrate Glances configuration out of Home Assistant config directory"
fi

# Ensure the configuration exists
if bashio::fs.file_exists '/config/glances/glances.conf'; then
    cp -f /config/glances/glances.conf /etc/glances.conf
else
    mkdir -p /config/glances \
        || bashio::exit.nok "Failed to create the Glances configuration directory"

    # Copy in template file
    cp /etc/glances.conf /config/glances/
fi

# Export Glances data to InfluxDB
if bashio::config.true 'influxdb.enabled'; then
    protocol='http'
    if bashio::config.true 'influxdb.ssl'; then
        protocol='https'
    fi
    host="$(bashio::config 'influxdb.host')"

    # Modify the configuration
    if bashio::config.equals 'influxdb.version' '1'; then
        bashio::config.require "influxdb.username"
        bashio::config.require "influxdb.password"
        bashio::config.require "influxdb.database"
        bashio::config.require "influxdb.prefix"
        {
            echo "[influxdb]"
            echo "user=$(bashio::config 'influxdb.username')"
            echo "password=$(bashio::config 'influxdb.password')"
            echo "db=$(bashio::config 'influxdb.database')"
            echo "prefix=$(bashio::config 'influxdb.prefix')"
            echo "interval=$(bashio::config 'influxdb.interval')"
        } >> /etc/glances.conf
    elif bashio::config.equals 'influxdb.version' '2'; then
        bashio::config.require "influxdb.org"
        bashio::config.require "influxdb.bucket"
        bashio::config.require "influxdb.token"
        {
            echo "[influxdb2]"
            echo "org=$(bashio::config 'influxdb.org')"
            echo "bucket=$(bashio::config 'influxdb.bucket')"
            echo "token=$(bashio::config 'influxdb.token')"
            echo "interval=$(bashio::config 'influxdb.interval')"
        } >> /etc/glances.conf
    elif bashio::config.equals 'influxdb.version' '3'; then
        bashio::config.require "influxdb.database"
        bashio::config.require "influxdb.token"

        # The InfluxDB 3 exporter only passes the host to its client, which
        # then assumes HTTPS on port 443. Make both part of the host instead.
        host="${protocol}://${host}:$(bashio::config 'influxdb.port')"
        {
            echo "[influxdb3]"
            echo "org=$(bashio::config 'influxdb.org' 'default')"
            echo "database=$(bashio::config 'influxdb.database')"
            echo "token=$(bashio::config 'influxdb.token')"
            echo "interval=$(bashio::config 'influxdb.interval')"
        } >> /etc/glances.conf
    else
        bashio::exit.nok "Unsupported InfluxDB version: must be 1, 2 or 3"
    fi

    {
        echo "protocol=${protocol}"
        echo "host=${host}"
        echo "port=$(bashio::config 'influxdb.port')"
    } >> /etc/glances.conf
fi
