#!/bin/bash

# Usage: create-cluster.sh user password port local-port space-separated-ips

user=$1
password=$2
port=$3
localPort=$4
ips=$5

firstIp=1

for ip in $ips; do

  if [ "$firstIp" == "1" ]; then

    echo "First IP=$ip"

    firstIp=$ip

  else

    echo "Registering membership for $ip"

    curl -X PUT http://$user:$password@$firstIp:$localPort/_nodes/couchdb@$ip -d {}
    
  fi

  echo "Setting [couch_peruser] enable=true"
   
  curl -X PUT http://$user:$password@$ip:$localPort/_node/couchdb@$ip/_config/couch_peruser/enable -d 'true'

done

# Create system DBs
echo "Creating _users"
curl -X PUT http://$user:$password@$firstIp:$port/_users
echo "Creating _replicator"
curl -X PUT http://$user:$password@$firstIp:$port/_replicator
echo "Creating _global_changes"
curl -X PUT http://$user:$password@$firstIp:$port/_global_changes
