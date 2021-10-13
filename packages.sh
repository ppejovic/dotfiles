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

    brew install hashicorp/tap/terraform

    brew install azure-cli \
                 hashicorp/tap/terraform \
                 helm \
                 jq   \
                 kubernetes-cli \
                 minikube \
                 nmap \
                 pandoc \
                 pandoc-citeproc \
                 telnet \
                 tmux \
                 tree 

    
    # Homebrew formulae
    brew install --cask aws-vault \
                        zettlr \
                        basictex

    # Azure cli
    az extension add --name azure-devops

    pushd /tmp

    # AWS cli
    curl https://awscli.amazonaws.com/AWSCLIV2.pkg -o AWSCLIV2.pkg
    sudo installer -pkg ./AWSCLIV2.pkg -target /

    # Dotnet
    curl https://download.visualstudio.microsoft.com/download/pr/0a7fa783-02e1-4785-b7b1-3c430f8825dc/764e53ff2f5722bc1b8bbc178fe25930/dotnet-sdk-5.0.101-osx-x64.pkg \
        -o dotnet-sdk.pkg
    sudo installer -pkg ./dotnet-sdk.pkg -target /

    popd

elif is_linux; then

    ## Repositories
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

    MS_DEB=packages-microsoft-prod.deb
    curl https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -o $MS_DEB 
    sudo dpkg -i $MS_DEB 
    rm -f $MS_DEB

    # apt packages
    apps=(
        apt-transport-https
        dotnet-sdk-5.0
	    git
        jq
        pass
        python3-pip
        software-properties-common
        terraform
        tree
        unzip
        wget
        zip
        zsh
    )

    sudo apt-get update && sudo apt-get install "${apps[@]}" -y
    sudo apt-get upgrade && sudo apt-get autoremove 
    
    # Import AWS cli public key
    gpg --import aws-cli-public-key

    pushd /tmp/

    # AWS cli
    curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig -o awscliv2.sig 
    curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip

    gpg --verify awscliv2.sig awscliv2.zip

    unzip -o awscliv2.zip
    sudo ./aws/install --update

    popd

    # PowerShell as dotnet global tool
    dotnet tool update -g PowerShell
fi

mkdir -p ~/.zsh/completion

# Docker completion
curl -L https://raw.githubusercontent.com/docker/compose/1.28.2/contrib/completion/zsh/_docker-compose > ~/.zsh/completion/_docker-compose

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
