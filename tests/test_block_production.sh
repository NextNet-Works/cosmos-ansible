#!/bin/bash 
# Check that blocks are being produced.

gaia_host=$1
gaia_port=$2
stop_height=$3

# Test gaia response
tests/test_gaia_response.sh $gaia_host $gaia_port

# Get the current gaia version from the API
gaiad_version=$(curl -s http://$gaia_host:$gaia_port/abci_info | jq -r .result.response.version)

# Check if gaia is producing blocks
test_counter=0
max_tests=60
echo "Current gaiad version: $gaiad_version"
echo "Block height: $cur_height"
echo "Waiting to reach block height $stop_height..."
height=0
until [ $height -ge $stop_height ]
do
    sleep 5
    if [ ${test_counter} -gt ${max_tests} ]
    then
        echo "Queried gaia $test_counter times with a 5s wait between queries. A block height of $stop_height was not reached. Exiting."
        exit 2
    fi
    height=$(curl -s http://$gaia_host:$gaia_port/block | jq -r .result.block.header.height)
    if [ -z "$height" ]
    then
        height=0
    fi
    echo "Block height: $height"
    test_counter=$(($test_counter+1))
done
echo "Gaia is producing blocks."