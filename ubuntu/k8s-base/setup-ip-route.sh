#/bin/bash

ip route add 10.96.0.1/32 dev enp0s8 src $1
