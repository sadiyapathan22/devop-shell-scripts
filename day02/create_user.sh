#!/bin/bash

read -p "Enter username: " username

echo "you entred $username"

sudo useradd -m $username

echo "New User added"
