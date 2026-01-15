#!/bin/bash

# fn command_exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "=== Starting development tools installation ==="

# --- Docker ---
if command_exists docker; then
    echo "Docker already installed: $(docker --version)"
else
    echo "Installing Docker..."
    # macOS (Homebrew)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install --cask docker
        echo "Docker installed. Please start Docker.app from Applications."
    # Linux (Debian/Ubuntu)
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt update
        sudo apt install -y docker.io
        sudo systemctl enable --now docker
    fi
fi

# --- Docker Compose ---
if command_exists docker-compose; then
    echo "Docker Compose already installed: $(docker-compose --version)"
else
    echo "Installing Docker Compose..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install docker-compose
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
fi

# --- Python ---
if command_exists python3; then
    PY_VER=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    echo "Python is installed: $PY_VER"
else
    echo "Installing Python 3.9+..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install python@3.11
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt update
        sudo apt install -y python3 python3-pip
    fi
fi

# --- Django ---
if python3 -m pip show django >/dev/null 2>&1; then
    echo "Django is already installed: $(python3 -m django --version)"
else
    echo "Installing Django..."
    python3 -m pip install --upgrade pip
    python3 -m pip install django
fi

echo "=== Installation finished! ==="

# Optional: show versions
docker --version 2>/dev/null
docker-compose --version 2>/dev/null
python3 --version
python3 -m django --version
