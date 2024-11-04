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

# Prompt for Activation Code and ID
read -p "Enter Activation Code: " activation_code
read -p "Enter Activation ID: " activation_id

# Detect system architecture
ARCH=$(uname -m)

# Uninstall any existing AWS CLI installation
sudo rm -rf /usr/local/aws-cli || true
sudo rm /usr/local/bin/aws || true

# Install AWS CLI v2 based on architecture if not already installed
if ! which aws > /dev/null 2>&1; then
  if [ "$ARCH" = "x86_64" ]; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  elif [ "$ARCH" = "aarch64" ]; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
  else
    echo "Unsupported architecture: $ARCH"
    exit 1
  fi

  unzip awscliv2.zip
  sudo ./aws/install

  # Create symbolic link if it doesn't exist
  if [ ! -L /usr/bin/aws ]; then
    sudo ln -s /usr/local/bin/aws /usr/bin/aws
  fi
fi

# Verify the AWS CLI installation
aws --version

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os=$ID
else
    echo "Unable to detect Linux distribution"
    exit 1
fi

# Install SSM Agent based on the detected OS and architecture
mkdir -p /tmp/ssm
case $os in
    amzn)
        log "Installing SSM agent for Amazon Linux..."
        curl "https://amazon-ssm-$region.s3.$region.amazonaws.com/latest/linux_amd64/ssm-setup-cli" -o /tmp/ssm/ssm-setup-cli
        sudo chmod +x /tmp/ssm/ssm-setup-cli
        sudo /tmp/ssm/ssm-setup-cli -register -activation-code "$activation_code" -activation-id "$activation_id" -region "$region"
        ;;
    rhel|centos)
        if [[ "$version_id" == 6* ]]; then
            log "Installing SSM agent for RHEL/CentOS 6.x..."
            curl "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/3.0.1479.0/linux_amd64/amazon-ssm-agent.rpm" -o /tmp/ssm/amazon-ssm-agent.rpm
            sudo yum install -y /tmp/ssm/amazon-ssm-agent.rpm
            sudo stop amazon-ssm-agent
            sudo -E amazon-ssm-agent -register -code "$activation_code" -id "$activation_id" -region "$region"
            sudo start amazon-ssm-agent
        else
            log "Installing SSM agent for RHEL/CentOS 7.x and later..."
            curl "https://amazon-ssm-$region.s3.$region.amazonaws.com/latest/linux_amd64/ssm-setup-cli" -o /tmp/ssm/ssm-setup-cli
            sudo chmod +x /tmp/ssm/ssm-setup-cli
            sudo /tmp/ssm/ssm-setup-cli -register -activation-code "$activation_code" -activation-id "$activation_id" -region "$region"
        fi
        ;;
    ubuntu|debian)
        log "Installing SSM agent for Ubuntu/Debian..."
        mkdir -p /tmp/ssm
        if [ "$ARCH" = "armv7l" ] || [ "$ARCH" = "aarch64" ]; then
            curl "https://amazon-ssm-$region.s3.$region.amazonaws.com/latest/debian_arm/ssm-setup-cli" -o /tmp/ssm/ssm-setup-cli
        else
            curl "https://amazon-ssm-$region.s3.$region.amazonaws.com/latest/debian_amd64/ssm-setup-cli" -o /tmp/ssm/ssm-setup-cli
        fi
        sudo chmod +x /tmp/ssm/ssm-setup-cli
        sudo /tmp/ssm/ssm-setup-cli -register -activation-code "$activation_code" -activation-id "$activation_id" -region "$region" 2>/dev/null
        ;;
    raspbian)
        log "Installing SSM agent for Raspberry Pi OS..."
        curl "https://amazon-ssm-$region.s3.$region.amazonaws.com/latest/debian_arm/ssm-setup-cli" -o /tmp/ssm/ssm-setup-cli
        sudo chmod +x /tmp/ssm/ssm-setup-cli
        sudo /tmp/ssm/ssm-setup-cli -register -activation-code "$activation_code" -activation-id "$activation_id" -region "$region"
        ;;
    *)
        log "Unsupported Linux distribution: $os"
        exit 1
        ;;
esac

# Stop SSM Agent
echo "Stopping SSM Agent"
sudo systemctl stop amazon-ssm-agent || true

# Register SSM Agent
sudo amazon-ssm-agent -register -code "$activation_code" -id "$activation_id" -region "$region"

# Update KeyAutoRotateDays in SSM Agent config
sudo sed -i 's/"KeyAutoRotateDays": 0/"KeyAutoRotateDays": 1/' /etc/amazon/ssm/amazon-ssm-agent.json.template

# Copy the template to a new config file
sudo cp /etc/amazon/ssm/amazon-ssm-agent.json.template /etc/amazon/ssm/amazon-ssm-agent.json

# Set up AWS credentials directory
sudo mkdir -p /home/$USER/.aws
sudo ln -s /root/.aws/credentials /home/$USER/.aws/credentials
sudo chown -R $USER:$USER /home/$USER/.aws

# Restart and enable SSM Agent
echo "Restarting and enabling SSM Agent"
sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent || true

echo "SSM Agent installation, configuration, and private key auto-rotation setup completed."
