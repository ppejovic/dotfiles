#!/usr/bin/env bash

function is_osx() {
    [[ $OSTYPE =~ ^darwin ]]
}

function is_linux() {
    [[ $OSTYPE =~ ^linux ]]
}

sudo -v

if is_osx; then

    # Install Homebrew if not found
    if [[ -z $(command -v brew) ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi
    
    # Make sure we’re using the latest Homebrew
    brew update
    
    # Upgrade any already-installed formulae
    brew upgrade

    brew install tree \
                 jq   \
                 tmux \
                 nmap \
                 telnet

    # Homebrew formulae
    brew cask install aws-vault

    pushd /tmp

    # AWS cli
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    sudo installer -pkg ./AWSCLIV2.pkg -target /

    popd

elif is_linux; then

    ## Repositories
    sudo apt-add-repository --yes --update ppa:ansible/ansible

    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    
    # apt packages
    apps=(
        ansible
        jq
        pass
        python3-pip
        screenfetch
        software-properties-common
        terraform
        tree
        vault
        unzip
        wget
        zip
        zsh
    )

    sudo apt-get update && sudo apt-get install "${apps[@]}" -yi
    sudo apt-get upgrade && sudo apt-get autoremove 
    
    # Azure cli
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    az extension add --name azure-devops

    pushd /tmp/

    # AWS cli
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -o awscliv2.zip
    sudo ./aws/install --update

    popd

    # AWS Global Tool for dotnet
    dotnet tool update -g Amazon.Lambda.Tools

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
