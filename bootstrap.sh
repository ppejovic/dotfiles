#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")"

git pull origin master --recurse-submodule --no-rebase

function do_it() {

    rsync --exclude "wsl.conf" \
        --exclude ".git/" \
        --exclude ".DS_Store" \
        --exclude ".osx" \
        --exclude ".gitignore" \
        --exclude ".gitmodules" \
        --exclude "aws-cli-public-key" \
        --exclude "bootstrap.sh" \
        --exclude "packages.sh" \
        --exclude "README.md" \
        --exclude "LICENSE" \
        -avh --no-perms . ~

    if [[ $OSTYPE =~ ^darwin ]]; then
        git config --global credential.helper osxkeychain
    elif [[ -n "${WSL_DISTRO_NAME}" ]]; then
        WINDOWS_USER=$(/mnt/c/Windows/System32/cmd.exe "/c" "echo %USERNAME%" | tr -d '\r')
        git config --global credential.helper "/mnt/c/Users/$WINDOWS_USER/AppData/Local/Programs/Git/mingw64/libexec/git-core/git-credential-manager-core.exe"
        sudo rsync -avh --no-perms wsl.conf /etc/wsl.conf
    fi
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
    do_it
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        do_it
    fi
fi
unset do_it
