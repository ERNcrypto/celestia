#!/bin/bash

# Ensure necessary tools are installed
if ! command -v jq &> /dev/null || ! command -v curl &> /dev/null || ! command -v nc &> /dev/null; then
    echo "jq, curl, or nc (netcat) is not installed. Please install them and try again."
    exit 1
fi

# List of node IPs for querying
NODE_IPS=(
"104.219.237.146"
"37.27.109.215"
"136.175.9.193"
"85.10.196.25"
"209.159.154.142"
"104.243.40.149"
"65.109.54.91"
"158.220.87.136"
"38.58.183.3"
"51.159.215.215"
"65.108.142.147"
"138.201.82.234"
"38.242.234.180"
"93.159.130.38"
"141.94.73.39"
"142.132.202.87"
"95.217.225.107"
"65.109.16.220"
"15.235.218.151"
"88.198.12.182"
"162.19.19.41"
"5.9.10.222"
"64.176.57.63"
"141.95.35.218"
"57.129.1.77"
"37.27.119.173"
"116.202.217.20"
"217.160.102.31"
"62.138.24.120"
"88.99.219.120"
"94.130.35.35"
"95.216.223.149"
"91.121.55.152"
"125.253.92.7"
"64.227.18.169"
"195.14.6.178"
"45.143.198.5"
"95.217.200.98"
"136.243.176.86"
"141.94.135.203"
"162.55.65.137"
"https://celestia-testnet-rpc.itrocket.net/"
"https://celestia-testnet.rpc.kjnodes.com/"
"https://celestia-testnet-rpc.stake-town.com/"
"https://celestia.test.rpc.nodeshub.online/"
"https://celestia.rpc.testnets.services-ernventures.com/"
"https://celestia-rpc.0xcryptovestor.com"
"https://rpc.celestia.nodestake.top"
)

# Port for querying
PORTS=(
"26667"
"26657"
"21657"
"27657"
"35657"
"43657"
"26698"
"34657"
"26647"
"18657"
"11657"
"443"
)

# Initialize output file
OUTPUT_FILE="rpc_endpoints.txt"
LOG_FILE="rpc_check.log"

> $OUTPUT_FILE
> $LOG_FILE

# Function to check availability of a port on a given IP
check_rpc() {
    local ip=$1
    local port=$2
    echo "Проверка $ip:$port" | tee -a $LOG_FILE  # Log the process of checking
    if nc -zv -w 2 $ip $port 2>&1 | tee -a $LOG_FILE | grep -q "succeeded"; then
        echo "Доступен: $ip:$port" | tee -a $LOG_FILE
        echo "http://$ip:$port/" >> $OUTPUT_FILE
    else
        echo "Недоступен или превышен тайм-аут: $ip:$port" | tee -a $LOG_FILE
    fi
}

# Check each IP on each port
for ip in "${NODE_IPS[@]}"; do
    for port in "${PORTS[@]}"; do
        check_rpc $ip $port
    done
done

# Display the results
echo "Список доступных RPC точек записан в файл $OUTPUT_FILE:" | tee -a $LOG_FILE
cat $OUTPUT_FILE | tee -a $LOG_FILE