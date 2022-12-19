#!/bin/bash

# This script installs iperf on a Linux system.

# Check if the user is root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Check if iperf is already installed
if [ -f /usr/bin/iperf ]; then
    echo "iperf is already installed"
    exit 1
fi

# get machine's ip address using dig
IP_ADDRESS=$(dig +short myip.opendns.com @resolver1.opendns.com)

# go to ~
cd ~
mkdir iperf
cd iperf

# Download iperf
apt install -y iperf3

# Generate rsa keypair
openssl genrsa -des3 -out private.pem 2048
openssl rsa -in private.pem -outform PEM -pubout -out public.pem
openssl rsa -in private.pem -out private_not_protected.pem -outform PEM

# Create a user for iperf
S_USER=iperf_client
S_PASSWD=iperf_pass
HASH_USER=$(echo -n "{$S_USER}$S_PASSWD" | sha256sum | awk '{ print $1 }')
echo "$S_USER,$HASH_USER" > credentials.csv

# Read the port from user; default is 5201
read -p "Enter the iperf server port (default is 5201): " SERVER_PORT
if [ -z "$SERVER_PORT" ]; then
    SERVER_PORT=5201
fi

# Print server info
clear
echo "Server address: $IP_ADDRESS"
echo "Server port: $SERVER_PORT"

echo "Public key:"
cat public.pem
echo

# Run iperf server
echo "iperf3 -s --rsa-private-key-path private_not_protected.pem --authorized-users-path credentials.csv"
iperf3 -s --rsa-private-key-path private_not_protected.pem --authorized-users-path credentials.csv
