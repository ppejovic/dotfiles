#!/usr/bin/env bash

function is_osx {
    [[ $OSTYPE =~ ^darwin ]]
}

function is_linux {
    [[ $OSTYPE =~ ^linux ]]
}

if is_osx; then
    sudo -v

    # Install Homebrew if not found
    if [[ -z $(command -v brew) ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi

    # Make sure we’re using the latest Homebrew
    brew update

    # Upgrade any already-installed formulae
    brew upgrade

    brew install tree
    brew install jq

elif is_linux; then
    sudo -v

    sudo apt update

    apps=(
        jq
        zsh
        tree
        screenfetch
    )

    sudo apt install "${apps[@]}"

    # Azure cli
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    az extension add --name azure-devops
fi

# zsh
update_shell() {
  local shell_path;
  shell_path="$(command -v zsh)"

  if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi
  chsh -s "$shell_path"
}

if [[ $SHELL != */zsh ]]; then
    update_shell
fi