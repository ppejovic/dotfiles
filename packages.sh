#!/usr/bin/env bash

function is_osx() {
    [[ $OSTYPE =~ ^darwin ]]
}

function is_linux() {
    [[ $OSTYPE =~ ^linux ]]
}

sudo -v

# Install Homebrew if not found
if [[ -z $(command -v brew) ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    if is_linux; then
        test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
        test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
        echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.zprofile
    fi
fi

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

if is_osx; then

    brew install tree
    brew install jq
    brew install tmux

elif is_linux; then
    sudo apt update

    # Homebrew formulae
    brew install aws-vault

    # apt packages
    apps=(
        software-properties-common
	    jq
        zsh
        zip
        unzip
        tree
        screenfetch
        wget
        python3-pip
    )

    sudo apt install "${apps[@]}" -y

    # Ansible
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt install ansible

    # Azure cli
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    az extension add --name azure-devops

    pushd /tmp/

    # AWS cli
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -o awscliv2.zip
    sudo ./aws/install --update

    # AWS Global Tool for dotnet
    dotnet tool update -g Amazon.Lambda.Tools

    # Terraform
    TERR_VER=`curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | cut -d: -f2 | tr -d \"\,\v | awk '{$1=$1};1'`
    wget https://releases.hashicorp.com/terraform/${TERR_VER}/terraform_${TERR_VER}_linux_amd64.zip
    unzip terraform_${TERR_VER}_linux_amd64.zip
    sudo mv terraform /usr/local/bin
    
    popd

fi

# zsh
update_shell() {
    local shell_path
    shell_path="$(command -v zsh)"

    if ! grep "$shell_path" /etc/shells >/dev/null 2>&1; then
        sudo sh -c "echo $shell_path >> /etc/shells"
    fi
    chsh -s "$shell_path"
}

if [[ $SHELL != */zsh ]]; then
    update_shell
fi
