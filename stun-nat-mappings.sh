#!/bin/bash


## Install coturn and turnutils package
##apt-get update && apt install coturn


STUN_IP='stun.l.google.com'
STUN_PORT='19302'

PUBLIC_IP=`turnutils_natdiscovery -p $STUN_PORT $STUN_IP -m | grep 'UDP reflexive addr' | cut -d ':' -f 3`

PUBLIC_PORT=`turnutils_natdiscovery -p $STUN_PORT $STUN_IP -m | grep 'UDP reflexive addr' | cut -d ':' -f 4` 
echo $PUBLIC_IP
echo $PUBLIC_PORT

PRIVATE_IP=`turnutils_natdiscovery -p $STUN_PORT $STUN_IP -m | grep 'Local addr' | cut -d ':' -f 4` 
PRIVATE_PORT=`turnutils_natdiscovery -p $STUN_PORT $STUN_IP -m | grep 'Local addr' | cut -d ':' -f 5` 

echo $PRIVATE_IP
echo $PRIVATE_PORT
