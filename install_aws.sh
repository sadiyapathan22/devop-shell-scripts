#!/bin/bash

# task
# Connect Aws with shell script by Install Aws CLI
# Launch instance
# Check if instance is in running state
# task

set -euo pipefail

install_aws_cli(){ 
    echo "Installing AWS CLI v2 on Linux..." 
    # Download and install AWS CLI v2 
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" 
    sudo apt-get install -y unzip &> /dev/null 
    unzip -q awscliv2.zip 
    sudo ./aws/install --update 
    # Verify installation 
    aws --version 
    # Clean up 
    rm -rf awscliv2.zip ./aws
}

create_instance(){ 
    echo "Fetching latest Ubuntu 24.04 AMI..." 
    LATEST_UBUNTU_AMI=$(aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" "Name=state,Values=available" --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text) 
    
    echo "Creating Instance using AMI: $LATEST_UBUNTU_AMI" 
    INSTANCE_ID=$(aws ec2 run-instances --image-id "$LATEST_UBUNTU_AMI" --instance-type "t3.micro" --key-name "shell-scripting-for-devops-key" --security-group-ids "sg-03e711da00752e309" --query "Instances[0].InstanceId" --output text) 
    
    if [ -z "$INSTANCE_ID" ]; then 
        echo "Error: Failed to create Instance" 
        exit 1 
    fi 
    echo "Instance created successfully! ID: $INSTANCE_ID"
}

check_instance_state(){ 
    echo "Checking instance state..." 
    #loop continue till instance state will be running 
    while true; do 
        STATE=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].State.Name" --output text) 
        echo "Current status: $STATE" 
        if [ "$STATE" == "running" ]; then 
            echo "Instance created and started running!" 
            break 
        fi 
        echo "Waiting for instance to start... sleeping for 5 seconds" 
        sleep 5 
    done
}

if ! install_aws_cli; then 
    echo "Error in installing Aws CLI" 
    exit 1
fi

if ! create_instance; then 
    echo "Error in creating intance" 
    exit 1
fi

if ! check_instance_state; then 
    echo "State failed" 
    exit 1
fi

