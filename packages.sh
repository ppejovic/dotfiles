#!/usr/bin/env bash

## Repositories
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

MS_DEB=packages-microsoft-prod.deb
curl https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -o $MS_DEB 
sudo dpkg -i $MS_DEB 
rm -f $MS_DEB

## Apps and packages
# apt packages
apps=(
    apt-transport-https
    git
    jq
    openssh-server
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

## Completions
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
