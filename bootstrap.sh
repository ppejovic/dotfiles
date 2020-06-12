#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master --recurse-submodule --no-rebase;

function doIt() {

    rsync --exclude ".git/" \
        --exclude ".DS_Store" \
        --exclude ".osx" \
        --exclude ".gitmodules" \
        --exclude "bootstrap.sh" \
        --exclude "packages.sh" \
        --exclude "README.md" \
        --exclude "LICENSE" \
        -avh --no-perms . ~;

    if [[ $OSTYPE =~ ^darwin ]]; then
        git config --global credential.helper osxkeychain
    elif [[ -n "${WSL_DISTRO_NAME}" ]]; then
        git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager.exe"
    fi
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
    doIt;
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
    echo "";
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        doIt;
    fi;
fi;
unset doIt;