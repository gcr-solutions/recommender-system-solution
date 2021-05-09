#!/usr/bin/env bash

echo "install boto3..."
sudo pip3 install boto3

echo "download install_chronicled.py..."
sudo wget https://raw.githubusercontent.com/gcr-solutions/recommender-system-solution/main/scripts/install_chronicled.py

echo "install chronicled..."
sudo python install_chronicled.py

