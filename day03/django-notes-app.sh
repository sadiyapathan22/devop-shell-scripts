#!/bin/bash

<<task
Deploy a django app
and handle the code for errors cleanly
task

code_clone(){
        # Check if folder already exists, pull the latest updates instead of cloning
        if [ -d "django-notes-app" ]; then
                echo "The code directory already exists. Pulling latest changes.."
                cd django-notes-app
                git pull
                cd .. # Always move back out so the script stays in day03
        else
                echo "Cloning fresh repository"
                git clone "https://github.com/sadiyapathan22/django-notes-app.git"
        fi
}

install_requirements(){
        # -y automatically answers "Yes" to installation prompts so the script does not freeze
        sudo apt-get install docker.io nginx -y
}

setup_permission()
{
        # Uses grep to check if the current user belongs to the docker group
        if getent group docker | grep -q "\b$USER\b"; then
                echo "User permission verified"
        else
                echo "Adding user to docker group"
                sudo usermod -aG docker $USER
        fi
}

required_restarts(){
        # Enable services for system boot backups
        sudo systemctl enable docker
        sudo systemctl enable nginx
        
        # Immediate service restarts to load configurations instantly
        sudo systemctl restart docker
        sudo systemctl restart nginx
}

deploy(){
        echo "Clearing out old deployments"

        # Grab the container ID on port 8000 and hold it in a variable
        CONTAINER_ID=$(docker ps -q --filter "publish=8000")
        
        # Only run the delete command if the search actually finds an ID means variable is not empty (-n checks for text)
        if [ -n "$CONTAINER_ID" ]; then
                echo "Found active container $CONTAINER_ID on port 8000. Deleting it..."
                docker rm -f "$CONTAINER_ID"
        fi

        echo "Building the new image"
        # -t flag stands for "tag" and is used to name your image
        docker build -t notes-app ./django-notes-app

        echo "Launching the container"
        # -d runs container in background so the terminal stays free
        # -p maps host port 8000 to container port 8000
        # We assign a fixed nickname using --name
        docker run -d --name notes-app-container -p 8000:8000 notes-app:latest
}

echo "****************DEPLOYMENT STARTED***************"
code_clone

if ! install_requirements; then
        echo "Installation failed"
        exit 1
fi

setup_permission

if ! required_restarts; then
        echo "System fault identified"
        exit 1
fi

deploy
echo "**************DEPLOYMENT DONE*****************"

