#!/bin/bash

# Function to check the status of a service
check_service_status() {
    local service_name=$1
    systemctl is-active --quiet $service_name
    if [ $? -eq 0 ]; then
        echo "$service_name is OK"
    else
        echo "$service_name is not running."
    fi
}

# List of services to check
services=("mariadb" "apache2" "asterisk")

# Check the status of each service
for service in "${services[@]}"; do
    check_service_status $service
done

