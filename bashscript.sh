#!/bin/bash
sudo apt-get update
sudo apt -y install iperf3
iperf3 -s
