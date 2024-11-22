#!/bin/bash

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to validate AWS region format
validate_region() {
    if [[ $1 =~ ^[a-z]{2}-[a-z]+-[1-9]{1}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Prompt for AWS region
while true; do
    read -p "Enter AWS region (e.g., us-east-1): " region
    if validate_region "$region"; then
        break
    else
        echo "Invalid region format. Please try again."
    fi
done

# Prompt for Activation Code and ID, and remove spaces
read -p "Enter Activation Code: " raw_activation_code
activation_code=$(echo "$raw_activation_code" | tr -d '[:space:]')

read -p "Enter Activation ID: " raw_activation_id
activation_id=$(echo "$raw_activation_id" | tr -d '[:space:]')

# Log the sanitized inputs
log "Activation Code: '$activation_code' and Activation ID: '$activation_id' have been sanitized."

# Update package lists and install dependencies
log "Updating package lists and installing dependencies..."
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y unzip curl wget
elif command -v yum >/dev/null 2>&1; then
    sudo yum update -y
    sudo yum install -y unzip curl wget
else
    echo "Unsupported package manager. Exiting."
    exit 1
fi

# Remove existing AWS CLI if present
log "Removing existing AWS CLI installations..."
sudo rm -rf /usr/local/aws-cli
sudo rm -f /usr/local/bin/aws
sudo rm -f /usr/bin/aws

# Detect system architecture
ARCH=$(uname -m)
log "Detected architecture: $ARCH"

# Install AWS CLI v2
log "Installing AWS CLI v2..."
if ! command -v aws >/dev/null 2>&1; then
    if [ "$ARCH" = "x86_64" ]; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    elif [ "$ARCH" = "aarch64" ]; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
    else
        echo "Unsupported architecture for AWS CLI: $ARCH"
        exit 1
    fi

    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws/
fi

# Verify AWS CLI installation
log "Verifying AWS CLI installation..."
aws --version || { echo "AWS CLI installation failed."; exit 1; }

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os=$ID
    version_id=$VERSION_ID
    log "Detected OS: $os $version_id"
else
    echo "Unable to detect Linux distribution"
    exit 1
fi

# Install SSM Agent based on architecture and distribution
log "Installing SSM Agent..."
mkdir -p /tmp/ssm

if [[ $os == "amzn" || $os == "centos" || $os == "rhel" ]]; then
    if [[ "$os" == "amzn" ]]; then
        log "Installing SSM Agent for Amazon Linux..."
        curl "https://amazon-ssm-$region.s3.$region.amazonaws.com/latest/linux_amd64/ssm-setup-cli" -o /tmp/ssm/ssm-setup-cli
        sudo chmod +x /tmp/ssm/ssm-setup-cli
        sudo /tmp/ssm/ssm-setup-cli -register -activation-code "$activation_code" -activation-id "$activation_id" -region "$region"
    elif [[ "$os" == "rhel" || "$os" == "centos" ]]; then
        if [[ "$version_id" == 6* ]]; then
            log "Installing SSM Agent for RHEL/CentOS 6.x..."
            curl "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/3.0.1479.0/linux_amd64/amazon-ssm-agent.rpm" -o /tmp/ssm/amazon-ssm-agent.rpm
            sudo yum install -y /tmp/ssm/amazon-ssm-agent.rpm
            sudo stop amazon-ssm-agent
            sudo -E amazon-ssm-agent -register -code "$activation_code" -id "$activation_id" -region "$region"
            sudo start amazon-ssm-agent
        elif [[ "$version_id" == 7* ]]; then
            log "Installing SSM Agent for RHEL/CentOS 7.x..."
            curl "https://amazon-ssm-$region.s3.$region.amazonaws.com/latest/linux_amd64/ssm-setup-cli" -o /tmp/ssm/ssm-setup-cli
            sudo chmod +x /tmp/ssm/ssm-setup-cli
            sudo /tmp/ssm/ssm-setup-cli -register -activation-code "$activation_code" -activation-id "$activation_id" -region "$region"
        elif [[ "$version_id" == 8* ]]; then
            log "Installing SSM Agent for RHEL/CentOS 8.x..."
            curl "https://amazon-ssm-$region.s3.$region.amazonaws.com/latest/linux_amd64/ssm-setup-cli" -o /tmp/ssm/ssm-setup-cli
            sudo chmod +x /tmp/ssm/ssm-setup-cli
            sudo /tmp/ssm/ssm-setup-cli -register -activation-code "$activation_code" -activation-id "$activation_id" -region "$region"
        else
            log "Unsupported version of RHEL/CentOS: $version_id"
            exit 1
        fi
    fi
elif [[ $os == "debian" ]]; then
    log "Installing SSM Agent for Debian..."
    if [ "$ARCH" = "x86_64" ]; then
        curl "https://amazon-ssm-$region.s3.$region.amazonaws.com/latest/debian_amd64/amazon-ssm-agent.deb" -o /tmp/amazon-ssm-agent.deb
    elif [ "$ARCH" = "aarch64" ]; then
        curl "https://s3.us-east-2.amazonaws.com/amazon-ssm-us-east-2/latest/debian_arm64/amazon-ssm-agent.deb" -o /tmp/amazon-ssm-agent.deb
    else
        echo "Unsupported architecture: $ARCH"
        exit 1
    fi
    sudo dpkg -i /tmp/amazon-ssm-agent.deb
    # Add explicit registration for Debian
    sudo amazon-ssm-agent -register -code "$activation_code" -id "$activation_id" -region "$region"
elif [[ $os == "raspbian" ]]; then
    log "Installing SSM Agent for Raspberry Pi OS (ARM 32-bit)..."
    curl "https://amazon-ssm-$region.s3.$region.amazonaws.com/latest/debian_arm/amazon-ssm-agent.deb" -o /tmp/amazon-ssm-agent.deb
    sudo dpkg -i /tmp/amazon-ssm-agent.deb
    # Add explicit registration for Raspbian
    sudo amazon-ssm-agent -register -code "$activation_code" -id "$activation_id" -region "$region"
elif [[ $os == "ubuntu" ]]; then
    log "Installing SSM Agent for Ubuntu..."
    if [ "$ARCH" = "x86_64" ]; then
        curl "https://amazon-ssm-$region.s3.$region.amazonaws.com/latest/debian_amd64/amazon-ssm-agent.deb" -o /tmp/amazon-ssm-agent.deb
    elif [ "$ARCH" = "aarch64" ]; then
        curl "https://s3.us-east-2.amazonaws.com/amazon-ssm-us-east-2/latest/debian_arm64/amazon-ssm-agent.deb" -o /tmp/amazon-ssm-agent.deb
    else
        echo "Unsupported architecture: $ARCH"
        exit 1
    fi
    sudo dpkg -i /tmp/amazon-ssm-agent.deb
    # Add explicit registration for Ubuntu
    sudo amazon-ssm-agent -register -code "$activation_code" -id "$activation_id" -region "$region"
else
    log "Unsupported Linux distribution: $os"
    exit 1
fi

# Prompt for KeyAutoRotateDays
read -p "Enter the number of days for KeyAutoRotateDays (default: 1): " key_auto_rotate_days
key_auto_rotate_days=${key_auto_rotate_days:-1}

# Update KeyAutoRotateDays in the SSM Agent config template
log "Updating KeyAutoRotateDays to $key_auto_rotate_days in the SSM Agent config template..."
SSM_CONFIG_TEMPLATE="/etc/amazon/ssm/amazon-ssm-agent.json.template"
SSM_CONFIG="/etc/amazon/ssm/amazon-ssm-agent.json"

if [ -f "$SSM_CONFIG_TEMPLATE" ]; then
    sudo sed -i "s/\"KeyAutoRotateDays\": [0-9]\+/\"KeyAutoRotateDays\": $key_auto_rotate_days/" "$SSM_CONFIG_TEMPLATE"
    log "KeyAutoRotateDays updated in the template."

    # Copy the updated template to the main config file
    sudo cp "$SSM_CONFIG_TEMPLATE" "$SSM_CONFIG"
else
    log "SSM Agent config template not found. Creating a new config with KeyAutoRotateDays set to $key_auto_rotate_days..."
    sudo tee "$SSM_CONFIG" > /dev/null << EOF
{
    "KeyAutoRotateDays": $key_auto_rotate_days
}
EOF
fi

# Restart and enable SSM Agent
log "Restarting and enabling SSM Agent..."
sudo systemctl restart amazon-ssm-agent || true
sudo systemctl enable amazon-ssm-agent || true

log "SSM Agent installation, configuration, and private key auto-rotation setup completed successfully."
